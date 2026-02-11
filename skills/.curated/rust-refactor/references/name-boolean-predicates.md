---
title: Use is_, has_, should_ for Boolean Predicates
impact: MEDIUM
impactDescription: Question-like prefixes make boolean return types self-evident
tags: name, booleans, predicates, is, has, should
---

## Use is_, has_, should_ for Boolean Predicates

Boolean-returning functions use question-like prefixes (`is_`, `has_`, `should_`, `can_`) that read as yes/no questions.

**Incorrect (problematic pattern):**

```rust
fn btrfs(path: &Path) -> bool { ... }
fn paused(&self) -> bool { ... }
fn cpu_significant(&self, threshold: f64) -> bool { ... }
fn capture(&self, state: &PidState) -> bool { ... }
fn empty(&self) -> bool { ... }
```

**Correct (recommended pattern):**

```rust
fn is_btrfs(path: &Path) -> bool { ... }
fn is_paused(&self) -> bool { ... }
fn is_cpu_significant(&self, threshold: f64) -> bool { ... }
fn should_capture(&self, state: &PidState) -> bool { ... }

// has_ for ownership/containment
fn has_children(&self) -> bool { ... }
fn has_error(&self) -> bool { ... }

// can_ for capability checks
fn can_write(&self) -> bool { ... }
fn can_connect(&self) -> bool { ... }
```

```rust
// Usage reads naturally
if is_btrfs(&path) && !reader.is_paused() {
    if should_capture(&pid_state) {
        collect_stats();
    }
}
```

**When NOT to use:**
- Standard library conventions (`is_empty()` is fine without the underscore for trait impls)
- When the method name is already clearly boolean (`exists()`, `contains()`)
