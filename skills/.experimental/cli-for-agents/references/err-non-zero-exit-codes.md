---
title: Use Distinct Non-Zero Exit Codes for Distinct Failures
impact: HIGH
impactDescription: prevents silent failures and unnecessary retries
tags: err, exit-codes, posix, retry
---

## Use Distinct Non-Zero Exit Codes for Distinct Failures

Agents decide whether to retry based on exit code. Exit 0 means "done, continue." Exit 1 means "generic failure, retry with caution." Exit 2 traditionally means "usage error — don't retry, fix input." Exit 75 (`EX_TEMPFAIL` from sysexits.h) is the canonical "transient failure, retry with backoff" signal. A CLI that always exits 0 (or always exits 1) hides this signal, forcing agents to parse error text with regex.

**Incorrect (every failure exits 1 or not at all):**

```go
package main

import (
    "fmt"
    "os"
)

func main() {
    env := os.Getenv("ENV")
    if env == "" {
        fmt.Fprintln(os.Stderr, "missing env")
        os.Exit(1)  // agent retries, same result
    }
    if err := deploy(env); err != nil {
        fmt.Fprintln(os.Stderr, err)
        os.Exit(1)  // same code as usage error
    }
}
```

**Correct (distinct codes for distinct failure classes):**

```go
package main

import (
    "errors"
    "fmt"
    "os"
)

const (
    ExitOK       = 0
    ExitFailure  = 1
    ExitUsage    = 2
    ExitTempFail = 75 // sysexits.h EX_TEMPFAIL: transient failure, retry-friendly
)

var ErrTransient = errors.New("transient upstream failure")

func main() {
    env := os.Getenv("ENV")
    if env == "" {
        fmt.Fprintln(os.Stderr, "Error: ENV is required.")
        fmt.Fprintln(os.Stderr, "  ENV=staging mycli deploy")
        os.Exit(ExitUsage) // agent: do not retry, fix input
    }
    if err := deploy(env); err != nil {
        fmt.Fprintln(os.Stderr, "Error:", err)
        if errors.Is(err, ErrTransient) {
            os.Exit(ExitTempFail) // agent: retry with backoff
        }
        os.Exit(ExitFailure)
    }
}
```

**Alternative (bash with the same sysexits.h taxonomy):**

The same rule applies to shell scripts. Bash has no native enums, but named constants
at the top of the script achieve the same clarity — and more importantly, they make
it obvious to the reader that `75` isn't an arbitrary number but `EX_TEMPFAIL` from `/usr/include/sysexits.h`.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Exit codes. 0/1/2 follow POSIX/bash convention; 69/75 come from sysexits.h.
# Agents branch on these, so do not renumber.
readonly EX_OK=0
readonly EX_FAILURE=1
readonly EX_USAGE=2            # POSIX/getopt convention (sysexits.h defines 64)
readonly EX_UNAVAILABLE=69     # sysexits.h EX_UNAVAILABLE: service unavailable
readonly EX_TEMPFAIL=75        # sysexits.h EX_TEMPFAIL: transient failure, retry-friendly

main() {
  local env="${ENV:-}"
  if [[ -z $env ]]; then
    echo "Error: ENV is required." >&2
    echo "  ENV=staging mycli deploy" >&2
    exit "$EX_USAGE"   # agent: do not retry, fix input
  fi

  if ! git fetch --prune origin 2>/dev/null; then
    echo "Error: git fetch failed (network/upstream)." >&2
    echo "  Retry in a few seconds, or check VPN." >&2
    exit "$EX_TEMPFAIL"  # agent: retry with backoff
  fi

  deploy "$env" || exit "$EX_FAILURE"
  exit "$EX_OK"
}

main "$@"
```

**Benefits:**
- Agents branch on exit code without parsing text
- Code 2 (usage) signals "don't retry — fix the command"
- Code 75 (`EX_TEMPFAIL`) signals "retry with backoff"; `EX_UNAVAILABLE` (69) is the related "service unavailable" hard failure
- Named constants (`$EX_TEMPFAIL` instead of `75`) make scripts self-documenting and catch typos at read-time

Reference: [FreeBSD sysexits.h — Preferable exit codes](https://man.freebsd.org/cgi/man.cgi?query=sysexits)
