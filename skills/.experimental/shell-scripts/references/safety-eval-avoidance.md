---
title: Avoid eval for Dynamic Commands
impact: CRITICAL
impactDescription: eliminates code injection vector
tags: safety, eval, injection, security
---

## Avoid eval for Dynamic Commands

`eval` interprets its arguments as shell code, making it extremely dangerous with any variable data. Even carefully escaped data can be exploited through edge cases.

**Incorrect (using eval):**

```bash
#!/bin/bash
# Building command dynamically with eval
cmd="ls"
opts="-la"
dir="$1"

eval "$cmd $opts $dir"
# User passes: "; rm -rf /" → executes destructive command
```

**Correct (use arrays for command building):**

```bash
#!/bin/bash
# Build commands safely with arrays
declare -a cmd=(ls -la)
dir="$1"

# Add arguments safely
cmd+=("$dir")

# Execute without shell interpretation
"${cmd[@]}"
```

**Alternative (indirect variable expansion):**

```bash
#!/bin/bash
# When you need variable indirection
var_name="PATH"

# Instead of: eval "echo \$$var_name"
# Use bash indirect expansion:
echo "${!var_name}"

# For associative data, use associative arrays:
declare -A config
config[database]="mydb"
config[host]="localhost"

key="database"
echo "${config[$key]}"
```

**When eval seems necessary, alternatives exist:**
- Command building → arrays with `"${array[@]}"`
- Variable indirection → `${!var}` or `declare -n`
- Dynamic assignment → `declare "$name=$value"`
- Arithmetic → `$(( expression ))`

Reference: [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
