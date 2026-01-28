---
title: Handle Storage Quota Errors
impact: HIGH
impactDescription: prevents data loss from quota exceeded errors
tags: store, quota, error-handling, overflow
---

## Handle Storage Quota Errors

Storage areas have quota limits. Always handle `QUOTA_BYTES_PER_ITEM` and `QUOTA_BYTES` errors to prevent data loss and provide user feedback.

**Incorrect (unhandled quota errors):**

```typescript
async function cachePageContent(url: string, content: string) {
  const cache = await pageCache.getValue()
  cache[url] = content
  // Throws if cache exceeds quota - data lost
  await pageCache.setValue(cache)
}
```

**Correct (quota-aware caching):**

```typescript
const MAX_CACHE_ENTRIES = 100
const MAX_CONTENT_SIZE = 50_000 // 50KB per entry

async function cachePageContent(url: string, content: string) {
  // Validate before storing
  if (content.length > MAX_CONTENT_SIZE) {
    content = content.slice(0, MAX_CONTENT_SIZE)
    console.warn('Content truncated to fit quota')
  }

  try {
    const cache = await pageCache.getValue()

    // Evict old entries if at capacity
    const entries = Object.entries(cache)
    if (entries.length >= MAX_CACHE_ENTRIES) {
      const oldest = entries
        .sort(([, a], [, b]) => a.timestamp - b.timestamp)
        .slice(0, entries.length - MAX_CACHE_ENTRIES + 1)
      oldest.forEach(([key]) => delete cache[key])
    }

    cache[url] = { content, timestamp: Date.now() }
    await pageCache.setValue(cache)
  } catch (error) {
    if (isQuotaError(error)) {
      // Clear cache and retry
      await pageCache.setValue({})
      await pageCache.setValue({ [url]: { content, timestamp: Date.now() } })
    } else {
      throw error
    }
  }
}

function isQuotaError(error: unknown): boolean {
  return error instanceof Error && (
    error.message.includes('QUOTA_BYTES') ||
    error.message.includes('quota')
  )
}
```

Reference: [Chrome Storage Quotas](https://developer.chrome.com/docs/extensions/reference/api/storage#storage_areas)
