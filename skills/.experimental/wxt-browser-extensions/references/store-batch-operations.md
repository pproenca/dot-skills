---
title: Batch Storage Operations
impact: HIGH
impactDescription: reduces storage API calls by 80%+
tags: store, batch, performance, defineItem
---

## Batch Storage Operations

Multiple sequential storage operations trigger multiple disk writes. Group related data into a single `defineItem` to reduce I/O overhead.

**Incorrect (multiple sequential operations):**

```typescript
async function saveFormData(form: FormData) {
  await storage.setItem('local:name', form.name)
  await storage.setItem('local:email', form.email)
  await storage.setItem('local:phone', form.phone)
  await storage.setItem('local:address', form.address)
  // 4 separate disk writes
}

async function loadFormData(): Promise<FormData> {
  const name = await storage.getItem('local:name')
  const email = await storage.getItem('local:email')
  const phone = await storage.getItem('local:phone')
  const address = await storage.getItem('local:address')
  // 4 separate disk reads
  return { name, email, phone, address }
}
```

**Correct (single defineItem for related data):**

```typescript
interface FormData {
  name: string
  email: string
  phone: string
  address: string
}

const formData = storage.defineItem<FormData>('local:formData', {
  fallback: { name: '', email: '', phone: '', address: '' }
})

async function saveFormData(form: FormData) {
  await formData.setValue(form) // 1 disk write
}

async function loadFormData(): Promise<FormData> {
  return await formData.getValue() // 1 disk read, never null
}

// Partial updates
async function updateEmail(email: string) {
  const current = await formData.getValue()
  await formData.setValue({ ...current, email })
}
```

**When to use separate items instead:**

```typescript
// Separate items when data has different lifecycles or sync needs
const userPrefs = storage.defineItem<UserPrefs>('sync:preferences', {
  fallback: { theme: 'light', language: 'en' }
})
const pageCache = storage.defineItem<PageCache>('local:cache', {
  fallback: {}
})
// Preferences sync across devices, cache is local-only
```

**Key principle:** Group data that is read/written together into a single storage item. Split data with different storage areas, sync needs, or independent lifecycles.

Reference: [WXT Storage API](https://wxt.dev/storage)
