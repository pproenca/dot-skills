---
title: Use Process Substitution for Temp Files
impact: LOW-MEDIUM
impactDescription: eliminates file I/O and cleanup overhead
tags: perf, process-substitution, temp-files, pipes
---

## Use Process Substitution for Temp Files

Creating temp files for intermediate data requires file I/O and cleanup. Process substitution `<()` and `>()` provides files that are actually pipes, avoiding disk overhead.

**Incorrect (temp files for intermediate data):**

```bash
#!/bin/bash
# Creating temp files is slow and needs cleanup
sorted1=$(mktemp)
sorted2=$(mktemp)
trap 'rm -f "$sorted1" "$sorted2"' EXIT

sort file1.txt > "$sorted1"
sort file2.txt > "$sorted2"
diff "$sorted1" "$sorted2"

# Multiple intermediates
grep "pattern1" input > /tmp/step1.$$
grep "pattern2" /tmp/step1.$$ > /tmp/step2.$$
wc -l /tmp/step2.$$
rm /tmp/step1.$$ /tmp/step2.$$
```

**Correct (process substitution):**

```bash
#!/bin/bash
# No temp files, no cleanup needed
diff <(sort file1.txt) <(sort file2.txt)

# Chain processing without files
wc -l <(grep "pattern2" <(grep "pattern1" input))

# Or simpler with pipes for linear chains
grep "pattern1" input | grep "pattern2" | wc -l
```

**Process substitution types:**

```bash
#!/bin/bash
# <(command) - command output as file (reading)
# Compare output of two commands
diff <(ls dir1) <(ls dir2)

# Feed multiple sources to command expecting files
paste <(cut -f1 file1) <(cut -f2 file2)

# >(command) - write to command as file (writing)
# Tee to multiple processors
./generate_data | tee >(grep "error" > errors.log) >(grep "warn" > warns.log)

# Avoid file for single-use data
command > >(process_output)
```

**Practical examples:**

```bash
#!/bin/bash
# Compare sorted versions of files
diff <(sort -u file1.txt) <(sort -u file2.txt)

# Compare remote and local files
diff <(curl -s http://example.com/file) local_file.txt

# Join data from different sources
join <(sort file1.txt) <(sort file2.txt)

# Feed compressed data to commands expecting files
zcat large_file.gz > temp.txt
wc -l temp.txt
rm temp.txt
# Better:
wc -l <(zcat large_file.gz)

# Source from process output
source <(generate_config)

# Compare directory listings with filters
diff <(ls -la dir1 | awk '{print $9, $5}') \
     <(ls -la dir2 | awk '{print $9, $5}')
```

**Combining with while loops:**

```bash
#!/bin/bash
# Reading from process - keeps variables in main shell
count=0
while read -r line; do
  ((count++))
  process "$line"
done < <(find . -name "*.txt")
echo "Processed $count files"

# Without process substitution, need temp file or lost variables
```

**Limitations:**

```bash
#!/bin/bash
# Process substitution is bash/ksh/zsh only - not POSIX
# In POSIX sh, use temp files or pipes

# Can't seek in process substitution (it's a pipe)
# This won't work:
head -1 <(generate_data)
tail -1 <(generate_data)  # Data is gone!

# Instead:
data=$(generate_data)
echo "$data" | head -1
echo "$data" | tail -1
```

Reference: [Bash Manual - Process Substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html)
