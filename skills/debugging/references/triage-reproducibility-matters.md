---
title: Factor Reproducibility into Triage
impact: MEDIUM
impactDescription: prevents wasted investigation time
tags: triage, reproducibility, investigation, feasibility
---

## Factor Reproducibility into Triage

Bugs that cannot be reliably reproduced are harder to fix and verify. Factor reproducibility into priority: sometimes a lower-severity reproducible bug should be fixed before a higher-severity intermittent one.

**Incorrect (ignoring reproducibility in triage):**

```markdown
## Sprint Planning:

Task 1: Fix critical race condition
- Severity: CRITICAL
- Reproducibility: Random, ~1% of requests
- Estimate: Unknown (can't reliably reproduce)

Task 2: Fix broken pagination
- Severity: MEDIUM
- Reproducibility: 100% reproducible
- Estimate: 2 hours

Decision: Work on critical race condition first
Result: 2 weeks spent trying to reproduce, still unfixed
```

**Correct (reproducibility-aware triage):**

```markdown
## Sprint Planning:

Task 1: Fix critical race condition
- Severity: CRITICAL
- Reproducibility: Random, ~1% of requests, no reproduction steps
- Investigation needed: Add logging to capture conditions
- Action: Add instrumentation this sprint, fix next sprint

Task 2: Fix broken pagination
- Severity: MEDIUM
- Reproducibility: 100% reproducible
- Estimate: 2 hours
- Action: Fix this sprint (quick win)

Task 3: Review race condition logs
- Prerequisite: Task 1 logging deployed for 1 week
- Goal: Establish reliable reproduction steps
- Then: Schedule fix with accurate estimate
```

**Reproducibility levels:**
| Level | Description | Triage Action |
|-------|-------------|---------------|
| 100% | Always happens with specific steps | Estimate and fix |
| Sometimes | Happens under certain conditions | Document conditions, then fix |
| Rarely | Cannot reliably reproduce | Add instrumentation first |
| Once | Happened once, never again | Monitor, don't prioritize |

Reference: [BirdEatsBug - Bug Triage Process](https://birdeatsbug.com/blog/bug-triage-process)
