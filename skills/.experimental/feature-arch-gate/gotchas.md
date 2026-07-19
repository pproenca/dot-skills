# Gotchas

### Dry-run record — gate proven both ways (v0.1.0)
Violating fixture (central api/, cross-feature deep imports, global mixed store, N+1, wildcard barrel chain, mixed casing, central tests/): **unanimous FAIL**, 20+ rules failed by both reviewers with matching `file:line` evidence. Conforming fixture (two features, public APIs, key factories, per-feature error boundaries, app composition root): **unanimous PASS** (28 PASS / 5 N/A). Reaching unanimous PASS took three rounds — each earlier contest traced to a real fixture defect the reviewers correctly caught (see entries below), not to rule flakiness.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

### `struct-shared-layer` contests on unused generic-looking primitives in `shared/`
In the first dry run, a `shared/components/button.tsx` with zero consumers split the reviewers: one applied the rule's litmus test ("Do 2+ features use it today?") and failed it as speculative placement; the other passed it as "a generic UI primitive, the rule's own Correct example". The litmus test is the deciding evidence — the source rule explicitly forbids speculative placement, so *appearance of genericity does not exempt dead code*. The evidence descriptor in `references/_rule-evidence.md` now states this. If this rule's verdict ever flips across re-reviews of an unchanged target, quote the litmus test verbatim in the composed reviewer prompt.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

### Missing-structure rules split FAIL vs N/A when the structure is absent entirely
In the first dry run's failing artifact (which had no `src/app/` at all), `struct-app-layer` and `fcomp-error-boundaries` went CONTESTED: one reviewer failed them (route knowledge embedded in a feature, zero boundaries around crash-prone components), the other marked N/A ("no placement point exists to judge"). The reviewer prompt now states absence of a required structure is a FAIL when the concerns it must own are present, and N/A is reserved for genuinely absent subjects. Both contests still merged to FAIL overall (fail-closed), so the gate's verdict was unaffected — but the sharper guidance keeps per-rule verdicts stable.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

### The gate catches route-path duplication between app route table and feature builders
Round 2 contested `bound-feature-scoped-routing` on a target whose app route table hardcoded `'/users/:userId'` while the user feature's builder also owned that path. The stricter reviewer was right: the source rule's Correct example registers routes via the builder (`path: userRoutes.profile(':userId')`) precisely so the path string has one owner. When composing the reviewer prompt for targets with route builders, expect this to be judged — a literal in the route table that duplicates a feature builder's path is a FAIL, not style.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)
