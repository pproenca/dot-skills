---
title: Use Ctrl Combinations for Terminal Control
impact: HIGH
impactDescription: enables proper terminal interaction patterns
tags: cmd, ctrl, keyboard, terminal, signals
---

## Use Ctrl Combinations for Terminal Control

VHS supports `Ctrl+<key>` combinations for terminal control sequences. Use these for interrupting processes, clearing screens, and navigating within terminal applications.

**Incorrect (trying to type control characters):**

```tape
Type "^C"  # Types literal ^C, doesn't send interrupt
Type "^L"  # Types literal ^L, doesn't clear screen
```

**Correct (using Ctrl combinations):**

```tape
# Start a long-running process
Type "sleep 100"
Enter
Sleep 1s

# Interrupt it
Ctrl+C

# Clear the screen
Ctrl+L

# Common Ctrl combinations
Ctrl+A  # Move to beginning of line
Ctrl+E  # Move to end of line
Ctrl+K  # Kill to end of line
Ctrl+U  # Kill to beginning of line
Ctrl+W  # Delete word backward
Ctrl+R  # Reverse search history
Ctrl+D  # EOF/Exit
Ctrl+Z  # Suspend process
```

**With modifiers:**

```tape
Ctrl+Alt+Delete  # Multiple modifiers
Ctrl+Shift+T     # Common terminal shortcuts
```

Reference: [VHS README - Keys](https://github.com/charmbracelet/vhs#keys)
