---
title: "How the Masonry Grid Works"
date: 2025-04-10
description: "Understanding the hybrid CSS Grid and JavaScript approach to masonry layouts."
tags:
  - theme
  - masonry
  - reference
---

The homepage and section list pages use a masonry grid — a layout where items of varying heights pack together without gaps, like a stone wall.

## The Hybrid Approach

Pure CSS Grid gives us responsive columns but leaves vertical gaps. Pure JavaScript positioning is fragile on resize. The tadg_ie theme uses both:

1. **CSS Grid** handles the horizontal layout — responsive columns that reflow based on viewport width.
2. **JavaScript** runs after images load and adjusts vertical positioning to fill gaps.

This means the layout works (albeit with gaps) even when JavaScript is disabled.

## Responsive Breakpoints

Breakpoints use `em` units rather than pixels, so the layout adapts when users change their browser's default font size:

| Viewport | Columns |
|----------|---------|
| ≤ 30em   | 2 |
| 30–48em  | 2 |
| 48–64em  | 3 |
| 64–80em  | 4 |
| ≥ 80em   | 5 |

{{< callout type="alert" text="Using em-based breakpoints is a WCAG 2.1 requirement (Success Criterion 1.4.4). Pixel-based breakpoints break when users zoom." >}}
