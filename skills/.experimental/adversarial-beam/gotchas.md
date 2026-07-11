# Gotchas

Failure points discovered while running this gate. Append-only, with dates.

### Gate proven both ways at creation (dry run, 2026-07-11)

Two blind reviewers per artifact, identical composed prompt, Elixir ~> 1.18 stack with libcluster + Ecto + Oban + PubSub + telemetry:

- **Planted-violation artifact** (five-file "Pulse" market-data app — TCP feed, ledger, orders, billing — violating all 23 rules): both reviewers returned overall FAIL and unanimously failed **all 23 rules**, each with file:line evidence and a concrete fix. Zero contested rules. The fail-open rule fired correctly: both reviewers independently named the same GenStage producer → producer_consumer → consumer split for the three-hop push pipeline before FAILing `load-demand-driven-pipeline`.
- **Clean artifact, round 1**: both reviewers returned overall FAIL with the *identical* three findings — a PubSub subscription taken in `init` under top-level `:one_for_one` (`sup-strategy-matches-dependencies`), a cluster-shared ledger sequence enforced by a node-local name with libcluster present (`dist-node-local-is-not-cluster-wide`), and a Jason-decoded `sku` sub-binary stored uncopied into long-lived book state (`mech-copy-sub-binaries-into-state`). These were genuine bugs accidentally left in the "clean" artifact — the gate caught real defects the author missed, with zero contested verdicts. Treat unanimous convergence on author-unintended findings as the strongest decidability evidence this dry run produced.
- **Clean artifact, round 2** (three bugs fixed): both reviewers returned overall PASS — 22 PASS + 1 N/A (`state-persistent-term-is-read-optimized`, N/A vs N/A → N/A), zero contested. Carve-outs were claimed with citations, not asserted: the Book's restart-amnesia PASS cited the venue_seq-guarded latest-tick derivation rebuilt by the live stream; the per-node ledger sequence PASS cited the `(node(), seq)` keying and `max_seq(node())` rehydrate; the `:global` BillingRunner PASS cited both the `Pulse.Leases.acquire` stand-down AND the per-day idempotency keys.
- Convergence notes worth keeping: (1) both reviewers ruled that an `active: :once` socket re-armed only after a synchronous `push` returns satisfies `load-call-for-backpressure-on-ingest` — the kernel buffer is the bound; treat that shape as PASS. (2) Both ruled `send/2` into an assumed-cheap collector process is not ingest-edge evidence without visible nontrivial per-message work. (3) Both ruled `Date.utc_today()` inside an idempotency key is timestamp-as-data, not a duration subtraction.

Added: 2026-07-11

### Scope guards the reviewers must not override (pre-recorded at creation)

- This gate judges **runtime-semantics assumptions**, not general Elixir style or paradigm fit. Pipe taste, module layout, GenServer-per-entity questions, and OO-layering habits belong to the sibling gate `adversarial-elixir` — reviewers must not import them here.
- **`cast` is not banned.** `load-call-for-backpressure-on-ingest` fires only on the conjunction: externally-driven message rate AND nontrivial per-message work AND no bound anywhere on the path. A `cast` for a low-rate internal notification is not evidence of anything.
- **Exactly one rule fails open:** `load-demand-driven-pipeline` FAILs only when the reviewer names the demand-driven replacement (stage split or Broadway adapter). Every other rule fails closed — carve-outs must be claimed with the citation the rule specifies.
- **Shapes, not brands.** Oban/Broadway are canonical remedies, not requirements: an outbox table with a relay satisfies `evt-transactional-enqueue`; a hand-rolled demand/ack protocol satisfies `load-demand-driven-pipeline`. Conversely their absence does not make those rules N/A when the problem shape is present.
- **Telemetry scope is attach-side only.** `:telemetry.execute`/span emission is never a violation; only handler functions passed to `attach/attach_many` are judged.
- **Wall-clock as data is fine.** `mech-monotonic-time-for-durations` judges subtraction, not reads: persisted timestamps, display times, and cross-boundary business rules ("expire after 30 days" against `inserted_at`) are the rule's own carve-out.
- **Oban `unique` is enqueue-side only** — it dedupes insertion, not execution. Citing it as the idempotency guard for `evt-idempotent-consumers` is not a PASS; the `perform` body must be safe to re-run.
- **`dist-*` N/A axis is evidence-based:** the category is N/A only when clustering is demonstrably absent (no clustering dep/config, no `:global`/`:pg`). Any `:global` usage in the target activates it.

Added: 2026-07-11
