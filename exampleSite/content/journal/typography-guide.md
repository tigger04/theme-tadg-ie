---
title: "Typography in the tadg_ie Theme"
date: 2025-07-01
description: "A demonstration of heading levels, lists, code blocks, and other typographic elements."
tags:
  - theme
  - typography
  - reference
toc: true
tldr: "A comprehensive demonstration of how standard Markdown elements render in this theme."
pin: 100
---

This post demonstrates how standard Markdown typography renders in the tadg_ie theme. Use it as a reference when writing content.

## Headings

Headings from H2 to H6 are available. H1 is reserved for the page title.

### Third Level

#### Fourth Level

##### Fifth Level

###### Sixth Level

## Text Formatting

Regular paragraph text. **Bold text** for emphasis. *Italic text* for subtlety. ~~Strikethrough~~ for corrections. `Inline code` for technical terms.

> Blockquotes are useful for highlighting important passages or attributing quotes to their sources.

## Lists

### Unordered

- First item
- Second item
  - Nested item
  - Another nested item
- Third item

### Ordered

1. First step
2. Second step
3. Third step

## Code Blocks

```python
def greet(name: str) -> str:
    """Return a greeting for the given name."""
    return f"Hello, {name}!"
```

```bash
#!/usr/bin/env bash
set -euo pipefail
echo "Hello from the shell"
```

## Tables

| Feature | Supported | Notes |
|---------|-----------|-------|
| Masonry grid | Yes | CSS Grid + JavaScript hybrid |
| Galleries | Yes | With lightbox and EXIF |
| Dark mode | Yes | Auto, toggle, or fixed |
| Sidebars | Yes | Four configuration modes |

## Horizontal Rules

Content above the rule.

---

Content below the rule.

## Links and Images

[External link](https://gohugo.io) to the Hugo project.

Footnotes are also supported[^1].

[^1]: This is a footnote demonstrating the theme's footnote styling.
