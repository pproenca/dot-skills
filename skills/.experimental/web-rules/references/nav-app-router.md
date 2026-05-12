---
title: Use App Router Layouts, Route Groups, and `<Link>` for All Internal Navigation
impact: CRITICAL
impactDescription: Skipping `<Link>` disables prefetching and adds 200-800 ms to subsequent navigations; nesting client components above the route boundary forfeits Server Component streaming
tags: nav, app-router, next-link, layouts, route-groups, parallel-routes
---

## Use App Router Layouts, Route Groups, and `<Link>` for All Internal Navigation

In Next.js 16 every navigation between internal pages goes through `<Link>` from `next/link`. Layouts (`layout.tsx`) hold shared chrome (header, sidebar, footer) and re-render only when their segment changes. Nested layouts compose; do not duplicate chrome across routes. Use parallel routes (`@slot`) for independent panels (modal + page, list + detail) and intercepting routes (`(..)slug`) for "open as modal" patterns.

**Incorrect (raw `<a>`, duplicated chrome, `useRouter().push` for visible links):**

```tsx
// app/projects/page.tsx — duplicates the header on every page
export default function Projects() {
  const router = useRouter()
  return (
    <>
      <Header />
      <a href="/projects/new">New project</a>
      <button onClick={() => router.push('/projects/123')}>Open project</button>
    </>
  )
}
```

**Correct (layout owns chrome, `<Link>` for all visible navigation):**

```tsx
// app/projects/layout.tsx
export default function ProjectsLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="grid grid-cols-[16rem_1fr] h-dvh">
      <ProjectsSidebar />
      <main className="overflow-auto">{children}</main>
    </div>
  )
}

// app/projects/page.tsx
import Link from 'next/link'

export default async function Projects() {
  const projects = await getProjects() // Server Component — data fetched on server
  return (
    <>
      <header className="flex justify-between items-center p-6">
        <h1 className="text-xl font-semibold">Projects</h1>
        <Link
          href="/projects/new"
          className="rounded-md bg-primary px-3 py-1.5 text-sm text-primary-foreground"
        >
          New project
        </Link>
      </header>
      <ul>
        {projects.map((p) => (
          <li key={p.id}>
            <Link href={`/projects/${p.id}`}>{p.name}</Link>
          </li>
        ))}
      </ul>
    </>
  )
}
```

**Rule:**
- Always import `Link` from `next/link` for internal hrefs; reserve `<a>` for external links (and add `rel="noopener noreferrer"` with `target="_blank"`)
- Never call `router.push()` for navigation a user would otherwise click — keep `useRouter` for programmatic flows (post-action redirects, auth)
- Shared chrome lives in `layout.tsx` at the deepest segment it applies to
- Use parallel routes for independent loading states (e.g., `@modal` + page)
- Use `loading.tsx` and `error.tsx` at every route segment that fetches data

Reference: [App Router · Next.js 16](https://nextjs.org/docs/app/building-your-application/routing)
