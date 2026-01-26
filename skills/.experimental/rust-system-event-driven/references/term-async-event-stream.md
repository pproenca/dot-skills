---
title: Use Async Event Stream for Terminal Input
impact: MEDIUM-HIGH
impactDescription: enables non-blocking input handling in async apps
tags: term, async, events, crossterm, tokio
---

## Use Async Event Stream for Terminal Input

For async TUI applications, use crossterm's event stream to receive terminal events without blocking the async runtime.

**Incorrect (blocking poll in async context):**

```rust
async fn event_loop() {
    loop {
        // Blocks the entire async runtime!
        if crossterm::event::poll(Duration::from_millis(100)).unwrap() {
            let event = crossterm::event::read().unwrap();
            handle_event(event).await;
        }
    }
}
```

**Correct (async event stream):**

```rust
use crossterm::event::{Event, EventStream};
use futures::StreamExt;

async fn event_loop(mut rx: mpsc::Receiver<AppEvent>) {
    let mut event_stream = EventStream::new();

    loop {
        tokio::select! {
            biased;

            Some(app_event) = rx.recv() => {
                if handle_app_event(app_event).await.is_break() {
                    break;
                }
            }

            Some(Ok(event)) = event_stream.next() => {
                if handle_terminal_event(event).await.is_break() {
                    break;
                }
            }
        }
    }
}

async fn handle_terminal_event(event: Event) -> ControlFlow<()> {
    match event {
        Event::Key(key) if key.code == KeyCode::Char('q') => {
            ControlFlow::Break(())
        }
        Event::Resize(width, height) => {
            // Handle terminal resize
            ControlFlow::Continue(())
        }
        _ => ControlFlow::Continue(())
    }
}
```

**Note:** Enable the `event-stream` feature in crossterm.

Reference: [crossterm EventStream](https://docs.rs/crossterm/latest/crossterm/event/struct.EventStream.html)
