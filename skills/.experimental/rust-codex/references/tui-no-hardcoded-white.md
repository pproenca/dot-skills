---
title: Avoid Hardcoded White Color
impact: MEDIUM
impactDescription: preserves theme compatibility with dark and light modes
tags: tui, color, theme, accessibility
---

## Avoid Hardcoded White Color

Do not use `.white()` for text color in TUI components. Use the default foreground color (no color modifier) instead. Hardcoded white is invisible on light-themed terminals and overrides the user's configured terminal colors. The default foreground adapts to the terminal theme automatically.

**Incorrect (invisible text on light-themed terminals):**

```rust
use ratatui::style::Stylize;

let title = "Session History".white().bold();
let status = Line::from(vec![
    "Status: ".white(),
    "Active".green(),
]);
```

**Correct (default foreground adapts to terminal theme):**

```rust
use ratatui::style::Stylize;

let title = "Session History".bold();
let status = Line::from(vec![
    "Status: ".into(),
    "Active".green(),
]);
```
