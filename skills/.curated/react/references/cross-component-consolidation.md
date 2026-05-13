---
title: Consolidate near-duplicate components into one with variants or composition
impact: HIGH
impactDescription: collapses 2+ structurally identical components into a single source, eliminates parallel-edit cost
tags: cross, duplication, consolidation, variants, composition
---

## Consolidate near-duplicate components into one with variants or composition

**This is a cross-cutting rule.** It surfaces only when 2+ components are read side-by-side and recognized as the same shape with different labels.

### Shapes to recognize

- Two components with the same JSX skeleton (same elements, same nesting, same className taxonomy) differing only in: hardcoded text, icon imports, color tokens, accessor names on a single object prop.
- Two components named after their data (`UserCard`, `MemberCard`, `OrgCard`) when their data shapes share the same display fields (`name`, `avatarUrl`, `tagline`).
- Two components named after a state (`EmptyState`, `ErrorState`, `LoadingState`) whose JSX shapes are 90% the same — title + icon + body + optional action.
- Component A and component B where B is "component A but with one branch removed/added" — an in-disguise conditional.
- Two route-level pages whose layouts differ only by which child sections they include.

### Detection procedure

1. After Categories 1–8, list every component in the inventory by JSX shape signature (top-level element + child element types, ignoring children content).
2. For each signature with 2+ members, ask: would a single component with a discriminated prop or a `children`-based composition cover both?
3. **Two criteria to consolidate** (both must hold): structural similarity ≥ 90%, AND a clean variant axis (one prop, one branch).

### Multi-file example

**Incorrect (two cards, two files, parallel edits required):**

```typescript
// src/users/UserCard.tsx
function UserCard({ user }: { user: User }) {
  return (
    <article className="card">
      <img src={user.avatarUrl} alt="" className="card-avatar" />
      <h3 className="card-title">{user.name}</h3>
      <p className="card-tagline">{user.tagline}</p>
      <Link to={`/users/${user.id}`}>View user</Link>
    </article>
  )
}

// src/members/MemberCard.tsx
function MemberCard({ member }: { member: Member }) {
  return (
    <article className="card">
      <img src={member.avatarUrl} alt="" className="card-avatar" />
      <h3 className="card-title">{member.name}</h3>
      <p className="card-tagline">{member.bio}</p>   // drift: tagline vs bio
      <Link to={`/members/${member.id}`}>View member</Link>
    </article>
  )
}
```

**Correct (Option 1: one component, two callers, discriminated prop):**

```typescript
// src/lib/PersonCard.tsx
type PersonCardProps = {
  person: { id: string; name: string; avatarUrl: string; tagline: string }
  kind: 'user' | 'member'
}

function PersonCard({ person, kind }: PersonCardProps) {
  return (
    <article className="card">
      <img src={person.avatarUrl} alt="" className="card-avatar" />
      <h3 className="card-title">{person.name}</h3>
      <p className="card-tagline">{person.tagline}</p>
      <Link to={`/${kind}s/${person.id}`}>View {kind}</Link>
    </article>
  )
}
```

**Correct (Option 2: composition, no `kind` prop at all):**

```typescript
// src/lib/Card.tsx
function Card({ avatarUrl, name, tagline, action }: {
  avatarUrl: string; name: string; tagline: string; action: ReactNode
}) {
  return (
    <article className="card">
      <img src={avatarUrl} alt="" className="card-avatar" />
      <h3 className="card-title">{name}</h3>
      <p className="card-tagline">{tagline}</p>
      {action}
    </article>
  )
}

// callers
<Card {...user} action={<Link to={`/users/${user.id}`}>View user</Link>} />
<Card {...member} tagline={member.bio} action={<Link to={`/members/${member.id}`}>View member</Link>} />
```

Option 2 is preferred when the variant axis isn't a clean enum — when call sites need to vary multiple things, composition beats prop explosion (see [`rcomp-composition.md`](rcomp-composition.md)).

### When NOT to consolidate

- The two components are in different bounded contexts (e.g. one in `admin/`, one in `public/`) and are likely to diverge — premature consolidation will be undone in 3 months.
- The shared shape is so small (< 5 lines of JSX) that the abstraction costs more than the duplication.
- Consolidating would force a discriminated prop with > 3 enum members — the abstraction is fighting the data.

### Risk before consolidating

- If either component is exported from a package or shared with another team, the consolidation is an API change.
- Test coverage on each call site before merging — divergent test expectations often encode different requirements you didn't see in the JSX.

Reference: [Thinking in React — Step 2: Identify the components](https://react.dev/learn/thinking-in-react)
