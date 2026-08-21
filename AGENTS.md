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
- If you changed a chapter that contains **any executable chunk**, you
  re-rendered it locally and committed its `_freeze/<chapter>/` in the same
  commit. This includes prose-only edits: `_quarto.yml` sets `freeze: auto`,
  which keys on the source file changing rather than on the code changing, and
  the freeze stores the chapter's whole rendered markdown. Edit a sentence
  without re-rendering and CI fails with `Unable to locate an installed version
  of R` — verified 2026-08-21. Only chapters with no chunks at all are exempt.
- The rendered result was actually looked at. This repo's output is figures and
  tables; "it rendered" is not the same as "the figure is right".

There is no test suite to run. The freeze cache is this repo's correctness
surface, and the gate below is the only thing standing in for one.

## The automated gates

| workflow | fails on |
|---|---|
| `pr-check.yml` | a changed chapter that runs code whose `_freeze/` was not updated, then `quarto render --to html` |
| `publish.yml` | the render on `main`, then deploys `_book/` to `gh-pages` |
| `house-style.yaml` | `.claude/house-style.md` drifting from the vault sources it was composed from |
| `version-check.yml` | nothing — reports sibling version drift as a tracking issue, weekly |
| `deep-render.yml` | the render, when run manually with the freeze bypassed |

**CI does not run R.** Neither workflow sets up R, so every render in CI reads
the committed `_freeze/` cache and never executes a chunk. That single
constraint explains most of what follows.

Read that as a choice, not an impossibility. This file claimed until 2026-08-21
that a runner "cannot install" the dependencies, and that is false: every
package the book needs is on CRAN or in a **public** GitHub repo, and
`hvtiverse::hvtiverse_install()` fetches the family in one call. The freeze
stays anyway, for two reasons that outlive the correction. The published
figures should be the ones a person reviewed, not ones a runner recomputed
behind their back. And installing the compiled random-forest stack on every PR
would trade a 1m 16s render for minutes of build time to reproduce output that
is already committed.

## The one thing that destroys work

**Stale `_freeze/` publishes a lie that nothing can detect.**

Change a chunk, skip the local re-render, and the site keeps serving the *old*
output beside the *new* code — indefinitely, with a green build, because CI
never re-executes anything. There is no failing test to catch it downstream;
the freeze cache is the published result.

`pr-check.yml` blocks the version of this it can see: chunk content changed in
a PR without a matching `_freeze/` update. It compares chunk bodies, not whole
files — but that comparison only words the error now, it no longer decides it.
The gate fires on **any** source change to a chapter that contains a chunk,
prose included, because `freeze: auto` invalidates the cache on any change to
the `.qmd`. It was narrower than that until 2026-08-21, which meant a
prose-only PR passed the gate and then failed the render with a much vaguer
message. Chapters with no chunks at all are exempt and pass untouched.

**The version it cannot see is the dangerous one.** This book is a reverse
dependency of `hvtiPlotR`, `ggRandomForests`, `TemporalHazard`,
`hvtiRutilities` and `hvtiRtables`. When one of those changes an API, argument
default or returned object, nothing in this repo changes — so no gate fires,
and the published figures silently become output from a version of the package
that no longer exists.

**A plain re-render does not defend against this, and used to be prescribed
here as though it did.** `freeze: auto` re-executes a chapter only when that
chapter's *source* changes. After a sibling release nothing in this repo has
changed, so `quarto render` reuses every cache and reports success without
running a single line of R — verified 2026-08-21 by completing a full render
with R removed from `PATH`. It produces a green log and byte-identical output,
which reads as "checked, no drift" when nothing was checked. **Delete the cache
first** — `rm -rf _freeze && quarto render --to html` — or nothing executes.

What now covers it, in two pieces that do different jobs:

| | when | cost | catches |
|---|---|---|---|
| `version-check.yml` (A) | weekly, and on demand | none — no R, no render | that versions have **moved** |
| `deep-render.yml` (B) | `workflow_dispatch` only | installs the family, executes every chunk | that something has **broken** |

Job A compares `sibling-versions.json` — written by the render itself, see
"What this build used" in `packages.qmd` — against each sibling's `DESCRIPTION`
on `main`. On divergence it opens or updates one reused tracking issue and
**exits 0 regardless**. A red scheduled run on `main` would claim the book is
broken, which is not what it learned; it learned that a re-render is due.

Job A tells you when to press the button on job B. Neither replaces the other,
and **breakage remains undetected until a human runs job B**. Say that plainly
rather than treating the weekly green tick as assurance.

`hvtiverse::hvtiverse_status()` does the same comparison locally, against
installed versions rather than the recorded ones, and is the quicker check when
you are already at a prompt.

A caveat that will keep biting until it is closed: `sibling-versions.json`
records the versions installed at the moment the chapter carrying it last
executed. Chapter caches written at other times may have been built against
other versions. The record becomes exact for the whole book after one forced
full re-render (`rm -rf _freeze`), and approximate again as chapters are
re-rendered piecemeal. Divergence can also mean the last render ran against
unreleased local code — a sibling checkout on a feature branch — rather than
against `main`; rule that out before re-rendering.

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

- **Never add a branch to `publish.yml`'s `push:` trigger.** The deploy step
  uses `force_orphan: true`, which replaces the whole `gh-pages` history rather
  than adding to it — so any branch listed there can overwrite the entire
  published site with a partial book. It deploys from `main` only, plus
  `workflow_dispatch` for a manual run. A long-lived `feat/plot-recipes` entry
  sat here until 2026-08-21, outliving the branch itself; that is the shape of
  the mistake to avoid re-introducing.
- **`_brand.yml` exists now** (added 2026-08-21, `#3366FF`, taken from
  `hvtiPlotR::hv_theme_*`'s `accent` default), so `_quarto.yml`'s
  `theme: [cosmo, brand]` is no longer a dangling reference. This entry used to
  say the opposite and warn against adding one. A forced full re-render will
  pick it up across all 51 chapters; that is expected, not drift.
- **`.gitignore`'s note names three local-source dependencies
  (`TemporalHazard`, `hvtiRutilities`, `ggsankey`); the real set is larger** —
  `hvtiPlotR` and `hvtiRtables` are also local-source and load in far more
  chapters. The list understates what a fresh machine needs to render.
- **Prose configuration is generated; never hand-maintain a second copy.**
  `.claude/house-style.md` carries the reader-persona default and the voice
  rules, is composed from the vault sources, and is drift-checked by CI. A
  `.claude/CLAUDE.md` used to restate the persona by hand and was deleted on
  2026-08-21. That file's own closing paragraph recorded why: this repo carried
  hand-synced copies until 2026-08-06 and one had been stale for three weeks
  without anyone noticing. Read the generated artifact; do not mirror it.
- **A `_freeze/` directory does not tell you whether a chapter carries code.**
  Measured 2026-08-21: 51 chapters, 13 of them chunk-free, but 46 freeze
  directories — six chunk-free chapters (`formatting`, `publications`,
  `randomforests`, `specialty`, `summary`, `usingR`) keep leftover directories
  from when they had chunks. So a predicate of the form "does `_freeze/<ch>/`
  exist" over-fires on exactly the prose-only pages it should ignore.
  `pr-check.yml` worked that way once; it now reads the chapter's content for a
  chunk instead. Do not reinstate the directory test. The leftover directories
  are inert — a chunk-free chapter renders clean with a stale one or none.

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
`.claude/house-style.md` from the vault sources. Read that file — it is
self-contained and states the active reader persona for this repo. In Claude
Code, apply the `ehrlinger-writing` skill.

The registry classifies this repo as `profile: book`: chapters teach a reader
to do something, so they carry more narrative scaffolding than package
documentation, and they compose without the package structure rules that govern
README order, the roxygen contract and vignette roles.

`.claude/house-style.md` is **generated — do not edit it.** Edit the vault
sources and recompose:

```
git clone --branch house-style-v1 https://github.com/ehrlinger/house-style ../house-style
Rscript ../house-style/compose-house-style.R --repo hvti_graphics
```

Clone the `house-style-v1` **tag**, not the default branch — that is the ref CI
pins. Composing against a newer composer than CI validates with produces a clean
local result and a red build, which is the confusion the pin exists to prevent.
Add `--check` to report drift without rewriting the artifact; that is what CI
runs. Exit codes: 0 clean, 1 usage error or missing source, 2 drift.

The composer reads the canonical sources from `~/Documents/ObsidianVault/memory/`
when that exists and otherwise falls back to the mirror inside the composer repo,
which is what CI uses since a runner has no vault. Every run prints which
directory it read, so you can tell the two apart.
