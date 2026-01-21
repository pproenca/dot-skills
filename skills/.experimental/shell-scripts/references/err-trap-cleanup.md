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
tmpfile=$(mktemp)
tmpdir=$(mktemp -d)

# If script is interrupted (Ctrl+C) or fails,
# temp files are never cleaned up
process_data > "$tmpfile"
# ... more operations
rm "$tmpfile"
rm -rf "$tmpdir"  # May never be reached
```

**Correct (trap-based cleanup):**

```bash
#!/bin/bash
set -euo pipefail

# Global cleanup variables
TMPFILE=""
TMPDIR=""
BACKGROUND_PID=""

cleanup() {
  local exit_code=$?

  # Remove temporary files
  [[ -n "$TMPFILE" && -f "$TMPFILE" ]] && rm -f "$TMPFILE"
  [[ -n "$TMPDIR" && -d "$TMPDIR" ]] && rm -rf "$TMPDIR"

  # Kill background processes
  [[ -n "$BACKGROUND_PID" ]] && kill "$BACKGROUND_PID" 2>/dev/null || true

  exit "$exit_code"
}

# Register cleanup for multiple signals
trap cleanup EXIT ERR INT TERM

# Now create resources
TMPFILE=$(mktemp)
TMPDIR=$(mktemp -d)

# Script work here - cleanup runs automatically on exit
process_data > "$TMPFILE"
```

**Trap for specific signals:**

```bash
#!/bin/bash
# Different handlers for different situations
trap 'echo "Interrupted"; exit 130' INT
trap 'echo "Terminated"; exit 143' TERM
trap 'cleanup' EXIT

# ERR trap for debugging
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
