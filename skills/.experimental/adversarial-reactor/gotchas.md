# Gotchas

Failure points discovered while running this gate. Append-only, with dates.

### Gate proven both ways at creation (dry run, 2026-07-16)

Two blind reviewers per artifact, identical composed prompt, Reactor ~> 1.0 stack with Ecto + sandbox-backed tests + Mimic:

- **Planted-violation artifact** (multi-file "Shipster" order-fulfillment app — order saga, catalog import, audit middleware, tests — violating all 28 rules): both reviewers returned overall FAIL and unanimously failed **all 28 rules**, each with file:line evidence and a flip-test fix. Zero contested rules. Both independently kept genuine-but-out-of-scope defects (a never-mounted middleware, a cross-checkout shared-stash race) in the `Out of scope` note without letting them affect verdicts.
- **Clean artifact, round 1**: both reviewers returned overall FAIL with the *identical* single finding — two steps whose `compensate` returns `:retry` mounted without `max_retries` (`retry-cap-max-retries`), same two locations, same fix. This was a genuine bug accidentally left in the "clean" artifact — the gate caught a real defect the author missed, with zero contested verdicts. Treat unanimous convergence on author-unintended findings as the strongest decidability evidence this dry run produced.
- **Clean artifact, round 2** (bug fixed): both reviewers returned overall PASS — 25 PASS + 3 N/A, zero contested. Carve-outs were claimed with citations, not asserted: the no-undo email step PASSed via the cited best-effort moduledoc naming its reconciler; the terminal-step and pure-inline-fn boundaries were applied identically by both reviewers.
- Convergence notes worth keeping: (1) one PASS vs N/A split occurred (`comp-compose-over-nested-run` — "top-level call sites pass" vs "no nesting occurs"); the merge table resolves it to PASS and it is not a decidability bug. (2) Both reviewers correctly ruled ExUnit's case-level `async: true` irrelevant to `conc-sandbox-tests-sync` — the rule judges the `Reactor.run` options, not the test case attribute. (3) Both ruled a one-shot aggregate call taking a list (`Inventory.reserve(id, items)`) is not `comp-map-over-enum-in-step` evidence — the rule needs per-item iteration inside the run body. (Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

Added: 2026-07-16

### Scope guards the reviewers must not override (pre-recorded at creation)

- This gate judges **Reactor orchestration semantics**, not general Elixir style or OTP runtime concerns. Supervision, PubSub, ETS, and backpressure belong to the sibling gate `adversarial-beam`; paradigm fit belongs to `adversarial-elixir` — reviewers must not import them here.
- **A side effect, for `saga-*` and `step-modules-for-side-effects`, is an externally-visible write** — database rows, payments, reservations, HTTP mutations, file writes, published messages. Reads, pure computation, and logging are not side effects; failing a read-only step for a missing `undo` is judging outside the rules.
- **Step verdicts follow the mounted module, not just the DSL block.** A `step :x, SomeModule` line with no inline `undo` is not evidence of a missing undo — `SomeModule` must be read first. Ruling FAIL without reading the mounted module is a protocol violation, not a strict review.
- **Shapes, not brands.** `Reactor.Middleware.Telemetry` and Mimic are canonical remedies, not requirements: a custom middleware emitting equivalent lifecycle events satisfies `obs-telemetry-middleware-over-logging`; any module-copying mock library motivates `step-modules-for-side-effects` equally. Their absence does not make those rules N/A when the problem shape is present.
- **`comp-compose-over-nested-run` carve-out is role-based:** an inner `Reactor.run` fired from a job worker, controller, or resume path is a new top-level workflow, not nesting — but the reviewer must cite the call site's role to claim it.
- **Every rule fails closed.** Carve-outs are claimed with the citation the rule specifies (the acceptable-loss statement, the size bound, the reduction, the downstream consumer) — asserted carve-outs without evidence do not excuse violations.

Added: 2026-07-16
