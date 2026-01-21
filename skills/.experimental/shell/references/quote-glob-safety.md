---
title: Control Glob Expansion Explicitly
impact: MEDIUM-HIGH
impactDescription: prevents unintended file matching in commands
tags: quote, glob, wildcards, expansion, nullglob
---

## Control Glob Expansion Explicitly

Unquoted wildcards expand to matching files. If no files match, the literal pattern is passed (error-prone). If too many match, argument limits may be exceeded.

**Incorrect (uncontrolled globbing):**

```bash
#!/bin/bash
pattern="*.log"
rm $pattern        # Expands - might delete wrong files
echo $pattern      # Prints filenames, not pattern

# No matches: literal passed
rm *.xyz           # If no .xyz files: rm "*.xyz" (error)

# In find, glob should NOT expand
find . -name *.log # Shell expands BEFORE find sees it!
```

**Correct (controlled globbing):**

```bash
#!/bin/bash
# Quote to prevent expansion
pattern="*.log"
echo "$pattern"    # Prints "*.log" literally

# Let find handle the pattern
find . -name "*.log"   # find sees "*.log" pattern
find . -name '*.log'   # Single quotes also work

# Intentional glob with safety
shopt -s nullglob      # No matches = empty list
for file in *.log; do
  rm "$file"           # Only runs if files exist
done
```

**nullglob and failglob:**

```bash
#!/bin/bash
# Default: unmatched glob is passed literally
echo *.nonexistent   # Prints "*.nonexistent"

# nullglob: unmatched glob expands to nothing
shopt -s nullglob
echo *.nonexistent   # Prints nothing
for f in *.nonexistent; do
  echo "$f"          # Loop body never runs
done

# failglob: unmatched glob is an error
shopt -s failglob
echo *.nonexistent   # Error: no match

# Restore defaults
shopt -u nullglob failglob
```

**Safe iteration over files:**

```bash
#!/bin/bash
shopt -s nullglob  # Set once at script start

# Safe - no iteration if no matches
for file in /path/to/logs/*.log; do
  process "$file"
done

# Safe array building
files=(/path/to/logs/*.log)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No log files found"
else
  process_files "${files[@]}"
fi
```

**Extended globs:**

```bash
#!/bin/bash
shopt -s extglob nullglob

# Extended patterns (bash only)
echo *.@(jpg|png|gif)     # Match .jpg, .png, or .gif
echo !(*.log)             # Match everything except .log
echo *.+(o|a)             # One or more of .o or .a
echo file?.txt            # Single character wildcard
echo file[0-9].txt        # Character class
```

**Glob in case statements:**

```bash
#!/bin/bash
# Globs work in case patterns without expansion
case "$filename" in
  *.tar.gz|*.tgz)
    tar -xzf "$filename"
    ;;
  *.zip)
    unzip "$filename"
    ;;
  *)
    echo "Unknown format"
    ;;
esac
```

Reference: [Greg's Wiki - Glob](https://mywiki.wooledge.org/glob)
