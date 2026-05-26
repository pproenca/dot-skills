# Rust

**Version 1.1.0**  
OpenAI  
May 2026

---

## Abstract

Distilled Rust coding patterns extracted from openai/codex (codex-rs, 2,008 Rust files across 119 workspace crates), refreshed against main at commit 8a94430 (2026-05-25). Captures the end-to-end craft of its top contributors — Michael Bolin, jif-oai, Ahmed Ibrahim, Eric Traut, and others — across defensive coding, error discipline, async cancellation, sandboxing, secret handling and process hardening, type invariants, testing, protocol design, workspace organization, observability, and Ratatui TUI architecture. Each rule cites the exact codex-rs file and shows a minimal incorrect/correct pair so the reader can internalize the judgment, not just the syntax.

---

## Table of Contents

1. [Defensive Coding & Panic Discipline](references/_sections.md#1-defensive-coding-&-panic-discipline) — **CRITICAL**
   - 1.1 [Avoid learning allowlist rules for general-purpose interpreters](references/defensive-banned-interpreter-prefixes.md) — CRITICAL (prevents approval amendments from green-lighting arbitrary interpreter flags)
   - 1.2 [Canonicalize shell wrappers before hashing approval keys](references/defensive-canonicalize-approval-cache-key.md) — HIGH (avoids re-prompting users for logically identical commands and blocks cache collisions between wrapped scripts)
   - 1.3 [Cap subprocess output with a head-and-tail ring buffer](references/defensive-head-tail-output-buffer.md) — CRITICAL (prevents OOM on runaway output and preserves the most informative tail lines)
   - 1.4 [Deny unwrap and expect at the workspace level](references/defensive-deny-unwrap-workspace-wide.md) — CRITICAL (prevents unreviewed panic sites across a 75-crate workspace)
   - 1.5 [Load untrusted plugins fault-isolated and sanitize their model-facing text](references/defensive-fault-isolate-plugin-load.md) — HIGH (one broken or hostile plugin can't fail startup or inject the model's prompt)
   - 1.6 [Recover a poisoned lock with into_inner instead of unwrapping it](references/defensive-recover-poisoned-lock.md) — CRITICAL (stops one thread's panic from cascading a poisoned lock into every other holder)
   - 1.7 [Refuse to run when the sandbox cannot enforce the policy](references/defensive-refuse-to-run-unsandboxed.md) — CRITICAL (prevents silent privilege erosion when the sandbox backend lacks the required primitive)
   - 1.8 [Register a drain timeout to escape grandchild pipe leaks](references/defensive-io-drain-timeout-grandchildren.md) — CRITICAL (prevents the whole agent from hanging when a killed child leaves grandchildren holding stdout)
   - 1.9 [Use debug_assert with safe fallback on unreachable branches](references/defensive-debug-assert-with-early-return.md) — CRITICAL (prevents release-mode panics while keeping bugs loud in tests)
2. [Error Handling & Result Discipline](references/_sections.md#2-error-handling-&-result-discipline) — **CRITICAL**
   - 2.1 [Carry the server-requested retry delay inside the error variant](references/errors-carry-retry-delay-in-variant.md) — HIGH (eliminates out-of-band retry-after plumbing through the error flow)
   - 2.2 [Classify retryable errors via an exhaustive match](references/errors-exhaustive-retryable-match.md) — CRITICAL (prevents silent retry drift when a new error variant is added)
   - 2.3 [Encode transient vs permanent failures as two enum variants](references/errors-transient-permanent-type-split.md) — CRITICAL (prevents boolean retry-policy checks that drift out of sync with the error source)
   - 2.4 [Split tool errors into respond-to-model and fatal variants](references/errors-tool-call-respond-vs-fatal.md) — HIGH (eliminates downcasting every failure to decide whether the LLM can recover)
   - 2.5 [Store display-relevant error state in a struct, not a string](references/errors-struct-display-payload.md) — HIGH (enables plan-specific tests to assert against error state instead of fragile English sentences)
   - 2.6 [Translate errors at the layer boundary in one function](references/errors-boundary-error-translator.md) — CRITICAL (eliminates reqwest error status inspection scattered across business logic)
   - 2.7 [Wrap io::Error in a struct with a context field](references/errors-io-error-with-context-struct.md) — MEDIUM-HIGH (enables PartialEq tests against IoError without dragging anyhow into a library crate)
3. [Async, Concurrency & Cancellation](references/_sections.md#3-async,-concurrency-&-cancellation) — **HIGH**
   - 3.1 [Bound submissions but leave events unbounded](references/async-bounded-vs-unbounded-channel-split.md) — HIGH (avoids session loop stalls on slow consumers while rate-limiting misbehaving producers)
   - 3.2 [Cancel cooperatively first, then abort after a grace deadline](references/async-graceful-then-forceful-cancel.md) — HIGH (prevents unbounded shutdown latency while still letting well-behaved tasks clean up)
   - 3.3 [Give spawned sub-tasks child tokens, not parent clones](references/async-child-cancellation-tokens.md) — HIGH (prevents cancelling one child from cascading into all siblings)
   - 3.4 [Store JoinHandles as AbortOnDropHandle so Drop cancels them](references/async-abort-on-drop-handle.md) — HIGH (prevents leaked background tasks when a session or turn is cleared)
   - 3.5 [Use biased select when cancellation must win ties](references/async-biased-select-for-cancellation.md) — HIGH (prevents rare approval races where cancel and response fire in the same poll)
   - 3.6 [Wrap background JoinHandle in Shared BoxFuture for multi-waiter joins](references/async-shared-boxfuture-joinhandle.md) — MEDIUM-HIGH (enables multiple independent callers to await the same background task completion)
4. [Sandboxing & Process Isolation](references/_sections.md#4-sandboxing-&-process-isolation) — **HIGH**
   - 4.1 [Clear the env and tether children via pre_exec before every spawn](references/sandbox-env-clear-pre-exec.md) — HIGH (prevents LD_PRELOAD inheritance and orphaned grandchildren after a parent kill)
   - 4.2 [Keep sandbox policy as shared data, not per-platform code](references/sandbox-shared-policy-data-model.md) — HIGH (prevents three independently-drifting notions of "workspace-write")
   - 4.3 [Mount /dev/null over the first missing path component](references/sandbox-dev-null-first-missing-mount.md) — HIGH (prevents mkdir-and-write escapes through non-existent protected paths)
   - 4.4 [Multiplex helper binaries via argv[0] and symlinks](references/sandbox-argv0-multiplex-binary.md) — MEDIUM-HIGH (eliminates TOCTOU risk and packaging overhead of shipping multiple binaries)
   - 4.5 [Resolve hostnames and reject private IPs before allowing egress](references/sandbox-resolve-before-allow-dns-rebinding.md) — HIGH (defeats DNS-rebinding bypass of a string-based egress allowlist)
   - 4.6 [Stack env, syscalls, and namespace for network isolation](references/sandbox-three-layer-network-isolation.md) — HIGH (prevents network escape through any single uncooperative tool)
   - 4.7 [Stage incompatible restrictions via re-executing the same binary](references/sandbox-staged-restrictions-re-exec.md) — HIGH (eliminates the "seccomp breaks bwrap" conflict via two-stage application)
5. [Secrets & Process Hardening](references/_sections.md#5-secrets-&-process-hardening) — **HIGH**
   - 5.1 [Harden a secret-handling process before main() runs, and fail closed](references/secrets-ctor-pre-main-hardening.md) — HIGH (closes the core-dump / ptrace / LD_PRELOAD window before any arg parsing or allocation)
   - 5.2 [Read a secret into a zeroized stack buffer, then mlock it — never through stdin()](references/secrets-read-into-locked-buffer.md) — HIGH (guarantees exactly one in-memory copy of an API key, locked out of swap and core dumps)
   - 5.3 [Write a manual Debug impl that elides credentials instead of deriving it](references/secrets-manual-debug-elide.md) — HIGH (stops tokens and credential providers leaking into {:?} and tracing output)
6. [Type Design & Invariants](references/_sections.md#6-type-design-&-invariants) — **HIGH**
   - 6.1 [Mark public wire-level enums non_exhaustive from the start](references/types-non-exhaustive-public-enums.md) — HIGH (prevents breaking external match statements when a variant is added)
   - 6.2 [Pass deserializer context via a thread-local RAII guard](references/types-thread-local-raii-serde.md) — HIGH (enables serde to run path resolution without DeserializeSeed plumbing)
   - 6.3 [Preserve unrecognized wire values in an Unknown variant](references/types-unknown-variant-forward-compat.md) — HIGH (prevents older readers from crashing on configs written by newer versions)
   - 6.4 [Use serde try_from on newtypes to run validation on every parse](references/types-try-from-newtype-validation.md) — HIGH (eliminates forgotten validation calls at construction sites via parse-don't-validate)
7. [Testing Architecture](references/_sections.md#7-testing-architecture) — **MEDIUM-HIGH**
   - 7.1 [Attach tests as sibling files via a path attribute](references/testing-path-attribute-sibling-tests.md) — MEDIUM-HIGH (prevents 5000-line modules where implementation hides inside a mile-long test body)
   - 7.2 [Enable test-only behavior via AtomicBool, not a cargo feature](references/testing-atomic-bool-test-opt-in.md) — MEDIUM-HIGH (avoids doubling the build matrix while keeping deterministic IDs for tests)
   - 7.3 [Snapshot terminal rendering with insta for stable TUI diffs](references/testing-insta-snapshot-tui-rendering.md) — MEDIUM-HIGH (enables 1400 reviewable terminal snapshots that diff cleanly in PRs)
   - 7.4 [Use start_paused and advance for deterministic timing tests](references/testing-paused-runtime-advance.md) — MEDIUM-HIGH (eliminates wall-clock flakes from timing-dependent tests)
   - 7.5 [Use wiremock and small SSE constructors instead of mocking HTTP traits](references/testing-wiremock-sse-fakes.md) — MEDIUM-HIGH (enables serialization, retry, and streaming coverage on every test)
8. [Protocol & Serde Design](references/_sections.md#8-protocol-&-serde-design) — **MEDIUM-HIGH**
   - 8.1 [Dispatch JSON-RPC via an internally tagged enum with a macro](references/proto-internally-tagged-rpc-dispatch.md) — MEDIUM-HIGH (eliminates hand-rolled method dispatch that drifts from typed param validation)
   - 8.2 [Gate experimental fields by runtime presence, not capability flags](references/proto-experimental-runtime-gate.md) — MEDIUM-HIGH (enables adding unstable fields to stable methods without duplicating the request type)
   - 8.3 [Keep removed feature flags as parseable no-op tombstones](references/proto-removed-feature-tombstone.md) — MEDIUM-HIGH (lets old and new configs round-trip across versions without parse failures)
   - 8.4 [Pair rename and alias to migrate wire names without breaking clients](references/proto-rename-alias-wire-migration.md) — MEDIUM-HIGH (prevents flag-day migrations by keeping old wire names as read-only aliases)
   - 8.5 [Split internal error enums from wire error enums](references/proto-internal-vs-wire-error-split.md) — MEDIUM-HIGH (enables internal error refactors without breaking the stable wire contract)
   - 8.6 [Treat SSE streams as idle-timeout with a required terminator](references/proto-sse-idle-timeout-terminator.md) — MEDIUM-HIGH (prevents long turns from being killed by wall-clock deadlines and silent half-closes)
   - 8.7 [Use double-nested Options to distinguish absent, null, and set](references/proto-double-option-tri-state.md) — MEDIUM-HIGH (eliminates invented FieldAction enums for PATCH-like update APIs)
9. [Workspace & Crate Organization](references/_sections.md#9-workspace-&-crate-organization) — **MEDIUM**
   - 9.1 [Avoid per-crate features; use target-cfg or split crates](references/workspace-ban-per-crate-features.md) — MEDIUM (prevents combinatorial build matrix explosion across a ~100-crate workspace)
   - 9.2 [Encode design policy in workspace.lints and clippy.toml](references/workspace-lint-config-package.md) — MEDIUM (prevents policy drift from review-only conventions)
   - 9.3 [Place shared utilities in single-purpose microcrates under utils/](references/workspace-utils-microcrate-fanout.md) — MEDIUM (enables parallel compilation and minimal dependency graphs per concern)
   - 9.4 [Register shared test helpers as workspace member crates](references/workspace-test-support-as-member-crates.md) — MEDIUM (enables cross-crate test helper reuse without path-attribute hacks)
   - 9.5 [Stack HTTP layers as transport, api, and core crates](references/workspace-layered-transport-api-core.md) — MEDIUM (enables client crate reuse and prevents business logic from pulling in retries)
10. [Observability & Tracing](references/_sections.md#10-observability-&-tracing) — **MEDIUM**
   - 10.1 [Build per-layer EnvFilter instances with boxed fmt layers](references/otel-layered-subscribers-env-filter.md) — MEDIUM (enables independently-filtered sinks without per-layer generic divergence)
   - 10.2 [Declare span fields as field Empty then record when known](references/otel-field-empty-then-record.md) — MEDIUM (reduces duplicate child spans by keeping one parent span renamed at the apm)
   - 10.3 [Default instrument spans to trace level, reserve info for network calls](references/otel-instrument-at-trace-level.md) — MEDIUM (enables free internal instrumentation that costs zero in normal operation)
   - 10.4 [Propagate W3C traceparent via env, RPC, and HTTP headers](references/otel-w3c-traceparent-propagation.md) — MEDIUM (enables distributed tracing from CI runner through codex to backend APIs)
   - 10.5 [Route PII to log-only targets and keep traces cardinality-safe](references/otel-log-only-vs-trace-safe-targets.md) — MEDIUM (prevents PII from leaking into wider-access trace backends)
11. [TUI (Ratatui) Rendering](references/_sections.md#11-tui-(ratatui)-rendering) — **MEDIUM**
   - 11.1 [Coalesce redraws through a FrameRequester actor](references/tui-schedule-frame-coalescer.md) — MEDIUM (reduces redraw count when multiple producers request frames in the same tick)
   - 11.2 [Detect unbracketed paste bursts via a character timing state machine](references/tui-paste-burst-state-machine.md) — MEDIUM (prevents mid-paste shortcut key interpretation on terminals without bracketed paste)
   - 11.3 [Pause the event stream by dropping it before subprocess handoff](references/tui-event-broker-pause-resume.md) — MEDIUM (prevents stdin race with child processes after handing off the terminal)
   - 11.4 [Replace fixed throttles with hysteresis-gated smooth and catch-up modes](references/tui-two-gear-hysteresis-chunking.md) — MEDIUM (prevents visible lag on bursts without sacrificing the typewriter cadence feel)
   - 11.5 [Restore terminal state via a Drop guard and chained panic hook](references/tui-drop-guard-panic-hook-chain.md) — MEDIUM (prevents wedged terminals that require manual `reset` after a panic)

---

## References

1. [https://github.com/openai/codex](https://github.com/openai/codex)
2. [https://github.com/openai/codex/tree/main/codex-rs](https://github.com/openai/codex/tree/main/codex-rs)
3. [https://github.com/openai/codex/blob/main/AGENTS.md](https://github.com/openai/codex/blob/main/AGENTS.md)
4. [https://developers.openai.com/codex](https://developers.openai.com/codex)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |