# dot-skills Quality Report

_Generated from `09c66fa67` · 158 skills · metrics: [METRICS.md](METRICS.md) · credibility: [calibration/correlation.md](calibration/correlation.md)_

## TL;DR

- **Current mean SQS 90.3** (median 91.7). Verdicts: 156 SHIP, 2 NEEDS-WORK.
- **The corpus is structurally mature and improving slowly.** Monthly mean SQS: 26-01 90.2 → 26-02 91.1 → 26-03 89.5 → 26-04 89.3 → 26-05 90.3. A dip in Mar–Apr coincides with bulk experimental additions; May recovers.
- **SQS measures structure, NOT usefulness.** Calibration found SQS↔functional-lift ≈ −0.5: the highest-SQS sampled skill (`react`, 95.7) added **0%** over a no-skill baseline, while two low-SQS prose skills added **+50–75%**. Read SQS as an authoring/regression signal only — see [calibration](calibration/correlation.md).
- **Content bugs are common even in high-SQS skills** — the rubric review found a real, fixable defect in ~8 of 12 sampled skills (e.g. a `jq --slurpfile` crash, a `Justfile` detection bug, an API misname). Static scoring cannot see these.

## What we measure (and why no single number suffices)

| Question | Instrument | Cost | Coverage |
|----------|-----------|------|----------|
| Follows authoring best practices? Structure regressed? | **SQS** (deterministic) | $0, instant | every skill, every commit |
| Content correct / current / non-contradictory? | **Rubric review** | moderate | periodic sample |
| Actually beats a no-skill baseline? | **FQD** (baseline-differential) | high | the skills that matter most |

SQS is a weighted composite over **Discoverability, Context economy, Structural integrity, Instructional calibration** (universal) plus a **discipline** dimension (distillation / composition / investigation / extraction / guidance). Full definitions and source citations in [METRICS.md](METRICS.md).

## Current state (HEAD)

### By tier

| Tier | Count | Mean SQS |
|------|------:|---------:|
| experimental | 120 | 89.6 |
| curated | 38 | 92.4 |

### By discipline

| Discipline | Count | Mean SQS |
|------------|------:|---------:|
| distillation | 123 | 91.9 |
| composition | 20 | 84.4 |
| guidance | 9 | 85.3 |
| extraction | 6 | 84.3 |

### Top 10 by SQS

| SQS | Skill | Discipline | Tier |
|----:|-------|-----------|------|
| 98.2 | tdd | distillation | curated |
| 97.7 | typescript | distillation | curated |
| 97.5 | code-map-visualization | distillation | experimental |
| 97.4 | react-hook-form | distillation | curated |
| 97.3 | react-optimise | distillation | experimental |
| 97.1 | geohash-spatial-code-maps | distillation | experimental |
| 97.0 | io-bound-data-processing | distillation | experimental |
| 96.7 | typescript-advanced-patterns | distillation | experimental |
| 96.6 | react-refactor | distillation | experimental |
| 96.5 | marketplace-recsys-feature-engineering | distillation | experimental |

### Bottom 10 by SQS (where to focus)

| SQS | Verdict | Skill | Discipline | Tier |
|----:|---------|-------|-----------|------|
| 51.0 | NEEDS-WORK | human-copywrite | distillation | experimental |
| 70.4 | NEEDS-WORK | dev-rfc | composition | experimental |
| 75.0 | SHIP | effect-ts | distillation | experimental |
| 75.2 | SHIP | rails-application-ui-blocks | composition | experimental |
| 76.4 | SHIP | bug-review | composition | experimental |
| 76.4 | SHIP | dx-harness | composition | experimental |
| 77.5 | SHIP | ios-xcode | distillation | experimental |
| 77.6 | SHIP | drizzle-sqlite-scaffold | extraction | experimental |
| 77.6 | SHIP | expo-ios-screen-scaffolder | extraction | experimental |
| 78.7 | SHIP | complexity-optimizer | composition | experimental |

## Quality over time (longitudinal)

Scored against the actual tree at each month-end (skills later removed still count).

| Month | Skills | Mean SQS | SHIP | NEEDS-WORK | REJECT |
|-------|------:|---------:|----:|----------:|------:|
| 2026-01 | 56 | 90.2 | 52 | 4 | 0 |
| 2026-02 | 93 | 91.1 | 92 | 1 | 0 |
| 2026-03 | 105 | 89.5 | 101 | 4 | 0 |
| 2026-04 | 113 | 89.3 | 107 | 6 | 0 |
| 2026-05 | 158 | 90.3 | 156 | 2 | 0 |

### Biggest improvers (per-skill SQS delta across its own versions)

| Δ SQS | Skill | First → Last | Versions |
|------:|-------|-------------|---------:|
| +23.5 | code-map-visualization | 74.0 → 97.5 | 2 |
| +23.0 | io-bound-data-processing | 74.0 → 97.0 | 3 |
| +22.5 | marketplace-recsys-feature-engineering | 74.0 → 96.5 | 6 |
| +22.4 | django-recommender-search-backend-patterns | 74.0 → 96.4 | 3 |
| +21.8 | ruby-optimise | 74.0 → 95.8 | 7 |
| +21.6 | rails-testing | 74.0 → 95.6 | 8 |
| +21.6 | storybook | 74.0 → 95.6 | 4 |
| +21.2 | rails-dev | 74.0 → 95.2 | 8 |

_Pattern: many jumps are description-length fixes lifting a skill off the structural hard-fail cap (74) — the #1 authoring failure in this repo._

### Biggest decliners

| Δ SQS | Skill | First → Last | Versions |
|------:|-------|-------------|---------:|
| -2.2 | swift-data | 90.7 → 88.5 | 14 |
| -2.1 | ios-ui-refactor | 89.1 → 87.0 | 10 |
| -1.7 | nextjs | 95.5 → 93.8 | 8 |
| -1.2 | audio-voice-recovery | 89.7 → 88.5 | 8 |
| -1.1 | react-refactor | 97.7 → 96.6 | 7 |
| -1.1 | shadcn | 93.3 → 92.2 | 8 |

## Calibration — is SQS trustworthy?

12 stratified skills were independently checked with the dev-skill rubric; 3 got a full baseline-differential functional eval. Full analysis: [calibration/correlation.md](calibration/correlation.md).

| Skill | SQS | SQS verdict | Rubric | FQD |
|-------|----:|------------|--------|----:|
| harness-engineering | 80.1 | SHIP | SHIP | +50% |
| humanize | 83.0 | SHIP | NEEDS-WORK | – |
| think | 83.1 | SHIP | NEEDS-WORK | +75% |
| rust-refactor | 90.8 | SHIP | NEEDS-WORK | – |
| effect-ts | 75.0 | SHIP | NEEDS-WORK | – |
| bug-review | 76.4 | SHIP | NEEDS-WORK | – |
| dx-harness | 76.4 | SHIP | NEEDS-WORK | – |
| nuqs-codemod-runner | 86.5 | SHIP | NEEDS-WORK | – |
| react-19-component-scaffolder | 86.8 | SHIP | NEEDS-WORK | – |
| zod | 89.2 | SHIP | SHIP | – |
| react | 95.7 | SHIP | NEEDS-WORK | +0% |
| tdd | 98.2 | SHIP | SHIP | – |

**Conclusion.** SQS is a reliable, reproducible signal for **structural/authoring quality and regressions** — and honestly only that. It does not predict whether a skill helps (FQD) or whether its content is correct (rubric). Track all three; never read a high SQS as proof a skill is good or useful.

## Recommended actions

1. **Fix the rubric-flagged content bugs** in sampled skills (nuqs `--slurpfile` crash, dx-harness `Justfile` detection, effect-ts API misname, react example contradiction).
2. **Triage the bottom-10 SQS skills** for structural gaps (description packing, progressive disclosure, missing rule structure).
3. **Run FQD on high-traffic skills** before assuming they add value — `react`-class skills may add little over a strong baseline.
4. **Adopt the baseline** (`baseline.json`) and re-run the scorer on every change to catch regressions (see [README.md](README.md)).

