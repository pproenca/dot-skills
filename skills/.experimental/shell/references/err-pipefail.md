---
title: Use pipefail to Catch Pipeline Errors
impact: HIGH
impactDescription: detects failures hidden in pipeline stages
tags: err, pipefail, pipestatus, pipes
---

## Use pipefail to Catch Pipeline Errors

By default, a pipeline's exit status is the exit status of the last command. Failures in earlier commands are silently ignored, leading to corrupt or incomplete data.

**Incorrect (pipeline hides errors):**

```bash
#!/bin/bash
# curl fails but grep succeeds with empty input
# Script reports success!
curl http://invalid-url 2>/dev/null | grep "data" > results.txt
echo "Exit status: $?"  # Shows 0 (grep's status)

# Processing corrupt/incomplete data
failing_command | process_data | save_results
# Only save_results status is checked
```

**Correct (pipefail catches failures):**

```bash
#!/bin/bash
set -o pipefail

# Now pipeline fails if ANY command fails
curl http://invalid-url 2>/dev/null | grep "data" > results.txt
echo "Exit status: $?"  # Shows non-zero (curl's status)
```

**Check individual pipeline stages:**

```bash
#!/bin/bash
# PIPESTATUS array holds exit codes of all pipeline commands
producer | filter | consumer

# Check each stage
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  echo "Producer failed" >&2
fi
if [[ ${PIPESTATUS[1]} -ne 0 ]]; then
  echo "Filter failed" >&2
fi
if [[ ${PIPESTATUS[2]} -ne 0 ]]; then
  echo "Consumer failed" >&2
fi
```

**PIPESTATUS must be read immediately:**

```bash
#!/bin/bash
producer | consumer

# WRONG: PIPESTATUS is already overwritten
echo "Checking status"
echo "${PIPESTATUS[@]}"  # Shows status of echo!

# CORRECT: Capture immediately
producer | consumer
pipe_status=("${PIPESTATUS[@]}")  # Save immediately
echo "Producer: ${pipe_status[0]}, Consumer: ${pipe_status[1]}"
```

**Alternative without pipefail:**

```bash
#!/bin/bash
# When you can't use pipefail, use process substitution
# to get the producer's exit status

producer > >(consumer)
producer_status=$?
```

Reference: [Greg's Wiki - BashFAQ/105](https://mywiki.wooledge.org/BashFAQ/105)
