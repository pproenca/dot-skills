---
title: Reproduce Before Debugging
impact: CRITICAL
impactDescription: Prevents 50%+ of wasted debugging time on unreproducible or misunderstood issues
tags: prob, reproduction, prerequisites, scientific-method
---

## Reproduce Before Debugging

Never start debugging until you can reliably reproduce the bug. Without reproduction, you cannot verify your fix works and may spend hours chasing phantom issues or misunderstanding the actual problem.

**Incorrect (jumping straight to code):**

```python
# Bug report: "App crashes sometimes when saving"
# Developer immediately starts reading save code...

def save_data(data):
    # Check if this null check helps
    if data is None:  # Add defensive check
        return False
    # Check the file permission
    with open(self.path, 'w') as f:  # Add try/except?
        json.dump(data, f)
    # Hours later: still no idea what causes the crash
```

**Correct (reproduce first):**

```python
# Bug report: "App crashes sometimes when saving"
# Step 1: Gather reproduction details

"""
Reproduction attempt log:
1. Fresh install, create new file, save -> OK
2. Open existing file, edit, save -> OK
3. Open large file (>10MB), edit, save -> CRASH!
4. Open large file, small edit, save -> CRASH!
5. Open large file, don't edit, save -> OK

Hypothesis: Crash occurs when saving edits to large files
Minimal reproduction: Open 15MB JSON file, change one character, save
"""

# NOW start debugging with a clear, reproducible case
```

**Reproduction checklist:**
- Document exact steps to trigger the bug
- Note environment details (OS, version, config)
- Identify the minimal reproduction case
- Confirm you can trigger it consistently (or note frequency if intermittent)

**When NOT to use this pattern:**
- Obvious typos or syntax errors visible in stack trace
- Build failures with clear error messages

Reference: [Why Programs Fail - Reproducing Problems](https://www.whyprogramsfail.com/)
