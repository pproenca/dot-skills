---
title: End Recordings with Final Sleep
impact: MEDIUM
impactDescription: prevents abrupt GIF endings
tags: timing, sleep, ending, polish
---

## End Recordings with Final Sleep

Always end your tape file with a `Sleep` command to give viewers time to see the final output before the GIF loops. Recordings that end immediately after the last command feel abrupt and unprofessional.

**Incorrect (abrupt ending):**

```tape
Type "mycli demo"
Enter
# GIF ends immediately, loops back before viewer processes output
```

**Correct (pause before loop):**

```tape
Type "mycli demo"
Enter
Sleep 3s  # Give viewers time to read output

# Or use LoopOffset for seamless looping
```

**With LoopOffset for seamless loops:**

```tape
Set LoopOffset 80%  # Start loop at 80% through

Type "mycli demo"
Enter
Sleep 5s  # Final output visible, then loops smoothly
```

**Recommended final sleep durations:**
- Simple output: 2-3s
- Complex output: 4-5s
- Output viewers need to read: 5-10s

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
