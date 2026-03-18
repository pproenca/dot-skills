---
title: Use assert_snapshot for UI Render Output
impact: CRITICAL
impactDescription: 100% visual coverage of UI changes reviewable in PR diffs
tags: assert, insta, snapshot, ui-testing
---

## Use assert_snapshot for UI Render Output

Use `insta::assert_snapshot!` to capture rendered terminal output for TUI components. Snapshot tests produce `.snap` files that show the exact visual representation, making UI changes easy to review in pull requests. Any change that affects user-visible UI must include corresponding snapshot coverage.

**Incorrect (manual string assertions miss layout changes):**

```rust
#[test]
fn test_trust_dialog_renders() {
    let mut terminal = setup_test_terminal(80, 24);
    render_trust_dialog(&mut terminal, &test_state());
    let content = terminal.backend().to_string();
    assert!(content.contains("Trust this directory?"));
    assert!(content.contains("[Yes]"));
    // Layout changes, spacing shifts, or color changes go undetected
}
```

**Correct (snapshot captures full visual output):**

```rust
#[test]
fn test_trust_dialog_renders() {
    let mut terminal = setup_test_terminal(80, 24);
    render_trust_dialog(&mut terminal, &test_state());
    insta::assert_snapshot!(terminal.backend());
    // Full terminal output stored in .snap file, reviewable in PR
}
```
