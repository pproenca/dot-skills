---
title: Use Ratatui Stylize Trait Helpers
impact: MEDIUM
impactDescription: reduces boilerplate by 60-70% for styled spans
tags: tui, ratatui, stylize, spans
---

## Use Ratatui Stylize Trait Helpers

Use concise styling helpers from ratatui's Stylize trait instead of manually constructing `Span::styled` with `Style` objects. Use `"text".into()` for basic spans and `"text".red()`, `"text".dim()`, `"text".bold()` for styled spans. Chain helpers for compound styles: `url.cyan().underlined()`.

**Incorrect (verbose manual style construction):**

```rust
use ratatui::style::{Color, Style};
use ratatui::text::Span;

let spans = vec![
    Span::styled("  └ ", Style::default()),
    Span::styled("M", Style::default().fg(Color::Red)),
    Span::styled(" ", Style::default().add_modifier(Modifier::DIM)),
    Span::styled("tui/src/app.rs", Style::default().add_modifier(Modifier::DIM)),
];
```

**Correct (concise Stylize helpers):**

```rust
use ratatui::style::Stylize;

let spans = vec![
    "  └ ".into(),
    "M".red(),
    " ".dim(),
    "tui/src/app.rs".dim(),
];
```
