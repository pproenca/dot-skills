---
name: openai-codex-rust-patterns
description: OpenAI Codex Rust coding patterns distilled from the codex-rs workspace. Use this skill whenever writing, reviewing, or refactoring Rust code — especially for async agents, CLI tools, sandboxing, Ratatui TUIs, JSON-RPC protocols, tokio-based services, or any codebase that needs defensive panic discipline. Trigger even when the user does not explicitly mention Codex, because the patterns generalize to any production Rust workspace. Covers async cancellation, error enum design, process sandboxing, Cargo workspace architecture, wiremock-based fakes, insta snapshot testing, OpenTelemetry tracing, and Ratatui rendering.
---

# OpenAI Codex Rust Best Practices

Distilled from [`openai/codex`](https://github.com/openai/codex) `codex-rs/` — a 72-crate, 1,418-file Rust workspace that ships the Codex CLI coding agent. Contains 60 rules across 10 categories, each citing the exact file in codex-rs where the pattern lives, so you can write Rust the way its top contributors (Michael Bolin, jif-oai, Ahmed Ibrahim, Eric Traut, Pavel Krymets) actually ship it.

## When to Apply

Reference these guidelines when:

- Writing or reviewing async Rust code that spawns tokio tasks, owns cancellation tokens, or manages long-lived background workers.
- Designing error enums, `Result` flows, retry loops, or layer boundaries in a library or service.
- Building a CLI tool that spawns subprocesses, enforces sandboxing, or runs LLM-generated code safely.
- Architecting a Cargo workspace with more than ~5 crates, deciding what to split out, and how to manage shared dependencies.
- Adding tests to a Rust codebase where existing tests are inline `mod tests { ... }` blocks and scaling is becoming painful.
- Implementing a JSON-RPC or custom wire protocol with serde — especially one that must evolve without breaking clients.
- Wiring OpenTelemetry traces, logs, or metrics into a service that has privacy constraints around PII.
- Building a Ratatui-based TUI that streams LLM output, handles paste bursts, or manages raw-mode terminal state.
- Hardening a binary against debugger attach, LD_PRELOAD, or environment-variable tampering.
- Any time you find yourself reaching for `.unwrap()`, `anyhow::Result<()>`, or `#[cfg(feature = "test")]` — this skill explains what codex does instead.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Defensive Coding & Panic Discipline | CRITICAL | `defensive-` |
| 2 | Error Handling & Result Discipline | CRITICAL | `errors-` |
| 3 | Async, Concurrency & Cancellation | HIGH | `async-` |
| 4 | Sandboxing & Process Isolation | HIGH | `sandbox-` |
| 5 | Type Design & Invariants | HIGH | `types-` |
| 6 | Testing Architecture | MEDIUM-HIGH | `testing-` |
| 7 | Protocol & Serde Design | MEDIUM-HIGH | `proto-` |
| 8 | Workspace & Crate Organization | MEDIUM | `workspace-` |
| 9 | Observability & Tracing | MEDIUM | `otel-` |
| 10 | TUI (Ratatui) Rendering | MEDIUM | `tui-` |

## Quick Reference

### 1. Defensive Coding & Panic Discipline (CRITICAL)

- [`defensive-deny-unwrap-workspace-wide`](references/defensive-deny-unwrap-workspace-wide.md) — Deny unwrap and expect at the workspace level, opt in locally.
- [`defensive-debug-assert-with-early-return`](references/defensive-debug-assert-with-early-return.md) — Use debug_assert(false) with a safe fallback on unreachable branches.
- [`defensive-banned-interpreter-prefixes`](references/defensive-banned-interpreter-prefixes.md) — Avoid learning allowlist rules for general-purpose interpreters.
- [`defensive-head-tail-output-buffer`](references/defensive-head-tail-output-buffer.md) — Cap subprocess output with a head-and-tail ring buffer.
- [`defensive-io-drain-timeout-grandchildren`](references/defensive-io-drain-timeout-grandchildren.md) — Time out the I/O drain task separately from the child process.
- [`defensive-canonicalize-approval-cache-key`](references/defensive-canonicalize-approval-cache-key.md) — Canonicalize shell wrappers before hashing approval keys.
- [`defensive-refuse-to-run-unsandboxed`](references/defensive-refuse-to-run-unsandboxed.md) — Refuse to run when the sandbox cannot enforce the requested policy.

### 2. Error Handling & Result Discipline (CRITICAL)

- [`errors-exhaustive-retryable-match`](references/errors-exhaustive-retryable-match.md) — Classify retryable errors with an exhaustive match on every variant.
- [`errors-transient-permanent-type-split`](references/errors-transient-permanent-type-split.md) — Encode transient vs permanent outcomes as two enum variants.
- [`errors-carry-retry-delay-in-variant`](references/errors-carry-retry-delay-in-variant.md) — Carry the server-requested retry delay inside the error variant.
- [`errors-boundary-error-translator`](references/errors-boundary-error-translator.md) — Translate errors at the layer boundary in a single function.
- [`errors-struct-display-payload`](references/errors-struct-display-payload.md) — Put display-relevant error state in a struct, not a preformatted string.
- [`errors-tool-call-respond-vs-fatal`](references/errors-tool-call-respond-vs-fatal.md) — Split tool errors into respond-to-model and fatal variants.
- [`errors-io-error-with-context-struct`](references/errors-io-error-with-context-struct.md) — Wrap io::Error in a struct with a context field instead of anyhow.

### 3. Async, Concurrency & Cancellation (HIGH)

- [`async-abort-on-drop-handle`](references/async-abort-on-drop-handle.md) — Use Arc<AbortOnDropHandle> so dropped owners auto-cancel tasks.
- [`async-graceful-then-forceful-cancel`](references/async-graceful-then-forceful-cancel.md) — Cancel cooperatively first, then abort after a grace deadline.
- [`async-biased-select-for-cancellation`](references/async-biased-select-for-cancellation.md) — Use biased select to make cancellation always win race ties.
- [`async-bounded-vs-unbounded-channel-split`](references/async-bounded-vs-unbounded-channel-split.md) — Bound the submission channel but leave the event channel unbounded.
- [`async-child-cancellation-tokens`](references/async-child-cancellation-tokens.md) — Give spawned sub-tasks child tokens, not clones of the parent.
- [`async-shared-boxfuture-joinhandle`](references/async-shared-boxfuture-joinhandle.md) — Wrap a background JoinHandle in Shared<BoxFuture> for multi-waiter joins.

### 4. Sandboxing & Process Isolation (HIGH)

- [`sandbox-shared-policy-data-model`](references/sandbox-shared-policy-data-model.md) — Keep sandbox policy as shared data, not per-platform code.
- [`sandbox-staged-restrictions-re-exec`](references/sandbox-staged-restrictions-re-exec.md) — Stage incompatible restrictions by re-executing the same binary.
- [`sandbox-argv0-multiplex-binary`](references/sandbox-argv0-multiplex-binary.md) — Multiplex helper binaries via argv[0] and symlinks.
- [`sandbox-dev-null-first-missing-mount`](references/sandbox-dev-null-first-missing-mount.md) — Mount /dev/null over the first missing path to block mkdir escapes.
- [`sandbox-three-layer-network-isolation`](references/sandbox-three-layer-network-isolation.md) — Stack env vars, seccomp, and namespaces for network isolation.
- [`sandbox-env-clear-pre-exec`](references/sandbox-env-clear-pre-exec.md) — Clear the env and tether children via pre_exec before every spawn.

### 5. Type Design & Invariants (HIGH)

- [`types-thread-local-raii-serde`](references/types-thread-local-raii-serde.md) — Pass deserializer context via a thread-local RAII guard.
- [`types-dyn-safe-adapter-trait`](references/types-dyn-safe-adapter-trait.md) — Pair an ergonomic trait with a private dyn-safe adapter trait.
- [`types-try-from-newtype-validation`](references/types-try-from-newtype-validation.md) — Use serde try_from on a newtype to run validation on every parse.
- [`types-full-reference-hierarchy`](references/types-full-reference-hierarchy.md) — Implement Borrow, AsRef, and Deref on every public ID newtype.
- [`types-non-exhaustive-public-enums`](references/types-non-exhaustive-public-enums.md) — Mark every public wire-level enum non_exhaustive from the start.
- [`types-unknown-variant-forward-compat`](references/types-unknown-variant-forward-compat.md) — Preserve unrecognized values in an Unknown variant.

### 6. Testing Architecture (MEDIUM-HIGH)

- [`testing-path-attribute-sibling-tests`](references/testing-path-attribute-sibling-tests.md) — Attach tests as sibling files via #[path] instead of inline mod tests.
- [`testing-wiremock-sse-fakes`](references/testing-wiremock-sse-fakes.md) — Fake the network with wiremock and small SSE event constructors.
- [`testing-atomic-bool-test-opt-in`](references/testing-atomic-bool-test-opt-in.md) — Gate test-only behavior with an AtomicBool, not a cargo feature.
- [`testing-config-closure-builder`](references/testing-config-closure-builder.md) — Configure test fixtures with a closure builder.
- [`testing-insta-snapshot-tui-rendering`](references/testing-insta-snapshot-tui-rendering.md) — Snapshot terminal rendering with insta for stable UI diffs.
- [`testing-paused-runtime-advance`](references/testing-paused-runtime-advance.md) — Use start_paused and advance to make timing-dependent tests deterministic.

### 7. Protocol & Serde Design (MEDIUM-HIGH)

- [`proto-internally-tagged-rpc-dispatch`](references/proto-internally-tagged-rpc-dispatch.md) — Dispatch JSON-RPC by an internally tagged enum with a macro.
- [`proto-double-option-tri-state`](references/proto-double-option-tri-state.md) — Use Option<Option<T>> to distinguish absent, null, and set.
- [`proto-rename-alias-wire-migration`](references/proto-rename-alias-wire-migration.md) — Pair rename and alias to migrate wire names without breaking clients.
- [`proto-experimental-runtime-gate`](references/proto-experimental-runtime-gate.md) — Gate experimental fields by runtime presence, not capability flags.
- [`proto-sse-idle-timeout-terminator`](references/proto-sse-idle-timeout-terminator.md) — Treat SSE streams as idle-timeout with required terminator.
- [`proto-internal-vs-wire-error-split`](references/proto-internal-vs-wire-error-split.md) — Split internal error enums from wire error enums.

### 8. Workspace & Crate Organization (MEDIUM)

- [`workspace-ban-per-crate-features`](references/workspace-ban-per-crate-features.md) — Avoid per-crate features; use target-cfg or separate crates instead.
- [`workspace-single-source-dependencies`](references/workspace-single-source-dependencies.md) — Declare every dependency version once in workspace.dependencies.
- [`workspace-layered-transport-api-core`](references/workspace-layered-transport-api-core.md) — Stack HTTP layers as transport, api, and core crates.
- [`workspace-test-support-as-member-crates`](references/workspace-test-support-as-member-crates.md) — Register shared test helpers as workspace member crates.
- [`workspace-utils-microcrate-fanout`](references/workspace-utils-microcrate-fanout.md) — Place shared utilities in single-purpose microcrates under utils/.
- [`workspace-lint-config-package`](references/workspace-lint-config-package.md) — Encode policy in workspace.lints and clippy.toml.

### 9. Observability & Tracing (MEDIUM)

- [`otel-log-only-vs-trace-safe-targets`](references/otel-log-only-vs-trace-safe-targets.md) — Route PII to log-only targets and keep traces cardinality-safe.
- [`otel-field-empty-then-record`](references/otel-field-empty-then-record.md) — Declare span fields as field::Empty, then record them when known.
- [`otel-layered-subscribers-env-filter`](references/otel-layered-subscribers-env-filter.md) — Build per-layer EnvFilter instances with boxed fmt layers.
- [`otel-w3c-traceparent-propagation`](references/otel-w3c-traceparent-propagation.md) — Propagate W3C traceparent via env vars, JSON-RPC, and HTTP headers.
- [`otel-instrument-at-trace-level`](references/otel-instrument-at-trace-level.md) — Default #[instrument] to trace level, reserve info for network calls.

### 10. TUI (Ratatui) Rendering (MEDIUM)

- [`tui-two-gear-hysteresis-chunking`](references/tui-two-gear-hysteresis-chunking.md) — Replace fixed throttles with hysteresis-gated smooth and catch-up modes.
- [`tui-schedule-frame-coalescer`](references/tui-schedule-frame-coalescer.md) — Coalesce redraws through a FrameRequester actor and rate limiter.
- [`tui-drop-guard-panic-hook-chain`](references/tui-drop-guard-panic-hook-chain.md) — Restore terminal state via a Drop guard and a chained panic hook.
- [`tui-paste-burst-state-machine`](references/tui-paste-burst-state-machine.md) — Detect unbracketed paste bursts via a character timing state machine.
- [`tui-event-broker-pause-resume`](references/tui-event-broker-pause-resume.md) — Pause the event stream by dropping it before a subprocess handoff.

## How to Use

Read individual reference files for detailed explanations and code examples cited from `codex-rs/`:

- [Section definitions](references/_sections.md) — Category structure, impact levels, and prefixes
- [AGENTS.md](AGENTS.md) — Auto-generated navigation document compiling every rule

Each rule file contains:

- Imperative title matching its frontmatter
- 2–4 sentence explanation of the WHY
- **Incorrect** example showing the naive approach
- **Correct** example from codex-rs with the file path cited

## Reference Files

| File | Description |
|------|-------------|
| [AGENTS.md](AGENTS.md) | Auto-built TOC document compiling every rule |
| [README.md](README.md) | Skill repository docs — contribution, structure, commands |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [gotchas.md](gotchas.md) | Failure points discovered while applying these rules |
| [metadata.json](metadata.json) | Version, discipline, references to codex-rs |
