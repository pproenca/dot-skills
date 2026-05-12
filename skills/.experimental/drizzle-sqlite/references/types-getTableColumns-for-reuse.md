---
title: Use getTableColumns to share projections without duplicating
impact: MEDIUM
impactDescription: prevents projection/schema drift across endpoints
tags: types, projection, getTableColumns, dry
---

## Use getTableColumns to share projections without duplicating

A handful of endpoints all return "user without password_hash": each spells out `{ id: users.id, email: users.email, name: users.name, ...etc }`. Add a column and all of them silently miss it; remove a column and you get runtime errors at the callsite that still listed it. `getTableColumns(table)` returns the table's column object spread, which you can extend or omit fields from. Define the projection once and reuse it.

**Incorrect (projection duplicated across endpoints — drift):**

```typescript
// app/api/me/route.ts
export async function GET() {
  const [me] = await db
    .select({ id: users.id, email: users.email, name: users.name, avatarUrl: users.avatarUrl })
    .from(users).where(eq(users.id, currentUserId));
  return Response.json(me);
}

// app/api/admin/users/route.ts
export async function GET() {
  return Response.json(
    await db
      .select({ id: users.id, email: users.email, name: users.name }) // forgot avatarUrl
      .from(users),
  );
}
```

**Correct (shared projection — change once, propagate everywhere):**

```typescript
// src/db/projections.ts
import { getTableColumns } from 'drizzle-orm';
import { users } from './schema';

// Everything except sensitive columns:
export const publicUserCols = (() => {
  const { passwordHash, emailVerificationToken, ...rest } = getTableColumns(users);
  return rest;
})();
```

```typescript
// app/api/me/route.ts
import { publicUserCols } from '@/db/projections';

export async function GET() {
  const [me] = await db.select(publicUserCols).from(users).where(eq(users.id, currentUserId));
  return Response.json(me);
}
```

```typescript
// app/api/admin/users/route.ts
import { publicUserCols } from '@/db/projections';

export async function GET() {
  return Response.json(await db.select(publicUserCols).from(users));
}
```

**Joining: shared projection + spread on each side:**

```typescript
import { getTableColumns, eq } from 'drizzle-orm';

const postWithAuthor = await db
  .select({
    ...getTableColumns(posts),
    author: publicUserCols, // nested projection
  })
  .from(posts)
  .innerJoin(users, eq(users.id, posts.authorId));
// Result: each row is { id, title, ..., author: { id, email, name, avatarUrl } }
```

**For relational queries, the equivalent is `columns:` with `false` to exclude:**

```typescript
const me = await db.query.users.findFirst({
  where: (u, { eq }) => eq(u.id, currentUserId),
  columns: {
    passwordHash: false,
    emailVerificationToken: false,
  },
});
```

Reference: [Drizzle — getTableColumns helper](https://orm.drizzle.team/docs/goodies#get-table-information)
