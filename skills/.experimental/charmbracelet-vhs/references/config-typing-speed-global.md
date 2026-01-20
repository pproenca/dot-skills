---
title: Set Global TypingSpeed Early
impact: HIGH
impactDescription: establishes consistent pacing throughout recording
tags: config, typingspeed, pacing, timing
---

## Set Global TypingSpeed Early

Set a global `TypingSpeed` near the top of your tape file to establish consistent pacing. Unlike other settings, `TypingSpeed` can be changed mid-file, but setting a sensible default prevents inconsistent typing speeds throughout your demo.

**Incorrect (no global default, inconsistent pacing):**

```tape
Output demo.gif

Type "echo 'fast'"
Enter
Type "echo 'also fast at default 50ms'"
Enter
```

**Correct (global default with intentional overrides):**

```tape
Output demo.gif

Set TypingSpeed 75ms

Type "echo 'normal speed'"
Enter
Type@200ms "echo 'deliberately slow for emphasis'"
Enter
Type "echo 'back to normal'"
Enter
```

**Recommended speeds:**
- 25-50ms: Fast, for experienced users or long commands
- 50-100ms: Normal, readable for most viewers
- 100-200ms: Slow, for emphasis or tutorials

Reference: [VHS README - Typing Speed](https://github.com/charmbracelet/vhs#type)
