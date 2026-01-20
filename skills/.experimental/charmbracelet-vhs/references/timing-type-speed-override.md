---
title: Override TypingSpeed for Emphasis
impact: HIGH
impactDescription: draws attention to important commands
tags: timing, typingspeed, emphasis, pacing
---

## Override TypingSpeed for Emphasis

Use the `@<time>` suffix on `Type` to override typing speed for specific commands. Slow down for important commands viewers should notice, speed up for boilerplate they can skim.

**Incorrect (uniform speed throughout):**

```tape
Set TypingSpeed 50ms

Type "cd my-project"
Enter
Type "npm install"
Enter
Type "npm run dangerous-command --force"  # Same speed, easy to miss
Enter
```

**Correct (varied speed for emphasis):**

```tape
Set TypingSpeed 50ms

Type "cd my-project"
Enter
Sleep 500ms

Type@25ms "npm install"  # Fast, routine command
Enter
Sleep 3s

Type@150ms "npm run dangerous-command --force"  # Slow, draws attention
Enter
Sleep 2s
```

**Speed guidelines:**
- `@25ms`: Very fast, for familiar boilerplate
- `@50ms`: Normal reading speed
- `@100ms`: Slightly slow, noticeable
- `@150-200ms`: Deliberate, for important content
- `@500ms`: Very slow, dramatic effect

Reference: [VHS README - Type](https://github.com/charmbracelet/vhs#type)
