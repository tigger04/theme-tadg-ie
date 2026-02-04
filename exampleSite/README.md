# tadg_ie Example Site

A demonstration site for the [tadg_ie Hugo theme](https://github.com/tigger04/theme-tadg-ie).

## Quick Start

```bash
cd themes/tadg_ie/exampleSite
hugo server --themesDir ../..
```

Then open <http://localhost:1313>.

## Content Sections

| Section | Features Demonstrated |
|---------|----------------------|
| **Recipes** | Masonry card grid, sidebar mode 2 (content markdown with section-list), tags, callout/details/colorbold shortcodes, `pin`, `hideDate` |
| **Journal** | All 7 single-page layouts (banner, hero, columns, featured-columns-right, featured, background, default), TOC, TL;DR, popquote shortcode, dark mode reference |
| **Photography** | Gallery subsections, `gallery: true`, lightbox, EXIF metadata, sidebar mode 4 (root-based) |
| **Stories** | List view, dialogue/direction/poem shortcodes, sidebar mode 3 (explicit sections) |
| **Poetry** | Masonry cards, recursive listing, nested collections (half-remembered/), sidebar mode 4 (root-based), `hideDate` cascade, `pin`, poem shortcode |

## Feature Coverage

### Display Styles
- **Masonry grid (cards):** Homepage, journal/, recipes/, poetry/
- **List view:** stories/
- **Gallery view:** photography/

### Sidebar Modes
- **Mode 1 — simple (`true`):** journal/
- **Mode 2 — content (markdown):** Homepage, recipes/
- **Mode 3 — explicit sections:** stories/
- **Mode 4 — root-based:** photography/, poetry/

### Single-Page Layouts
- **banner:** journal/typography-guide/
- **hero:** journal/masonry-explained/
- **columns:** journal/on-walking/
- **featured-columns-right:** journal/dark-mode-setup/
- **featured:** journal/featured-image/
- **background:** journal/background-images/
- **default (text-only):** journal/shortcode-showcase

### Shortcodes (all 14)
All shortcodes are demonstrated in the [Shortcode Showcase](/journal/shortcode-showcase/) page and/or throughout the site content:

| Shortcode | Showcase | Also Used In |
|-----------|----------|-------------|
| callout (4 types) | Yes | recipes, journal articles |
| colorbold | Yes | recipes/colcannon |
| contactform | Yes | — |
| details | Yes | recipes, stories |
| dialogue | Yes | stories/the-waiting-room |
| direction | Yes | stories/the-waiting-room |
| formspree | Yes | — |
| gallery | Yes (documented) | photography/ galleries |
| img | Yes (documented) | — |
| poem | Yes | stories/morning-song, all poetry/ |
| popquote | Yes | journal/on-walking |
| rawhtml | Yes | — |
| section-list | Yes | homepage sidebar, recipes sidebar |
| video | Yes | — |

### Other Features
- **Dark mode toggle:** Site-wide (`mode: toggle`)
- **Responsive grid config:** Full breakpoint configuration in hugo.yaml
- **TOC:** typography-guide, shortcode-showcase, dark-mode-setup
- **TL;DR summary:** typography-guide
- **Content pinning:** soda-bread, colcannon, typography-guide, the-cartographer
- **hideDate:** miso-aubergine, poetry/ (via cascade)
- **Tags & taxonomy pages:** All sections
- **Recursive listing:** poetry/ (includes nested collections)
- **Nested sections:** poetry/half-remembered/
- **Social icons:** Both Feather (github, rss) and Simple Icons (bluesky, mastodon)
- **Background images with blur:** Journal articles with image frontmatter
- **Pagination:** Per-section config

## Adding Images

The photography galleries are empty by default. To see the gallery and lightbox features in action, add `.jpg` or `.png` images to:

- `content/photography/coastal-walks/`
- `content/photography/market-mornings/`

Hugo will process them automatically with responsive sizing and WebP conversion.

## Configuration

See `hugo.yaml` for all theme parameters. Key settings demonstrated:

- `params.mode: toggle` — visitors can try dark mode
- `params.grid` — full responsive breakpoint configuration
- `params.mainSections` — controls homepage masonry grid content
- `menu.main` — navigation entries including Poetry and Tags
- `params.bgImage` — background image opacity and blur defaults
- `params.social` — both Feather and Simple Icons icon types

## License

MIT License. Content is fictional and for demonstration purposes only.
