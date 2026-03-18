---
title: Design for Cancellation Safety in Async Code
impact: MEDIUM-HIGH
impactDescription: prevents resource leaks and partial state corruption on cancel
tags: asyncp, cancellation, safety, select, drop
---

## Design for Cancellation Safety in Async Code

When a future is used in `tokio::select!`, the non-winning branches are dropped mid-execution. Design futures so that partial progress is either committed atomically or rolled back on drop. Do not leave shared state in an inconsistent intermediate form between await points.

**Incorrect (partial write visible if cancelled between awaits):**

```rust
async fn transfer_funds(
    ledger: &Mutex<Ledger>,
    from: AccountId,
    to: AccountId,
    amount: u64,
) {
    let mut l = ledger.lock().await;
    l.debit(from, amount);
    // If cancelled here, funds are debited but not credited
    external_notify(&from).await;
    l.credit(to, amount);
}
```

**Correct (atomic commit, safe to cancel at any point):**

```rust
async fn transfer_funds(
    ledger: &Mutex<Ledger>,
    from: AccountId,
    to: AccountId,
    amount: u64,
) {
    let mut l = ledger.lock().await;
    l.transfer(from, to, amount);
    drop(l);
    // Notification is best-effort; cancellation is safe
    let _ = external_notify(&from).await;
}
```
