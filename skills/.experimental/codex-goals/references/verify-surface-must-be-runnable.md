---
title: The Verification Surface Must Be Something Codex Can Actually Run or Inspect
impact: CRITICAL
impactDescription: prevents Goals that look verifiable on paper but can't be checked in practice
tags: verify, runnable, executable, realism
---

## The Verification Surface Must Be Something Codex Can Actually Run or Inspect

A verification surface is only useful if Codex can reach it. Naming a benchmark Codex can't run, a test suite that requires production credentials Codex doesn't have, or a manual QA process gates the Goal on something outside the loop — Codex will either fake it, skip it, or report blocked. Before activating a Goal, confirm that every named surface is locally runnable (or that the Goal explicitly accepts proxies). If the real verification needs human or external infrastructure, either provide a local proxy in the Goal text or scope the Goal to what Codex can verify and call out the rest as a separate manual step. A Goal whose evidence is out of reach is a Goal that completes on belief.

**Incorrect (surface Codex cannot reach):**

```text
/goal Cut homepage TTFB below 200 ms, verified by the synthetic
monitoring dashboard at synthetics.internal/homepage
```

```text
# Codex cannot open the synthetics dashboard. It can change code but
# cannot observe the metric. It will either pretend it can ("based on
# the changes, TTFB should be below 200 ms") or declare blocked.
# Either way, completion is decoupled from the real surface.
```

**Correct (locally runnable surface + named proxy):**

```text
/goal Cut homepage TTFB below 200 ms, verified by:
(1) the local benchmark `npm run bench:homepage` reporting TTFB < 200 ms
across 50 runs (this is our agreed proxy for the synthetics dashboard
since Codex cannot access synthetics.internal),
(2) the e2e suite (`npm test:e2e`) passing.
After the Goal completes, the user will confirm by checking the
synthetics dashboard manually.
```

```text
# Both surfaces are runnable in Codex's environment.
# The relationship to the unreachable surface is stated explicitly,
# not silently substituted. Manual confirmation is scoped out of the Goal.
```

Reference: [Using Goals in Codex — What changes when a Goal is active](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
