# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance** —
the runtime-architecture mistakes with the widest blast radius go first; the
verdict report's fix list follows this order.

This is a pass/fail review gate, not a performance skill, so there are no impact
tiers. Each rule names a wrong assumption about the BEAM's execution and delivery
model — assumptions the code compiles cleanly with and unit tests never expose —
and carries an **Evidence of violation** paragraph: the artifact evidence that
decides PASS/FAIL/N/A, with carve-outs that must be claimed with citable evidence
(fail closed otherwise).

---

## 1. Supervision & Failure Design (sup)

**Description:** Supervision trees written as boilerplate instead of as the
system's recovery plan. Restart strategies that ignore inter-child dependencies,
startup work that blocks the supervisor, durability parked in `terminate/2`
(which crashes and kills skip), state that silently evaporates on restart, and
tasks linked or orphaned against the caller's actual failure intent. The wrong
assumption: "the supervisor restarts it, so we recover." Restart only restores a
*known good state* — the tree must be shaped so that what restarts together
depends together, and anything not rebuildable in `init` must live somewhere
durable.

## 2. Backpressure & Overload (load)

**Description:** Pipelines with no way to say no. `cast` and bare `send` on
ingest paths (mailboxes are unbounded — the overflow policy is VM death),
hand-rolled multi-hop pipelines with no demand signal, call timeouts treated as
noise to silence with `:infinity` or to catch-and-retry against non-idempotent
servers, and unbounded `Task.async` fan-out sized by external input. The wrong
assumption: "the BEAM handles load." It handles *concurrency*; overload is a
protocol you must design, and backpressure only works when every hop propagates
it.

## 3. Event Delivery Semantics (evt)

**Description:** Event-driven designs that assume guarantees the transport never
made. `Phoenix.PubSub` is fire-and-forget at-most-once, so a broadcast must never
be the only carrier of a business fact; side-effect jobs enqueued outside the
transaction that creates the fact are lost or ghosted at the crash boundary; Oban
and Broadway deliver at-least-once, so consumers must be idempotent; the BEAM
orders signals only between one sender-receiver pair, so cross-source ordering
needs a sequence guard; `:telemetry` handlers run inline in the caller and detach
forever on the first raise; broadcast payloads persisted as authoritative
snapshots race each other stale.

## 4. Shared State & Consistency (state)

**Description:** Shared state placed against the grain of the runtime's
consistency tools. Lookup-then-write sequences on ETS and Registry that race
between the two atomic steps, hot read paths funneled through a single
GenServer mailbox that serializes every reader, and `:persistent_term.put` in
per-event code where each write triggers a global scan of every process. The
wrong assumption: carrying single-threaded intuitions ("I just checked, it's
still true") or database intuitions ("writes are cheap") onto ETS, Registry, and
persistent_term, each of which is atomic and cheap only along the axis it was
built for.

## 5. Distribution Reality (dist)

**Description:** Single-node constructs silently promoted to cluster-wide
guarantees. A `:global` singleton is not a lock — partitions run duplicates and
the default conflict resolver kills a random survivor on heal — so
correctness-critical singletons need fencing; `Registry`, ETS, and locally
registered names stop at the node boundary, so using them to enforce an
invariant phrased as "one per cluster" breaks the day a second node starts. The
whole category is N/A for applications that demonstrably never cluster.

## 6. Runtime Mechanics (mech)

**Description:** Misuse of the VM's clocks, binaries, and atom table.
Durations and deadlines diffed from wall-clock reads that NTP can jump, slices
of large external binaries stored in long-lived state where they pin the
multi-megabyte parent alive, and atoms minted from external input into a finite
table that is never garbage collected. Each is invisible in review and in tests,
and each has a one-line correct form (`System.monotonic_time/0`,
`:binary.copy/1`, `String.to_existing_atom/1`).
