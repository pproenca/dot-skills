---
title: Extract Custom Hooks for Reusable Stateful Logic
impact: CRITICAL
impactDescription: makes stateful behavior reusable without HOCs, render props, or context gymnastics
tags: func, hook, reuse, custom-hook
---

## Extract Custom Hooks for Reusable Stateful Logic

When two components share the same `useState` + `useEffect` dance, the dance itself is the abstraction. Custom hooks are React's first-class mechanism for behavior reuse — they replaced HOCs and render props as the idiomatic answer, and in React 19 they are even more central with the React Compiler and `use()`. Extracting a hook keeps rendering in each component while the stateful machinery lives in one place.

**Incorrect (two components duplicating the same fetch-and-track pattern):**

```tsx
// ProjectDashboard and WorkspaceMembers both implement the same fetch/loading/error logic.
function ProjectDashboard({ projectId }: { projectId: string }) {
  const [project, setProject] = useState<Project | null>(null);
  const [error, setError] = useState<Error | null>(null);
  useEffect(() => {
    let cancelled = false;
    fetch(`/api/projects/${projectId}`)
      .then((r) => r.json())
      .then((data) => { if (!cancelled) setProject(data); })
      .catch((e) => { if (!cancelled) setError(e); });
    return () => { cancelled = true; };
  }, [projectId]);
  if (error) return <ErrorBanner error={error} />;
  if (!project) return <Skeleton />;
  return <ProjectView project={project} />;
}

function WorkspaceMembers({ workspaceId }: { workspaceId: string }) {
  const [members, setMembers] = useState<Member[] | null>(null);
  const [error, setError] = useState<Error | null>(null);
  useEffect(() => {
    let cancelled = false;
    fetch(`/api/workspaces/${workspaceId}/members`)
      .then((r) => r.json())
      .then((data) => { if (!cancelled) setMembers(data); })
      .catch((e) => { if (!cancelled) setError(e); });
    return () => { cancelled = true; };
  }, [workspaceId]);
  if (error) return <ErrorBanner error={error} />;
  if (!members) return <Skeleton />;
  return <MemberList members={members} />;
}
```

**Correct (one `useFetch` hook owns the pattern; components only render):**

```tsx
// One source of truth for the fetch-loading-error lifecycle. Bug fixes apply everywhere.
function useFetch<T>(url: string): { data: T | null; error: Error | null } {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  useEffect(() => {
    let cancelled = false;
    fetch(url)
      .then((r) => r.json())
      .then((value) => { if (!cancelled) setData(value); })
      .catch((e) => { if (!cancelled) setError(e); });
    return () => { cancelled = true; };
  }, [url]);
  return { data, error };
}

function ProjectDashboard({ projectId }: { projectId: string }) {
  const { data: project, error } = useFetch<Project>(`/api/projects/${projectId}`);
  if (error) return <ErrorBanner error={error} />;
  if (!project) return <Skeleton />;
  return <ProjectView project={project} />;
}

function WorkspaceMembers({ workspaceId }: { workspaceId: string }) {
  const { data: members, error } = useFetch<Member[]>(`/api/workspaces/${workspaceId}/members`);
  if (error) return <ErrorBanner error={error} />;
  if (!members) return <Skeleton />;
  return <MemberList members={members} />;
}
```

**When NOT to apply this pattern:**
- Stateful logic used in exactly one place — extracting a hook "for the future" is YAGNI and adds a layer of indirection for no current benefit.
- Logic so trivial that the extraction obscures more than it reveals: a hook that wraps a single `useState` with no derived behavior just renames the React primitive without adding meaning.
- When the "hook" is really a constant or a pure function in disguise — `useColors()` returning a static palette should be a plain `const colors = ...` exported from a module; the `use` prefix would mislead.

**Why this matters:** Custom hooks turn shared stateful concerns into named, testable units; without them, the same lifecycle ceremony spreads across every consumer and drifts independently.

Reference: [react.dev: Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks), [TkDodo: Thinking in React Query](https://tkdodo.eu/blog/thinking-in-react-query)
