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
# deploy.sh — Deploy application to staging environment
# Usage: deploy.sh [-v] [-e environment] <version>

set -euo pipefail

# 1. Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DEPLOY_CONFIG="/etc/myapp/deploy.conf"

# 2. Configurable defaults (override via environment)
: "${LOG_LEVEL:=info}"
: "${DRY_RUN:=false}"

# 3. Source dependencies
source "${SCRIPT_DIR}/lib/logging.sh"

# 4. Global variables (mutable state)
VERBOSE=false
TARGET_ENV="staging"

# 5. Functions
cleanup() { :; }
parse_args() { :; }
deploy_release() { :; }

# 6. Main entry point
main() {
  trap cleanup EXIT
  parse_args "$@"
  deploy_release
}

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
