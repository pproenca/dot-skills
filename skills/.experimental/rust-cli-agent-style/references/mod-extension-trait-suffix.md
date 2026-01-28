---
title: Use Ext suffix for extension traits
impact: MEDIUM
impactDescription: Clear naming distinguishes extension traits from core traits
tags: mod, traits, naming
---

# Use Ext suffix for extension traits

Name extension traits with the `Ext` suffix to distinguish them from core traits.

## Why This Matters

- Clear indication of extension trait
- Conventional in Rust ecosystem
- Easy to find extension methods
- Distinguishes from main trait

**Incorrect (avoid this pattern):**

```rust
// Ambiguous - is this the main trait or extension?
pub trait OrCancel {
    fn or_cancel(&self) -> Result<()>;
}

pub trait RectHelpers {
    fn center(&self) -> Point;
}
```

**Correct (recommended):**

```rust
// Clear extension trait naming
pub trait OrCancelExt {
    fn or_cancel(self, token: CancellationToken) -> OrCancel<Self>
    where
        Self: Sized;
}

pub trait RectExt {
    fn center(&self) -> Point;
    fn contains_point(&self, point: Point) -> bool;
}

pub trait StreamExt {
    fn aggregate(self) -> AggregateStream<Self>
    where
        Self: Sized;
}
```

## Implementation Pattern

```rust
// Extension trait for existing type
pub trait RectExt {
    fn center(&self) -> Point;
}

impl RectExt for Rect {
    fn center(&self) -> Point {
        Point {
            x: self.x + self.width / 2,
            y: self.y + self.height / 2,
        }
    }
}

// Usage requires importing the extension trait
use crate::RectExt;

let rect = Rect::new(0, 0, 100, 100);
let center = rect.center();  // Extension method
```

## Common Patterns

- `FutureExt` - extensions for `Future`
- `StreamExt` - extensions for `Stream`
- `IteratorExt` - extensions for `Iterator`
- `ResultExt` - extensions for `Result`
- `OptionExt` - extensions for `Option`
