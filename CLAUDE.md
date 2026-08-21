@AGENTS.md

# Claude Code specifics

[`AGENTS.md`](AGENTS.md), imported above, is the operational contract and applies in full. It is
written to be tool neutral so that Codex and other agents read the same rules. Only the Claude
Code affordances live here.

## Before you touch code

`AGENTS.md` says to orient before editing. In Claude Code the way to do that is the codemap —
it lives in the Obsidian vault under `Claude/repomaps/` and is read via the `read-codemap`
skill (`/codemap hvti_graphics`). If the codemap looks stale, say so and offer to refresh it
(`/regenerate-codemap`) rather than working from a guess.

If the vault is not available, say so rather than staying quiet about it, then orient from
`_quarto.yml`, whose `chapters:` tree is the book's table of contents and its structure.

## Not a package

`r-package-dev` and `r-package-style` do **not** apply here — both are scoped to the R
packages, and this repo is a Quarto book with no `DESCRIPTION`, `NAMESPACE` or tests. See
"This is not an R package" in `AGENTS.md` before reaching for `devtools::check()` or roxygen.

## Prose

Apply the `ehrlinger-writing` skill for chapter prose and captions. It carries the same voice,
reader persona and project context that `.claude/house-style.md` is composed from.
