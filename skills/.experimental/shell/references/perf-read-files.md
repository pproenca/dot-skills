---
title: Read Files Efficiently
impact: LOW-MEDIUM
impactDescription: prevents O(n) line reads and subshell overhead
tags: perf, files, reading, loops
---

## Read Files Efficiently

Reading files line-by-line in bash is slow. For large files, use specialized tools (awk, sed, grep). When shell processing is needed, use efficient patterns.

**Incorrect (slow patterns):**

```bash
#!/bin/bash
# Spawns cat + creates subshell
cat file.txt | while read -r line; do
  process "$line"
done

# Reading file multiple times
line_count=$(wc -l < file.txt)
first_line=$(head -1 file.txt)
last_line=$(tail -1 file.txt)

# Processing large files in shell loop
while read -r line; do
  echo "${line//old/new}"
done < large_file.txt  # Extremely slow
```

**Correct (efficient patterns):**

```bash
#!/bin/bash
# Direct redirection - no cat, no subshell variable loss
while IFS= read -r line; do
  process "$line"
done < file.txt

# Read entire file at once for small files
content=$(<file.txt)

# Read into array
mapfile -t lines < file.txt
for line in "${lines[@]}"; do
  process "$line"
done

# Use awk/sed for large file transformations
sed 's/old/new/g' large_file.txt > output.txt
awk '{print $1, $3}' large_file.txt > output.txt
```

**Choosing the right approach:**

```bash
#!/bin/bash
# Small files (< 100 lines) - shell is fine
while IFS= read -r line; do
  # Shell processing OK
done < small_file.txt

# Medium files (100-10000 lines) - consider awk/sed
# If you need shell variables, mapfile is good
mapfile -t lines < medium_file.txt

# Large files (> 10000 lines) - always use awk/sed/grep
# Shell loops are too slow
grep "pattern" huge_file.txt | head -100
awk '/pattern/ {print $2}' huge_file.txt
```

**Reading specific parts:**

```bash
#!/bin/bash
# First N lines
head -n 10 file.txt

# Last N lines
tail -n 10 file.txt

# Lines M to N
sed -n '5,10p' file.txt

# Read first line into variable
IFS= read -r first_line < file.txt

# Read first N lines into array
mapfile -t first_10 -n 10 < file.txt
```

**Handling special characters:**

```bash
#!/bin/bash
# IFS= prevents leading/trailing whitespace trimming
# -r prevents backslash interpretation
while IFS= read -r line; do
  echo "[$line]"  # Preserves exact content
done < file.txt

# Handle files without final newline
while IFS= read -r line || [[ -n "$line" ]]; do
  process "$line"
done < file.txt

# Handle null-separated data (find -print0)
while IFS= read -r -d '' file; do
  process "$file"
done < <(find . -name "*.txt" -print0)
```

**Processing fields efficiently:**

```bash
#!/bin/bash
# Parse fields in one read
while IFS=: read -r user _ uid gid _ home shell; do
  echo "User $user uses $shell"
done < /etc/passwd

# Process CSV
while IFS=, read -r field1 field2 field3; do
  process "$field1" "$field2" "$field3"
done < data.csv

# But for complex CSV, use a real parser
# Bash can't handle quoted fields with embedded commas
```

Reference: [Greg's Wiki - BashFAQ/001](https://mywiki.wooledge.org/BashFAQ/001)
