---
title: Delete unreachable routes, unused Server Actions, and orphan components/utilities
impact: MEDIUM-HIGH
impactDescription: removes bundle weight, reduces audit surface, prevents accidental copy-from-zombie, and most importantly removes routes that respond to public traffic but no longer serve a purpose
tags: cross, dead-code, unused-routes, unused-actions, deletion
---

## Delete unreachable routes, unused Server Actions, and orphan components/utilities

**This is a cross-cutting rule.** It cannot be seen from a single file — a `page.tsx` looks "valid" even if no internal link points to it and no marketing campaign drives traffic to it.

### Shapes to recognize

- Routes (`app/**/page.tsx`) that nothing links to (no `<Link href>`, no `redirect()`, no `router.push()`), absent from sitemap, with no traffic in analytics.
- `route.ts` handlers exporting `GET`/`POST` that no client code calls — a public API surface left over from a deprecated feature.
- Server Actions exported but not bound to any `<form action>` or `formAction` prop.
- `loading.tsx` / `error.tsx` / `not-found.tsx` co-located with deleted page files.
- Custom hooks/utilities in `lib/` or `hooks/` with zero importers (after route auto-discovery is accounted for).
- "Legacy" / "Old" / "V1" / "Deprecated" prefixed exports kept "in case we need them."
- Components imported only by *other dead components* (transitive dead code), or by tests for a route that no longer ships.

### Detection procedure

1. Build an import graph of the inventory: every `import` statement, every `export` declaration.
2. Start from the roots — every `page.tsx` / `layout.tsx` / `route.ts` that is reachable from a published URL (cross-reference with sitemap, analytics, marketing pages).
3. Mark everything reachable from a live root as live.
4. Also check `<Link href>` patterns and route navigation calls — a route reachable only via `Link` and never imported is still live.
5. Everything unmarked is dead. Order the dead set by file size (large modules first).
6. **Re-check three false-positive sources before deleting:**
   - **Dynamic route lookup** — `<Link href={path}>` where `path` is constructed at runtime (template literals, computed strings).
   - **External traffic** — even unlinked routes may have inbound links from email campaigns, bookmarks, or referral domains. Check analytics for 30 days of traffic before deleting public routes.
   - **API consumers** — `route.ts` handlers may be called by mobile apps, third-party integrations, or webhooks that aren't in the repo.

### Multi-file example

**Incorrect (inventory finding — these files exist, nothing reachable from a live route imports them):**

```text
app/(deprecated)/old-dashboard/page.tsx       — 0 traffic in last 90 days, 0 incoming Links
app/(deprecated)/old-dashboard/loading.tsx    — orphan partner of above
app/api/legacy-export/route.ts                — 0 calls in last 90 days
app/admin/v1/page.tsx                         — superseded by app/admin/page.tsx, not linked anywhere
lib/legacy/auth.ts                            — 0 importers
hooks/useDeprecatedSession.ts                 — 0 importers
actions/oldCreateUser.ts                      — exports server action, never bound to a form
```

**Correct (after deletion):**

```text
app/(deprecated)/                             — deleted (entire directory: page, loading, error, layout)
app/api/legacy-export/route.ts                — deleted (after verifying no external traffic for 90 days)
app/admin/v1/page.tsx                         — deleted
lib/legacy/                                   — deleted (entire directory)
hooks/useDeprecatedSession.ts                 — deleted
actions/oldCreateUser.ts                      — deleted
```

### Reporting shape (what the audit emits)

| File | Type | Last traffic | Importers | Action | Risk |
|---|---|---|---|---|---|
| `app/(deprecated)/old-dashboard/page.tsx` | route | 0 (90d) | 0 inbound | delete | check analytics retention |
| `app/api/legacy-export/route.ts` | API | 0 (90d) | 0 internal | delete | check external integrations |
| `lib/legacy/auth.ts` | util | n/a | 0 | delete | none |
| `hooks/useDeprecatedSession.ts` | hook | n/a | 0 | delete | check Storybook |
| `actions/oldCreateUser.ts` | server action | n/a | 0 forms | delete | none |

### When NOT to delete

- The route is referenced by a `<Link href={path}>` whose path is computed at runtime — verify by running the code path or grep the templates.
- The API handler is called by external systems (mobile apps, webhooks, third-party integrations) not in the repo — verify with analytics.
- A route is dormant but tied to a documented contract (legal, compliance, audit retention).
- The file is feature-flagged off but scheduled for re-enable — leave it but file a TODO with the flag name and the expected re-enable date.

### Risk before deleting

- Sitemap and `robots.ts` may reference deleted routes. Re-run a sitemap build after deletion.
- 404 errors are a *symptom* of dead-code deletion done without redirects — add `redirect()` calls in `proxy.ts` for routes that had real traffic.
- Run the full test suite *after* deletion, not before — broken imports from dead files will surface.

Reference: [Routing Fundamentals](https://nextjs.org/docs/app/building-your-application/routing), [proxy.ts redirects](https://nextjs.org/docs/app/building-your-application/routing/redirecting)
