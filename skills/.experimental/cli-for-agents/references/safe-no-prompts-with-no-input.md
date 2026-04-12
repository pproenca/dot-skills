---
title: Never Prompt When --no-input Is Set
impact: HIGH
impactDescription: prevents silent fallback to prompts in scripted mode
tags: safe, no-input, scripting, confirmation
---

## Never Prompt When --no-input Is Set

`--no-input` is the explicit signal "I am a script, never prompt" (defined in [`interact-no-input-flag`](interact-no-input-flag.md)). Destructive commands that would normally prompt for confirmation must respect this — not by silently proceeding (that's dangerous), and not by falling through to the prompt anyway (that's a hang), but by erroring immediately with "requires --yes." The guardrail stays intact, the hang doesn't happen, and the agent gets a clear fix.

**Incorrect (--no-input silently bypasses confirmation):**

```go
package main

import (
    "flag"
    "fmt"
    "os"
)

func main() {
    var noInput = flag.Bool("no-input", false, "disable prompts")
    var yes = flag.Bool("yes", false, "skip confirmation")
    flag.Parse()

    if !*yes && !*noInput {
        if !confirm("Really delete?") {
            os.Exit(1)
        }
    }
    // BUG: --no-input alone bypasses confirmation entirely
    doDelete()
    fmt.Println("deleted")
}
```

**Correct (--no-input requires --yes for destructive actions):**

```go
package main

import (
    "flag"
    "fmt"
    "os"
)

func main() {
    var noInput = flag.Bool("no-input", false, "disable prompts; fail on missing values")
    var yes = flag.Bool("yes", false, "skip confirmation")
    flag.Parse()

    if !*yes {
        if *noInput || !isTerminal(os.Stdin.Fd()) {
            fmt.Fprintln(os.Stderr, "Error: --yes is required in non-interactive mode.")
            fmt.Fprintln(os.Stderr, "  mycli delete --yes")
            os.Exit(2)
        }
        if !confirm("Really delete?") {
            os.Exit(1)
        }
    }
    doDelete()
    fmt.Println("deleted")
}
```

**Benefits:**
- `--no-input` never silently proceeds past a guardrail
- Agent gets a clear "add --yes" fix instead of a hang or a surprise delete
- Non-TTY detection is folded into the same check for consistency

Reference: [clig.dev — Interactivity and scripts](https://clig.dev/#interactivity)
