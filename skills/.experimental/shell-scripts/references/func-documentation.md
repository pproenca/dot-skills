---
title: Document Functions with Header Comments
impact: MEDIUM
impactDescription: enables maintenance and API understanding
tags: func, documentation, comments, headers
---

## Document Functions with Header Comments

Complex functions without documentation become unmaintainable. Header comments explain purpose, parameters, and return values for future readers and users.

**Incorrect (no documentation):**

```bash
#!/bin/bash
process_data() {
  local f="$1"
  local o="$2"
  local v="${3:-false}"
  # What do these parameters mean?
  # What does this return?
  # What are the side effects?
}
```

**Correct (documented function):**

```bash
#!/bin/bash
#######################################
# Process input data and generate output.
#
# Reads the input file, applies transformation rules,
# and writes results to output file or stdout.
#
# Globals:
#   CONFIG_FILE: Path to configuration (read)
#   PROCESSED_COUNT: Incremented for each file (modified)
#
# Arguments:
#   $1 - Input file path (required)
#   $2 - Output file path (optional, defaults to stdout)
#   $3 - Verbose mode: true/false (optional, default: false)
#
# Outputs:
#   Writes processed data to stdout or output file.
#   Progress messages to stderr if verbose.
#
# Returns:
#   0 - Success
#   1 - Input file not found
#   2 - Permission denied
#   3 - Invalid input format
#######################################
process_data() {
  local input_file="$1"
  local output_file="${2:-}"
  local verbose="${3:-false}"

  # Implementation...
}
```

**When to document:**

```bash
#!/bin/bash
# Document these:
# - Library functions (used by other scripts)
# - Complex logic (non-obvious behavior)
# - Public API functions
# - Functions with side effects
# - Functions with multiple parameters

# Skip documentation for:
# - Trivial one-liners that are self-explanatory
# - Private helper functions with obvious names

# Trivial - name is self-documenting
die() {
  echo "$*" >&2
  exit 1
}

# Non-obvious - needs documentation
#######################################
# Retries a command with exponential backoff.
# Arguments:
#   $1 - Max attempts
#   $@ - Command to run
# Returns:
#   Exit status of command, or 1 if all retries fail
#######################################
retry_with_backoff() {
  # ...
}
```

**Minimal documentation template:**

```bash
#!/bin/bash
# Short description of what the function does.
# Arguments: $1 - description, $2 - description
# Returns: 0 on success, 1 on error
function_name() {
  # ...
}
```

**File header template:**

```bash
#!/bin/bash
#
# Script name and one-line description.
#
# Longer description of what this script does, when to use it,
# and any important caveats or prerequisites.
#
# Usage: script.sh [options] <required_arg>
#
# Options:
#   -h, --help     Show help
#   -v, --verbose  Verbose output
#
# Examples:
#   script.sh input.txt
#   script.sh -v -o output.txt input.txt
#
# Dependencies:
#   - jq (JSON processing)
#   - curl (HTTP requests)
#

set -euo pipefail
```

Reference: [Google Shell Style Guide - Function Comments](https://google.github.io/styleguide/shellguide.html)
