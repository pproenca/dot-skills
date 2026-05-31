---
title: {Imperative, decision-oriented rule title}
tags: {prefix}, {concept1}, {concept2}
# Optional — performance rules only. Omit for correctness/idiom rules:
# impact: {CRITICAL|HIGH|MEDIUM|LOW}
# impactDescription: {quantified outcome, e.g. "O(n)→O(1)"}
---

## {Same text as title}

{1–3 sentences naming the wrong default a competent Go developer would otherwise reach for, and the concrete consequence in a process-management CLI — orphaned children, leaked goroutines, skipped cleanup, unbounded shutdown, etc.}

```go
{Canonical, copy-pasteable example with realistic names — never foo/bar.
 Show the correct pattern; keep it focused on the one decision the rule settles.}
```

{Optional: an Incorrect/Correct foil ONLY if the wrong way is a genuine, common trap.
 Keep the diff minimal so the contrast is the lesson. Link related rules with
 [title](other-rule.md) when a task spans categories.}

Reference: [{source title}]({url})
