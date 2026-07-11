---
title: Stay lazy through the chain; collect once, and into Result for fallible steps
tags: iter, collect, lazy, result-collect
---

## Stay lazy through the chain; collect once, and into Result for fallible steps

Engineers who learned "list in, list out" materialize a `Vec` after every step — allocating per stage what adapter fusion would do in one pass — and, hitting a fallible step, abandon the chain for a mut-accumulator loop. codex-rs denies `needless_collect` workspace-wide, and its standard idiom for the fallible step is collecting *into* `Result`: `collect::<Result<Vec<_>, _>>()?` appears 49 times in production, short-circuiting on the first `Err` while staying a single pass. For fold-with-failure it uses `try_fold` (merging permission profiles). The chain stays lazy from source to the one terminal collect.

**Incorrect (materialize per step; loop for the fallible part):**

```rust
fn import_records(records: Vec<i64>) -> Result<Vec<String>, String> {
    let positive: Vec<i64> = records.into_iter().filter(|r| *r > 0).collect();
    let doubled: Vec<i64> = positive.into_iter().map(|r| r * 2).collect();
    let mut out = Vec::new();
    for r in doubled {
        out.push(convert(r)?);
    }
    Ok(out)
}

fn convert(record: i64) -> Result<String, String> {
    if record > 1000 {
        return Err(format!("out of range: {record}"));
    }
    Ok(record.to_string())
}
```

**Correct (one lazy chain, one collect, Err short-circuits — the codex-rs idiom):**

```rust
fn import_records(records: Vec<i64>) -> Result<Vec<String>, String> {
    records
        .into_iter()
        .filter(|r| *r > 0)
        .map(|r| r * 2)
        .map(convert)
        .collect::<Result<Vec<_>, _>>()
}

fn convert(record: i64) -> Result<String, String> {
    if record > 1000 {
        return Err(format!("out of range: {record}"));
    }
    Ok(record.to_string())
}
```

**When an intermediate collect IS right:** the middle step needs a *different data structure's semantics*. codex-rs's apply-patch path collects into a `BTreeSet` mid-chain to dedup and order paths, then continues into a fallible `collect::<Result<Vec<_>, _>>()` — two collects, each buying something (dedup, then short-circuit) that no adapter provides. The smell is collecting into a `Vec` only to iterate it again, which the lint already refuses to compile.

Reference: [codex-rs core/src/tools/handlers/apply_patch.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/tools/handlers/apply_patch.rs#L226), [codex-rs config/src/permissions_toml.rs `try_fold`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/config/src/permissions_toml.rs#L102), [codex-rs Cargo.toml `needless_collect`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/Cargo.toml#L493)
