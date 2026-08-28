# HVTI graphics recipes — worked examples design

Date: 2026-05-28
Status: approved (pending spec review)

## Goal

Fill the stub chapters of the Quarto book *HVTI ggplot graphics recipes*
(`hvti_graphics`) with self-contained, rendered worked examples. The primary
engine is the `hvtiPlotR` package (v2.3.1); the book is extended to also cover
the related visualization stack — `ggRandomForests`, `randomForestSRC`,
`varPro`, and `TemporalHazard` — plus a data-governance chapter built on
`hvtiRutilities`. Every plot listed gets at least one worked
example; gaps no package covers are filled with base-ggplot recipes styled to
match. The book renders to **HTML and PDF (LaTeX)** so a generated `.tex`/PDF
deliverable exists.

## Packages covered

| Package | Role | Plot surface |
|---|---|---|
| `hvtiPlotR` (2.3.1) | clinical/descriptive ggplot helpers | `hv_*` constructor → `plot()` families |
| `ggRandomForests` (2.7.3.9014 dev → v3.0.0) | ggplot2 visualization of random forests | `gg_*` + `autoplot`/`plot` methods |
| `randomForestSRC` (3.6.2) | RF fitting engine + example datasets | `rfsrc()`; datasets veteran, pbc, breast, wine, housing |
| `varPro` (3.1.0) | variable priority / selection | visualized via ggRandomForests `gg_varpro`, `gg_beta_varpro`, `gg_ivarpro`, `gg_isopro`, `gg_partial_varpro` |
| `TemporalHazard` (1.0.3) | complete R survival/hazard modeling package | `hazard()`/`predict()` → ggplot; `hzr_kaplan`, `hzr_nelson`, `hzr_competing_risks`, `hzr_calibrate`, `hzr_gof` |
| `hvtiRutilities` (1.0.0.9004) | data governance / reproducibility utilities | `data_dictionary`, `label_map`, manifest (`verify_manifest`/`update_manifest`), `compare_datasets`, `r_data_types` |

`TemporalHazard` is a self-contained R package; the original `hazard` C library
is not required for this book. A gap analysis against the SAS `hazard` package
is explicitly **future work**, out of scope here.

`ggRandomForests` is on the `2.7.3.90xx` dev line heading to a **v3.0.0 CRAN
release**. The book targets the v3.0.0 API; if examples are written against the
installed dev build, re-verify them against v3.0.0 once it lands.

Package provenance:

- **CRAN** (already installed, no local source): `randomForestSRC`, `varPro`,
  `ggRandomForests`, `hvtiPlotR`.
- **Local source** (install before rendering — see Risks):
  `TemporalHazard` (`~/Documents/GitHub/temporal_hazard`, package name
  `TemporalHazard`) and `hvtiRutilities` (`~/Documents/GitHub/hvtiRutilities`).

## Source material

`hvtiPlotR`'s vignettes already contain rendered worked examples for ~20
functions:

- `vignettes/plot-functions.qmd` — constructor → `plot()` examples for every
  `hv_*` family, using exported `sample_*()` data generators.
- `vignettes/plot-decorators.qmd` — themes, colour scales, labels/annotations,
  legend positioning, multi-panel patchwork, and saving (PDF/PPT).

These are the raw material. We adapt and condense them into the book's chapter
structure rather than inventing examples.

## The example pattern

Every plot example follows the package's two-step workflow, fully reproducible
via bundled generators so the book renders end-to-end:

```r
dat <- sample_*(...)               # bundled generator, reproducible
obj <- hv_*(dat, ...)              # constructor → S3 object of class hv_data
p   <- plot(obj, ...)              # bare ggplot: no scales/labels/theme
p + scale_*() + labs() + theme_hv_*()   # decorate with + operator
```

Each chapter begins with a shared, hidden setup chunk:

```r
#| include: false
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)
library(hvtiPlotR)
library(ggplot2)
```

Theme functions use the `theme_hv_*()` aliases (`theme_hv_manuscript`,
`theme_hv_poster`, `theme_hv_ppt`, `theme_hv_ppt_dark`,
`theme_hv_ppt_light`) — both `theme_hv_*` and `hv_theme_*` are exported.

Gap chapters (no hvtiPlotR helper) use base ggplot2 geoms styled with
`theme_hv_manuscript()` so they sit visually alongside the package plots.

## Chapter plan

Hybrid structure: keep the existing outline, add focused new chapters for
function families that do not fit a generic plot type. New files marked **new**.

### Getting started part

| File | Functions / content |
|---|---|
| `data_governance.qmd` **new** | `hvtiRutilities` data governance: `data_dictionary`, `label_map`/`add_labels`, dataset manifests (`verify_manifest`/`update_manifest`), `compare_datasets`, `r_data_types`. Uses `generate_survival_data`/`sample_data` for reproducible input. Registered under the existing Getting started part. |

### Figures part

| File | Functions / content |
|---|---|
| `scatter.qmd` | `hv_eda` — continuous scatter + LOESS |
| `survival.qmd` | `hv_survival` — KM curve, cumulative hazard, log-log, integrated life table |
| `hazard.qmd` **new** | `hazard_plot` family (survival/hazard/cumhaz/stratified/life overlay), `hv_nonparametric` curve, `hv_ordinal` |
| `nnt.qmd` **new** | `nnt_plot`, `survival_difference_plot` |
| `histograms.qmd` | `hv_mirror_hist` (binary + IPTW), `hv_stacked` (count + proportion) |
| `density.qmd` | base `geom_density` (gap) |
| `bar.qmd` | `hv_eda` count/percentage barplots, `hv_longitudinal` |
| `boxplots.qmd` | base `geom_boxplot` (gap) |
| `upset.qmd` | `hv_upset` (keeps existing Venn intro prose) |
| `spaghetti.qmd` | `hv_spaghetti`, `hv_trends` |
| `postagestamp.qmd` | base `facet_wrap` small multiples (gap) |
| `specialty.qmd` | part intro prose |
| `consort.qmd` **new** | `hv_consort` patient-flow (tracker workflow) |
| `sankey.qmd` **new** | `hv_alluvial`, `hv_sankey` cluster-stability |
| `balance.qmd` **new** | `hv_balance` covariate balance, `hv_followup` goodness-of-followup |
| `combination.qmd` | patchwork multi-panel composites |

### Random forests & variable selection part (new)

New book part registered in `_quarto.yml`. RF examples fit a model with
`randomForestSRC::rfsrc()` on a bundled dataset, then visualize with
ggRandomForests. varPro examples fit `varPro::varpro()` then visualize.

| File | Functions / content | Dataset |
|---|---|---|
| `randomforests.qmd` **new** | part intro: fit-then-visualize workflow, `autoplot()` vs `plot()` | — |
| `rf_error.qmd` **new** | `gg_error` — OOB error convergence | veteran (survival) |
| `rf_predicted.qmd` **new** | `gg_rfsrc`, `gg_survival` — predicted response / survival | veteran, pbc |
| `rf_vimp.qmd` **new** | `gg_vimp` — variable importance | pbc |
| `rf_dependence.qmd` **new** | `gg_variable` (variable dependence), `gg_partial`/`gg_partial_rfsrc` (partial dependence) | pbc |
| `rf_roc.qmd` **new** | `gg_roc`, `gg_brier` — classification performance | breast / wine |
| `varpro.qmd` **new** | `gg_varpro`, `gg_beta_varpro`, `gg_ivarpro`, `gg_isopro`, `gg_partial_varpro` | housing / breast |

### Survival modeling addition (figures part)

| File | Functions / content |
|---|---|
| `temporal_hazard.qmd` **new** | `TemporalHazard`: `hazard()` fit → `predict()` hazard/cumhaz/survival ggplots; `hzr_kaplan`, `hzr_nelson`, `hzr_competing_risks`, `hzr_calibrate`, `hzr_gof`. Placed after `nnt.qmd`. |

### Tables part

Tables use `gt` directly in this pass. A dedicated `hvtiRtables` package (to
augment `hvtiPlotR`) is planned but does not yet exist; it is a **separate
sub-project** with its own spec/plan. These chapters note that they will
migrate to `hvtiRtables` once it lands.

| File | Content |
|---|---|
| `qt_tables.qmd` | Publication-quality `gt` tables — a summary/"table 1" style table built from `sample_*()` data, following the rich-iannone gt-effective-display-tables guidance already linked in the stub. |
| `figure_tables.qmd` | Tables that pair with figures: numbers-at-risk table from `hv_survival`, and the numeric table panel from `hv_longitudinal`. API for the risk/report table verified against the package during implementation. |

### Formatting part (adapted from `plot-decorators.qmd`)

| File | Content |
|---|---|
| `annotation.qmd` | `make_footnote` draft/publication footnotes, `labs()`, `annotate()`, `coord_cartesian()` |
| `themes.qmd` | `theme_hv_manuscript`, `theme_hv_poster`, `theme_hv_ppt`, `theme_hv_ppt_dark` |
| `colors.qmd` | manual colours, ColorBrewer palettes, suppressing legends |
| `legends.qmd` | legend positioning (inside/outside panel), text/key size |

### Publications part

| File | Content |
|---|---|
| `manuscripts.qmd` | manuscript PDF save with `hv_ggsave_dims` + `theme_hv_manuscript`; PowerPoint export (officer/rvg) |
| `researchday.qmd` | poster sizing with `theme_hv_poster` + PDF save |

## Output formats

`_quarto.yml` gains a `pdf` (LaTeX) format alongside `html`, so the build
produces a generated `.tex` and PDF. `pdflatex` is present on the system. The
existing `typst` format is removed to avoid maintaining three renderers (HTML
for browsing, PDF/LaTeX for the deliverable). Chunks that write external files
(PowerPoint export via officer/rvg) are set `eval: false` so neither renderer
attempts to emit binaries during the book build.

## Files touched

- New chapter files (14): `data_governance.qmd`, `hazard.qmd`, `nnt.qmd`,
  `temporal_hazard.qmd`, `consort.qmd`, `sankey.qmd`, `balance.qmd`,
  `randomforests.qmd`, `rf_error.qmd`, `rf_predicted.qmd`, `rf_vimp.qmd`,
  `rf_dependence.qmd`, `rf_roc.qmd`, `varpro.qmd`.
- Edited chapter files: scatter, survival, histograms, density, bar, boxplots,
  upset, spaghetti, postagestamp, specialty, combination, qt_tables,
  figure_tables, annotation, themes, colors, legends, manuscripts, researchday.
- `_quarto.yml`: register all new chapters and the new RF part; add `pdf`
  format, remove `typst`.
- Environment: install `TemporalHazard` (`~/Documents/GitHub/temporal_hazard`)
  and `hvtiRutilities` (`~/Documents/GitHub/hvtiRutilities`) from local source.

## Success criteria

1. `quarto render` completes without error and produces **both HTML and a
   generated `.tex`/PDF** for the book.
2. Every plot function family in the chapter plan (hvtiPlotR `hv_*`,
   ggRandomForests `gg_*`, varPro via `gg_*`, TemporalHazard `hazard()`/`hzr_*`)
   has at least one rendered worked example, and the data-governance chapter
   demonstrates the core `hvtiRutilities` workflow.
3. Each example is self-contained: data via `sample_*()`, bundled
   randomForestSRC datasets, or base R — no external files, no PHI.
4. Gap chapters (density, boxplots, postage-stamp) render base-ggplot examples
   styled with a `theme_hv_*` theme.
5. New chapters and the RF part appear in the book navigation via `_quarto.yml`.

## Out of scope (deferred sub-projects)

- **`hvtiRtables` package creation** — a separate brainstorm → spec → plan when
  the user is ready. The book's table chapters use `gt` directly until then.
- **SAS `hazard` gap analysis** — future work; `TemporalHazard` is treated as
  the complete R package here.
- New functionality in any of the existing packages themselves.
- Reorganizing the existing part structure beyond adding the listed chapters
  and the new RF part.
- The `gt` table content beyond representative examples (not an exhaustive gt tutorial).

## Risks

- **`TemporalHazard` and `hvtiRutilities` not installed.** Must `install_local`
  from `~/Documents/GitHub/temporal_hazard` and `~/Documents/GitHub/hvtiRutilities`
  before rendering, else those chapters fail. Fallback: set the affected
  chapter's chunks `eval: false` and show code only.
- **RF rendering cost.** `rfsrc()` fits are slow; use small `ntree` and small
  datasets, and rely on Quarto's freeze/cache so re-renders are cheap.
- **PDF/LaTeX figure sizing.** Poster/PPT themes are large; for the PDF format,
  rely on per-chunk `fig-width`/`fig-height` so wide figures don't overflow the
  page.

## Verification

`quarto render` from the repo root; confirm HTML in `_book/` and a generated
`.tex`/PDF for each chapter/the book. Per repo workflow: all changes land on
branch `feat/plot-recipes` via PR; the user merges.
