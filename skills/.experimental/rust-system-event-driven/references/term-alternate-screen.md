---
title: Use Alternate Screen for Full-Screen Apps
impact: MEDIUM-HIGH
impactDescription: preserves user's terminal history and scrollback
tags: term, alternate-screen, tui, crossterm, ratatui
---

## Use Alternate Screen for Full-Screen Apps

The alternate screen buffer provides a clean canvas for TUI applications without destroying the user's terminal history. Switch back when your app exits.

**Incorrect (overwrites terminal history):**

```rust
fn run_tui() -> Result<(), Error> {
    let mut stdout = std::io::stdout();
    execute!(stdout, Clear(ClearType::All), MoveTo(0, 0))?;

    // App runs, user's previous terminal content is gone forever
    app_loop()?;

    Ok(())
}
```

**Correct (uses alternate screen):**

```rust
use crossterm::{
    execute,
    terminal::{EnterAlternateScreen, LeaveAlternateScreen},
};

fn run_tui() -> Result<(), Error> {
    let mut stdout = std::io::stdout();

    execute!(stdout, EnterAlternateScreen)?;
    enable_raw_mode()?;

    let result = app_loop();

    disable_raw_mode()?;
    execute!(stdout, LeaveAlternateScreen)?;

    result
}
```

**With ratatui setup:**

```rust
fn setup_terminal() -> Result<Terminal<CrosstermBackend<Stdout>>, Error> {
    enable_raw_mode()?;
    let mut stdout = std::io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    Terminal::new(backend)
}

fn restore_terminal(terminal: &mut Terminal<CrosstermBackend<Stdout>>) -> Result<(), Error> {
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    terminal.show_cursor()?;
    Ok(())
}
```

Reference: [crossterm alternate screen](https://docs.rs/crossterm/latest/crossterm/terminal/index.html#alternate-screen)
