---
title: Choose Output Format Based on Use Case
impact: MEDIUM-HIGH
impactDescription: 10-50× file size difference between formats
tags: output, format, gif, mp4, webm, optimization
---

## Choose Output Format Based on Use Case

Select the appropriate output format based on where your recording will be used. GIF is universally compatible but large; MP4/WebM offer better compression but limited platform support.

**Incorrect (always using GIF):**

```tape
Output documentation-demo.gif  # 15MB GIF for a 30-second demo
```

**Correct (format matched to platform):**

```tape
# For GitHub README (GIF required, auto-plays)
Output demo.gif

# For documentation sites (modern formats supported)
Output demo.webm
Output demo.mp4

# For generating multiple formats simultaneously
Output demo.gif
Output demo.mp4
Output demo.webm
```

**Format comparison:**
| Format | Size | Compatibility | Best For |
|--------|------|---------------|----------|
| GIF | Large (10-50MB) | Universal | README, GitHub |
| MP4 | Small (1-5MB) | Most browsers | Documentation |
| WebM | Smallest (0.5-3MB) | Modern browsers | Web apps |
| PNG frames | Variable | Processing | Post-processing |

**Generate multiple formats:**

```tape
Output demo.gif     # For GitHub
Output demo.mp4     # For docs
Output demo.webm    # For web
Output frames/      # For custom processing
```

Reference: [VHS README - Output](https://github.com/charmbracelet/vhs#output)
