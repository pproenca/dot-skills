---
title: Type Safety Loses to Ergonomics at Stable Boundaries
impact: MEDIUM
impactDescription: prevents impossible-state representations at compile time
tags: meta, typescript, ergonomics, api-design
---

## Type Safety Loses to Ergonomics at Stable Boundaries

Maximally precise types catch maximally many bugs — in theory. In practice, callers must understand the types to use the API. Beyond a complexity threshold, precision becomes friction: devs write `as any`, copy-paste from working call sites without understanding why they work, and you've lost both safety AND ergonomics. At stable internal boundaries, boring beats clever.

**Incorrect (dogmatic precision — signature as puzzle):**

```ts
// Technically precise. Catches a few extra bugs the boring version wouldn't.
// In exchange: every caller stares at the signature for five minutes, and
// the team starts writing `as any` to bypass it.
function createUser<
  T extends Record<string, unknown>,
  K extends keyof T & string,
>(
  data: T,
  ...requiredKeys: [K, ...K[]]
): Pick<T, K> & { id: UserId; createdAt: Date } {
  // ...
}

// Caller spends real time figuring out what to pass.
const user = createUser({ email: 'a@b.c', name: 'A' } as const, 'email', 'name');
```

**Correct (balanced — precise where it pays, boring where it doesn't):**

```ts
// Boring. Obvious. Used correctly without thought.
// The precision the old signature added was buying nothing real:
// callers already pass CreateUserInput-shaped objects.
type CreateUserInput = {
  email: string;
  name: string;
};

function createUser(input: CreateUserInput): User {
  // ...
}

const user = createUser({ email: 'alice@example.com', name: 'Alice' });
```

**When NOT to apply this pattern:**
- Library APIs where the types ARE the contract — e.g., a fetcher that infers response shape from a route declaration; the gymnastics are doing real work for many unknown callers.
- Security-critical paths where loose types could allow exploitation (auth tokens, permission checks, sanitization) — pay the precision cost.
- Codebases with experienced TS teams where precision is the local norm — consistency with the codebase outweighs absolute ergonomics.

**Why this matters:** Type precision and ergonomics are both forms of intent communication — to the compiler and to the human. Optimizing one to the destruction of the other defeats both.

Reference: [Clean Code, Chapter 4: Comments (intent over precision)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Matt Pocock — Total TypeScript](https://www.totaltypescript.com/)
