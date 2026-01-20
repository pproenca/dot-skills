---
title: Use VecDeque for Queue Operations
impact: HIGH
impactDescription: O(n) to O(1) for front operations
tags: ds, vecdeque, queue, deque, fifo
---

## Use VecDeque for Queue Operations

When you need to push/pop from both ends, use `VecDeque`. Vec's `insert(0, x)` and `remove(0)` are O(n) because they shift all elements.

**Incorrect (O(n) per dequeue):**

```rust
fn process_queue(mut tasks: Vec<Task>) {
    while !tasks.is_empty() {
        let task = tasks.remove(0);  // O(n) - shifts all elements
        process(task);
        if let Some(next) = task.spawn_next() {
            tasks.push(next);
        }
    }
}
```

**Correct (O(1) per dequeue):**

```rust
use std::collections::VecDeque;

fn process_queue(mut tasks: VecDeque<Task>) {
    while let Some(task) = tasks.pop_front() {  // O(1)
        process(&task);
        if let Some(next) = task.spawn_next() {
            tasks.push_back(next);  // O(1)
        }
    }
}
```

**VecDeque advantages:**
- O(1) `push_front`, `pop_front`, `push_back`, `pop_back`
- Efficient for FIFO queues and LRU caches
- Indexing is still O(1)

Reference: [std::collections::VecDeque documentation](https://doc.rust-lang.org/std/collections/struct.VecDeque.html)
