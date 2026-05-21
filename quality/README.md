# Skill Quality Measurement & Tracking

A standalone, reproducible system for measuring `dot-skills` quality and tracking it over time.
Grounded in [Anthropic's Agent Skills guidance](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills),
the dev-skill discipline rubrics, and `skills-ref`.

## The headline you must internalize

**SQS measures structural / authoring quality, not usefulness.** Calibration proved this:
the highest-SQS sampled skill added **0%** over a no-skill baseline, while two low-SQS prose
skills added **+50–75%** (SQS↔functional-lift ≈ −0.5). Three different questions need three
different instruments:

| Question | Instrument | Cost |
|----------|-----------|------|
| Follows authoring best practices? Did structure regress? | **SQS** — `score-all.mjs` | $0, instant |
| Is the content correct / current? | **Rubric review** — dev-skill `skill-reviewer` | moderate |
| Does it beat a no-skill baseline? | **FQD** — baseline-differential eval (`/dev-skill:eval`) | high |

Details: [METRICS.md](METRICS.md) (definitions) · [calibration/correlation.md](calibration/correlation.md) (credibility).

## Files

| File | What |
|------|------|
| `METRICS.md` | Metric definitions, source citations, weights, SQS formula, verdict bands |
| `snapshot.json` | Current-HEAD scores for every skill (regenerate any time) |
| `history.json` | Per-skill SQS trajectories + monthly / discipline / tier aggregates |
| `baseline.json` | **Frozen** snapshot — the anchor future deltas are measured against |
| `REPORT.md` | Findings writeup (Obsidian-friendly) |
| `dashboard.html` | Self-contained visual dashboard (open in a browser) |
| `calibration/` | The 12-skill calibration: sample, rubric+FQD results, correlation verdict |

Scorers live in `../scripts/quality/` (`score.mjs` library + CLIs).

## Commands

```bash
# Score one skill (debug)
node scripts/quality/score-skill.mjs skills/.curated/react --pretty

# Re-score all skills at HEAD -> quality/snapshot.json
node scripts/quality/score-all.mjs

# Replay full git history -> quality/history.json  (~45s)
node scripts/quality/score-history.mjs

# Rebuild REPORT.md + dashboard.html from the JSON
node scripts/quality/report.mjs

# Track drift vs the frozen baseline (exits 1 on regression)
node scripts/quality/track.mjs --rescore
```

## Tracking workflow (going forward)

1. After authoring/evolving skills, run `node scripts/quality/track.mjs --rescore`.
2. It flags any skill whose SQS dropped > 2.0 or whose verdict downgraded vs `baseline.json`.
3. Investigate regressions (usually: description over 1024 chars → the structural hard-fail
   cap of 74; or lost rule structure).
4. Periodically refresh the baseline: `cp quality/snapshot.json quality/baseline.json`, and
   re-run `score-history.mjs` + `report.mjs` to refresh the trend and dashboard.
5. **Re-calibrate** when the consuming model changes or quarterly: re-run a small rubric +
   FQD sample (see `calibration/README.md`) and confirm SQS still behaves as documented.

## Determinism

`score-all.mjs` on an unchanged tree reproduces `snapshot.json` byte-for-byte (no time, no
randomness). Scores are comparable across commits because SQS is intrinsic and version-local
(maintenance staleness is reported separately, with 0 weight — see METRICS.md §3).
