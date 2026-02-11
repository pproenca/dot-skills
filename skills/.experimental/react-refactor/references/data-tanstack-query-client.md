---
title: Use TanStack Query for Client-Side Server State
impact: MEDIUM
impactDescription: eliminates 80% of data fetching boilerplate, built-in cache/retry/deduplication
tags: data, tanstack-query, caching, client-state
---

## Use TanStack Query for Client-Side Server State

Manual useEffect + useState fetch patterns require hand-rolled loading states, error handling, caching, request deduplication, and retry logic. Every fetch endpoint duplicates this boilerplate. TanStack Query provides all of these as built-in behavior with a declarative API, and its staleTime/gcTime controls eliminate redundant network requests.

**Incorrect (manual fetch — no caching, no retry, duplicated per endpoint):**

```tsx
"use client";

import { useState, useEffect } from "react";

export function useWarehouseInventory(warehouseId: string) {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);

    fetch(`/api/warehouses/${warehouseId}/inventory`)
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
      })
      .then((data) => {
        if (!cancelled) setInventory(data);
      })
      .catch((err) => {
        if (!cancelled) setError(err);
      })
      .finally(() => {
        if (!cancelled) setIsLoading(false);
      });

    return () => { cancelled = true; };
  }, [warehouseId]);

  // No caching — remounting refetches, no deduplication across components
  return { inventory, isLoading, error };
}
```

**Correct (TanStack Query — caching, retry, deduplication built in):**

```tsx
"use client";

import { useQuery } from "@tanstack/react-query";

async function fetchWarehouseInventory(warehouseId: string): Promise<InventoryItem[]> {
  const res = await fetch(`/api/warehouses/${warehouseId}/inventory`);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

export function useWarehouseInventory(warehouseId: string) {
  return useQuery({
    queryKey: ["warehouse", warehouseId, "inventory"],
    queryFn: () => fetchWarehouseInventory(warehouseId),
    staleTime: 30_000, // serves cached data for 30s without refetch
    gcTime: 5 * 60_000,
    retry: 2,
  });
}

// Multiple components using the same warehouseId share one request
export function InventoryCount({ warehouseId }: { warehouseId: string }) {
  const { data: inventory } = useWarehouseInventory(warehouseId);
  return <span>{inventory?.length ?? 0} items</span>;
}
```

Reference: [TanStack Query - Overview](https://tanstack.com/query/latest/docs/framework/react/overview)
