---
name: maintain-website
description: >-
  Maintain and update the ychsu987.github.io Quarto teaching website (HKU course
  materials). Use when editing site content, adding lectures or tutorials, updating
  navigation, rendering or publishing the site, working with revealjs slides,
  live-html/webr exercises, course listings, or Quarto extensions in this repo.
---

# Maintain ychsu987.github.io

Personal teaching website for Yu Cheng Hsu (HKU). Built with **Quarto website** (`project.type: website`), deployed to GitHub Pages via the `gh-pages` branch.

Live site: https://ychsu987.github.io

## Quick orientation

| Layer | Location | Role |
|-------|----------|------|
| Site config | `_quarto.yml` | Navbar, theme, freeze, resources |
| Hub pages | `about.qmd`, `cc.qmd`, `quant.qmd`, `programming.qmd`, `hybridPBL.qmd` | Course index pages with listings |
| Course content | `courses/{YEAR}/{COURSE_CODE}/` | Lectures, tutorials, assets |
| Shared assets | `assets/css/`, `assets/images/` | Site-wide styles and images |
| Content modules | `_content/modules/` | Reusable content blocks (future) |
| Extensions | `_extensions/` | Quarto Live (`r-wasm/live`) for in-browser R |
| Frozen output | `_freeze/` | Cached execution results (`freeze: auto`) |
| Build output | `_site/` | Rendered site (gitignored) |
| Published site | `gh-pages` branch | What GitHub Pages serves |

**Do not edit** `_site/`, `.quarto/`, or `*_files/` render artifacts unless debugging a specific build issue.

## Before making changes

1. Read `_quarto.yml` and the relevant hub page (e.g. `quant.qmd` for BIOF2014).
2. Open an existing document in the same course and format — match its YAML front matter and conventions.
3. Identify document type: **lecture slide**, **sketch slide**, **tutorial HTML**, or **live exercise**.

For the full course catalog and per-format templates, see [reference.md](reference.md).

## Common tasks

### Add a new lecture slide (revealjs)

1. Create `courses/{YEAR}/COURSE/filename.qmd` next to sibling lectures.
2. Use the course's revealjs YAML pattern (theme, chalkboard, title-slide background).
3. Put images in the course's `img/` folder; use relative paths.
4. Add the file to the hub page `listing.contents` in the correct order.
5. Render and verify: `quarto render COURSE/filename.qmd`

### Add a sketch version (in-class annotated slides)

Sketches are student-facing versions with chalkboard annotations pre-loaded.

- Name: `{lecture-basename}-sketch.qmd` (mirror the lecture filename exactly, append `-sketch`).
- Add `chalkboard: src: compiled_pdf/chalkboard N.json` when applicable.
- Register in the hub page's sketch listing block (e.g. `2014sketches` in `quant.qmd`).

### Add a tutorial / question set

- **BIOF2014 style**: `html` format with `toc: true`, `html-math-method: katex`, `student_view.css`. Wrap solutions in `:::{.hide}` blocks.
- **BBMS1021 style**: `live-html` format with `{webr}` code chunks for interactive R.
- Add to the appropriate listing in the hub page.

### Update navigation

Edit `_quarto.yml` for top-level navbar items. Edit hub pages (`cc.qmd`, `quant.qmd`, etc.) for course-specific listings.

Listing pattern used throughout:

```yaml
listing:
  - id: my-list
    contents:
      - COURSE/file.qmd
    fields: [title]
    sort: false
```

Place the listing on the page with a div: `::: {#my-list}`

### Add a new course section

1. Create a course folder under `courses/{YEAR}/` (e.g. `courses/2026/NEWT101/`) with `img/` for assets.
2. Create or extend a hub page with listings.
3. Add a navbar entry in `_quarto.yml` if it needs a top-level menu item.
4. If the course has static assets outside Quarto render paths, add the folder under `project.resources` in `_quarto.yml`.

## Build and publish

**Prerequisites**: Quarto >= 1.4 (repo tested with 1.7.x), R for knitr/webr documents.

```bash
# Render entire site
quarto render

# Render one document
quarto render COURSE/file.qmd

# Preview locally with live reload
quarto preview
```

**Publish to GitHub Pages** (pushes rendered `_site/` to `gh-pages`):

```bash
quarto publish gh-pages
```

Only publish when the user explicitly asks. The `main` branch holds source; `gh-pages` holds the built site.

### Freeze behavior

`execute: freeze: auto` in `_quarto.yml` caches computation in `_freeze/`. When code or data changes:

```bash
quarto render --cache-refresh        # refresh all frozen content
quarto render file.qmd --cache-refresh  # refresh one file
```

Commit `_freeze/` changes when execution output legitimately changed.

## Styling conventions

| File | Purpose |
|------|---------|
| `courses/2025/BIOF2014/general_style.scss` | Title slide layout, shared revealjs rules |
| `courses/2025/BIOF2014/student_view.scss` / `.css` | Hide solution blocks (`.hide { visibility: hidden }`) |
| Per-course `style.scss` | Course-specific overrides (e.g. `courses/2025/BIOF3001/`) |
| `assets/images/` | Site-wide images (e.g. about page photo) |

- Use `:::{.hide}` to wrap answers/solutions students should not see on blank lecture slides.
- Use `:::{.smaller}` on slides for dense content.
- `lightbox: true` in YAML enables image lightbox.
- Title slides use `title-slide-attributes` with `data-background-image`.

## Interactive code (Quarto Live)

Root extension: `_extensions/r-wasm/live/`. Some subfolders have local copies — prefer the root extension; avoid duplicating unless a subproject requires isolation.

**live-html** documents (BBMS1021 tutorials, ggplot2 intro):

```yaml
format:
  live-html:
    toc: true
    self-contained: true
engine: knitr
```

Use `{webr}` code chunks (not `{r}`) for browser-executable R:

````markdown
```{webr}
x <- c(1, 2, 3)
mean(x)
```
````

Set `eval: false` in YAML when chunks are meant for students to run, not pre-executed.

## Content guidelines

- Author line: `author: Yu Cheng Hsu` (or course team variant for tutorials).
- Slides include **Intended learning outcomes** as an early section.
- BIOF2014 lectures use `subtitle` for topic detail; listings show `title`, `subtitle`, `image`.
- Preserve existing typos in user-facing course titles only if they appear in navigation labels the user has not asked to fix.
- Keep diffs minimal: do not reformat unrelated slides or rename files without being asked.

## Verification checklist

After substantive changes:

```
- [ ] `quarto render` succeeds (or targeted `quarto render path/to/file.qmd`)
- [ ] New content appears in the correct hub listing
- [ ] Links and image paths resolve (relative to the .qmd file)
- [ ] Hidden solutions still wrapped in `.hide` on lecture (non-sketch) files
- [ ] `_freeze/` updated if code chunks changed
- [ ] User asked before `quarto publish gh-pages`
```

## Git: what to commit vs what gets published

This repo has **two targets** with different purposes:

| Target | Branch | What it holds |
|--------|--------|---------------|
| Source repo | `main` | `.qmd` sources, config, assets, `_freeze/`, root `_extensions/` |
| Live website | `gh-pages` | Full rendered `_site/` output only |

`quarto publish gh-pages` pushes `_site/` to `gh-pages`. GitHub Pages serves **only** that branch. Nothing on `main` is served directly.

### Commit on `main` (source of truth)

| Path | Why |
|------|-----|
| `*.qmd`, `_quarto.yml` | Site and course content |
| `_extensions/` (root only) | Quarto Live and other extensions needed to render |
| `_freeze/` | Frozen chunk output (`freeze: auto`); avoids re-running R on every render |
| `img/`, `data/`, `*.bib`, `*.scss`, `*.css`, `*.csv` | Course assets referenced by `.qmd` files |
| `AILT9015/` and other `project.resources` | Static content copied into the built site |
| `.cursor/skills/` | Agent maintenance docs (optional but useful) |

### Do not commit on `main` (generated or local)

These are **not needed in the source repo**. Many are already gitignored but still tracked from earlier commits — do not add new files in these categories.

| Path / pattern | What it is | Why skip |
|----------------|------------|----------|
| `_site/` | Full site render | Rebuilt by `quarto render`; published via `gh-pages` only |
| `.quarto/` | Project index, cache, session temps | Machine-local; changes every preview/render |
| `**/*_files/` | Per-document libs, figures, revealjs assets | Regenerated beside each `.qmd` on render (~376 tracked today — legacy) |
| `docs/` | Old partial HTML build | Superseded by `gh-pages`; stale (~22 tracked — legacy) |
| `**/*.quarto_ipynb` | Quarto notebook sidecars | Editor artifact |
| `.DS_Store`, `Thumbs.db` | OS metadata | No content value |
| `.cursor/` (except skills) | Local editor state | Not part of the site |
| Standalone `*.html` next to `.qmd` | One-off render output | `_site/` is the canonical HTML output |
| Subfolder `_extensions/` copies | Duplicates of root extension | Use `_extensions/r-wasm/live/` at repo root; remove nested copies when safe |

### Published on `gh-pages` only (not on `main`)

| Path | Notes |
|------|-------|
| Rendered `.html` pages | All course pages, hub pages, `search.json` |
| `_site/site_libs/` | Bootstrap, quarto-nav, live-runtime JS/CSS |
| Copied assets | Images, data, bib files as referenced in rendered pages |

Do **not** put `_freeze/`, `.qmd` sources, or `.quarto/` on `gh-pages` — they are build inputs, not website content.

### Recommended `.gitignore` (source repo)

Current `.gitignore` only covers `.quarto/`, `_site/`, and `*.quarto_ipynb`. Consider expanding to:

```gitignore
# Quarto build output
/_site/
/.quarto/
**/*.quarto_ipynb

# Per-document render artifacts (regenerated on render)
**/*_files/

# Legacy/stale output
/docs/

# OS and editor
.DS_Store
Thumbs.db
.cursor/
```

After updating `.gitignore`, untrack legacy artifacts (only when the user asks):

```bash
git rm -r --cached _site/ .quarto/ docs/ 2>/dev/null
git ls-files "*_files" | xargs git rm -r --cached
```

### `_freeze/` — commit on main, not published

`_freeze/` is **intentionally tracked** on `main`. It stores pre-computed chunk results so renders are fast and reproducible. During `quarto render`, frozen output is woven into `_site/`; the `_freeze/` folder itself does not need to appear on `gh-pages`.

Re-commit `_freeze/` when code chunks, data, or figures change (`quarto render --cache-refresh`).

### Git conventions

- Commit messages are short and descriptive (e.g. "update 2014 lecture", "update sketches")
- Do not commit unless the user explicitly requests it
- Do not run `quarto publish gh-pages` unless the user explicitly asks

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Stale figures/output | `quarto render --cache-refresh` |
| webr chunks not interactive | Confirm `live-html` format and `{webr}` engine; check `_extensions/r-wasm/live/` exists |
| Listing missing new page | Add `.qmd` path to hub page `listing.contents`; check `id` div matches |
| Image not found | Path is relative to the `.qmd` file, usually under course `img/` |
| AILT9015 listing broken | `programming.qmd` references `AILT9015/index.html` — ensure that static resource exists and is listed in `project.resources` |

## Additional resources

- Full course catalog and YAML templates: [reference.md](reference.md)
- Quarto website docs: https://quarto.org/docs/websites/
- Quarto Live docs: https://quarto.org/docs/interactive/ojs/quarto-live.html
