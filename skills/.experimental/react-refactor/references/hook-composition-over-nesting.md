---
title: Compose Hooks Instead of Nesting Them
impact: HIGH
impactDescription: flattens dependency graph, eliminates hidden coupling
tags: hook, composition, nesting, dependency-graph, coupling
---

## Compose Hooks Instead of Nesting Them

When hooks call other hooks internally, the dependency chain becomes invisible to the consuming component. A change in a deeply nested hook silently alters the behavior of every hook above it. Composing independent hooks at the component level makes the dependency graph explicit and each hook independently replaceable.

**Incorrect (nested hooks — hidden dependency chain):**

```tsx
function useOrganizationMembers(orgId: string) {
  // Hidden: internally calls useAuth, usePermissions, and usePagination
  const { token } = useAuth(); // If useAuth changes, this hook silently breaks
  const { canViewMembers } = usePermissions(token);
  const { page, pageSize, nextPage } = usePagination();
  const [members, setMembers] = useState<Member[]>([]);

  useEffect(() => {
    if (!canViewMembers) return;
    fetchMembers(orgId, { page, pageSize }, token).then(setMembers);
  }, [orgId, page, pageSize, token, canViewMembers]);

  return { members, nextPage, canViewMembers };
}

// Consumer has no visibility into auth/permission/pagination dependencies
function MemberList({ orgId }: { orgId: string }) {
  const { members, nextPage, canViewMembers } = useOrganizationMembers(orgId);
  if (!canViewMembers) return <AccessDenied />;
  return <MemberTable members={members} onLoadMore={nextPage} />;
}
```

**Correct (flat composition — dependencies visible at call site):**

```tsx
function useMembers(orgId: string, token: string, page: number, pageSize: number) {
  const [members, setMembers] = useState<Member[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setIsLoading(true);
    fetchMembers(orgId, { page, pageSize }, token).then(setMembers).finally(() => setIsLoading(false));
  }, [orgId, page, pageSize, token]);

  return { members, isLoading };
}

// All dependencies visible — each hook independently replaceable
function MemberList({ orgId }: { orgId: string }) {
  const { token } = useAuth();
  const { canViewMembers } = usePermissions(token);
  const { page, pageSize, nextPage } = usePagination();
  const { members, isLoading } = useMembers(orgId, token, page, pageSize);

  if (!canViewMembers) return <AccessDenied />;
  if (isLoading) return <Skeleton rows={5} />;
  return <MemberTable members={members} onLoadMore={nextPage} />;
}
```

Reference: [React Docs - Custom Hooks: Sharing Logic Between Components](https://react.dev/learn/reusing-logic-with-custom-hooks)
