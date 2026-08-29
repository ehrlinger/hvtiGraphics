# HVTI Recipes reader alignment design

**Date:** 2026-08-28

**Status:** Approved in conversation

**Audience:** HVTI/CORR biostatisticians

## Goal

Align the entire *HVTI Recipes* book around the work a CORR biostatistician is
trying to complete. The revised book should take a reader from a clinical or
analytical question to runnable R code, a figure or table they can interpret,
and an output they can deliver. It should document the current `main` branches
of the HVTI R family, use John Ehrlinger's house voice, and make the replacement
of legacy SAS workflows explicit.

The book remains a Quarto book. It consumes the package family and does not
become an R package.

## Reader and voice

The single prose audience is the HVTI/CORR biostatistician described as persona
(a) in `.claude/house-style.md`. That reader knows R, ggplot2, survival analysis,
and CORR datasets. They want three things from a recipe: runnable code, a call on
which tool to use, and the meaning of the arguments shown in context.

Clinical researchers and surgeons are downstream figure consumers. They do not
need to read the recipe, so the exported figure or table must carry enough
context to stand on its own.

The generated `.claude/house-style.md` remains the voice authority and is not
edited as part of this work. Prose should:

- open from a familiar analytical or clinical question;
- sound like one colleague teaching another at a whiteboard;
- use `we` and `you` naturally;
- define unfamiliar terms inline;
- explain the statistical purpose before showing code;
- use an analogy only when it teaches;
- avoid marketing language, generic filler, and mechanical parallelism;
- avoid em dashes in drafted text; and
- distinguish description, prediction, association, and causation carefully.

Strong passages stay. The purpose is alignment, not rewriting for its own sake.

## Package baseline and boundary

The book targets the approved source revision for each sibling repository. That
is current clean `main` except for the reviewed hvtiPlotR repair required by the
book's at-risk workflow:

| Package | Version | Approved source | Role in the book |
|---|---:|---|---|
| `hvtiR` | 1.0.13 | `main` at `5227077` | install, update, diagnose, and inspect the family |
| `hvtiPlotR` | 2.7.11 | authorized repair at `a808123` (pending merge) | house figures, themes, composition, and export |
| `ggRandomForests` | 4.0.0 | `main` at `8e1b1f66` | forest, varPro, and Random Hazard Forest interpretation |
| `TemporalHazard` | 1.2.6 | `main` at `aeb663a` | time-to-event modeling, prediction, and diagnostics |
| `hvtiRtables` | 1.0.0 | `main` at `64dd174` | CORR and JTCVS manuscript tables and Word validation |

`randomForestRHF` 2.0.0 from CRAN is part of the render environment required by
ggRandomForests 4.0.0. The local `randomForestRHF` checkout is still 1.0.2 and
must not replace that installed dependency. Its modeling interface is taught
only to the extent needed to build an object for the ggRandomForests graphics
workflow.

`hvtiRtemplates` is out of scope. The revised book may include a short handoff
to the planned templates book, but it will not absorb template-management or
document-production recipes.

Completeness means every clinically meaningful workflow has a worked recipe.
It does not mean every low-level helper gets an artificial example. A final
coverage map routes each workflow-level public export to a recipe or to its
authoritative package documentation.

## SAS replacement policy

This is an R replacement, not a dual-language book.

- Every recipe teaches the R workflow as the complete maintained workflow.
- SAS appears only as a migration landmark, such as mapping a familiar macro to
  its R replacement.
- No recipe requires SAS code, SAS output, a SAS license, or a side-by-side SAS
  implementation.
- Numerical parity is claimed only where it has been verified, and the text
  names what was checked rather than implying general equivalence.
- TemporalHazard translation tools may move a legacy program into R, but the
  resulting R analysis becomes the maintained source.
- Text should say "R replacement for" where the package truly replaces the
  legacy workflow, not merely "alternative to SAS."

## Information architecture

The primary navigation follows the reader's question. Package names remain
visible, but they are secondary to the work being done.

### 1. Start a reproducible analysis

- What are you trying to show?
- Install the HVTI family.
- Check, update, and diagnose the installed family.
- Record package and source provenance.
- Work without PHI using synthetic or public examples.
- Use the constructor -> `plot()` -> `+` decoration pattern.

The installation lifecycle uses the current `ehrlinger/hvtiR` pattern:

```r
install.packages("pak")
pak::pak("ehrlinger/hvtiR")
hvtiR::install()

hvtiR::status()
hvtiR::update()
hvtiR::doctor()
```

The text explains that family members install from GitHub `main`, why a later
`update.packages()` can replace a newer GitHub build with an older CRAN release,
and why installation should run in a fresh R session. Direct sibling checkout
installation is a maintainer workflow, not part of the normal reader path.

### 2. Describe the cohort

- Inspect a dataset and its dictionary.
- Build descriptive and manuscript tables.
- Show distributions and counts.
- Show relationships and longitudinal observations.
- Describe patient flow and overlapping groups.
- Assess covariate balance and follow-up completeness.

### 3. Analyze time-to-event outcomes

- Choose between nonparametric and parametric views.
- Plot survival, cumulative hazard, and hazard rate with numbers at risk.
- Show absolute survival differences and number needed to treat.
- Fit and interpret TemporalHazard additive phase models.
- Predict survival, cumulative hazard, and instantaneous hazard.
- Assess calibration and goodness of fit.
- Perform selection and bootstrap assessment.
- Handle competing risks and supported censoring structures.
- Migrate a legacy `PROC HAZARD` workflow into maintained R code.

The current overloaded TemporalHazard chapter should split into a short,
ordered sequence. Each chapter remains independently runnable even when the
sequence shares a conceptual story.

### 4. Explain predictive models

- Check whether a forest has enough trees.
- Examine predicted response or survival.
- Separate global importance, local attribution, and dependence.
- Assess discrimination and prediction error.
- Use varPro for variable priority and partial dependence.
- Fit and inspect a Random Hazard Forest.
- Examine its hazard output, time-varying performance, importance, and tuning.

Existing forest chapters are retained where strong and updated against
ggRandomForests 4.0.0. The Random Hazard Forest sequence adds `gg_rhf()`,
`gg_auct()`, `gg_rhf_importance()`, and `gg_tune_rhf()` with the current
`randomForestRHF` interface.

### 5. Finish and deliver the result

- Apply manuscript, poster, and slide themes.
- Choose color and shape encodings.
- Add labels and annotations.
- Place or replace legends.
- Combine panels and pair figures with supporting tables.
- Export manuscript figures, Word tables, posters, and presentations.

The hvtiRtables path is explicit:

1. summarize with `hv_tbl_summary()`;
2. render the CORR or JTCVS form;
3. construct and validate footnotes;
4. save the table to Word; and
5. inspect the written document with `hv_check_docx()`.

Generic `gt` recipes remain appropriate for HTML and book-native tables.
Manuscript Word tables route through hvtiRtables.

### Coverage map

The appendix lists each workflow-level public export, package and baseline
version, the chapter that teaches it, and its role: constructor, plot method,
diagnostic, formatter, export helper, or migration helper. Low-level or
overlapping exports link to package documentation instead of receiving weak
recipes.

## Recipe contract

Every worked chapter follows one recognizable path:

1. **The question:** the clinical or analytical decision.
2. **When to use it:** how it differs from nearby choices.
3. **The data it needs:** columns, types, grouping, censoring, and missingness.
4. **Build it:** a complete, independently runnable example.
5. **Inspect it:** what the constructor or fitted object contains.
6. **Read it:** what the result says and what it does not establish.
7. **Adapt it:** the arguments a CORR biostatistician is likely to change.
8. **Deliver it:** the relevant manuscript, Word, PDF, poster, or slide path.
9. **Pitfalls:** failure modes, validation checks, and careful interpretation.

Not every chapter needs nine literal second-level headings. Short navigation or
formatting chapters may combine adjacent steps, while multi-workflow chapters
may repeat the path within each workflow. The reader should nevertheless find
every applicable element without guessing.

Across recipes:

- prefer a family constructor over hand-built ggplot code when one exists;
- preserve the constructor -> `plot()` -> `+` pattern;
- load only the packages the example uses;
- keep examples independent, seeded where simulation is involved, and free of
  PHI;
- make labels, captions, scales, and legends useful outside the book;
- cross-link shared setup, themes, and export guidance rather than repeating
  it; and
- keep useful pedagogical repetition when a stand-alone recipe needs it.

## Source and chapter changes

The `_quarto.yml` outline may be reordered, and chapters may be split, merged,
added, renamed, or retired when the reader path benefits. The current
51-chapter count is not a constraint.

The update should be surgical within each subject: retain correct examples and
working figures, then revise only what the new structure, API baseline, voice,
or recipe contract requires. Part introductions that only repeat their title
may merge into useful decision guides. Long chapters carrying several distinct
decisions may split.

Bibliography entries, cross-references, navigation links, captions, and figure
labels change with the chapters they support. `_book/`, the generated PDF, and
LaTeX remain untracked preview artifacts.

## Failure handling

Core recipes must execute. A package-main failure is not hidden with
`eval: false`, stale freeze output, or an altered example that dodges the
intended API.

When a valid workflow fails:

1. capture the smallest reproducible call and exact error;
2. verify the installed version and sibling `main` commit;
3. distinguish a book error from a package defect; and
4. stop for approval before changing a sibling package.

The book repository does not silently take ownership of package fixes.

## Verification and review

Work occurs on a `codex/` branch. Nothing publishes or pushes to `main` during
the update.

Before rendering:

1. verify that each sibling checkout is clean and on `main`;
2. install the agreed baseline and required dependencies;
3. confirm the installed versions;
4. audit examples against source APIs and package documentation; and
5. scan for superseded calls, SAS-as-current-workflow language, missing recipe
   elements, and uncovered workflow-level exports.

Because the full book and its package baseline are changing, the final render
is a forced rebuild from a clean worktree. Remove `_freeze`, `.quarto`, `_book`,
and the per-chapter `*_files` intermediates before rendering so Quarto cannot
repopulate stale output from a shadow cache. Review the deletion targets before
running the command; none should be tracked user work other than the deliberate
replacement of `_freeze`.

Verification then requires:

- `quarto render --to html` succeeds;
- the local macOS PDF build succeeds;
- every rendered chapter is inspected for figures, tables, labels, legends,
  navigation, cross-references, overflow, and interpretation;
- `sibling-versions.json` records the agreed baseline;
- `_freeze/` contains the newly rendered, live chapter output;
- the source and freeze diffs contain only intended changes; and
- `_book/`, the PDF, and LaTeX remain uncommitted.

The user receives a local HTML/PDF preview and a chapter-by-chapter change
summary. Publishing, pushing to `main`, and deployment remain out of scope. A
PR is opened only after the user reviews the preview and asks to proceed.

## Acceptance criteria

- Navigation begins with the reader's analytical question rather than the
  supplying package.
- Every clinically meaningful workflow in the five-package boundary has a
  worked recipe or an explicit, justified route in the coverage map.
- Every worked recipe meets the applicable recipe contract.
- SAS is consistently framed as the retired workflow being replaced by R.
- Prose follows `.claude/house-style.md` for the CORR biostatistician persona.
- All examples use synthetic or public data and contain no PHI.
- The book renders from a clean cache against the approved package baseline.
- The HTML and PDF outputs pass full visual review.
- The revised source, `_freeze/`, and provenance record are ready for user
  review without publishing the site.

## Non-goals

- Turning the book into an R package.
- Reproducing every low-level package helper as a worked recipe.
- Teaching SAS as a supported parallel workflow.
- Building the future hvtiRtemplates book.
- Modifying a sibling package without separate approval.
- Publishing or deploying before the user reviews the preview.
