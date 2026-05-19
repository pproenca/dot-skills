---
title: Surface Blockers Explicitly — Never Substitute a Proxy for the Asked Claim
impact: HIGH
impactDescription: prevents approximate evidence from being mislabeled as the asked claim
tags: evidence, blockers, honesty, proxies
---

## Surface Blockers Explicitly — Never Substitute a Proxy for the Asked Claim

When the asked verification cannot be performed — because the data isn't available, the surface can't run, or the path requires something Codex doesn't have — the right action is to surface the blocker, not to silently substitute a proxy. A proxy can support a claim, raise confidence, or partially validate the result, but it must be labeled as a proxy, not reported as the asked claim. This is what distinguishes a Goal report you can trust from one that looks plausible but is wrong in places that matter. The same principle applies inside long iterations: when one check fails or can't run, name it as a gap, not as a substitution. Honest labels are the difference between an audit and a marketing claim.

**Incorrect (proxy substituted for the asked claim):**

```text
[Asked: "verified by reproducing the published Heston reference price"]

Codex: "Heston reference price reproduced. Goal complete."

[What actually happened: the original training paths, seeds, and
checkpoints were unavailable. Codex trained a new policy with new
seeds and reported the new policy's price as the reproduction.]
```

```text
# A close approximation was reported as exact reproduction.
# The asked claim ("reproduce the published price") was not verified —
# a new training run with different seeds was, and it was relabeled
# as the asked claim. The report cannot be trusted.
```

**Correct (proxy clearly labeled; original claim marked blocked):**

```text
[Asked: "verified by reproducing the published Heston reference price"]

Codex: "Reproduction status:
- Original published price: NOT exactly reproduced. The paper does not
  provide the random seeds, training paths, or saved checkpoints needed
  for exact replay. Status: blocked.
- Approximate reproduction (new training run, new seeds): produced a
  Heston reference price within 0.6% of the published value across
  three independent seeds.

Recommendation: treat this as a close approximate reproduction
supporting the claim, not an exact replay. Goal state: partial
completion with one blocked dimension."
```

```text
# The asked claim is marked blocked with the reason.
# The supporting evidence is clearly labeled as approximate.
# The reader can judge what the result means.
```

Reference: [Using Goals in Codex — Using Goals for complex research](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
