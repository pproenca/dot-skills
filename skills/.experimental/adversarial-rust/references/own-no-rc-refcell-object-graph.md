---
title: Avoid rebuilding a GC object graph with Rc<RefCell<T>>
tags: own, rc, refcell, object-graph
---

## Avoid rebuilding a GC object graph with Rc<RefCell<T>>

In a garbage-collected language every object freely holds references to its peers, so a ported design arrives as `Rc<RefCell<T>>` at every edge. That trades the compiler's aliasing guarantees for runtime ones — `borrow_mut()` panics replace borrow errors, moving the checking from your build to your users — and any back-edge (`child.parent`) creates an `Rc` cycle that never deallocates, because `Rc` does not collect cycles. The refactor is to pick owners: structure the data as a tree where parents own children and `&mut` flows down, and turn cross-links into IDs resolved through the owner.

**Incorrect (every edge shared and mutable, parent back-edge leaks):**

```rust
use std::{cell::RefCell, rc::Rc};

struct Department {
    employees: Vec<Rc<RefCell<Employee>>>,
}

struct Employee {
    name: String,
    department: Rc<RefCell<Department>>, // cycle: never freed
}
```

**Correct (one owner, cross-links by ID):**

```rust
struct Company {
    departments: Vec<Department>,
}

struct Department {
    employees: Vec<Employee>,
}

struct Employee {
    name: String,
    department: DeptId, // resolved via &Company when needed
}
```

**When Rc/RefCell IS right:** genuinely shared ownership with no better owner (a config blob referenced by many subsystems in a single-threaded program) — and then prefer `Rc<T>` with immutable contents, reaching for `RefCell` only when shared *mutation* is the requirement, and `Weak` for any back-edge.

Reference: [The Rust Book — Reference Cycles Can Leak Memory](https://doc.rust-lang.org/book/ch15-06-reference-cycles.html)
