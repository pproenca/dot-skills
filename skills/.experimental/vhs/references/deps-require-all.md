---
title: Require All External Commands
impact: HIGH
impactDescription: documents and validates all dependencies
tags: deps, require, documentation, portability
---

## Require All External Commands

Add a `Require` statement for every external command used in your tape file, not just the primary tool being demonstrated. This serves as documentation and ensures portability across different systems.

**Incorrect (only requiring main tool):**

```tape
Require mycli

Output demo.gif
Set Shell "bash"

Type "mycli init"
Enter
Sleep 2s
Type "jq '.name' package.json"
Enter
Sleep 1s
Type "bat config.yaml"
Enter
# jq and bat might not be installed!
```

**Correct (requiring all external commands):**

```tape
Require mycli
Require jq
Require bat

Output demo.gif
Set Shell "bash"

Type "mycli init"
Enter
Sleep 2s
Type "jq '.name' package.json"
Enter
Sleep 1s
Type "bat config.yaml"
Enter
```

**When NOT to use this pattern:**
- Standard shell built-ins (echo, cd, pwd, export)
- Commands guaranteed by the specified shell

Reference: [VHS README - Require](https://github.com/charmbracelet/vhs#require)
