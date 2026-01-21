---
title: Use Correct Type Command Syntax
impact: HIGH
impactDescription: prevents command parsing failures
tags: cmd, type, syntax, quotes
---

## Use Correct Type Command Syntax

The `Type` command requires the text to be enclosed in double quotes. Missing or mismatched quotes cause parsing errors that halt tape execution entirely.

**Incorrect (missing quotes):**

```tape
Type echo hello
# Error: parsing tape file

Type 'echo hello'
# Error: single quotes not supported
```

**Correct (double quotes):**

```tape
Type "echo hello"
Enter

Type "echo 'single quotes inside are fine'"
Enter

Type "echo \"escaped double quotes\""
Enter
```

**For special characters:**

```tape
# Backticks
Type "echo \`date\`"
Enter

# Dollar signs (literal)
Type "echo \$HOME"
Enter

# Dollar signs (expanded in shell)
Type "echo $HOME"
Enter
```

Reference: [VHS README - Type](https://github.com/charmbracelet/vhs#type)
