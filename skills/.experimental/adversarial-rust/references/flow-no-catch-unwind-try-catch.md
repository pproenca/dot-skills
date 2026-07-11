---
title: Reserve catch_unwind for isolation boundaries, never try/catch
tags: flow, panic, catch-unwind, isolation
---

## Reserve catch_unwind for isolation boundaries, never try/catch

Exception-trained engineers reach for `std::panic::catch_unwind` as Rust's `try { } catch { }` — but panics are bugs, not outcomes: they can be configured to abort (making the catch dead code), they skip destructors' invariants (`AssertUnwindSafe` is you *promising* nothing is broken), and catching them as control flow hides the defect. codex-rs has 14 `catch_unwind` call sites — four in test harnesses, and every production one a supervision seam where a panic in *someone else's* unit of work must not take down the host: the V8 runtime thread supervisor converts a panic into a `RuntimeEvent::ThreadPanicked` event, the remote-control websocket task logs clean-vs-unexpected exit, telemetry init degrades to "no OTEL" instead of crashing the CLI, and Windows FFI setup shields OS-call panics. None catch an expected failure.

**Incorrect (panic as control flow for an expected failure):**

```rust
use std::panic::{self, AssertUnwindSafe};

fn parse_config(text: &str) -> Option<u32> {
    // try/catch transliterated: parse errors are EXPECTED, not bugs
    panic::catch_unwind(AssertUnwindSafe(|| text.parse::<u32>().unwrap())).ok()
}
```

**Correct (expected failure returns Result; catch_unwind supervises a foreign unit of work — how codex-rs shields its V8 thread):**

```rust
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::sync::mpsc;
use std::thread;

fn parse_config(text: &str) -> Result<u32, std::num::ParseIntError> {
    text.parse::<u32>()
}

enum RuntimeEvent {
    ThreadPanicked,
}

fn supervise_runtime(runtime: impl FnOnce() + Send + 'static, event_tx: mpsc::Sender<RuntimeEvent>) {
    thread::spawn(move || {
        // A bug in the embedded runtime becomes a reportable event,
        // not a silent hole in the host process.
        if catch_unwind(AssertUnwindSafe(runtime)).is_err() {
            let _ = event_tx.send(RuntimeEvent::ThreadPanicked);
        }
    });
}
```

The test: does the closure belong to a different fault domain (spawned thread or task, embedded interpreter, FFI callback, optional subsystem init)? Then supervising its panics is correct — and the catch converts the panic into an event or a degraded mode, never into a value the happy path consumes.

Reference: [codex-rs code-mode/src/runtime/mod.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/code-mode/src/runtime/mod.rs#L128), [codex-rs exec/src/lib.rs OTEL init](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/exec/src/lib.rs#L497), [codex-rs app-server-transport remote_control](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/app-server-transport/src/transport/remote_control/mod.rs#L1035)
