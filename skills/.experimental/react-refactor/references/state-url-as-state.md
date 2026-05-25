---
title: Use URL Parameters as State for Shareable Views
impact: CRITICAL
impactDescription: enables deep linking, back/forward navigation, state sharing
tags: state, url-state, search-params, deep-linking
---

## Use URL Parameters as State for Shareable Views

Local state for filters, pagination, and search queries breaks browser back/forward navigation and makes views unshareable. When a user copies the URL, the recipient sees a blank slate. URL parameters preserve the exact view state in the address bar, enabling bookmarking, sharing, and history navigation for free.

**Incorrect (useState — view state lost on navigation and sharing):**

```tsx
function IssueTracker() {
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState<"open" | "closed" | "all">("open");
  const [page, setPage] = useState(1);
  const [sortBy, setSortBy] = useState<"created" | "updated">("created");

  // URL is always /issues — sharing it shows default filters, not the user's view
  const issues = useIssueSearch({ searchQuery, statusFilter, page, sortBy });

  return (
    <div>
      <input value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} />
      <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value as "open" | "closed" | "all")}>
        <option value="open">Open</option>
        <option value="closed">Closed</option>
        <option value="all">All</option>
      </select>
      <IssueTable issues={issues.data} />
      <Pagination current={page} total={issues.totalPages} onChange={setPage} />
    </div>
  );
}
```

**Correct (Next.js App Router `useSearchParams` — view state in the URL):**

```tsx
"use client";

import { useSearchParams, useRouter, usePathname } from "next/navigation";

function IssueTracker() {
  // In Next.js App Router, useSearchParams() is READ-ONLY — there is no setter.
  const searchParams = useSearchParams();
  const router = useRouter();
  const pathname = usePathname();

  const searchQuery = searchParams.get("q") ?? "";
  const statusFilter = (searchParams.get("status") ?? "open") as "open" | "closed" | "all";
  const page = Number(searchParams.get("page") ?? "1");
  const sortBy = (searchParams.get("sort") ?? "created") as "created" | "updated";

  // URL: /issues?q=auth&status=open&page=2&sort=updated — shareable, bookmarkable
  const issues = useIssueSearch({ searchQuery, statusFilter, page, sortBy });

  function updateParam(key: string, value: string) {
    // Updates go through the router — build a new query string, then push it.
    const next = new URLSearchParams(searchParams.toString());
    if (value) next.set(key, value);
    else next.delete(key);
    router.push(`${pathname}?${next.toString()}`);
  }

  return (
    <div>
      <input value={searchQuery} onChange={(e) => updateParam("q", e.target.value)} />
      <select value={statusFilter} onChange={(e) => updateParam("status", e.target.value)}>
        <option value="open">Open</option>
        <option value="closed">Closed</option>
        <option value="all">All</option>
      </select>
      <IssueTable issues={issues.data} />
      <Pagination current={page} total={issues.totalPages} onChange={(p) => updateParam("page", String(p))} />
    </div>
  );
}
```

For server-rendered filters, read the params instead from the route's `searchParams` prop — a Promise in Next.js 16, so `await` it: `async function Page({ searchParams }: { searchParams: Promise<Record<string, string>> }) { const { q } = await searchParams; }`.

Reference: [Next.js - useSearchParams](https://nextjs.org/docs/app/api-reference/functions/use-search-params)
