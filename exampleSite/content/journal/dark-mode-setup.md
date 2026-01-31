---
title: "Configuring Dark Mode"
date: 2025-05-20
description: "How the tadg_ie theme handles dark mode: auto-detection, manual toggle, and fixed modes."
tags:
  - theme
  - dark-mode
  - reference
toc: "In this guide"
---

The theme supports four dark mode strategies, configured via `params.mode` in your `hugo.yaml`.

## Mode Options

### `auto` (recommended)

Follows the operating system preference using `prefers-color-scheme: dark`. When the user switches their OS to dark mode, the site follows automatically.

```yaml
params:
  mode: auto
```

### `toggle`

Adds a toggle button in the header. Users can switch between light and dark mode regardless of their OS setting. Their preference is stored in `localStorage`.

```yaml
params:
  mode: toggle
```

### `dark`

Forces dark mode for all visitors.

```yaml
params:
  mode: dark
```

### `light`

Forces light mode for all visitors. This is the default if no mode is specified.

```yaml
params:
  mode: light
```

## CSS Variables

The theme uses CSS custom properties for all colours. Override them in your custom CSS:

```css
:root {
  --text-color: #000;
  --bg-color: #fff;
  --accent-color: hsl(27, 100%, 35%);
  --link-color: #007acc;
}

[data-theme="dark"] {
  --text-color: #e0e0e0;
  --bg-color: #1a1a1a;
  --accent-color: hsl(27, 100%, 55%);
  --link-color: #4db8ff;
}
```

{{< callout type="tip" text="When using 'auto' mode, test your site with both OS light and dark mode to ensure all content is readable in both." >}}
