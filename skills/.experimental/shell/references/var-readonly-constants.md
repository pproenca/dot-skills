---
title: Use readonly for Constants
impact: HIGH
impactDescription: prevents accidental modification of configuration values
tags: var, readonly, constants, immutable
---

## Use readonly for Constants

Constants that should never change after initialization can be accidentally overwritten. `readonly` prevents modifications and signals intent to readers.

**Incorrect (mutable constants):**

```bash
#!/bin/bash
# Can be accidentally modified
CONFIG_FILE="/etc/myapp/config"
MAX_RETRIES=3
VERSION="1.0.0"

# Later in script, typo causes bug:
CONFIG_FILE="/etc/myapp/conf"  # Oops, meant to use it

# Or in function:
process() {
  MAX_RETRIES=10  # Accidentally changes global constant
}
```

**Correct (immutable constants):**

```bash
#!/bin/bash
# Constants declared at top of file
readonly CONFIG_FILE="/etc/myapp/config"
readonly MAX_RETRIES=3
readonly VERSION="1.0.0"

# Attempt to modify causes error:
# CONFIG_FILE="/other"  # Error: CONFIG_FILE: readonly variable

# declare -r is equivalent
declare -r DATABASE_URL="postgres://localhost/db"
declare -r TIMEOUT_SECONDS=30
```

**Group related constants:**

```bash
#!/bin/bash
# Exit codes
readonly E_SUCCESS=0
readonly E_INVALID_ARGS=1
readonly E_FILE_NOT_FOUND=2
readonly E_PERMISSION_DENIED=3

# Paths
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="/etc/myapp"
readonly LOG_DIR="/var/log/myapp"
readonly DATA_DIR="/var/lib/myapp"

# Application settings
readonly APP_NAME="myapp"
readonly APP_VERSION="1.2.3"
readonly DEFAULT_PORT=8080
```

**readonly vs declare -r:**

```bash
#!/bin/bash
# Both work the same for global scope
readonly GLOBAL_CONST="value"
declare -r GLOBAL_CONST2="value"

# In functions, use local -r for local constants
my_function() {
  local -r local_const="value"  # Readonly within function
  echo "$local_const"
}
```

**Export readonly for child processes:**

```bash
#!/bin/bash
# Make readonly AND export for subprocesses
declare -rx EXPORTED_CONST="value"

# Or separately
readonly MY_CONST="value"
export MY_CONST
```

Reference: [Google Shell Style Guide - Constants and Environment Variables](https://google.github.io/styleguide/shellguide.html)
