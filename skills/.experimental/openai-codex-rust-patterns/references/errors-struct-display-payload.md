---
title: Store display-relevant error state in a struct, not a string
impact: HIGH
impactDescription: enables plan-specific tests to assert against error state instead of fragile English sentences
tags: errors, display, ui, testing
---

## Store display-relevant error state in a struct, not a string

When an error needs rich user-facing rendering (plan-specific wording, retry timestamps, request ids), the temptation is to format the final message at construction time: `CodexErr::UsageLimit(format!("You've hit..."))`. Every test that wants to check a plan-specific code path then does substring matching on a fragile English sentence. Codex keeps the raw inputs in a struct, hand-writes `impl Display`, and embeds the struct in the error enum — so tests assert against structured state and the UI still gets a clean error string.

**Incorrect (format at construction, lose the state):**

```rust
fn usage_limit_error(plan: PlanType, reset: DateTime<Utc>) -> CodexErr {
    let msg = format!(
        "You've reached your {} plan limit. Resets at {}.",
        plan.name(),
        reset.format("%H:%M"),
    );
    CodexErr::UsageLimitReached(msg)
}
// Test: assert!(err.to_string().contains("Pro plan")); — breaks on wording change
```

**Correct (structured payload, Display renders lazily):**

```rust
// protocol/src/error.rs
#[derive(Debug)]
pub struct UsageLimitReachedError {
    pub plan_type: Option<PlanType>,
    pub resets_at: Option<DateTime<Utc>>,
    pub rate_limits: Option<Box<RateLimitSnapshot>>,
    pub promo_message: Option<String>,
}

impl std::fmt::Display for UsageLimitReachedError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let message = match self.plan_type.as_ref() {
            Some(PlanType::Known(KnownPlan::Plus)) => format!(/* ... */),
            /* other plans */
            _ => "Usage limit reached".to_string(),
        };
        write!(f, "{message}")
    }
}

#[derive(Debug, thiserror::Error)]
pub enum CodexErr {
    #[error("{0}")]
    UsageLimitReached(UsageLimitReachedError),
    /* ... */
}
```

`rate_limits` is boxed to keep the enum variant small enough to pass the workspace's `large-error-threshold = 256` clippy lint. Tests assert against `err.plan_type` and `err.resets_at` directly; the UI still gets `err.to_string()`.

Reference: `codex-rs/protocol/src/error.rs:441`.
