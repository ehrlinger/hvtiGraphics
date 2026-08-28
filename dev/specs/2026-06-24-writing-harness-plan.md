# Writing Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a three-part writing harness — Voice DNA, a selectable Reader Profile, and project Context — packaged as an invokable user-level skill (`ehrlinger-writing`) with vault-canonical docs synced into the `hvti_graphics` book repo.

**Architecture:** Three markdown reference docs are canonical in the Obsidian vault (`memory/`). A user-level Skill loads them and resolves one active reader persona per task. A sync script copies the docs into the book repo's `.claude/` and installs the Skill under `~/.claude/skills/`, so the repo is self-contained and the Skill is invokable everywhere.

**Tech Stack:** Markdown; Claude Code Skills (`skill-creator` / `superpowers:writing-skills`); bash for sync; two git repos — the **book repo** (`hvti_graphics`, normal git on branch `feat/writing-harness`) and the **vault** (external git dir, see helper below).

---

## Conventions used throughout this plan

**Vault git** lives outside iCloud. There is NO `.git` inside the vault folder. Run every vault git command as:

```bash
GIT_DIR=~/Documents/GitHub/obsidian.git GIT_WORK_TREE=~/Documents/ObsidianVault git <cmd>
```

(Commit directly to `main` in the vault — it is a notes repo, not code.)

**Book repo git** is normal: `cd ~/Documents/GitHub/hvti_graphics` and commit to branch `feat/writing-harness` (already created).

**Voice check before each commit:** read the new/edited prose against `~/Documents/ObsidianVault/memory/writing-voice.md` — specifically the "AI tells to hunt and kill" list (mechanical parallelism, flavorlessness, missing we/you, forced tricolons, overstatement, "leverage"/"utilize"/"in order to"). This is the content analog of running tests.

---

## File Structure

| File | Responsibility | Repo |
|---|---|---|
| `~/Documents/ObsidianVault/memory/writing-voice.md` | Voice DNA (extend) | vault (canonical) |
| `~/Documents/ObsidianVault/memory/writing-reader-profile.md` | Selectable reader personas | vault (canonical) |
| `~/Documents/ObsidianVault/memory/writing-context.md` | Ecosystem / purpose / constraints | vault (canonical) |
| `~/Documents/ObsidianVault/tools/sync-writing-harness.sh` | Copy canon → repo + install Skill | vault (canonical) |
| `~/.claude/skills/ehrlinger-writing/SKILL.md` | Invokable skill; resolves persona, applies all three docs | user-level (installed by sync) |
| `hvti_graphics/.claude/writing-voice.md` | Synced copy | book repo |
| `hvti_graphics/.claude/writing-reader-profile.md` | Synced copy | book repo |
| `hvti_graphics/.claude/writing-context.md` | Synced copy | book repo |
| `hvti_graphics/.claude/CLAUDE.md` | Repo pointer; declares default persona = (a) biostatisticians | book repo |

The SKILL.md master is authored under `~/.claude/skills/ehrlinger-writing/` directly (it must live in a discoverable skills dir). The sync script does not generate it; it only copies the three reference docs outward and is the documented "install/refresh" entry point.

---

## Task 1: Extend the Voice DNA doc

**Files:**
- Modify: `~/Documents/ObsidianVault/memory/writing-voice.md`

- [ ] **Step 1: Add a "When NOT to apply this voice" section**

Insert this section immediately after the `## Rules` section (before `## AI tells to hunt and kill`):

```markdown
## When NOT to apply this voice

This voice governs documentation *prose* — Narrative and Terse. It does not
govern:

- CRAN-facing `\value` / `@return` boilerplate, which follows R documentation
  convention, not register.
- R error, warning, and message strings, which state the condition plainly.
- Code comments, which explain the code to a maintainer, not the method to a
  reader.

When the task is one of these, ignore the registers and write to the local
convention.
```

- [ ] **Step 2: Add a book-register exemplar**

In the `## Reference exemplars` list, add this bullet after the "Short-form announcement" bullet:

```markdown
- **Recipe book ("When to use it" sections)**: the Survival Plots chapter
  opener in `hvti_graphics/survival.qmd`. Narrative register aimed at a
  biostatistician reader: names the clinical question first ("how long until an
  event"), defines the one idea that makes the method its own (right-censoring),
  ties the function to the SAS macro the reader already trusts (`%kaplan`), and
  closes on how the object is used. No overstatement, "you" throughout.
```

- [ ] **Step 3: Voice check**

Read both additions against the AI-tells list in the same file. Confirm: no overstatement, "you"/"we" present where natural, no forced tricolon.

- [ ] **Step 4: Commit to the vault**

```bash
GIT_DIR=~/Documents/GitHub/obsidian.git GIT_WORK_TREE=~/Documents/ObsidianVault \
  git add memory/writing-voice.md
GIT_DIR=~/Documents/GitHub/obsidian.git GIT_WORK_TREE=~/Documents/ObsidianVault \
  git commit -m "docs(voice): add when-not-to-apply section and book-register exemplar"
```

---

## Task 2: Author the Reader Profile (interview-driven)

**Files:**
- Create: `~/Documents/ObsidianVault/memory/writing-reader-profile.md`

- [ ] **Step 1: Interview the author**

Ask these five questions, one at a time, and record the answers. Do not invent personas — these answers are the input data.

1. For persona (a) biostatisticians (Austin, Kelsey, Wendy): what is the single most common reason they open a recipe — to copy code, to check an argument, or to decide which plot to use?
2. What is the most frequent mistake or misunderstanding you see this team make that good docs could prevent?
3. For persona (b) clinical researchers/surgeons: do they read the book at all, or only see exported figures? If they read it, what one thing must a recipe give them?
4. For persona (c) SAS migrators: which SAS macros/outputs are the anchors they map from (`%kaplan`, `plot.sas`, others)?
5. Across all three, what is the fastest way a recipe loses a reader (the "bounce" trigger)?

- [ ] **Step 2: Write the reader profile**

Create the file with this exact structure, filling the bracketed fields from the Step 1 answers and from `~/Documents/ObsidianVault/Projects/hvtiPlotR.md`:

```markdown
# Reader Profiles — HVTI graphics documentation

A menu of selectable audiences for the `ehrlinger-writing` harness. Write for
ONE persona at a time, not a blend. The active persona is chosen per task
(explicit choice → repo `CLAUDE.md` default → ask). The `hvti_graphics` recipes
book defaults to persona (a).

## (a) HVTI/CORR biostatistician  — DEFAULT for the recipes book

The biostats team (Austin, Kelsey, Wendy) adopting the house plotting style.

- **Already knows:** R, ggplot2, survival analysis, the CORR datasets.
- **Wants from a recipe:** [most common reason — from Q1].
- **Lands when:** runnable code, the right argument shown in context, a clear
  "when to use it," and a reading guide for the figure.
- **Bounces when:** [bounce trigger — from Q5].
- **Watch for:** [common mistake good docs prevent — from Q2].

## (b) Clinical researcher / surgeon

Consumes finished figures; skims a recipe to decide which plot answers a
question.

- **Already knows:** the clinical question and the data; little or no R.
- **Reads the book:** [yes/no and what they need — from Q3].
- **Lands when:** the recipe names the clinical question first and explains how
  to read the figure.
- **Bounces when:** the chapter opens with a wall of code before saying what the
  plot is for.

## (c) External R user migrating from SAS

Maps a known SAS output to its R successor.

- **Already knows:** the SAS workflow; [anchor macros — from Q4].
- **Lands when:** the recipe ties the R function to the SAS macro it replaces
  and confirms the numbers match.
- **Bounces when:** the R API is described with no bridge from the SAS they know.
```

- [ ] **Step 3: Voice check**

Read the prose fields against the AI-tells list. The persona descriptions are Terse register — plain and concrete, no padding.

- [ ] **Step 4: Commit to the vault**

```bash
GIT_DIR=~/Documents/GitHub/obsidian.git GIT_WORK_TREE=~/Documents/ObsidianVault \
  git add memory/writing-reader-profile.md
GIT_DIR=~/Documents/GitHub/obsidian.git GIT_WORK_TREE=~/Documents/ObsidianVault \
  git commit -m "docs(reader): add selectable reader-profile menu"
```

---

## Task 3: Author the Context doc

**Files:**
- Create: `~/Documents/ObsidianVault/memory/writing-context.md`

- [ ] **Step 1: Write the context doc**

Create the file with this content (facts drawn from `Projects/hvtiPlotR.md` and the book's `index.qmd`/`intro.qmd` — read those first to confirm wording):

```markdown
# Project Context — HVTI graphics ecosystem

Why we write the way we do. The harness reads this so prose carries the right
assumptions about purpose and constraints.

## The ecosystem

- **hvtiPlotR** — ggplot2 themes and plot constructors; the R replacement for
  the historical `plot.sas` macro.
- **ggRandomForests** — graphics for random forests and variable priority
  (varPro), built on randomForestSRC.
- **temporal_hazard** — additive (Blackstone-Naftel-Turner) hazard models in
  pure R.
- **hvti_graphics** — this recipes book, which ties the three together into a
  house style for clinical figures.

## Purpose

Reproducible, publication-quality, house-style clinical graphics for
Cardiovascular Outcomes Registries and Research (CORR) at the Cleveland Clinic
Heart & Vascular Institute. Manuscripts, posters, and editable PowerPoint slides.

## Constraints that shape the writing

- **CORR publication standards** — figures must meet journal expectations.
- **Reproducibility** — Git, renv, dataset manifests; every figure regenerable.
- **No PHI** — never in code, prose, or example data.
- **R-first** — R is the working language; SAS is the heritage we migrate from.
- **SAS-migration heritage** — many readers trust SAS output; the R version has
  to earn that trust, so we say when numbers match the original.
```

- [ ] **Step 2: Voice check**

Read against the AI-tells list. Cut any overstatement; keep it concrete.

- [ ] **Step 3: Commit to the vault**

```bash
GIT_DIR=~/Documents/GitHub/obsidian.git GIT_WORK_TREE=~/Documents/ObsidianVault \
  git add memory/writing-context.md
GIT_DIR=~/Documents/GitHub/obsidian.git GIT_WORK_TREE=~/Documents/ObsidianVault \
  git commit -m "docs(context): add HVTI graphics ecosystem context"
```

---

## Task 4: Write the sync script

**Files:**
- Create: `~/Documents/ObsidianVault/tools/sync-writing-harness.sh`

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
# Sync the canonical writing harness from the vault out to a target repo and
# install the skill under ~/.claude/skills. Idempotent. Never edits the canon.
#
# Usage: sync-writing-harness.sh /path/to/target/repo
set -euo pipefail

VAULT="$HOME/Documents/ObsidianVault/memory"
SKILL_SRC="$HOME/.claude/skills/ehrlinger-writing/SKILL.md"
TARGET="${1:?usage: sync-writing-harness.sh /path/to/target/repo}"

DOCS=(writing-voice.md writing-reader-profile.md writing-context.md)

# 1. Copy the three reference docs into the target repo's .claude/
mkdir -p "$TARGET/.claude"
for d in "${DOCS[@]}"; do
  cp "$VAULT/$d" "$TARGET/.claude/$d"
  echo "synced $d -> $TARGET/.claude/$d"
done

# 2. Confirm the skill is installed (authored under ~/.claude/skills directly)
if [[ -f "$SKILL_SRC" ]]; then
  echo "skill present: $SKILL_SRC"
else
  echo "WARNING: skill not found at $SKILL_SRC (author it before invoking)" >&2
fi
```

- [ ] **Step 2: Make it executable and smoke-run it**

```bash
chmod +x ~/Documents/ObsidianVault/tools/sync-writing-harness.sh
~/Documents/ObsidianVault/tools/sync-writing-harness.sh ~/Documents/GitHub/hvti_graphics
```

Expected output: three `synced ...` lines, then a `WARNING: skill not found` line (the skill is authored in Task 5). Re-running must produce identical output (idempotent).

- [ ] **Step 3: Commit to the vault**

```bash
GIT_DIR=~/Documents/GitHub/obsidian.git GIT_WORK_TREE=~/Documents/ObsidianVault \
  git add tools/sync-writing-harness.sh
GIT_DIR=~/Documents/GitHub/obsidian.git GIT_WORK_TREE=~/Documents/ObsidianVault \
  git commit -m "tools: add writing-harness sync script"
```

---

## Task 5: Author and install the Skill, wire up the book repo

**Files:**
- Create: `~/.claude/skills/ehrlinger-writing/SKILL.md`
- Create: `hvti_graphics/.claude/CLAUDE.md`
- Create (via sync): `hvti_graphics/.claude/writing-voice.md`, `writing-reader-profile.md`, `writing-context.md`

- [ ] **Step 1: Invoke skill-creator to scaffold**

Use the `superpowers:writing-skills` skill (or `anthropic-skills:skill-creator`) to create the skill directory and a SKILL.md skeleton at `~/.claude/skills/ehrlinger-writing/`. Follow its frontmatter conventions.

- [ ] **Step 2: Write SKILL.md**

The file must contain this frontmatter and body (adjust only to match the skill-creator's required frontmatter schema):

```markdown
---
name: ehrlinger-writing
description: Apply John Ehrlinger's documentation writing harness — voice, reader persona, and project context — when drafting or editing prose (vignettes, README, roxygen @description/@details, recipe-book chapters, release/LinkedIn posts) in the hvti_graphics, hvtiPlotR, ggRandomForests, or temporal_hazard repos. Triggers on "write/edit/polish/rewrite this in my voice", "make this sound like me", "draft a vignette/README/release post", or any documentation prose task in these repos.
---

# Ehrlinger Writing Harness

Apply three reference docs to every documentation prose task. Prefer the vault
canon; fall back to the repo copy under `.claude/` if the vault is unavailable.

1. **Voice** — `~/Documents/ObsidianVault/memory/writing-voice.md`
   (fallback: `.claude/writing-voice.md`)
2. **Reader** — `~/Documents/ObsidianVault/memory/writing-reader-profile.md`
   (fallback: `.claude/writing-reader-profile.md`)
3. **Context** — `~/Documents/ObsidianVault/memory/writing-context.md`
   (fallback: `.claude/writing-context.md`)

## Steps

1. Read all three docs.
2. **Resolve the active reader persona**, in this order:
   a. an explicit persona named in the request ("write this for the SAS reader"),
   b. else the default in the repo's `.claude/CLAUDE.md`,
   c. else ask which persona applies before drafting.
   **State the persona in effect** before you draft or critique.
3. Draft or edit applying the voice registers, the *selected* persona, and the
   context constraints.
4. Before returning, self-check against the voice doc's "AI tells to hunt and
   kill" list and name any tell you removed.
```

- [ ] **Step 3: Run the sync into the book repo**

```bash
~/Documents/ObsidianVault/tools/sync-writing-harness.sh ~/Documents/GitHub/hvti_graphics
```

Expected: three `synced` lines and `skill present: ...` (no warning now).

- [ ] **Step 4: Write the book repo CLAUDE.md pointer**

Create `hvti_graphics/.claude/CLAUDE.md`:

```markdown
# hvti_graphics — repo instructions

All documentation prose (recipe chapters, README, captions) follows the
`ehrlinger-writing` harness. The canonical docs live in the Obsidian vault;
synced copies are in this `.claude/` directory.

**Default reader persona for this repo: (a) HVTI/CORR biostatistician.**
Override per task by naming another persona explicitly.
```

- [ ] **Step 5: Verify the copies match the canon**

```bash
for d in writing-voice.md writing-reader-profile.md writing-context.md; do
  diff ~/Documents/ObsidianVault/memory/$d ~/Documents/GitHub/hvti_graphics/.claude/$d \
    && echo "OK $d"
done
```

Expected: `OK writing-voice.md`, `OK writing-reader-profile.md`, `OK writing-context.md` with no diff output.

- [ ] **Step 6: Commit the book repo changes**

```bash
cd ~/Documents/GitHub/hvti_graphics
git add .claude/
git commit -m "feat(writing): wire ehrlinger-writing harness into the book repo

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 6: Verify the harness end to end

**Files:** none (verification only)

- [ ] **Step 1: Smoke test — default persona**

Invoke the `ehrlinger-writing` skill on the existing `survival.qmd` "When to use it" passage (lines 11-28). Confirm the response:
- states the active persona is **(a) biostatistician** (resolved from the repo `CLAUDE.md` default), AND
- cites at least one specific voice rule or named AI tell.

If it does not state a persona, the resolution step in SKILL.md is wrong — fix and re-run.

- [ ] **Step 2: Persona override test**

Invoke the skill with an explicit instruction: "rewrite this for the SAS-migration reader." Confirm the response reports persona **(c)** in effect, not the repo default.

- [ ] **Step 3: Idempotent sync check**

```bash
~/Documents/ObsidianVault/tools/sync-writing-harness.sh ~/Documents/GitHub/hvti_graphics
git -C ~/Documents/GitHub/hvti_graphics status --porcelain .claude/
```

Expected: the second run prints the same `synced`/`skill present` lines, and `git status` shows no changes (copies already matched — nothing to re-stage).

- [ ] **Step 4: Confirm vault canon untouched by sync**

```bash
GIT_DIR=~/Documents/GitHub/obsidian.git GIT_WORK_TREE=~/Documents/ObsidianVault \
  git status --porcelain memory/
```

Expected: no output (the sync reads the canon, never writes it).

---

## Self-Review (completed by plan author)

- **Spec coverage:** Voice extend (T1), Reader menu + selection (T2 + T5 SKILL), Context (T3), user-level Skill (T5), repo copies + CLAUDE.md default (T5), sync (T4), all five verification criteria (T6 + T5 Step 5). Covered.
- **Placeholder scan:** the bracketed fields in T2 are interview-driven *input data*, gathered in T2 Step 1 — not deferred work. All code/script/markdown blocks are complete.
- **Type/name consistency:** skill name `ehrlinger-writing`, doc filenames, and the three-step persona resolution match across T2, T5, and T6.
