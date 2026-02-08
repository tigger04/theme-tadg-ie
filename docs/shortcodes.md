# Shortcodes Reference

The tadg_ie theme provides 15 custom shortcodes for varied content types.

## Table of Contents

1. [callout](#callout) — Styled alert/notice boxes
2. [colorbold](#colorbold) — Inline accent-coloured bold text
3. [details](#details) — Collapsible content
4. [dialogue](#dialogue) — Character speech for plays
5. [direction](#direction) — Stage directions
6. [ga](#ga) — Inline Irish language text
7. [popquote](#popquote) — Expandable quotes
8. [poem](#poem) — Poetry with preserved line breaks
9. [video](#video) — HTML5 video player
10. [contactform](#contactform) — Self-hosted contact form with CAPTCHA
11. [formspree](#formspree) — Formspree-backed contact form
12. [rawhtml](#rawhtml) — Raw HTML pass-through
13. [section-list](#section-list) — Section navigation list
14. [img](#img) — Inline image with responsive thumbnails
15. [gallery](#gallery) — Image gallery with lightbox

---

## callout

Styled alert/callout boxes with colour-coded types.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `type` | Yes | One of: `tip`, `alert`, `warning`, `custom` |
| `text` | Yes | Message content |
| `title` | No | Custom title (only for `type="custom"`) |
| `style` | No | Inline CSS (only for `type="custom"`) |

### Usage

```markdown
{{< callout type="tip" text="This is a helpful tip!" >}}
{{< callout type="alert" text="Important alert message" >}}
{{< callout type="warning" text="Warning message" >}}
{{< callout type="custom" title="Custom Title" text="Custom message" style="background: #fee;" >}}
```

### Visual Examples

<!-- screenshot: callout-tip — tip callout in light mode -->
<!-- screenshot: callout-alert — alert callout in light mode -->
<!-- screenshot: callout-warning — warning callout in light mode -->
<!-- screenshot: callout-custom — custom callout with title and style -->

---

## colorbold

Inline text rendered in the secondary accent colour (`--color-secondary`) and bold. Underlined by default. Designed for emphasis within a sentence.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| First positional or `text` | Yes | Text to display |
| `underlined` | No | Set to `"false"` to remove underline (default: `true`) |

### Usage

```markdown
Are these only {{< colorbold "words" >}} I'm meant to frame?
This has {{< colorbold text="no underline" underlined=false >}} here.
```

### Visual Examples

<!-- screenshot: colorbold — inline colorbold with underline -->
<!-- screenshot: colorbold-no-underline — inline colorbold without underline -->

---

## details

Collapsible content block. Closed state shows an ellipsis hint; open state reveals full content.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| First positional | Yes | Summary/title text (supports markdown) |
| Inner content | Yes | Body content (supports markdown) |

### Usage

```markdown
{{< details "Click to expand" >}}
Hidden content goes here.
Can include **markdown**.
{{< /details >}}
```

### Visual Examples

<!-- screenshot: details-closed — collapsed details element -->
<!-- screenshot: details-open — expanded details element -->

---

## dialogue

Character speech for plays and screenplays. Character name renders in small caps with optional parenthetical (delivery direction) in italics.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| First positional or `name` | Yes | Character name |
| Second positional or `parenthetical` | No | Delivery direction |
| Inner content | Yes | Dialogue text |

Supports both positional and named parameters.

### Usage

```markdown
{{< dialogue "TOM" "pleading" >}}Please don't shake off the water!{{< /dialogue >}}
{{< dialogue "ALISON" >}}You've waited since yesterday, Tom.{{< /dialogue >}}
{{< dialogue name="BAYANI" parenthetical="chuckling" >}}Oh is that all?{{< /dialogue >}}
```

### Visual Examples

<!-- screenshot: dialogue-with-parenthetical — dialogue with character name and delivery direction -->
<!-- screenshot: dialogue-without-parenthetical — dialogue with character name only -->

---

## direction

Stage directions for plays. Renders in italics with secondary accent colour.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| Inner content | Yes | Stage direction text (supports markdown) |

### Usage

```markdown
{{< direction >}}A bare stage. Single chair centre. TOM enters.{{< /direction >}}
{{< direction >}}Pause.{{< /direction >}}
```

### Visual Examples

<!-- screenshot: direction — stage direction in light mode -->
<!-- screenshot: direction-dark — stage direction in dark mode -->

---

## ga

Inline Irish language text. Wraps content in `<span lang="ga">`, triggering the `:lang(ga)` CSS rule which applies Iosevka Gaeilge (wedge serif variant). Use this for Irish words or phrases within English text. For whole articles in Irish, use `contentLang: ga` in front matter instead.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| Inner content | Yes | Irish language text |

### Usage

```markdown
He greeted her with {{</* ga */>}}Dia duit, a chara{{</* /ga */>}} as she entered.
The word {{</* ga */>}}craic{{</* /ga */>}} has no direct English equivalent.
```

### Visual Examples

<!-- screenshot: ga — inline Irish text in Iosevka Gaeilge within English paragraph -->

---

## popquote

Expandable quote using the same collapsible styling as `details`.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| First positional | Yes | Opening/summary text |
| Inner content | Yes | Full quote content (supports markdown) |

### Usage

```markdown
{{< popquote "Opening line..." >}}
Full quote content here.
Multiple paragraphs supported.
{{< /popquote >}}
```

### Visual Examples

<!-- screenshot: popquote-closed — collapsed popquote -->
<!-- screenshot: popquote-open — expanded popquote -->

---

## poem

Poetry formatting with preserved line breaks. Newlines in source convert to `<br />` tags so verse structure is maintained.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| Inner content | Yes | Poem text with line breaks |

### Usage

```markdown
{{< poem >}}
Roses are red,
Violets are blue,
This preserves
Line breaks for you.
{{< /poem >}}
```

### Visual Examples

<!-- screenshot: poem — rendered poem with preserved line breaks -->

---

## video

Embed local video files with native HTML5 player controls.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| First positional | Yes | Video source URL |

### Usage

```markdown
{{< video "/videos/my-video.mp4" >}}
```

### Visual Examples

<!-- screenshot: video — HTML5 video player -->

---

## contactform

Self-hosted contact form with Cloudflare Turnstile CAPTCHA, Worker backend, and optional newsletter signup.

Requires Cloudflare Worker deployment and Hugo configuration. See [contactform.md](contactform.md) for the full setup guide.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `newsletter` | No | Set to `"true"` to show newsletter checkbox |

### Site Configuration Required

```yaml
params:
  contactform:
    worker_url: "https://your-worker.example.workers.dev"
    turnstile_sitekey: "0x..."
```

### Usage

```markdown
{{< contactform >}}
{{< contactform newsletter="true" >}}
```

### Visual Examples

<!-- screenshot: contactform — contact form without newsletter -->
<!-- screenshot: contactform-newsletter — contact form with newsletter checkbox -->

---

## formspree

Contact form using Formspree as the backend. Simpler alternative to `contactform` — no CAPTCHA, no self-hosting required.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `id` | Yes | Formspree form ID |

### Usage

```markdown
{{< formspree id="your-formspree-id" >}}
```

### Visual Examples

<!-- screenshot: formspree — Formspree contact form -->

---

## rawhtml

Pass through raw HTML without markdown processing. Use for embedding widgets, iframes, or any HTML that Hugo's markdown renderer would alter.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| Inner content | Yes | Raw HTML content |

### Usage

```markdown
{{< rawhtml >}}
<div class="custom-widget">
  <iframe src="https://example.com/embed"></iframe>
</div>
{{< /rawhtml >}}
```

### Visual Examples

<!-- screenshot: rawhtml — example of embedded raw HTML -->

---

## section-list

Renders a navigation list of site sections with chevron icons. Behaviour is consistent on any page (homepage, section pages, single pages).

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `sections` | No | Comma-separated section names (defaults to `site.Params.mainSections`) |
| `limit` | No | Number of recent items to show per section |

### Usage

```markdown
{{< section-list >}}
{{< section-list sections="blog,gallery" >}}
{{< section-list limit="3" >}}
```

### Visual Examples

<!-- screenshot: section-list — section navigation list -->
<!-- screenshot: section-list-limit — section list with recent items -->

---

## img

Inline image for embedding within article text. Generates responsive thumbnails with WebP support, matching gallery behaviour.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `src` | Yes | Image filename (from page resources) |
| `alt` | Yes | Alt text for accessibility |
| `caption` | No | Caption text below image |
| `position` | No | Placement: `left`, `right` (default), or `center` |
| `width` | No | Width when floated (default: `40%`) |
| `blur` | No | Set to `"true"` for blurred caption background |
| `opacity` | No | Caption background opacity override |

### Usage

```markdown
{{< img src="photo.jpg" alt="A scenic view" >}}
{{< img src="portrait.jpg" alt="Author" caption="Photo by Jane" position="left" >}}
{{< img src="hero.jpg" alt="Banner" position="center" width="80%" >}}
{{< img src="mood.jpg" alt="Atmosphere" caption="Dreamy" blur="true" opacity="0.7" >}}
```

### Visual Examples

<!-- screenshot: img-right — inline image floated right -->
<!-- screenshot: img-left — inline image floated left -->
<!-- screenshot: img-center — centered inline image -->
<!-- screenshot: img-caption-blur — image with blurred caption -->

---

## gallery

Displays page image resources as a responsive gallery with lightbox support.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `exclude` | No | Comma-separated filenames to exclude from gallery |

### Metadata Priority

1. Frontmatter resource params (`title`, `caption`, `alt`, `weight`)
2. EXIF data (`DocumentName` → title, `ImageDescription` → caption)
3. Filename (fallback)

### Frontmatter Configuration

```yaml
resources:
  - src: "*.jpg"
    params:
      weight: 10
  - src: "special.jpg"
    params:
      title: "Custom Title"
      caption: "Custom caption"
```

### Usage

```markdown
{{< gallery >}}
{{< gallery exclude="hero.jpg" >}}
{{< gallery exclude="inline1.jpg,inline2.jpg" >}}
```

Use `exclude` when you have images displayed inline (via `img` shortcode) that you don't want duplicated in the gallery grid.

### Visual Examples

<!-- screenshot: gallery — gallery grid in light mode -->
<!-- screenshot: gallery-lightbox — lightbox view with caption -->
<!-- screenshot: gallery-dark — gallery grid in dark mode -->

---

## Screenshot Key

Screenshots are captured from the [live demo site](https://tadg.ie) and placed in `screenshots/shortcodes/`. Each screenshot placeholder above follows the naming convention `screenshots/shortcodes/{name}.png`.

To contribute screenshots, capture them at 1200px viewport width in both light and dark mode where applicable.
