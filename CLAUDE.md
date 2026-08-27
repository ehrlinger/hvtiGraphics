@AGENTS.md

# Claude Code specifics

[`AGENTS.md`](AGENTS.md), imported above, is the operational contract and applies in full. It is
written to be tool neutral so that Codex and other agents read the same rules. Only the Claude
Code affordances live here.

## Before you touch code

`AGENTS.md` says to orient before editing. In Claude Code the way to do that is the codemap —
it lives in the Obsidian vault under `Claude/repomaps/` and is read via the `read-codemap`
skill (`/codemap hvtiGraphics`). If the codemap looks stale, say so and offer to refresh it
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

**The active reader persona is declared in `.claude/house-style.md`**, in its frontmatter and
again in the body — not in this file. There was a hand-written `.claude/CLAUDE.md` restating
it until 2026-08-21; it was deleted because the composed artifact is authoritative and CI
checks it for drift. If a skill or agent looks for the persona default in a `CLAUDE.md`, that
guidance is stale — send it to the generated artifact.
