# HVTI Recipes 3.0.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the book to *HVTI Recipes* (edition 3.0.0), add SHAP and table
chapters, and close the varPro coverage and correctness gaps.

**Architecture:** This is a Quarto book. Each chapter is a top-level `.qmd` in
the repo root, wired into the `book.chapters` tree in `_quarto.yml`. Chapters
execute R at render time; results are cached under `_freeze/`. There is no test
suite — **the render is the test**, and a chapter only counts as verified when
it renders with its freeze cache cleared.

**Tech Stack:** Quarto 1.x (book project), R, `ggplot2`, `hvtiPlotR`,
`ggRandomForests` 3.5.0, `varPro`, `kernelshap`, `gt`, `gtsummary`,
`hvtiRtables`, `hvtiRutilities`.

**Spec:** `dev/specs/2026-08-05-book-shap-and-tables-design.md`

## Global Constraints

- **Branch:** all work on `feat/shap-and-tables-chapters`. Never commit to
  `main`. Open a PR at the end; do not merge it.
- **Book title is `HVTI Recipes`.** Edition is `3.0.0`, and it appears in
  exactly one place: the README edition badge.
- **Repo stays `hvti_graphics`.** The published URL stays
  `https://ehrlinger.github.io/hvti_graphics/`. Do not rename the repo.
- **Chapter template**, set by `rf_vimp.qmd` and `varpro.qmd`: `# Title`, a
  hidden `setup` chunk, `## When to use it`, `## The data it needs`,
  `## Build it`, `## Read it`, `## Variations`, `## Pitfalls`.
- **Prose follows the `ehrlinger-writing` harness**, reader persona (a)
  HVTI/CORR biostatistician. Invoke that skill before authoring chapter prose.
- **Never write package lifecycle language into a chapter** — no version
  numbers, no "planned", "not yet", "will migrate to". That framing is exactly
  what went stale and caused this work.
- **Every figure chunk needs `#| label:` and `#| fig-cap:`.** Labels for
  figures are `fig-<something>`.
- **PDF is not a gate.** `cairo_pdf` is unavailable on this machine; book CI is
  HTML-only. Render with `quarto render --to html`.
- **`freeze: auto` will serve a cached success.** Any task that adds or changes
  an R chunk must clear that chapter's `_freeze/` directory before rendering,
  or the render proves nothing.

---

## File Structure

| File | Status | Responsibility |
|---|---|---|
| `_quarto.yml` | Modify | Book title, subtitle, chapter tree |
| `README.md` | Modify | Title, edition badge, lede, edition notes |
| `index.qmd` | Modify | Preface — de-figure-centre the framing |
| `HVTI-ggplot-graphics-recipes.tex` | Delete | Untracked 458 KB `keep-tex` leftover |
| `varpro_partial.qmd` | Modify | Add `method = "rnd"` to 5 call sites + pitfall |
| `rf_shap.qmd` | Create | SHAP attribution chapter |
| `varpro.qmd` | Modify | Add `gg_sdependent`, `gg_beta_uvarpro`, `varpro_feature_names` |
| `data_tables.qmd` | Create | `proc_contents` / `proc_means` / `data_dictionary` |
| `tables.qmd` | Modify | Part intro — remove stale hvtiRtables claim |
| `qt_tables.qmd` | Modify | Reframe as the by-hand teaching chapter |
| `hv_tables.qmd` | Create | hvtiRtables manuscript pipeline (**blocked**) |

---

## Task 1: Rename to HVTI Recipes 3.0.0

**Files:**
- Modify: `_quarto.yml:6-8`
- Modify: `README.md:1`, `README.md:5`, `README.md:8-12`, `README.md:17-21`
- Modify: `index.qmd:10-31`
- Delete: `HVTI-ggplot-graphics-recipes.tex`

**Interfaces:**
- Consumes: nothing.
- Produces: the book title string `HVTI Recipes` and edition `3.0.0`. No later
  task depends on code from this one, but every later task assumes the book is
  already renamed.

- [ ] **Step 1: Confirm the starting state**

```bash
grep -rn "ggplot graphics recipes" . --include="*.qmd" --include="*.yml" --include="*.md" --exclude-dir=_book --exclude-dir=_freeze --exclude-dir=.quarto --exclude-dir=dev
```

Expected: exactly two hits — `_quarto.yml:6` and `README.md:1`.

- [ ] **Step 2: Retitle in `_quarto.yml`**

Replace lines 6-8:

```yaml
  title: "HVTI Recipes"
  subtitle: "Figures, tables, and R recipes for CORR manuscripts"
  author: "John Ehrlinger <ehrlinj@ccf.org>"
```

The old `subtitle: "Version 2.1"` is deliberately gone — the version lives only
in the README badge from now on.

- [ ] **Step 3: Retitle the README and bump the edition badge**

`README.md:1` becomes:

```markdown
# HVTI Recipes
```

`README.md:5` becomes:

```markdown
[![Version](https://img.shields.io/badge/edition-3.0.0-blue)](https://github.com/ehrlinger/hvti_graphics/releases)
```

Leave the Publish, Site, and License badges untouched — the URL has not moved.

- [ ] **Step 4: Rewrite the README lede and edition notes**

Replace the lede (`README.md:8-12`). It currently reads "A working catalog of
the figures we draw…" — it must name tables as a first-class subject, not an
afterthought. Keep the closing line "start from a working recipe, not a blank
script", which is the book's thesis.

Replace the 3-paragraph 2.0.0 edition block (`README.md:17-21`) with 3.0.0
notes covering: the rename and why; SHAP attribution for random forests; the
expanded Tables part (data description via `hvtiRutilities`, manuscript-
compliant Word output via `hvtiRtables`); and the varPro coverage pass.

Author this per the `ehrlinger-writing` harness.

- [ ] **Step 5: De-figure-centre the preface**

In `index.qmd`, two places assume figures are the only subject:

`index.qmd:17-19` — "Two ideas run through the whole book. First, a figure is
built in two steps: a constructor prepares and validates the data, then
`plot()` hands you a bare ggplot you finish with the usual `+`." Keep the
constructor/`plot()` idea (it is true and useful) but scope it explicitly to
figures, so a reader does not take it as the book's universal model.

`index.qmd:24-31` — the parts tour ends "…and the last parts handle tables and
getting a finished figure out the door." Give the Tables part its own clause
describing what it covers, rather than listing it as an exit ramp.

- [ ] **Step 6: Delete the stale LaTeX artifact**

```bash
rm -f HVTI-ggplot-graphics-recipes.tex
```

It is untracked (`git ls-files | grep -c '\.tex$'` returns 0), so this is not a
tracked deletion. It regenerates under the new name on the next PDF render.

- [ ] **Step 7: Verify no old title survives**

```bash
grep -rn "ggplot graphics recipes\|Version 2.1\|edition-2.0.0" . --include="*.qmd" --include="*.yml" --include="*.md" --exclude-dir=_book --exclude-dir=_freeze --exclude-dir=.quarto --exclude-dir=dev
```

Expected: no output. (`dev/` is excluded because `dev/specs/` holds historical
plan files that legitimately quote the old title. It was `docs/` when this plan
was written, before the portfolio settled on `dev/specs/`.)

- [ ] **Step 8: Render the front matter**

```bash
quarto render index.qmd --to html
```

Expected: renders without error, and the generated page shows the new title.

- [ ] **Step 9: Update the GitHub repo description**

This is repo *metadata*, not tracked source — no branch or render will ever
catch it. The current description reads "Graphics Gallery fo Cleveland Clinic
Heart Vascular and Thoracic institute": stale scope, and a typo ("fo").

```bash
gh repo edit ehrlinger/hvti_graphics --description "HVTI Recipes — reproducible figures, tables, and datasets for cardiovascular clinical outcomes research"
```

Verify:

```bash
gh repo view ehrlinger/hvti_graphics --json description
```

Do **not** pass `--rename`. The repo slug and the gh-pages URL stay as they are.

- [ ] **Step 10: Commit**

```bash
git add _quarto.yml README.md index.qmd
git commit -m "docs: rename the book to HVTI Recipes, edition 3.0.0

The title said ggplot graphics recipes while the book already carried
consort, sankey, upset, and a gt tables part. Renames it, and moves the
figures-only framing in the preface and README lede with it.

The version string now lives in one place, the README edition badge; it
previously appeared twice with two different values.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 2: Pass `method = "rnd"` at every varPro partial-dependence call

**Files:**
- Modify: `varpro_partial.qmd:64`, `:79`, `:91`, `:108`, `:120`, and its
  `## Pitfalls` section

**Interfaces:**
- Consumes: nothing.
- Produces: nothing later tasks depend on.

**Why this matters:** every `gg_partial_varpro(object = )` call reaches
`varPro::partialpro()`, which grows its own isolation forest and lets
`isopro()` default to `method = "unsupv"`, handing `randomForestSRC` a
zero-length `yvar.wt` pointer (`entry.c:184`). `ggRandomForests` 3.5.1 corrected
its own `?gg_partial_varpro` example to pass `method = "rnd"`. The behaviour is
benign — the pointer is formed, never dereferenced, and the real fix belongs
upstream (`kogalur/randomForestSRC` PR #478). The reason to fix it here is that
readers copy these chunks verbatim.

`gg_partial_varpro()` already accepts `...` and forwards to `partialpro()` in
the installed 3.5.0, so this needs no package upgrade.

- [ ] **Step 1: Confirm five call sites, none passing `method`**

```bash
grep -n 'gg_partial_varpro(object' varpro_partial.qmd
```

Expected: 5 hits — lines 64, 79, 91, 108, 120.

```bash
grep -c 'method = "rnd"' varpro_partial.qmd
```

Expected: `0`.

- [ ] **Step 2: Add `method = "rnd"` to all five calls**

Line 64:

```r
plot(gg_partial_varpro(object = o_reg, nvars = 6, method = "rnd")) & theme_hv_manuscript()
```

Line 79:

```r
plot(gg_partial_varpro(object = o_cls, nvars = 6, scale = "prob", method = "rnd")) &
```

Line 91:

```r
plot(gg_partial_varpro(object = o_cls, nvars = 6, scale = "logodds", method = "rnd")) &
```

Line 108:

```r
plot(gg_partial_varpro(object = o_surv, nvars = 4, scale = "surv", method = "rnd")) &
```

Line 120:

```r
plot(gg_partial_varpro(object = o_surv, nvars = 4, scale = "rmst", method = "rnd")) &
```

Leave the trailing `&` continuations on lines 79/91/108/120 exactly as they are
— they continue onto the next line with `theme_hv_manuscript()`.

- [ ] **Step 3: Add the pitfall**

Append to `varpro_partial.qmd`'s `## Pitfalls` section a bullet that says:
`gg_partial_varpro()` passes `...` through to `varPro::partialpro()`, which
builds its own isolation forest; without `method = "rnd"` that forest defaults
to unsupervised mode and trips a zero-length pointer in `randomForestSRC`. Say
that it is harmless in practice but that the argument should be passed anyway,
and that every call in this chapter does.

Author per the `ehrlinger-writing` harness.

- [ ] **Step 4: Verify by count, not by eye**

```bash
test "$(grep -c 'gg_partial_varpro(object' varpro_partial.qmd)" = "$(grep -c 'method = "rnd"' varpro_partial.qmd)" && echo MATCH || echo MISMATCH
```

Expected: `MATCH` (5 and 5).

- [ ] **Step 5: Clear the freeze and re-render**

```bash
rm -rf _freeze/varpro_partial
quarto render varpro_partial.qmd --to html
```

Expected: renders without error. This chapter fits three `varpro` forests and
runs `partialpro` five times; allow several minutes.

- [ ] **Step 6: Commit**

```bash
git add varpro_partial.qmd
git commit -m "fix: pass method = \"rnd\" at every gg_partial_varpro call

partialpro() grows its own isolation forest, and without method = \"rnd\"
isopro() defaults to unsupv and hands randomForestSRC a zero-length
yvar.wt pointer. Harmless in practice, but the book teaches the pattern
and readers copy these chunks.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 3: `rf_shap.qmd` — SHAP attribution

**Files:**
- Create: `rf_shap.qmd`
- Modify: `_quarto.yml` (chapter tree, after `rf_vimp.qmd`)

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: nothing later tasks depend on.

**Verified facts — do not rediscover these:**

1. **`gg_shap()` rejects survival forests.** It errors with "only regression and
   classification forests are supported in this version; got family 'surv'."
   So `pbc` cannot be used. This chapter uses `breast` (classification), which
   `varpro.qmd` already establishes.
2. **`newdata` must hold predictors only.** Leaving the outcome column in fails
   inside `kernelshap` with `all(colnames(X) %in% colnames(bg_X)) is not TRUE`,
   a stack trace naming neither the outcome nor `newdata`.
3. **Timing on `breast`** (32 predictors, `ntree = 200`): 30 obs/`bg_n` 30 =
   99 s; **20/20 = 48 s**; 15/15 = 28 s. Use 20/20.
4. `gg_shap()` returns a long `data.frame` with columns `id`, `vars`, `shap`,
   `value`, `value_label` — one row per observation × variable (20 × 32 = 640).
5. All three renderers return a plain `ggplot`, so they take
   `+ theme_hv_manuscript()`, **not** patchwork's `&`.

- [ ] **Step 1: Create the chapter skeleton with the setup chunk**

Create `rf_shap.qmd`:

````markdown
# SHAP attribution

```{r}
#| label: setup
#| include: false
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, fig.width = 7, fig.height = 4.5, dpi = 150)
library(randomForestSRC)
library(ggRandomForests)
library(ggplot2)
library(hvtiPlotR)
```

## When to use it

## The data it needs

## Build it

## Read it

## Variations

## Pitfalls
````

- [ ] **Step 2: Add the fit and the SHAP computation under "The data it needs"**

```` markdown
```{r}
#| label: shap-fit
set.seed(42)
data(breast, package = "randomForestSRC")
dta <- na.omit(breast)
rf  <- rfsrc(status ~ ., data = dta, ntree = 200)

# newdata must carry predictors only -- see Pitfalls
nd <- dta[1:20, setdiff(names(dta), "status"), drop = FALSE]
gs <- gg_shap(rf, newdata = nd, bg_n = 20)
dim(gs)
```
````

- [ ] **Step 3: Add the three renderer chunks**

Under `## Build it`:

```` markdown
```{r}
#| label: fig-rf_shap-importance
#| fig-cap: "Global SHAP importance for the breast classification forest, ranking predictors by mean absolute attribution across the explained observations"
shap_importance(gs) + theme_hv_manuscript()
```
````

Under `## Read it`:

```` markdown
```{r}
#| label: fig-rf_shap-beeswarm
#| fig-cap: "The per-observation attributions behind that ranking, one point per patient per variable, showing the spread a mean absolute value hides"
#| fig-height: 5.5
shap_beeswarm(gs) + theme_hv_manuscript()
```
````

Under `## Variations`, as `### One variable across its range`:

```` markdown
```{r}
#| label: fig-rf_shap-dependence
#| fig-cap: "SHAP dependence for mean_radius, plotting each patient's attribution against their own value of the predictor"
shap_dependence(gs, xvar = "mean_radius") + theme_hv_manuscript()
```
````

- [ ] **Step 4: Author the prose**

Invoke the `ehrlinger-writing` skill first. Content each section must carry:

- **When to use it** — the VIMP contrast, which is this chapter's reason to
  exist next to `rf_vimp.qmd`. **VIMP** asks how much worse the forest predicts
  when a variable is permuted: one number per variable, a statement about the
  model. **SHAP** asks how much a variable moved *this* observation's
  prediction: one number per variable per observation, a statement about the
  individual. VIMP for "what drives the model", SHAP for "why did this patient
  score the way they did."
- **The data it needs** — a regression or classification `rfsrc` fit. State
  plainly that survival is not supported, since the rest of the part uses `pbc`
  and a reader will reach for it.
- **Read it** — how to read a beeswarm: position is attribution, colour is the
  predictor's own value, so a band running low-value-left to high-value-right
  means the variable pushes the prediction monotonically.
- **Pitfalls** — the three below.

- [ ] **Step 5: Write the pitfalls**

Three, in this order:

1. **`newdata` must be predictors only.** Passing the fitted frame whole fails
   inside `kernelshap` with `all(colnames(X) %in% colnames(bg_X)) is not TRUE`,
   which names neither `newdata` nor the outcome. Show the
   `setdiff(names(dta), "status")` fix.
2. **Cost scales with `nrow(newdata)` × `bg_n`.** Quote the measured figures:
   on this 32-predictor fit, 20 observations against a 20-row background takes
   roughly 48 seconds, and 30 against 30 roughly 99. Explain the tradeoff —
   `bg_n` is the reference sample the attribution is measured against, so a
   larger one is more stable and costs linearly.
3. **Attribution is not causation.** A large SHAP value says the model leaned on
   the variable for that patient, not that the variable causes the outcome.

- [ ] **Step 6: Wire it into the book**

In `_quarto.yml`, insert `rf_shap.qmd` immediately after `rf_vimp.qmd`:

```yaml
    - part: randomforests.qmd
      chapters:
        - rf_error.qmd
        - rf_predicted.qmd
        - rf_vimp.qmd
        - rf_shap.qmd
        - rf_dependence.qmd
        - rf_roc.qmd
        - varpro.qmd
        - varpro_partial.qmd
```

- [ ] **Step 7: Render from a clean freeze**

```bash
rm -rf _freeze/rf_shap
quarto render rf_shap.qmd --to html
```

Expected: renders without error in roughly 1-2 minutes, producing three
figures. If it errors with `all(colnames(X) %in% colnames(bg_X))`, the outcome
column is still in `nd`.

- [ ] **Step 8: Commit**

```bash
git add rf_shap.qmd _quarto.yml
git commit -m "feat: add the SHAP attribution chapter

Covers gg_shap() and its three renderers, sited after rf_vimp.qmd so the
VIMP-versus-SHAP contrast lands while VIMP is fresh: VIMP is a statement
about the model, SHAP a statement about the individual.

Uses the breast classification fit because gg_shap() rejects survival
forests, which rules out the part's usual pbc.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 4: varPro coverage — `gg_sdependent`, `gg_beta_uvarpro`, `varpro_feature_names`

**Files:**
- Modify: `varpro.qmd` — insert after `:213`, after `:114`, and into `## Pitfalls`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: nothing later tasks depend on.

**Verified facts:** all three run today on ggRandomForests 3.5.0.
`gg_sdependent(uv)` and `gg_beta_uvarpro(uv)` both accept the `uvarpro` fit
`varpro.qmd:211` already builds — **no new forest is needed** — each returns a
12-row `data.frame` and plots as a plain `ggplot` taking
`+ theme_hv_manuscript()`. `varpro_feature_names(o$xvar.names, housing)`
returns 30 names against the data's 81 columns.

- [ ] **Step 1: Confirm the three are absent book-wide**

```bash
grep -rn "gg_sdependent\|gg_beta_uvarpro\|varpro_feature_names" . --include="*.qmd" --exclude-dir=_book --exclude-dir=_freeze
```

Expected: no output.

- [ ] **Step 2: Add `gg_sdependent()` after the `gg_udependent()` section**

Insert after `varpro.qmd:213` (the closing ``` of the `fig-varpro-udependent`
chunk) and before the explanatory paragraph at `:215`, as a new
`### Signed dependence` subsection. It reuses `uv` — do not refit.

```` markdown
```{r}
#| label: fig-varpro-sdependent
#| fig-cap: "Signed dependency graph for the same unsupervised housing fit, where the sign distinguishes variables that move together from those that move against each other"
#| fig-height: 5.5
plot(gg_sdependent(uv)) + theme_hv_manuscript()
```
````

Prose must say what `gg_sdependent()` adds over `gg_udependent()`: the
dependency carries a direction, so you can tell a pair that rises together from
a pair that trades off. Mention `threshold` (default 0.25) and `directed`
(default `TRUE`) as the two knobs worth knowing.

- [ ] **Step 3: Add `gg_beta_uvarpro()` under Beta-refined importance**

`varpro.qmd:102` heads "### Beta-refined importance (regression only)". Insert
after the closing paragraph at `:118`, before `### Individual variable
priority` at `:120`:

```` markdown
```{r}
#| label: fig-varpro-beta-uvarpro
#| fig-cap: "Beta-refined importance for the unsupervised housing fit, the outcome-free counterpart to the regression beta plot above"
#| fig-height: 6
plot(gg_beta_uvarpro(uv)) + theme_hv_manuscript()
```
````

**Ordering problem to solve:** `uv` is created at `:211`, *after* this insertion
point. Either move the `uvarpro()` fit earlier in the chapter, or give this
subsection its own fit. **Move the fit** — refitting the same forest twice in
one chapter is the worse of the two, and the fit is cheap relative to the lasso
refinement already in this section.

Move it to a new hidden chunk immediately after `## Variations` (`varpro.qmd:100`),
which is after `housing` and `o` are created at `:46-48` and before the beta
section at `:102`:

```` markdown
```{r}
#| label: uvarpro-fit
#| include: false
set.seed(42)
num_cols <- names(housing)[vapply(housing, is.numeric, logical(1))]
uv <- uvarpro(housing[, setdiff(num_cols, "SalePrice")], ntree = 100)
```
````

Then delete those three lines from the `fig-varpro-udependent` chunk at
`:209-211`, leaving only the `plot(gg_udependent(uv))` call. The prose at
`:215-219` explains the numeric-only subsetting and still reads correctly with
the fit moved, since it describes the fit rather than pointing at the chunk.

The existing heading at `:102` says "(regression only)", which becomes wrong
once an unsupervised path is shown. Retitle it `### Beta-refined importance`
and let the prose distinguish the two: `gg_beta_varpro()` needs a regression
`varpro` fit, `gg_beta_uvarpro()` takes a `uvarpro` fit and needs no outcome.

- [ ] **Step 4: Add the `varpro_feature_names()` pitfall**

This is a usability trap, not a figure, so it belongs in `## Pitfalls` (from
`varpro.qmd:221`) rather than getting a plot. Add a bullet showing:

```` markdown
```{r}
#| label: varpro-feature-names
length(o$xvar.names)          # what the fit exposes
ncol(housing)                 # what you handed it
head(varpro_feature_names(o$xvar.names, housing))
```
````

The bullet must explain that a `varpro` fit narrows its predictors twice, so
the variables you can ask for downstream are not the variables you passed in —
here 30 of 81 — and that asking for a dropped variable fails confusingly.
`varpro_feature_names()` is how you find out what is actually available.

- [ ] **Step 5: Render from a clean freeze**

```bash
rm -rf _freeze/varpro
quarto render varpro.qmd --to html
```

Expected: renders without error. The chapter fits several forests plus a lasso
refinement; allow several minutes. Confirm the two new figures appear and that
moving the `uvarpro()` fit earlier did not break `fig-varpro-udependent`.

- [ ] **Step 6: Verify coverage**

```bash
grep -c "gg_sdependent\|gg_beta_uvarpro\|varpro_feature_names" varpro.qmd
```

Expected: at least `3`.

- [ ] **Step 7: Commit**

```bash
git add varpro.qmd
git commit -m "docs: cover gg_sdependent, gg_beta_uvarpro, varpro_feature_names

All three were absent book-wide. gg_sdependent joins its gg_udependent
sibling, gg_beta_uvarpro joins the beta section (whose regression-only
heading was wrong once an unsupervised path exists), and
varpro_feature_names becomes a pitfall rather than a figure: a fit
narrows its predictors twice, exposing 30 of housing's 81 columns.

Both new plots reuse the existing uvarpro fit, moved earlier in the
chapter so the beta section can reach it.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 5: `data_tables.qmd` — describing the data you have

**Files:**
- Create: `data_tables.qmd`
- Modify: `_quarto.yml` (Tables part, first chapter)

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: nothing later tasks depend on.

**Blocking prerequisite:** installed `hvtiRutilities` is 1.0.1; `proc_contents()`
and `proc_means()` landed in 1.0.2. The chapter cannot render until the local
install is refreshed.

- [ ] **Step 1: Reinstall hvtiRutilities and verify the functions exist**

```bash
Rscript -e 'devtools::install("~/Documents/GitHub/hvtiRutilities", upgrade = "never")'
```

```bash
Rscript -e 'cat(as.character(packageVersion("hvtiRutilities")), "\n"); cat(all(c("proc_contents","proc_means") %in% getNamespaceExports("hvtiRutilities")), "\n")'
```

Expected: `1.0.2` and `TRUE`. Do not proceed until both hold.

- [ ] **Step 2: Create the chapter**

Create `data_tables.qmd`:

````markdown
# Describing a dataset

```{r}
#| label: setup
#| include: false
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)
library(hvtiRutilities)
library(gt)
```

## When to use it

## The data it needs

```{r}
#| label: dd-data
dta <- hvtiRutilities::generate_survival_data(n = 200, seed = 42)
dim(dta)
```

## Build it

### What is in this dataset — `proc_contents()`

```{r}
#| label: dd-contents
proc_contents(dta)
```

### What the numbers look like — `proc_means()`

```{r}
#| label: dd-means
proc_means(dta, vars = c("age", "bmi", "gfr_bs"))
```

### Stratified by a class variable

```{r}
#| label: dd-means-class
proc_means(dta, vars = c("age", "bmi"), class = "sex")
```

### The whole dictionary — `data_dictionary()`

```{r}
#| label: dd-dictionary
data_dictionary(dta)
```

## Read it

## Pitfalls
````

Uses the same `generate_survival_data()` cohort as `qt_tables.qmd`, so a reader
moving between the two chapters sees one dataset.

- [ ] **Step 3: Author the prose**

Invoke `ehrlinger-writing` first. Framing is **SAS parity**: the reader knows
`PROC CONTENTS` and `PROC MEANS` and wants the R move. Content:

- **When to use it** — this is the *pre-analysis* table, the one you run before
  deciding what Table 1 should even contain. It answers "what am I holding":
  which variables exist, what type each is, how much is missing.
- **Read it** — `proc_contents()` gives type, label, and missingness per
  variable; `proc_means()` the numeric summaries; `data_dictionary()` is built
  on both and is the one to hand a collaborator.
- **Pitfalls** — the two below.

- [ ] **Step 4: Write the pitfalls**

1. **`pct_missing` is `NaN` for zero-row input**, not `0`. A filtered-to-empty
   frame gives a table that looks broken but is reporting honestly — there is
   no denominator.
2. **`class=` groups are compared by value, not by rendered string.** Two levels
   that print identically but differ underneath stay separate groups. This is
   correct, and surprising if you are eyeballing printed output.

- [ ] **Step 5: Wire it in as the Tables part's first chapter**

```yaml
    - part: tables.qmd
      chapters:
        - data_tables.qmd
        - qt_tables.qmd
        - figure_tables.qmd
```

`hv_tables.qmd` is added in Task 7, not here — the book must render at every
commit, and that file does not exist yet.

- [ ] **Step 6: Render from a clean freeze**

```bash
rm -rf _freeze/data_tables
quarto render data_tables.qmd --to html
```

Expected: renders without error, producing four tables.

- [ ] **Step 7: Commit**

```bash
git add data_tables.qmd _quarto.yml
git commit -m "feat: add the dataset description chapter

Covers proc_contents(), proc_means() with class stratification, and
data_dictionary(), framed as the SAS-parity move for a reader who knows
PROC CONTENTS and PROC MEANS. Opens the Tables part, because this is the
table you run before deciding what Table 1 contains.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 6: Retire the stale hvtiRtables claims

**Files:**
- Modify: `tables.qmd:15-20`
- Modify: `qt_tables.qmd:16-20`
- Modify: `packages.qmd:36-38`

**Interfaces:**
- Consumes: `data_tables.qmd` exists (Task 5) — the part intro routes to it.
- Produces: nothing later tasks depend on.

**Three** files assert things that are no longer true, and all three assert them
by describing where `hvtiRtables` *is* rather than what it *does*. That framing
is the root cause; the replacements must not repeat it.

- [ ] **Step 1: Confirm all three stale claims are present**

```bash
grep -n "not yet written\|will migrate to\|is planned" tables.qmd qt_tables.qmd packages.qmd
```

Expected: three hits — `tables.qmd:15`, `qt_tables.qmd:18`, `packages.qmd:37`.
Note the third uses neither of the first two phrasings, which is how it went
unnoticed until the plan review.

- [ ] **Step 2: Rewrite the Tables part intro**

`tables.qmd:15-20` currently says a companion `hvtiRtables` package "is planned
but not yet written, so treat these recipes as the current standard rather than
the final one", then previews two chapters.

Replace with a route across all chapters in the part, saying what each is for:
`data_tables.qmd` describes the data you have; `qt_tables.qmd` builds a summary
by hand with `gt`; `figure_tables.qmd` pairs a table with the figure it belongs
to. (Task 7 adds the `hv_tables.qmd` sentence — leave it out until that chapter
exists, so the intro never promises a chapter the reader cannot reach.)

No lifecycle language. Say what the packages do.

- [ ] **Step 3: Reframe the by-hand chapter**

`qt_tables.qmd:16-20` says "once a dedicated table package matures, **these
tables will migrate to the planned hvtiRtables package** and the call sites will
collapse to a single helper."

The chapter stays — building a Table 1 by hand teaches what is in one, and `gt`
is right for an HTML deliverable not bound for a journal. Replace the migration
promise with a statement of what this chapter is *for*: hand-built `gt` when you
want to understand the table or publish it to the web. Task 7 adds the forward
pointer to `hv_tables.qmd`.

- [ ] **Step 4: Rewrite the `packages.qmd` gt entry**

`packages.qmd:36-38` reads:

```markdown
- **gt** [@R-gt]: publication-quality tables. We use it directly for now; a
  companion `hvtiRtables` package is planned to give tables the same house
  treatment the plots get.
```

Replace with two bullets — `gt` standing on its own merits rather than as a
stopgap, and `hvtiRtables` described by what it does:

```markdown
- **gt** [@R-gt]: publication-quality tables, and the right tool when the
  table's destination is this book or another HTML document.
- **hvtiRtables**: manuscript tables. It renders a `gtsummary` summary through
  `flextable` so the Word output carries a single unmerged header row, which is
  what the CORR table rules require and what `gt`'s Word export cannot produce.
```

Add `gtsummary` as a bullet too if Task 7's chapter calls it directly.

Note `packages.qmd:13` also loads `hvtiRutilities` in a setup chunk with the
comment "data dictionaries, labels, manifests" — that is still accurate after
Task 5 and needs no change.

- [ ] **Step 5: Verify the claims are gone**

```bash
grep -rn "not yet written\|will migrate to\|planned but not\|is planned\|directly for now" . --include="*.qmd" --exclude-dir=_book --exclude-dir=_freeze
```

Expected: no output.

- [ ] **Step 6: Render all three**

```bash
quarto render tables.qmd --to html && quarto render qt_tables.qmd --to html && quarto render packages.qmd --to html
```

Expected: all three render without error. None gained an executable chunk, so
no freeze clearing is needed.

- [ ] **Step 7: Commit**

```bash
git add tables.qmd qt_tables.qmd packages.qmd
git commit -m "docs: retire the stale hvtiRtables claims

Three places said hvtiRtables was unwritten, planned, or a future
migration target: the tables part intro, qt_tables, and the packages
list. All three described where the package was rather than what it
does, which is why they went stale together -- the replacements
describe behaviour only.

qt_tables stays as the by-hand chapter: building a Table 1 by hand
teaches what is in one, and gt is right for a web deliverable.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 7: `hv_tables.qmd` — the manuscript pipeline (BLOCKED)

> **Do not start this task until John has pushed the pending `hvtiRtables`
> release and confirmed the API is settled.** As of this plan, the local repo is
> at 0.9.1 with a clean tree, and a further release is in progress whose
> contents are not yet known. Tasks 1-6 ship as a PR without this one.

**Files:**
- Create: `hv_tables.qmd`
- Modify: `_quarto.yml` (Tables part, after `qt_tables.qmd`)
- Modify: `tables.qmd` (add the sentence deferred in Task 6)
- Modify: `qt_tables.qmd` (add the forward pointer deferred in Task 6)

**Interfaces:**
- Consumes: `tables.qmd` and `qt_tables.qmd` as rewritten in Task 6.
- Produces: nothing.

**Blocking prerequisite:** installed `hvtiRtables` is **0.1.0**, which predates
the `hv_*` rename entirely — none of the functions below exist in it.

- [ ] **Step 1: Reinstall hvtiRtables and confirm the API**

```bash
Rscript -e 'devtools::install("~/Documents/GitHub/hvtiRtables", upgrade = "never")'
```

```bash
Rscript -e 'cat(as.character(packageVersion("hvtiRtables")), "\n"); print(sort(getNamespaceExports("hvtiRtables")))'
```

Expected exports, unless the pending release changes them: `hv_tbl_summary`,
`hv_man_table`, `hv_man_table_jtcvs`, `hv_man_table_save`,
`hv_man_table_save_jtcvs`, `hv_man_footnotes`. **If the export list differs from
this, stop and re-read the spec's chapter section against the new API before
writing anything.**

- [ ] **Step 2: Create the chapter**

````markdown
# Manuscript tables

```{r}
#| label: setup
#| include: false
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)
library(hvtiRtables)
library(gtsummary)
```

## When to use it

## The data it needs

```{r}
#| label: hv-data
dta <- hvtiRutilities::generate_survival_data(n = 200, seed = 42)
```

## Build it

### Summarise — `hv_tbl_summary()`

```{r}
#| label: hv-summary
tbl <- hv_tbl_summary(
  dta,
  by     = "sex",
  groups = list("Demographics" = c("age", "bmi"),
                "Comorbidity"  = c("diabetes")),
  continuous  = c("age", "bmi"),
  categorical = c("diabetes")
)
tbl
```

### Render — `hv_man_table()`

```{r}
#| label: hv-flextable
ft <- hv_man_table(tbl)
ft
```

## Read it

## Variations

### JTCVS format

## Pitfalls
````

Confirm every argument above against the installed help pages before running —
`hv_tbl_summary()`'s `groups`, `continuous`, `binary`, and `categorical`
arguments are the `%summarytable` SAS-macro interface, and the pending release
may have adjusted them.

- [ ] **Step 3: Show the save step without writing into the repo**

`hv_man_table_save()` writes a `.docx`, which cannot render inline and must not
land in the repo. Use a non-evaluated chunk:

```` markdown
```{r}
#| label: hv-save
#| eval: false
hv_man_table_save(ft, file = "table1.docx")
```
````

- [ ] **Step 4: Author the prose**

Invoke `ehrlinger-writing` first. The chapter's spine is *why the package
exists*: `gt::gtsave()`'s Word export bakes `tbl_summary(by=)` grouping into
merged spanning header cells, which is exactly the unreachable-layer problem the
HVTI CORR "Table Construction for Manuscripts" rules prohibit. `hvtiRtables`
swaps the render engine to `flextable`, which emits a single unmerged header
row. Footnotes come from `hv_man_footnotes()` by default.

Cover both house formats and say which to reach for: `hv_man_table()` for CORR
reports, `hv_man_table_jtcvs()` for JTCVS submissions, which want merged
spanning headers and lettered footnotes.

**No version numbers, no roadmap language.** Describe behaviour.

- [ ] **Step 5: Close the two forward pointers deferred in Task 6**

In `tables.qmd`, add the sentence routing readers to `hv_tables.qmd` for
manuscript-bound tables.

In `qt_tables.qmd`, add the forward pointer: hand-built `gt` for understanding
and for the web, `hv_*()` when it goes to a manuscript.

- [ ] **Step 6: Wire it in**

```yaml
    - part: tables.qmd
      chapters:
        - data_tables.qmd
        - qt_tables.qmd
        - hv_tables.qmd
        - figure_tables.qmd
```

- [ ] **Step 7: Render from a clean freeze**

```bash
rm -rf _freeze/hv_tables
quarto render hv_tables.qmd --to html
```

Expected: renders without error. Confirm no `.docx` was written into the repo:

```bash
git status --short | grep -i docx
```

Expected: no output.

- [ ] **Step 8: Commit**

```bash
git add hv_tables.qmd tables.qmd qt_tables.qmd _quarto.yml
git commit -m "feat: add the manuscript tables chapter

Covers hv_tbl_summary -> hv_man_table -> hv_man_table_save and the JTCVS
variants. The spine is why the package exists: gt's Word export bakes
grouping into merged spanning cells, the unreachable-layer problem the
CORR table rules prohibit; hvtiRtables renders through flextable
instead.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 8: Full-book verification and PR

**Files:** none modified.

- [ ] **Step 1: Full render**

```bash
quarto render --to html
```

Expected: the whole book builds. This uses cached freezes for untouched
chapters, which is fine — every changed chapter was already rendered clean in
its own task.

- [ ] **Step 2: Run every definition-of-done check**

```bash
grep -rn "ggplot graphics recipes\|not yet written\|will migrate to\|is planned\|directly for now" . --include="*.qmd" --include="*.yml" --include="*.md" --exclude-dir=_book --exclude-dir=_freeze --exclude-dir=.quarto --exclude-dir=dev
```

Expected: no output. `dev/` is excluded because `dev/specs/` holds historical
plan files that legitimately quote the old title and the old claims; they are
record, not source, and are deliberately left alone. It was `docs/` when this
plan was written, before the portfolio settled on `dev/specs/`.

```bash
grep -rn "edition-" README.md
```

Expected: exactly one line, reading `edition-3.0.0`.

```bash
test "$(grep -c 'gg_partial_varpro(object' varpro_partial.qmd)" = "$(grep -c 'method = "rnd"' varpro_partial.qmd)" && echo MATCH || echo MISMATCH
```

Expected: `MATCH`.

```bash
gh repo view ehrlinger/hvti_graphics --json description
```

Expected: the new description, no "fo" typo.

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://ehrlinger.github.io/hvti_graphics/
```

Expected: `200`. A 404 means the repo was renamed, which this plan forbids.

- [ ] **Step 3: Open the PR — do not merge it**

```bash
git push -u origin feat/shap-and-tables-chapters
```

```bash
gh pr create --title "HVTI Recipes 3.0.0: SHAP, tables, and varPro coverage" --body "$(cat <<'EOF'
Renames the book to **HVTI Recipes** (edition 3.0.0) and closes three coverage gaps.

## Rename
The title said "ggplot graphics recipes" while the book already carried consort,
sankey, upset, and a gt tables part. The figures-only framing in the preface and
README lede moved with the title. The version string now lives in one place, the
README edition badge; it previously appeared twice with two different values.

Repo and published URL are unchanged — a slug rename would break the gh-pages
path for no reader benefit.

## New chapters
- `rf_shap.qmd` — SHAP attribution, sited after `rf_vimp.qmd` so the
  VIMP-versus-SHAP contrast lands while VIMP is fresh.
- `data_tables.qmd` — `proc_contents()`, `proc_means()`, `data_dictionary()`,
  framed as the SAS-parity move.

## Fixes
- Every `gg_partial_varpro()` call now passes `method = "rnd"`. Without it,
  `partialpro()`'s isolation forest defaults to unsupervised mode and hands
  `randomForestSRC` a zero-length pointer. Harmless in practice, but readers
  copy these chunks.
- `gg_sdependent()`, `gg_beta_uvarpro()`, and `varpro_feature_names()` were
  absent book-wide; all three now covered in `varpro.qmd`.
- Retired two stale claims that said hvtiRtables was unwritten.

## Still open
`hv_tables.qmd` (the hvtiRtables manuscript pipeline) is deliberately not in
this PR — it waits on the pending hvtiRtables release.

Spec: `dev/specs/2026-08-05-book-shap-and-tables-design.md`

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Stop here.** John merges his own PRs.
