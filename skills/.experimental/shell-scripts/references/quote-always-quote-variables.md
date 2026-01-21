---
title: Always Quote Variable Expansions
impact: MEDIUM-HIGH
impactDescription: prevents word splitting and glob expansion bugs
tags: quote, variables, word-splitting, globbing
---

## Always Quote Variable Expansions

Unquoted variables undergo word splitting (on IFS) and pathname expansion (globbing). A filename with spaces becomes multiple arguments; `*` expands to all files.

**Incorrect (unquoted variables):**

```bash
#!/bin/bash
file="my file.txt"
rm $file             # Tries to remove "my" and "file.txt"

pattern="*.log"
echo $pattern        # Expands to all .log files!

dir="/path/with spaces"
cd $dir              # Fails: /path/with and spaces are separate

# Dangerous with user input
user_input="foo; rm -rf /"
grep $user_input file.txt
```

**Correct (quoted variables):**

```bash
#!/bin/bash
file="my file.txt"
rm "$file"           # Removes "my file.txt"

pattern="*.log"
echo "$pattern"      # Prints literal "*.log"

dir="/path/with spaces"
cd "$dir"            # Changes to "/path/with spaces"

# Safe with user input
user_input="foo; rm -rf /"
grep "$user_input" file.txt  # Searches for literal string
```

**When NOT to quote:**

```bash
#!/bin/bash
# Intentional globbing - document it!
# shellcheck disable=SC2086
for file in $file_glob; do
  process "$file"
done

# Integer arithmetic context (already unquoted)
count=5
(( count++ ))
if (( count > 10 )); then
  echo "Done"
fi

# Array expansion with [@] already handles it
files=("one" "two" "three")
process "${files[@]}"  # Already properly split
```

**Variable expansion in different contexts:**

```bash
#!/bin/bash
var="value"

# Always quote in these contexts:
echo "$var"
[[ "$var" == "value" ]]
if [ -n "$var" ]; then ...; fi
cmd --option="$var"
cmd --option "$var"

# Brace syntax is preferred for clarity
echo "${var}"
echo "${var}_suffix"

# Inside [[ ]], right side of == can be unquoted for patterns
[[ "$var" == val* ]]  # Pattern match (unquoted)
[[ "$var" == "val*" ]] # Literal match (quoted)
```

Reference: [ShellCheck SC2086](https://www.shellcheck.net/wiki/SC2086)
