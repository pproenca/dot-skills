---
title: Snapshot terminal rendering with insta for stable TUI diffs
impact: MEDIUM-HIGH
impactDescription: enables 1400 reviewable terminal snapshots that diff cleanly in PRs
tags: testing, snapshots, tui, insta
---

## Snapshot terminal rendering with insta for stable TUI diffs

Asserting individual strings with `assert!(popup.contains("Read Only"))` misses layout regressions and accepts arbitrary whitespace changes. Codex instantiates a real `ratatui::Terminal` backed by a VT100 emulator, draws the widget once, and `insta::assert_snapshot!(terminal.backend())` — the snapshot is a full ANSI-colored text dump. For stable file names when tests move between modules, it wraps the assertion in `insta::Settings::clone_current()`, `set_prepend_module_to_snapshot(false)`, `set_snapshot_path("snapshots")`, and binds a macro around it.

**Incorrect (substring assertions miss layout regressions):**

```rust
let rendered = render_popup(&state);
assert!(rendered.contains("Read Only"));
assert!(rendered.contains("Workspace Write"));
// A typo in alignment code? Still passes.
```

**Correct (full-terminal snapshot with stable paths):**

```rust
// tui/src/onboarding/trust_directory.rs
let mut terminal =
    Terminal::new(VT100Backend::new(70, 14)).expect("terminal");
terminal
    .draw(|frame| (&widget).render_ref(frame.area(), frame.buffer_mut()))
    .expect("draw");
insta::assert_snapshot!(terminal.backend());

// tui/src/chatwidget/tests.rs — macro with stable paths
macro_rules! assert_chatwidget_snapshot {
    ($name:expr, $value:expr $(,)?) => {{
        let mut settings = insta::Settings::clone_current();
        settings.set_prepend_module_to_snapshot(false);
        settings.set_snapshot_path(
            crate::chatwidget::tests::chatwidget_snapshot_dir(),
        );
        settings.bind(|| {
            insta::assert_snapshot!(
                format!("codex_tui__chatwidget__tests__{}", $name),
                $value,
            );
        });
    }};
}

// Platform-specific variant
#[cfg(target_os = "windows")]
insta::with_settings!({ snapshot_suffix => "windows" }, {
    assert_chatwidget_snapshot!("approvals_selection_popup", popup);
});
```

The macro hard-codes the `codex_tui__chatwidget__tests__` prefix so moving tests between submodules does not rename the snapshot files — a workaround for insta's default behavior. Look for `@windows` suffixes in `tui/src/chatwidget/snapshots/` to see how cross-platform variants coexist.

Reference: `codex-rs/tui/src/onboarding/trust_directory.rs:217`, `codex-rs/tui/src/chatwidget/tests.rs:230`.
