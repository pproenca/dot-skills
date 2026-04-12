---
title: Pause the event stream by dropping it before subprocess handoff
impact: MEDIUM
impactDescription: prevents stdin race with child processes after handing off the terminal
tags: tui, events, subprocess, crossterm
---

## Pause the event stream by dropping it before subprocess handoff

When a TUI launches `$EDITOR`, `git commit`, or a pager, just stopping the poll loop is not enough. Crossterm's `EventStream` spawns an internal reader thread that keeps reading from stdin even if you never call `poll_next`, stealing input the subprocess meant to see. Codex wraps the stream in an `EventBroker` with three states (`Paused`, `Start`, `Running(S)`). Pause drops the stream entirely; resume recreates it; `flush_terminal_input_buffer()` uses `libc::tcflush` to discard any bytes the user typed during the handoff.

**Incorrect (stop polling but keep the stream):**

```rust
async fn run_git_commit() -> io::Result<()> {
    *polling_enabled.lock().await = false;
    let status = Command::new("git").arg("commit").status().await?;
    *polling_enabled.lock().await = true;
    // Crossterm's internal reader already stole half of git's keystrokes.
    Ok(())
}
```

**Correct (drop the stream, tcflush, recreate):**

```rust
// tui/src/tui/event_stream.rs
//! The motivation for dropping/recreating the crossterm event stream is
//! to enable the TUI to fully relinquish stdin. If the stream is not
//! dropped, it will continue to read from stdin even if it is not
//! actively being polled (due to how crossterm's EventStream is
//! implemented), stealing input from other processes
//! reading stdin, like terminal text editors.

pub fn pause_events(&self) {
    *self.state.lock().unwrap() = EventBrokerState::Paused;
}

// tui/src/tui.rs — flush stale stdin bytes on resume
#[cfg(unix)]
fn flush_terminal_input_buffer() {
    let result = unsafe {
        libc::tcflush(libc::STDIN_FILENO, libc::TCIFLUSH)
    };
    if result != 0 {
        tracing::warn!(
            "failed to tcflush stdin: {}",
            std::io::Error::last_os_error(),
        );
    }
}
```

Stopping polling is not enough — crossterm spawns an internal reader thread that races the child for stdin bytes. You must drop the stream. And even after recreating it, stale bytes can remain in the kernel's tty input buffer from the handoff window; `tcflush(TCIFLUSH)` drops them. Windows has a sibling using `FlushConsoleInputBuffer`.

Reference: `codex-rs/tui/src/tui/event_stream.rs:10`, `codex-rs/tui/src/tui.rs:209`.
