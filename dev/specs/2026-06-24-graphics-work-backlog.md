# Graphics Work Backlog — 2026-06-24

Captured during a brainstorm before moving to code. Consolidated handoff for the
coding session. Two repos: **hvtiPlotR** (package) and **hvti_graphics** (book).

> **Note on referenced artifacts.** Some companion docs live **outside this
> repo** and CI/other contributors cannot resolve their paths — they are listed
> for the author's local workflow only:
> - hvtiPlotR Sankey spec — `docs/superpowers/specs/2026-06-24-hv-sankey-canonical-design.md`
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

**Spec:** `hvtiPlotR/docs/superpowers/specs/2026-06-24-hv-sankey-canonical-design.md`
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
