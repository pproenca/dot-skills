---
title: Restore terminal state via a Drop guard and chained panic hook
impact: MEDIUM-HIGH
impactDescription: prevents wedged terminals that require manual `reset` after a panic
tags: tui, terminal, panic, raii
---

## Restore terminal state via a Drop guard and chained panic hook

Calling `disable_raw_mode()` at the end of `main` leaves the user's terminal wedged on any panic halfway through — raw mode stays on, alternate screen stays active, and a `reset` is the only way out. Codex wraps the main body in a `TerminalRestoreGuard { active: bool }` whose `Drop` calls `restore_silently()`, and installs a `panic::set_hook` that *chains the previous hook* rather than replacing it — so color-eyre's rich backtrace still fires *after* the terminal is restored.

**Incorrect (explicit restore at end of main — panic wedges terminal):**

```rust
fn main() -> io::Result<()> {
    enable_raw_mode()?;
    execute!(stdout(), EnterAlternateScreen)?;
    run_app()?; // panic here leaves terminal in alt-screen raw mode
    execute!(stdout(), LeaveAlternateScreen)?;
    disable_raw_mode()?;
    Ok(())
}
```

**Correct (Drop guard + chained panic hook):**

```rust
// tui/src/lib.rs — chain, don't replace
let prev_hook = std::panic::take_hook();
std::panic::set_hook(Box::new(move |info| {
    tracing::error!("panic: {info}");
    prev_hook(info);
}));
let mut terminal = tui::init()?;
let mut terminal_restore_guard = TerminalRestoreGuard::new();

// tui/src/tui.rs — init also installs its own restore hook
fn set_panic_hook() {
    let hook = panic::take_hook();
    panic::set_hook(Box::new(move |panic_info| {
        let _ = restore(); // ignore errors, we're already failing
        hook(panic_info);
    }));
}

// TerminalRestoreGuard
impl Drop for TerminalRestoreGuard {
    fn drop(&mut self) {
        if self.active {
            let _ = restore();
            self.active = false;
        }
    }
}
```

There are *two* layered panic hooks — `tui::init` installs one to restore the terminal, and `run` adds a tracing hook on top. Both chain the previous one. The `Drop for TerminalRestoreGuard` means you can `return Err(...)` from anywhere without leaving raw mode on. The `active: bool` gate also lets explicit early restore (before exec-ing `git commit` into the same terminal) not double-fire.

Reference: `codex-rs/tui/src/tui.rs:101`, `codex-rs/tui/src/lib.rs:1019`.
