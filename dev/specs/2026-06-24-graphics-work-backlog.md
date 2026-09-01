# Graphics Work Backlog — 2026-06-24

Captured during a brainstorm before moving to code. Consolidated handoff for the
coding session. Two repos: **hvtiPlotR** (package) and **hvti_graphics** (book).

> **Note on referenced artifacts.** Some companion docs live **outside this
> repo** and CI/other contributors cannot resolve their paths — they are listed
> for the author's local workflow only:
> - hvtiPlotR Sankey spec — `hvtiPlotR/dev/specs/2026-06-24-hv-sankey-canonical-design.md`
>   *within the hvtiPlotR repo*, but **untracked** (`docs/` is gitignored there).
> - Figure-conventions house rules — in the author's Obsidian vault
>   (out-of-repo); machine paths like `~/Documents/...` are illustrative, not
>   resolvable in CI.
>
> Everything in **this** repo is referenced by repo-relative path.

Branch in flight: `hvtiPlotR@feat/sankey-canonical` (spec only so far, no code).
Per house rule: open PRs, **John merges**.

---

## 1. hvtiPlotR — `hv_sankey` canonical cluster-stability fix

**Spec:** `hvtiPlotR/dev/specs/2026-06-24-hv-sankey-canonical-design.md`
**Gist:** same `ggsankey` engine; auto-derive a lineage-preserving node order
(plurality-parent per k→k+1, sibling-adjacent leaf order) — fixes ribbon
crossing **and** the `NA` nodes (root cause: `node_levels` defaults to the first
column's levels, dropping finer-k clusters to `NA`). Styling defaults: label
`alpha = 0.3`, flow `alpha = 0.5`; palette Set1 in label order. Optional
`group_labels` for milestone x-axis. Canonical reference:
AVSD `09-publication-figures.qmd` `pub-sankey-full` + `_common.R`
(`node_order_full = c("B","F","H","D","I","C","E","G","A")`).

## 2. hvtiPlotR — `hv_alluvial` clean y-axis  +  book Impella example

- **Package:** add `show_yaxis = TRUE` to `plot.hv_alluvial()`; when `FALSE`,
  blank `axis.{title,text,ticks,line}.y`. Same release as #1.
- **Book:** new milestone patient-flow alluvial reproducing the Impella 5.5
  "Fig. 2" (Admission → Placement → Removal → Discharge; NO MCS/MCS strata;
  NHS/HTx/LVAD/Other/Dead outcomes; counts on flows; `show_yaxis = FALSE`).
  Synthetic data (no source code exists). Timeline annotation bar = optional
  decorator-level. Likely a new section in `sankey.qmd`.

## 3. Figure conventions (house rules — vault `figure-conventions.md`)

Apply across book + packages; fold defaults into hvtiPlotR themes
(`legend.position` inside).

- **Legends:** >1 series ⇒ legend present, **inside** the panel, sized/placed to
  not occlude data/curves; name series plainly. **Apply: Ch. 9
  `temporal_hazard.qmd`** — label *observed vs expected* and *observed vs
  parametric* on the comparison curves (observed = empirical data; expected/
  parametric = fitted curve; verify per figure), in-panel legend when overlaid.
- **Annotations:** inside the panel, non-occluding. **Apply: Ch. 10
  `histograms.qmd`** — the `annotate("text", … y = Inf …)` group labels.

## 4. `hv_venn()` constructor (hvtiPlotR) + Ch. 14 `upset.qmd` example

**Decision: build a new `hv_venn()` in hvtiPlotR** (not a bare book example).
Rationale: the chapter is "Venn diagrams and UpSet plots" and `hv_upset()`
already exists as a house S3 constructor wrapping `ggupset` — the Venn half
should be symmetric.

- **Package:** thin `hv_venn(data, sets) |> plot()` S3 constructor wrapping
  **`ggvenn`** (returns a ggplot). Defaults: house categorical palette (same as
  hv_upset bars / cluster Sankey), counts not percentages, theme-able. Add
  `ggvenn` to **Suggests**. Keep it bounded to 2–3 sets (chapter says more →
  UpSet); do **not** reimplement Venn geometry. hvtiPlotR session.
- **Book:** Ch. 14 `## VENN diagrams` section is currently prose-only; add a
  rendered 2–3 set example calling `hv_venn()`. **Deferred** here — consumes the
  package function.

## 5. Book Ch. 13 `boxplots.qmd` — filled boxplots

Current examples use plain grey `geom_boxplot()`. Add a "prettier" example with
**fill by group** (`aes(fill = <group>)` + `scale_fill_brewer`/`scale_fill_manual`).
Exercises the legend rule from #3 (fill = group ⇒ in-panel legend).

## 6. Numbers-at-risk composite (curve + risk-table panel) — survival family

**Important advancement.** Add a curve-over-numbers-at-risk composite (the
classic KM risk table; same two-panel idiom as Ch. 12 `bar.qmd` /
`hv_longitudinal`) to book **Ch. 6 `survival.qmd`, Ch. 7 `hazard.qmd`, Ch. 9
`temporal_hazard.qmd`, and if possible Ch. 8 `nnt.qmd`**.

- **Data already exists:** `hv_survival()` returns `$tables$risk` (numbers at
  risk) and `$tables$report`. Missing piece is a *panel renderer* aligned to the
  curve's time axis.
- **Harness decision: build it in hvtiPlotR** (recurs in 4 chapters; x-axis
  alignment is fiddly → write once, test once). Add a risk-table panel, e.g.
  `plot(km, type = "risk")` returning a ggplot on the time axis; the book then
  composites `curve / risk_panel` with patchwork (Ch. 12 pattern). **hvtiPlotR
  session.** Book examples consume it → **deferred** here until it lands.

---

## 7. Book Ch. 15 `spaghetti.qmd` — LOESS-overlay legend

Spaghetti plots need **no legend** (one undifferentiated series of trajectories).
**Exception:** a spaghetti **+ LOESS overlay** is a comparison (individual paths
vs smoothed trend) and **needs a legend** naming both. Add/ensure such an
example; legend inside per #3. (Convention recorded in `figure-conventions.md`.)

## 8. Book Ch. 16 `postagestamp.qmd` — 9-panel (3×3) example

Current postage-stamp example uses ~3 panels, which doesn't convey the
small-multiples idea. Use **~9 panels in a 3×3 grid** so the concept lands.

## 9. Book Ch. 17 `specialty.qmd` — promote to a part divider

`specialty.qmd` is a **section header** (prose introducing CONSORT / Sankey /
balance / follow-up), but it's listed as a plain chapter and gets numbered (17).
Restructure `_quarto.yml`: make it a `part:` page over consort/sankey/balance/
combination so it stops being a numbered chapter. (Renumbers later chapters.)

### Correction, 2026-09-01: #6 is now closed for three of four, and hazard is done

The 2026-08-29 resolution below called `hazard.qmd` permanently blocked. That was
right on the evidence then and is wrong now. **`sample_hazard_cohort()` shipped in
hvtiPlotR v2.7.11** and returns the subject-level records
`sample_hazard_empirical()` computes its overlay from, which is exactly the
missing piece.

**Verified before use, because the whole objection was correspondence.** Refitting
a Kaplan-Meier to `sample_hazard_cohort(n = 500, time_max = 10)` reproduces
`sample_hazard_empirical(n = 500, time_max = 10, n_bins = 6)` at every one of its
six points to a difference of **0**. So the counts genuinely belong to the figure.
The same cohort sits up to **2.31 percentage points** from the smooth parametric
grid, which is the ordinary and correct relationship: a risk table counts
patients, the smooth curve is the model. `hazard.qmd` now carries the composite
and says this in its prose.

**`nnt.qmd` stays blocked, for a narrower reason than before.** A grouped cohort
can be drawn, but nothing in that figure comes from it: `sample_nnt_data()` plots
a parametric ARR/NNT curve with no empirical overlay, and a cohort drawn from the
same model does not reproduce it (at t = 20, cohort ARR 6.15pp against the
curve's 5.75). Counts under that curve would describe a cohort that did not
generate it, which is the thing this backlog entry refused to do in the first
place. It needs either an empirical overlay for the NNT curve or an
`hv_atrisk()` that accepts a grid plus a denominator.

**Standing: 3 of 4.** `survival.qmd`, `figure_tables.qmd`, `temporal_fit.qmd`, and
now `hazard.qmd`, which makes four sites across three of the four chapters #6
named plus the one that inherited Ch. 9's slot.

### Resolution of #6, 2026-08-29

**Done where the data allows; blocked in `hvtiPlotR` where it does not.** Three of
the four chapters #6 named now have it. `hv_atrisk()` and `hv_atrisk_compose()`
landed in `hvtiPlotR`, and the composite is in `survival.qmd`,
`figure_tables.qmd`, and `temporal_fit.qmd`, which inherited the Ch. 9 slot when
`temporal_hazard.qmd` was split four ways. The temporal one works because
`TemporalHazard`'s `cabgkul` is subject-level, 5,880 rows of `int_dead` and
`dead`, the same records `hzr_kaplan()` reads.

**Note the package boundary.** `hv_atrisk()`, `hv_hazard()` and `hv_nnt()` are all
`hvtiPlotR`. `TemporalHazard` supplies only the cohort and the estimators, so any
fix for the two blocked chapters belongs to `hvtiPlotR`.

`hazard.qmd` and `nnt.qmd` cannot have it as they stand, and the reason is a data
model rather than an oversight. A numbers-at-risk panel needs subject-level
`time`/`status`; `hv_atrisk()` says so itself when handed anything else ("This
object has no `$tables$risk`. Pass subject-level data with
`time`/`status`/`group`"). Both chapters run on pre-computed curves by design:
`sample_hazard_data()` returns a prediction grid and `sample_nnt_data()` an NNT
curve, neither carrying patient rows, and `hazard.qmd` states the premise in its
own prose, that all three of its constructors take pre-computed data.
`survival.qmd` can compose because `sample_survival_data()` is subject-level.

Bolting a separate synthetic cohort under those curves would put counts beneath a
curve they did not generate. That is a figure that lies, so it was not done.

**What would unblock it**, in `hvtiPlotR` rather than here: either a subject-level
hazard constructor whose object carries `$tables$risk`, or `hv_atrisk()` accepting
a grid plus a denominator. Until one exists, treat #6 as closed for the survival
family and out of scope for the pre-computed-curve chapters.

### Status (book session, branch `feat/book-chapter-improvements`)
- **DONE (6 commits):** #5 filled boxplots (Ch. 13, `4efcf76`); #3 annotations
  (Ch. 10, `b5a6057`); #3 Ch. 9 observed-vs-parametric overlay (`c6b322d`); #8
  Ch. 16 postage 3×3 (`91d8e06`); #7 Ch. 15 spaghetti+LOESS legend (`60f4b8d`);
  #9 Ch. 17 specialty → part divider (`8210e5c`).
- **Next book pass (this branch):** random-forest+ chapters review.
- **Deferred book examples — consume hvtiPlotR work:** #2 Impella alluvial
  (`show_yaxis`), #4 Ch. 14 Venn (`hv_venn()`), #6 numbers-at-risk composites
  (risk-table panel).
- **hvtiPlotR session:** #1 `hv_sankey`; #2 `hv_alluvial show_yaxis`; #4 new
  `hv_venn()` (wraps `ggvenn`); #6 risk-table panel; #3 theme defaults
  (`legend.position` inside) + book-wide "legends inside" sweep.
