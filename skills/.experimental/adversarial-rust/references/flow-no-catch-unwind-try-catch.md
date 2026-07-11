---
title: Avoid catch_unwind as try/catch
tags: flow, panics, catch-unwind, error-handling
---

## Avoid catch_unwind as try/catch

Wrapping fallible business logic in `std::panic::catch_unwind` to "catch the exception" ports try/catch onto a mechanism that isn't one — the std docs say directly that it is not recommended as a general try/catch. It silently stops working when the binary is built with `panic = "abort"` (common for servers and embedded), it can leave the data the panicking code was mutating in a broken state (which is why mutexes poison), and it launders bugs into a control-flow branch so the underlying defect never surfaces. Expected failures belong in `Result`; a panic that crosses your logic should stay a loud bug report.

**Incorrect (a validation failure routed through unwinding):**

```rust
fn parse_row(line: &str) -> Option<Trade> {
    std::panic::catch_unwind(|| {
        let fields: Vec<&str> = line.split(',').collect();
        Trade {
            symbol: fields[0].to_owned(),           // panics on short rows —
            qty: fields[1].parse().unwrap(),        // "caught" like an exception
        }
    })
    .ok()
}
```

**Correct (fallibility expressed in the types):**

```rust
fn parse_row(line: &str) -> Option<Trade> {
    let (symbol, qty) = line.split_once(',')?;
    Some(Trade { symbol: symbol.to_owned(), qty: qty.trim().parse().ok()? })
}
```

**When catch_unwind IS right:** an isolation boundary that must survive *other people's* bugs — an FFI edge where unwinding into C is undefined behavior, a thread-pool or plugin host keeping one task's panic from killing its siblings. There you catch, log, and discard the task — you don't resume normal flow with its output.

Reference: [std::panic::catch_unwind — API docs](https://doc.rust-lang.org/std/panic/fn.catch_unwind.html)
