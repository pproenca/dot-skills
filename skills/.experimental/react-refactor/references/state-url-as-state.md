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

**Correct (useSearchParams — view state in the URL):**

```tsx
function IssueTracker() {
  const [searchParams, setSearchParams] = useSearchParams();

  const searchQuery = searchParams.get("q") ?? "";
  const statusFilter = (searchParams.get("status") ?? "open") as "open" | "closed" | "all";
  const page = Number(searchParams.get("page") ?? "1");
  const sortBy = (searchParams.get("sort") ?? "created") as "created" | "updated";

  // URL: /issues?q=auth&status=open&page=2&sort=updated — shareable, bookmarkable
  const issues = useIssueSearch({ searchQuery, statusFilter, page, sortBy });

  function updateParam(key: string, value: string) {
    setSearchParams((prev) => {
      const next = new URLSearchParams(prev);
      if (value) next.set(key, value);
      else next.delete(key);
      return next;
    });
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

Reference: [React Router - useSearchParams](https://reactrouter.com/en/main/hooks/use-search-params)
