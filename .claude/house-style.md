<!--
  GENERATED FILE - DO NOT EDIT.

  Composed by tools/house-style/compose-house-style.R in the
  ehrlinger-personal repository. Edit the sources in the Obsidian vault
  (memory/), then recompose. Editing this file directly will be reverted
  by the next compose and flagged by --check.

  repo:            hvti_graphics
  profile:         book
  default persona: (a)
  sources:
    writing-voice.md               sha256:6ca5d2b7682a
    writing-reader-profile.md      sha256:179212de138c
    writing-context.md             sha256:87d5555936e1
    r-package-structure.md         sha256:737699a33103
-->

# House Style — hvti_graphics

Default reader persona for this repository: **(a)**. Write for one persona at a time.

---

# John Ehrlinger — Writing Voice Fingerprint

Reference for keeping documentation and prose in a consistent human voice.
Canonical copy lives in the Obsidian vault; package repos hold a synced copy.

## The voice in one line

Pedagogical and conversational: start from something the reader already knows,
build to the new idea with a concrete analogy, and don't be afraid of a little
personality or a slightly imperfect sentence.

## Two registers

**Narrative** (vignettes, README, roxygen @description/@details, methods prose)
- Open from the familiar: "Most readers are familiar with simple linear regression..."
- Carry one concrete analogy through a hard idea (a fruit basket, the blind men
  and the elephant, a "noise-reduction filter").
- Question-headed sections: "Why Cluster?", "Where Do We Stop?".
- First person plural: "in our practice", "we proceed". Address the reader as "you".
- Gloss terms inline in parentheses; scare-quote a piece of jargon the first
  time it appears ("rules", "elbow", "eyeballing").
- Start sentences with But / Yet / Thus / Now when it helps the flow.
- **Conversational, not chatty.** A colleague explaining the method at a
  whiteboard, not a blog post. Keep an analogy when it teaches; cut winking
  asides and cute phrasing. "no Tukey rule hiding in the middle" is too cute;
  "not the usual Tukey 1.5 IQR whiskers" is right. Plain and direct beats
  folksy. The reader is a peer, so don't perform for them.
- Vary sentence length. A short flat statement after a long one lands well.

**Terse** (roxygen @param/@return, NEWS bullets)
- Compressed, but still plain and concrete, not sterile.
- State the thing; skip the preamble. "Logical; if TRUE, ..." not "This
  argument controls whether...".
- No analogies, no question headers here; the voice shows in word choice.

## Rules

- Em-dashes: use sparingly. Native to the voice and honestly overused. Keep one
  where it earns the pause; otherwise a comma, parentheses, or a full stop.
- Ellipses: an informal-register habit (text, email). Keep them out of package docs.
- Don't overstate. No overselling. Cut "enhanced", "powerful", "seamlessly",
  "robust" (as a brag), "comprehensive". State what the thing does, at its size.
- Imperfection is allowed. Mild redundancy, an occasional long sentence: human
  texture, not an error to scrub. Don't polish to a glassy finish.
- Repetition that teaches is voice, not defect. Restating a concept, or a
  callback structure (state the problems up front, answer each later), is kept.
  Repeat when it clarifies; cut repetition that only fills space.

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

## AI tells to hunt and kill

- Mechanical parallelism: same-shaped sentences with no teaching purpose, lists
  padded to equal length. (Pedagogical repetition is NOT this; preserve it.)
- Flavorlessness: correct but with no analogy, no picture, nothing a person
  would actually say.
- Missing "we"/"you": abstract, authorless prose.
- Forced tricolons: "fast, simple, and reliable".
- Hedge-free sterile balance: "X. However, Y. It is worth noting Z."
- Overstatement (see Rules).
- "in order to", "it is important to note", "leverage", "utilize".

Punctuation density is NOT a tell. The tells are structural.

## Before / after

AI:   "Set per_class = TRUE to enable the computation of per-class one-vs-rest
       ROC curves, providing enhanced flexibility for multi-class analysis."
John: "Set per_class = TRUE and a multi-class forest gives you one ROC curve
       per class, each class scored against all the others."


## Reference exemplars

Canonical samples of the voice, by register. When in doubt, read the one whose
register matches the task.

- **Plain-English explanatory** (the gold standard for teaching a method):
  the CORR methods boilerplates — the plain-English VarPro write-up and the
  SID-clustering supplement (internal, CORR Analysis Team share). Opens from the familiar, carries one analogy throughout
  (fruit basket, noise-reduction filter), question-headed sections, "we"/"you",
  numbered-problems-answered-later callback.
- **Short-form announcement** (LinkedIn / release posts): the TemporalHazard
  1.0.3 LinkedIn post, below. Compresses the narrative register: familiar
  opener, one rhetorical-question hook, one carried picture, understatement,
  "we"/"you", no marketing tricolons.
- **Recipe book ("When to use it" sections)**: the Survival Plots chapter
  opener in `hvti_graphics/survival.qmd`. Narrative register aimed at a
  biostatistician reader: names the clinical question first ("how long until an
  event"), defines the one idea that makes the method its own (right-censoring),
  ties the function to the SAS macro the reader already trusts (`%kaplan`), and
  closes on how the object is used. No overstatement, "you" throughout.
- **Formal academic**: arXiv 1612.08974 and 1501.07196 (Ishwaran/Ehrlinger).
  Passive, citation-dense, no "you" — use only when the task is a methods paper.

### Short-form exemplar — TemporalHazard 1.0.3 (LinkedIn, 2026-05-29)

> When modeling survival after surgery, we know that risk is not constant. It's
> high in the days right after the operation, falls to a low steady rate once
> patients recover, then creeps back up years later as they age. So why do we
> so often force a single Weibull curve onto all three? It can't be early, flat,
> and late at once — the Weibull curve splits the difference and fits none of
> these segments well.
>
> Additive hazards (Blackstone, Naftel, and Turner, 1986) allow us to linearly
> combine hazard functions into a coherent single model. Instead of forcing one
> shape, you add up several: an early phase, a constant phase, a late phase,
> each with its own scale and its own covariate effects. It's been the workhorse
> of cardiac surgery outcomes ever since, and its code has been openly licensed
> for years — but running it still meant a SAS license.
>
> TemporalHazard is that model, rebuilt in pure R at Cleveland Clinic. We
> checked it against the original program fit for fit, so the numbers match what
> longtime SAS users already trust. Putting it in R opens these methods to many
> more users.
>
> Around that core it does what you'd want: five distributions, stepwise
> selection, confidence limits on predictions, and the usual diagnostics —
> Kaplan-Meier overlays, calibration, bootstrap. The vignettes walk a real
> clinical dataset start to finish, the way you'd actually run the analysis.

Why it works: familiar opener ("we know that risk is not constant"), a
rhetorical-question hook ("So why do we so often..."), one carried picture
(early/flat/late), understatement ("the usual diagnostics"), and "we"/"you"
throughout. No forced tricolon, no padded feature list, no overselling.

---

# Reader Profiles — documentation audiences

A menu of selectable audiences for the `ehrlinger-writing` harness. Write for
ONE persona at a time, not a blend. The active persona is chosen per task
(explicit choice → repo `CLAUDE.md` default → ask). The `hvti_graphics` recipes
book defaults to persona (a); the public CRAN packages (`ggRandomForests`,
`temporal_hazard`) default to persona (d).

*Retitled 2026-07-16: this was "HVTI graphics documentation", but the harness
also governs two public CRAN packages whose readers have no HVTI context. See
(d).*

## (a) HVTI/CORR biostatistician — DEFAULT for the recipes book

The CORR biostatistics team adopting the house plotting style.

- **Already knows:** R, ggplot2, survival analysis, the CORR datasets.
- **Wants from a recipe:** all three at once — runnable code to copy, a call on
  which plot to use, and the meaning of a specific argument. They open a recipe
  for any of the three, often in the same sitting.
- **Lands when:** the code runs as written, the argument is shown in context,
  the recipe says when to use the plot, and the figure comes with a reading
  guide.
- **Bounces when:** the recipe opens with a wall of code before saying what the
  plot is for, or shows a figure with no guide on how to read it.
- **Watch for:** the reader hand-rolling a plot in raw ggplot instead of using
  the `hvtiPlotR`/`ggRandomForests` constructor that already makes it. Second,
  drifting off house style by skipping the `hv_*` theme or the two-step S3
  workflow.

## (b) Clinical researcher / surgeon — figure consumer

Clinical researchers and surgeons do not read the book. They receive the
exported figure. Persona (a) is the one who, on their behalf, picks the right
plot and writes or says how to read it. So this is not a prose audience — it is
a constraint on persona (a)'s prose: when writing for the biostatistician,
remember the figure will be handed to a clinician who never saw the recipe. The
recipe should make the figure self-explanatory, so the reading guide carries
over to the person who only sees the plot.


---

# Project Context — HVTI graphics ecosystem

Why we write the way we do. The harness reads this so prose carries the right
assumptions about purpose and constraints.

## The ecosystem

- **hvtiPlotR** — ggplot2 themes and plot constructors; the R replacement for
  the historical `plot.sas` macro.
- **ggRandomForests** — graphics for random forests and variable priority
  (varPro), built on randomForestSRC.
- **temporal_hazard** — additive (Blackstone, Naftel, and Turner, 1986) hazard
  models in pure R.
- **hvti_graphics** — this recipes book, which ties the three together into a
  house style for clinical figures.

## Purpose

A single source of ggplot2 recipes for publication-quality, house-style figures
for HVTI CORR (Cardiovascular Outcomes Registries and Research, Cleveland Clinic
Heart & Vascular Institute) publications and presentations. Each recipe pairs a
figure with the code that produces it, so the next person starts from a working
script instead of a blank one.

Two ideas run through the book: a figure is built in two steps (a constructor
prepares and validates the data, then `plot()` hands you a bare ggplot you finish
with `+`), and every example stands on its own with its own sample data.

## Constraints that shape the writing

- **CORR publication standards** — figures must meet journal expectations.
- **Reproducibility** — Git, renv, dataset manifests; every figure regenerable.
- **No PHI** — never in code, prose, or example data.
- **R-first** — R is the working language; SAS is the heritage we migrate from.
- **SAS-migration heritage** — many readers trust SAS output, so we say when the
  R version matches the original (the way we checked temporal_hazard fit for fit).
