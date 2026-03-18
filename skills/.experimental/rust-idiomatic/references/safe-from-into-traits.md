---
title: Implement From and Into for Type Conversions
impact: HIGH
impactDescription: enables automatic conversion with ? operator and .into()
tags: safe, from, into, conversion, traits, interoperability
---

## Implement From and Into for Type Conversions

Implement `From<A> for B` for lossless, infallible type conversions. This automatically provides `Into<B> for A` and enables the `?` operator for error type conversion. Use `TryFrom` when the conversion can fail.

**Incorrect (manual conversion scattered across callsites):**

```rust
fn convert_usage(api_usage: ResponseCompletedUsage) -> TokenUsage {
    TokenUsage {
        input_tokens: api_usage.input_tokens as i64,
        output_tokens: api_usage.output_tokens as i64,
        total_tokens: api_usage.total_tokens as i64,
    }
}
// Called as: let usage = convert_usage(response.usage);
```

**Correct (From implementation, used with .into()):**

```rust
impl From<ResponseCompletedUsage> for TokenUsage {
    fn from(usage: ResponseCompletedUsage) -> Self {
        Self {
            input_tokens: usage.input_tokens as i64,
            output_tokens: usage.output_tokens as i64,
            total_tokens: usage.total_tokens as i64,
        }
    }
}
// Called as: let usage: TokenUsage = response.usage.into();
```
