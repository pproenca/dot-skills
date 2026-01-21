---
title: Use Correct File Test Operators
impact: MEDIUM
impactDescription: prevents logic errors with symlinks and special files
tags: test, files, operators, symlinks
---

## Use Correct File Test Operators

Different file tests check different things. Using `-e` when you need `-f` accepts directories. Not checking `-L` misses symlink-specific issues.

**Incorrect (wrong operator):**

```bash
#!/bin/bash
# -e accepts directories, devices, symlinks
if [[ -e "$path" ]]; then
  cat "$path"  # Fails if it's a directory!
fi

# Doesn't handle broken symlinks
if [[ -f "$link" ]]; then
  # False for broken symlinks (target doesn't exist)
  process "$link"
fi

# Checking read without checking existence
if [[ -r "$file" ]]; then
  cat "$file"  # -r is false for non-existent, but error message unclear
fi
```

**Correct (appropriate operators):**

```bash
#!/bin/bash
# Check specific file type
if [[ -f "$path" ]]; then
  # Regular file only
  cat "$path"
fi

if [[ -d "$path" ]]; then
  # Directory only
  ls "$path"
fi

# Chain checks for clarity
if [[ -f "$file" && -r "$file" ]]; then
  cat "$file"
fi

# Handle symlinks explicitly
if [[ -L "$path" ]]; then
  echo "It's a symbolic link"
  if [[ -e "$path" ]]; then
    echo "Link target exists"
  else
    echo "Broken symlink!"
  fi
fi
```

**File test operators reference:**

```bash
#!/bin/bash
# Existence tests
[[ -e "$f" ]]    # Exists (any type)
[[ -f "$f" ]]    # Regular file
[[ -d "$f" ]]    # Directory
[[ -L "$f" ]]    # Symbolic link (doesn't follow)
[[ -h "$f" ]]    # Symbolic link (same as -L)
[[ -p "$f" ]]    # Named pipe (FIFO)
[[ -S "$f" ]]    # Socket
[[ -b "$f" ]]    # Block device
[[ -c "$f" ]]    # Character device

# Permission tests
[[ -r "$f" ]]    # Readable
[[ -w "$f" ]]    # Writable
[[ -x "$f" ]]    # Executable
[[ -u "$f" ]]    # SUID bit set
[[ -g "$f" ]]    # SGID bit set
[[ -k "$f" ]]    # Sticky bit set

# Size tests
[[ -s "$f" ]]    # Non-empty file (size > 0)

# Comparison tests
[[ "$f1" -nt "$f2" ]]   # f1 newer than f2
[[ "$f1" -ot "$f2" ]]   # f1 older than f2
[[ "$f1" -ef "$f2" ]]   # Same file (hard link or same inode)

# Special tests
[[ -t 0 ]]       # stdin is terminal
[[ -t 1 ]]       # stdout is terminal
```

**Common patterns:**

```bash
#!/bin/bash
# Safe file processing
process_file() {
  local file="$1"

  if [[ ! -e "$file" ]]; then
    echo "Error: File does not exist: $file" >&2
    return 1
  fi

  if [[ -d "$file" ]]; then
    echo "Error: Expected file, got directory: $file" >&2
    return 1
  fi

  if [[ ! -r "$file" ]]; then
    echo "Error: Cannot read file: $file" >&2
    return 1
  fi

  cat "$file"
}

# Directory creation with check
ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir" || return 1
  fi
}

# Detect terminal vs pipe
if [[ -t 1 ]]; then
  # stdout is terminal - use colors
  echo -e "\033[32mSuccess\033[0m"
else
  # stdout is piped - plain text
  echo "Success"
fi
```

Reference: [Bash Manual - Conditional Expressions](https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html)
