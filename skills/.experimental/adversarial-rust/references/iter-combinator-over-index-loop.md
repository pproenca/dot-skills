---
title: Name the transformation with a combinator, not an index loop
tags: iter, combinators, index-loops, enumerate
---

## Name the transformation with a combinator, not an index loop

C and Python transliterate into `for i in 0..v.len()` with `v[i]` (a bounds check and an off-by-one risk per access) and `let mut acc` + push loops that re-implement `map`/`filter`/`partition` anonymously. codex-rs bans the re-implementations mechanically — the workspace denies `manual_map`, `manual_filter`, `manual_find`, `manual_flatten`, `manual_retain`, `manual_try_fold` and seven more `manual_*` lints — and in its production code `.enumerate()` (~280 uses) dwarfs the handful of loops that index elements by `0..len()`. The combinator names the transformation: a reviewer reads `partition` and knows the shape of the result without simulating the loop.

**Incorrect (anonymous re-implementation of partition):**

```rust
struct ModelPreset {
    model: String,
}

fn split_presets(presets: Vec<ModelPreset>) -> (Vec<ModelPreset>, Vec<ModelPreset>) {
    let mut auto_presets = Vec::new();
    let mut other_presets = Vec::new();
    for i in 0..presets.len() {
        if presets[i].model.starts_with("auto") {
            auto_presets.push(ModelPreset { model: presets[i].model.clone() });
        } else {
            other_presets.push(ModelPreset { model: presets[i].model.clone() });
        }
    }
    (auto_presets, other_presets)
}
```

**Correct (the combinator is the name — how codex-rs splits model presets):**

```rust
struct ModelPreset {
    model: String,
}

fn split_presets(presets: Vec<ModelPreset>) -> (Vec<ModelPreset>, Vec<ModelPreset>) {
    presets
        .into_iter()
        .partition(|preset| preset.model.starts_with("auto"))
}
```

**When a plain `for` loop IS right** — codex-rs's surviving loops fall in four buckets: the body must `.await` per item (turn-lifecycle notifications), the body is side-effecting fallible I/O with `?` and no produced value (terminal drawing), the index *is* the datum (screen-cell coordinates, sliding windows), or a foreign API is by-index (`ZipArchive::by_index`, Windows ACL FFI). "Do this N times" retry loops (`for attempt in 0..=max_attempts`) are also loops, not iteration over data.

Reference: [codex-rs tui/src/chatwidget/model_popups.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/tui/src/chatwidget/model_popups.rs#L85), [codex-rs Cargo.toml workspace lints](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/Cargo.toml#L473), [codex-rs core/src/tasks/lifecycle.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/tasks/lifecycle.rs#L15)
