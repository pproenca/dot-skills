---
title: Restate the problem in your own words before solving
tags: frame, problem-definition, specification
---

## Restate the problem in your own words before solving

By default the agent paraphrases the prompt and starts solving, which silently locks in whatever the prompt encoded — including the parts that are wrong. A short restatement, surfaced back to the user before any code, exposes the unstated assumptions while they are still cheap to change.

```text
User: "Build a queue for failed webhook deliveries."

Restated before solving:
  - Each event must reach the receiver at least once, in original order,
    with at most 5 retry attempts over 24h.
  - "Failed" = HTTP 5xx or timeout; 4xx is permanent and goes to a DLQ.
  - Burst tolerance: 1000 events/sec, sustained 100/sec.
  - Out of scope: webhook signing, receiver auth, fan-out to multiple URLs.

  Does this match what you need? In particular, is "in original order"
  a real constraint, or can a later event overtake a stalled one?
```

Half the time, restating reveals that "order" was assumed but not needed, or that 4xx is also retryable, or that the real problem was duplicate deliveries — not failed ones. Solving the original prompt would have produced a correct answer to the wrong question.

Reference: [Lamport — State the Problem Before Describing the Solution (ACM SIGSOFT Software Engineering Notes, 1978)](https://www.microsoft.com/en-us/research/publication/state-the-problem-before-presenting-the-solution/)
