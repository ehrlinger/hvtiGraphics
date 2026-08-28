# Book Content Updates — Design Spec

**Date:** 2026-06-24
**Author:** John Ehrlinger (with Claude)
**Status:** Draft for review
**Repo:** hvti_graphics (the recipes book)

## Problem

Three gaps have opened between the recipes book and the packages it documents:

1. **New `ggRandomForests` graphics are undocumented.** Version 3.3.0 exports
   varPro partial-dependence and unsupervised-dependence graphics the book does
   not cover.
2. **The "When to use it" sections are uneven.** All 22 figure chapters now have
   one, but heading levels differ and a few are thinner than the rest.
3. **Two chapters call superseded `hvtiPlotR` functions.** `hazard.qmd` and
   `nnt.qmd` use the v1-style direct-plot helpers, which hvtiPlotR marks
   **Superseded** in favor of the `hv_*` S3 constructors the rest of the book
   already uses.

This is sub-project A. The writing harness built in sub-project B
(`ehrlinger-writing`, default persona: HVTI/CORR biostatistician) drives all
prose written or edited here.

### Non-goals

- No new chapters. Both new recipes live inside `varpro.qmd`.
- No recipe for `gg_partialpro` — it is a deprecated thin alias for
  `gg_partial_varpro` in 3.3.0. We mention the alias once; we do not duplicate.
- No mass rewrite of the "When to use it" sections. The audit is surgical:
  normalize heading level, strengthen only the genuinely thin ones, leave good
  prose alone.
- No change to `hvtiPlotR` or `ggRandomForests` source. This is book-only.
- No version bump of the targeted package API beyond what is installed
  (ggRandomForests 3.3.0, hvtiPlotR 2.3.4, varPro ≥ 3.1.0).

## Architecture

Book-only edits across four chapter files, plus the audit pass. The book uses
Quarto with `freeze: auto`, so every new or changed R chunk must execute
cleanly at render and produce a figure.

| File | Change |
|---|---|
| `varpro.qmd` | Add two recipe sections (partial dependence; unsupervised dependence) |
| `hazard.qmd` | Migrate `hazard_plot()` → `hv_hazard()` + `plot()` |
| `nnt.qmd` | Migrate `nnt_plot()` → `hv_nnt()`; `survival_difference_plot()` → `hv_survival_difference()` |
| all 22 figure chapters | Audit "When to use it": normalize heading level, strengthen thin ones |

### Component responsibilities

The four edited chapters are independent — each renders on its own. The audit
touches many files but each edit is local to one chapter. No shared module, no
cross-file interface.

## Workstream 1 — New `ggRandomForests` recipes (in `varpro.qmd`)

The varpro chapter already builds a regression `varpro` fit (object `o`,
modelling `mpg` on `mtcars`) and a classification fit. The two new sections
reuse and extend that setup.

### 1a. `gg_partial_varpro` — partial dependence curves

- **Placement:** a new `### Partial dependence curves` subsection under the
  existing `## Variations` section.
- **What it shows:** `varPro::partialpro()` computes partial-dependence answers
  for a fitted `varpro` object; `gg_partial_varpro()` splits that result into
  tidy continuous and categorical data frames and renders the marginal-effect
  curves. On a regression fit the curves are on the response scale.
- **Data it needs:** the chapter's existing regression fit `o`, fed through
  `varPro::partialpro()`. Keep the grid small (few points, small `ntree`
  upstream) so render stays fast.
- **Deprecated alias note:** one sentence — `gg_partialpro()` is the superseded
  name for `gg_partial_varpro()` in 3.3.0; use the new name.

### 1b. `gg_udependent` — unsupervised variable dependence

- **Placement:** a new `## Unsupervised variable dependence` section, after
  `## Variations` and before `## Pitfalls`. It is its own section, not a
  variation, because it needs a different fit.
- **What it shows:** a variable-dependency graph from an *unsupervised*
  `varPro::uvarpro()` fit — how strongly each variable depends on the others,
  rendered as a graph via `igraph`.
- **Data it needs:** a new small `uvarpro()` fit (the function's own example
  uses `uvarpro(iris[, -5], ntree = 50)`; the chapter will use a dataset
  consistent with the rest of the chapter). This section carries its own short
  "what it needs" note because the fit differs from the supervised `o`.
- **Dependency note:** `gg_udependent()` pulls in `igraph` (already a
  ggRandomForests dependency). Confirm `igraph` is available at render.

## Workstream 2 — Audit "When to use it" sections

- **Inventory (already taken):** all 22 figure chapters have a "When to use it"
  section. `sankey.qmd` and `balance.qmd` use `### When to use it`; the other 20
  use `## When to use it`.
- **Normalize:** bring `sankey.qmd` and `balance.qmd` to `## When to use it` to
  match the rest, unless their chapter structure makes `##` wrong (in which case
  note why and leave).
- **Strengthen, do not rewrite:** read each section against the
  `ehrlinger-writing` voice + the biostatistician persona. Expand only sections
  that are genuinely thin (missing the clinical question, missing the "when is
  this the wrong plot" counterpoint, or missing a reading cue). Strong sections
  (e.g. `survival.qmd`, `varpro.qmd`) are left as-is.
- **No fact changes.** Versions, function names, citations, defaults untouched.

## Workstream 3 — Migrate superseded `hvtiPlotR` aliases

hvtiPlotR NEWS marks `hazard_plot()`, `survival_difference_plot()`, and
`nnt_plot()` **Superseded** by the `hv_*` S3 constructors. The migration is not
a rename: the `hv_*` functions build an object you then `plot()`, matching the
two-step idiom the rest of the book uses (`hv_survival()` etc.).

- **`hazard.qmd`:** `hazard_plot(...)` → `hv_hazard(...)` then `plot()`,
  finishing with the house theme. Preserve every existing argument and the
  rendered result.
- **`nnt.qmd`:** `nnt_plot(...)` → `hv_nnt(...)` + `plot()`;
  `survival_difference_plot(...)` → `hv_survival_difference(...)` + `plot()`.
- **Equivalence check:** the migrated figure must match the pre-migration figure
  (same data, same visual result). If an argument has no `hv_*` equivalent, stop
  and surface it rather than dropping it.

## Rendering / compute risk

- `freeze: auto` means touched chapters re-execute. The new varPro calls
  (`partialpro`, `uvarpro`) are the slowest additions; keep `ntree` and grid
  sizes small. Confirm a clean `quarto render varpro.qmd`, `hazard.qmd`, and
  `nnt.qmd` (and a full-book render before done).
- All required packages are installed (ggRandomForests 3.3.0, hvtiPlotR 2.3.4,
  varPro ≥ 3.1.0, igraph). No new install should be required; if one is, surface
  it.

## Verification / success criteria

1. `varpro.qmd` renders with two new figures (partial dependence; unsupervised
   dependence), each produced by live code, each finished with a house theme.
2. `gg_partialpro` is mentioned once as the deprecated alias and has no separate
   recipe.
3. `hazard.qmd` and `nnt.qmd` render using only `hv_*` constructors; no
   `hazard_plot`/`nnt_plot`/`survival_difference_plot` calls remain
   (`grep` returns nothing in those chapters).
4. Migrated figures match their pre-migration output.
5. Every figure chapter uses `## When to use it` (level normalized), and no
   factual content changed in the audit.
6. A full `quarto render` of the book completes without error.

## Open questions

- Which dataset `gg_udependent`'s `uvarpro()` fit should use — the chapter's
  existing data or a small illustrative set like `iris`. Decided in the plan.
- Exact list of "thin" When-to-use sections to strengthen — produced as the
  first step of the audit (an inventory pass), not guessed here.
- Branch: continue on `feat/writing-harness` (inherits B's `.claude/` harness
  wiring and persona default) or branch fresh off `main` after B merges. Decided
  at implementation handoff.

## Relationship to sub-project B

B (the writing harness) is complete. A uses it: prose written or edited here is
run through the `ehrlinger-writing` skill with the repo-default persona (a)
HVTI/CORR biostatistician.
