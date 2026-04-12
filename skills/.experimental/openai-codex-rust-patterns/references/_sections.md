# Rule Categories

This document defines the category structure, impact levels, and file-name prefixes used by every rule in `references/`. Categories are ordered CRITICAL → LOW so the reader sees highest-impact patterns first.

## 1. Defensive Coding & Panic Discipline (defensive)

**Impact:** CRITICAL
**Description:** Patterns that prevent panics in production and turn "should never happen" into grepable tombstones. Codex cannot crash when a tool handler sees malformed input, a subprocess spawns a grandchild, or a sandbox backend cannot enforce the requested policy — so the defensive rules are load-bearing for service availability.

## 2. Error Handling & Result Discipline (errors)

**Impact:** CRITICAL
**Description:** Patterns that shape how `Result` and error enums flow through the system. Retry classification, transient-vs-permanent splits, layer-boundary translators, and struct-typed display payloads — the things that decide whether a user sees a clean message or a cryptic trace.

## 3. Async, Concurrency & Cancellation (async)

**Impact:** HIGH
**Description:** Tokio patterns for long-lived agents where tasks must clean up reliably, cancellation must win race ties, and channels must balance throughput against responsiveness. Covers Arc<AbortOnDropHandle>, CancellationToken discipline, and the bounded-vs-unbounded channel split.

## 4. Sandboxing & Process Isolation (sandbox)

**Impact:** HIGH
**Description:** Cross-platform sandbox patterns from running LLM-generated commands under Seatbelt, Landlock, seccomp, and Windows restricted tokens. Policy-as-data, argv[0] multiplexing, staged restrictions, and refusing to run when enforcement is impossible.

## 5. Type Design & Invariants (types)

**Impact:** HIGH
**Description:** Newtype, enum, and trait patterns that encode invariants at compile time — thread-local RAII for serde context, dyn-safe adapter traits for async registries, try_from-driven validation, and forward-compatible enum variants.

## 6. Testing Architecture (testing)

**Impact:** MEDIUM-HIGH
**Description:** Test organization patterns from a codebase with 5700-line test files. Sibling `foo_tests.rs` files via `#[path]`, wiremock-based fakes for SSE streams, AtomicBool test opt-ins, closure-based config builders, insta snapshot tests for Ratatui, and start_paused deterministic timing.

## 7. Protocol & Serde Design (proto)

**Impact:** MEDIUM-HIGH
**Description:** Serde-based protocol patterns for a JSON-RPC-like wire format with streaming, experimental fields, and forward compatibility — macro-generated dispatchers, Option<Option<T>>, rename+alias migration, and runtime experimental gating.

## 8. Workspace & Crate Organization (workspace)

**Impact:** MEDIUM
**Description:** Cargo workspace patterns from a 75-crate monorepo with zero per-crate features, a single source of truth for dependency versions, layered transport/api/core crates, and workspace-level lint enforcement via clippy.toml.

## 9. Observability & Tracing (otel)

**Impact:** MEDIUM
**Description:** tracing and OpenTelemetry patterns for services with privacy constraints — log-only vs trace-safe targets, field::Empty placeholders, W3C traceparent propagation across env vars and RPC envelopes, and trace-level `#[instrument]` as the default.

## 10. TUI (Ratatui) Rendering (tui)

**Impact:** MEDIUM
**Description:** Ratatui patterns from a streaming LLM TUI — two-gear hysteresis chunking, frame-request coalescing, panic-hook terminal restoration, unbracketed-paste burst detection, and pausing the event stream before a subprocess handoff.
