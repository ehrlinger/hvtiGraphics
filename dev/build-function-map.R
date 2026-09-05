#!/usr/bin/env Rscript
## Build the function-to-recipe map.
##
## This used to be four executable chunks inside `function_map.qmd`, and that
## was the one chapter in the book whose output depended on OTHER chapters'
## sources. `freeze: auto` re-executes a chapter only when its own source
## changes, so every edit anywhere else silently invalidated the map while its
## cache, and CI, stayed green. That is the "stale freeze publishes a lie"
## failure in the shape `pr-check.yml` cannot see, because the gate compares a
## chapter against its own source and this chapter declared none of the 51 it
## actually read.
##
## The map now lives outside the render. This script writes a markdown fragment
## the chapter includes, plus a manifest of the sources it was built from.
## `function-map.yml` recomputes that manifest in CI, with no R, and fails when
## it no longer matches. The dependency is declared, and staleness is now loud.
##
## Run from the repository root:  Rscript dev/build-function-map.R

out_md       <- "_generated/function-map.md"
out_manifest <- "_generated/function-map.manifest"

## ---- the contract ------------------------------------------------------

expected <- list(
  hvtiR = c("install", "status", "update", "doctor"),
  hvtiPlotR = c(
    "hv_alluvial", "hv_atrisk", "hv_atrisk_compose", "hv_balance",
    "hv_consort", "hv_consort_exclude", "hv_consort_patients",
    "hv_consort_start", "hv_consort_summary", "hv_eda", "hv_followup",
    "hv_ggsave_dims", "hv_hazard", "hv_legend_inside", "hv_longitudinal",
    "hv_mirror_hist", "hv_nnt", "hv_nonparametric", "hv_ordinal",
    "hv_ph_location", "hv_ppt_palette", "hv_ppt_series", "hv_sankey",
    "hv_spaghetti", "hv_stacked", "hv_survival", "hv_survival_difference",
    "hv_trends", "hv_upset", "hv_venn", "save_manuscript", "save_ppt",
    "theme_hv_manuscript", "theme_hv_poster", "theme_hv_ppt_dark",
    "theme_hv_ppt_light"),
  hvtiRtables = c(
    "hv_tbl_summary", "hv_man_table", "hv_man_footnotes", "hv_man_table_save",
    "hv_check_docx", "hv_man_table_jtcvs", "hv_test_footnotes_jtcvs",
    "hv_man_table_save_jtcvs"),
  ggRandomForests = c(
    "gg_error", "gg_rfsrc", "gg_survival", "gg_vimp", "gg_shap", "gg_variable",
    "gg_partial_rfsrc", "gg_roc", "gg_brier", "gg_varpro", "gg_beta_varpro",
    "gg_ivarpro", "gg_isopro", "gg_beta_uvarpro", "gg_udependent",
    "gg_sdependent", "gg_partial_varpro", "gg_rhf", "gg_auct",
    "gg_rhf_importance", "gg_tune_rhf"),
  TemporalHazard = c(
    "hazard", "hzr_argument_mapping", "hzr_bootstrap", "hzr_calibrate",
    "hzr_competing_risks", "hzr_deciles", "hzr_gof", "hzr_kaplan",
    "hzr_nelson", "hzr_phase", "hzr_phase_cumhaz", "hzr_phase_hazard",
    "hzr_read_outhaz", "hzr_stepwise", "hzr_translate_sas", "stepwise_trace")
)

## Every name in the contract must still be exported. A rename upstream fails
## the build here rather than leaving a dead entry in the map.
missing <- unlist(lapply(names(expected), function(p)
  setdiff(expected[[p]], getNamespaceExports(p))))
stopifnot(length(missing) == 0)

## ---- roles -------------------------------------------------------------

roles <- c(
  # hvtiR: family lifecycle
  install = "Install the whole hvtiR family on a fresh machine",
  status = "Compare installed family versions against GitHub main",
  update = "Install only the missing or stale family members",
  doctor = "Diagnose R, pak, GitHub access, and member status",

  # hvtiPlotR: constructors
  hv_survival = "Kaplan-Meier survival estimate and its risk table",
  hv_survival_difference = "Difference between two survival curves",
  hv_nnt = "Number needed to treat over follow-up",
  hv_hazard = "Parametric or life-table hazard estimate",
  hv_nonparametric = "Nonparametric hazard and cumulative hazard",
  hv_ordinal = "Ordinal outcome over time",
  hv_atrisk = "Numbers-at-risk table aligned to a time axis",
  hv_atrisk_compose = "Stack a curve over its numbers-at-risk panel",
  hv_followup = "Follow-up completeness over time",
  hv_balance = "Covariate balance before and after adjustment",
  hv_consort = "CONSORT patient-flow diagram",
  hv_consort_start = "Open a CONSORT flow at the screened cohort",
  hv_consort_exclude = "Add an exclusion arm to a CONSORT flow",
  hv_consort_patients = "Add a retained-patients node to a CONSORT flow",
  hv_consort_summary = "Summarise a CONSORT flow as counts",
  hv_sankey = "Sankey flow between cluster states",
  hv_alluvial = "Alluvial flow across milestones",
  hv_upset = "UpSet plot of set intersections",
  hv_venn = "Venn diagram for two or three sets",
  hv_trends = "Grouped trend series over time",
  hv_spaghetti = "Per-patient trajectories across repeated measures",
  hv_longitudinal = "Longitudinal counts with a composite panel",
  hv_stacked = "Stacked categorical composition",
  hv_mirror_hist = "Back-to-back histogram for two groups",
  hv_eda = "Quick exploratory view of a data frame",

  # hvtiPlotR: finishing and delivery
  theme_hv_manuscript = "Journal theme: small type, minimal chrome, no legend",
  theme_hv_poster = "Poster theme: large type for arm's-length reading",
  theme_hv_ppt_light = "Slide theme for white or light-grey backgrounds",
  theme_hv_ppt_dark = "Slide theme for navy or dark-gradient decks",
  hv_ppt_series = "Matched colour and shape scales plus a slide theme",
  hv_ppt_palette = "The slide palette on its own",
  hv_legend_inside = "Put a key in the emptiest corner of the panel",
  hv_ggsave_dims = "Fix the panel content area, not the file size",
  hv_ph_location = "Slide coordinates so a panel lands in the same place",
  save_manuscript = "Write a manuscript-geometry figure file",
  save_ppt = "Write the plot onto a slide as editable vector shapes",

  # hvtiRtables
  hv_tbl_summary = "Summarise a cohort into a Table 1",
  hv_man_table = "Render a summary as a manuscript table",
  hv_man_footnotes = "Attach footnotes to a manuscript table",
  hv_man_table_save = "Write a manuscript table to Word",
  hv_check_docx = "Check a written Word table against the format rules",
  hv_man_table_jtcvs = "Render a table in the JTCVS format",
  hv_test_footnotes_jtcvs = "JTCVS footnote conventions for test results",
  hv_man_table_save_jtcvs = "Write a JTCVS-format table to Word",

  # ggRandomForests
  gg_error = "Out-of-bag error against the number of trees",
  gg_rfsrc = "Predicted response or survival from a forest",
  gg_survival = "Empirical survival estimate for comparison",
  gg_vimp = "Permutation variable importance",
  gg_shap = "Per-observation SHAP attributions",
  gg_variable = "Predicted response against a predictor's own values",
  gg_partial_rfsrc = "Partial dependence with other predictors averaged out",
  gg_roc = "ROC curve for a classification forest",
  gg_brier = "Brier score over time",
  gg_varpro = "varPro rule-based variable priority",
  gg_beta_varpro = "Beta-refined varPro importance",
  gg_beta_uvarpro = "Beta-refined importance for an unsupervised fit",
  gg_ivarpro = "Individual-level varPro priority",
  gg_isopro = "Isolation and anomaly scores",
  gg_udependent = "Dependency graph among predictors",
  gg_sdependent = "Ranked signal-variable detection",
  gg_partial_varpro = "Partial dependence for varPro-selected variables",
  gg_rhf = "Pointwise and cumulative hazard from a Random Hazard Forest",
  gg_auct = "Time-varying AUC for an RHF fit",
  gg_rhf_importance = "Time-localized variable priority for an RHF fit",
  gg_tune_rhf = "Read a completed RHF tree-size tuning path",

  # TemporalHazard
  hazard = "Fit an additive multi-phase hazard model",
  hzr_phase = "Define a hazard phase",
  hzr_phase_hazard = "Phase-specific hazard estimates",
  hzr_phase_cumhaz = "Phase-specific cumulative hazard",
  hzr_kaplan = "Kaplan-Meier comparison for a hazard fit",
  hzr_nelson = "Nelson-Aalen comparison for a hazard fit",
  hzr_calibrate = "Calibration of predicted against observed risk",
  hzr_gof = "Goodness-of-fit summary",
  hzr_deciles = "Observed against expected by risk decile",
  hzr_bootstrap = "Bootstrap uncertainty for a hazard fit",
  hzr_competing_risks = "Competing-risks decomposition",
  hzr_stepwise = "Stepwise variable selection for a hazard model",
  stepwise_trace = "Inspect the path a stepwise selection took",
  hzr_argument_mapping = "Map SAS HAZARD arguments onto the R interface",
  hzr_translate_sas = "Translate a SAS HAZARD call into R",
  hzr_read_outhaz = "Read a SAS OUTHAZ data set"
)

## ---- scan the book ------------------------------------------------------

## Scan the book's own sources. This chapter is excluded on purpose: it names
## every function in the contract above, so including it would mark everything
## covered by itself.
qmd <- setdiff(list.files(".", pattern = "[.]qmd$"), "function_map.qmd")
bodies <- setNames(
  lapply(qmd, function(f) paste(readLines(f, warn = FALSE), collapse = "\n")),
  sub("[.]qmd$", "", qmd)
)

chapters_calling <- function(fn) {
  pattern <- paste0("\\b", gsub("[.]", "[.]", fn), "\\(")
  names(bodies)[vapply(bodies, grepl, logical(1), pattern = pattern)]
}

map <- do.call(rbind, lapply(names(expected), function(pkg) {
  do.call(rbind, lapply(expected[[pkg]], function(fn) {
    where <- chapters_calling(fn)
    data.frame(
      Package  = pkg,
      Function = sprintf("`%s()`", fn),
      Role     = if (is.na(roles[fn])) "" else unname(roles[fn]),
      Recipe   = if (length(where))
                   paste(sprintf("[%s](%s.qmd)", where, where), collapse = ", ")
                 else "Package reference",
      Coverage = if (length(where)) "Worked recipe" else "Package reference",
      stringsAsFactors = FALSE
    )
  }))
}))

## ---- write the fragment ----------------------------------------------

lines <- c(
  "<!-- GENERATED by dev/build-function-map.R. Do not edit. -->",
  "",
  sprintf(
    "This book works through **%d of the %d** workflow-level functions in the contract.",
    sum(map$Coverage == "Worked recipe"), nrow(map)
  )
)

for (pkg in names(expected)) {
  rows <- map[map$Package == pkg, c("Function", "Role", "Recipe", "Coverage")]
  lines <- c(
    lines, "", paste0("### ", pkg), "",
    knitr::kable(rows, format = "pipe", row.names = FALSE)
  )
}

writeLines(lines, out_md)

## ---- write the manifest ----------------------------------------------
## One line per scanned source, `<md5>  <file>`, in `list.files()` order. This is the
## declaration the chapter never had: CI hashes the same files and fails on
## any difference, so an edit in another chapter can no longer pass unnoticed.

digests <- vapply(qmd, function(f) tools::md5sum(f)[[1]], character(1))
writeLines(sprintf("%s  %s", digests, qmd), out_manifest)

cat(sprintf(
  "Wrote %s (%d functions, %d worked) and %s (%d sources).\n",
  out_md, nrow(map), sum(map$Coverage == "Worked recipe"),
  out_manifest, length(qmd)
))
