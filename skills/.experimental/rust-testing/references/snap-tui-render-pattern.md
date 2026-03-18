---
title: Use Buffer Rendering for TUI Snapshot Tests
impact: MEDIUM
impactDescription: 100% pixel-accurate terminal output capture for comparison
tags: snap, tui, buffer-rendering, terminal
---

## Use Buffer Rendering for TUI Snapshot Tests

Create a test terminal with fixed dimensions, render the widget into it, then snapshot `terminal.backend()`. The backend captures the exact buffer content including styled characters. Fixed dimensions ensure the snapshot is reproducible across different physical terminal sizes.

**Incorrect (rendering to string loses layout and style information):**

```rust
#[test]
fn test_dialog_render() {
    let state = build_test_state();
    let text = format_dialog(&state);
    insta::assert_snapshot!(text);
    // Loses column alignment, colors, and terminal-specific layout
}
```

**Correct (buffer rendering captures exact terminal output):**

```rust
#[test]
fn test_dialog_render() {
    let mut terminal = setup_test_terminal(80, 24);
    let state = build_test_state();
    terminal.draw(|frame| {
        render_dialog(frame, frame.area(), &state);
    }).unwrap();
    insta::assert_snapshot!(terminal.backend());
    // Captures exact 80x24 buffer with styles and alignment
}
```
