---
title: Adjust Letter and Line Spacing
impact: LOW-MEDIUM
impactDescription: fine-tunes readability for specific fonts
tags: visual, letterspacing, lineheight, typography
---

## Adjust Letter and Line Spacing

Use `LetterSpacing` and `LineHeight` to fine-tune text appearance when default spacing doesn't work well with your chosen font or content density.

**Incorrect (cramped or sparse text):**

```tape
Output demo.gif

Set FontFamily "Fira Code"
# Default spacing may be too tight for this font

Type "function hello() { console.log('world'); }"
Enter
```

**Correct (adjusted for readability):**

```tape
Output demo.gif

Set FontFamily "Fira Code"
Set LetterSpacing 1
Set LineHeight 1.4

Type "function hello() { console.log('world'); }"
Enter
```

**Spacing guidelines:**
| Setting | Default | Compact | Spacious |
|---------|---------|---------|----------|
| LetterSpacing | 0 | -1 | 1-2 |
| LineHeight | 1.0 | 0.9 | 1.2-1.5 |

**When to adjust:**
- Dense code blocks: Increase LineHeight to 1.3-1.5
- Wide terminals: Slight LetterSpacing increase improves readability
- Narrow fonts: May need LetterSpacing increase

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
