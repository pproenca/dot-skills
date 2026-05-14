---
title: Wrap Third-Party Hooks in Custom Hooks
impact: MEDIUM-HIGH
impactDescription: localizes library-version churn to a single file
tags: bound, hooks, third-party, abstraction
---

## Wrap Third-Party Hooks in Custom Hooks

When 25 components each call `useSession()` from next-auth and reach into `session.user.id`, every library upgrade or auth-strategy change forces a 25-file rewrite. A single custom hook — `useCurrentUser()` — owns the shape and returns a domain-typed result. The library swap becomes a one-file change; downstream code doesn't notice.

**Incorrect (library shape leaks into every consumer):**

```tsx
// 25 components do this. Migrate from next-auth to Clerk?
// Migrate to JWT? Every call site breaks.
import { useSession } from 'next-auth/react';

function OrderHistory() {
  const { data: session, status } = useSession();
  if (status === 'loading') return <Spinner />;
  if (!session?.user?.id) return <SignInPrompt />;
  return <OrdersList userId={session.user.id} />;
}
```

**Correct (one wrapper, domain-typed; consumers don't import the library):**

```tsx
// useCurrentUser is the only file that imports next-auth.
// Domain consumers get a typed UserId and don't care about the provider.
function useCurrentUser(): { id: UserId; email: string } | null {
  const { data } = useSession();
  if (!data?.user?.id || !data.user.email) return null;
  return { id: data.user.id as UserId, email: data.user.email };
}

function OrderHistory() {
  const user = useCurrentUser();
  if (user === null) return <SignInPrompt />;
  return <OrdersList userId={user.id} />;
}
```

**When NOT to apply this pattern:**
- Prototypes and spikes — wrapping before you know what shape you want is premature abstraction.
- Pure renames with no abstraction value — `const useMyQuery = useQuery` adds an import indirection without changing anything.
- Libraries that ARE already the domain abstraction — `useNavigate` from react-router or `useParams` are thin and stable enough that re-wrapping them adds noise.

**Why this matters:** Wrapping turns a wide change surface (every consumer) into a narrow one (one wrapper) — the same locality-of-change principle that motivates DTO/domain separation.

Reference: [Clean Code, Chapter 8: Boundaries](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [React Docs: Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
