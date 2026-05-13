---
title: Converge on canonical names when the same concept wears different prop names across components
impact: MEDIUM-HIGH
impactDescription: eases composition and reuse, removes one-line adapter wrappers, reduces cognitive overhead during reads
tags: cross, naming, prop-drift, types, conventions
---

## Converge on canonical names when the same concept wears different prop names across components

**This is a cross-cutting rule.** A single component's prop names always look reasonable — drift is only visible when you compare components.

### Shapes to recognize

- The same conceptual entity carried under different prop names: `user` / `member` / `account` / `profile`, when the underlying type is the same.
- The same event under different handler names: `onChange` / `onUpdate` / `onSelect` / `onValueChange` for what is conceptually "the value changed."
- The same loading/error/data tri-state with field names that drift: `loading` / `isLoading` / `pending` / `busy`, and `error` / `err` / `errors` / `failure`.
- The same identifier under different names: `id` / `key` / `slug` / `name` when all three call sites mean "the URL-safe handle."
- Container components accepting `children` under names like `content`, `body`, `items`, `slot` for what is conceptually just the React children.

### Detection procedure

1. Build a prop-name frequency table across the inventory. For each component, list its props with their types.
2. Group props by type signature (e.g. all props typed `User`, all props typed `() => void`).
3. For each group with > 1 name, ask: *is the difference meaningful (domain concept) or accidental (whoever wrote this picked a name)?*
4. Concept-meaningful drift is fine. Accidental drift is the finding.

### Multi-file example

**Incorrect (five components, same concept, five names, one-line adapter wrappers proliferating):**

```typescript
// src/profile/Profile.tsx
function Profile({ user }: { user: User }) { /* ... */ }

// src/team/TeamRow.tsx
function TeamRow({ member }: { member: User }) { /* ... same type! */ }

// src/billing/AccountHeader.tsx
function AccountHeader({ account }: { account: User }) { /* ... */ }

// src/auth/CurrentUserBadge.tsx
function CurrentUserBadge({ profile }: { profile: User }) { /* ... */ }

// src/admin/ImpersonationBar.tsx
function ImpersonationBar({ subject }: { subject: User }) { /* ... */ }
```

Composition becomes painful — every call site that wants to pass the same user has to remember which name *this* component wants. Adapter wrappers start to appear:

```typescript
// src/team/MemberCard.tsx — a wrapper that exists only to rename
function MemberCard({ user }: { user: User }) {
  return <TeamRow member={user} />
}
```

**Correct (one canonical name, no adapters, easier reads):**

```typescript
function Profile({ user }: { user: User }) { /* ... */ }
function TeamRow({ user }: { user: User }) { /* ... */ }
function AccountHeader({ user }: { user: User }) { /* ... */ }
function CurrentUserBadge({ user }: { user: User }) { /* ... */ }
function ImpersonationBar({ user }: { user: User }) { /* ... */ }
```

When the concept truly is "the impersonated user," keep `subject` and make the type a narrower `ImpersonationSubject`. The rule is *converge when the concept is the same*, not *use the same name for everything*.

**Event-handler example:**

```typescript
// Before — three pickers, three handler names, same signature.
<DatePicker onChange={(d) => setDate(d)} />
<UserPicker onSelect={(u) => setUser(u)} />
<TagPicker onValueChange={(tags) => setTags(tags)} />

// After — converge on onChange across "picker"-shaped components.
<DatePicker onChange={setDate} />
<UserPicker onChange={setUser} />
<TagPicker onChange={setTags} />
```

### Cross-file observation shape (what the audit emits)

| Concept | Type | Names found | Suggested canonical | Files |
|---|---|---|---|---|
| logged-in user | `User` | `user`, `member`, `account`, `profile`, `subject` | `user` | 5 files |
| value-changed event | `(v: T) => void` | `onChange`, `onUpdate`, `onSelect`, `onValueChange` | `onChange` | 8 files |
| loading flag | `boolean` | `loading`, `isLoading`, `pending`, `busy` | `loading` | 12 files |

### When NOT to converge

- The concepts genuinely differ — `user` vs `currentUser` vs `targetUser` may all be `User`-typed but mean different things in context. Names that distinguish role/relationship are load-bearing.
- The drift exists at a package boundary (e.g. you're wrapping a third-party `<Select onValueChange={}>`) and changing the inner name would lie about the underlying component.
- You're about to convert a prop into a more specific narrowed type — then the rename is part of the same refactor, not a standalone fix.

### Risk before renaming

- Every rename is an API change for any external consumer. Run a global search for the old name before renaming.
- If the component is exported from a package, treat this as a breaking change and bump major.
- Codemod with `ts-morph` or similar when > 10 call sites — manual rename is error-prone past that.

Reference: [Passing Props to a Component](https://react.dev/learn/passing-props-to-a-component)
