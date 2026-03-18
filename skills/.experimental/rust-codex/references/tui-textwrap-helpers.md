---
title: Use textwrap and word_wrap_lines for Text Wrapping
impact: MEDIUM
impactDescription: eliminates 100% of manual wrapping bugs and edge cases
tags: tui, textwrap, wrapping, text-layout
---

## Use textwrap and word_wrap_lines for Text Wrapping

Always use `textwrap::wrap` to wrap plain strings. For ratatui `Line` values, use the helpers in `tui/src/wrapping.rs` (`word_wrap_lines`, `word_wrap_line`). For indentation of wrapped lines, use `initial_indent` and `subsequent_indent` from `RtOptions` instead of writing custom logic. For prefixing lines, use the `prefix_lines` helper from `line_utils`.

**Incorrect (manual character counting for wrapping):**

```rust
fn wrap_message(text: &str, width: usize) -> Vec<String> {
    let mut lines = Vec::new();
    let mut current = String::new();
    for word in text.split_whitespace() {
        if current.len() + word.len() + 1 > width {
            lines.push(current.clone());
            current.clear();
        }
        if !current.is_empty() { current.push(' '); }
        current.push_str(word);
    }
    if !current.is_empty() { lines.push(current); }
    lines
}
```

**Correct (using textwrap for plain strings):**

```rust
use textwrap::{wrap, Options as RtOptions};

fn wrap_message(text: &str, width: usize) -> Vec<String> {
    let options = RtOptions::new(width)
        .initial_indent("  ")
        .subsequent_indent("  ");
    wrap(text, &options)
        .into_iter()
        .map(|cow| cow.into_owned())
        .collect()
}
```

**Alternative (using word_wrap_lines for ratatui Lines):**

```rust
use crate::wrapping::word_wrap_lines;

fn wrap_styled_lines(lines: Vec<Line<'_>>, width: u16) -> Vec<Line<'_>> {
    word_wrap_lines(&lines, width as usize)
}
```
