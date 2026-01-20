---
title: Use LoopOffset for Seamless Loops
impact: MEDIUM
impactDescription: creates professional-looking continuous playback
tags: output, loopoffset, gif, loop, polish
---

## Use LoopOffset for Seamless Loops

Set `LoopOffset` to start the GIF loop from a point other than the beginning. This creates smoother loops by starting from a stable state rather than an empty terminal.

**Incorrect (jarring loop restart):**

```tape
Output demo.gif

Type "mycli demo"
Enter
Sleep 5s
# Loop restarts from empty prompt—jarring transition
```

**Correct (smooth loop with offset):**

```tape
Output demo.gif

Set LoopOffset 75%  # Loop starts at 75% through

Type "mycli demo"
Enter
Sleep 5s
# Loop starts from near the end, showing output briefly before restart
```

**LoopOffset strategies:**
- `0%`: Start from beginning (default)
- `50%`: Start from middle (good for short demos)
- `75-90%`: Start near end (shows result, then loops)
- `100%`: Effectively shows last frame only

**For continuous-looking demos:**

```tape
Set LoopOffset 80%

Type "watch -n1 date"
Enter
Sleep 10s
Ctrl+C
# Loops smoothly, always shows date updating
```

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
