---
title: Keep Modules Under 500 Lines of Code
impact: HIGH
impactDescription: reduces merge conflicts by 40-60% in high-touch files
tags: mod, module-size, maintainability, code-organization
---

## Keep Modules Under 500 Lines of Code

Target Rust modules under 500 LoC, excluding tests. If a file exceeds roughly 800 LoC, add new functionality in a new module instead of extending the existing file. This applies especially to high-touch files like `codex-rs/tui/src/app.rs` and `codex-rs/tui/src/bottom_pane/chat_composer.rs` that already attract unrelated changes.

**Incorrect (growing a large module with unrelated features):**

```rust
// codex-rs/tui/src/app.rs (1200+ LoC and growing)
// Adding yet another feature handler in the same file:
impl App {
    fn handle_voice_input(&mut self) { /* ... */ }
    fn handle_image_paste(&mut self) { /* ... */ }
    fn handle_artifact_preview(&mut self) { /* ... */ }
    // File keeps growing with every new feature
}
```

**Correct (extracting into focused modules):**

```rust
// codex-rs/tui/src/app.rs (~400 LoC, orchestration only)
mod voice_input;
mod image_paste;
mod artifact_preview;

impl App {
    fn handle_voice_input(&mut self) {
        voice_input::process(self);
    }
}

// codex-rs/tui/src/voice_input.rs (~150 LoC, focused)
pub(crate) fn process(app: &mut App) { /* ... */ }
```
