---
title: "Shortcode Showcase"
date: 2025-12-01
description: "A comprehensive demonstration of every shortcode available in the tadg_ie theme."
tags:
  - theme
  - shortcodes
  - reference
toc: "Shortcodes"
---

This page demonstrates every shortcode available in the tadg_ie theme. Use it as a visual reference.

## Colorbold

Inline highlighted text in the theme's secondary accent colour:

This recipe calls for {{< colorbold "really good butter" >}} — the kind from a farmers' market.

Without the underline: {{< colorbold text="no underline here" underlined="false" >}}.

## Img

The `img` shortcode embeds a page resource image with positioning, caption, and optional blur:

```text
{{</* img src="image.jpg" alt="Description" caption="Caption" position="right" width="40%" */>}}
```

(This shortcode requires a page bundle with an image resource. See any article with a `layout` for a working example.)

## Callout

Four built-in types plus custom styling:

{{< callout type="tip" text="This is a tip callout — use it for helpful suggestions." >}}

{{< callout type="alert" text="This is an alert callout — use it for critical information." >}}

{{< callout type="warning" text="This is a warning callout — use it for cautionary notes." >}}

{{< callout type="custom" title="Custom Callout" text="This callout has a custom title and background colour." style="background: hsl(210, 50%, 95%);" >}}

## Details

Collapsible content using the HTML `<details>` element:

{{< details "Click to expand this section" >}}
This content is hidden by default. It can contain **bold text**, *italic text*, `code`, and other Markdown formatting.

- List items work too
- As do other block elements
{{< /details >}}

## Dialogue

For plays and screenplays — character name in small caps with optional parenthetical:

{{< dialogue "ELENA" >}}Have you seen the forecast?{{< /dialogue >}}

{{< dialogue "MARCUS" "checking his phone" >}}Rain again. Third day running.{{< /dialogue >}}

{{< dialogue "ELENA" "sighing" >}}At least the garden is happy.{{< /dialogue >}}

## Direction

Stage directions for dramatic scripts:

{{< direction >}}The café. Morning light through rain-streaked windows. ELENA and MARCUS at a corner table.{{< /direction >}}

{{< direction >}}Pause. The sound of rain intensifies.{{< /direction >}}

## Popquote

Expandable quote with a summary line:

{{< popquote "The best time to plant a tree was twenty years ago..." >}}
The best time to plant a tree was twenty years ago. The second best time is now.

This shortcode is useful for long quotations that would interrupt the flow of an article. The reader can choose to expand it.
{{< /popquote >}}

## Poem

Preserves line breaks exactly as written — essential for verse:

{{< poem >}}
The rain falls soft on Connacht stone,
on field and wall and empty lane,
on everything I've ever known
and some things I won't know again.
{{< /poem >}}

## Video

Embeds a local video file with HTML5 player controls:

{{< video "/videos/sample.mp4" >}}

(Place a video file at `static/videos/sample.mp4` to see this in action.)

## Contact Form

Self-hosted contact form with Cloudflare Turnstile CAPTCHA:

{{< contactform newsletter="true" >}}

(Requires Cloudflare Worker configuration in `hugo.yaml`. See [docs/contactform.md](https://github.com/tigger04/theme-tadg-ie/blob/main/docs/contactform.md) for setup.)

## Formspree

A simpler contact form using Formspree as the backend:

{{< formspree id="example-form-id" >}}

(Replace `example-form-id` with your actual Formspree form ID.)

## Raw HTML

Passes HTML through without Markdown processing:

{{< rawhtml >}}
<div style="padding: 1rem; border: 2px dashed var(--border-color, #ddd); border-radius: 0.5rem; text-align: center;">
  <p style="margin: 0;">This is raw HTML passed through the <code>rawhtml</code> shortcode.</p>
</div>
{{< /rawhtml >}}

## Gallery

The `gallery` shortcode renders all images in a page bundle as a responsive grid with lightbox. It reads EXIF data for titles and captions automatically.

```text
{{</* gallery */>}}
```

See the [Photography](/photography/) section for working examples with actual images.

## Section List

Renders navigation links to site sections:

{{< section-list >}}

With a limit parameter to show recent items per section:

{{< section-list limit="2" >}}
