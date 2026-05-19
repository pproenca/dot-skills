---
title: Avoid the Three Common Goal Anti-Patterns — Keep-Going Wishes, Hidden Uncertainty, Overclaim on Proxy
impact: MEDIUM
impactDescription: prevents three common Goal failure modes that produce untrustworthy completions
tags: research, anti-patterns, failure-modes, overclaim
---

## Avoid the Three Common Goal Anti-Patterns — Keep-Going Wishes, Hidden Uncertainty, Overclaim on Proxy

Three patterns repeatedly produce Goals that look complete but are wrong in ways that matter. (1) Keep-going wishes: "continue until X is done" where X is undefined — there's no verifiable terminal condition, so Codex either spins or fakes completion. (2) Hidden uncertainty: a Goal text that doesn't acknowledge unavailable data or flaky surfaces, so Codex silently substitutes proxies and the user never learns the gaps. (3) Overclaim on proxy: an approximate or trained replacement is reported as the exact asked claim. Each of these is preventable by upgrading the Goal text up front. The pattern is consistent: when uncertainty exists, name it inside the Goal; when proxies are acceptable, define how they should be labeled; when "continue until X" is the goal, ensure X is verifiable.

**Incorrect (all three anti-patterns at once):**

```text
/goal Reproduce the paper's results and keep going until you've
confirmed everything works
```

```text
# (1) "Keep going until everything works" — no verifiable terminal.
# (2) Doesn't acknowledge that the paper may not provide all artifacts.
# (3) Doesn't define how proxies should be labeled — opens the door
#     to retraining with new seeds being reported as "confirmed".
```

**Correct (anti-patterns addressed inline):**

```text
/goal Audit the reproducibility of Buehler et al., "Deep Hedging"
against the available materials.

- Terminal condition: every headline claim has a labeled status entry
  (confirmed / approximate reconstruction / proxy support / blocked).
  The Goal is complete when the ledger is exhaustive, not when every
  claim is confirmed.
- Acknowledged uncertainty: the paper does not provide random seeds,
  training paths, TensorFlow graph state, optimizer state, or
  checkpoints. Claims that depend on those should be labeled "blocked"
  for exact reproduction; approximate reconstructions with new seeds
  are acceptable but must be labeled "approximate reconstruction".
- Proxy policy: a close numerical match, a rebuilt figure, or a
  retrained policy may be reported as support for a claim but never as
  the original asked claim. The status field must reflect what was
  actually produced.

If blocked or no defensible path remains for a claim, mark it blocked
and continue to the next claim — do not stop the Goal.
```

```text
# (1) Terminal is "ledger exhaustive", not "all confirmed" — verifiable.
# (2) Unavailable artifacts named up front; expected status is "blocked".
# (3) Proxy policy explicit — retrained ≠ original; labels are forced.
# A complete Goal under this contract may still report blocked claims;
# that's the truthful state, and the architecture supports it.
```

Reference: [Using Goals in Codex — When not to use Goals; Using Goals for complex research](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
