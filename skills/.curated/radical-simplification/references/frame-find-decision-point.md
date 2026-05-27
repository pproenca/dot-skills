---
title: Find the decision the answer must change
tags: frame, hamming, decision
---

## Find the decision the answer must change

Hamming's question — "What is the most important problem in your field, and why aren't you working on it?" — has a sibling for any concrete request: **what decision will be made differently depending on the answer?** If no decision changes, the work is theatre. If the decision is "ship vs. don't ship in this release", the real question may be different from the literal one.

```text
Literal question: "How long will this migration take?"

Decisions the answer feeds:
  1. Whether to ship in the May release (cut date: 3 weeks).
  2. Whether to staff a second engineer.
  3. Whether to communicate downtime to customers.

If the answer is "6 weeks", decision 1 is "no" — and the real question
becomes "Is there a degraded subset we can ship in 3 weeks that
unblocks the customer ask?" Answering the literal question alone
leaves the team with "6 weeks" and no path forward.
```

Phrase the answer in terms of the decision: "If you can move the cut date by 2 weeks, yes; otherwise we ship phases 1 and 2 only and finish 3 in June." That is what the asker actually needed.

Reference: [Hamming — You and Your Research](https://www.cs.virginia.edu/~robins/YouAndYourResearch.html)
