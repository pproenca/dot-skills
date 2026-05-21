# Skill Quality Metrics

This document defines how `dot-skills` measures skill quality: the metrics, where each comes
from, how they are normalized and weighted into a single **Skill Quality Score (SQS)**, and
how that cheap score is validated against expensive ground-truth evaluation. It is the
authoritative spec that `scripts/quality/score-skill.mjs` implements.

> **One-line summary:** SQS is a deterministic, reproducible 0–100 index of a skill's
> **structural / authoring quality** (discoverability, conciseness, progressive disclosure,
> calibration, format conformance). Calibration (`calibration/correlation.md`) showed it is
> reliable for *that* — and that it does **not** measure content correctness (use rubric
> review) or marginal usefulness (use baseline-differential functional eval, FQD; SQS↔FQD was
> ~−0.5 on the anchor). Treat SQS as a structural-quality and regression signal, not a
> verdict on whether a skill helps.

---

## 1. Why these metrics (sources)

Every metric traces to a published, citable source — not personal taste:

| Source | What we take from it |
|--------|----------------------|
| Anthropic, *Equipping agents for the real world with Agent Skills* ([engineering blog](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)) | Progressive disclosure; discovery via `name`/`description`; context economy/conciseness; **evaluation-first with no-skill baseline comparison**; "state the rule, then the why"; anti-patterns (over-triggering, overreliance, anticipating context upfront) |
| dev-skill discipline rubrics (`distillation`/`composition`/`investigation`/`extraction` `RUBRIC.md`) | Discipline-specific verifiable checks; SHIP / NEEDS-WORK / REJECT verdict vocabulary |
| dev-skill `QUALITY_CHECKLIST.md` | Quantified structural targets: impact calibration (CRITICAL not inflated), quantified-impact >80%, incorrect+correct coverage 100%, code-fence languages, no generic names, rule-count band 40–60 |
| repo `scripts/skills-ref` | Hard structural rules: name format/length/dir-match, description ≤1024 chars, SKILL.md ≤500 lines, Quick-Reference ↔ reference-file consistency |
| repo `scripts/check-versions.mjs` | Maintenance taxonomy: OK / STALE / DIRTY / NEVER_BUMPED |

---

## 2. The measurement model: a calibrated proxy

Three tiers, each used where it is cost-justified:

1. **SQS (deterministic proxy)** — static analysis only, $0 model cost, fully reproducible.
   Runs on **every skill** and **every version in git history**. This document defines it.
2. **FQD (Functional Quality Delta — ground truth)** — Anthropic's baseline-differential
   eval: pass-rate(with-skill) − pass-rate(no-skill) on gap-targeted assertions. Expensive;
   run only on a stratified **calibration sample** (~12 skills).
3. **Rubric verdict (accuracy cross-check)** — the dev-skill discipline rubric run by the
   `skill-reviewer` agent on the same sample. Catches factual/staleness errors that neither
   statics nor pass-rates surface.

**SQS is validated by FQD.** We compute the Spearman rank correlation between SQS and FQD on
the sample. A strong positive correlation is the credibility statement that licenses trusting
SQS across the whole corpus and its history. If correlation is weak, the weights in §5 are
re-tuned and history is re-scored.

**Anti-fooling guardrails** (so the proxy can't drift from reality):
- *Discriminating power* — a metric that scores the same for known-good and known-bad skills
  is dropped.
- *Deltas over absolutes* — a skill's SQS change across **its own versions** is the primary
  tracking signal; it controls for domain difficulty. Cross-skill absolute SQS is secondary.
- *Goodhart guard* — the per-dimension vector is always reported, never just the headline.
- *Periodic re-calibration* — re-run a small fresh eval sample on a schedule; if correlation
  decays, re-tune.

---

## 3. Scope of SQS: intrinsic and version-local

SQS is built **only** from signals that are intrinsic to a single version of a skill, so it is
comparable across git history. **Maintenance health** (STALE / NEVER_BUMPED from
`check-versions`) is *time-relative* — an old snapshot that was correct when committed should
not score as "low quality" today — so it is reported as a separate **operational flag at HEAD
only** and carries **0 weight in SQS**. This keeps the longitudinal trend honest.

Discipline is auto-detected, **distillation-first** (matching dev-skill's precedence):
`metadata.json.discipline` if present, else by structure — rule files with `impact`
frontmatter ⇒ distillation; `scripts/` ⇒ composition; `*-tree.md` or `references/queries/`
⇒ investigation; `assets/templates/*.template` ⇒ extraction; none of the above ⇒
**guidance** (a prose skill — see Layer B below). The `guidance` discipline was added in the
calibration re-tune: grading prose skills as broken distillation rule-packs was SQS's single
worst bias (calibration showed prose skills can carry the *highest* functional value).

---

## 4. Dimensions and metrics

Each metric yields a sub-score in **[0, 1]**. Dimension score = mean of its metrics (some
weighted). All regexes are case-insensitive unless noted.

### Layer A — Universal (all disciplines)

**A1. Discoverability** *(Anthropic: name/description triggering)*
- `desc_valid` — present and ≤1024 chars (1/0).
- `desc_packed` — length scaled: ≥250 chars → 1.0; 150–250 → 0.7; 80–150 → 0.4; <80 → 0.1.
- `has_trigger` — matches `use (this skill )?when|should be used when|when (writing|building|...)` (1/0).
- `third_person` — does **not** open with "I "/"You "; mentions "This skill" (1/0).
- `negative_scope` — declares boundaries: `does not|doesn't cover|not for|use \w+ (skill )?instead|rather than` (1/0).
- `name_valid` — kebab-case, 1–64 chars, no edge/double hyphens, matches dir (1/0).

**A2. Context economy** *(Anthropic: progressive disclosure, lean SKILL.md)*
- `line_band` — SKILL.md lines: 80–200 → 1.0; 200–350 → 0.7; 350–500 → 0.4; >500 → 0; <40 → 0.5.
- `progressive_disclosure` — detail is offloaded: has `references/` (≥3 rule files) or `scripts/` or `assets/templates/` (1/0).
- `body_focus` — SKILL.md is navigation, not a data dump: body word count ≤ ~1500 → 1.0, scaled down beyond.

**A3. Structural integrity** *(skills-ref + QUALITY_CHECKLIST)*
- `skills_ref_pass` — name + description + ≤500-line rules pass (1/0).
- `metadata_complete` — `metadata.json` present with `version`, `discipline`, `abstract`, non-empty `references` (graded fraction).
- `refs_consistent` — every Quick-Reference slug has a matching `references/<slug>.md` (1/0; n/a → 1).
- `agents_md` — `AGENTS.md` present (curated weighted higher); 1/0.5/0.

**A4. Instructional calibration** *(Anthropic: state rule + why; no vague hedging/fluff)*
- `low_vagueness` — density of `consider|might( want)?|perhaps|maybe|probably|potentially|try to` per 1k words; 0 → 1.0, scaled down.
- `no_fluff` — count of `amazing|revolutionary|blazing|seamless|cutting-edge|game-?changer`; 0 → 1.0.
- `has_rationale` — fraction of rule files carrying a non-empty `impactDescription` / explicit "why" (distillation); for other disciplines, presence of rationale text.

### Layer B — Discipline-specific

**distillation** *(QUALITY_CHECKLIST + distillation RUBRIC)*
- `rule_count_band` — count of `references/*.md` excluding `_*.md`: 40–60 → 1.0; 30–40 or 60–70 → 0.7; 20–30 → 0.4; else lower.
- `impact_calibration` — CRITICAL share of rules ≤30% → 1.0; rises toward 0 as inflation grows; penalty if any category has 0 rules.
- `quantified_impact` — fraction of `impactDescription` matching quantification (`\d+\s*[×x%]|\bO\(|ms\b|reduces|prevents|avoids|\d+-\d+`); target >80%.
- `pair_coverage` — fraction of rule files containing both `**Incorrect` and `**Correct`.
- `annotation_desc` — fraction of Incorrect/Correct annotations with parenthetical text `**Incorrect (…)`.
- `codefence_lang` — fraction of ``` fences that declare a language.
- `generic_name_avoid` — count of `\b(foo|bar|baz|qux)\b` in code blocks; 0 → 1.0.

**composition** *(composition RUBRIC)*
- `script_syntax` — fraction of scripts passing syntax check (`bash -n` for sh; node `--check`; `python -m py_compile`).
- `strict_mode` — fraction of shell scripts with `set -euo pipefail` (or equivalent).
- `input_validation` — fraction of scripts that validate args before use (heuristic: `$#`, `[ -z`, usage/exit).
- `guardrails` — destructive ops (`rm -rf|git push|curl .*-X (POST|PUT|DELETE)|DROP `) are guarded by confirmation/dry-run, OR none exist (1/0).
- `dryrun_doc` — SKILL.md or a script mentions dry-run/--dry-run/preview (1/0).

**investigation** *(investigation RUBRIC)*
- `tree_present` — `*-tree.md` or `references/queries/` exists.
- `no_dead_ends` — heuristic: tree leaves end in an action verb (`fix|escalate|dismiss|restart|roll ?back|check`), no `TODO`/empty leaves.
- `measurable_criteria` — branch lines contain comparison/threshold markers (`>|<|=|\d`).
- `query_valid` — query files have header comments + pass syntax check where checkable.

**extraction** *(extraction RUBRIC)*
- `template_present` — `assets/templates/*` exists.
- `params_documented` — placeholders (`{name}` etc.) are documented in conventions/README.
- `convention_rationale` — `conventions.md` (or equivalent) gives "why" per convention.
- `no_hardcoded` — templates parameterize instance-specific values (heuristic: presence of placeholders, low count of literal paths).

**guidance** *(prose skills — added in calibration re-tune)*
- `has_structure` — SKILL.md/refs organized with multiple `##` headings.
- `actionable` — contains concrete steps/checklists or imperative instructions.
- `has_rationale` — explains *why* (because / so that / trade-off).
- `depth` — body right-sized (≈400–4000 words; thin or bloated penalized).
- *Limitation:* a refactoring/topic skill that *should* be a rule pack but is written as prose
  will score well here. SQS cannot make the "should-be-restructured" call — the rubric layer
  does (see `calibration/correlation.md`, the `rust-refactor` case).

---

## 5. Weights and the SQS formula

Weights are **initial priors**, tuned by calibration (§2). They are intentionally explicit and
adjustable. Layer A = 55, Layer B = 45 (sum 100).

| Dimension | Weight |
|-----------|-------:|
| A1 Discoverability | 15 |
| A2 Context economy | 12 |
| A3 Structural integrity | 18 |
| A4 Instructional calibration | 10 |
| **Layer B (discipline composite)** | **45** |

```
SQS = 100 × ( 0.15·A1 + 0.12·A2 + 0.18·A3 + 0.10·A4 + 0.45·B )
```

where each `Ai` and `B` ∈ [0,1]. `B` is the weighted mean of the active discipline's metrics
(equal weights within a discipline initially; see scorer for exact sub-weights).

**Verdict bands** (aligned with dev-skill SHIP/NEEDS-WORK/REJECT):

| SQS | Verdict |
|-----|---------|
| ≥ 75 | **SHIP** |
| 50–74 | **NEEDS-WORK** |
| < 50 | **REJECT** |

A skill that fails a **hard** `skills-ref` rule (bad name, description >1024, >500 lines) is
capped at NEEDS-WORK regardless of other dimensions — structure is a gate, not a tradeoff.

---

## 6. Outputs

- `score-skill.mjs <dir>` → JSON: `{ skill, discipline, metrics{…}, dimensions{A1..B}, sqs, verdict, hard_fails[] }`
- `score-all.mjs` → `quality/snapshot.json` (HEAD, all skills) + maintenance flags from check-versions.
- `score-history.mjs` → `quality/history.json` (per-skill SQS trajectory per commit + monthly /
  per-discipline / curated-vs-experimental aggregates).
- `quality/baseline.json` — frozen snapshot; the anchor future deltas are measured against.

Re-running on an unchanged tree must reproduce `snapshot.json` byte-for-byte (determinism).
