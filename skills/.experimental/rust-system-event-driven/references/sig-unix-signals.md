---
title: Handle Unix Signals Asynchronously
impact: MEDIUM
impactDescription: enables proper daemon behavior and log rotation
tags: sig, unix, signal, daemon, tokio
---

## Handle Unix Signals Asynchronously

Use tokio's signal API to handle Unix signals like SIGHUP (reload config), SIGTERM (terminate), and SIGUSR1 (custom) asynchronously.

**Incorrect (blocking signal handler):**

```rust
use signal_hook::iterator::Signals;

fn main() {
    let mut signals = Signals::new(&[SIGHUP, SIGTERM]).unwrap();

    // This blocks a thread waiting for signals
    for sig in signals.forever() {
        match sig {
            SIGHUP => reload_config(),
            SIGTERM => break,
            _ => {}
        }
    }
}
```

**Correct (async signal handling):**

```rust
use tokio::signal::unix::{signal, SignalKind};

#[tokio::main]
async fn main() {
    let mut sigterm = signal(SignalKind::terminate()).unwrap();
    let mut sighup = signal(SignalKind::hangup()).unwrap();

    loop {
        tokio::select! {
            _ = sigterm.recv() => {
                println!("Received SIGTERM, shutting down");
                break;
            }
            _ = sighup.recv() => {
                println!("Received SIGHUP, reloading config");
                reload_config().await;
            }
            _ = run_main_loop() => {}
        }
    }
}
```

**Common Unix signals:**
- `SIGTERM` - Graceful shutdown request
- `SIGHUP` - Reload configuration (daemon convention)
- `SIGUSR1/2` - Custom application signals
- `SIGINT` - Interactive interrupt (Ctrl-C)

Reference: [tokio::signal::unix](https://docs.rs/tokio/latest/tokio/signal/unix/)
