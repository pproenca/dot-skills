---
title: Use Explicit Time Units
impact: MEDIUM
impactDescription: prevents confusion between seconds and milliseconds
tags: timing, sleep, units, clarity
---

## Use Explicit Time Units

Always specify time units (`s` for seconds, `ms` for milliseconds) in `Sleep` commands. While VHS accepts bare numbers as seconds, explicit units prevent confusion and make tape files more readable.

**Incorrect (ambiguous units):**

```tape
Sleep 2     # Is this 2 seconds or 2 milliseconds?
Sleep 500   # 500 seconds?! No, VHS treats this as 500ms
Sleep .5    # Half a second? Works but unclear
```

**Correct (explicit units):**

```tape
Sleep 2s      # Clearly 2 seconds
Sleep 500ms   # Clearly 500 milliseconds
Sleep 0.5s    # Clearly half a second
Sleep 1500ms  # Clearly 1.5 seconds
```

**Unit reference:**
- `ms`: milliseconds (1000ms = 1s)
- `s`: seconds
- Bare numbers: interpreted as seconds (avoid)

Reference: [VHS README - Sleep](https://github.com/charmbracelet/vhs#sleep)
