---
title: Fetch Data on the Server by Default
impact: MEDIUM
impactDescription: eliminates client loading spinners, reduces client JS bundle by 30-60%
tags: data, server-components, data-fetching, performance
---

## Fetch Data on the Server by Default

Client-side fetching with useEffect creates a waterfall: download JS, parse, render shell, fetch data, render content. The user sees a loading spinner for every request. Server components fetch data before HTML reaches the browser, eliminating the waterfall and removing fetch logic from the client bundle entirely.

**Incorrect (client-side fetch — waterfall and spinner):**

```tsx
"use client";

import { useState, useEffect } from "react";

export function ProjectList() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Fetch starts AFTER component mounts in the browser
  useEffect(() => {
    fetch("/api/projects")
      .then((res) => res.json())
      .then(setProjects)
      .catch((err) => setError(err.message))
      .finally(() => setIsLoading(false));
  }, []);

  if (isLoading) return <Skeleton count={5} />;
  if (error) return <ErrorMessage message={error} />;

  return (
    <ul>
      {projects.map((project) => (
        <li key={project.id}>{project.name} — {project.status}</li>
      ))}
    </ul>
  );
}
```

**Correct (server component — data arrives with HTML):**

```tsx
// Server component — no "use client", no useState, no useEffect
import { db } from "@/lib/db";

export async function ProjectList() {
  const projects = await db.project.findMany({
    orderBy: { updatedAt: "desc" },
  });

  return (
    <ul>
      {projects.map((project) => (
        <li key={project.id}>{project.name} — {project.status}</li>
      ))}
    </ul>
  );
}

// Layout wraps with Suspense for streaming
import { Suspense } from "react";

export default function DashboardPage() {
  return (
    <Suspense fallback={<Skeleton count={5} />}>
      <ProjectList />
    </Suspense>
  );
}
// Zero client JS for ProjectList — data fetched on the server, streamed as HTML
```

Reference: [React Docs - Server Components](https://react.dev/reference/rsc/server-components)
