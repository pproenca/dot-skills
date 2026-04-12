---
title: Never Use Timed Prompts or Press-Any-Key Screens
impact: HIGH
impactDescription: prevents wall-clock waste on every retry
tags: interact, timeouts, confirmation, press-any-key
---

## Never Use Timed Prompts or Press-Any-Key Screens

A "press y within 30 seconds to continue" prompt will wait the full timeout on every agent invocation — the agent cannot send keystrokes during the countdown, so the CLI consumes 30 real seconds of wall-clock before moving on. Multiply by retries and you have a CLI that is technically working but unusable. Replace timeouts with an explicit `--yes` / `-y` flag that skips the confirmation entirely.

**Incorrect (10-second countdown with keystroke poll):**

```go
package main

import (
    "fmt"
    "os"
    "time"
)

func confirmRollback() bool {
    fmt.Println("Rolling back in 10s. Press Ctrl-C to cancel, y to confirm now.")
    deadline := time.Now().Add(10 * time.Second)
    for time.Now().Before(deadline) {
        // Agent cannot hit 'y' — the loop burns the full 10s every run
        if keyPressed() == 'y' {
            return true
        }
        time.Sleep(100 * time.Millisecond)
    }
    fmt.Fprintln(os.Stderr, "Timeout; aborting.")
    return false
}
```

**Correct (explicit --yes flag, no implicit timer):**

```go
package main

import (
    "flag"
    "fmt"
    "os"
)

func main() {
    yes := flag.Bool("yes", false, "skip confirmation prompt")
    flag.Parse()

    if !*yes {
        if !isTerminal(os.Stdin.Fd()) {
            fmt.Fprintln(os.Stderr, "Error: --yes is required when stdin is not a TTY.")
            fmt.Fprintln(os.Stderr, "  mycli rollback --yes")
            os.Exit(2)
        }
        if !promptYesNo("Roll back?") {
            os.Exit(1)
        }
    }
    doRollback()
}
```

Reference: [clig.dev — Confirm dangerous actions](https://clig.dev/#robustness-guidelines)
