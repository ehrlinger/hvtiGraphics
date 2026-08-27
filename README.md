# HVTI Recipes

[![Publish](https://github.com/ehrlinger/hvtiGraphics/actions/workflows/publish.yml/badge.svg)](https://github.com/ehrlinger/hvtiGraphics/actions/workflows/publish.yml)
[![Site](https://img.shields.io/badge/read-ehrlinger.github.io%2FhvtiGraphics-1f6feb)](https://ehrlinger.github.io/hvtiGraphics/)
[![Version](https://img.shields.io/badge/edition-3.0.0-blue)](https://github.com/ehrlinger/hvtiGraphics/releases)
[![License: CC BY 4.0](https://img.shields.io/badge/license-CC%20BY%204.0-lightgrey)](https://creativecommons.org/licenses/by/4.0/)

A working catalog of the figures and tables we build for CORR manuscripts and
presentations: Kaplan-Meier curves, propensity-balance plots, spaghetti plots,
CONSORT diagrams, random-forest visualizations, the Table 1 that opens the
paper. Each is paired with the code that produces it. The aim is the one we
hold for all of this team's tooling: start from a working recipe, not a blank
script.

**Read it here:** <https://ehrlinger.github.io/hvtiGraphics/>

This is the **3.0.0** edition, and the first under the new name. The old title
promised ggplot recipes. But the book already carried CONSORT diagrams,
Sankeys, upset plots, and a tables part by then, and the name had stopped
describing what was in it. Tables are a subject here, not an appendix to the
figures.

New in this edition is SHAP attribution for random forests. VIMP tells you how
much worse the forest predicts when a variable is permuted, one number per
variable, a statement about the model. SHAP tells you how much a variable moved
*this* observation's prediction. So you reach for VIMP when you want to know
what drives the model, and for SHAP when a reviewer asks why one patient scored
the way they did.

The Tables part now covers both ends of a table's life: `hvtiRutilities` for the
inventory you run before deciding what Table 1 should contain, and
`hvtiRtables` for Word output that meets the CORR manuscript rules. The varPro
chapters picked up the entry points they were missing — unsupervised dependence
and beta-refined unsupervised importance — and every `gg_partial_varpro()` call
now passes `method = "rnd"`, with the chapter's pitfalls explaining why you want
it in your own scripts too.

## Who it's for

The HVTI/CORR biostatistics team and anyone building publication figures on our
stack. It assumes you know R, `ggplot2`, and the clinical questions; it does not
assume you remember which constructor draws a stratified hazard plot or how to
overlay a population life table.

## Two ideas run through the book

- **A figure is built in two steps.** A constructor (`hv_survival()`,
  `gg_varpro()`, …) prepares and validates the data, then `plot()` hands you a
  bare ggplot you finish with the usual `+`. That two-step shape is the figure
  pattern, not a universal one, though the tables keep the same division of
  labour between preparing the data and rendering it. The recipes lean on it so
  styling stays in your hands.
- **Every example stands on its own.** Each chunk generates its own sample data,
  so you can copy it, run it, and see the result before you point it at your own
  analysis.

## The packages underneath

The recipes are built on the `hvti*` packages we maintain — chiefly
[hvtiPlotR](https://github.com/ehrlinger/hvtiPlotR) (themes and plot
constructors), with
[hvtiRutilities](https://github.com/ehrlinger/hvtiRutilities) for data
dictionaries, manifests, and the synthetic cohorts the examples run on, and
[hvtiRtables](https://github.com/ehrlinger/hvtiRtables) for the manuscript Word
tables. Alongside them,
[ggRandomForests](https://github.com/ehrlinger/ggRandomForests) covers forest and
varPro graphics and
[TemporalHazard](https://github.com/ehrlinger/temporal_hazard) the
additive-hazard models, with `ggplot2` underneath. Where a package gives you a
helper we use it; where it does not (a plain density or box plot), we fall back
to bare `ggplot2` and style it to match.

## Building it locally

The book is a [Quarto](https://quarto.org) book.

```bash
quarto render                          # full book (HTML + PDF)
quarto render --to html                # HTML only
quarto render survival.qmd --to html   # also the full book, see below
```

There is no single-chapter render. Naming a chapter rebuilds the whole book,
because a chapter `.qmd` is an input to the book project rather than a document
of its own. That third line is still the one to run while iterating, though:
`freeze: auto` re-executes only the chapters whose source changed, so the render
walks all of them and rewrites the cache for yours alone.

Rendering reuses Quarto's committed `_freeze/` cache, so a normal render does not
re-run R. When you change a chapter's code, re-render it locally and commit the
updated `_freeze/` so the change reaches the site.

## How the site is published

A push to `main` triggers [`.github/workflows/publish.yml`](.github/workflows/publish.yml),
which renders the HTML from the frozen results and deploys `_book/` to the
`gh-pages` branch. CI never runs R — the book depends on local-source packages it
cannot install — so the published figures are only as current as the committed
`_freeze/`. The PDF is built locally; CI does HTML only.

## License

The text and figures are released under
[Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/)
(CC BY 4.0); see [`LICENSE`](LICENSE). Copyright 2025, John Ehrlinger.
