---
title: Replace fixed throttles with hysteresis-gated smooth and catch-up modes
impact: MEDIUM-HIGH
impactDescription: prevents visible lag on bursts without sacrificing the typewriter cadence feel
tags: tui, streaming, chunking, hysteresis
---

## Replace fixed throttles with hysteresis-gated smooth and catch-up modes

A fixed inter-line delay either looks choppy under bursts or abandons the typewriter feel entirely. Codex runs a single baseline cadence (one line per animation tick) in `Smooth` mode and flips to `CatchUp` when queue pressure builds, draining the backlog in one tick. Hysteresis on both entry and exit prevents gear-flapping: enter uses OR (depth OR age), exit uses AND (depth AND age), with an `EXIT_HOLD` window before coming back and a cooldown after exit unless backlog is severe.

**Incorrect (fixed per-line delay, bursts visibly lag):**

```rust
for line in new_lines {
    render_line(line).await;
    tokio::time::sleep(Duration::from_millis(16)).await; // choppy
}
```

**Correct (hysteresis thresholds, asymmetric enter/exit):**

```rust
// tui/src/streaming/chunking.rs
const ENTER_QUEUE_DEPTH_LINES: usize = 8;
const ENTER_OLDEST_AGE: Duration = Duration::from_millis(120);
const EXIT_QUEUE_DEPTH_LINES: usize = 2;
const EXIT_OLDEST_AGE: Duration = Duration::from_millis(40);
const EXIT_HOLD: Duration = Duration::from_millis(250);
const REENTER_CATCH_UP_HOLD: Duration = Duration::from_millis(250);
const SEVERE_QUEUE_DEPTH_LINES: usize = 64;
const SEVERE_OLDEST_AGE: Duration = Duration::from_millis(300);

pub fn decide(&self, snapshot: QueueSnapshot, now: Instant) -> Decision {
    let enter = snapshot.queued_lines >= ENTER_QUEUE_DEPTH_LINES
        || snapshot
            .oldest_age
            .map(|age| age >= ENTER_OLDEST_AGE)
            .unwrap_or(false);
    let exit = snapshot.queued_lines <= EXIT_QUEUE_DEPTH_LINES
        && snapshot
            .oldest_age
            .map(|age| age < EXIT_OLDEST_AGE)
            .unwrap_or(true);
    /* transition logic with hold windows */
}
```

Enter OR, exit AND — that asymmetry is what kills oscillation when only one signal is noisy. The codex team's own doc `docs/tui-stream-chunking-tuning.md` prescribes the tuning order: thresholds → holds → severe gates → baseline cadence.

Reference: `codex-rs/tui/src/streaming/chunking.rs:82`, `codex-rs/docs/tui-stream-chunking-tuning.md`.
