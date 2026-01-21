---
title: Declare Output at File Start
impact: CRITICAL
impactDescription: prevents missing output files
tags: config, output, structure, order
---

## Declare Output at File Start

Declare `Output` commands at the top of your tape file to clearly indicate what files will be generated. While VHS defaults to `out.gif`, explicit output declarations prevent confusion and ensure outputs are written to expected locations.

**Incorrect (relying on defaults):**

```tape
Set FontSize 32

Type "echo hello"
Enter

Sleep 2s
# Where does the output go? Defaults to out.gif in current directory
```

**Correct (explicit output declaration):**

```tape
Output demo.gif
Output demo.mp4

Set FontSize 32

Type "echo hello"
Enter

Sleep 2s
```

**When NOT to use this pattern:**
- Quick local testing where default `out.gif` is acceptable

Reference: [VHS README - Output](https://github.com/charmbracelet/vhs#output)
