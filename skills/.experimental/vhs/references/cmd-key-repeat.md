---
title: Use Key Repeat Counts
impact: HIGH
impactDescription: reduces tape file verbosity by 5-10×
tags: cmd, keys, repeat, shortcuts
---

## Use Key Repeat Counts

Navigation and editing keys accept an optional repeat count. Use this instead of repeating the same key command multiple times, which bloats tape files and increases maintenance burden.

**Incorrect (repeated key commands):**

```tape
Type "some long command here"
Enter

# Go back to edit
Up
Left
Left
Left
Left
Left
Backspace
Backspace
Backspace
Type "new"
Enter
```

**Correct (using repeat counts):**

```tape
Type "some long command here"
Enter

# Go back to edit
Up
Left 5
Backspace 3
Type "new"
Enter
```

**Keys supporting repeat counts:**
- Arrow keys: `Left 10`, `Right 5`, `Up 3`, `Down 2`
- Editing: `Backspace 5`, `Delete 3`
- Navigation: `Tab 2`, `Space 4`
- Special: `Enter 2`, `Escape 2`

Reference: [VHS README - Keys](https://github.com/charmbracelet/vhs#keys)
