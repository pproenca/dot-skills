---
title: Fetch Initial Data in Server Components, Not on the Client
impact: HIGH
impactDescription: 100-500ms saved per page load (removes a hydration round-trip)
tags: server, client, ssr, react-query, initial-data
---

## Fetch Initial Data in Server Components, Not on the Client

A page that fetches its initial data on the client sends an empty shell to the browser, waits for hydration, then opens a round-trip from the user's network. The same page fetching server-side delivers fully-rendered HTML on the first response and saves a round-trip — the query happens server-side, where latency to your database is millisecond-level instead of crossing the user's wifi twice. Use client fetching for *subsequent* data (after the user interacts), not the page's first paint. This holds for any backend; the example reads through Supabase.

**Incorrect (`'use client'` page that fetches on mount):**

```tsx
// app/[locale]/home/(user)/projects/page.tsx
'use client';

import { useSupabase } from '@app/supabase/client';
import { useQuery } from '@tanstack/react-query';

export default function ProjectsPage() {
  const client = useSupabase();
  const { data: projects } = useQuery({
    queryKey: ['projects'],
    queryFn: () => client.from('projects').select('*').then((r) => r.data),
  });
  // Browser receives empty <div>, hydrates, THEN fetches.
  // User sees a loading spinner before the list appears.

  if (!projects) return <Spinner />;
  return <ProjectList projects={projects} />;
}
```

**Correct (server component fetches, passes data as props):**

```tsx
// app/[locale]/home/(user)/projects/page.tsx
// No 'use client' — this is a server component by default.

import { getServerClient } from '@app/supabase/server';
import { ProjectList } from './_components/project-list';

export default async function ProjectsPage() {
  const client = getServerClient();
  const { data: projects } = await client.from('projects').select('*');

  // Server returns HTML with the list already populated.
  // No spinner. No second round-trip.
  return <ProjectList projects={projects ?? []} />;
}
```

```tsx
// app/[locale]/home/(user)/projects/_components/project-list.tsx
'use client';
// Client component only because it needs onClick handlers and local state.
// It received the data as props — no fetching here.

export function ProjectList({ projects }: { projects: Project[] }) {
  const [filter, setFilter] = useState('');
  const filtered = projects.filter((project) => project.name.includes(filter));
  return (/* ... */);
}
```

**When client fetching IS the right answer:**

- **Real-time:** live subscriptions (e.g. Supabase `postgres_changes` channels, WebSockets) belong on the client.
- **Polling / refetch-on-focus:** server fetches are one-shot per render; React Query handles "refetch when the tab regains focus."
- **User-driven filters/pagination that aren't in the URL:** if the filter state lives in `useState`, the data lives client-side too. (URL-driven filters can stay server-side via search params.)
- **Cross-cutting cached lookups:** workspace data already loaded by the layout — re-fetching on the client wastes both.

**Hydrating React Query with server-fetched initial data (best of both):**

```tsx
// Server component fetches → client component starts with initial data,
// then can refetch / subscribe / mutate.
export default async function ProjectsPage() {
  const client = getServerClient();
  const { data: projects } = await client.from('projects').select('*');

  return <ProjectListWithRealtime initialProjects={projects ?? []} />;
}

// In the client component:
const { data } = useQuery({
  queryKey: ['projects'],
  queryFn: fetchProjects,
  initialData: initialProjects,        // No loading spinner on first paint.
  refetchOnWindowFocus: false,
});
```

**Why this isn't "server components are always faster":** the database round-trip costs the same. The difference is where the *additional* hop happens — server → browser (one hop) vs. server → browser → user-network → server (three hops for the same data). Server-side rendering pays once; client-side fetching pays twice.

**Don't use server actions for reads.** Server actions are for mutations. Reading data via a server action means a `fetch('POST', /-/action)` round-trip from the client — worse than React Query.

Reference: [Next.js data fetching and caching](https://nextjs.org/docs/app/getting-started/fetching-data)
