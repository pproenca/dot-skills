---
title: Use Into Conversions for Ergonomic APIs
impact: CRITICAL
impactDescription: reduces callsite verbosity, accepts both &str and String
tags: own, into, conversion, api-design, ergonomics
---

## Use Into Conversions for Ergonomic APIs

Accept `impl Into<String>` instead of `String` in constructors and builder methods. This lets callers pass `&str`, `String`, or any type implementing `Into<String>` without explicit `.to_string()` calls at every callsite.

**Incorrect (forces callers to convert):**

```rust
pub fn new(base_url: String) -> Result<Self> {
    let parsed = Url::parse(&base_url)?;
    Ok(Self { base_url: parsed })
}
// Callsite: Client::new(url.to_string())?
```

**Correct (accepts any string-like type):**

```rust
pub fn new(base_url: impl Into<String>) -> Result<Self> {
    let url_string = base_url.into();
    let parsed = Url::parse(&url_string)?;
    Ok(Self { base_url: parsed })
}
// Callsite: Client::new("https://api.example.com")?
```
