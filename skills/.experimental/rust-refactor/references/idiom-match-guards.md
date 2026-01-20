---
title: Use Match Guards for Complex Conditions
impact: MEDIUM
impactDescription: reduces nesting depth by 2-3 levels
tags: idiom, match, guards, pattern-matching, conditions
---

## Use Match Guards for Complex Conditions

Use match guards (`if` after pattern) to add conditions beyond what patterns can express. This keeps related logic together.

**Incorrect (nested conditions after match):**

```rust
fn categorize_number(n: i32) -> &'static str {
    match n {
        0 => "zero",
        x => {
            if x > 0 && x < 10 {
                "small positive"
            } else if x >= 10 && x < 100 {
                "medium positive"
            } else if x >= 100 {
                "large positive"
            } else if x > -10 {
                "small negative"
            } else {
                "large negative"
            }
        }
    }
}
```

**Correct (match guards):**

```rust
fn categorize_number(n: i32) -> &'static str {
    match n {
        0 => "zero",
        x if x > 0 && x < 10 => "small positive",
        x if x >= 10 && x < 100 => "medium positive",
        x if x >= 100 => "large positive",
        x if x > -10 => "small negative",
        _ => "large negative",
    }
}
```

**With struct destructuring:**

```rust
fn process_event(event: Event) {
    match event {
        Event::Click { x, y } if x < 100 && y < 100 => {
            handle_top_left_click(x, y)
        }
        Event::Click { x, y } if x >= 100 => {
            handle_right_side_click(x, y)
        }
        Event::Click { x, y } => {
            handle_other_click(x, y)
        }
        Event::KeyPress { key } if key.is_ascii() => {
            handle_ascii_key(key)
        }
        _ => {}
    }
}
```

**Note:** Guards don't contribute to exhaustiveness checking - you still need a catch-all if guards might not cover all cases.

Reference: [Match Guards - Rust Book](https://doc.rust-lang.org/book/ch18-03-pattern-syntax.html#extra-conditionals-with-match-guards)
