---
title: Redesign ownership instead of cloning to satisfy the borrow checker
tags: own, clone, borrowing, ownership
---

## Redesign ownership instead of cloning to satisfy the borrow checker

`.clone()` added until the error goes away is the signature move of treating the borrow checker as an obstacle. Each such clone silences a *design* diagnostic — the checker is reporting that two parts of the code want the same data at the same time — and buys the silence with an allocation and, worse, a fork: mutations to the copy never reach the original, which is a latent bug, not a style issue. Restructure instead: borrow disjoint fields separately, hoist the needed value out before mutating, or pass indices.

**Incorrect (clone forks the data to dodge a split-borrow error):**

```rust
struct Cart { items: Vec<LineItem>, log: Vec<String> }

impl Cart {
    fn apply_bulk_discount(&mut self) {
        for mut item in self.items.clone() { // clone dodges the &self/&mut self clash…
            item.price = item.price.discounted(BULK_RATE); // …and edits the copy
            self.log.push(format!("discounted {}", item.sku));
        }
        // self.items still holds the old prices — the discount is silently lost
    }
}
```

**Correct (borrow disjoint fields — the checker allows it):**

```rust
struct Cart { items: Vec<LineItem>, log: Vec<String> }

impl Cart {
    fn apply_bulk_discount(&mut self) {
        let Cart { items, log } = self; // split &mut self into field borrows
        for item in items.iter_mut() {
            item.price = item.price.discounted(BULK_RATE);
            log.push(format!("discounted {}", item.sku));
        }
    }
}
```

**When a clone IS right:** the program genuinely needs two independent copies (a snapshot, data crossing a thread boundary by value), or the type is a cheap handle (`Rc`/`Arc` clone bumps a refcount). The test is whether you can say *why* two copies must exist — "it wouldn't compile otherwise" is the anti-pattern.

Reference: [Rust Design Patterns — Clone to satisfy the borrow checker (anti-pattern)](https://rust-unofficial.github.io/patterns/anti_patterns/borrow_clone.html)
