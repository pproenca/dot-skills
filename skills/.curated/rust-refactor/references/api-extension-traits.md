---
title: Use Extension Traits to Add Methods to Foreign Types
impact: HIGH
impactDescription: adds functionality without wrapping, maintains ergonomic API
tags: api, extension, traits, foreign-types, coherence
---

## Use Extension Traits to Add Methods to Foreign Types

Define extension traits to add methods to types you don't own. This works around the orphan rule while providing ergonomic APIs.

**Incorrect (wrapper type loses ergonomics):**

```rust
// Can't impl directly on String due to orphan rule
struct EnhancedString(String);

impl EnhancedString {
    fn truncate_words(&self, max_words: usize) -> String {
        self.0.split_whitespace()
            .take(max_words)
            .collect::<Vec<_>>()
            .join(" ")
    }
}

// Awkward usage - must wrap every string
let enhanced = EnhancedString("hello world foo bar".to_string());
let truncated = enhanced.truncate_words(2);
```

**Correct (extension trait adds methods directly):**

```rust
pub trait StringExt {
    fn truncate_words(&self, max_words: usize) -> String;
}

impl StringExt for str {
    fn truncate_words(&self, max_words: usize) -> String {
        self.split_whitespace()
            .take(max_words)
            .collect::<Vec<_>>()
            .join(" ")
    }
}

// Natural usage after importing the trait
use crate::StringExt;

let text = "hello world foo bar";
let truncated = text.truncate_words(2);  // "hello world"
```

**Naming convention:** Use `Ext` suffix (e.g., `IteratorExt`, `ResultExt`, `StringExt`).

**Common use cases:**
- Adding convenience methods to standard library types
- Providing domain-specific operations
- Creating fluent APIs for third-party types

Reference: [Extension Traits - Rust Design Patterns](https://rust-unofficial.github.io/patterns/patterns/behavioural/newtype.html)
