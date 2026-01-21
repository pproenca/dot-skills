---
title: Optimize Framerate for File Size
impact: MEDIUM-HIGH
impactDescription: 2-3× file size reduction with lower framerate
tags: output, framerate, optimization, filesize
---

## Optimize Framerate for File Size

Reduce framerate to significantly decrease file size without noticeably affecting quality for terminal recordings. Terminal content changes slowly compared to video, so high framerates are unnecessary.

**Incorrect (default high framerate):**

```tape
Output demo.gif
# Default framerate creates unnecessarily large files
```

**Correct (optimized framerate):**

```tape
Output demo.gif

Set Framerate 15  # Half the frames, significantly smaller file

Type "npm install"
Enter
Sleep 5s
```

**Framerate guidelines:**
- 30 fps: High quality, large files (rarely needed)
- 20 fps: Good quality, moderate files
- 15 fps: Recommended for most demos
- 10 fps: Small files, slight choppiness on fast typing

**When to use higher framerates:**
- Animations or spinners that update rapidly
- Smooth cursor movement demos
- High-polish marketing materials

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
