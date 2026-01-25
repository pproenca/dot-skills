---
title: Use Colored Output for Error Visibility
impact: LOW-MEDIUM
impactDescription: 2-3× faster error identification in terminals
tags: error, color, styling, terminal, visibility
---

## Use Colored Output for Error Visibility

Use clap's built-in color support and consider enhancing with libraries like `anstream` for cross-platform colored output.

**Incorrect (manual color handling without fallback):**

```rust
fn print_error(msg: &str) {
    eprintln!("\x1b[31merror:\x1b[0m {}", msg);  // No TTY check
}
// Outputs escape codes to files and pipes, corrupting output
```

**Correct (clap's automatic color handling):**

```rust
#[derive(Parser)]
#[command(color = clap::ColorChoice::Auto)]
struct Cli {
    #[arg(long)]
    input: PathBuf,
}
// Clap automatically colors error messages when terminal supports it
// Respects NO_COLOR environment variable
```

**Pattern for custom colored errors:**

```rust
use std::io::{self, Write};

fn print_error(msg: &str) {
    let stderr = io::stderr();
    let mut handle = stderr.lock();

    if atty::is(atty::Stream::Stderr) {
        writeln!(handle, "\x1b[31merror:\x1b[0m {}", msg).ok();
    } else {
        writeln!(handle, "error: {}", msg).ok();  // No colors for pipes
    }
}
```

**Best practices:**
- Respect `NO_COLOR` environment variable
- Use `clap::ColorChoice::Auto` as default
- Allow `--color never/auto/always` override

Reference: [Clap ColorChoice](https://docs.rs/clap/latest/clap/enum.ColorChoice.html)
