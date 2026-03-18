---
title: Use Insta Snapshots for All UI Changes
impact: MEDIUM
impactDescription: makes UI impact reviewable in PR diffs for 100% of visual changes
tags: snap, insta, ui-coverage, visual-review
---

## Use Insta Snapshots for All UI Changes

Any change that affects user-visible UI must include corresponding `insta` snapshot coverage. Add a new snapshot test if one does not exist yet, or update the existing snapshot. Snapshot files (`.snap`) are committed alongside the code, making visual changes reviewable in PR diffs.

**Incorrect (UI change with no snapshot coverage):**

```rust
// PR adds a new footer component but no snapshot test
fn render_footer(frame: &mut Frame, area: Rect, status: &str) {
    let text = Line::from(status.dim());
    frame.render_widget(Paragraph::new(text), area);
    // No way to review what this looks like in the PR
}
```

**Correct (snapshot test captures the rendered output):**

```rust
fn render_footer(frame: &mut Frame, area: Rect, status: &str) {
    let text = Line::from(status.dim());
    frame.render_widget(Paragraph::new(text), area);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_footer_renders_status() {
        let mut terminal = setup_test_terminal(80, 3);
        terminal.draw(|frame| render_footer(frame, frame.area(), "Ready")).unwrap();
        insta::assert_snapshot!(terminal.backend());
        // .snap file shows exact rendered output, reviewable in PR
    }
}
```
