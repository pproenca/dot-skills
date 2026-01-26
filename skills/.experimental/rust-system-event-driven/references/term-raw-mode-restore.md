---
title: Always Restore Terminal State on Exit
impact: MEDIUM-HIGH
impactDescription: prevents leaving user with broken terminal
tags: term, raw-mode, restore, cleanup, panic
---

## Always Restore Terminal State on Exit

When using raw mode for terminal applications, always restore the terminal to its original state on exit, including on panic. A broken terminal state requires users to run `reset`.

**Incorrect (terminal left in raw mode on error):**

```rust
use crossterm::terminal::{enable_raw_mode, disable_raw_mode};

fn run_tui() -> Result<(), Error> {
    enable_raw_mode()?;

    let result = app_loop()?;  // If this panics, terminal stays in raw mode!

    disable_raw_mode()?;
    Ok(result)
}
```

**Correct (RAII guard ensures cleanup):**

```rust
use crossterm::terminal::{enable_raw_mode, disable_raw_mode};

struct RawModeGuard;

impl RawModeGuard {
    fn new() -> Result<Self, Error> {
        enable_raw_mode()?;
        Ok(Self)
    }
}

impl Drop for RawModeGuard {
    fn drop(&mut self) {
        let _ = disable_raw_mode();
    }
}

fn run_tui() -> Result<(), Error> {
    let _guard = RawModeGuard::new()?;  // Restored on drop, even on panic

    app_loop()
}
```

**With panic hook for extra safety:**

```rust
fn run_tui() -> Result<(), Error> {
    let original_hook = std::panic::take_hook();
    std::panic::set_hook(Box::new(move |info| {
        let _ = disable_raw_mode();
        let _ = execute!(std::io::stdout(), LeaveAlternateScreen);
        original_hook(info);
    }));

    let _guard = RawModeGuard::new()?;
    app_loop()
}
```

Reference: [crossterm terminal](https://docs.rs/crossterm/latest/crossterm/terminal/)
