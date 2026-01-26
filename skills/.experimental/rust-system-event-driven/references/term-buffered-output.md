---
title: Buffer Terminal Output for Performance
impact: MEDIUM-HIGH
impactDescription: reduces syscalls by 100×, eliminates flicker
tags: term, buffer, performance, flush, tui
---

## Buffer Terminal Output for Performance

Each write to stdout is a syscall. Buffer all frame updates and flush once to eliminate flicker and improve performance dramatically.

**Incorrect (unbuffered writes cause flicker):**

```rust
fn render_frame(stdout: &mut Stdout) -> Result<(), Error> {
    execute!(stdout, Clear(ClearType::All))?;  // Syscall
    execute!(stdout, MoveTo(0, 0))?;            // Syscall
    write!(stdout, "Line 1")?;                  // Syscall
    execute!(stdout, MoveTo(0, 1))?;            // Syscall
    write!(stdout, "Line 2")?;                  // Syscall
    // ... hundreds of syscalls per frame = flicker
    Ok(())
}
```

**Correct (buffered with single flush):**

```rust
use std::io::{BufWriter, Write};

fn render_frame(stdout: &mut BufWriter<Stdout>) -> Result<(), Error> {
    queue!(stdout, Clear(ClearType::All))?;     // Buffered
    queue!(stdout, MoveTo(0, 0))?;              // Buffered
    write!(stdout, "Line 1")?;                  // Buffered
    queue!(stdout, MoveTo(0, 1))?;              // Buffered
    write!(stdout, "Line 2")?;                  // Buffered
    stdout.flush()?;                            // Single syscall
    Ok(())
}

fn main() -> Result<(), Error> {
    let mut stdout = BufWriter::new(std::io::stdout());
    render_frame(&mut stdout)?;
    Ok(())
}
```

**Note:** Use `queue!` instead of `execute!` - it queues commands without flushing.

Reference: [crossterm queue! macro](https://docs.rs/crossterm/latest/crossterm/macro.queue.html)
