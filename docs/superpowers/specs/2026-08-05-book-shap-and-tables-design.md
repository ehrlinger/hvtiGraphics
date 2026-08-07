# HVTI Recipes 3.0.0: SHAP and table chapters, and a rename

Date: 2026-08-05
Status: approved, ready for planning

## Problem

The book is called "HVTI ggplot graphics recipes" and is no longer that. It
already carries `consort.qmd`, `sankey.qmd`, `upset.qmd`, and a `gt` tables
part that are not ggplot recipes, and this change adds three more chapters that
widen the gap. Separately, two bodies of work have matured outside the book and
are not represented in it.

1. **SHAP.** `ggRandomForests` 3.5.0 exports `gg_shap()` and three render
   helpers (`shap_importance()`, `shap_beeswarm()`, `shap_dependence()`). The
   book's Random Forests part covers error, predicted, VIMP, dependence, ROC,
   and varPro, but has nothing on per-observation attribution.

2. **Tables.** `hvtiRtables` (0.9.1) provides the manuscript-compliant Word
   pipeline, and `hvtiRutilities` (1.0.2) added `proc_contents()` /
   `proc_means()` and rebuilt `data_dictionary()` on top of them. Neither
   appears in the book.

The book also carries **three** claims about `hvtiRtables` that are now false,
which makes this a correction as much as an addition:

- `tables.qmd:15` — "A companion `hvtiRtables` package ... is planned but not
  yet written."
- `qt_tables.qmd:18` — "once a dedicated table package matures, **these tables
  will migrate to the planned hvtiRtables package**."
- `packages.qmd:36-38` — "**gt**: publication-quality tables. We use it
  directly for now; a companion `hvtiRtables` package **is planned** to give
  tables the same house treatment the plots get."

All three describe where the package *is* rather than what it *does*, which is
precisely why all three went stale together.

## Scope

A rename to **HVTI Recipes**, edition **3.0.0**; three new chapters; rewrites
of the prose that frames the book as figures-only; and a varPro pass covering
one correctness fix and three uncovered entry points.

Out of scope: any change to `hvtiRtables`, `hvtiRutilities`, or
`ggRandomForests` themselves. This is book-side work only. **The repository
stays `hvti_graphics`** and the published URL stays
`https://ehrlinger.github.io/hvti_graphics/` — renaming the repo would move the
gh-pages path, breaking the README badges and any saved links, and GitHub's
repo redirect does not cover gh-pages. The title is what readers see; the slug
is plumbing.

## Rename

Only two lines in tracked source carry the old title, but the figure-centric
framing runs deeper and has to move with it.

| File | Change |
|---|---|
| `_quarto.yml:6` | `title:` → `"HVTI Recipes"` |
| `_quarto.yml:8` | `subtitle:` → descriptive text, e.g. "Figures, tables, and R recipes for CORR manuscripts". **Drop the version string.** |
| `README.md:1` | Heading → `# HVTI Recipes` |
| `README.md:5` | Edition badge → `edition-3.0.0` |
| `README.md:8–12` | Lede reframe: "a working catalog of the figures we draw" → figures *and* tables |
| `README.md:17–21` | Replace the 2.0.0 edition paragraph with 3.0.0 notes |
| `index.qmd:17–19` | "a figure is built in two steps" — the constructor/`plot()` framing is figure-only; generalise or scope it explicitly to figures |
| `index.qmd:24–31` | Parts tour: tables are currently an afterthought ("the last parts handle tables and getting a finished figure out the door"). Give the Tables part its own standing. |
| `HVTI-ggplot-graphics-recipes.tex` | **Delete.** Untracked 458 KB `keep-tex: true` leftover from May; regenerates under the new name. |

The version string lives in **one** place after this: the README edition badge.
It currently appears twice with two different values (`_quarto.yml:8` says
"Version 2.1", `README.md:5` says `edition-2.0.0`), which is how they drifted
apart in the first place.

## Chapter structure

```yaml
    - part: randomforests.qmd
      chapters:
        - rf_error.qmd
        - rf_predicted.qmd
        - rf_vimp.qmd
        - rf_shap.qmd        # NEW
        - rf_dependence.qmd
        - rf_roc.qmd
        - varpro.qmd
        - varpro_partial.qmd
    - part: tables.qmd
      chapters:
        - data_tables.qmd    # NEW  — describe the data you have
        - qt_tables.qmd      #        summarise it (gt, by hand)
        - hv_tables.qmd      # NEW  — ship it to a journal
        - figure_tables.qmd  #        pair it with a figure
```

`rf_shap.qmd` sits directly after `rf_vimp.qmd` so the VIMP-vs-SHAP contrast
lands while VIMP is still fresh in the reader's mind.

The Tables part reads as a progression: know your data, summarise it, make it
compliant, attach it to a figure.

## Chapter specifications

Every chapter follows the part's established shape, as set by `rf_vimp.qmd` and
`varpro.qmd`: `# Title`, a hidden `setup` chunk, `## When to use it`,
`## The data it needs`, `## Build it`, `## Read it`, `## Variations`,
`## Pitfalls`. Prose follows the `ehrlinger-writing` harness, reader persona
(a) HVTI/CORR biostatistician.

### `rf_shap.qmd`

**Verified against real fits on 2026-08-05; three constraints the chapter must
respect.**

1. **`gg_shap()` rejects survival forests.** It errors with "only regression and
   classification forests are supported in this version; got family 'surv'."
   `pbc` — the dataset `rf_vimp.qmd` and most of the part use — is therefore
   unusable here. The chapter uses the `breast` classification fit instead,
   which `varpro.qmd` already establishes.
2. **`newdata` must contain predictors only.** Leaving the outcome column in
   fails inside `kernelshap` with `all(colnames(X) %in% colnames(bg_X)) is not
   TRUE` — a stack trace through `prepare_bg()` that names neither the outcome
   nor `newdata`. This is the chapter's most valuable pitfall.
3. **It is slow.** Measured on `breast` (32 predictors, `ntree = 200`):
   30 obs / `bg_n = 30` took 99 s, 20/20 took 48 s, 15/15 took 28 s. The
   chapter uses **20 / 20**, cached by `freeze` after the first render.

`gg_shap()` returns a long `data.frame` — `id`, `vars`, `shap`, `value`,
`value_label`, one row per observation × variable. All three renderers return a
plain `ggplot`, so they take `+ theme_hv_manuscript()`, not patchwork's `&`.

Builds an `rfsrc` fit, calls `gg_shap(object, newdata, bg_n = )`, then shows
the three renderers:

- `shap_importance()` — global ranking, mean absolute SHAP per variable.
- `shap_beeswarm()` — the per-observation distribution behind that ranking.
- `shap_dependence(xvar = ...)` — one variable's effect across its range.

The chapter must earn its place next to `rf_vimp.qmd`. Its substance is the
contrast:

- **VIMP** asks how much worse the forest predicts when a variable is permuted.
  One number per variable. A statement about the model.
- **SHAP** asks how much a variable moved *this* observation's prediction. One
  number per variable per observation. A statement about the individual.

Guidance: VIMP for "what drives the model," SHAP for "why did this patient
score the way they did."

Pitfalls:

- `kernelshap` cost scales with `nrow(newdata)` and with `bg_n`; explain the
  background-sample tradeoff rather than leaving the defaults unexplained.
- Attribution is not causation. A large SHAP value says the model used the
  variable, not that the variable causes the outcome.
- Classification forests need `which.class`; the default of 1 is not always the
  class of interest.

### `data_tables.qmd`

The pre-analysis table — what you run before deciding what Table 1 should
contain.

- `proc_contents(data, order = )` — variable inventory: type, label, missingness.
- `proc_means(data, vars = , class = )` — numeric summaries, optionally
  stratified.
- `data_dictionary(data)` — now built on both.

Framing is SAS parity: the reader knows `PROC CONTENTS` and `PROC MEANS` and
wants the R equivalent. Data source is
`hvtiRutilities::generate_survival_data()`, consistent with `qt_tables.qmd`.

Pitfalls: `pct_missing` is `NaN` for zero-row input; `class=` group membership
is compared by value, not by rendered string.

### `hv_tables.qmd`

The manuscript pipeline:

```
hv_tbl_summary(data, by =, groups =, continuous =, binary =, categorical =)
  -> hv_man_table()            -> hv_man_table_save()
  -> hv_man_table_jtcvs()      -> hv_man_table_save_jtcvs()
```

The chapter's spine is why the package exists: `gt::gtsave()`'s Word export
bakes `tbl_summary(by=)` grouping into merged spanning header cells, which is
exactly the unreachable-layer problem the HVTI CORR "Table Construction for
Manuscripts" rules prohibit. `hvtiRtables` swaps the render engine to
`flextable`, which emits a single unmerged header row. Footnotes come from
`hv_man_footnotes()` by default.

Two house formats exist because CORR reports and JTCVS submissions want
different shapes; the chapter says which to reach for and why, rather than
documenting one and mentioning the other.

Word `.docx` output cannot render inline in the book. The chapter shows the
code and the on-screen `flextable`, and describes the file written.

**Write about what the functions do, not where the package is in its
lifecycle.** No version numbers, no roadmap language, no "planned" or "not yet"
claims. That framing is what made the existing two notes go stale, and
`hvtiRtables` is still moving.

### varPro pass: `varpro.qmd` and `varpro_partial.qmd`

Both existing chapters are edited in place. **No new chapter** — each item
below belongs next to material already there, and relocating it would only
split the varPro story across three files.

#### Correctness: `method = "rnd"` on every `gg_partial_varpro(object = )`

`ggRandomForests` 3.5.1 is a test-and-docs-only release fixing a `gcc-UBSAN`
additional issue CRAN raised against 3.5.0. It introduces **no new varPro
features**. What it does carry is an instruction the book is on the wrong side
of: any `gg_partial_varpro(object = )` call reaches `varPro::partialpro()`,
which grows its own isolation forest and lets `isopro()` default to
`method = "unsupv"`, handing `randomForestSRC` a zero-length `yvar.wt` pointer
(`entry.c:184`). 3.5.1 corrected its own `?gg_partial_varpro` `\donttest`
example to pass `method = "rnd"`.

The book has five call sites, none passing it:

| Site | Call |
|---|---|
| `varpro_partial.qmd:64` | `gg_partial_varpro(object = o_reg, nvars = 6)` |
| `varpro_partial.qmd:79` | `... o_cls, scale = "prob"` |
| `varpro_partial.qmd:91` | `... o_cls, scale = "logodds"` |
| `varpro_partial.qmd:108` | `... o_surv, scale = "surv"` |
| `varpro_partial.qmd:120` | `... o_surv, scale = "rmst"` |

Add `method = "rnd"` to each, and a short note in that chapter's `## Pitfalls`
saying why. The behaviour is benign — the pointer is formed, never
dereferenced, and the real fix belongs upstream (`kogalur/randomForestSRC`
PR #478) — but the book teaches the pattern and readers copy chunks verbatim.
That is the reason to fix it: not that the book breaks, but that it propagates.

**No version dependency.** `gg_partial_varpro()` already takes `...` and passes
it to `partialpro()` in the installed 3.5.0, so this lands today and does not
wait on 3.5.1 being released. (3.5.1 is unreleased as of this spec — tags stop
at `v3.5.0`.)

#### Coverage: three entry points absent book-wide

`gg_sdependent()`, `gg_beta_uvarpro()`, and `varpro_feature_names()` appear in
no `.qmd` in the book. Each gets added to `varpro.qmd` beside its existing
sibling:

- **`gg_sdependent()`** — next to the existing "Unsupervised variable
  dependence" section, which already covers `gg_udependent()`. Covering one
  dependency graph and not the other is the least defensible of the three gaps.
- **`gg_beta_uvarpro()`** — a subsection under "Beta-refined importance". That
  section currently says `gg_beta_varpro()` is regression-only without noting
  that an unsupervised path exists.
- **`varpro_feature_names()`** — this one is a usability trap, not a missing
  figure, so it earns a `## Pitfalls` entry rather than a plot. A `varpro` fit
  narrows its predictors twice, so the variables you can ask for are not the
  variables you passed in; a reader who asks for a dropped variable hits a
  confusing failure with no guidance. `ggRandomForests` 3.5.0 added vignette
  coverage for exactly this.

### Rewrite: `tables.qmd` (part intro)

Remove the "planned but not yet written" claim. Route the reader across all
four chapters and say what each is for.

### Rewrite: `packages.qmd` gt entry

`packages.qmd:36-38` still frames `gt` as a stopgap ("We use it directly for
now") against a planned package. Give `hvtiRtables` its own bullet describing
what it does — manuscript-compliant Word output through `flextable` — and let
the `gt` bullet stand on its own merits rather than as a placeholder. Add
`gtsummary` if the new chapters use it directly.

### Rewrite: `qt_tables.qmd` framing

Keep the chapter. Building a Table 1 by hand teaches what is in one, and `gt`
remains the right tool for an HTML deliverable not bound for a journal. Replace
the migration promise at `qt_tables.qmd:18` with a forward pointer: hand-built
`gt` for understanding and for the web, `hv_*()` when it goes to a manuscript.

## Sequencing

`hv_tables.qmd` is written **last**, after the pending `hvtiRtables` release is
pushed, because that version's API surface is not yet settled. The other work
is independent of it:

1. Rename and edition bump (title, README, preface, delete stale `.tex`)
2. varPro `method = "rnd"` fix — five call sites, independent of everything else
3. `rf_shap.qmd`
4. varPro coverage pass (`gg_sdependent`, `gg_beta_uvarpro`,
   `varpro_feature_names`)
5. `data_tables.qmd`
6. `tables.qmd` and `qt_tables.qmd` rewrites, `_quarto.yml` wiring
7. `hv_tables.qmd` — blocked on the hvtiRtables push

Steps 1–6 can land as a PR without step 7. The rename goes first so the new
chapters are written into a book that already knows what it is. Step 2 is
sequenced early because it is a one-argument correctness fix with no
dependencies, and it should not be held hostage to the chapter work.

Steps 3 and 4 both touch the Random Forests part, and steps 5–7 the Tables
part; they do not conflict.

## Build prerequisites

Installed versions are behind the APIs these chapters use. Both must be
reinstalled from source before the chapters will render:

| Package | Installed | Repo | Needed for |
|---|---|---|---|
| hvtiRtables | 0.1.0 | 0.9.1+ | `hv_*()` — installed build predates the rename |
| hvtiRutilities | 1.0.1 | 1.0.2 | `proc_contents()`, `proc_means()` |
| ggRandomForests | 3.5.0 | — | `gg_shap()` — present, no action |
| kernelshap | 0.9.1 | — | present, no action |

If `packages.qmd` enumerates book dependencies, add `hvtiRtables` there.

## Definition of done

- The three new chapters render from a **clean freeze**, not from cache:
  delete each new chapter's directory under `_freeze/` and render that chapter
  on its own (`quarto render rf_shap.qmd`), confirming the R code actually
  executes. `execute: freeze: auto` will serve a cached success for untouched
  chapters, so a green full-book build is not evidence that a new chapter works.
- No occurrence of the stale claims remains. Grep the book source for
  `not yet written`, `will migrate to`, `is planned`, and `for now` — the third
  claim (`packages.qmd`) uses none of the first two phrasings, which is how it
  was missed on the first pass.
- No occurrence of the old title remains: grep tracked source for "ggplot
  graphics recipes". The version string appears exactly once, in the README
  edition badge, reading `3.0.0`.
- The preface and README describe a book about figures *and* tables. A reader
  who lands on `index.qmd` should not conclude tables are an appendix.
- Every `gg_partial_varpro(object = )` call in the book passes
  `method = "rnd"`. Verify by grep, not by eye: the count of
  `gg_partial_varpro(object` occurrences equals the count of `method = "rnd"`
  occurrences in `varpro_partial.qmd`.
- `gg_sdependent`, `gg_beta_uvarpro`, and `varpro_feature_names` each appear at
  least once in `varpro.qmd`. `varpro.qmd` re-renders from a cleared freeze —
  it gains executable chunks, so a cached pass proves nothing.
- Every new chapter has all three of `## When to use it`, `## Build it`,
  `## Pitfalls`.
- The book builds to HTML. PDF is not a gate — `cairo_pdf` is unavailable on
  this machine, and book CI is HTML-only.

## Risks

- **Stale freeze masking a broken chapter.** Mitigated by requiring a clean
  render of the new chapters specifically.
- **`hvtiRtables` moves again after `hv_tables.qmd` is written.** Mitigated by
  the no-lifecycle-language rule: document behaviour, not package state.
- **SHAP compute time inflating book build.** `gg_shap()` goes through
  `kernelshap`. Keep `newdata` and `bg_n` small enough that the chapter renders
  quickly, and say in the text that production use wants larger values.
- **varPro coverage additions inflating `varpro.qmd` render time.** The chapter
  already fits four forests. `gg_sdependent()` and `gg_beta_uvarpro()` need a
  `uvarpro` fit; reuse the one the existing `gg_udependent()` section builds
  rather than growing another.
- ~~`gg_sdependent()` and `gg_beta_uvarpro()` data requirements unverified.~~
  **Resolved 2026-08-05.** Both run on the `uvarpro` fit `varpro.qmd:211`
  already builds, return 12-row `data.frame`s, and plot as plain `ggplot`
  objects taking `+ theme_hv_manuscript()`. No extra fit needed.
  `varpro_feature_names(o$xvar.names, housing)` also confirmed: the `housing`
  regression fit exposes **30** of the data's **81** columns, which is the
  concrete number the pitfall should quote.
