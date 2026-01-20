---
title: Always Follow Type with Enter
impact: HIGH
impactDescription: ensures commands actually execute
tags: cmd, type, enter, execution
---

## Always Follow Type with Enter

After typing a command, you must explicitly use `Enter` to execute it. `Type` only simulates keystrokes—it does not press Enter automatically. Forgetting `Enter` leaves commands sitting at the prompt without execution.

**Incorrect (missing Enter):**

```tape
Type "echo hello"
Sleep 2s
Type "echo world"
Sleep 2s
# Neither command executes—both just sit at the prompt
```

**Correct (explicit Enter after each command):**

```tape
Type "echo hello"
Enter
Sleep 1s

Type "echo world"
Enter
Sleep 1s
```

**When typing partial content (no Enter needed):**

```tape
# Interactive typing demonstration
Type "git com"
Sleep 500ms
Tab  # Autocomplete
Type "it -m "
Sleep 500ms
Type "'Initial commit'"
Enter
```

Reference: [VHS README - Type](https://github.com/charmbracelet/vhs#type)
