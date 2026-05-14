---
title: Prop Drilling Often Smells Like Demeter Violation
impact: MEDIUM-HIGH
impactDescription: reduces structural coupling between distant components
tags: data, demeter, props, context
---

## Prop Drilling Often Smells Like Demeter Violation

The Law of Demeter says "don't talk to strangers": a function should only call methods of objects it directly knows. When `<Avatar>` four levels deep takes the whole `user` object just to read `user.imageUrl`, it has full knowledge of `User`'s structure — and every refactor of `User` risks breaking Avatar. Pass only what's needed, or hoist truly cross-cutting state into Context.

**Incorrect (each level handles the full `user` it doesn't need):**

```tsx
// Every intermediate component is now coupled to the User type
// even though only Avatar reads a single field.
function App({ user }: { user: User })          { return <Page user={user} />; }
function Page({ user }: { user: User })         { return <Sidebar user={user} />; }
function Sidebar({ user }: { user: User })      { return <Avatar user={user} />; }
function Avatar({ user }: { user: User }) {
  return <img src={user.profile.imageUrl} alt={user.name} />;
}
```

**Correct (pass only what's used; or use Context for true cross-cutting state):**

```tsx
// Intermediate components no longer know User's shape; only Avatar does.
function App({ user }: { user: User }) {
  return <Page imageUrl={user.profile.imageUrl} name={user.name} />;
}
function Page(props: AvatarProps)    { return <Sidebar {...props} />; }
function Sidebar(props: AvatarProps) { return <Avatar {...props} />; }

type AvatarProps = { imageUrl: string; name: string };
function Avatar({ imageUrl, name }: AvatarProps) {
  return <img src={imageUrl} alt={name} />;
}
// Alternative: put current user in AuthContext and let Avatar read it directly.
```

**When NOT to apply this pattern:**
- Shallow trees (one or two levels) — destructuring at the top adds noise without paying off.
- The prop is genuinely used at every intermediate level for other reasons (e.g., each level renders something user-specific).
- Reaching for Context would couple a dozen unrelated components to one store — sometimes explicit prop passing is the more honest dependency.

**Why this matters:** Reducing what each component knows about types it doesn't use makes refactors cheaper and re-render impact smaller — the same change-locality principle as DTO separation.

Reference: [Clean Code, Chapter 6: Objects and Data Structures (Law of Demeter)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Before You memo() — Dan Abramov](https://overreacted.io/before-you-memo/)
