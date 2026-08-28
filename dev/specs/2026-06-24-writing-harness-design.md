# Writing Harness — Design Spec

**Date:** 2026-06-24
**Author:** John Ehrlinger (with Claude)
**Status:** Draft for review
**Repo:** hvti_graphics (book), with canonical artifacts in the Obsidian vault

## Problem

Prose across the HVTI graphics ecosystem — the recipes book (`hvti_graphics`),
`hvtiPlotR`, and `ggRandomForests` — is kept in a consistent human voice by a
single reference, `~/Documents/ObsidianVault/memory/writing-voice.md` (the
"Writing Voice Fingerprint"). That doc is mature, but the harness has three
gaps:

1. **It is voice-only.** There is no documented *reader profile* (who we write
   for) and no *project context* (why we write the way we do). Both shape word
   choice, depth, and what counts as "landing."
2. **It is not invokable.** The voice doc is applied by hand. There is no Skill
   that loads it automatically, so the standard holds only when the author
   remembers to load it.
3. **The book repo is not wired in.** `hvti_graphics` — where prose is written
   most heavily — has no `.claude/`, no `CLAUDE.md`, and no copy of the voice
   doc. The harness reaches the package repos (synced copies) but not the book.

This spec covers building a three-part writing harness (Voice / Reader /
Context), packaging it as an invokable Skill, and wiring it into the book repo.

### Non-goals

- Not rebuilding the Voice DNA from scratch. It already exists and was built
  from real exemplars (CORR boilerplate methods docs, Ishwaran/Ehrlinger arXiv
  papers, the TemporalHazard LinkedIn post). We extend it, lightly.
- No newsletter/marketing framing from the source article: no conversion
  triggers, pricing, "unsubscribe" funnels, or offer content. The reader
  profile is reframed for technical clinical documentation.
- No separate intro/ending sub-skills (YAGNI). The single voice doc with its
  per-register exemplars is the unit. Revisit only if it proves too coarse.
- No MCP server.

## Architecture

Three canonical reference docs live in the vault (source of truth). One
invokable Skill loads them. Synced copies live in the book repo so it is
self-contained.

```
~/Documents/ObsidianVault/memory/            # canonical source of truth
  writing-voice.md            # EXISTS — Voice DNA; extend lightly
  writing-reader-profile.md   # NEW — who we write for
  writing-context.md          # NEW — project / ecosystem context

~/.claude/skills/ehrlinger-writing/
  SKILL.md                    # invokable everywhere; loads the three docs

hvti_graphics/.claude/                        # synced copies; repo is self-contained
  writing-voice.md
  writing-reader-profile.md
  writing-context.md
  CLAUDE.md                   # thin pointer: prose follows ehrlinger-writing;
                              # declares default reader persona = (a) biostatisticians
```

**Why the Skill is user-level.** A Skill must live in a discoverable skills
directory to be invokable. User-level (`~/.claude/skills/`) makes it available
in every repo — the book and both package repos — which is what "applies
everywhere" requires. The Skill reads the vault canon; the book repo keeps
copies so it still works without vault access.

**Why vault-canonical + synced copies.** Matches the existing setup (the voice
doc is already vault-canonical with synced copies in package repos). The vault
is the single place edits land; sync pushes copies outward. See Sync below.

### Component responsibilities

| Unit | Purpose | Depends on |
|---|---|---|
| `writing-voice.md` | *How* the prose sounds — registers, rules, AI tells, exemplars | nothing |
| `writing-reader-profile.md` | *Who* reads it — personas, what lands, what bounces | nothing |
| `writing-context.md` | *Why* we write this way — ecosystem, purpose, constraints | nothing |
| `SKILL.md` | Loads the three docs and applies them on demand | the three docs |
| repo copies + `CLAUDE.md` | Make the book repo self-documenting | the three docs |
| sync step | Keep vault canon and repo copies from drifting | all of the above |

Each reference doc is independently readable and editable; the Skill composes
them. Changing the reader profile does not require touching the voice doc.

## The three documents

### 1. `writing-voice.md` (extend, do not rebuild)

Keep the existing structure (voice-in-one-line, two registers, rules, AI tells,
before/after, reference exemplars). Add only:

- **"When NOT to apply this voice"** — a short section. The voice is for
  Narrative and Terse documentation prose. It does *not* govern CRAN-facing
  `\value`/`@return` boilerplate, R error/warning messages, or code comments,
  which have their own conventions.
- **One book-register exemplar** — a short "When to use it" passage from a
  recipe chapter. Current exemplars are package/LinkedIn/arXiv; none is from the
  recipes book, which is the dominant surface in this repo.

### 2. `writing-reader-profile.md` (new)

Reframed for technical clinical documentation. This doc is a **menu of
selectable personas**, not a single fixed audience: the harness is reusable, so
a given writing task chooses the persona it is written for. Each persona is
drawn from real vault data (`Projects/hvtiPlotR.md` names the team and purpose)
plus a short author interview during implementation — not invented:

- **(a) HVTI/CORR biostatisticians** adopting the house plotting style (the
  biostats team: Austin, Kelsey, Wendy). They will run the code.
  **This is the default persona for the `hvti_graphics` recipes book.**
- **(b) Clinical researchers / surgeons** who skim a recipe to decide *which
  plot answers my question* and consume the finished figure. They mostly do not
  run the code.
- **(c) External R users migrating from SAS** (`plot.sas`, the `%kaplan` macro).
  They map a known SAS output to its R successor.

For each persona, document: what they already know, what they want from a
recipe, what makes a recipe *land*, and what makes them *bounce* (the docs
analog of "unsubscribe": a wall of code with no explanation, a missing "when to
use it," unexplained jargon, a figure with no reading guide).

**Persona selection.** The reader profile is one audience at a time, not all
three blended. The active persona is chosen per task:

1. an explicit choice passed when the skill is invoked (e.g. "write this for the
   SAS-migration reader"), else
2. the project default declared in the repo's `.claude/CLAUDE.md`
   (`hvti_graphics` → persona (a), biostatisticians), else
3. if neither is set, the skill asks which persona applies before drafting.

### 3. `writing-context.md` (new)

The "why we write this way" layer (the article's "business profile," reframed):

- **The ecosystem:** `hvtiPlotR` (themes + plot constructors), `ggRandomForests`
  (forest/varpro graphics), `temporal_hazard` (additive hazards), and this
  recipes book that ties them together.
- **Purpose:** reproducible, publication-quality, house-style clinical graphics
  for Cardiovascular Outcomes Registries and Research (CORR) at the Cleveland
  Clinic Heart & Vascular Institute.
- **Constraints that shape the writing:** CORR publication standards,
  reproducibility (Git, renv, dataset manifests), no PHI, R-first, and the
  SAS-migration heritage (readers who trust SAS output need the R version to
  earn that trust).

### 4. `SKILL.md` (new, user-level)

A skill named `ehrlinger-writing`. Frontmatter `description` triggers on prose
work in these repos (drafting/editing vignettes, README, roxygen, recipe
chapters, release posts). Body:

1. Load the three reference docs (prefer the vault canon; fall back to the repo
   copy).
2. **Resolve the active reader persona** via the selection order above
   (explicit choice → repo `CLAUDE.md` default → ask). State which persona is
   in effect so the choice is visible.
3. Apply voice + the *selected* reader persona + context to the drafting or
   editing task.

Built with the `skill-creator` / `writing-skills` tooling.

## Sync

The vault is canonical. A short, documented sync step copies:

- the three reference docs → `hvti_graphics/.claude/` (and, on the same model,
  the package repos that already carry `writing-voice.md`), and
- `SKILL.md` → `~/.claude/skills/ehrlinger-writing/`.

Implementation: a small shell script (e.g. `tools/sync-writing-harness.sh` in
the vault, or a documented `cp` sequence) — decided during planning. The script
must be idempotent and must not edit the canon. Note: vault git lives outside
iCloud (`GIT_DIR`/`GIT_WORK_TREE` form per global setup), so the sync touches
files under the vault working tree but commits to the vault repo separately.

## Verification / success criteria

1. The three reference docs exist in the vault and as copies in the book repo;
   `diff` shows the copies match the canon.
2. `ehrlinger-writing` is invokable via the Skill tool from the book repo.
3. **Smoke test:** invoke the skill on one existing recipe passage and confirm
   it (a) states the active reader persona — defaulting to (a) biostatisticians
   from the repo `CLAUDE.md` — and (b) cites specific voice rules (names an AI
   tell or a register), i.e. it is using all three docs, not just the voice doc.
4. **Persona override test:** invoke the skill with an explicit persona (e.g.
   the SAS-migration reader) and confirm it reports that persona instead of the
   repo default.
5. The sync step runs idempotently and leaves vault canon unchanged.

## Open questions

- Exact persona detail for the reader profile — resolved by the author
  interview during implementation.
- Sync mechanism: script vs. documented manual `cp` — decided in the plan.
- Whether the package repos also adopt the new reader/context docs now, or only
  the book repo for this pass. Default: book repo now; package repos later.

## Relationship to sub-project A

This is sub-project B. Per the agreed sequencing, B is finished
(spec → plan → implement) before sub-project A (book content: new
`ggRandomForests` recipes, audit of "When to use it" sections, migration of
superseded `hvtiPlotR` aliases) gets its own spec. The harness built here is
then used to drive A's prose.
