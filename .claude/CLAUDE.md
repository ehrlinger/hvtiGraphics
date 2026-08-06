# hvti_graphics — repo instructions

All documentation prose (recipe chapters, README, captions) follows the
`ehrlinger-writing` harness. Voice, reader personas, and project context are
composed into `.claude/house-style.md` in this directory — one self-contained
document, generated from the canonical sources in the Obsidian vault.

**Default reader persona for this repo: (a) HVTI/CORR biostatistician.**
Persona (b), the clinician who receives the figure, is never a prose target —
it is a constraint on (a)'s prose, since the figure gets handed to someone who
never saw the recipe. Override per task by naming another persona explicitly.

`house-style.md` is **generated — do not edit it.** Edit the vault sources and
recompose:

```
Rscript ~/Documents/GitHub/ehrlinger-personal/tools/house-style/compose-house-style.R \
  --repo hvti_graphics
```

CI fails the build when the artifact drifts from those sources. That check
exists because this repo carried hand-synced copies of the same documents until
2026-08-06, and one of them — `writing-reader-profile.md` — had been stale for
roughly three weeks, missing persona (d) entirely, without anyone noticing.

This is a book, not an R package, so it composes under the `book` profile:
voice, personas and context, without the package structure rules that govern
README order, the roxygen contract, and vignette roles.
