---
title: Use main() Function Pattern
impact: MEDIUM
impactDescription: enables testing and prevents execution on source
tags: func, main, structure, sourcing, testing
---

## Use main() Function Pattern

Code at file level executes when sourced for testing. Wrapping logic in `main()` with a guard allows both direct execution and sourcing without side effects.

**Incorrect (top-level execution):**

```bash
#!/bin/bash
# All code runs immediately, even when sourced
config_file="/etc/app.conf"
load_config

process_args "$@"
do_work
cleanup

# Cannot source this file for testing without side effects
# source script.sh  # Immediately runs everything!
```

**Correct (main function with guard):**

```bash
#!/bin/bash
set -euo pipefail

# Constants and function definitions
readonly CONFIG_FILE="/etc/app.conf"

load_config() {
  # ...
}

process() {
  local input="$1"
  # ...
}

cleanup() {
  # ...
}

main() {
  local args=("$@")

  load_config
  process "${args[@]}"
  cleanup
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

**Testing sourced functions:**

```bash
#!/bin/bash
# test_script.sh

# Source the script without running main
source ./my_script.sh

# Now test individual functions
test_process() {
  local result
  result=$(process "test input")
  if [[ "$result" != "expected output" ]]; then
    echo "FAIL: process returned '$result'"
    return 1
  fi
  echo "PASS: process"
}

test_process
```

**Alternative guards:**

```bash
#!/bin/bash
# Method 1: BASH_SOURCE comparison (recommended)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

# Method 2: Function existence check
if ! declare -f main > /dev/null; then
  main() { :; }  # Define no-op for sourcing
fi

# Method 3: Environment variable
if [[ "${SCRIPT_TESTING:-}" != "true" ]]; then
  main "$@"
fi
```

**Script structure template:**

```bash
#!/bin/bash
#
# Description of what this script does.
#
set -euo pipefail

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Global variables with defaults
: "${LOG_LEVEL:=info}"

# Function definitions (alphabetical or logical order)
cleanup() { :; }
parse_args() { :; }
process() { :; }
usage() { :; }

# Main entry point
main() {
  trap cleanup EXIT
  parse_args "$@"
  process
}

# Run if executed directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
```

Reference: [Google Shell Style Guide - main](https://google.github.io/styleguide/shellguide.html)
