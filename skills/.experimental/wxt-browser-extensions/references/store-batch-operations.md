---
title: Batch Storage Operations
impact: HIGH
impactDescription: reduces storage API calls by 80%+
tags: store, batch, performance, setItems
---

## Batch Storage Operations

Multiple sequential storage operations trigger multiple disk writes. Batch operations into single calls to reduce I/O overhead.

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

**Correct (batched operations):**

```typescript
async function saveFormData(form: FormData) {
  await storage.setItems([
    { key: 'local:name', value: form.name },
    { key: 'local:email', value: form.email },
    { key: 'local:phone', value: form.phone },
    { key: 'local:address', value: form.address }
  ])
  // 1 disk write
}

async function loadFormData(): Promise<FormData> {
  const items = await storage.getItems([
    'local:name',
    'local:email',
    'local:phone',
    'local:address'
  ])
  // 1 disk read
  return {
    name: items['local:name'],
    email: items['local:email'],
    phone: items['local:phone'],
    address: items['local:address']
  }
}
```

**Alternative (single object for related data):**

```typescript
// Best: store related data as single item
const formData = storage.defineItem<FormData>('local:formData', {
  fallback: { name: '', email: '', phone: '', address: '' }
})

await formData.setValue(form)
const data = await formData.getValue()
```

Reference: [WXT Storage API](https://wxt.dev/storage)
