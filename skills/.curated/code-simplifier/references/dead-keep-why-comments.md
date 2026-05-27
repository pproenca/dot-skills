---
title: Keep Comments That Explain Why, Not What
impact: MEDIUM
impactDescription: Why-comments preserve context, preventing 80% of "cleanup" bugs where devs break intentional behavior
tags: dead, comments, documentation, context, intent
---

## Keep Comments That Explain Why, Not What

Code shows what happens; only comments can explain why. Keep comments that capture business decisions, workarounds, non-obvious constraints, and historical context. These comments prevent future developers from "fixing" intentional behavior or repeating mistakes that led to the current implementation.

**Incorrect (removing valuable context):**

```typescript
// Before removing comments:
function processPayment(amount: number): boolean {
  // Visa requires amounts in cents, not dollars
  const centAmount = Math.round(amount * 100);

  // Retry limit set by PCI compliance audit (see JIRA-4521)
  const maxRetries = 3;

  // Must sleep 100ms between retries - payment gateway rate limits
  // Discovered during Black Friday 2023 outage
  for (let i = 0; i < maxRetries; i++) {
    if (gateway.charge(centAmount)) return true;
    sleep(100);
  }
  return false;
}

// After overzealous cleanup - WRONG:
function processPayment(amount: number): boolean {
  const centAmount = Math.round(amount * 100);
  const maxRetries = 3;

  for (let i = 0; i < maxRetries; i++) {
    if (gateway.charge(centAmount)) return true;
    sleep(100);
  }
  return false;
}
// Future dev removes sleep(100) as "unnecessary" -> outage
// Future dev changes maxRetries to 10 -> compliance violation
```

**Correct (preserve why comments):**

```typescript
function processPayment(amount: number): boolean {
  // Visa requires amounts in cents, not dollars
  const centAmount = Math.round(amount * 100);

  // Retry limit set by PCI compliance audit (JIRA-4521)
  const maxRetries = 3;

  // 100ms delay required by payment gateway rate limits (Black Friday 2023 postmortem)
  for (let i = 0; i < maxRetries; i++) {
    if (gateway.charge(centAmount)) return true;
    sleep(100);
  }
  return false;
}
```

**Comments worth keeping:**

```python
# Business rule: orders over $10k require manual approval (legal requirement)
if order.total > 10000:
    order.status = "pending_review"

# HACK: Safari doesn't support this API before v15, polyfill only for Safari
# Remove after dropping Safari 14 support (EOL March 2024)
if is_safari and version < 15:
    load_polyfill()

# WARNING: DO NOT change sort order - downstream systems depend on this
# exact ordering for invoice reconciliation (see incident #892)
transactions.sort(key=lambda t: (t.date, t.id))

# Performance: using raw SQL because ORM generates N+1 queries here
# Benchmarked: 50ms vs 2.3s for 1000 records
cursor.execute(RAW_QUERY, params)

# Counterintuitive: we check for empty BEFORE validation because
# empty arrays are valid (user clearing their cart) but the validator
# rejects them. Business confirmed this behavior in Q3 product review.
if not items:
    return Success(empty_cart)
```

**Comments to remove vs keep:**

```javascript
// REMOVE: States the obvious
const isActive = user.status === 'active';  // Check if user is active

// KEEP: Explains non-obvious business rule
const isActive = user.status === 'active';  // "suspended" users can still view but not purchase

// REMOVE: Describes the code
for (const item of items) {  // Loop through items
  process(item);
}

// KEEP: Explains why this approach was chosen
for (const item of items) {  // forEach breaks on async - must use for...of
  await process(item);
}

// REMOVE: Documents obvious type
let count: number = 0;  // Number to track count

// KEEP: Documents why type is unusual
let count: number = 0;  // Must be number (not bigint) for legacy API compatibility
```

### Categories of Why Comments Worth Keeping

1. **Business rules**: Legal, compliance, contractual requirements
2. **Workarounds**: Browser bugs, library quirks, API limitations
3. **Performance**: Why a non-obvious approach was faster
4. **Historical**: Incidents, postmortems, decisions that led here
5. **Warnings**: Things that look wrong but are intentional

### Benefits

- Preserves institutional knowledge
- Prevents regression of intentional behavior
- Reduces "why is this here?" Slack messages
- Makes code archaeology faster during incidents
- Protects against well-meaning "cleanup" that breaks things
