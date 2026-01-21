---
title: Use Parameter Expansion for String Operations
impact: LOW-MEDIUM
impactDescription: avoids external commands for common transformations
tags: perf, parameter-expansion, strings, substitution
---

## Use Parameter Expansion for String Operations

External commands like `basename`, `dirname`, `sed`, `cut` spawn processes. Parameter expansion handles most string operations as builtins, eliminating fork overhead.

**Incorrect (external commands):**

```bash
#!/bin/bash
path="/home/user/documents/report.txt"

# External commands for string manipulation
filename=$(basename "$path")        # Spawns process
directory=$(dirname "$path")        # Spawns process
extension=$(echo "$path" | sed 's/.*\.//')  # Two processes
name=$(echo "$filename" | sed 's/\.[^.]*$//')  # Two processes
upper=$(echo "$str" | tr 'a-z' 'A-Z')  # Two processes
```

**Correct (parameter expansion):**

```bash
#!/bin/bash
path="/home/user/documents/report.txt"

# Builtins - no external processes
filename=${path##*/}                # report.txt
directory=${path%/*}                # /home/user/documents
extension=${path##*.}               # txt
name=${filename%.*}                 # report
upper=${str^^}                      # UPPERCASE (bash 4+)
lower=${str,,}                      # lowercase (bash 4+)
```

**Parameter expansion reference:**

```bash
#!/bin/bash
var="hello.world.txt"

# Remove prefix (shortest match)
${var#*.}          # world.txt

# Remove prefix (longest match)
${var##*.}         # txt

# Remove suffix (shortest match)
${var%.*}          # hello.world

# Remove suffix (longest match)
${var%%.*}         # hello

# Substitution (first occurrence)
${var/world/there}  # hello.there.txt

# Substitution (all occurrences)
${var//./-}         # hello-world-txt

# Length
${#var}             # 15

# Substring
${var:0:5}          # hello
${var:6}            # world.txt
${var: -3}          # txt (note the space before -)
${var:(-3)}         # txt (alternative)

# Case conversion (bash 4+)
${var^}             # Hello.world.txt (first char upper)
${var^^}            # HELLO.WORLD.TXT (all upper)
${var,}             # hello.world.txt (first char lower)
${var,,}            # hello.world.txt (all lower)
```

**Common use cases:**

```bash
#!/bin/bash
# Extract filename and extension
filepath="/path/to/image.tar.gz"
filename=${filepath##*/}        # image.tar.gz
dir=${filepath%/*}              # /path/to
base=${filename%%.*}            # image
ext=${filename#*.}              # tar.gz

# Change extension
newfile=${filepath%.tar.gz}.zip  # /path/to/image.zip

# Strip leading/trailing whitespace (bash 4.4+)
trimmed=${string#"${string%%[![:space:]]*}"}
trimmed=${trimmed%"${trimmed##*[![:space:]]}"}

# Or simpler with read
read -r trimmed <<< "$string"

# Add prefix/suffix to all elements
files=(*.txt)
prefixed=("${files[@]/#/backup_}")  # backup_file1.txt ...
suffixed=("${files[@]/%/.bak}")     # file1.txt.bak ...

# Check prefix/suffix
if [[ "$var" == prefix* ]]; then
  echo "Starts with prefix"
fi
if [[ "$var" == *suffix ]]; then
  echo "Ends with suffix"
fi
```

**Default values:**

```bash
#!/bin/bash
# Use default if unset or empty
${var:-default}

# Set default if unset or empty
${var:=default}

# Error if unset or empty
${var:?error message}

# Use alternate if set
${var:+alternate}
```

Reference: [Bash Manual - Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
