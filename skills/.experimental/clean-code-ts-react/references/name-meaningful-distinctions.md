---
title: Make Meaningful Distinctions
impact: CRITICAL
impactDescription: prevents noise-word naming collisions
tags: name, distinction, noise-words, parameters
---

## Make Meaningful Distinctions

When two names exist side by side, the difference between them should describe a difference in the *thing*, not be noise added to dodge a name clash. `a1`/`a2`, `data`/`dataInfo`, `getActiveAccount`/`getActiveAccountInfo` all force the reader to open both definitions to learn which is which. Make the distinction part of the name.

**Incorrect (noise words disguise the lack of a real distinction):**

```ts
// Which is source and which is target? You must read the body — or guess.
function copyChars(a1: string[], a2: string[]): void {
  for (let i = 0; i < a1.length; i++) {
    a2[i] = a1[i];
  }
}

// Three functions, three suffixes, zero clarity on what differs.
function getActiveAccount(id: string): Account { /* ... */ }
function getActiveAccountInfo(id: string): Account { /* ... */ }
function getActiveAccountData(id: string): Account { /* ... */ }
```

**Correct (the name itself states what differs):**

```ts
// Now the call site reads as a sentence.
function copyChars(source: string[], destination: string[]): void {
  for (let i = 0; i < source.length; i++) {
    destination[i] = source[i];
  }
}

// One canonical getter; the other concerns get names that describe them.
function getActiveAccount(id: string): Account { /* ... */ }
function getAccountBillingSummary(id: string): BillingSummary { /* ... */ }
function getAccountAuditTrail(id: string): AuditEvent[] { /* ... */ }
```

**When NOT to apply this pattern:**
- When the suffix IS the meaningful distinction: `accountsActive` vs `accountsArchived` both name a real status; that is not noise.
- Short-lived destructuring tuples where the convention itself is the contract: `const [value, setValue] = useState(...)` — `value`/`setValue` is canonical React pairing and resisting it adds friction.
- Generated identifiers in tests or fixtures (`user1`, `user2`) where the numeric suffix means "another instance for the test" rather than a domain distinction.

**Why this matters:** Meaningful distinctions push the cost of disambiguation onto the writer (once) instead of the reader (every time).

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
