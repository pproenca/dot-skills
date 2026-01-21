---
title: Follow Consistent File Structure
impact: LOW
impactDescription: enables quick navigation and maintenance
tags: style, structure, organization, layout
---

## Follow Consistent File Structure

Scripts without consistent structure are hard to navigate. Following a standard layout helps readers find what they need quickly.

**Incorrect (unstructured):**

```bash
#!/bin/bash
process() { ... }
readonly VAR=1
set -e
another_func() { ... }
# Random comment
CONFIG=/etc/app
main() { ... }
source ./lib.sh
main "$@"
```

**Correct (structured layout):**

```bash
#!/bin/bash
#
# Script description: Brief explanation of what this script does.
#
# Usage: script.sh [options] <required_arg>
#
# Options:
#   -h, --help     Show help message
#   -v, --verbose  Enable verbose output
#

set -euo pipefail

#######################################
# Constants
#######################################
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly CONFIG_FILE="/etc/myapp/config"
readonly LOG_FILE="/var/log/myapp.log"

#######################################
# Configurable defaults (can override via environment)
#######################################
: "${LOG_LEVEL:=info}"
: "${DRY_RUN:=false}"

#######################################
# Source dependencies
#######################################
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/logging.sh"

#######################################
# Global variables (mutable state)
#######################################
VERBOSE=false
OUTPUT_FILE=""

#######################################
# Functions (alphabetical or logical order)
#######################################

cleanup() {
  # Cleanup logic here
  :
}

parse_args() {
  # Argument parsing here
  :
}

process() {
  # Main processing logic
  :
}

usage() {
  cat << EOF
Usage: ${SCRIPT_NAME} [options] <input>

Options:
  -h, --help     Show this help message
  -v, --verbose  Enable verbose output
  -o FILE        Output file (default: stdout)

Examples:
  ${SCRIPT_NAME} input.txt
  ${SCRIPT_NAME} -v -o output.txt input.txt
EOF
}

#######################################
# Main entry point
#######################################
main() {
  trap cleanup EXIT

  parse_args "$@"
  process
}

# Only run main if executed directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
```

**Section order:**

1. Shebang and file header comment
2. `set` options (strict mode)
3. Constants (`readonly`)
4. Configurable defaults
5. Source dependencies
6. Global variables
7. Function definitions
8. Main function
9. Main invocation guard

**File naming:**

```bash
# Executables
my-script        # No extension, executable
my-script.sh     # With extension (if build system renames)

# Libraries (sourced, not executed)
lib/common.sh    # Always .sh extension
lib/logging.sh   # Not executable
```

Reference: [Google Shell Style Guide - File Organization](https://google.github.io/styleguide/shellguide.html)
