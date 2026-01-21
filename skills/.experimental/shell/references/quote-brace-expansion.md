---
title: Use Braces for Variable Clarity
impact: MEDIUM-HIGH
impactDescription: prevents ambiguous variable boundaries
tags: quote, braces, variables, expansion, clarity
---

## Use Braces for Variable Clarity

Without braces, variable boundaries are ambiguous. `$var_suffix` looks for variable `var_suffix`, not `$var` + `_suffix`. Braces make boundaries explicit.

**Incorrect (ambiguous boundaries):**

```bash
#!/bin/bash
prefix="file"
# What variable is this?
echo $prefix_name.txt    # Looks for $prefix_name, not $prefix
echo $prefix1            # Looks for $prefix1, not $prefix + "1"

# Array access without braces fails
files=(one two three)
echo $files[0]           # Wrong: prints "one[0]"
```

**Correct (explicit braces):**

```bash
#!/bin/bash
prefix="file"
echo "${prefix}_name.txt"  # Clear: $prefix + "_name.txt"
echo "${prefix}1"          # Clear: $prefix + "1"

# Array access requires braces
files=(one two three)
echo "${files[0]}"         # Correct: prints "one"
echo "${files[@]}"         # All elements
echo "${#files[@]}"        # Array length
```

**When braces are required:**

```bash
#!/bin/bash
var="value"

# Adjacent to valid identifier characters
echo "${var}_suffix"      # Required
echo "${var}123"          # Required
echo "${var}text"         # Required

# Array operations
echo "${array[0]}"        # Required
echo "${array[@]}"        # Required
echo "${#array[@]}"       # Required

# Parameter expansion operations
echo "${var:-default}"    # Required
echo "${var:0:5}"         # Required (substring)
echo "${var^^}"           # Required (uppercase)
echo "${var//old/new}"    # Required (substitution)
```

**When braces are optional but recommended:**

```bash
#!/bin/bash
# Optional but clearer
echo "${var}"             # Consistent style
echo "${1}"               # Positional parameters

# Can omit for simple cases
echo "$var"               # OK if followed by space/newline
echo "$1 $2 $3"           # OK with spaces

# Special parameters (braces optional)
echo "$?"                 # Exit status
echo "$$"                 # PID
echo "$!"                 # Background PID
```

**Consistency recommendation:**

```bash
#!/bin/bash
# Google Style Guide recommends:
# - Always use braces: "${var}"
# - Exception: simple $1, $2, etc. in clear context

# This is acceptable:
echo "Processing $1"
for arg in "$@"; do ...

# But this is clearer and safer:
echo "Processing ${1}"
echo "File: ${filename}"
```

Reference: [Google Shell Style Guide - Quoting](https://google.github.io/styleguide/shellguide.html)
