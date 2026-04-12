---
title: Disable ANSI Color When NO_COLOR or Non-TTY
impact: MEDIUM
impactDescription: prevents escape sequences from breaking regex matches
tags: output, no-color, ansi, tty
---

## Disable ANSI Color When NO_COLOR or Non-TTY

ANSI escape sequences (`\x1b[31m`) confuse agents that pattern-match on output — a regex for `Error:` won't match `\x1b[31mError:\x1b[0m`. Three signals mean "don't emit color": the `NO_COLOR` env var is set to a non-empty value (per the no-color.org spec — any non-empty value disables color), the destination stream is not a TTY (piped or redirected), or the user passed `--no-color`. Check all three against whichever stream you're writing color to (stderr for error color, stdout for data color).

**Incorrect (always emits color regardless of context):**

```go
package main

import (
    "fmt"
    "os"
)

const (
    red   = "\x1b[31m"
    reset = "\x1b[0m"
)

func main() {
    if err := run(); err != nil {
        // Agent piping to grep sees: \x1b[31mError: ...\x1b[0m
        fmt.Fprintf(os.Stderr, "%sError: %s%s\n", red, err, reset)
    }
}
```

**Correct (honor NO_COLOR, --no-color, and isTTY):**

```go
package main

import (
    "flag"
    "fmt"
    "os"

    "golang.org/x/term"
)

func useColor(noColorFlag bool) bool {
    if noColorFlag {
        return false
    }
    if v, ok := os.LookupEnv("NO_COLOR"); ok && v != "" {
        return false // no-color.org: set to any non-empty value disables color
    }
    // Checking stderr because this program colorizes errors.
    // Check stdout instead when colorizing data output.
    return term.IsTerminal(int(os.Stderr.Fd()))
}

func main() {
    noColor := flag.Bool("no-color", false, "disable ANSI color output")
    flag.Parse()

    colorize := useColor(*noColor)
    if err := run(); err != nil {
        if colorize {
            fmt.Fprintf(os.Stderr, "\x1b[31mError: %s\x1b[0m\n", err)
        } else {
            fmt.Fprintf(os.Stderr, "Error: %s\n", err)
        }
    }
}
```

**Benefits:**
- Non-empty-value `NO_COLOR` check matches the spec at no-color.org
- Agents regex-match `Error:` without stripping escape sequences first
- Works automatically in CI, `| grep`, `| tee log.txt`, and redirected runs

Reference: [no-color.org — NO_COLOR specification](https://no-color.org/)
