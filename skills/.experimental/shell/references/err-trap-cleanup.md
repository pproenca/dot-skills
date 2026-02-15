---
title: Use trap for Cleanup on Exit
impact: HIGH
impactDescription: prevents resource leaks and orphaned processes
tags: err, trap, cleanup, signals, exit
---

## Use trap for Cleanup on Exit

Without cleanup traps, scripts leave behind temporary files, running background processes, and held locks when interrupted or on errors.

**Incorrect (no cleanup handling):**

```bash
#!/bin/bash
build_log=$(mktemp)
staging_dir=$(mktemp -d)

# If script is interrupted (Ctrl+C) or fails,
# these files are never cleaned up
process_data > "$build_log"
# ... more operations
rm "$build_log"
rm -rf "$staging_dir"  # May never be reached
```

**Correct (trap-based cleanup):**

```bash
#!/bin/bash
set -euo pipefail

# Global cleanup variables
BUILD_LOG=""
STAGING_DIR=""
WORKER_PID=""

cleanup() {
  local exit_code=$?

  # Remove working files
  [[ -n "$BUILD_LOG" && -f "$BUILD_LOG" ]] && rm -f "$BUILD_LOG"
  [[ -n "$STAGING_DIR" && -d "$STAGING_DIR" ]] && rm -rf "$STAGING_DIR"

  # Kill background processes
  [[ -n "$WORKER_PID" ]] && kill "$WORKER_PID" 2>/dev/null || true

  exit "$exit_code"
}

# Register cleanup on EXIT only — EXIT fires on all shell exits
# including signal-induced exits (INT, TERM), avoiding double execution
trap cleanup EXIT

# Now create resources
BUILD_LOG=$(mktemp)
STAGING_DIR=$(mktemp -d)

# Script work here - cleanup runs automatically on exit
process_data > "$BUILD_LOG"
```

**Common mistake — trapping EXIT + signals causes double execution:**

```bash
#!/bin/bash
# WRONG: cleanup runs TWICE on SIGINT/SIGTERM
# (once for signal handler, once for EXIT when shell exits)
trap cleanup EXIT ERR INT TERM

# CORRECT: EXIT alone catches all exit paths including signals
trap cleanup EXIT
```

**Separate handlers for signal-specific behavior:**

```bash
#!/bin/bash
# Use separate handlers only when different behavior is needed per signal
trap 'echo "Interrupted" >&2; exit 130' INT
trap 'echo "Terminated" >&2; exit 143' TERM
trap 'cleanup' EXIT

# ERR trap for debugging (separate concern from cleanup)
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR
```

**Lock file pattern with trap:**

```bash
#!/bin/bash
LOCKFILE="/var/run/myapp.lock"

acquire_lock() {
  if ! mkdir "$LOCKFILE" 2>/dev/null; then
    echo "Another instance is running" >&2
    exit 1
  fi
  trap 'rm -rf "$LOCKFILE"' EXIT
}

acquire_lock
# Script runs exclusively
```

Reference: [Greg's Wiki - BashFAQ/105](https://mywiki.wooledge.org/BashFAQ/105)
