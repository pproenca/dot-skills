---
title: Converge on canonical names when the same concept wears different prop/param names across routes and components
impact: MEDIUM-HIGH
impactDescription: eases composition and route navigation, removes one-line adapter wrappers, reduces cognitive overhead during code reads
tags: cross, naming, prop-drift, params-drift, conventions
---

## Converge on canonical names when the same concept wears different prop/param names across routes and components

**This is a cross-cutting rule.** A single component's prop names always look reasonable — drift is only visible when you compare components, route segments, and search params side-by-side.

### Shapes to recognize

- Same conceptual entity carried under different prop names: `user` / `member` / `account` / `profile`, when the underlying type is the same.
- Dynamic route segments using different names for the same concept: `app/users/[id]/`, `app/members/[memberId]/`, `app/accounts/[accountSlug]/` — three names for the same routing concern.
- Search params for the same filter under different names across pages: `?q=`, `?query=`, `?search=` for full-text search; `?page=` vs `?p=` for pagination.
- Same event under different handler names: `onChange` / `onUpdate` / `onSelect` / `onValueChange` for what is conceptually "the value changed."
- API route handlers under inconsistent paths: `/api/users/`, `/api/v1/members/`, `/api/account-data/` for the same kind of resource.
- Server Action arguments named inconsistently — one action takes `userId: string`, another takes `id: string` for the same entity.

### Detection procedure

1. Build a name-frequency table across the inventory. Three dimensions:
   - **Component props** — group by type signature (all `User`-typed, all `(v: T) => void` handlers).
   - **Route params** — list every `[param]` segment across the route tree.
   - **Search params** — grep for `searchParams.get(`/`useSearchParams().get(` calls; cluster by what they read.
2. For each group with > 1 name, ask: *is the difference meaningful (domain concept) or accidental (whoever wrote this picked a name)?*
3. Concept-meaningful drift is fine. Accidental drift is the finding.

### Multi-file example

**Incorrect (five surfaces, same concept, five names):**

```typescript
// app/users/[id]/page.tsx
export default async function UserRoute({ params }: { params: { id: string } }) { /* ... */ }

// app/members/[memberId]/page.tsx
export default async function MemberRoute({ params }: { params: { memberId: string } }) { /* ... */ }

// app/teams/[teamSlug]/members/[m]/page.tsx
export default async function NestedMember({ params }: { params: { teamSlug: string; m: string } }) { /* ... */ }

// actions/profile.ts
export async function updateUser(userId: string, data: User) { /* ... */ }
export async function updateMember(id: string, data: User) { /* same User type, different param name */ }

// app/search/page.tsx — three search-param names across three pages
const q = searchParams.get('q')           // app/search
const query = searchParams.get('query')   // app/users
const search = searchParams.get('search') // app/admin/users
```

Every link, every navigation, every action call site has to remember "which name does THIS surface want?"

**Correct (one canonical name per concept, no adapters):**

```typescript
// All "person being viewed" route segments use [id]
// app/users/[id]/page.tsx
// app/members/[id]/page.tsx
// app/teams/[teamId]/members/[id]/page.tsx — teamId only when nesting is ambiguous

// actions/profile.ts — all "edit this person" actions take userId
export async function updateUser(userId: string, data: User) { /* ... */ }
export async function updateMember(userId: string, data: User) { /* ... */ }

// All search params use canonical names
const q = searchParams.get('q')  // q for full-text search across all pages
const page = searchParams.get('page')  // page for pagination
```

### Cross-file observation shape (what the audit emits)

| Concept | Type | Names found | Suggested canonical | Files |
|---|---|---|---|---|
| profile entity ID (route segment) | `string` | `[id]`, `[memberId]`, `[m]`, `[accountSlug]` | `[id]` | 6 route files |
| profile entity ID (action arg) | `string` | `userId`, `id`, `accountId` | `userId` | 4 action files |
| full-text search query | `string` | `q`, `query`, `search`, `term` | `q` | 5 pages |
| pagination cursor | `string \| number` | `page`, `p`, `cursor`, `offset` | `page` | 7 pages |
| value-changed event (forms) | `(v: T) => void` | `onChange`, `onUpdate`, `onValueChange` | `onChange` | 12 components |

### When NOT to converge

- The concepts genuinely differ (`user` vs `currentUser` vs `targetUser`).
- Drift is at a third-party boundary (e.g. wrapping a library that names its callback `onValueChange`).
- A rename would break SEO-relevant URLs (`?q=` to `?query=` invalidates every backlink).

### Risk before renaming

- **Search param renames break inbound links.** If the old name is anywhere in marketing/email/external sites, add a redirect rule in `proxy.ts` mapping the old key to the canonical one for a transition period.
- **Route segment renames break URLs.** Add `redirects: () => [{ source: ..., destination: ..., permanent: true }]` in `next.config.js` for changed paths.
- Action parameter renames are internal — safe, but every call site must be updated in the same commit.

Reference: [Dynamic Routes](https://nextjs.org/docs/app/building-your-application/routing/dynamic-routes), [Redirects](https://nextjs.org/docs/app/api-reference/config/next-config-js/redirects)
