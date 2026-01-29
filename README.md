# tadg_ie Hugo Theme

Live demo: https://tadg.ie

# Screenshots
## Home page
![Light mode](screenshots/home-light.png)
![Dark mode](screenshots/home-dark.png)
## Gallery
![Light mode](screenshots/gallery-light.png)
![Dark mode](screenshots/gallery-dark.png)



> Plase note in the below notes, the terms poetry, artwork, blog, snips, plays, stories are describing types of content from my original site, for which I wrote the theme. This does not mean your content needs to be poetry, plays, etc etc, but rather by example how you can use the frontmatter fields to drive the behaviours you desire for presentation of your site.

A Hugo theme for multi-content-type sites with masonry layouts, galleries, and responsive design. Based on the Archie theme with extensive customizations.

## Features

- **Masonry grid layout** with CSS Grid fallback and JavaScript positioning
- **Image galleries** with lightbox and EXIF metadata support
- **Multiple content types** (blog, poetry, artwork, plays, stories)
- **Section-specific card styles** for each content type
- **Responsive design** with em-based breakpoints (WCAG 2.1 compliant)
- **Pagination** with per-section override
- **8 custom shortcodes** (callout, details, popquote, poem, video, formspree, rawhtml, section-list)
- **Flexible sidebar** with content, shortcodes, or section navigation
- **Dark mode support** with system preference detection

## Quick Start

1. Add the theme to your Hugo site:
   ```bash
   git submodule add https://github.com/tigger04/theme-tadg-ie.git themes/tadg_ie
   ```

   Or clone directly:
   ```bash
   git clone https://github.com/tigger04/theme-tadg-ie.git themes/tadg_ie
   ```

2. Update your `hugo.yaml`:
   ```yaml
   theme: tadg_ie
   ```

3. Create content in sections: `poetry/`, `artwork/`, `blog/`, `snips/`, `stories/`, `plays/`

4. Run Hugo:
   ```bash
   hugo server
   ```

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Page Templates](#page-templates)
3. [Article Layouts](#article-layouts)
4. [Masonry Grid System](#masonry-grid-system)
5. [Section Display Configuration](#section-display-configuration)
6. [Pagination](#pagination)
7. [Section-Specific Behaviour](#section-specific-behaviour)
8. [Gallery System (Artwork)](#gallery-system-artwork)
9. [Shortcodes](#shortcodes)
10. [Configuration Options](#configuration-options)
11. [Index Files and Page Bundles](#index-files-and-page-bundles)
12. [Frontmatter Reference](#frontmatter-reference)
13. [CSS Customization](#css-customization)
14. [JavaScript Components](#javascript-components)
15. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

The theme provides a complete set of templates:

```
themes/tadg_ie/
├── layouts/
│   ├── index.html             # Homepage template
│   ├── _default/
│   │   ├── baseof.html        # Base template wrapper
│   │   ├── single.html        # Article/page template
│   │   └── list.html          # Section list template
│   ├── artwork/
│   │   └── single.html        # Individual gallery page
│   ├── partials/
│   │   ├── masonry-grid.html  # Shared masonry grid component
│   │   ├── list-view.html     # Simple list layout
│   │   ├── gallery-section.html # Gallery grid layout
│   │   ├── pagination.html    # Pagination controls
│   │   └── ...
│   └── shortcodes/
│       └── ...
├── assets/
│   └── css/
│       ├── custom.css         # Theme customizations
│       ├── fonts.css          # Font definitions
│       └── lightbox.css       # Lightbox styling
└── static/
    └── js/
        ├── masonry-init.js    # Masonry layout
        ├── lightbox.js        # Image lightbox
        └── burger-menu.js     # Mobile nav
```

---

## Page Templates

### Homepage (`layouts/index.html`)

The homepage displays a masonry grid with pinned/featured content from each section.

**Pin Logic:**
1. For each section (poetry, artwork, blog, snips, plays, stories), find pages with `pin` frontmatter
2. Select the page with the lowest `pin` value (e.g., `pin: 1` beats `pin: 10`)
3. If no pinned page exists, use the most recent page from that section
4. Pinned pages appear first in the grid, followed by remaining pages by date

**Structure:**
```html
<main class="home">
  <!-- Optional subtitle from site params -->
  <!-- Optional homepage content from _index.md -->
  <!-- Masonry grid with pinned + recent content -->
  <!-- Pagination for remaining content -->
</main>
```

### List Pages (`layouts/_default/list.html`)

Used for section index pages (`/poetry/`, `/blog/`, etc.) and taxonomy pages.

**Features:**
- Page header with title and optional description
- Optional content from `_index.md`
- Configurable display style (cards, list, gallery)
- Optional sidebar for subsection navigation
- Pagination with per-section override

### Single Pages (`layouts/_default/single.html`)

The article template supports multiple layout modes selected via the `layout` frontmatter field.

---

## Article Layouts

The `layout` frontmatter field controls how a single article is displayed. Available layouts:

### `banner`
Full-width banner image at the top with title overlay.

```yaml
layout: banner
image:
  src: my-image.jpg
  dark: true  # Optional: adds dark overlay for light text
  caption: "Photo by Example"  # Optional
```

### `hero`
Large featured image below the title.

```yaml
layout: hero
image:
  src: hero-image.jpg
  alt: "Description"
  caption: "Optional caption"
```

### `columns` / `featured-columns-left`
Two-column layout with image on the left, text on the right.

```yaml
layout: columns
image:
  src: side-image.jpg
```

### `featured-columns-right`
Two-column layout with text on the left, image on the right.

### `featured`
Inline featured image within the content flow.

### `background` (default when image present)
Background image behind the content with blur and opacity.

```yaml
layout: background
image:
  src: bg-image.jpg
  opacity: 0.3      # Override default
  blur: 10px        # Override default
  dark: true        # Dark mode variant
```

### No Layout (text-only)
When no `layout` is specified and no image exists, a simple text layout is used.

---

## Masonry Grid System

The masonry grid (`layouts/partials/masonry-grid.html`) is the core component for displaying content on homepages and list pages.

### How It Works

**Hybrid CSS Grid + JavaScript Approach:**

1. **CSS Grid** provides the responsive column structure:
   ```css
   grid-template-columns: repeat(auto-fill, minmax(17.5rem, 1fr));
   ```

2. **JavaScript** (`static/js/masonry-init.js`) adjusts vertical positioning to fill gaps using a shortest-column algorithm.

**Accessibility Note:** Both CSS media queries and JavaScript breakpoints use relative units (`em`/`rem`) rather than fixed pixels. This ensures the layout adapts when users change their browser's default font size (WCAG 2.1 Success Criterion 1.4.4).

### Responsive Breakpoints

Breakpoints are defined in `em` units (relative to browser font size):

| Viewport | Columns | With Sidebar |
|----------|---------|--------------|
| ≤ 30em   | 2       | 2 (sidebar stacked) |
| 30-48em  | 2       | 2 (sidebar stacked) |
| 48-64em  | 3       | 2 + sidebar = 3 total |
| ≥ 64em   | 4       | 3 + sidebar = 4 total |

**Constraint:** Min 2, max 4 columns total (including sidebar when present).

### Card Styles by Section

Each content type gets section-specific styling via the `.masonry-{section}` class:

| Section  | Style         | Elements Shown                        |
|----------|---------------|---------------------------------------|
| artwork  | Image-dominant| Large thumbnail, title below          |
| poetry   | Text-focused  | Title, verse excerpt                  |
| blog     | Balanced      | Title, date, summary                  |
| snips    | Compact       | Title, date, short excerpt            |
| plays    | Synopsis      | Title, date, longer synopsis          |
| stories  | Balanced      | Title, date, summary                  |

### Background Images on Cards

Cards display a background image when `image.src` is set in frontmatter. The image is rendered with blur and opacity as configured in `params.bgImage`:
- Default opacity: 0.2 (20%)
- Default blur: 5px

### Usage in Templates

```go-html-template
{{ partial "masonry-grid.html" (dict
    "pages" .Pages
    "showSection" true
    "Site" .Site
) }}
```

---

## Section Display Configuration

These frontmatter fields control how section list pages (`_index.md` / `_index.org`) display content:

```yaml
---
list_style: cards       # "cards" (default), "list", or "gallery"
sidebar: true           # true or false (default), or a map with content
list_recursive: false   # true or false (default)
paginate: 12            # items per page (default: 12)
---
```

**Note:** We use `list_style` (not `layout`) because Hugo reserves `layout` for template selection.

### Field Descriptions

| Field | Default | Description |
|-------|---------|-------------|
| `list_style` | `cards` | Display mode: `cards` (masonry grid), `list` (vertical list), `gallery` (image grid) |
| `sidebar` | `false` | Show sidebar. Can be `true` (subsection nav), or a map with `title`, `content`, `sections`, `root` |
| `list_recursive` | `false` | Include all nested content recursively (uses `.RegularPagesRecursive`) |
| `paginate` | `12` | Items per page before pagination links appear |

### Sidebar Configuration

The sidebar is entirely configured via frontmatter. Two main modes:

#### Mode 1: Simple (`sidebar: true`)

Shows subsections of the current page automatically. Use this for section pages.

```yaml
# content/poetry/_index.md
sidebar: true
```

Result: Shows Riddles, Terminus, Secrets... (poetry's subsections)

#### Mode 2: Content-based (`sidebar.content`)

Full control via markdown and shortcodes. Use this for custom content like bios, or mixed layouts.

```yaml
# content/_index.md (homepage)
sidebar:
  title: "Taḋg Paul"
  content: |
    Writer, artist, technologist.

    {{< section-list >}}

    Based in Dublin.
```

The `section-list` shortcode behaviour is consistent everywhere:
- `{{< section-list >}}` → shows `mainSections` (Poetry, Artwork, Blog...)
- `{{< section-list sections="poetry,artwork" >}}` → shows those specific sections

#### Mode 3: Explicit sections list

A simpler alternative to content-based when you just need section links:

```yaml
sidebar:
  title: "Browse"
  sections:
    - poetry
    - artwork
    - blog
```

#### Mode 4: Root-based sibling navigation (`sidebar.root`)

Shows subsections of a specified root section. Use this for sibling navigation in deeply nested pages.

```yaml
# content/artwork/humans/_index.org
sidebar:
  root: artwork
```

Result: Shows all artwork galleries (Humans, Remy, Action, Bits...) regardless of which gallery you're viewing. This enables consistent navigation across sibling sections.

### Display Combinations

| list_style | sidebar | list_recursive | Result |
|------------|---------|----------------|--------|
| cards | false | false | Current default: masonry grid |
| cards | true | false | Sidebar + masonry grid |
| cards | true | true | Sidebar + all nested content as cards |
| list | false | false | Simple vertical list |
| list | true | false | Sidebar + list |
| gallery | false | false | Image gallery grid |
| gallery | true | false | Sidebar + gallery grid |

### Recommended Section Defaults

| Section | list_style | sidebar | Notes |
|---------|------------|---------|-------|
| Poetry | cards | true | Sidebar for subsections |
| Blog | cards | true | Sidebar for categories |
| Snips | cards | true | Sidebar for topics |
| Stories | list | false | Simple list for narrative content |
| Plays | list | false | Simple list for theatrical works |
| Artwork | gallery | true | Gallery grid with folder navigation |

---

## Pagination

Site-wide pagination default is set in `hugo.yaml`:

```yaml
pagination:
  pagerSize: 12   # Items per page (default)
```

Override per-section using `paginate` frontmatter field in section `_index.md` files:

```yaml
---
title: My Section
paginate: 20  # Show 20 items per page in this section
---
```

The pagination partial (`layouts/partials/pagination.html`) displays prev/next links and page numbers with ellipsis for large page counts.

---

## Section-Specific Behaviour

### Poetry (`/poetry/`)

- Text-focused cards with verse excerpts
- Author displayed prominently
- Supports `collection` frontmatter for grouping by poet
- Verse preview maintains line breaks (`pre-line`)

### Artwork (`/artwork/`)

Uses custom templates for gallery functionality. See [Gallery System](#gallery-system-artwork).

### Blog (`/blog/`)

- Balanced cards with date and summary
- Supports all article layouts
- Image backgrounds from `image.src`

### Snips (`/snips/`)

- Compact cards for technical snippets
- Short excerpts (100 characters)

### Plays (`/plays/`)

- Synopsis-friendly layout
- Longer descriptions (250 characters)
- Author and date displayed

### Stories (`/stories/`)

- Same layout as blog
- Balanced text and image treatment

### Collections (`/collections/`)

Special handling for poet collections:
- Main page lists all poets with content
- Individual poet pages show their poems
- Uses `collection` frontmatter to group content

---

## Gallery System (Artwork)

The artwork section uses the `{{< gallery >}}` shortcode for flexible image display.

### Gallery List Page

Displays all gallery folders (subsections) with:
- Hero image for each gallery (first image or `featured_image`)
- Gallery title and description
- Image count badge

### Gallery Shortcode (`layouts/shortcodes/gallery.html`)

Any page can display its image resources as a gallery by including `{{< gallery >}}` in its content.

**Features:**

1. **Metadata Priority:**
   - Frontmatter resource params (highest priority)
   - EXIF data (`DocumentName`, `ImageDescription`)
   - Filename (fallback)

2. **EXIF Metadata Extraction:**
   - `DocumentName` → Image title
   - `ImageDescription` → Image caption/description
   - Used for alt text and captions

3. **Responsive Images:**
   - Three sizes: 400px, 800px, 1600px
   - WebP format for modern browsers
   - Original format fallback
   - Lazy loading enabled

4. **Lightbox Integration:**
   - Click to open full-size image
   - Keyboard navigation (arrows, Escape)
   - Caption display from EXIF or frontmatter

### Gallery Frontmatter

```yaml
---
title: "Gallery Name"
description: "Gallery description"
params:
  featured_image: "hero.jpg"  # Optional: hero image for list page
resources:
  - src: "*.jpg"
    params:
      weight: 10  # Sort order
  - src: "special.jpg"
    params:
      title: "Custom Title"      # Overrides EXIF
      caption: "Custom caption"  # Overrides EXIF
---

{{< gallery >}}
```

---

## Shortcodes

### `{{< callout >}}`

Styled alert/callout boxes.

```markdown
{{< callout type="tip" text="This is a helpful tip!" >}}
{{< callout type="alert" text="Important alert message" >}}
{{< callout type="warning" text="Warning message" >}}
{{< callout type="custom" title="Custom Title" text="Custom message" style="background: #fee;" >}}
```

**Types:** `tip`, `alert`, `warning`, `custom`

### `{{< details >}}`

Collapsible content block.

```markdown
{{< details "Click to expand" >}}
Hidden content goes here.
Can include **markdown**.
{{< /details >}}
```

### `{{< popquote >}}`

Expandable quote with styled summary.

```markdown
{{< popquote "Opening line..." >}}
Full quote content here.
Multiple paragraphs supported.
{{< /popquote >}}
```

### `{{< poem >}}`

Poetry formatting with preserved line breaks.

```markdown
{{< poem >}}
Roses are red,
Violets are blue,
This preserves
Line breaks for you.
{{< /poem >}}
```

### `{{< video >}}`

Embed local video files.

```markdown
{{< video "/videos/my-video.mp4" >}}
```

### `{{< formspree >}}`

Embed a Formspree contact form.

```markdown
{{< formspree id="your-formspree-id" >}}
```

### `{{< rawhtml >}}`

Pass through raw HTML without processing.

```markdown
{{< rawhtml >}}
<div class="custom-widget">
  <iframe src="..."></iframe>
</div>
{{< /rawhtml >}}
```

### `{{< section-list >}}`

Renders a navigation list of site sections. Behaviour is consistent on any page (homepage, section pages, single pages).

```markdown
{{< section-list >}}
```

**Parameters:**
- `sections` - Comma-separated list of sections (defaults to `site.Params.mainSections`)
- `limit` - Show this many items per section (optional, shows section links only if omitted)

**Examples:**

| Usage | Shows |
|-------|-------|
| `{{< section-list >}}` | `mainSections` (Poetry, Artwork, Blog...) |
| `{{< section-list sections="poetry,artwork" >}}` | Those specific sections |
| `{{< section-list limit="3" >}}` | Sections with up to 3 recent items each |

---

## Configuration Options

### `hugo.yaml` Settings

```yaml
baseURL: https://example.com/
title: Site Title
theme: tadg_ie

pagination:
  pagerSize: 12   # Items per page

params:
  # Background image defaults for masonry cards
  bgImage:
    opacity: 0.2    # 0-1, transparency of background images
    blur: 5px       # CSS blur value

  # Read more button on masonry cards
  readMore:
    type: icon      # "icon" or "text"
    value: icons/chevron-right-duo-thick.svg  # icon path or text string

  # Theme mode: light, dark, auto, toggle
  mode: light

  # Main sections for homepage grid
  mainSections:
    - poetry
    - artwork
    - blog
    - snips
    - stories
    - plays

  # CDN usage for fonts/libraries
  useCDN: false

  # Custom CSS files (loaded last)
  customcss:
    - css/custom.css
    - css/fonts.css
    - css/lightbox.css

  # Custom JavaScript files
  customJS:
    - js/burger-menu.js
    - js/lightbox.js

  # Social links
  social:
    - name: GitHub
      icon: github
      url: https://github.com/username/

  # Optional features
  mathjax: false    # Enable MathJax
  katex: false      # Enable KaTeX

# Image processing
imaging:
  quality: 99
  resampleFilter: "CatmullRom"
  exif:
    disableDate: false
    disableLatLong: true  # Privacy: no GPS data
```

### Menu Configuration

```yaml
menu:
  main:
    - name: Poetry
      url: /poetry/
      weight: 10
    - name: Artwork
      url: /artwork/
      weight: 20
    # ...
```

---

## Index Files and Page Bundles

Hugo uses two types of index files to organize content.

### File Types Overview

| File | Type | Purpose | URL Example |
|------|------|---------|-------------|
| `_index.md` | Branch bundle | Section/list page metadata and content | `/poetry/` |
| `index.md` | Leaf bundle | Individual page content | `/poetry/my-poem/` |

### `_index.md` — Branch Bundles (Sections)

A `_index.md` (or `_index.org`) file defines metadata for a **section** or **list page**.

**Example:**
```yaml
---
title: Poetry
description: A collection of verses and musings
list_style: cards
sidebar: true
---

Welcome to my poetry section.
```

### `index.md` — Leaf Bundles (Individual Pages)

An `index.md` file defines an **individual content page** within a page bundle.

**Example:**
```yaml
---
title: That Day
date: 2004-05-01
layout: columns
image:
  src: sunset.jpg
---

Take me to that place in time...
```

### Org-mode Support

Both `.md` (Markdown) and `.org` (Org-mode) files are supported. Frontmatter in Org files uses the same YAML format.

---

## Frontmatter Reference

### Common Fields

```yaml
---
title: "Page Title"
date: 2025-01-15
draft: false
description: "Page description for SEO and previews"
author: "Author Name"
tags:
  - tag1
  - tag2
---
```

### Image Fields

```yaml
image:
  src: "image.jpg"        # Relative to page bundle
  alt: "Alt text"         # Accessibility
  caption: "Photo credit" # Displayed below image
  dark: false             # Dark mode variant flag
  opacity: 0.2            # Override default bg opacity
  blur: 5px               # Override default bg blur
```

### Layout Control

```yaml
layout: hero              # banner, hero, columns, featured, background
toc: true                 # Show table of contents
tldr: "Brief summary"     # TL;DR section at top
```

### Pin/Featured

```yaml
pin: 1                    # Lower number = higher priority
```

### Exclude from Listings

```yaml
build:
  list: false             # Hide from list pages (homepage, section indexes)
```

Use this to exclude a page from appearing in:
- Homepage masonry grid
- Section list pages
- RSS feeds

The page remains accessible via direct URL and is included in the sitemap. This is Hugo's standard build option (not a custom field).

### Section Display (for `_index.md`)

```yaml
list_style: cards         # cards, list, or gallery
sidebar: true             # Show subsection navigation
list_recursive: false     # Include nested content
paginate: 12              # Items per page
```

### Gallery-Specific

```yaml
gallery: true             # Mark as gallery folder
featured_image: "hero.jpg"
sort_by: Date
sort_order: desc
```

---

## CSS Customization

### CSS Variables (Light Mode)

```css
:root {
  --text-color: #000;
  --text-secondary: #333;
  --text-muted: #666;
  --bg-color: #fff;
  --bg-secondary: #f5f5f5;
  --bg-hover: #f1f1f1;
  --border-color: #ddd;
  --accent-color: hsl(27, 100%, 35%);
  --link-color: #007acc;
  --content-max-width: 1600px;
}
```

### Dark Mode

Supports both system preference (`prefers-color-scheme: dark`) and manual toggle (`data-theme="dark"`).

### Key Classes

| Class | Purpose |
|-------|---------|
| `.masonry-grid` | Container for masonry layout |
| `.masonry-item` | Individual grid item |
| `.masonry-{section}` | Section-specific styling |
| `.masonry-bg` | Background image layer |
| `.gallery-grid` | Gallery image container |
| `.gallery-item` | Individual gallery image |
| `.lightbox` | Lightbox overlay |
| `.pagination` | Pagination container |
| `.pagination-link` | Pagination button |

---

## JavaScript Components

### Masonry Layout (`static/js/masonry-init.js`)

**Purpose:** Positions masonry items using shortest-column algorithm.

**Features:**
- Responsive column calculation using em-based breakpoints
- Waits for images to load before positioning
- Debounced resize handling
- Falls back to CSS Grid for single column

**Public API:**
```javascript
window.masonryLayout();  // Re-run layout
window.masonryInit();    // Full re-initialization
```

### Lightbox (`static/js/lightbox.js`)

**Purpose:** Full-screen image viewing for galleries.

**Features:**
- Click to open, click outside to close
- Keyboard navigation (←, →, Escape)
- WebP source detection for best quality
- EXIF-based captions

### Burger Menu (`static/js/burger-menu.js`)

Mobile navigation toggle.

---

## Troubleshooting

### Images Not Displaying

1. **Check path:** Image paths should be relative filenames for page bundles
   ```yaml
   # Correct (page bundle)
   image:
     src: my-image.jpg

   # Incorrect
   image:
     src: /posts/old-path/my-image.jpg
   ```

2. **Run tests:** `make test` validates image paths

### Masonry Not Working

1. Check browser console for JS errors
2. Ensure `masonry-init.js` is loaded
3. Verify `.masonry-grid` container exists
4. Check images have loaded (lazy loading delay)

### Gallery Images Missing Captions

EXIF metadata must include `DocumentName` or `ImageDescription` tags.

### Dark Mode Not Toggling

Ensure both CSS files are loaded:
- `css/main.css` (base)
- `css/dark.css` (dark mode)

### Pagination Not Appearing

- Pagination only shows when there are more items than `pagerSize`
- Check that `paginate` frontmatter value is a positive integer
- Verify the section has enough content pages

---

## License

MIT License. See [LICENSE](LICENSE) for details.

Based on the [Archie theme](https://github.com/athul/archie) by Athul Cyriac Ajay.
