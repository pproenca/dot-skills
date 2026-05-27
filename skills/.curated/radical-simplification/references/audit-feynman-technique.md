---
title: Explain it as if to a beginner — gaps in explanation are gaps in understanding
tags: audit, feynman, explanation
---

## Explain it as if to a beginner — gaps in explanation are gaps in understanding

Feynman's diagnostic: try to explain the topic to a curious beginner who knows none of the vocabulary. The places where the explanation needs a hedge ("roughly", "sort of", "for our purposes") or a hand-wave are the places the explainer does not actually understand. The default failure is fluent-sounding shorthand that *looks* like understanding because the words are correct; the test is whether they can be unfolded.

```text
Agent writes: "We use eventual consistency for sessions because it
scales better."

Feynman expansion (forced, in beginner vocabulary):
  "When a user logs in on phone A, we write the session to one server.
   Other servers learn about it slowly — usually within 200ms but
   sometimes up to 5 seconds during heavy load.

   So if the user logs in on phone A and then opens the app on tablet B
   within 5 seconds, tablet B might see the old logged-out state and
   ask them to log in again.

   We accepted this because [reason] — and the reason has to be more
   than 'it scales better', because the cost is the user occasionally
   sees a stale login state, which is a real UX cost."

After expanding, the agent realises:
  - The 5s upper bound was a guess, not measured.
  - The actual reason was 'we didn't want to run a Redis cluster',
    not 'scales better' — and the alternative ('one Postgres write')
    would have scaled to the actual traffic too.

The expansion turned a fluent assertion into a list of falsifiable
claims, two of which were wrong.
```

A useful trigger: any time the agent writes "for performance", "because of scale", "for correctness", or "for reasons" — stop and unfold each into a sentence a non-expert could verify. Most of the time, two of the three claims dissolve.

Reference: [Goodstein — Feynman's Lost Lecture (Norton, 1996); the "I couldn't reduce it to the freshman level" anecdote about spin-½](https://en.wikipedia.org/wiki/Feynman%27s_Lost_Lecture)
