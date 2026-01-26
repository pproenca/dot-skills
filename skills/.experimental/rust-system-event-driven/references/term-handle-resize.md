---
title: Handle Terminal Resize Events
impact: MEDIUM-HIGH
impactDescription: prevents UI corruption when terminal size changes
tags: term, resize, events, responsive, tui
---

## Handle Terminal Resize Events

Terminal windows can be resized at any time. Listen for resize events and redraw your UI to prevent corruption and provide a responsive experience.

**Incorrect (ignores resize, UI breaks):**

```rust
fn main() -> Result<(), Error> {
    let (width, height) = terminal::size()?;  // Only checked once!

    loop {
        render_frame(width, height)?;
        handle_input()?;
        // If user resizes, UI renders incorrectly
    }
}
```

**Correct (handles resize events):**

```rust
use crossterm::event::{Event, EventStream};

async fn main() -> Result<(), Error> {
    let mut size = terminal::size()?;
    let mut event_stream = EventStream::new();

    loop {
        render_frame(size.0, size.1)?;

        match event_stream.next().await {
            Some(Ok(Event::Resize(width, height))) => {
                size = (width, height);
                // Redraw immediately with new dimensions
            }
            Some(Ok(Event::Key(key))) => {
                if handle_key(key).is_break() {
                    break;
                }
            }
            _ => {}
        }
    }

    Ok(())
}
```

**With ratatui:**

```rust
fn run_app(terminal: &mut Terminal<impl Backend>) -> Result<(), Error> {
    loop {
        terminal.draw(|frame| {
            // frame.area() automatically reflects current size
            let area = frame.area();
            render_ui(frame, area);
        })?;

        if let Event::Resize(_, _) = event::read()? {
            // Terminal::draw handles resize automatically
            continue;
        }
    }
}
```

Reference: [crossterm Event::Resize](https://docs.rs/crossterm/latest/crossterm/event/enum.Event.html#variant.Resize)
