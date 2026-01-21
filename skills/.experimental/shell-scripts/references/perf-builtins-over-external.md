---
title: Use Builtins Over External Commands
impact: LOW-MEDIUM
impactDescription: 10-100× faster by avoiding fork/exec overhead
tags: perf, builtins, external, fork
---

## Use Builtins Over External Commands

Every external command spawns a new process (fork + exec). In loops, this overhead multiplies. Builtins execute in the same process, avoiding this cost.

**Incorrect (external commands in loops):**

```bash
#!/bin/bash
# Each iteration spawns external processes
for i in $(seq 1 1000); do          # External: seq
  result=$(expr $i + 1)              # External: expr
  echo "$result" | cat >> output     # External: cat
done
# Total: 3000+ process spawns!

# Using external commands for simple operations
if [ "$(echo "$var" | wc -c)" -gt 10 ]; then
  echo "long"
fi
```

**Correct (use builtins):**

```bash
#!/bin/bash
# Builtins - no process spawning
for ((i = 1; i <= 1000; i++)); do    # Builtin: (( ))
  ((result = i + 1))                  # Builtin: (( ))
  echo "$result" >> output            # Builtin: echo, redirection
done
# Total: 0 external processes

# Parameter expansion instead of external commands
if [[ ${#var} -gt 10 ]]; then
  echo "long"
fi
```

**Common replacements:**

```bash
#!/bin/bash
# Arithmetic
# BAD:  result=$(expr $a + $b)
# GOOD: ((result = a + b))

# String length
# BAD:  len=$(echo "$str" | wc -c)
# GOOD: len=${#str}

# Substring
# BAD:  sub=$(echo "$str" | cut -c1-5)
# GOOD: sub=${str:0:5}

# Basename
# BAD:  name=$(basename "$path")
# GOOD: name=${path##*/}

# Dirname
# BAD:  dir=$(dirname "$path")
# GOOD: dir=${path%/*}

# Search and replace
# BAD:  new=$(echo "$str" | sed 's/old/new/g')
# GOOD: new=${str//old/new}

# Upper/lowercase (bash 4+)
# BAD:  lower=$(echo "$str" | tr 'A-Z' 'a-z')
# GOOD: lower=${str,,}
# GOOD: upper=${str^^}

# Sequence generation
# BAD:  for i in $(seq 1 10); do
# GOOD: for ((i = 1; i <= 10; i++)); do

# Reading files line by line
# BAD:  cat file | while read line; do
# GOOD: while read -r line; do ... done < file
```

**Check if command is builtin:**

```bash
#!/bin/bash
# type shows if command is builtin
type echo      # echo is a shell builtin
type cat       # cat is /bin/cat
type [[        # [[ is a shell keyword

# Use help for builtin documentation
help echo
help read
help printf
```

**When external commands are fine:**

```bash
#!/bin/bash
# Outside loops - one-time cost is negligible
date=$(date +%Y-%m-%d)
hostname=$(hostname)

# Complex text processing - sed/awk are optimized
# Piping many lines through sed is faster than bash loop
sed 's/old/new/g' large_file.txt

# When builtin doesn't exist or is limited
# sort, uniq, grep for large data sets
```

Reference: [Advanced Bash Scripting Guide - Builtins](https://tldp.org/LDP/abs/html/internal.html)
