---
title: Return Option or Result instead of sentinel values
tags: flow, option, sentinels, api-design
---

## Return Option or Result instead of sentinel values

Returning `-1`, `0`, an empty `String`, or a `bool` plus an out-parameter to mean "not found / failed" is the C convention, and it re-imports C's classic bug: the sentinel is a *valid value of the type*, so the compiler cannot tell a forgotten check from a deliberate use, and the sentinel silently flows into arithmetic or storage. `Option`/`Result` make absence a different *type* — the caller physically cannot use the value without deciding what `None` means, and combinators (`map_or`, `unwrap_or_else`, `ok_or`) make the handling terser than the `if ret == -1` dance ever was.

**Incorrect (the sentinel is a legal value):**

```rust
fn find_seat(rows: &[Row], passenger: &str) -> i32 {
    for (i, row) in rows.iter().enumerate() {
        if row.holder == passenger {
            return i as i32;
        }
    }
    -1 // callers must remember; -1 + 1 == 0 is a real seat
}
```

**Correct (absence is unmistakable and checked):**

```rust
fn find_seat(rows: &[Row], passenger: &str) -> Option<usize> {
    rows.iter().position(|row| row.holder == passenger)
}
```

Reference: [std::option — module documentation](https://doc.rust-lang.org/std/option/index.html)
