---
title: Lift Shared Lines Out of Mirrored Branches
impact: HIGH
impactDescription: reduces twin if/else bodies to one shared block plus the actual difference
tags: dup, branches, conditionals, refactor
---

## Lift Shared Lines Out of Mirrored Branches

When the `if` and `else` branches of a conditional contain the same five lines plus one different line, the common lines are *not* about the condition — they always run. The condition is only deciding the differing line. Pulling shared lines out (above or below the conditional) shrinks the function, makes the actual decision visible, and prevents the common case where someone edits one branch and forgets the other.

**Incorrect (mirrored branches with one real difference):**

```typescript
function recordPayment(payment: Payment, user: User): Receipt {
  if (payment.method === 'card') {
    const receipt = createReceipt(payment);
    receipt.lineItems = payment.lineItems;
    receipt.timestamp = Date.now();
    receipt.processor = 'stripe';
    saveReceipt(receipt);
    notifyAccounting(receipt);
    return receipt;
  } else {
    const receipt = createReceipt(payment);
    receipt.lineItems = payment.lineItems;
    receipt.timestamp = Date.now();
    receipt.processor = 'ach';
    saveReceipt(receipt);
    notifyAccounting(receipt);
    return receipt;
  }
  // 12 lines, of which 10 are duplicated. The condition decides ONE field.
}
```

**Correct (the shared work happens once; the decision is one line):**

```typescript
function recordPayment(payment: Payment, user: User): Receipt {
  const receipt = createReceipt(payment);
  receipt.lineItems = payment.lineItems;
  receipt.timestamp = Date.now();
  receipt.processor = payment.method === 'card' ? 'stripe' : 'ach';
  saveReceipt(receipt);
  notifyAccounting(receipt);
  return receipt;
}
// The condition is now where the decision is, not where the duplication lives.
```

**A more interesting case — the diff is in the middle:**

```typescript
// Incorrect:
if (kind === 'export') {
  validate(payload);
  authorize(user, 'export');
  log('export.start');
  doExport(payload);
  log('export.done');
} else {
  validate(payload);
  authorize(user, 'import');
  log('import.start');
  doImport(payload);
  log('import.done');
}

// Correct (lift the structure, parameterize the inner action and labels):
const action  = kind === 'export' ? doExport : doImport;
const verb    = kind;
validate(payload);
authorize(user, verb);
log(`${verb}.start`);
action(payload);
log(`${verb}.done`);
// Five lines, no branch — the difference is captured in two variables.
```

**Symptoms:**

- Two branches with the same length and almost-identical structure.
- A code review comment of the form "you forgot to update the else branch."
- Adding a feature requires editing both branches in symmetric ways.
- The diff between branches highlights as a single line (or a few).

**When NOT to use this pattern:**

- The branches happen to look similar but model genuinely different operations that may diverge — refactor only after the duplication has appeared three times.
- The "shared" parts have subtly different orderings or interleavings — lifting them changes behaviour. Read carefully before lifting.

Reference: [Refactoring — Consolidate Duplicate Conditional Fragments](https://refactoring.com/) (Martin Fowler)
