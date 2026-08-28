# Book Content Updates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add two new `ggRandomForests` varPro recipes to the book, migrate two chapters off superseded `hvtiPlotR` aliases, and normalize/strengthen the "When to use it" sections.

**Architecture:** Book-only edits to `varpro.qmd`, `hazard.qmd`, `nnt.qmd`, and a light audit across the 22 figure chapters. The book is Quarto with `freeze: auto`; every changed R chunk must execute at render. All new/changed code in this plan has been run and verified before writing.

**Tech Stack:** Quarto, R, ggplot2; `ggRandomForests` 3.3.0, `hvtiPlotR` 2.3.4, `varPro` ≥ 3.1.0, `igraph`. Branch: `feat/book-content-updates` (already created off `main`).

---

## Conventions used throughout this plan

**Branch:** all work is on `feat/book-content-updates` in `~/Documents/GitHub/hvti_graphics` (normal git; commit, do not push).

**Render check (the "test"):** to verify a single chapter executes, render just that file:
```bash
cd ~/Documents/GitHub/hvti_graphics && quarto render <chapter>.qmd --to html
```
Expected: completes with no error and writes `_freeze/<chapter>/…`. A chunk error fails the render loudly.

**Voice gate before each commit:** the `ehrlinger-writing` skill is wired into this repo (`.claude/CLAUDE.md`, default persona = HVTI/CORR biostatistician). Read new prose against `.claude/writing-voice.md` ("AI tells to hunt and kill") before committing.

**Verified facts this plan relies on (already tested):**
- `gg_partial_varpro(object = o)` accepts the regression `varpro` fit directly and `plot()` returns a **patchwork** — theme every panel with `& theme_hv_manuscript()` (not `+`).
- `gg_udependent(uv)` takes an unsupervised `uvarpro` fit; `plot()` returns a **ggraph** that takes `+ theme_hv_manuscript()`.
- The `hv_*` constructors take the same data/column args as the old direct-plot functions; the only dropped args are styling (`ci_alpha`, `line_width`, `point_size`, `point_shape`, `errorbar_width`), and **no call site in the book uses any of them**. So each migration is a pure wrap: `FN(ARGS) + decorators` → `plot(hv_FN(ARGS)) + decorators`.

---

## File Structure

| File | Change | Task |
|---|---|---|
| `varpro.qmd` | Add `### Partial dependence curves` (under Variations) | 1 |
| `varpro.qmd` | Add `## Unsupervised variable dependence` (before Pitfalls) | 2 |
| `hazard.qmd` | Wrap 5 `hazard_plot()` calls + 2 prose mentions → `hv_hazard()` | 3 |
| `nnt.qmd` | Wrap `nnt_plot`/`survival_difference_plot` calls + prose → `hv_*` | 4 |
| all 22 figure chapters | Audit "When to use it": normalize level, strengthen thin | 5 |
| (whole book) | Full render verification | 6 |

---

## Task 1: Add `gg_partial_varpro` recipe to `varpro.qmd`

**Files:**
- Modify: `varpro.qmd` (insert a new `###` subsection at the end of the `## Variations` section, i.e. immediately AFTER the "### Anomaly / isolation scores" block and its trailing paragraph, and BEFORE the `## Pitfalls` heading)

- [ ] **Step 1: Insert the recipe section**

Insert this block immediately before the `## Pitfalls` line:

````markdown
### Partial dependence curves

The extractors so far rank and refine variables; partial dependence asks a
different question — *how does the prediction move as one variable changes,
holding the rest as they are?* `gg_partial_varpro()` runs `varPro::partialpro()`
on the fitted forest and tidies the result into marginal-effect curves: one
panel per variable, the predicted response across that variable's range. On the
regression fit the y-axis is on the response scale (`mpg`).

```{r}
#| label: partial-varpro
plot(gg_partial_varpro(object = o)) & theme_hv_manuscript()
```

`plot()` returns a panel of curves (a `patchwork`), so we finish it with `&`
rather than `+` to apply the house theme to every panel. Each curve shows the
modelled effect of one predictor; a flat curve is a variable the forest barely
uses, a steep one a variable that moves the prediction. `gg_partialpro()` is the
superseded name for this extractor in older code — it is now a thin alias for
`gg_partial_varpro()`, so reach for the new name.
````

- [ ] **Step 2: Render-verify**

Run: `cd ~/Documents/GitHub/hvti_graphics && quarto render varpro.qmd --to html`
Expected: completes with no error; the `partial-varpro` chunk produces a multi-panel figure.

- [ ] **Step 3: Voice gate**

Read the new prose against `.claude/writing-voice.md`. Confirm: "you"/"we" present, no overstatement, the analogy/question opener fits the Narrative register, no forced tricolon.

- [ ] **Step 4: Commit**

```bash
cd ~/Documents/GitHub/hvti_graphics
git add varpro.qmd _freeze/varpro
git commit -m "feat(varpro): add gg_partial_varpro partial-dependence recipe"
```

---

## Task 2: Add `gg_udependent` section to `varpro.qmd`

**Files:**
- Modify: `varpro.qmd` (insert a new `##` section AFTER the `### Partial dependence curves` block from Task 1 and BEFORE `## Pitfalls`)

- [ ] **Step 1: Insert the section**

Insert this block immediately before the `## Pitfalls` line (after Task 1's block):

````markdown
## Unsupervised variable dependence

Everything above needs an outcome. `varPro::uvarpro()` drops that requirement:
it fits an *unsupervised* forest and scores how strongly each variable depends
on the others, with no response to predict. `gg_udependent()` reads those
cross-variable scores and draws them as a dependency graph — nodes are
variables, edges the dependencies between them — so you can see which predictors
travel together before any modelling. Reach for it when you want to understand
the structure among the predictors themselves, for example to spot a cluster of
collinear measurements.

```{r}
#| label: udependent-fit
set.seed(42)
uv <- uvarpro(iris[, -5], ntree = 100)
plot(gg_udependent(uv)) + theme_hv_manuscript()
```

We fit it on the four `iris` measurements with the species label dropped, since
the method takes no outcome. A thick edge between two variables means the forest
finds them strongly interdependent; an isolated node is a variable that carries
information the others do not.
````

- [ ] **Step 2: Render-verify**

Run: `cd ~/Documents/GitHub/hvti_graphics && quarto render varpro.qmd --to html`
Expected: completes with no error; the `udependent-fit` chunk produces a graph figure.

- [ ] **Step 3: Voice gate**

Read against `.claude/writing-voice.md` as in Task 1.

- [ ] **Step 4: Commit**

```bash
cd ~/Documents/GitHub/hvti_graphics
git add varpro.qmd _freeze/varpro
git commit -m "feat(varpro): add gg_udependent unsupervised-dependence section"
```

---

## Task 3: Migrate `hazard.qmd` off `hazard_plot()`

**Files:**
- Modify: `hazard.qmd` — 5 code call sites (chunk lines ~57, 103, 127, 157, 206) and 2 prose mentions (lines ~20, ~32)

**The transformation (mechanical wrap):** for every `hazard_plot(` call, wrap the constructor in `plot(hv_hazard(...))`. Concretely: change the opening `hazard_plot(` to `plot(hv_hazard(`, and add one extra closing `)` at the end of the argument list (the `)` that currently sits just before the trailing `+`). All arguments stay identical. The `+ scale_* / labs / theme_*` decorator chain after the call is unchanged.

- [ ] **Step 1: Worked example — the `hazard_survival` chunk**

BEFORE:
```r
hazard_plot(
  dat_hp,
  estimate_col  = "survival",
  lower_col     = "surv_lower",
  upper_col     = "surv_upper",
  empirical     = emp_hp,
  emp_lower_col = "lower",
  emp_upper_col = "upper"
) +
  scale_colour_manual(values = c("steelblue"), guide = "none") +
```

AFTER:
```r
plot(hv_hazard(
  dat_hp,
  estimate_col  = "survival",
  lower_col     = "surv_lower",
  upper_col     = "surv_upper",
  empirical     = emp_hp,
  emp_lower_col = "lower",
  emp_upper_col = "upper"
)) +
  scale_colour_manual(values = c("steelblue"), guide = "none") +
```

- [ ] **Step 2: Apply the same wrap to the other 4 call sites**

Apply the identical wrap to the chunks `hazard_rate` (~103), `hazard_cumhaz` (~127), `hazard_stratified` (~157), and `hazard_lifetable` (~206). In each: `hazard_plot(` → `plot(hv_hazard(`, and add the extra `)` before the trailing ` +`. Do not change any argument.

- [ ] **Step 3: Update the 2 prose mentions**

Line ~20: `Reach for `hazard_plot()` when you have a parametric prediction grid…` → replace `hazard_plot()` with `hv_hazard()`.
Line ~32: `` `hazard_plot()` takes a parametric prediction grid… `` → replace `hazard_plot()` with `hv_hazard()`. Keep the rest of each sentence as is (facts unchanged).

- [ ] **Step 4: Confirm no old calls remain**

Run: `grep -n "hazard_plot" hazard.qmd`
Expected: no output.

- [ ] **Step 5: Render-verify**

Run: `cd ~/Documents/GitHub/hvti_graphics && quarto render hazard.qmd --to html`
Expected: completes with no error; all five hazard figures render as before.

- [ ] **Step 6: Commit**

```bash
cd ~/Documents/GitHub/hvti_graphics
git add hazard.qmd _freeze/hazard
git commit -m "refactor(hazard): migrate hazard_plot() to hv_hazard() S3 constructor"
```

---

## Task 4: Migrate `nnt.qmd` off `nnt_plot()` and `survival_difference_plot()`

**Files:**
- Modify: `nnt.qmd` — `nnt_plot()` at chunk lines ~55 and ~96; `survival_difference_plot()` at ~136 and ~176; prose mention at ~113

Same mechanical wrap as Task 3.

- [ ] **Step 1: Wrap the two `nnt_plot()` calls**

For `nnt_plot(` at the `nnt_curve` chunk (~55) and the `nnt_arr` chunk (~96): change `nnt_plot(` → `plot(hv_nnt(`, and add the extra `)` before the trailing ` +`. Worked example (`nnt_curve`):

BEFORE:
```r
nnt_plot(
  nnt_dat,
  lower_col = "nnt_lower",
  upper_col = "nnt_upper"
) +
```
AFTER:
```r
plot(hv_nnt(
  nnt_dat,
  lower_col = "nnt_lower",
  upper_col = "nnt_upper"
)) +
```

- [ ] **Step 2: Wrap the two `survival_difference_plot()` calls**

For the `surv_diff_plot` chunk (~136), wrap exactly as above: `survival_difference_plot(` → `plot(hv_survival_difference(`, add the extra `)` before ` +`.

The `surv_diff_multi` chunk (~176) is a one-liner with the data inline:
BEFORE:
```r
survival_difference_plot(rbind(d1, d2, d3), group_col = "comparison") +
```
AFTER:
```r
plot(hv_survival_difference(rbind(d1, d2, d3), group_col = "comparison")) +
```

- [ ] **Step 3: Update the prose mention**

Line ~113: `` `survival_difference_plot()` plots the difference `S_2(t) - S_1(t)`… `` → replace `survival_difference_plot()` with `hv_survival_difference()`. Facts unchanged.

- [ ] **Step 4: Confirm no old calls remain**

Run: `grep -nE "nnt_plot|survival_difference_plot" nnt.qmd`
Expected: no output.

- [ ] **Step 5: Render-verify**

Run: `cd ~/Documents/GitHub/hvti_graphics && quarto render nnt.qmd --to html`
Expected: completes with no error; the NNT, ARR, survival-difference, and multi-comparison figures render as before.

- [ ] **Step 6: Commit**

```bash
cd ~/Documents/GitHub/hvti_graphics
git add nnt.qmd _freeze/nnt
git commit -m "refactor(nnt): migrate nnt_plot/survival_difference_plot to hv_* constructors"
```

---

## Task 5: Audit and normalize "When to use it" sections

**Files:**
- Modify: `sankey.qmd`, `balance.qmd` (heading level), plus any chapter found thin in Step 1
- Read-only first: all 22 figure chapters

- [ ] **Step 1: Inventory pass (produce the worklist, do not edit yet)**

Run: `cd ~/Documents/GitHub/hvti_graphics && grep -nE "^#+ +[Ww]hen to use" scatter.qmd survival.qmd hazard.qmd nnt.qmd temporal_hazard.qmd histograms.qmd density.qmd bar.qmd boxplots.qmd upset.qmd spaghetti.qmd postagestamp.qmd consort.qmd sankey.qmd balance.qmd combination.qmd randomforests.qmd rf_error.qmd rf_predicted.qmd rf_vimp.qmd rf_dependence.qmd rf_roc.qmd varpro.qmd`

For each chapter, read its "When to use it" section and classify it: **OK** (names the clinical/analytic question and when the plot is the right choice) or **THIN** (missing the question, missing the "when is this the wrong plot" counterpoint, or no reading cue). Record the THIN list. Known-strong (leave alone): `survival.qmd`, `varpro.qmd`.

- [ ] **Step 2: Normalize heading level**

In `sankey.qmd` and `balance.qmd`, change `### When to use it` to `## When to use it` — UNLESS the section is intentionally nested under a `##` parent in that chapter (check the surrounding heading structure). If nesting makes `##` wrong, leave it and note why in the commit message.

Run to confirm after editing:
`grep -nE "^#+ +When to use it" sankey.qmd balance.qmd`
Expected: both show `## When to use it` (or a documented exception).

- [ ] **Step 3: Strengthen the THIN sections only**

For each chapter on the THIN list from Step 1, add the missing element(s) — the clinical/analytic question it answers, and/or a one-line "reach for X instead when…" counterpoint — written for the biostatistician persona, in the Narrative register. Do NOT rewrite sections classified OK. Change no facts (function names, defaults, citations).

- [ ] **Step 4: Render-verify the touched chapters**

For each chapter you edited in Steps 2-3, run `quarto render <chapter>.qmd --to html` and confirm no error.

- [ ] **Step 5: Voice gate + commit**

Read every edited section against `.claude/writing-voice.md`. Then:
```bash
cd ~/Documents/GitHub/hvti_graphics
git add -A
git commit -m "docs(figures): normalize and strengthen When-to-use sections"
```

---

## Task 6: Full-book render verification

**Files:** none (verification only)

- [ ] **Step 1: Render the whole book**

Run: `cd ~/Documents/GitHub/hvti_graphics && quarto render`
Expected: the full book renders with no error. With `freeze: auto`, only changed chapters re-execute.

- [ ] **Step 2: Confirm the four content chapters are clean**

Run: `grep -nE "hazard_plot|nnt_plot|survival_difference_plot|gg_partialpro\(" hazard.qmd nnt.qmd varpro.qmd`
Expected: no output (no superseded calls; `gg_partialpro` appears only as the prose alias note, not as a call — the `\(` guards against matching the call form).

- [ ] **Step 3: Commit any freeze updates**

```bash
cd ~/Documents/GitHub/hvti_graphics
git add _freeze _book 2>/dev/null; git status --porcelain | head
git commit -m "build: refresh freeze after content updates" || echo "nothing to commit"
```

---

## Self-Review (completed by plan author)

- **Spec coverage:** WS1 new recipes → Tasks 1-2 (gg_partial_varpro + gg_udependent; gg_partialpro alias noted, no separate recipe — spec non-goal honored). WS2 audit → Task 5 (inventory → normalize sankey/balance → strengthen thin only). WS3 alias migration → Tasks 3-4 (hazard/nnt, equivalence via render + grep gates). Rendering risk → per-task render checks + Task 6 full render. All six spec success criteria map to a step.
- **Placeholder scan:** all code blocks are verified-working (run before writing). The THIN worklist in Task 5 is produced by the Step 1 inventory (real classification step), not deferred — this is data-gathering, not a placeholder.
- **Type/name consistency:** `o` (regression varpro fit) and `oc` (classification) match varpro.qmd; `&` vs `+` theme application is per the verified return types (patchwork vs ggraph vs ggplot); `hv_hazard`/`hv_nnt`/`hv_survival_difference` names match the migration targets throughout.
- **Open questions resolved:** udependent dataset = `iris[, -5]` (Task 2); branch = `feat/book-content-updates` off main (done).
