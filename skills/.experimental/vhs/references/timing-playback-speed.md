---
title: Use PlaybackSpeed for Final Adjustments
impact: MEDIUM
impactDescription: adjusts recording duration without re-recording
tags: timing, playbackspeed, duration, post-processing
---

## Use PlaybackSpeed for Final Adjustments

Use `Set PlaybackSpeed` to adjust the final recording speed without changing timing in your tape file. This is useful for making long demos shorter or slowing down fast sections.

**Incorrect (adjusting all Sleep values manually):**

```tape
# Original: too slow at 30 seconds total
Sleep 5s
Type "command"
Sleep 5s

# Manually halving all sleeps: error-prone
Sleep 2.5s
Type "command"
Sleep 2.5s
```

**Correct (using PlaybackSpeed):**

```tape
Set PlaybackSpeed 2.0  # 2× faster playback

Sleep 5s
Type "command"
Sleep 5s
# Renders in 15 seconds instead of 30
```

**PlaybackSpeed values:**
- `0.5`: 2× slower (30s recording → 60s playback)
- `1.0`: Normal speed (default)
- `1.5`: 1.5× faster
- `2.0`: 2× faster (30s recording → 15s playback)

**When to use each:**
- `0.5`: Complex demos viewers need time to understand
- `1.0`: Standard tutorials
- `1.5-2.0`: README GIFs that should be brief

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
