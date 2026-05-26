---
title: Probe limit cases — zero, infinity, empty, identity
tags: reduce, limits, edge-cases
---

## Probe limit cases — zero, infinity, empty, identity

Physicists check what happens at the boundary because the boundary is where the structure of a system becomes legible. The same trick works on designs and code: ask what happens at 0, ∞, the empty input, and the identity case **before** writing the general logic. The agent that skips this consistently ships designs that degrade in unexpected ways at the extremes — exactly where users hit them.

```text
Designing a rate limiter: permits per second.

  permits = 0   → blocks forever? returns immediately? errors? Pick one,
                  on purpose, and write it in the spec.

  permits = ∞   → does the implementation even take this path, or does it
                  collapse into "no limiter"? If it should, prove it.

  window = 0    → division by zero, or "instant refill"? Different choices
                  imply different code paths.

  duration = 0  → identity case: same start and end. Most aggregation bugs
                  live here.

  empty input   → empty output, or error, or sentinel? An empty list of
                  permits to issue is a different shape than "0 permits".
```

These four probes catch most "the design works on the example, then production input is weirder" bugs without running the code. If the limit-case answer is "we just won't hit that," write down why — that assumption is now part of the design.

Reference: [Pólya — How to Solve It, "Specialization" heuristic (Princeton UP, 1945)](https://en.wikipedia.org/wiki/How_to_Solve_It)
