---
title: Consolidate near-duplicate routes/layouts/components into one with variants or composition
impact: HIGH
impactDescription: collapses 2+ structurally identical routes or components into a single source, eliminates parallel-edit cost and copy-paste drift
tags: cross, duplication, consolidation, route-variants, composition
---

## Consolidate near-duplicate routes/layouts/components into one with variants or composition

**This is a cross-cutting rule.** It surfaces only when 2+ routes/components are read side-by-side and recognized as the same shape with different labels.

### Shapes to recognize

- Two `app/<entity-a>/page.tsx` and `app/<entity-b>/page.tsx` with the same JSX skeleton, same data-fetcher shape, differing only by entity name and a couple of strings.
- Two layouts with the same `<header><main><footer>` shell and identical children handling, differing only by a className or a static title.
- Two parallel routes (`@modalA`, `@modalB`) whose content components are 90% the same — should be one slot with a discriminated prop.
- Two route handlers (`/api/v1/users` and `/api/v1/members`) doing the same CRUD against different tables — usually a sign that the *data model* should be one with a `kind` column.
- Two `(group-a)/page.tsx` and `(group-b)/page.tsx` files that exist only to apply different route groups to functionally identical content.

### Detection procedure

1. After Categories 1–8, list every `page.tsx`, `layout.tsx`, and major Client Component by JSX shape signature (top-level element + child element types, ignoring children content).
2. For each signature with 2+ members, ask: would a single component with a discriminated prop, a dynamic route segment (`[kind]`), or a `children`-based composition cover both?
3. **Two criteria to consolidate** (both must hold): structural similarity ≥ 90%, AND a clean variant axis (one slug, one prop, one branch).

### Multi-file example

**Incorrect (two routes, two files, parallel edits required):**

```typescript
// app/users/[id]/page.tsx
export default async function UserPage({ params }: { params: { id: string } }) {
  const user = await getUser(params.id)
  return (
    <article className="profile">
      <Avatar src={user.avatarUrl} />
      <h1>{user.name}</h1>
      <p>{user.bio}</p>
      <Link href={`/users/${user.id}/edit`}>Edit user</Link>
    </article>
  )
}

// app/members/[id]/page.tsx — identical shape, different entity
export default async function MemberPage({ params }: { params: { id: string } }) {
  const member = await getMember(params.id)
  return (
    <article className="profile">
      <Avatar src={member.avatarUrl} />
      <h1>{member.name}</h1>
      <p>{member.bio}</p>  // drift: was "tagline" in UserPage at some point
      <Link href={`/members/${member.id}/edit`}>Edit member</Link>
    </article>
  )
}
```

Two routes that diverge every time anyone touches profile UI.

**Correct (Option 1: one route with a dynamic segment):**

```typescript
// app/[kind]/[id]/page.tsx (where kind is 'users' | 'members')
type Kind = 'users' | 'members'

export default async function ProfilePage({
  params,
}: {
  params: { kind: Kind; id: string }
}) {
  const profile = await getProfile(params.kind, params.id)
  return (
    <article className="profile">
      <Avatar src={profile.avatarUrl} />
      <h1>{profile.name}</h1>
      <p>{profile.tagline}</p>
      <Link href={`/${params.kind}/${profile.id}/edit`}>Edit {profile.singular}</Link>
    </article>
  )
}
```

**Correct (Option 2: shared component, two thin routes if route groups matter):**

```typescript
// components/profile/ProfilePage.tsx
export async function ProfilePage({ profile, basePath }: { profile: Profile; basePath: string }) {
  return (
    <article className="profile">
      <Avatar src={profile.avatarUrl} />
      <h1>{profile.name}</h1>
      <p>{profile.tagline}</p>
      <Link href={`${basePath}/${profile.id}/edit`}>Edit</Link>
    </article>
  )
}

// app/users/[id]/page.tsx — thin
export default async function UserRoute({ params }) {
  return <ProfilePage profile={await getUser(params.id)} basePath="/users" />
}

// app/members/[id]/page.tsx — thin
export default async function MemberRoute({ params }) {
  return <ProfilePage profile={await getMember(params.id)} basePath="/members" />
}
```

Option 1 collapses to one route segment. Option 2 keeps two routes (for routing/metadata divergence) but shares the body.

### When NOT to consolidate

- The two routes are in different access tiers (admin vs public) and the divergence is *intentional* (different layouts, different middleware checks).
- One route is server-rendered statically and the other is dynamic — Next.js may force them apart even if they look alike.
- The data shapes are nominally the same but semantically different (e.g., users have permissions; members don't).

### Risk before consolidating

- If the two routes have different metadata (`generateMetadata`), the merge needs to handle both.
- Parallel/intercepting route conventions can break silently — verify after merging.
- Sitemaps and `robots.ts` may reference both paths separately.

Reference: [Dynamic Routes](https://nextjs.org/docs/app/building-your-application/routing/dynamic-routes), [Route Groups](https://nextjs.org/docs/app/building-your-application/routing/route-groups)
