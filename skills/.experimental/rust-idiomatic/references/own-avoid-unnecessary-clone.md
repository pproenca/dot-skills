---
title: Avoid Unnecessary Clone in Closures
impact: CRITICAL
impactDescription: eliminates N allocations per loop iteration in hot paths
tags: own, clone, closures, allocation, performance
---

## Avoid Unnecessary Clone in Closures

Cloning inside closures that run repeatedly (event handlers, iterator chains, loop bodies) creates a new allocation on every invocation. Clone before the closure and move the clone in, or restructure to borrow.

**Incorrect (clones on every iteration):**

```rust
fn process_events(events: &[Event], config: &Config) -> Vec<String> {
    events
        .iter()
        .map(|event| {
            let cfg = config.clone();
            format_event(event, &cfg)
        })
        .collect()
}
```

**Correct (borrows config, zero allocations):**

```rust
fn process_events(events: &[Event], config: &Config) -> Vec<String> {
    events
        .iter()
        .map(|event| format_event(event, config))
        .collect()
}
```
