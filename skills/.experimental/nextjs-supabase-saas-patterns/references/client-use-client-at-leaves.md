---
title: Mark `'use client'` at Leaf Components, Not Page Roots
impact: HIGH
impactDescription: saves 50-200KB per misplaced boundary
tags: client, use-client, react-server-components, bundle
---

## Mark `'use client'` at Leaf Components, Not Page Roots

`'use client'` is a boundary marker — the file with the directive, and every component imported by it, ships to the browser and runs client-side. Putting it at the page or layout level forces the entire subtree (including the server-only data fetching) into the bundle and hydrates components that never needed JavaScript. The pattern: server components own structure and data; only the leaf components that actually need state, effects, or event handlers get `'use client'`.

**Incorrect (`'use client'` at the page level — whole tree bundled):**

```tsx
// app/[locale]/home/(user)/projects/page.tsx
'use client';

import { useState } from 'react';
import { useSupabase } from '@kit/supabase/hooks/use-supabase';
import { useQuery } from '@tanstack/react-query';
import { ProjectFilter } from './_components/project-filter';
import { ProjectCard } from './_components/project-card';
import { PageHeader } from './_components/page-header';   // Static, but now in client bundle.
import { EmptyState } from './_components/empty-state';   // Static, but now in client bundle.

export default function ProjectsPage() {
  const client = useSupabase();
  const { data: projects } = useQuery({
    queryKey: ['projects'],
    queryFn: () => client.from('projects').select('*').then(r => r.data),
  });
  const [filter, setFilter] = useState('');

  return (
    <>
      <PageHeader title="Projects" />
      <ProjectFilter value={filter} onChange={setFilter} />
      {!projects?.length ? <EmptyState /> : projects.map((p) => <ProjectCard key={p.id} project={p} />)}
    </>
  );
}
// Bundle includes: ProjectsPage, ProjectFilter, ProjectCard, PageHeader, EmptyState,
// useSupabase, useQuery, the entire Supabase client SDK — all shipped to the user.
```

**Correct (server page composes; only the interactive piece is client):**

```tsx
// app/[locale]/home/(user)/projects/page.tsx
// No 'use client' — this is a server component.

import { getSupabaseServerClient } from '@kit/supabase/server-client';
import { PageHeader } from './_components/page-header';
import { EmptyState } from './_components/empty-state';
import { ProjectList } from './_components/project-list';   // The one client island.

export default async function ProjectsPage() {
  const client = getSupabaseServerClient();
  const { data: projects } = await client.from('projects').select('*');

  return (
    <>
      <PageHeader title="Projects" />
      {!projects?.length ? <EmptyState /> : <ProjectList initialProjects={projects} />}
    </>
  );
}
```

```tsx
// app/[locale]/home/(user)/projects/_components/project-list.tsx
'use client';
// ONLY this file (and what it imports) ends up in the client bundle.

import { useState } from 'react';
import { ProjectFilter } from './project-filter';
import { ProjectCard } from './project-card';

export function ProjectList({ initialProjects }: { initialProjects: Project[] }) {
  const [filter, setFilter] = useState('');
  const filtered = initialProjects.filter((p) => p.name.toLowerCase().includes(filter.toLowerCase()));
  return (
    <>
      <ProjectFilter value={filter} onChange={setFilter} />
      {filtered.map((p) => <ProjectCard key={p.id} project={p} />)}
    </>
  );
}
```

**The rule of thumb:** if a component uses `useState`, `useEffect`, an event handler (`onClick`, `onChange`), or a React Query hook, it's a client component. If it just renders props/children, it's a server component. Push `'use client'` as deep as possible.

**`PageHeader`, `EmptyState`, layouts, decorative wrappers** — none of these need `'use client'`. Even if they're imported *by* a client component, they remain server components unless they have the directive themselves OR are imported into a client file. The boundary is per-file.

**Client components can render server components as children** (via props/children), so server data can pass through a client wrapper:

```tsx
// app/[locale]/home/(user)/page.tsx (server)
<DismissableBanner>             {/* client component for the dismiss interaction */}
  <ServerRenderedContent />      {/* still server-rendered, passed as children */}
</DismissableBanner>
```

**Don't fight this with `dynamic({ ssr: false })`.** That's a different escape hatch (skipping SSR for a specific component, e.g., for browser-only APIs). It doesn't replace correct `'use client'` placement.

Reference: [React `'use client'` directive](https://react.dev/reference/rsc/use-client)
