---
title: Avoid Unnecessary Subshells
impact: LOW-MEDIUM
impactDescription: reduces fork overhead and variable scope issues
tags: perf, subshells, fork, pipes
---

## Avoid Unnecessary Subshells

Subshells create new processes with copied state. Pipelines, `$()`, and `()` create subshells. Variables modified in subshells are lost when they exit.

**Incorrect (unnecessary subshells):**

```bash
#!/bin/bash
# Pipeline creates subshell - variable lost
cat file.txt | while read -r line; do
  ((count++))
done
echo "Count: $count"  # Still 0! count modified in subshell

# Useless use of cat creates subshell
cat file | grep pattern

# Command substitution for simple output
echo $(pwd)

# Unnecessary ( ) grouping
(cd /tmp && rm -f *.log)  # cd affects only subshell
```

**Correct (avoid subshells):**

```bash
#!/bin/bash
# Process substitution keeps loop in main shell
while read -r line; do
  ((count++))
done < <(cat file.txt)
echo "Count: $count"  # Correct value

# Or redirect directly
while read -r line; do
  ((count++))
done < file.txt

# Remove useless cat
grep pattern file

# Variable instead of command substitution
echo "$PWD"

# Use { } for grouping without subshell
{
  cd /tmp && rm -f *.log
}  # cd affects current shell!

# Or be explicit about wanting subshell isolation
(
  cd /tmp  # Only affects subshell
  rm -f *.log
)
# Still in original directory here
```

**When subshells are created:**

```bash
#!/bin/bash
# Pipeline (each command in pipeline)
cmd1 | cmd2 | cmd3  # Three subshells

# Command substitution
var=$(command)      # One subshell

# Explicit subshell
( commands )        # One subshell

# Process substitution
<(command)          # One subshell
>(command)          # One subshell

# Background processes
command &           # One subshell
```

**Passing data from subshells:**

```bash
#!/bin/bash
# Problem: Can't use variables from subshell
echo "hello" | read -r var
echo "$var"  # Empty!

# Solution 1: Here-string
read -r var <<< "hello"
echo "$var"  # "hello"

# Solution 2: Process substitution
read -r var < <(echo "hello")
echo "$var"  # "hello"

# Solution 3: File or named pipe
command > /tmp/output.$$
read -r var < /tmp/output.$$
rm /tmp/output.$$

# Solution 4: Command output to array
mapfile -t lines < <(command)
for line in "${lines[@]}"; do
  process "$line"
done
```

**Check subshell level:**

```bash
#!/bin/bash
echo "Main: $BASH_SUBSHELL"  # 0
(
  echo "Subshell: $BASH_SUBSHELL"  # 1
  (
    echo "Nested: $BASH_SUBSHELL"  # 2
  )
)
```

**Intentional subshell uses:**

```bash
#!/bin/bash
# Isolate cd - don't affect main script
(cd /some/dir && do_work)

# Isolate variable changes
(
  export TEMP_VAR="value"
  run_with_temp_env
)
# TEMP_VAR doesn't exist here

# Parallel execution
(slow_task1) &
(slow_task2) &
wait
```

Reference: [Greg's Wiki - SubShell](https://mywiki.wooledge.org/SubShell)
