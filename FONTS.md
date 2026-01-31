# Font Architecture

This document describes the font stack used in the tadg_ie theme.

## Active Fonts

| Font | Purpose | Locations |
|------|---------|-----------|
| **IosevkaCustom Extended** | Body text, paragraphs, image captions | `p`, `.image-caption` |
| **IosevkaCustom** | Base UI, code blocks, callouts | `html`, `.callout p`, code elements |
| **Special Elite** | Navigation, buttons, logos, UI elements | `nav`, `.read-more-btn`, `.site-logo-text` |
| **EB Garamond** | Poetry/verse content | `.verse`, `.masonry-poetry` |

## Font Files

All fonts are stored in `/static/fonts/` and loaded via `@font-face` definitions in `assets/css/fonts.css`.

### IosevkaCustom Extended (Body Text)

Extended width variant for improved readability in body text.

- `IosevkaCustom-Extended.woff2` (400 normal)
- `IosevkaCustom-ExtendedItalic.woff2` (400 italic)
- `IosevkaCustom-ExtendedBold.woff2` (700 normal)
- `IosevkaCustom-ExtendedBoldItalic.woff2` (700 italic)

### IosevkaCustom (Code/Monospace)

Standard width for code and monospace contexts.

- `IosevkaCustom-Regular.woff2` (400 normal)
- `IosevkaCustom-Italic.woff2` (400 italic)
- `IosevkaCustom-Bold.woff2` (700 normal)
- `IosevkaCustom-BoldItalic.woff2` (700 italic)

### Special Elite (UI Elements)

Single-weight typewriter-style font for UI elements.

- `SpecialElite-Regular.woff2`
- Note: "Fake" bold/italic variants map to the same file

### EB Garamond (Poetry/Verse)

Serif font for poetry and verse content.

- Weight variants: 400, 500, 600, 700, 800
- Includes italic variants for each weight

## CSS Cascade

The font stack cascades through three CSS files:

1. **main.css** - Base font definitions
   - `html`: IosevkaCustom (base UI font)
   - `p`: IosevkaCustom Extended (body text)
   - `.callout p`: IosevkaCustom (code style in callouts)

2. **custom.css** - Overrides and specialisations
   - Special Elite scoped to UI elements only: `nav`, `.read-more-btn`, `.site-logo-text`, `.list-author`, `.list-date`
   - `.image-caption`: IosevkaQuasiProportional Condensed
   - `.verse`: EB Garamond
   - `ul li, ol li`: IosevkaQuasiProportional (matches body text)

3. **fonts.css** - @font-face definitions only

## Legacy Fonts (Retained but Unused)

These fonts remain in fonts.css for potential future use:

- White Rabbit / WR
- Agave
- Profont
- Sudoers
- tigger
- Fira Sans (definitions retained, not referenced in CSS)

## Adding New Fonts

1. Add font files to `/static/fonts/`
2. Add `@font-face` definitions to `fonts.css`
3. Reference the font-family in main.css or custom.css
4. Update this documentation
