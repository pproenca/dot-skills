---
title: Use Builder Pattern with Method Chaining
impact: MEDIUM
impactDescription: Builders enable flexible construction while keeping structs immutable
tags: type, builder, construction, pattern
---

## Use Builder Pattern with Method Chaining

Implement builder pattern using a separate XBuilder struct with methods that take and return `Self` by value for method chaining.

**Incorrect (problematic pattern):**

```rust
// Mutable reference chaining - awkward
pub struct RenderConfigBuilder {
    rc: RenderConfig,
}

impl RenderConfigBuilder {
    pub fn title(&mut self, title: &str) -> &mut Self {
        self.rc.title = Some(title.into());
        self
    }
}

// Usage
let mut builder = RenderConfigBuilder::new();
builder.title("My Title");
builder.width(80);
let config = builder.get();  // Have to call separately
```

**Correct (recommended pattern):**

```rust
pub struct RenderConfig {
    pub title: Option<String>,
    pub format: Option<RenderFormat>,
    pub width: Option<u32>,
}

pub struct RenderConfigBuilder {
    rc: RenderConfig,
}

impl RenderConfigBuilder {
    pub fn new() -> Self {
        Self { rc: RenderConfig::default() }
    }

    // Take self by value, return Self
    pub fn title<T: AsRef<str>>(mut self, title: T) -> Self {
        self.rc.title = Some(title.as_ref().to_owned());
        self
    }

    pub fn format(mut self, format: RenderFormat) -> Self {
        self.rc.format = Some(format);
        self
    }

    pub fn width(mut self, width: u32) -> Self {
        self.rc.width = Some(width);
        self
    }

    // Consume builder to produce final value
    pub fn build(self) -> RenderConfig {
        self.rc
    }
}

// Usage - clean chaining
let config = RenderConfigBuilder::new()
    .title("CPU Stats")
    .format(RenderFormat::Table)
    .width(120)
    .build();
```

**When NOT to use:**
- Simple structs with few fields
- Structs where all fields are required (use constructor)
