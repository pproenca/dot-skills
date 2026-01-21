---
title: Prefer Functions Over Aliases
impact: MEDIUM
impactDescription: enables arguments and proper scoping
tags: func, aliases, reusability, arguments
---

## Prefer Functions Over Aliases

Aliases are simple text substitution with limitations: no arguments in the middle, no local variables, unpredictable expansion. Functions handle all cases properly.

**Incorrect (using aliases):**

```bash
#!/bin/bash
# Aliases have severe limitations

# Can't use arguments in the middle
alias greet='echo "Hello, $1"'
greet World  # Prints "Hello, " then "World" as separate command

# Alias expands unexpectedly
alias rm='rm -i'
# Then: rm -f file.txt
# Becomes: rm -i -f file.txt (not what you expected)

# Can't use local variables or logic
alias random_name='echo "prefix_${RANDOM}"'
# RANDOM evaluated at definition time, not call time!

# Can't have multi-line logic
alias complex='cmd1 && cmd2'  # Works but ugly
```

**Correct (use functions):**

```bash
#!/bin/bash
# Functions solve all alias limitations

# Arguments work naturally
greet() {
  echo "Hello, $1"
}
greet World  # Prints "Hello, World"

# Logic and local variables
safe_rm() {
  local file="$1"
  if [[ -f "$file" ]]; then
    rm -i "$file"
  else
    echo "File not found: $file" >&2
    return 1
  fi
}

# Dynamic values evaluated at call time
random_name() {
  echo "prefix_${RANDOM}"
}
random_name  # Different each time

# Multi-line logic is clean
backup_and_edit() {
  local file="$1"
  cp "$file" "${file}.bak"
  "${EDITOR:-vim}" "$file"
}
```

**When aliases are acceptable:**

```bash
# Interactive shell shortcuts (in .bashrc, NOT scripts)
alias ll='ls -la'
alias ..='cd ..'
alias grep='grep --color=auto'

# These are OK because:
# - Used interactively, not in scripts
# - Simple substitution is sufficient
# - No arguments needed in middle
```

**Converting aliases to functions:**

```bash
# Alias version (limited)
alias gitlog='git log --oneline -n 10'

# Function version (flexible)
gitlog() {
  local count="${1:-10}"
  git log --oneline -n "$count"
}
gitlog      # Shows 10
gitlog 20   # Shows 20

# Alias with complex options
alias findbig='find . -size +10M -exec ls -lh {} \;'

# Function version (configurable)
findbig() {
  local size="${1:-10M}"
  local dir="${2:-.}"
  find "$dir" -size "+$size" -exec ls -lh {} \;
}
findbig         # Default: 10M in current dir
findbig 100M /var  # 100M in /var
```

**Functions can call functions:**

```bash
#!/bin/bash
# Composition that aliases can't do
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

info() { log "INFO: $*"; }
warn() { log "WARN: $*"; }
error() { log "ERROR: $*"; }

info "Starting process"
warn "Low disk space"
error "Connection failed"
```

Reference: [Google Shell Style Guide - Features to Avoid](https://google.github.io/styleguide/shellguide.html)
