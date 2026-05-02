# Landing Page Style Guide

Design language for the Typster marketing landing page (`/`). All tokens
live in `assets/css/app.css`; component markup is split between
`lib/typster_web/components/layouts/marketing.html.heex` (shell + nav)
and `lib/typster_web/controllers/page_html/home.html.heex` (sections).

## Theming

Two themes selected via `data-theme` on `<html>` (`light` default, `dark`
opt-in). User preference is stored in `localStorage["phx:theme"]` and
applied before first paint by an inline script in the layout. Theme
toggle uses the View Transitions API for a circular reveal centered on
the toggle button.

```html
<html data-theme="dark">
```

## Color tokens

Defined as CSS custom properties on `:root` (light) and overridden under
`[data-theme="dark"]`.

### Brand
| Token            | Light       | Dark        | Usage                       |
| ---------------- | ----------- | ----------- | --------------------------- |
| `--mk-pri`       | `#4f46e5`   | `#6366f1`   | Primary CTA, brand mark     |
| `--mk-pri-h`     | `#4338ca`   | `#4f46e5`   | Primary hover               |
| `--mk-pri-50`    | `#eef2ff`   | rgba indigo | Pill background, soft chips |
| `--mk-pri-100`   | `#e0e7ff`   |             | Pill border                 |

### Neutrals
| Token         | Light       | Dark        | Usage                       |
| ------------- | ----------- | ----------- | --------------------------- |
| `--mk-fg`     | `#09090b`   | `#fafafa`   | Headings, primary text      |
| `--mk-fg2`    | `#3f3f46`   | `#d4d4d8`   | Body, secondary text        |
| `--mk-fg3`    | `#71717a`   | `#a1a1aa`   | Muted, captions             |
| `--mk-fg4`    | `#a1a1aa`   | `#71717a`   | Disabled, hint              |
| `--mk-bd`     | `#e4e4e7`   | `#27272a`   | Border default              |
| `--mk-bd2`    | `#f4f4f5`   | `#1f1f23`   | Surface hover, separators   |
| `--mk-bg`     | `#ffffff`   | `#0a0a0b`   | Card surface                |
| `--mk-bg2`    | `#fafafa`   | `#111114`   | Tinted section bg           |

### Page background
- `html` and `body` share `#eef0f4` (light) / `#15131f` (dark) — solid
  cool-gray base. `overscroll-behavior: none` is set to remove the
  rubber-band seam between overscroll color and decorative layers.

### Accent code-token palette (mock editor)
| Class              | Color       | Token role          |
| ------------------ | ----------- | ------------------- |
| `.mk-tok-comment`  | `#71717a`   | Slash-slash comment |
| `.mk-tok-keyword`  | `#9333ea`   | `#set`, `#datetime` |
| `.mk-tok-string`   | `#16a34a`   | String literals     |
| `.mk-tok-heading`  | `#0369a1`   | `=`, `==` headings  |
| `.mk-tok-em`       | `#dc2626`   | `*bold*`, `_em_`    |

## Typography

- **Family:** `Inter` (Google Fonts, weights 100–900) with system
  fallback `system-ui, sans-serif`.
- **Base:** `14px / 1.5`, antialiased.
- **Hero h1:** clamp-style sizing, weight `700`, tight line-height,
  `<em>` rendered in brand color (no italic).
- **Section h2 (`.mk-section-h`):** large display weight on neutral fg.
- **Eyebrow (`.mk-eyebrow`):** small uppercase tracking-wide muted text
  above each section heading.
- **Mono surfaces** (mock editor source) inherit OS monospace.

## Surface treatment

Two persistent decorative layers inside `.mk-body`:

1. **Solid base color** on `html` + `body` (matches overscroll exactly).
2. **`.mk-body::after`** — fixed-position 800px-tall texture overlay:
   - SVG `feTurbulence` fractal-noise tile (240×240, baseFrequency 0.85)
   - Two `repeating-linear-gradient` brushed diagonals at 115° and 118°
   - `mix-blend-mode: multiply` (light) / `screen` (dark)
   - Linear-gradient mask fades the texture out by 800px

No corner glows, no radial gradients — the original gradient hero was
intentionally removed in favor of a calmer, brushed-silver field.

## Layout

- **Container:** `.mk-container` is centered, `max-width: ~1100px`,
  symmetric horizontal padding.
- **Sections:** `.mk-section` provides vertical rhythm with `~96px`
  padding. `.mk-section-tinted` fills with `--mk-bg2`.
- **Floating navbar (`.mk-nav`):** `position: fixed; top: 14px`, pill
  shape (`border-radius: 18px`), frosted glass via
  `backdrop-filter: blur(20px) saturate(180%)`, semi-transparent white
  fill, soft inset highlight + outer drop shadow. Adds `.is-scrolled`
  class after 16px of scroll for elevated state.

## Components

### Buttons (`.mk-btn`)
- Heights `34px` (`-sm`), `40px` (default), `48px` (`-lg`).
- `border-radius` `var(--mk-r-sm)` / `var(--mk-r)` for `-lg`.
- Variants: `-primary` (filled brand), `-light` (white on dark CTA
  band), `-outline` (border + neutral surface), `-ghost` (text-only,
  hover bg).
- Active state scales to `0.97`, transitions `120–160ms` with
  `--mk-ease-out` (`cubic-bezier(0.23, 1, 0.32, 1)`).

### Pill (`.mk-pill`)
- Small rounded chip with brand-50 fill, brand-100 border,
  brand-hover text. Used for "v1.0 · Public beta is live" tag.
- Includes a `.mk-pill-dot` 6px brand-color dot.

### Hero mockup (`.mk-art`/`.mk-mock`)
Three-pane editor mock: traffic-light bar, file sidebar, source code
with line numbers and syntax tokens, PDF preview. Shadow:
`var(--mk-sh-2xl)` (deep ambient drop). Card `border-radius` ~12px,
`border: 1px var(--mk-bd)`.

### Stats band (`.mk-stats`)
4-column grid, large numerals (`.mk-stat-n`), muted labels. Numerals
mix solid weight with `<span>`-wrapped suffixes for hierarchy
(e.g. `2,400`, `~200ms`).

### How-it-works (`.mk-hiw-steps`)
3 columns, each step with monospace `01/02/03` numeral, title, copy.

### Feature grid (`.mk-feat-grid`)
3×2 cards (`.mk-feat`), each with `.mk-feat-icon` (40px square in
brand-50 fill, brand-color stroke, 20px SVG inside).

### Keyboard band (`.mk-kb-band`)
2-column grid of shortcut rows; `<kbd class="mk-kb-key">` chips for
keys with subtle shadow + border.

### Snippet switcher (`.mk-demo-section`)
Tab bar (`.mk-demo-tab`) over a fixed-height (`420px`) split panel
showing source ↔ rendered PDF side-by-side. JS `mkSwitchTab` toggles
`.is-active` between panels; height is fixed to prevent layout jumps.

### Use cases (`.mk-usecase-grid`)
5 cards with emoji icons and short copy. Looser, more conversational
section.

### Pricing (`.mk-price-grid`)
3 columns. Featured tier (`.mk-price-featured`) gains a "Most popular"
flag, brand-tinted border, and bolder shadow.

### FAQ (`.mk-faq`)
Native `<details>` accordion, custom `+`/`−` icon, hairline borders,
generous vertical padding.

### CTA band (`.mk-cta-band`)
Full-width brand-color block with white headline + light button.

### Footer (`.mk-foot`)
4-column layout: brand block + 3 link columns. Compact bottom row with
copyright and tagline.

## Motion

- **Scroll-revealed elements:** any node with `.mk-reveal` (or children
  of `.mk-reveal-group`) starts hidden (`opacity 0`, `translateY 12px`)
  and animates in on `IntersectionObserver` intersection. Group children
  receive a `--i` index var for staggered delay.
- **Theme transition:** circular `clip-path` reveal anchored on the
  toggle button, 480ms `cubic-bezier(.4,0,.2,1)`.
- **Easing curves:**
  - `--mk-ease`: `cubic-bezier(.4, 0, .2, 1)` (standard)
  - `--mk-ease-out`: `cubic-bezier(0.23, 1, 0.32, 1)` (overshoot-out)
  - `--mk-ease-in-out`: `cubic-bezier(0.77, 0, 0.175, 1)` (deep)
- All motion respects `@media (prefers-reduced-motion: reduce)`.

## Iconography

- **Source files:** `priv/static/images/icons/*.svg` — 12 standalone
  monochrome SVGs (`arrow-right`, `github`, `file`, `image`, `bolt`,
  `command`, `eye`, `cloud-upload`, `share`, `font`, `moon`, `sun`).
- **Component:** `<.mk_icon name="..." class="..."/>` from
  `TypsterWeb.MarketingIcons` inlines them with `currentColor` for
  theme-aware coloring.
- **Sizing utilities:** `.mk-icon-12 / -14 / -16` for explicit pixel
  sizes when used outside icon-shaped containers.

## Shadows

| Token             | Use                                     |
| ----------------- | --------------------------------------- |
| `--mk-sh-sm`      | Subtle (kbd chips, small chips)         |
| `--mk-sh-md`      | Cards, mid-elevation surfaces           |
| `--mk-sh-lg`      | Pricing cards, raised surfaces          |
| `--mk-sh-2xl`     | Hero editor mock, max elevation         |

## Radii

| Token         | Value      | Use                          |
| ------------- | ---------- | ---------------------------- |
| `--mk-r-sm`   | `0.375rem` | Buttons, small chips         |
| `--mk-r`      | `0.5rem`   | Cards, large buttons, mocks  |
| (literal 18px)|            | Floating navbar              |

## Accessibility

- `color-scheme: light/dark` declared on `<html>` so native form
  controls and scrollbars match the active theme.
- All interactive elements maintain visible focus rings via UA defaults
  + the `:focus-visible` polyfill behavior.
- Reduced-motion users get static gradients and instant theme switches.

## Static preview

`preview-export/index.html` is a self-contained snapshot of the page
(no Phoenix runtime needed) for design review. It bundles a copy of
the compiled `app.css`. Open it directly in a browser.
