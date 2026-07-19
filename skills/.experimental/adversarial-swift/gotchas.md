# Gotchas

Failure points discovered while running this gate. Append-only, with dates.

### Gate proven both ways at v1.0.0 creation (dry run, 2026-07-16)

Two blind reviewers per artifact, identical composed prompt, Swift 6.3.3 / nonisolated default actor isolation:

- **Planted-violation artifact** (single-file Swift module, 15 planted violations spanning all 7 categories): both reviewers returned overall FAIL and unanimously failed all 15 planted rules (`conc-resume-continuation-every-path`, `conc-check-cancellation-in-loops`, `conc-async-let-for-independent-awaits`, `prop-computed-over-stored-derived`, `prop-private-set-internal-mutation`, `err-preserve-underlying-error`, `err-callsite-location-default-args`, `enum-unknown-default-external-enums`, `enum-caseiterable-over-hand-lists`, `api-memberwise-init-via-extension`, `api-optionset-over-boolean-rows`, `coll-reduce-into-accumulators`, `coll-count-where-over-filter-count`, `flow-branch-assigned-let`, `flow-validating-untrusted-bytes`), each with file:line evidence and a concrete fix. Zero contested rules.
- **Clean equivalent artifact**: both reviewers returned overall PASS with per-rule evidence. Zero contested rules.
- Near-miss traps behaved as designed: two `final` classes passed `api-final-or-private-classes`, a correct `default:` dictionary upsert passed `coll-dictionary-default-subscript`, and neither reviewer credited `try? await Task.sleep` as a cancellation check.
- The sharpened `prop-private-set-internal-mutation` carve-out resolved identically for both clean-side reviewers (a settable property with no invariant-enforcing methods judged out of the rule's trigger, not N/A-by-external-write), confirming the fail-closed rewording.
- `conc-concurrent-offload-under-mainactor-default` went N/A on both artifacts as constructed (nonisolated default isolation in the stack facts) — it has not yet been exercised FAIL-side in a MainActor-default target.

(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

Added: 2026-07-16

### Source-fidelity guards the reviewer must not override (pre-recorded at v1.0.0 creation)

The gate's rules are grounded in source material that deliberately diverges from common community lore in ways a reviewer trained on that lore may try to re-impose:

- **Untyped `throws` is NOT a violation.** The source material keeps untyped throws as the recommended default for general-purpose code; there is no typed-throws rule in this gate, and flagging `throws` without `throws(E)` is out of scope.
- **Explicit `_ =` discards are NOT a violation.** There is no `@discardableResult` rule — many styles prefer the explicit discard at call sites.
- **`@concurrent` is the primary offloading remedy** for `conc-concurrent-offload-under-mainactor-default` on Swift 6.2+; `nonisolated` and moving the work to a non-main actor are accepted equivalents, not preferred ones.
- **`zip(collection.indices, collection)` is the in-language remedy** for `flow-zip-indices-over-enumerated` — `indexed()` requires the swift-algorithms package and is never required for a PASS.

Added: 2026-07-16

### Source-verbatim examples are frozen — accept the validator's generic-name warnings

The code examples are kept exactly as the source material presents them (user-directed). `validate-skill.js` warns about generic identifiers in `err-result-get-over-manual-switch.md` (`processData()`) and `prop-defer-observed-init-assignments.md` (`MyClass`) — those are the source's own identifiers. Do NOT rename them to silence the warnings on a future evolve; the warnings are accepted deliberately. The one permitted deviation class is compile necessity (e.g. `prop-discard-self-in-consuming-cleanup.md` stores an `Int` id where the source used a `String`, because `discard self` requires trivially destroyable storage) — always note such deviations in the rule's surrounding text or here.

Added: 2026-07-16

### try? await Task.sleep does not propagate cancellation

`conc-check-cancellation-in-loops` explicitly names `try? await Task.sleep(...)` as NOT counting as cancellation propagation — `try?` swallows the `CancellationError`, so a loop whose only suspension point is a `try?`-wrapped sleep runs to completion after `cancel()`. The reviewer repeatedly wants to credit the sleep as a cancellation check; the rule text forbids it. (Carried over from the v0.1.x gate, where this split reviewers until pre-recorded — recorded under the earlier two-reviewer protocol.)

Added: 2026-07-16

### Rules pre-flagged as decidability-risk at creation

Three rules were flagged at planning as decidability risks (a single reviewer could plausibly land on either verdict) and included by user decision with tightened carve-outs. If a dry run or live review produces a verdict that flips across re-reviews of an unchanged target for one of them, or a human overrides the verdict after reading the evidence, sharpen the rule text (or demote the rule to a distillation sibling) rather than overriding the gate:

- `api-final-or-private-classes` — needs whole-file-set subclass knowledge; test-double base classes (visible Mock/Spy/Stub subclass) and pre-existing classes the diff merely touches are N/A by rule text.
- `err-warning-directive-for-pending-work` — verdict depends on build-config stack facts (warnings-as-errors CI, SwiftLint todo rule); absent those facts, only diff-introduced TODOs on stubbed/incomplete behavior fail.
- `flow-take-for-one-shot-optionals` — consequence is explicit single-use intent, not a crash; only the adjacent read-then-nil teardown shape fails, and toolchains before `Optional.take()` (Swift 6.0, SE-0437) are N/A.
- `prop-private-set-internal-mutation` — an external write site is NOT settable-API evidence when the type's own methods guard the invariant that write could break; the skill-reviewer flagged the earlier carve-out wording ("external write sites exist → N/A") as self-neutralizing exactly when the bypass is most visible. The rule text now says the bypassing write is the violation made manifest — fail closed.

Added: 2026-07-16

### Field failure: gates run as cleanup drivers on a moving target (maddie-ios, July 2026)

Three Codex sessions invoked this gate family with "do full cleanup for any slop and
complexity, do it aggressively" — verdict-only gates used as rewrite engines. Result:
blind reviews were dispatched, discarded when the code changed underneath them, and
re-dispatched, with **zero verdicts rendered across ~11 hours**; the diff grew to 33
files; a parallel "cleanup" subagent deleted the vendored skill trees mid-run; and the
repo's micro-commit discipline collapsed into 90–162-file opaque sweeps. The SKILL.md
dispatch preconditions (frozen target manifest, verdicts-not-cleanup, immutable rule
snapshot, gate-status record) were added in direct response — do not weaken them on
evolve.

Added: 2026-07-17
