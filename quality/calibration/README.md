# Calibration Sample & Method

The deterministic **SQS** (see `../METRICS.md`) is a cheap proxy. It is only trustworthy to
the degree it tracks **ground-truth quality**. This directory holds the evidence that licenses
(or challenges) trusting SQS across the whole corpus and its history.

## Two independent ground-truth signals

1. **Rubric verdict** — the dev-skill `skill-reviewer` agent applies the discipline-specific
   `RUBRIC.md` (claim verification, contradictions, reference authority, code realism) and
   returns **SHIP / NEEDS-WORK / REJECT**. Run on all 12 sampled skills. Tests *intrinsic
   correctness*. (Read-only; moderate cost.)

2. **Functional Quality Delta (FQD)** — Anthropic's baseline-differential method: run a
   representative task **with** and **without** the skill, grade gap-targeted assertions, and
   take `pass_rate(with) − pass_rate(without)`. Run on a focused 3-skill anchor. Tests
   *outcome improvement* — the only signal that proves a skill actually helps. (Heavy; spent
   only where it most challenges SQS.)

We then report **SQS↔rubric agreement** (n=12) and **SQS↔FQD rank correlation** (n=3 anchor)
in `correlation.md`. If SQS disagrees with the ground truth, the weights in `METRICS.md` are
re-tuned and history is re-scored before shipping.

## The 12-skill stratified sample

Chosen to span every SQS band, all disciplines, both tiers, and — deliberately — the cases
where SQS is *most likely wrong* (high-craft prose/guidance skills that score low; a known
regression).

| Skill | Tier | Discipline | SQS | Band | Why included | Functional eval? |
|-------|------|-----------|----:|------|--------------|:---:|
| harness-engineering | exp | distillation* | 48.3 | REJECT | Only REJECT; high-craft *guidance* skill — prime "proxy under-rates prose" test | ✅ |
| humanize | exp | distillation* | 54.9 | NEEDS-WORK | Pure prose skill, no rule pack | |
| think | curated | distillation* | 58.4 | NEEDS-WORK | Excellent description, prose ideation — prime under-rate test | ✅ |
| rust-refactor | curated | distillation | 62.7 | NEEDS-WORK | Biggest historical decliner (−25.4) — is the drop real? | |
| effect-ts | exp | distillation | 75.0 | SHIP- | Borderline SHIP threshold | |
| bug-review | exp | composition | 76.4 | SHIP- | Multi-pass workflow composition | |
| dx-harness | exp | composition | 76.4 | SHIP- | Audit/scaffold/verify composition | |
| nuqs-codemod-runner | curated | composition | 86.5 | SHIP- | Script-driven codemod composition | |
| react-19-component-scaffolder | curated | extraction | 86.8 | SHIP- | Template scaffolder (extraction) | |
| zod | curated | distillation | 89.2 | SHIP- | Solid curated rule pack | |
| react | curated | distillation | 95.7 | SHIP+ | Top-tier rule pack (positive control) | ✅ |
| tdd | curated | distillation | 98.2 | SHIP+ | Highest scorer | |

`*` = defaulted to distillation by detection but is really a prose/guidance skill — these are
the cases the calibration is built to scrutinize.

**Functional anchor (FQD):** `react` (high), `think` (low prose), `harness-engineering`
(lowest). These three span SQS 48→96 and concentrate on whether SQS under-rates non-rule
skills — the highest-value question for the proxy's validity.

## Outputs
- `results.json` — per-skill `{ sqs, rubric_verdict, rubric_findings, fqd? }`
- `correlation.md` — SQS↔rubric agreement, SQS↔FQD correlation, and the credibility verdict.
