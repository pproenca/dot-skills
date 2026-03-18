---
title: Test Both tui and tui_app_server for Shared Behavior
impact: LOW-MEDIUM
impactDescription: 100% behavioral parity between tui and tui_app_server
tags: integ, tui, tui-app-server, parallel-implementations
---

## Test Both tui and tui_app_server for Shared Behavior

When a change lands in `codex-rs/tui` and `codex-rs/tui_app_server` has a parallel implementation of the same behavior, reflect the change in both crates and add tests to both. This prevents behavioral drift between the two TUI implementations.

**Incorrect (change in tui only, tui_app_server diverges):**

```rust
// PR: "Add keyboard shortcut for copy in tui"
// Only changes codex-rs/tui/src/app.rs
// codex-rs/tui_app_server has the same feature but now behaves differently
```

**Correct (both implementations updated and tested):**

```rust
// codex-rs/tui/src/app.rs — adds Ctrl+C copy handler
#[test]
fn test_ctrl_c_copies_selection() {
    let mut app = TestApp::new();
    app.select_text("hello");
    app.handle_key(KeyCode::Char('c'), Modifiers::CTRL);
    assert_eq!(app.clipboard(), "hello");
}

// codex-rs/tui_app_server/src/app.rs — parallel change
#[test]
fn test_ctrl_c_copies_selection() {
    let mut app = TestAppServer::new();
    app.select_text("hello");
    app.handle_key(KeyCode::Char('c'), Modifiers::CTRL);
    assert_eq!(app.clipboard(), "hello");
}
```
