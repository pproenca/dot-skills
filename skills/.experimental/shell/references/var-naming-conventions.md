---
title: Follow Variable Naming Conventions
impact: HIGH
impactDescription: prevents collisions with environment and builtins
tags: var, naming, conventions, constants, environment
---

## Follow Variable Naming Conventions

Inconsistent naming causes collisions with environment variables and makes code harder to read. Following conventions prevents bugs and improves maintainability.

**Incorrect (inconsistent naming):**

```bash
#!/bin/bash
# Collides with environment variables
PATH="/my/files"  # Breaks command execution!
HOME="/tmp"       # Breaks ~ expansion!
USER="admin"      # May conflict

# Inconsistent style
fileName="test.txt"
file_count=0
FILESIZE=1024
```

**Correct (follow conventions):**

```bash
#!/bin/bash
# Constants and environment exports: UPPER_CASE
readonly CONFIG_PATH="/etc/myapp"
readonly MAX_RETRIES=3
export MY_APP_DEBUG=1

# Regular variables: lower_case
file_name="test.txt"
file_count=0
file_size=1024

# Loop variables: lower_case
for file in "${files[@]}"; do
  process "$file"
done
```

**Naming conventions summary:**

```bash
#!/bin/bash

# CONSTANTS (readonly, set once)
readonly DATABASE_URL="postgres://localhost/db"
readonly MAX_CONNECTIONS=100

# ENVIRONMENT VARIABLES (exported)
export MY_APP_CONFIG="/etc/myapp.conf"
export MY_APP_LOG_LEVEL="info"

# Regular variables (script-local)
input_file=""
output_dir=""
line_count=0

# Function-local variables
my_function() {
  local temp_file
  local result_code
}

# Private/internal variables (convention: leading underscore)
_internal_state=""
_cache_valid=false
```

**Avoid collisions:**

```bash
#!/bin/bash
# Dangerous - common environment variables
# PATH, HOME, USER, SHELL, PWD, OLDPWD
# IFS, PS1, PS2, TERM, EDITOR, LANG

# Use prefixes for your variables
readonly MY_APP_PATH="/opt/myapp"
readonly MY_APP_CONFIG="/etc/myapp"

# Or use descriptive names that won't collide
readonly config_file_path="/etc/myapp/config"
readonly installation_directory="/opt/myapp"
```

**Boolean naming pattern:**

```bash
#!/bin/bash
# Use is_, has_, should_ prefixes for booleans
is_verbose=false
has_errors=false
should_continue=true

if [[ "$is_verbose" == true ]]; then
  echo "Verbose mode enabled"
fi
```

Reference: [Google Shell Style Guide - Naming Conventions](https://google.github.io/styleguide/shellguide.html)
