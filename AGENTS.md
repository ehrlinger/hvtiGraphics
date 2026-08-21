# hvti_graphics

The **HVTI Recipes** book — 51 Quarto chapters, ~8,000 lines, published to
`gh-pages`. It is the CORR group's reference for figures, tables and R recipes
for manuscripts.

This file is the operational contract and applies in full. It is tool neutral,
so Codex and any other agent read the same rules. Claude Code affordances live
in `CLAUDE.md`, which imports this file.

## This is not an R package, and must not become one

The book **consumes** the family; it does not produce it. Across 51 chapters
there are exactly three function definitions (`shape`, `docx_scan`, `decorate`,
all single-chapter helpers), while 41 chapters call into the sibling packages
and `library(hvtiPlotR)` alone appears 34 times.

So there is no `DESCRIPTION`, no `NAMESPACE`, no `man/`, and no `tests/`, and
adding them would produce a package with three exports and no callers. Do not
propose it. `devtools::check()`, `roxygen`, `testthat` and `lintr` have nothing
to act on here — if a habit reaches for them, that habit is in the wrong repo.

If a chapter helper ever earns reuse, it belongs in `hvtiRutilities`, not in a
new package carved out of the book.

## Definition of done

- `quarto render --to html` succeeds.
- If you changed an **executable chunk**, you re-rendered that chapter locally
  and committed its `_freeze/<chapter>/` in the same commit. Prose-only edits
  need no re-render.
- The rendered result was actually looked at. This repo's output is figures and
  tables; "it rendered" is not the same as "the figure is right".

There is no test suite to run. The freeze cache is this repo's correctness
surface, and the gate below is the only thing standing in for one.

## The automated gates

| workflow | fails on |
|---|---|
| `pr-check.yml` | changed chunks whose `_freeze/` was not updated, then `quarto render --to html` |
| `publish.yml` | the render on `main`, then deploys `_book/` to `gh-pages` |
| `house-style.yaml` | `.claude/house-style.md` drifting from the vault sources it was composed from |

**CI cannot run R.** The book depends on local-source packages a runner cannot
install, so every render in CI reads the committed `_freeze/` cache and never
executes a chunk. That single constraint explains most of what follows.

## The one thing that destroys work

**Stale `_freeze/` publishes a lie that nothing can detect.**

Change a chunk, skip the local re-render, and the site keeps serving the *old*
output beside the *new* code — indefinitely, with a green build, because CI
never re-executes anything. There is no failing test to catch it downstream;
the freeze cache is the published result.

`pr-check.yml` blocks the version of this it can see: chunk content changed in
a PR without a matching `_freeze/` update. It compares chunk bodies, not whole
files, so prose edits pass untouched.

**The version it cannot see is the dangerous one.** This book is a reverse
dependency of `hvtiPlotR`, `ggRandomForests`, `TemporalHazard`,
`hvtiRutilities` and `hvtiRtables`. When one of those changes an API, argument
default or returned object, nothing in this repo changes — so no gate fires,
and the published figures silently become output from a version of the package
that no longer exists. The only defence is re-rendering the whole book locally
after sibling releases and reading what changed. Do that deliberately; nothing
will remind you.

## Rules for this repo

- **Synthetic or public data only. No PHI, ever.** The book states this itself
  in `data_governance.qmd` and every chapter runs on generated cohorts, seeded
  for reproducibility. A recipe book is the realistic place for someone to
  paste a real extract to make an example look better — do not, and say so if
  asked to.
- **`_freeze/` is committed on purpose.** 474 files, 46 chapter caches, ~54 MB.
  `.gitignore` records the reason. It is the build input for CI, not clutter.
- **`_book/` is not committed** and is gitignored. Never add it.
- **HTML is built in CI; the PDF is built locally.** The `pdf` format needs a
  TeX stack the runner does not have, so `publish.yml` renders `--to html`
  only. `HVTI-Recipes.pdf` and `.tex` are gitignored deliverables.
- **Re-render a single chapter, not the book, while iterating** —
  `quarto render <chapter>.qmd` — then commit that chapter's `_freeze/`. A full
  render touches every cache and buries the real change in the diff.

## Gotchas

- **`publish.yml` still triggers on `feat/plot-recipes`, a branch that no
  longer exists on the remote.** It is dead config today, but the deploy step
  uses `force_orphan: true`, so if that branch name is ever reused a push to it
  would overwrite the entire published site from a feature branch. Remove the
  trigger rather than relying on the branch staying gone.
- **`_quarto.yml` declares `theme: [cosmo, brand]` but there is no
  `_brand.yml`.** Quarto tolerates this and the book renders correctly today —
  the last publish succeeded in 1m 16s. Adding a `_brand.yml` to "fix" the
  dangling reference would restyle all 51 chapters at once. Leave it unless
  restyling is the actual task.
- **`.gitignore`'s note names three local-source dependencies
  (`TemporalHazard`, `hvtiRutilities`, `ggsankey`); the real set is larger** —
  `hvtiPlotR` and `hvtiRtables` are also local-source and load in far more
  chapters. The list understates what a fresh machine needs to render.
- **Two `CLAUDE.md` files exist and disagree** — `./CLAUDE.md` and
  `.claude/CLAUDE.md`, both tracked, overlapping but not identical. Neither is
  generated; only `.claude/house-style.md` is. Treat this file as the contract
  and raise the duplication rather than editing both.
- **Every chapter has a `_freeze/` directory, including part-intro pages with
  no chunks at all.** A predicate of the form "does `_freeze/<ch>/` exist" does
  not tell you whether a chapter carries code. `pr-check.yml` used to work that
  way and flagged prose edits; do not reinstate it.

## Git and versioning

- **Never push to `main`.** Branch, then open a PR and let the maintainer merge.
- **`main` is protected by an active ruleset named `protect main`** — verified,
  not assumed. A rejected push comes from the server, not a local hook. Never
  force-push around it.
- **This repo has no version number.** With no `DESCRIPTION` there is nothing to
  bump and no `NEWS.md` to match. Do not invent a versioning scheme for it; the
  published site is the artifact and `git log` is the history.

## Change discipline

1. **Think before coding.** Do not assume, ask. If the request is ambiguous or
   a name, path or chapter is uncertain, surface the confusion rather than
   running with a guess.
2. **Simplicity first.** Write the minimum that solves the stated problem. For
   this book that means the plain, readable recipe a reader can copy, not the
   clever one.
3. **Surgical changes.** Touch only the chapters the task requires. Do not
   restyle or reorganise adjacent chapters, and do not re-render the whole book
   to fix one figure. Raise nearby problems separately.
4. **Goal-driven execution.** State what done looks like before starting. Here
   the criterion is a rendered chapter you have actually looked at, with its
   `_freeze/` committed — not a clean render log.

## Prose

Recipe chapters, captions and README text follow the house voice, composed into
`.claude/house-style.md` from the vault sources. In Claude Code apply the
`ehrlinger-writing` skill. The house-style registry classifies this repo as
`profile: book` — chapters teach a reader to do something, so they carry more
narrative scaffolding than package documentation does.
