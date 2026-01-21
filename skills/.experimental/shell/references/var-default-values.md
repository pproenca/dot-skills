---
title: Use Parameter Expansion for Defaults
impact: HIGH
impactDescription: handles unset variables safely without conditionals
tags: var, defaults, parameter-expansion, unset
---

## Use Parameter Expansion for Defaults

Checking for unset variables with if/else is verbose and error-prone. Parameter expansion provides concise, safe defaults that work with `set -u`.

**Incorrect (verbose conditional checks):**

```bash
#!/bin/bash
# Verbose and error-prone
if [[ -z "$CONFIG_FILE" ]]; then
  CONFIG_FILE="/etc/default.conf"
fi

if [[ -z "$TIMEOUT" ]]; then
  TIMEOUT=30
fi

# Or ignoring the issue:
echo "Using: $UNDEFINED_VAR"  # Empty string, potential bug
```

**Correct (parameter expansion):**

```bash
#!/bin/bash
set -u  # Error on undefined variables

# ${var:-default} - Use default if unset or empty
config_file="${CONFIG_FILE:-/etc/default.conf}"
timeout="${TIMEOUT:-30}"

# ${var:=default} - Set AND use default if unset or empty
: "${LOG_LEVEL:=info}"  # Sets LOG_LEVEL if not already set

# ${var:?message} - Error if unset or empty
input_file="${1:?Usage: $0 <input_file>}"

# ${var:+value} - Use value only if var IS set
# Useful for optional flags
verbose_flag="${VERBOSE:+--verbose}"
my_command $verbose_flag  # Only adds --verbose if VERBOSE is set
```

**Difference between :- and - (colon matters):**

```bash
#!/bin/bash
# With colon: treats empty string same as unset
empty_var=""
echo "${empty_var:-default}"   # Outputs: default
echo "${empty_var-default}"    # Outputs: (empty)

# ${var:-default} = use default if unset OR empty
# ${var-default}  = use default only if unset
```

**Common patterns:**

```bash
#!/bin/bash
# Script configuration with defaults
: "${DEBUG:=false}"
: "${LOG_DIR:=/var/log/myapp}"
: "${MAX_WORKERS:=4}"
: "${CONFIG_FILE:=/etc/myapp/config.ini}"

# Environment-based configuration
db_host="${DB_HOST:-localhost}"
db_port="${DB_PORT:-5432}"
db_name="${DB_NAME:-myapp}"

# Required parameters
: "${API_KEY:?Error: API_KEY environment variable is required}"

# Optional verbose mode
if [[ "${VERBOSE:-false}" == "true" ]]; then
  set -x
fi
```

**With arrays:**

```bash
#!/bin/bash
# Default array if not set
: "${TARGETS[*]:=localhost}"

# Or check array length
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=(localhost)
fi
```

Reference: [Bash Manual - Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
