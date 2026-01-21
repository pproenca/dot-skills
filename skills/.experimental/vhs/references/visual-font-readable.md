---
title: Choose Readable Font Settings
impact: MEDIUM
impactDescription: improves accessibility and viewer comprehension
tags: visual, font, fontsize, fontfamily, readability
---

## Choose Readable Font Settings

Set appropriate font size and family for readability. Default sizes may be too small for GitHub README previews or too large for documentation embeds. Monospace fonts with clear character distinction work best.

**Incorrect (default or tiny font):**

```tape
Output demo.gif
# Default font size may be hard to read in GitHub preview

Set FontSize 14  # Too small for most use cases
```

**Correct (optimized for viewing context):**

```tape
Output demo.gif

Set FontFamily "JetBrains Mono"
Set FontSize 28  # Readable in README previews

Type "echo 'Clear and readable'"
Enter
```

**Font size guidelines by context:**
| Context | Font Size |
|---------|-----------|
| GitHub README | 24-32 |
| Documentation embed | 18-24 |
| Presentation slides | 32-48 |
| Social media | 28-36 |

**Recommended font families:**
- JetBrains Mono (default, excellent)
- Fira Code (ligatures)
- Source Code Pro (clean)
- Hack (highly readable)

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
