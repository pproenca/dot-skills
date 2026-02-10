---
title: Use Storage Versioning for Schema Migrations
impact: HIGH
impactDescription: prevents data corruption when storage schema evolves
tags: store, versioning, migrations, schema, defineItem
---

## Use Storage Versioning for Schema Migrations

Production extensions evolve over time. Use `version` and `migrations` in `storage.defineItem` to safely transform stored data when the schema changes.

**Incorrect (manual migration scattered across codebase):**

```typescript
async function getIgnoredSites() {
  const sites = await storage.getItem<string[] | IgnoredSite[]>('local:ignoredSites')
  if (!sites) return []

  // Check if migration needed by inspecting shape
  if (typeof sites[0] === 'string') {
    // Old format - migrate in place
    const migrated = (sites as string[]).map((url) => ({ id: crypto.randomUUID(), url }))
    await storage.setItem('local:ignoredSites', migrated)
    return migrated
  }
  return sites as IgnoredSite[]
}
```

**Correct (declarative versioning with migrations):**

```typescript
interface IgnoredSiteV2 {
  id: string
  url: string
}

// V1 was string[] (unversioned)
const ignoredSites = storage.defineItem<IgnoredSiteV2[]>('local:ignoredSites', {
  fallback: [],
  version: 2,
  migrations: {
    // Runs automatically when migrating from v1 (or unversioned) to v2
    2: (oldSites: string[]): IgnoredSiteV2[] => {
      return oldSites.map((url) => ({
        id: crypto.randomUUID(),
        url
      }))
    }
  }
})

// Usage - migrations run transparently on first access
const sites = await ignoredSites.getValue() // Always IgnoredSiteV2[]
```

**Multi-version migration chain:**

```typescript
interface IgnoredSiteV3 {
  id: string
  url: string
  addedAt: number
  reason?: string
}

const ignoredSites = storage.defineItem<IgnoredSiteV3[]>('local:ignoredSites', {
  fallback: [],
  version: 3,
  migrations: {
    2: (v1: string[]): IgnoredSiteV2[] =>
      v1.map((url) => ({ id: crypto.randomUUID(), url })),
    3: (v2: IgnoredSiteV2[]): IgnoredSiteV3[] =>
      v2.map((site) => ({ ...site, addedAt: Date.now() }))
  }
})
```

**Key concepts:**
- Migrations run automatically on first `getValue()` call
- Migrations execute sequentially: v1 -> v2 -> v3
- Metadata is stored at `key + "$"` with the current version
- Use `fallback` for default when no value exists; use `init` to persist a default on first access

Reference: [WXT Storage Versioning](https://wxt.dev/storage)
