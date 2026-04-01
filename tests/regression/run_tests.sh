#!/usr/bin/env bash
# ABOUTME: Regression test runner for the tadg_ie Hugo theme
# ABOUTME: Builds a test site and checks rendered output against expected patterns
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES_DIR="${SCRIPT_DIR}/fixtures"
THEME_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BUILD_OUTPUT="${FIXTURES_DIR}/public"

pass_count=0
fail_count=0
skip_count=0

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() {
    printf "${GREEN}  PASS${NC} %s: %s\n" "$1" "$2"
    pass_count=$((pass_count + 1))
}

fail() {
    printf "${RED}  FAIL${NC} %s: %s\n" "$1" "$2"
    fail_count=$((fail_count + 1))
}

skip() {
    printf "${YELLOW}  SKIP${NC} %s: %s\n" "$1" "$2"
    skip_count=$((skip_count + 1))
}

# --- Build test site ---
echo "Building test site..."
rm -rf "${BUILD_OUTPUT}"

if ! hugo_output=$(hugo --source "${FIXTURES_DIR}" --quiet 2>&1); then
    echo "Hugo build failed:"
    echo "${hugo_output}"
    exit 1
fi

echo "Build complete. Running tests..."
echo ""

# --- RT-001: Local video path renders HTML5 <video> element ---
test_id="RT-001"
test_file="${BUILD_OUTPUT}/test-pages/local-video/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q '<video' "${test_file}" && grep -q '<source src="/videos/test.mp4"' "${test_file}"; then
        pass "${test_id}" "Local video path renders HTML5 <video> element"
    else
        fail "${test_id}" "Local video path does not render <video> with correct source"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-002: CF Stream UID renders iframe with correct URL ---
test_id="RT-002"
test_file="${BUILD_OUTPUT}/test-pages/cfstream-video/index.html"
if [[ -f "${test_file}" ]]; then
    expected_src="https://customer-TESTCODE.cloudflarestream.com/ea95132c15732412d22c1476fa83f27a/iframe"
    if grep -q '<iframe' "${test_file}" && grep -q "${expected_src}" "${test_file}"; then
        pass "${test_id}" "CF Stream UID renders iframe with correct embed URL"
    else
        fail "${test_id}" "CF Stream UID does not render correct iframe URL"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-003: Optional params forwarded as querystring ---
test_id="RT-003"
test_file="${BUILD_OUTPUT}/test-pages/cfstream-params/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'autoplay=true' "${test_file}" && grep -q 'muted=true' "${test_file}"; then
        pass "${test_id}" "Optional params forwarded as querystring arguments"
    else
        fail "${test_id}" "Optional params not found in iframe src querystring"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-004: CF Stream iframe has loading="lazy" ---
test_id="RT-004"
test_file="${BUILD_OUTPUT}/test-pages/cfstream-video/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'loading="lazy"' "${test_file}"; then
        pass "${test_id}" "CF Stream iframe has loading=\"lazy\""
    else
        fail "${test_id}" "CF Stream iframe missing loading=\"lazy\""
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-005: Responsive container has cfstream-container class ---
test_id="RT-005"
test_file="${BUILD_OUTPUT}/test-pages/cfstream-video/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'cfstream-container' "${test_file}"; then
        pass "${test_id}" "Responsive container has cfstream-container class"
    else
        fail "${test_id}" "cfstream-container class not found in output"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-006: Missing customerCode produces warning ---
# This test builds a separate site without customerCode config
test_id="RT-006"
no_config_dir=$(mktemp -d)
trap 'rm -rf "${no_config_dir}"' EXIT

mkdir -p "${no_config_dir}/content/test-pages" "${no_config_dir}/themes"
ln -sf "${THEME_DIR}" "${no_config_dir}/themes/tadg_ie"

cat > "${no_config_dir}/hugo.yaml" <<'YAMLEOF'
baseURL: https://test.example.com/
title: Test Site No Config
theme: tadg_ie
YAMLEOF

cat > "${no_config_dir}/content/test-pages/cfstream-no-config.md" <<'MDEOF'
---
title: No Config Test
---

{{< video "ea95132c15732412d22c1476fa83f27a" >}}
MDEOF

no_config_output=$(hugo --source "${no_config_dir}" 2>&1 || true)
no_config_html="${no_config_dir}/public/test-pages/cfstream-no-config/index.html"

if echo "${no_config_output}" | grep -qi 'customerCode\|cloudflareStream'; then
    pass "${test_id}" "Missing customerCode produces Hugo warning"
elif [[ -f "${no_config_html}" ]] && grep -qi 'customerCode\|cloudflareStream\|error\|warning\|missing' "${no_config_html}"; then
    pass "${test_id}" "Missing customerCode produces visible warning in output"
else
    fail "${test_id}" "No warning produced for missing customerCode"
fi

# --- RT-007: Documentation covers both modes ---
test_id="RT-007"
shortcodes_doc="${THEME_DIR}/docs/shortcodes.md"
readme_doc="${THEME_DIR}/README.md"
rt007_pass=true

if [[ -f "${shortcodes_doc}" ]]; then
    # Must specifically document CF Stream in the video shortcode section, not just mention Cloudflare elsewhere
    if ! grep -qi 'cloudflare stream' "${shortcodes_doc}"; then
        fail "${test_id}" "docs/shortcodes.md does not document Cloudflare Stream video support"
        rt007_pass=false
    elif ! grep -q 'customerCode' "${shortcodes_doc}"; then
        fail "${test_id}" "docs/shortcodes.md does not document customerCode config"
        rt007_pass=false
    fi
else
    fail "${test_id}" "docs/shortcodes.md not found"
    rt007_pass=false
fi

if [[ -f "${readme_doc}" ]]; then
    if ! grep -qi 'cloudflare stream' "${readme_doc}"; then
        fail "${test_id}" "README.md does not reference Cloudflare Stream video support"
        rt007_pass=false
    fi
else
    fail "${test_id}" "README.md not found"
    rt007_pass=false
fi

if [[ "${rt007_pass}" == "true" ]]; then
    pass "${test_id}" "Documentation covers Cloudflare Stream in shortcodes.md and README.md"
fi

# =============================================================================
# Issue #43: Video in page layouts
# =============================================================================

# --- RT-43.1: Hero page with video.id contains a CF Stream player ---
test_id="RT-43.1"
test_file="${BUILD_OUTPUT}/test-pages/hero-video/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'post-hero' "${test_file}" && grep -q 'cfstream-container' "${test_file}"; then
        pass "${test_id}" "Hero with video.id contains CF Stream player in post-hero"
    else
        fail "${test_id}" "Hero with video.id missing cfstream-container in post-hero"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.2: Hero page with video.id does not contain image in media slot ---
test_id="RT-43.2"
test_file="${BUILD_OUTPUT}/test-pages/hero-video/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'post-hero' "${test_file}" && ! grep -q '<img' "${test_file}"; then
        pass "${test_id}" "Hero with video.id does not render an image"
    else
        fail "${test_id}" "Hero with video.id unexpectedly contains an <img>"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.3: Hero page with image.src still renders image (regression) ---
test_id="RT-43.3"
test_file="${BUILD_OUTPUT}/test-pages/hero-image/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'post-hero' "${test_file}" && grep -q '<img' "${test_file}"; then
        pass "${test_id}" "Hero with image.src still renders image (regression)"
    else
        fail "${test_id}" "Hero with image.src does not render image"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.4: Columns-left with video.id contains CF Stream player ---
test_id="RT-43.4"
test_file="${BUILD_OUTPUT}/test-pages/columns-left-video/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'featured-image-col' "${test_file}" && grep -q 'cfstream-container' "${test_file}"; then
        pass "${test_id}" "Columns-left with video.id contains CF Stream player"
    else
        fail "${test_id}" "Columns-left with video.id missing cfstream-container"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.5: Columns-right with video.id contains CF Stream player ---
test_id="RT-43.5"
test_file="${BUILD_OUTPUT}/test-pages/columns-right-video/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'featured-image-col' "${test_file}" && grep -q 'cfstream-container' "${test_file}"; then
        pass "${test_id}" "Columns-right with video.id contains CF Stream player"
    else
        fail "${test_id}" "Columns-right with video.id missing cfstream-container"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.6: Columns with image.src still renders image (regression) ---
test_id="RT-43.6"
test_file="${BUILD_OUTPUT}/test-pages/columns-image/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'featured-image-col' "${test_file}" && grep -q '<img' "${test_file}"; then
        pass "${test_id}" "Columns with image.src still renders image (regression)"
    else
        fail "${test_id}" "Columns with image.src does not render image"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.7: Featured with video.id contains CF Stream player ---
test_id="RT-43.7"
test_file="${BUILD_OUTPUT}/test-pages/featured-video/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'post-featured' "${test_file}" && grep -q 'cfstream-container' "${test_file}"; then
        pass "${test_id}" "Featured with video.id contains CF Stream player"
    else
        fail "${test_id}" "Featured with video.id missing cfstream-container"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.8: Featured with image.src still renders image (regression) ---
test_id="RT-43.8"
test_file="${BUILD_OUTPUT}/test-pages/featured-image/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'post-featured' "${test_file}" && grep -q '<img' "${test_file}"; then
        pass "${test_id}" "Featured with image.src still renders image (regression)"
    else
        fail "${test_id}" "Featured with image.src does not render image"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.9: Video params forwarded (autoplay, muted) ---
test_id="RT-43.9"
test_file="${BUILD_OUTPUT}/test-pages/hero-video-params/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'autoplay=true' "${test_file}" && grep -q 'muted=true' "${test_file}"; then
        pass "${test_id}" "Video params autoplay and muted forwarded to iframe src"
    else
        fail "${test_id}" "Video params not found in iframe src"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.10: No querystring when no optional params set ---
test_id="RT-43.10"
test_file="${BUILD_OUTPUT}/test-pages/hero-video-noparams/index.html"
if [[ -f "${test_file}" ]]; then
    # The iframe src should end with /iframe" (no ?)
    if grep -q 'cfstream-container' "${test_file}" && ! grep -q 'iframe?' "${test_file}"; then
        pass "${test_id}" "No querystring when no optional params set"
    else
        fail "${test_id}" "Unexpected querystring in iframe src"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.16: Value-type param startTime forwarded ---
test_id="RT-43.16"
test_file="${BUILD_OUTPUT}/test-pages/hero-video-starttime/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'startTime=5' "${test_file}"; then
        pass "${test_id}" "Value-type param startTime=5 forwarded to iframe src"
    else
        fail "${test_id}" "startTime=5 not found in iframe src"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.22: Boolean params set to false are NOT forwarded to iframe src ---
test_id="RT-43.22"
test_file="${BUILD_OUTPUT}/test-pages/hero-video-false-params/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'cfstream-container' "${test_file}" \
        && ! grep -q 'autoplay=' "${test_file}" \
        && ! grep -q 'muted=' "${test_file}" \
        && ! grep -q 'loop=' "${test_file}"; then
        pass "${test_id}" "Params set to false are not forwarded in iframe src"
    else
        fail "${test_id}" "False-valued param(s) unexpectedly present in iframe src (or player missing)"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.18: Frontmatter width/height produce correct aspect-ratio style ---
test_id="RT-43.18"
test_file="${BUILD_OUTPUT}/test-pages/hero-video-inv-frontmatter/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'style="aspect-ratio: 640 / 480;"' "${test_file}"; then
        pass "${test_id}" "Frontmatter width/height produce aspect-ratio: 640 / 480"
    else
        fail "${test_id}" "Expected aspect-ratio: 640 / 480 not found in cfstream-container"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.19: Inventory lookup produces correct aspect-ratio when no frontmatter dims ---
test_id="RT-43.19"
test_file="${BUILD_OUTPUT}/test-pages/hero-video-inv-lookup/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'style="aspect-ratio: 1080 / 1920;"' "${test_file}"; then
        pass "${test_id}" "Inventory lookup produces aspect-ratio: 1080 / 1920"
    else
        fail "${test_id}" "Expected aspect-ratio: 1080 / 1920 from inventory not found"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.20: Frontmatter dims take precedence over inventory ---
test_id="RT-43.20"
test_file="${BUILD_OUTPUT}/test-pages/hero-video-inv-frontmatter/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'style="aspect-ratio: 640 / 480;"' "${test_file}" \
        && ! grep -q 'aspect-ratio: 1920 / 1080' "${test_file}"; then
        pass "${test_id}" "Frontmatter dims (640/480) override inventory dims (1920/1080)"
    else
        fail "${test_id}" "Inventory dims leaked through despite frontmatter override"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.21: No inline aspect-ratio when no frontmatter dims and UID not in inventory ---
test_id="RT-43.21"
test_file="${BUILD_OUTPUT}/test-pages/hero-video-noparams/index.html"
if [[ -f "${test_file}" ]]; then
    # Player must render; container must have no inline style attribute
    if grep -q 'cfstream-container' "${test_file}" \
        && ! grep -q 'cfstream-container.*style=' "${test_file}"; then
        pass "${test_id}" "No inline aspect-ratio style when dims unavailable (16:9 CSS default applies)"
    else
        fail "${test_id}" "Unexpected inline style on cfstream-container or player missing"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.11: Banner with video.id does NOT contain CF Stream player ---
test_id="RT-43.11"
test_file="${BUILD_OUTPUT}/test-pages/banner-video/index.html"
if [[ -f "${test_file}" ]]; then
    if ! grep -q 'cfstream-container' "${test_file}"; then
        pass "${test_id}" "Banner with video.id does not render CF Stream player"
    else
        fail "${test_id}" "Banner with video.id unexpectedly contains cfstream-container"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.12: Background default with video.id does NOT contain CF Stream player ---
test_id="RT-43.12"
test_file="${BUILD_OUTPUT}/test-pages/background-video/index.html"
if [[ -f "${test_file}" ]]; then
    if ! grep -q 'cfstream-container' "${test_file}"; then
        pass "${test_id}" "Background with video.id does not render CF Stream player"
    else
        fail "${test_id}" "Background with video.id unexpectedly contains cfstream-container"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.13: Hero with both video and image → video wins ---
test_id="RT-43.13"
test_file="${BUILD_OUTPUT}/test-pages/hero-both/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'cfstream-container' "${test_file}" && ! grep -q '<img' "${test_file}"; then
        pass "${test_id}" "Hero with both video+image: video takes precedence"
    else
        fail "${test_id}" "Hero with both video+image: video did not take precedence"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.14: Shortcode with positional CF Stream UID (regression) ---
test_id="RT-43.14"
test_file="${BUILD_OUTPUT}/test-pages/cfstream-video/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'cfstream-container' "${test_file}" && grep -q '<iframe' "${test_file}"; then
        pass "${test_id}" "Shortcode with positional UID renders CF Stream player (regression)"
    else
        fail "${test_id}" "Shortcode with positional UID does not render CF Stream player"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.15: Shortcode with local file path (regression) ---
test_id="RT-43.15"
test_file="${BUILD_OUTPUT}/test-pages/local-video/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q '<video' "${test_file}" && grep -q '<source' "${test_file}"; then
        pass "${test_id}" "Shortcode with local file path renders HTML5 video (regression)"
    else
        fail "${test_id}" "Shortcode with local file path does not render HTML5 video"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-43.17: Shortcode with named id param (regression) ---
test_id="RT-43.17"
test_file="${BUILD_OUTPUT}/test-pages/cfstream-params/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'cfstream-container' "${test_file}" && grep -q '<iframe' "${test_file}"; then
        pass "${test_id}" "Shortcode with named id param renders CF Stream player (regression)"
    else
        fail "${test_id}" "Shortcode with named id param does not render CF Stream player"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# =============================================================================
# Issue #45: poster_image parameter for CF Stream embeds
# =============================================================================

# --- RT-45.1: Relative poster_image resolved to page-bundle absolute URL ---
test_id="RT-45.1"
test_file="${BUILD_OUTPUT}/test-pages/video-poster-relative/index.html"
expected_poster="poster=https://test.example.com/test-pages/video-poster-relative/toast.jpg"
if [[ -f "${test_file}" ]]; then
    if grep -q "${expected_poster}" "${test_file}"; then
        pass "${test_id}" "Relative poster_image resolved to page-bundle absolute URL"
    else
        fail "${test_id}" "Expected '${expected_poster}' not found in iframe src"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-45.2: Site-root-relative poster_image resolved to absolute URL ---
test_id="RT-45.2"
test_file="${BUILD_OUTPUT}/test-pages/video-poster-root/index.html"
expected_poster="poster=https://test.example.com/images/thumb.jpg"
if [[ -f "${test_file}" ]]; then
    if grep -q "${expected_poster}" "${test_file}"; then
        pass "${test_id}" "Root-relative poster_image resolved to absolute URL"
    else
        fail "${test_id}" "Expected '${expected_poster}' not found in iframe src"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-45.3: Absolute poster_image URL used verbatim ---
test_id="RT-45.3"
test_file="${BUILD_OUTPUT}/test-pages/video-poster-absolute/index.html"
expected_poster="poster=https://cdn.example.com/thumb.jpg"
if [[ -f "${test_file}" ]]; then
    if grep -q "${expected_poster}" "${test_file}"; then
        pass "${test_id}" "Absolute poster_image URL used verbatim"
    else
        fail "${test_id}" "Expected '${expected_poster}' not found in iframe src"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-45.4: No poster_image → no poster= param in iframe src ---
test_id="RT-45.4"
test_file="${BUILD_OUTPUT}/test-pages/video-poster-none/index.html"
if [[ -f "${test_file}" ]]; then
    if grep -q 'cfstream-container' "${test_file}" && ! grep -q 'poster=' "${test_file}"; then
        pass "${test_id}" "No poster_image → no poster= param in iframe src"
    else
        fail "${test_id}" "Unexpected poster= param found or player missing"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-45.5: Shortcode poster_image resolved to page-bundle absolute URL ---
test_id="RT-45.5"
test_file="${BUILD_OUTPUT}/test-pages/video-poster-shortcode/index.html"
expected_poster="poster=https://test.example.com/test-pages/video-poster-shortcode/toast.jpg"
if [[ -f "${test_file}" ]]; then
    if grep -q "${expected_poster}" "${test_file}"; then
        pass "${test_id}" "Shortcode poster_image resolved to page-bundle absolute URL"
    else
        fail "${test_id}" "Expected '${expected_poster}' not found in iframe src"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-45.6: No frontmatter poster_image → inventory poster_image used ---
test_id="RT-45.6"
test_file="${BUILD_OUTPUT}/test-pages/video-poster-inv-lookup/index.html"
expected_poster="poster=https://test.example.com/inventory/poster.jpg"
if [[ -f "${test_file}" ]]; then
    if grep -q "${expected_poster}" "${test_file}"; then
        pass "${test_id}" "Inventory poster_image used when no frontmatter poster_image"
    else
        fail "${test_id}" "Expected '${expected_poster}' not found in iframe src"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- RT-45.7: Frontmatter poster_image overrides inventory poster_image ---
test_id="RT-45.7"
test_file="${BUILD_OUTPUT}/test-pages/video-poster-inv-override/index.html"
expected_poster="poster=https://test.example.com/test-pages/video-poster-inv-override/toast.jpg"
unexpected_poster="poster=https://test.example.com/inventory/poster-override.jpg"
if [[ -f "${test_file}" ]]; then
    if grep -q "${expected_poster}" "${test_file}" && ! grep -q "${unexpected_poster}" "${test_file}"; then
        pass "${test_id}" "Frontmatter poster_image takes precedence over inventory poster_image"
    else
        fail "${test_id}" "Frontmatter poster_image did not override inventory poster_image"
    fi
else
    fail "${test_id}" "Test page not found: ${test_file}"
fi

# --- Summary ---
echo ""
total=$((pass_count + fail_count + skip_count))
echo "Results: ${pass_count} passed, ${fail_count} failed, ${skip_count} skipped (${total} total)"

if [[ ${fail_count} -gt 0 ]]; then
    exit 1
fi
