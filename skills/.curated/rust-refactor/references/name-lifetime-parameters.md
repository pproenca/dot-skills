---
title: Use Single Lowercase Letters for Lifetimes
impact: LOW
impactDescription: Consistent lifetime naming follows Rust conventions
tags: name, lifetimes, conventions
---

## Use Single Lowercase Letters for Lifetimes

Lifetime parameters use single lowercase letters, typically starting with `'a`. Use descriptive names only when multiple lifetimes need distinction.

**Incorrect (problematic pattern):**

```rust
struct Reader<'reader_lifetime> {
    data: &'reader_lifetime [u8],
}

fn process<'input_data, 'output_buffer>(
    input: &'input_data str,
    output: &'output_buffer mut String,
) { ... }
```

**Correct (recommended pattern):**

```rust
// Simple case - single lifetime
struct Reader<'a> {
    data: &'a [u8],
}

struct NetworkStats<'a> {
    net: &'a procfs::NetStat,
    ethtool: &'a Option<ethtool::EthtoolStats>,
}

// Multiple lifetimes - alphabetical
fn process<'a, 'b>(
    input: &'a str,
    output: &'b mut String,
) { ... }

// When distinction helps readability
struct Parser<'input, 'arena> {
    source: &'input str,
    allocator: &'arena Arena,
}
```

```rust
// Lifetime elision - prefer when possible
impl Reader<'_> {
    fn get_slice(&self) -> &[u8] {  // Elided lifetime
        self.data
    }
}

// Anonymous lifetime for clarity
fn parse(input: &str) -> Result<'_, ParseError> { ... }
```

**When NOT to use:**
- When multiple lifetimes with different semantic meanings benefit from descriptive names
- In complex trait bounds where alphabetical letters become confusing
