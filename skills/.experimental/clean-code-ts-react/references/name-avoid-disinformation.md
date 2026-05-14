---
title: Avoid Misleading Names
impact: CRITICAL
impactDescription: prevents readers from acting on false assumptions baked into a name
tags: name, disinformation, types, accuracy
---

## Avoid Misleading Names

A name that contradicts the value's actual shape, behavior, or vocabulary is worse than a vague name — it actively misleads. If you call something `accountList` when it is an `Account[]`, every reader who knows JavaScript's `List` semantics (or comes from a `List<T>` language) will form wrong assumptions about cost and API. In TypeScript, the type system can carry the structure, so the name should carry the *concept*.

**Incorrect (name lies about the data structure or domain meaning):**

```tsx
// `accountList` implies a List API (push/pop/iterate). Reader expects list semantics.
// `oCustomer` Hungarian-style prefix actively misleads — it's a Map, not an object literal.
const accountList: Account[] = await fetchAccounts();
const oCustomer: Map<string, Customer> = await fetchCustomers();

// Two near-identical names for two unrelated concepts forces the reader to keep checking.
type Customer = { id: string; name: string };
type CustomerInfo = { plan: string; renewedAt: Date }; // not "info about Customer" — separate concept
```

**Correct (name matches the actual shape and the domain meaning):**

```tsx
// `accounts` matches the array. `customersById` says "this is keyed lookup".
// `Subscription` names the second concept for what it actually is.
const accounts: Account[] = await fetchAccounts();
const customersById: Map<string, Customer> = await fetchCustomers();

type Customer = { id: string; name: string };
type Subscription = { plan: string; renewedAt: Date };
```

**When NOT to apply this pattern:**
- Established team or industry vocabulary that *looks* misleading but is universally understood: `useState`, `useEffect`, `useId`, `useMemo` all bend the "verb phrase" rule (they're really queries returning values) but are React canon.
- Domain terms inherited from a business glossary (e.g., calling a REST handler a `Resource` even when it is not strictly REST) — fighting the team's shared vocabulary creates more confusion than the imperfect name.
- Single-letter identifiers like `l` and `O` are discouraged in *handwritten* code, but auto-generated identifiers (e.g., from codegen tools) where the convention is enforced elsewhere can stay.

**Why this matters:** A misleading name plants a false invariant in the reader's head; every downstream change is reasoned about against the wrong model.

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
