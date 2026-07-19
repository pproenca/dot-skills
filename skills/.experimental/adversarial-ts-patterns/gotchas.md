# Gotchas

### Dry-run proof — gate proven both ways (2026-07-11, v0.1.0)

Two fixtures, two blind reviewers each, per the review protocol:

- **Planted-violation fixture** (checkout feature with 9 planted violations across all 6 categories): both reviewers returned overall FAIL and flagged exactly the 9 planted rules (`state-union-over-boolean-flags`, `state-no-effect-chains`, `state-no-stored-derived-state`, `state-exhaustive-match-on-unions`, `create-no-getinstance-singleton`, `behave-no-single-method-class`, `layer-no-passthrough-repository`, `oo-no-static-only-class`, `oo-no-trivial-accessors`) — no false positives on the other 9 rules, zero contested verdicts.
- **Idiomatic fixture** (same feature written with a discriminated union, function strategies, direct query functions, module utilities): both reviewers returned overall PASS with per-rule evidence; N/A-vs-PASS splits only, which resolve to PASS.
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

### state-no-effect-chains vs state-no-stored-derived-state overlap on single-effect cascades

A handler-sets-state → one-effect-reacts-and-sets-more-state cascade is strictly one effect link, not the rule's canonical effect→effect chain. In the dry run both reviewers still FAILed it under the "chain reachable from one originating update" clause (and both also FAILed it under `state-no-stored-derived-state`, which covers the same evidence when the written value is pure derivation), so the verdict was stable — but if this rule's verdict ever flips across re-reviews of an unchanged target, the sharpening is: a single state→state effect is decided by `state-no-stored-derived-state`; `state-no-effect-chains` requires two or more effect links.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)
