---
title: Verify Fix With Original Reproduction
impact: MEDIUM
impactDescription: Confirms fix actually works; prevents false confidence from unrelated changes
tags: verify, reproduction, testing, confirmation, validation
---

## Verify Fix With Original Reproduction

After implementing a fix, re-run the exact reproduction steps that originally triggered the bug. A fix isn't confirmed until the original failure case passes.

**Incorrect (assuming fix works):**

```python
# Original bug: crash when saving empty file
# Developer adds null check, assumes it's fixed

def save_file(content):
    if content is None:  # Added fix
        content = ""
    write_to_disk(content)

# Developer runs unrelated test: "test_save_normal_file" - passes
# Marks bug as fixed
# User reports: still crashes on empty files
# Developer's fix handles None but original bug was empty string ""
```

**Correct (verify with original reproduction):**

```python
# Original bug reproduction:
# 1. Open app
# 2. Create new file
# 3. Don't type anything
# 4. Click Save
# 5. CRASH

def save_file(content):
    if not content:  # Fixed: handles None AND empty string
        content = ""
    write_to_disk(content)

# Verification:
# 1. Run EXACT original reproduction steps:
#    - Open app
#    - Create new file
#    - Don't type anything (content is "")
#    - Click Save
# 2. PASS - no crash
# 3. Also verify edge cases:
#    - content = None
#    - content = "   " (whitespace only)
#    - content = valid text
```

**Verification checklist:**
- [ ] Can you still reproduce the bug without the fix?
- [ ] Does the fix prevent the original reproduction?
- [ ] Do related scenarios still work?
- [ ] Are there edge cases of the same bug?
- [ ] Did you test on the same environment as the original report?

**When NOT to use this pattern:**
- Bug was caused by transient external factor (already gone)
- Reproduction requires specific hardware/environment you don't have

Reference: [Why Programs Fail - Fixing the Defect](https://www.whyprogramsfail.com/)
