---
title: Prefer Object Parameters Over Long Argument Lists
impact: CRITICAL
impactDescription: eliminates positional-argument errors and makes refactors safe
tags: func, parameters, arguments, object-params
---

## Prefer Object Parameters Over Long Argument Lists

Three or more positional arguments cross a cognitive threshold: callers can no longer remember which goes where, and reorderings or insertions become silent type-compatible mistakes (string-string-string is the canonical disaster). A destructured object parameter gives you named arguments, optional defaults, and refactor safety, with one extra line of boilerplate.

**Incorrect (five positional args — two booleans next to each other is a bug magnet):**

```ts
// Callers must memorize order. Adding a new field requires touching every call site.
function createMember(
  workspaceId: string,
  email: string,
  role: 'admin' | 'editor' | 'viewer',
  isActive: boolean,
  sendWelcomeEmail: boolean,
): Promise<Member> {
  return memberRepository.insert({ workspaceId, email, role, isActive, sendWelcomeEmail });
}

// Swap the two booleans and TS won't catch it.
await createMember('ws_1', 'a@b.com', 'editor', true, false);
```

**Correct (named object parameter — call site is self-documenting and refactor-safe):**

```ts
type CreateMemberInput = {
  workspaceId: string;
  email: string;
  role: 'admin' | 'editor' | 'viewer';
  isActive: boolean;
  sendWelcomeEmail?: boolean;
};

function createMember({
  workspaceId,
  email,
  role,
  isActive,
  sendWelcomeEmail = true,
}: CreateMemberInput): Promise<Member> {
  return memberRepository.insert({ workspaceId, email, role, isActive, sendWelcomeEmail });
}

// Self-documenting; reordering or adding fields is a no-op for existing callers.
await createMember({
  workspaceId: 'ws_1',
  email: 'a@b.com',
  role: 'editor',
  isActive: true,
  sendWelcomeEmail: false,
});
```

**When NOT to apply this pattern:**
- One or two strongly typed arguments where positional is unambiguous: `getMemberById(id: MemberId)` does not benefit from wrapping in `{ id }`.
- Math and utility functions where positional is the established convention: `clamp(value, min, max)`, `Math.max(a, b)`, `Math.atan2(y, x)`. Wrapping these obscures the well-known signature.
- React component props are already an object — `<CreateMemberForm input={{ workspaceId, email, ... }} />` would double-wrap and read worse than just spreading props onto the component directly.

**Why this matters:** Named parameters make function signatures resilient to evolution; positional ones break silently the moment requirements change.

Reference: [Clean Code, Chapter 3: Functions — Function Arguments](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Matt Pocock: Object Parameters](https://www.totaltypescript.com/)
