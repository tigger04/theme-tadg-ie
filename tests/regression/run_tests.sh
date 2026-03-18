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

# --- Summary ---
echo ""
total=$((pass_count + fail_count + skip_count))
echo "Results: ${pass_count} passed, ${fail_count} failed, ${skip_count} skipped (${total} total)"

if [[ ${fail_count} -gt 0 ]]; then
    exit 1
fi
