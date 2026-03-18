---
title: Mirror Changes Between tui and tui_app_server
impact: MEDIUM
impactDescription: prevents behavioral drift between TUI implementations
tags: tui, tui-app-server, parallel-implementations, consistency
---

## Mirror Changes Between tui and tui_app_server

When a change lands in `codex-rs/tui` and `codex-rs/tui_app_server` has a parallel implementation of the same behavior, reflect the change in `tui_app_server` too unless there is a documented reason not to. The two TUI implementations share UI logic and must stay in sync to provide a consistent user experience.

**Incorrect (fixing a bug in tui only):**

```rust
// codex-rs/tui/src/bottom_pane/chat_composer.rs
fn handle_paste(&mut self, content: &str) {
    // Fixed: strip ANSI codes before inserting
    let clean = strip_ansi_codes(content);
    self.buffer.insert_str(self.cursor, &clean);
}

// codex-rs/tui_app_server/src/bottom_pane/chat_composer.rs
fn handle_paste(&mut self, content: &str) {
    // BUG: still inserts raw ANSI codes
    self.buffer.insert_str(self.cursor, content);
}
```

**Correct (same fix applied to both implementations):**

```rust
// codex-rs/tui/src/bottom_pane/chat_composer.rs
fn handle_paste(&mut self, content: &str) {
    let clean = strip_ansi_codes(content);
    self.buffer.insert_str(self.cursor, &clean);
}

// codex-rs/tui_app_server/src/bottom_pane/chat_composer.rs
fn handle_paste(&mut self, content: &str) {
    let clean = strip_ansi_codes(content);
    self.buffer.insert_str(self.cursor, &clean);
}
```
