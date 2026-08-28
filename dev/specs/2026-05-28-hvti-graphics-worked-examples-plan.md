# HVTI Graphics Recipes — Worked Examples Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fill the stub chapters of the `hvti_graphics` Quarto book with self-contained, rendered worked examples across `hvtiPlotR`, `ggRandomForests`/`randomForestSRC`/`varPro`, `TemporalHazard`, and `hvtiRutilities`, rendering to HTML and PDF/LaTeX.

**Architecture:** Each chapter is a `.qmd` with a shared hidden setup chunk plus worked examples. hvtiPlotR/decorator chapters are adapted from the package's existing vignettes (`vignettes/plot-functions.qmd`, `vignettes/plot-decorators.qmd`) at the exact line ranges cited per task. RF/varPro and TemporalHazard chapters use fresh code (no vignette source). Gap chapters use base ggplot2 styled with `theme_hv_manuscript()`. The "test" for every chapter is a successful `quarto render` of that file.

**Tech Stack:** Quarto 1.10, R, knitr; `hvtiPlotR` 2.3.1, `ggRandomForests` 2.7.3.9014 (→ v3.0.0), `randomForestSRC` 3.6.2, `varPro` 3.1.0, `TemporalHazard` 1.0.3, `hvtiRutilities` 1.0.0.9004, `gt`, `patchwork`, LaTeX (`pdflatex`).

**Spec:** `docs/superpowers/specs/2026-05-28-hvti-graphics-worked-examples-design.md`
**Branch:** `feat/plot-recipes` (already created)

---

## Conventions used in every chapter

**Shared setup chunk** — the first chunk of every chapter. Add `library()` lines for the packages that chapter uses (noted per task). The hvtiPlotR baseline is:

````markdown
```{r}
#| label: setup
#| include: false
knitr::opts_chunk$set(
  echo = TRUE, message = FALSE, warning = FALSE,
  fig.width = 7, fig.height = 4.5, dpi = 150
)
library(hvtiPlotR)
library(ggplot2)
```
````

**Per-chapter render check (the "test"):**

```bash
quarto render <file>.qmd --to html
```
Expected: exits 0; produces `<file>.html`; no R errors in stdout. (Single-file render is fast and validates the R code; the full book + PDF is built in the final task.)

**Commit cadence:** one commit per chapter (or per gap-chapter pair), message `docs(book): <chapter> worked examples`.

**Source-adaptation rule:** where a task says "adapt vignette lines A–B", open `~/Documents/GitHub/hvtiPlotR/vignettes/<file>.qmd` at those lines, copy the relevant chunks, condense to the variants listed, and re-flow prose to book style (drop SAS-template cross-references unless noted). Do NOT invent new API — use only functions shown in the source.

---

## Task 0: Environment + book configuration

**Files:**
- Modify: `_quarto.yml`
- Create: `.gitignore` entry check only (no change expected)

- [ ] **Step 1: Install the two local-source packages**

Run:
```bash
Rscript -e 'devtools::install_local("~/Documents/GitHub/temporal_hazard", upgrade="never", force=TRUE); devtools::install_local("~/Documents/GitHub/hvtiRutilities", upgrade="never", force=TRUE)'
```
Expected: both install; `* DONE (TemporalHazard)` and `* DONE (hvtiRutilities)`.

- [ ] **Step 2: Verify all six packages load**

Run:
```bash
Rscript -e 'for (p in c("hvtiPlotR","ggRandomForests","randomForestSRC","varPro","TemporalHazard","hvtiRutilities")) cat(p, as.character(requireNamespace(p, quietly=TRUE)), "\n")'
```
Expected: all six print `TRUE`.

- [ ] **Step 3: Rewrite `_quarto.yml`** — register new chapters/part, set HTML+PDF, drop typst, enable freeze.

Replace the file with:
```yaml
project:
  type: book
  output-dir: _book

book:
  title: "HVTI ggplot graphics recipes"
  author: "John Ehrlinger <ehrlinj@ccf.org>"
  date: today
  page-navigation: true
  page-footer:
    left: "Copyright 2025, John Ehrlinger"
    right:
      - icon: github
        href: https://github.com/ehrlinger/hvti_graphics
  chapters:
    - index.qmd
    - intro.qmd
    - part: gettingstarted.qmd
      chapters:
        - packages.qmd
        - usingR.qmd
        - data_governance.qmd
    - part: figures.qmd
      chapters:
        - scatter.qmd
        - survival.qmd
        - hazard.qmd
        - nnt.qmd
        - temporal_hazard.qmd
        - histograms.qmd
        - density.qmd
        - bar.qmd
        - boxplots.qmd
        - upset.qmd
        - spaghetti.qmd
        - postagestamp.qmd
        - specialty.qmd
        - consort.qmd
        - sankey.qmd
        - balance.qmd
        - combination.qmd
    - part: "Random forests & variable selection"
      chapters:
        - randomforests.qmd
        - rf_error.qmd
        - rf_predicted.qmd
        - rf_vimp.qmd
        - rf_dependence.qmd
        - rf_roc.qmd
        - varpro.qmd
    - part: tables.qmd
      chapters:
        - qt_tables.qmd
        - figure_tables.qmd
    - part: formatting.qmd
      chapters:
        - annotation.qmd
        - themes.qmd
        - colors.qmd
        - legends.qmd
    - part: publications.qmd
      chapters:
        - manuscripts.qmd
        - researchday.qmd
    - summary.qmd
    - references.qmd

bibliography: references.bib

format:
  html:
    theme:
      - cosmo
      - brand
    number-sections: true
  pdf:
    documentclass: scrreprt
    keep-tex: true

execute:
  freeze: auto

editor: source
```

- [ ] **Step 4: Create the new chapter files as minimal stubs so the book is registerable**

Run (creates the 14 new files with a title only; content filled in later tasks):
```bash
cd ~/Documents/GitHub/hvti_graphics
for f in data_governance:"Data governance and reproducibility" \
         hazard:"Hazard and nonparametric curves" \
         nnt:"Number needed to treat and survival difference" \
         temporal_hazard:"Parametric hazard modeling with TemporalHazard" \
         consort:"CONSORT patient-flow diagrams" \
         sankey:"Alluvial and Sankey plots" \
         balance:"Covariate balance and follow-up" \
         randomforests:"Random forests: fit then visualize" \
         rf_error:"Random forest error convergence" \
         rf_predicted:"Predicted response and survival" \
         rf_vimp:"Variable importance" \
         rf_dependence:"Variable and partial dependence" \
         rf_roc:"ROC and Brier performance" \
         varpro:"Variable priority with varPro"; do
  name="${f%%:*}"; title="${f##*:}";
  [ -f "$name.qmd" ] || printf '# %s\n' "$title" > "$name.qmd";
done
ls data_governance.qmd hazard.qmd nnt.qmd temporal_hazard.qmd consort.qmd sankey.qmd balance.qmd randomforests.qmd rf_error.qmd rf_predicted.qmd rf_vimp.qmd rf_dependence.qmd rf_roc.qmd varpro.qmd
```
Expected: all 14 filenames listed.

- [ ] **Step 5: Render the whole book skeleton to HTML to confirm config is valid**

Run: `cd ~/Documents/GitHub/hvti_graphics && quarto render --to html`
Expected: exits 0; `_book/index.html` exists; all new chapters appear in the sidebar.

- [ ] **Step 6: Commit**

```bash
git add _quarto.yml data_governance.qmd hazard.qmd nnt.qmd temporal_hazard.qmd consort.qmd sankey.qmd balance.qmd randomforests.qmd rf_error.qmd rf_predicted.qmd rf_vimp.qmd rf_dependence.qmd rf_roc.qmd varpro.qmd
git commit -m "docs(book): register chapters/RF part, add HTML+PDF formats, stub new chapters"
```

---

## Wave 1 — Getting started

### Task 1: `data_governance.qmd` (hvtiRutilities)

**Files:**
- Modify: `data_governance.qmd`

**Setup chunk libraries:** `hvtiRutilities`, `gt` (for displaying the dictionary nicely).

- [ ] **Step 1: Write the chapter** with these sections, using only `hvtiRutilities` exports. Reproducible input via `generate_survival_data()`.

````markdown
# Data governance and reproducibility

```{r}
#| label: setup
#| include: false
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)
library(hvtiRutilities)
library(gt)
```

Reproducible analysis starts before the first plot: a documented dataset, typed
and labelled variables, and a manifest that pins exactly which extract produced
a result. `hvtiRutilities` provides those building blocks.

## A reproducible sample dataset

```{r}
dat <- generate_survival_data(n = 200, seed = 42)
str(dat)
```

## Data dictionary

`data_dictionary()` summarises every column — type, missingness, and a compact
value summary — the artefact you attach to a deliverable.

```{r}
dd <- data_dictionary(dat)
dd
```

## Variable labels

`label_map()` extracts the current label/variable mapping; `add_labels()`
applies a new set. Labels travel with the data into tables and figures.

```{r}
lm <- label_map(dat)
lm
```

## Inferring R data types

`r_data_types()` classifies columns (continuous, binary, categorical) so
downstream code can branch on variable role rather than storage type.

```{r}
r_data_types(dat)
```

## Dataset manifests

A manifest records the provenance of an extract — source, date, row count, and
a content hash — so a result can be traced to the exact data that produced it.

```{r}
#| eval: false
manifest_path <- tempfile(fileext = ".yaml")
update_manifest(
  file        = "delivery_2026_05.csv",
  manifest_path = manifest_path,
  extract_date  = Sys.Date(),
  n_rows        = nrow(dat),
  source        = "CORR DWH"
)
verify_manifest(manifest_path, data_dir = ".")
```

## Comparing dataset versions

When a re-delivery arrives, `compare_datasets()` reports what changed between
the old and new extracts — added/removed columns and rows.

```{r}
old <- dat[1:150, ]
new <- dat[51:200, ]
cmp <- compare_datasets(old, new)
cmp
```
````

Note: confirm `data_dictionary()` returns an object that prints cleanly; if it
returns a data frame, wrap the display chunk in `gt(dd)`. The manifest chunk is
`eval: false` because it writes a file and needs a real data path.

- [ ] **Step 2: Render check** — `quarto render data_governance.qmd --to html` → exits 0, no R errors.
- [ ] **Step 3: Commit** — `git add data_governance.qmd && git commit -m "docs(book): data_governance worked examples"`

---

## Wave 2 — hvtiPlotR figures

All Wave 2 tasks adapt `~/Documents/GitHub/hvtiPlotR/vignettes/plot-functions.qmd`.
Setup chunk libraries: `hvtiPlotR`, `ggplot2` (add `patchwork` where noted).

### Task 2: `scatter.qmd` — `hv_eda` continuous scatter

**Files:** Modify `scatter.qmd`
**Source:** plot-functions.qmd lines 885–1107 (EDA section), continuous scatter subsection ~1006–1022.

- [ ] **Step 1:** Replace the stub. Keep only the continuous scatter + LOESS example here (the categorical/bar variants go in `bar.qmd`). Use `sample_eda_data()`; show `hv_eda(..., x_col, y_col)` → `plot()` → decorate with `labs()` + `theme_hv_manuscript()`. Include the `plot.hv_eda(smooth_method=, smooth_span=)` LOESS variant.
- [ ] **Step 2:** Render check `quarto render scatter.qmd --to html` → exits 0.
- [ ] **Step 3:** Commit `docs(book): scatter worked examples`.

### Task 3: `survival.qmd` — `hv_survival` Kaplan-Meier family

**Files:** Modify `survival.qmd`
**Source:** plot-functions.qmd lines 674–884 (KM section).

- [ ] **Step 1:** Adapt the KM section. Use `sample_survival_data()`; build the `hv_survival()` object once, then show: survival curve (`type` default), numbers-at-risk note, cumulative hazard, log-log, integrated life table — each via `plot(obj, type=...)`. Drop the "Saving" subsection (covered in publications) and the SAS `PLOTS=` cross-refs. Decorate with `theme_hv_manuscript()`.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): survival worked examples`.

### Task 4: `hazard.qmd` — `hazard_plot`, `hv_nonparametric`, `hv_ordinal`

**Files:** Modify `hazard.qmd`
**Source:** plot-functions.qmd lines 1443–1634 (Hazard), 2346–2503 (Nonparametric curve), 2504–2653 (Nonparametric ordinal).

- [ ] **Step 1:** Three sections.
  (a) **Hazard plot** — `sample_hazard_data()` / `sample_hazard_empirical()`; show `hazard_plot()` survival-with-KM-overlay, hazard rate, cumulative hazard, stratified, life-table overlay (pick 3 representative variants, not all).
  (b) **Nonparametric curve** — `sample_nonparametric_curve_data()` + `sample_nonparametric_curve_points()`; single average curve with CI ribbon, two-group comparison.
  (c) **Ordinal** — `sample_nonparametric_ordinal_data()` + `_points()`; grade-probability curves with data points.
  Use `theme_hv_manuscript()`. Drop the dplyr "collapse grades" commented block.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): hazard worked examples`.

### Task 5: `nnt.qmd` — `nnt_plot`, `survival_difference_plot`

**Files:** Modify `nnt.qmd`
**Source:** plot-functions.qmd lines 1635–1715 (survival difference), 1716–1805 (NNT).

- [ ] **Step 1:** Two sections. NNT: `sample_nnt_data()` → `nnt_plot()` NNT curve + absolute-risk-reduction variant. Survival difference: `sample_survival_difference_data()` → `survival_difference_plot()` single curve + multiple-comparisons variant. `theme_hv_manuscript()`.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): nnt worked examples`.

### Task 6: `histograms.qmd` — `hv_mirror_hist`, `hv_stacked`

**Files:** Modify `histograms.qmd`
**Source:** plot-functions.qmd lines 78–253 (mirror histogram), 254–339 (stacked).

- [ ] **Step 1:** Mirror histogram: `sample_mirror_histogram_data()` binary-match mode + IPTW weighted mode, each bare + decorated (the decorated `scale_fill_manual` block is in the source). Stacked: `sample_stacked_histogram_data()` count + proportion variants. Keep the diagnostics readout (`$tables$diagnostics`). `theme_hv_poster()` for the mirror (as in source), `theme_hv_manuscript()` for stacked.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): histograms worked examples`.

### Task 7: `bar.qmd` — `hv_eda` bars, `hv_longitudinal`

**Files:** Modify `bar.qmd`
**Source:** plot-functions.qmd lines 885–1107 (EDA bars: 921–1005), 2654–2775 (longitudinal counts).

**Setup chunk libraries:** `hvtiPlotR`, `ggplot2`, `patchwork`.

- [ ] **Step 1:** EDA bars: `sample_eda_data()` → binary count barplot + percentage barplot + ordinal/multi-level. Longitudinal: `sample_longitudinal_counts_data()` → bar chart + numeric table panel + two-panel patchwork layout. `theme_hv_manuscript()`.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): bar worked examples`.

### Task 8: `upset.qmd` — `hv_upset`

**Files:** Modify `upset.qmd`
**Source:** plot-functions.qmd lines 2776–2881 (UpSet).

- [ ] **Step 1:** Keep the existing Venn-diagram intro prose at the top of the current `upset.qmd`. Under "## Upset plots", add: `sample_upset_data()` → `hv_upset()` default plot, custom intersection bar colour, colour-bars-by-era variant. Note the patchwork-composite behaviour when `set_size = TRUE`. `theme_hv_manuscript()` via `&` on the composite.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): upset worked examples`.

### Task 9: `spaghetti.qmd` — `hv_spaghetti`, `hv_trends`

**Files:** Modify `spaghetti.qmd`
**Source:** plot-functions.qmd lines 2152–2345 (spaghetti), 1806–2151 (trends — pick a subset).

- [ ] **Step 1:** Spaghetti: `sample_spaghetti_data()` → bare, unstratified, stratified-by-group, with LOESS overlay. Trends: `sample_trends_data()` → single-variable cases/year, multiple groups with `scale_colour_brewer`, with confidence ribbon (3 variants max — do NOT port all 12 trend variants). `theme_hv_manuscript()`.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): spaghetti worked examples`.

### Task 10: `consort.qmd` — `hv_consort`

**Files:** Modify `consort.qmd`
**Source:** plot-functions.qmd lines 1336–1442 (CONSORT).

- [ ] **Step 1:** `sample_consort_data()` → build a tracker (`hv_consort_start` → `hv_consort_exclude` → `hv_consort_summary`), render the diagram (`hv_consort`/`plot.hv_consort`), and show the cohort audit (`hv_consort_patients`). Note: the diagram uses a grid/`consort` backend, not ggplot — no theme layering.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): consort worked examples`.

### Task 11: `sankey.qmd` — `hv_alluvial`, `hv_sankey`

**Files:** Modify `sankey.qmd`
**Source:** plot-functions.qmd lines 1108–1230 (alluvial), 1231–1335 (cluster sankey).

- [ ] **Step 1:** Alluvial: `sample_alluvial_data()` → bare, fill-by-grade, two-axis before/after. Cluster sankey: `sample_cluster_sankey_data()` → default (K=2..9), custom palette, subset of K. Decorate per source.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): sankey worked examples`.

### Task 12: `balance.qmd` — `hv_balance`, `hv_followup`

**Files:** Modify `balance.qmd`
**Source:** plot-functions.qmd lines 505–673 (covariate balance), 340–504 (goodness-of-followup).

- [ ] **Step 1:** Balance: `sample_covariate_balance_data()` → bare, add colour/shape/axis scales, directional annotations + theme, controlling covariate order. Followup: `sample_goodness_followup_data()` → death follow-up plot bare + decorated, non-fatal event panel. `theme_hv_manuscript()`.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): balance worked examples`.

### Task 13: `combination.qmd` — patchwork composites

**Files:** Modify `combination.qmd`
**Source:** plot-decorators.qmd lines 693–792 (multi-panel patchwork).

**Setup chunk libraries:** `hvtiPlotR`, `ggplot2`, `patchwork`.

- [ ] **Step 1:** Build two or three small hvtiPlotR plots (reuse `sample_*` generators, e.g. a survival curve + a balance plot), then show: side-by-side, relative widths/heights, plot-above-risk-table, shared axis labels + panel tags (`plot_annotation(tag_levels = "A")`).
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): combination worked examples`.

### Task 14: Gap chapters — `density.qmd`, `boxplots.qmd`, `postagestamp.qmd`

**Files:** Modify `density.qmd`, `boxplots.qmd`, `postagestamp.qmd`
**Source:** none — base ggplot2 styled with `theme_hv_manuscript()`. Data: `hvtiPlotR::sample_eda_data()` (has continuous + categorical columns) or base R `iris`/`mtcars`.

- [ ] **Step 1: `density.qmd`** — `geom_density` (single + grouped/`fill` with alpha), `geom_density(aes(y=after_stat(count)))` variant; `theme_hv_manuscript()`; note hvtiPlotR has no density helper.

````markdown
# Density Plots

```{r}
#| label: setup
#| include: false
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)
library(hvtiPlotR)
library(ggplot2)
```

hvtiPlotR has no dedicated density helper, so we use ggplot2's `geom_density()`
directly and apply a house theme for visual consistency.

```{r}
dat <- sample_eda_data()
num <- names(dat)[vapply(dat, is.numeric, logical(1))][1]
grp <- names(dat)[vapply(dat, function(x) is.factor(x) || (is.character(x)), logical(1))][1]

ggplot(dat, aes(x = .data[[num]])) +
  geom_density(fill = "grey70", alpha = 0.7) +
  labs(x = num, y = "Density") +
  theme_hv_manuscript()
```

```{r}
ggplot(dat, aes(x = .data[[num]], fill = .data[[grp]])) +
  geom_density(alpha = 0.5) +
  labs(x = num, y = "Density", fill = grp) +
  theme_hv_manuscript()
```
````

- [ ] **Step 2: `boxplots.qmd`** — `geom_boxplot` (single + grouped), optional jitter overlay; same setup/theme pattern, same `sample_eda_data()` column-detection idiom.
- [ ] **Step 3: `postagestamp.qmd`** — small multiples via `facet_wrap`: take a continuous outcome over a faceting variable, `geom_line`/`geom_point` + `facet_wrap(~ grp)`; `theme_hv_manuscript()`; explain "postage stamp" = grid of small panels.
- [ ] **Step 4:** Render check each — `quarto render density.qmd --to html`, `boxplots.qmd`, `postagestamp.qmd` → all exit 0.
- [ ] **Step 5:** Commit `docs(book): gap chapters (density, boxplots, postage-stamp)`.

---

## Wave 3 — TemporalHazard

### Task 15: `temporal_hazard.qmd`

**Files:** Modify `temporal_hazard.qmd`
**Source:** none — TemporalHazard API. Verify signatures against `?hazard`, `?predict.hazard`, `?hzr_kaplan` before writing; the package ships example data (`R/data.R`).

**Setup chunk libraries:** `TemporalHazard`, `ggplot2`, `hvtiPlotR` (for theme).

- [ ] **Step 1:** Identify a bundled TemporalHazard dataset:
  ```bash
  Rscript -e 'data(package="TemporalHazard")$results[,"Item"]'
  ```
  Use that dataset (fallback: `survival::veteran` with `Surv(time, status)`).

- [ ] **Step 2:** Write sections:
  (a) **Nonparametric** — `hzr_kaplan(time, status)` and `hzr_nelson(time, event)`; plot the returned estimates with `ggplot` + `theme_hv_manuscript()`.
  (b) **Parametric fit** — `fit <- hazard(time, status, ...)`; `predict(fit, type=...)` for hazard / cumulative hazard / survival on a time grid; plot each.
  (c) **Competing risks** — `hzr_competing_risks(time, event)` cumulative incidence.
  (d) **Diagnostics** — `hzr_calibrate(...)` and `hzr_gof(fit, time_grid)` plotted or tabulated.
  Use the actual returned object structure (inspect with `str()` first) to build the ggplot frames; do not assume column names — derive them from the returned object.

- [ ] **Step 3:** Render check → exits 0. If any TemporalHazard call errors, set that chunk `eval: false` with a one-line note (per spec fallback) rather than blocking.
- [ ] **Step 4:** Commit `docs(book): temporal_hazard worked examples`.

---

## Wave 4 — Random forests & variable selection

Setup chunk libraries: `randomForestSRC`, `ggRandomForests`, `ggplot2`, `hvtiPlotR` (theme).
**Render cost control:** every `rfsrc()` call uses `ntree = 100` and `nodesize` defaults; rely on `freeze: auto` so re-renders are cached. Verify `gg_*` signatures against installed help (`?gg_vimp`, etc.) — the package is on the v3.0.0 dev line and some args may differ from CRAN 2.7.3.

### Task 16: `randomforests.qmd` — part intro

**Files:** Modify `randomforests.qmd`

- [ ] **Step 1:** Explain the workflow: fit with `randomForestSRC::rfsrc()`, then visualize with ggRandomForests `gg_*()` constructors, each with `plot()`/`autoplot()`. Show one minimal end-to-end example:
  ```r
  library(randomForestSRC); library(ggRandomForests)
  data(veteran, package = "randomForestSRC")
  rf <- rfsrc(Surv(time, status) ~ ., data = veteran, ntree = 100)
  plot(gg_error(rf)) + theme_hv_manuscript()
  ```
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): randomforests intro`.

### Task 17: `rf_error.qmd` — `gg_error`

**Files:** Modify `rf_error.qmd`. Dataset: `veteran` (survival).

- [ ] **Step 1:** Fit `rf <- rfsrc(Surv(time, status) ~ ., data = veteran, ntree = 100)`; `plot(gg_error(rf)) + theme_hv_manuscript()`; explain OOB error vs. number of trees as a convergence check.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): rf_error worked examples`.

### Task 18: `rf_predicted.qmd` — `gg_rfsrc`, `gg_survival`

**Files:** Modify `rf_predicted.qmd`. Datasets: `veteran`, `pbc`.

- [ ] **Step 1:** `gg_rfsrc(rf)` predicted survival curves (per-observation); `gg_survival(...)` population survival by a grouping variable. Fit pbc with `rfsrc(Surv(days, status) ~ ., data = pbc, ntree = 100)` (drop rows with `NA` in outcome if needed). Decorate with `theme_hv_manuscript()`.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): rf_predicted worked examples`.

### Task 19: `rf_vimp.qmd` — `gg_vimp`

**Files:** Modify `rf_vimp.qmd`. Dataset: `pbc`.

- [ ] **Step 1:** Fit pbc rfsrc; `plot(gg_vimp(rf)) + theme_hv_manuscript()`; explain VIMP (permutation importance) ranking; show `gg_vimp(rf, nvar = 10)`.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): rf_vimp worked examples`.

### Task 20: `rf_dependence.qmd` — `gg_variable`, `gg_partial`

**Files:** Modify `rf_dependence.qmd`. Dataset: `pbc`.

- [ ] **Step 1:** `gg_variable(rf)` variable dependence (panel of top predictors, e.g. `bili`, `age`); `gg_partial(plot.variable(rf, partial = TRUE, ...))` or `gg_partial_rfsrc(...)` partial dependence — verify the current constructor name with `?gg_partial` / `?gg_partial_rfsrc` and use whichever the installed dev build exports. Decorate with `theme_hv_manuscript()`.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): rf_dependence worked examples`.

### Task 21: `rf_roc.qmd` — `gg_roc`, `gg_brier`

**Files:** Modify `rf_roc.qmd`. Dataset: `breast` (classification, status N/R) and/or `wine`.

- [ ] **Step 1:** Fit `rf <- rfsrc(status ~ ., data = breast, ntree = 100)`; `plot(gg_roc(rf, which.outcome = "R")) + theme_hv_manuscript()` (verify arg name `which.outcome`/`which_outcome` against `?gg_roc`); `plot(gg_brier(rf))`. For a multi-class example use `wine` and `gg_roc(..., per_class = TRUE)` if supported.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): rf_roc worked examples`.

### Task 22: `varpro.qmd` — varPro via ggRandomForests

**Files:** Modify `varpro.qmd`. Datasets: `housing` (regression), `breast` (classification).
**Setup chunk libraries:** `varPro`, `ggRandomForests`, `ggplot2`, `hvtiPlotR`.

- [ ] **Step 1:** Fit `o <- varpro(medv ~ ., data = ...)` (verify `housing` outcome name with `names(housing)`; use the actual response column). Show: `gg_varpro(o)` importance, `gg_beta_varpro(o)` (regression β refinement), `gg_partial_varpro(...)` partial effects. For classification use `breast`; add `gg_ivarpro(o)` and `gg_isopro(...)` if the installed build supports them. Cache the expensive `beta.varpro` call if needed (pass a precomputed `beta_fit`). Verify every constructor name/signature against installed help first. Decorate with `theme_hv_manuscript()`.
- [ ] **Step 2:** Render check → exits 0. Set any unsupported-on-this-build chunk `eval: false` with a note rather than blocking.
- [ ] **Step 3:** Commit `docs(book): varpro worked examples`.

---

## Wave 5 — Tables (gt)

### Task 23: `qt_tables.qmd` — publication gt table

**Files:** Modify `qt_tables.qmd`
**Setup chunk libraries:** `gt`, `hvtiPlotR` (for `sample_*` data), `dplyr`.

- [ ] **Step 1:** Keep the existing gt-effective-display-tables link as a reference at top. Build a "Table 1"-style summary from `sample_survival_data()` or `generate_survival_data()` (group counts, means/SD, %), rendered with `gt()` + `tab_header()` + `cols_label()` + `fmt_number()`. Add a one-line note: "These tables will migrate to the planned `hvtiRtables` package."
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): qt_tables worked examples`.

### Task 24: `figure_tables.qmd` — tables paired with figures

**Files:** Modify `figure_tables.qmd`
**Setup chunk libraries:** `hvtiPlotR`, `gt`, `ggplot2`, `patchwork`.

- [ ] **Step 1:** Numbers-at-risk: build `hv_survival()` and extract the risk/report table (inspect `obj$tables` with `str()` to find the exact slot — verify during implementation per spec) and render with `gt()`. Longitudinal table panel: `hv_longitudinal()` numeric table panel from Task 7's source (lines 2720–2738). Same hvtiRtables migration note.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): figure_tables worked examples`.

---

## Wave 6 — Formatting

All Wave 6 tasks adapt `~/Documents/GitHub/hvtiPlotR/vignettes/plot-decorators.qmd`.
Setup chunk libraries: `hvtiPlotR`, `ggplot2`.

### Task 25: `annotation.qmd`

**Files:** Modify `annotation.qmd`
**Source:** plot-decorators.qmd lines 223–290 (labels/annotations), plot-functions.qmd lines 2882–2946 (footnotes).

- [ ] **Step 1:** Build a base plot, then: `labs()`, `annotate("text"/"segment")`, `coord_cartesian()` zoom, and `make_footnote()` draft + publication footnote patterns.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): annotation worked examples`.

### Task 26: `themes.qmd`

**Files:** Modify `themes.qmd`
**Source:** plot-decorators.qmd lines 66–164 (themes), 571–692 (theme overrides).

- [ ] **Step 1:** Same base plot rendered under each theme: `theme_hv_manuscript()`, `theme_hv_poster()`, `theme_hv_ppt_light()`/`theme_hv_ppt()`, `theme_hv_ppt_dark()`. Then theme overrides: axis text size, removing minor grids, rotating x labels, title/subtitle, margins (via `...` forwarding into the theme functions).
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): themes worked examples`.

### Task 27: `colors.qmd`

**Files:** Modify `colors.qmd`
**Source:** plot-decorators.qmd lines 165–222 (colour scales).

- [ ] **Step 1:** Manual colours (`scale_colour_manual`/`scale_fill_manual`), ColorBrewer palettes (`scale_colour_brewer`), suppressing legends (`guide = "none"`).
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): colors worked examples`.

### Task 28: `legends.qmd`

**Files:** Modify `legends.qmd`
**Source:** plot-decorators.qmd lines 473–570 (legend positioning).

- [ ] **Step 1:** Legend inside the panel, outside (explicit sides), suppress all, legend text/key size.
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): legends worked examples`.

---

## Wave 7 — Publications

Setup chunk libraries: `hvtiPlotR`, `ggplot2`.
**Source:** plot-decorators.qmd lines 291–472 (saving).

### Task 29: `manuscripts.qmd`

**Files:** Modify `manuscripts.qmd`

- [ ] **Step 1:** Manuscript PDF save: build a plot with `theme_hv_manuscript()`, then `hv_ggsave_dims()` + `ggsave()` to a PDF — set the save chunks `eval: false` so the book build does not write files. Add a PowerPoint section (officer/rvg via `save_ppt()`), also `eval: false`, showing the code only (per spec).
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): manuscripts worked examples`.

### Task 30: `researchday.qmd`

**Files:** Modify `researchday.qmd`

- [ ] **Step 1:** Poster sizing: build a plot with `theme_hv_poster()`, show poster-dimension `ggsave()` (`eval: false`). Explain large base sizes / fixed-panel geometry (`hv_ph_location()`).
- [ ] **Step 2:** Render check → exits 0.
- [ ] **Step 3:** Commit `docs(book): researchday worked examples`.

---

## Wave 8 — Full build + finish

### Task 31: Full book render (HTML + PDF) and review

**Files:** none (build only)

- [ ] **Step 1:** Full HTML render — `cd ~/Documents/GitHub/hvti_graphics && quarto render --to html`. Expected: exits 0; every chapter present under `_book/`.
- [ ] **Step 2:** Full PDF/LaTeX render — `quarto render --to pdf`. Expected: exits 0; `_book/*.pdf` produced and `keep-tex` leaves a `.tex`. Fix any LaTeX figure-overflow by adding per-chunk `fig-width`/`fig-height` (per spec risk).
- [ ] **Step 3:** Spot-check 3–4 rendered chapters (one hvtiPlotR, one RF, temporal_hazard, one gap) for actual figures, not error text.
- [ ] **Step 4:** Commit any render fixes — `git commit -am "docs(book): full HTML+PDF render fixes"`.

### Task 32: Finish the branch

- [ ] **Step 1:** Confirm clean tree — `git status` → only intended files.
- [ ] **Step 2:** Invoke `superpowers:finishing-a-development-branch` to choose merge/PR. Per repo workflow: open a PR with `gh pr create`, let the user merge. Do NOT push to `main` directly.

---

## Self-Review (completed by plan author)

**Spec coverage:** every chapter in the spec's chapter plan maps to a task — Getting started/governance (T1), figures incl. survival split + gaps (T2–T14), TemporalHazard (T15), RF part + varpro (T16–T22), tables (T23–T24), formatting (T25–T28), publications (T29–T30), output formats + installs (T0), full HTML+PDF build (T31). No spec section is unaddressed.

**Placeholder scan:** chapters adapted from vignettes cite exact line ranges instead of duplicating code (the source file is authoritative and on disk) — this is a deliberate adaptation instruction, not a TBD. Fresh-code chapters (governance, gaps, RF, TemporalHazard, tables) include concrete runnable code or exact constructor calls + dataset names. RF/varPro/TemporalHazard tasks include an explicit "verify signature against installed help" step because the dev build may differ from CRAN docs — that is a verification action, not a placeholder.

**Type/name consistency:** theme functions use `theme_hv_*()` throughout; `sample_*()` generator names match the package exports verified in the spec; rfsrc formulas use real dataset columns (`veteran`: time/status; `pbc`: days/status; `breast`: status N/R). `_quarto.yml` chapter filenames match the files created in Task 0 Step 4.
