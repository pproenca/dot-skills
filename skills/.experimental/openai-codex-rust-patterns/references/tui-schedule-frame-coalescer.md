---
title: Coalesce redraws through a FrameRequester actor
impact: MEDIUM
impactDescription: reduces redraw count when multiple producers request frames in the same tick
tags: tui, ratatui, rendering, performance
---

## Coalesce redraws through a FrameRequester actor

Drawing synchronously on every event produces wasted frames when three back-to-back updates all land in the same tick. Codex exposes a cheap, cloneable `FrameRequester` that sends an `Instant` over an unbounded channel. A dedicated tokio task coalesces every request received before the next deadline into a single `draw_tx.send(())` broadcast, clamped by a 120 FPS `FrameRateLimiter`. The event loop never draws spontaneously; widgets never call `draw` — they call `schedule_frame()` and go back to work.

**Incorrect (draw per event — wasted frames on bursts):**

```rust
async fn event_loop(mut terminal: Terminal<B>) -> io::Result<()> {
    while let Some(event) = events.next().await {
        handle_event(event);
        terminal.draw(|frame| render(frame))?; // draws on every event
    }
    Ok(())
}
```

**Correct (actor coalesces draw requests, draws on deadline):**

```rust
// tui/src/tui/frame_requester.rs
async fn run(mut self) {
    const ONE_YEAR: Duration = Duration::from_secs(60 * 60 * 24 * 365);
    let mut next_deadline: Option<Instant> = None;
    loop {
        let target = next_deadline.unwrap_or_else(|| {
            Instant::now() + ONE_YEAR
        });
        let deadline = tokio::time::sleep_until(target.into());
        tokio::pin!(deadline);
        tokio::select! {
            draw_at = self.receiver.recv() => {
                let Some(draw_at) = draw_at else { break };
                let draw_at = self.rate_limiter.clamp_deadline(draw_at);
                next_deadline = Some(
                    next_deadline
                        .map_or(draw_at, |cur| cur.min(draw_at)),
                );
                continue; // do NOT draw yet — recompute sleep
            }
            _ = &mut deadline => {
                if next_deadline.is_some() {
                    next_deadline = None;
                    self.rate_limiter.mark_emitted(target);
                    let _ = self.draw_tx.send(());
                }
            }
        }
    }
}
```

The `continue` after receiving a request is the crux — it does not draw, just tightens the sleep target. Three back-to-back `schedule_frame()` calls produce exactly one draw notification. The `ONE_YEAR` sentinel replaces the "how do I block forever on select" dance with a simple future-time constant.

Reference: `codex-rs/tui/src/tui/frame_requester.rs:96`.
