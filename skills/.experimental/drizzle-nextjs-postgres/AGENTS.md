# Drizzle ORM + PostgreSQL + Next.js App Router

**Version 0.1.0**  
dot-skills  
July 2026

---

## Abstract

Library-reference skill for Drizzle ORM against PostgreSQL inside the Next.js App Router. 36 rules across 7 categories, covering only the decisions where the Postgres dialect or the Next.js runtime changes the correct answer: client construction and driver capability, reads under Next.js 16 Cache Components, Server Action mutations and cache invalidation, Postgres column semantics, drizzle-kit migration safety, transactions against a connection pool, and Postgres query traps. Pinned to drizzle-orm 0.45.2, drizzle-kit 0.31.10, and Next.js 16.2.11; API claims were verified against the unpacked package tarballs.

---

## Table of Contents

1. [Client Construction & Driver Choice](references/_sections.md#1-client-construction-&-driver-choice)
   - 1.1 [Cache the pool on globalThis so HMR does not leak connections](references/conn-singleton-across-hmr.md)
   - 1.2 [Choose the driver by whether you need to branch on an intermediate result](references/conn-driver-choice-follows-transactions.md)
   - 1.3 [Mark the db module server-only and keep schema imports separate](references/conn-server-only-db-module.md)
   - 1.4 [Pass schema to drizzle() or db.query is empty](references/conn-pass-schema-for-relational-queries.md)
   - 1.5 [Set prepare false when postgres-js runs behind a transaction-mode pooler](references/conn-disable-prepare-behind-transaction-pooler.md)
   - 1.6 [Size the pool for instance count, not for request count](references/conn-pool-sizing-for-serverless.md)
2. [Reads in Server Components](references/_sections.md#2-reads-in-server-components)
   - 2.1 [Cache queries with use cache, not unstable_cache or route segment config](references/rsc-use-cache-replaces-unstable-cache.md)
   - 2.2 [Do not move routes to the edge runtime to satisfy a driver](references/rsc-node-runtime-not-edge.md)
   - 2.3 [Do not treat use cache as durable query caching on serverless](references/rsc-use-cache-is-per-instance-memory.md)
   - 2.4 [Push uncached queries below a Suspense boundary](references/rsc-suspense-around-uncached-reads.md)
   - 2.5 [Take the tenant id as an argument instead of reading cookies inside use cache](references/rsc-no-request-apis-inside-use-cache.md)
   - 2.6 [Wrap per-request lookups in React cache to dedupe across the tree](references/rsc-dedupe-with-react-cache.md)
3. [Server Actions & Mutations](references/_sections.md#3-server-actions-&-mutations)
   - 3.1 [Authorize and validate inside the Server Action, not at the call site](references/mut-authorize-inside-the-action.md)
   - 3.2 [Defer audit and analytics writes with after()](references/mut-after-for-post-response-writes.md)
   - 3.3 [Use updateTag after a mutation the user must see immediately](references/mut-updatetag-vs-revalidatetag.md)
4. [Postgres Schema Definition](references/_sections.md#4-postgres-schema-definition)
   - 4.1 [Declare timestamps with withTimezone](references/schema-timestamptz-not-timestamp.md)
   - 4.2 [Pick the bigint mode that matches the range you actually store](references/schema-bigint-mode-truncation.md)
   - 4.3 [Return an array from the third pgTable argument](references/schema-table-extras-are-an-array.md)
   - 4.4 [Store money as integer cents, and expect numeric to infer as string](references/schema-numeric-is-a-string.md)
   - 4.5 [Treat pgEnum as append-only, and never backfill with a new value in the same migration](references/schema-enum-values-are-append-only.md)
   - 4.6 [Use identity columns instead of serial](references/schema-identity-not-serial.md)
   - 4.7 [Use jsonb and narrow it with $type](references/schema-jsonb-with-dollar-type.md)
   - 4.8 [Use text unless a length limit is a real business rule](references/schema-text-not-varchar-length.md)
5. [Migrations & Schema Change Safety](references/_sections.md#5-migrations-&-schema-change-safety)
   - 5.1 [Add constraints NOT VALID, then validate in a second step](references/migrate-add-constraints-not-valid-then-validate.md)
   - 5.2 [Apply concurrent index builds outside the migrator](references/migrate-concurrent-index-outside-transaction.md)
   - 5.3 [Generate and review migration files; keep push for local prototyping](references/migrate-generate-not-push.md)
   - 5.4 [Pick "rename column" at the prompt; "create column" silently drops the data](references/migrate-map-renames-explicitly.md)
   - 5.5 [Run migrations as a deploy step, not from application code](references/migrate-run-in-deploy-step-not-at-runtime.md)
6. [Transactions & Pooled Connections](references/_sections.md#6-transactions-&-pooled-connections)
   - 6.1 [Keep network calls and cache invalidation out of the transaction body](references/tx-no-external-io-inside.md)
   - 6.2 [Lock the row with .for('update') when a write depends on what you read](references/tx-lock-rows-for-read-modify-write.md)
   - 6.3 [Retry serializable transactions on SQLSTATE 40001](references/tx-retry-serialization-failures.md)
7. [Postgres Query Building](references/_sections.md#7-postgres-query-building)
   - 7.1 [Name prepared statements, and skip them behind a transaction pooler](references/query-prepared-statements-need-names.md)
   - 7.2 [Paginate by cursor, not by OFFSET](references/query-keyset-not-offset.md)
   - 7.3 [Read db.execute() results by the driver's shape, not a fixed one](references/query-execute-shape-is-driver-dependent.md)
   - 7.4 [Treat a row count as a query with a cost, not free metadata](references/query-count-scans-the-table.md)
   - 7.5 [Use notExists instead of NOT IN over a nullable subquery](references/query-not-in-null-trap.md)

---

## References

1. [https://orm.drizzle.team/docs/get-started/postgresql-new](https://orm.drizzle.team/docs/get-started/postgresql-new)
2. [https://orm.drizzle.team/docs/column-types/pg](https://orm.drizzle.team/docs/column-types/pg)
3. [https://orm.drizzle.team/docs/indexes-constraints](https://orm.drizzle.team/docs/indexes-constraints)
4. [https://orm.drizzle.team/docs/rqb](https://orm.drizzle.team/docs/rqb)
5. [https://orm.drizzle.team/docs/relations](https://orm.drizzle.team/docs/relations)
6. [https://orm.drizzle.team/docs/transactions](https://orm.drizzle.team/docs/transactions)
7. [https://orm.drizzle.team/docs/select](https://orm.drizzle.team/docs/select)
8. [https://orm.drizzle.team/docs/perf-queries](https://orm.drizzle.team/docs/perf-queries)
9. [https://orm.drizzle.team/docs/zod](https://orm.drizzle.team/docs/zod)
10. [https://orm.drizzle.team/docs/migrations](https://orm.drizzle.team/docs/migrations)
11. [https://orm.drizzle.team/docs/drizzle-kit-generate](https://orm.drizzle.team/docs/drizzle-kit-generate)
12. [https://orm.drizzle.team/docs/drizzle-kit-migrate](https://orm.drizzle.team/docs/drizzle-kit-migrate)
13. [https://orm.drizzle.team/docs/drizzle-kit-push](https://orm.drizzle.team/docs/drizzle-kit-push)
14. [https://orm.drizzle.team/docs/connect-neon](https://orm.drizzle.team/docs/connect-neon)
15. [https://orm.drizzle.team/docs/connect-supabase](https://orm.drizzle.team/docs/connect-supabase)
16. [https://nextjs.org/docs/app/api-reference/directives/use-cache](https://nextjs.org/docs/app/api-reference/directives/use-cache)
17. [https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheComponents](https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheComponents)
18. [https://nextjs.org/docs/app/guides/migrating-to-cache-components](https://nextjs.org/docs/app/guides/migrating-to-cache-components)
19. [https://nextjs.org/docs/app/api-reference/functions/updateTag](https://nextjs.org/docs/app/api-reference/functions/updateTag)
20. [https://nextjs.org/docs/app/api-reference/functions/revalidateTag](https://nextjs.org/docs/app/api-reference/functions/revalidateTag)
21. [https://nextjs.org/docs/app/api-reference/functions/after](https://nextjs.org/docs/app/api-reference/functions/after)
22. [https://nextjs.org/docs/app/getting-started/server-and-client-components](https://nextjs.org/docs/app/getting-started/server-and-client-components)
23. [https://nextjs.org/blog/security-nextjs-server-components-actions](https://nextjs.org/blog/security-nextjs-server-components-actions)
24. [https://react.dev/reference/react/cache](https://react.dev/reference/react/cache)
25. [https://www.postgresql.org/docs/current/sql-altertable.html](https://www.postgresql.org/docs/current/sql-altertable.html)
26. [https://www.postgresql.org/docs/current/sql-altertype.html](https://www.postgresql.org/docs/current/sql-altertype.html)
27. [https://www.postgresql.org/docs/current/sql-createindex.html](https://www.postgresql.org/docs/current/sql-createindex.html)
28. [https://www.postgresql.org/docs/current/sql-prepare.html](https://www.postgresql.org/docs/current/sql-prepare.html)
29. [https://www.postgresql.org/docs/current/explicit-locking.html](https://www.postgresql.org/docs/current/explicit-locking.html)
30. [https://www.postgresql.org/docs/current/transaction-iso.html](https://www.postgresql.org/docs/current/transaction-iso.html)
31. [https://www.postgresql.org/docs/current/errcodes-appendix.html](https://www.postgresql.org/docs/current/errcodes-appendix.html)
32. [https://www.postgresql.org/docs/current/datatype-json.html](https://www.postgresql.org/docs/current/datatype-json.html)
33. [https://www.postgresql.org/docs/current/datatype-numeric.html](https://www.postgresql.org/docs/current/datatype-numeric.html)
34. [https://www.postgresql.org/docs/current/datatype-character.html](https://www.postgresql.org/docs/current/datatype-character.html)
35. [https://www.postgresql.org/docs/current/row-estimation-examples.html](https://www.postgresql.org/docs/current/row-estimation-examples.html)
36. [https://www.postgresql.org/docs/current/queries-limit.html](https://www.postgresql.org/docs/current/queries-limit.html)
37. [https://www.postgresql.org/docs/current/functions-subquery.html](https://www.postgresql.org/docs/current/functions-subquery.html)
38. [https://wiki.postgresql.org/wiki/Don%27t_Do_This](https://wiki.postgresql.org/wiki/Don%27t_Do_This)
39. [https://vercel.com/guides/connection-pooling-with-functions](https://vercel.com/guides/connection-pooling-with-functions)
40. [https://node-postgres.com/features/pooling](https://node-postgres.com/features/pooling)
41. [https://www.pgbouncer.org/features.html](https://www.pgbouncer.org/features.html)
42. [https://use-the-index-luke.com/no-offset](https://use-the-index-luke.com/no-offset)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |