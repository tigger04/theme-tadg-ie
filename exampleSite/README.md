# tadg_ie Example Site

A demonstration site for the [tadg_ie Hugo theme](https://github.com/tigger04/theme-tadg-ie).

## Quick Start

```bash
cd themes/tadg_ie/exampleSite
hugo server --themesDir ../..
```

Then open <http://localhost:1313>.

## Content Sections

| Section | Feature Demonstrated |
|---------|---------------------|
| **Recipes** | Masonry card grid, sidebar navigation, tags, callout and details shortcodes |
| **Journal** | Article layouts, TOC sidebar, TL;DR, popquote shortcode, dark mode reference |
| **Photography** | Gallery subsections, `gallery: true`, lightbox, EXIF metadata |
| **Stories** | List view, dialogue/direction/poem shortcodes |

## Adding Images

The photography galleries are empty by default. To see the gallery and lightbox features in action, add `.jpg` or `.png` images to:

- `content/photography/coastal-walks/`
- `content/photography/market-mornings/`

Hugo will process them automatically with responsive sizing and WebP conversion.

## Configuration

See `hugo.yaml` for all theme parameters. Key settings demonstrated:

- `params.mode: auto` — dark mode follows OS preference
- `params.mainSections` — controls homepage masonry grid content
- `menu.main` — navigation entries including Tags page
- `params.bgImage` — background image opacity and blur defaults

## License

MIT License. Content is fictional and for demonstration purposes only.
