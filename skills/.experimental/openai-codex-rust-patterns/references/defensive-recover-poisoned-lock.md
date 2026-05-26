---
title: Recover a poisoned lock with into_inner instead of unwrapping it
impact: CRITICAL
impactDescription: stops one thread's panic from cascading a poisoned lock into every other holder
tags: defensive, mutex, poison, panic-discipline
---

## Recover a poisoned lock with into_inner instead of unwrapping it

`mutex.lock().unwrap()` is the idiomatic-looking default, and in a long-lived multi-task agent it is a latent outage: if any thread panics while holding the lock, the `Mutex` becomes *poisoned*, and from then on every other `.lock().unwrap()` panics too. A single recoverable failure in one task thereby cascades into a process-wide crash. On its long-lived paths codex recovers the guarded data from the poison error instead of unwrapping — consistent with the workspace setting `unwrap_used = "deny"` (see [[defensive-deny-unwrap-workspace-wide]]).

**Incorrect (poison turns one panic into a chain reaction):**

```rust
let mut emitted = self.app_used_emitted_keys.lock().unwrap(); // panics forever once poisoned
```

**Correct (recover the data and keep serving):**

```rust
// analytics/src/client.rs — recover through the PoisonError
let mut emitted = self
    .app_used_emitted_keys
    .lock()
    .unwrap_or_else(std::sync::PoisonError::into_inner);

// the match form is equivalent and used where `?`-style reads better:
let guard = match self.cache.lock() {
    Ok(g) => g,
    Err(poisoned) => poisoned.into_inner(),
};
```

`PoisonError::into_inner` hands back the same `MutexGuard`, so the surviving threads keep working instead of inheriting an unrelated task's panic. Recover like this when the panicking section didn't leave the guarded value half-updated; if a broken invariant is possible, reset the state explicitly rather than blindly trusting it. The idiom recurs at ~40 call sites across ~17 crates precisely because process longevity depends on it.

Reference: `codex-rs/analytics/src/client.rs:95`, `codex-rs/keyring-store/src/lib.rs:128`.
