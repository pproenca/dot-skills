---
title: Use Arrays for Lists Instead of Strings
impact: HIGH
impactDescription: prevents word splitting bugs in argument handling
tags: var, arrays, lists, arguments, word-splitting
---

## Use Arrays for Lists Instead of Strings

Storing lists in strings leads to word splitting issues with spaces, requires fragile quoting, and often forces unsafe `eval` usage. Arrays handle all edge cases correctly.

**Incorrect (string-based lists):**

```bash
#!/bin/bash
# Breaks with spaces in filenames
files="file1.txt file2.txt my file.txt"
for f in $files; do
  echo "$f"  # "my" and "file.txt" are separate!
done

# Building commands in strings
cmd="ls -la"
opts="-h"
$cmd $opts  # Breaks with complex arguments
cmd="grep 'hello world'"  # Quotes don't survive expansion
```

**Correct (use arrays):**

```bash
#!/bin/bash
# Arrays preserve elements with spaces
files=("file1.txt" "file2.txt" "my file.txt")
for f in "${files[@]}"; do
  echo "$f"  # Correctly handles "my file.txt"
done

# Building commands safely
declare -a cmd=(ls -la)
cmd+=(-h)
"${cmd[@]}"  # Executes correctly

# Arguments with spaces work
declare -a grep_args=(-r "hello world" .)
grep "${grep_args[@]}"
```

**Array operations:**

```bash
#!/bin/bash
# Declaration
declare -a empty_array=()
declare -a with_values=("one" "two" "three")

# Append
with_values+=("four")
with_values+=("five" "six")  # Append multiple

# Length
echo "Count: ${#with_values[@]}"

# Iterate
for item in "${with_values[@]}"; do
  process "$item"
done

# Access by index
echo "First: ${with_values[0]}"
echo "Last: ${with_values[-1]}"

# Slice
echo "Middle: ${with_values[@]:1:2}"  # Elements 1-2

# All indices
for i in "${!with_values[@]}"; do
  echo "Index $i: ${with_values[i]}"
done
```

**Read files into array safely:**

```bash
#!/bin/bash
# Handle filenames with spaces, newlines, etc.
declare -a files=()
while IFS= read -r -d '' file; do
  files+=("$file")
done < <(find . -type f -print0)

# Process safely
for file in "${files[@]}"; do
  process "$file"
done
```

Reference: [Google Shell Style Guide - Arrays](https://google.github.io/styleguide/shellguide.html)
