---
title: Minimize Client Component Scope
impact: CRITICAL
impactDescription: Each 'use client' boundary adds component code to JS bundle; a misplaced directive can add 250KB+ to client payload
tags: bundle, client-components, use-client, tree-shaking
---

## Minimize Client Component Scope

The `'use client'` directive marks a boundary - everything below it becomes client-side JavaScript. Place it as deep in the component tree as possible, only around components that truly need interactivity.

**Incorrect (wide client boundary):**

```typescript
'use client'

// Entire layout is now client-side
export default function ProductLayout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      <Header />           {/* Static header - now client JS */}
      <Navigation />       {/* Static nav - now client JS */}
      <main>{children}</main>
      <Footer />           {/* Static footer - now client JS */}
    </div>
  )
}

// Bundle impact: 100KB+ of unnecessary JS
```

**Correct (minimal client boundary):**

```typescript
// Server Component - no JS shipped
export default function ProductLayout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      <Header />           {/* Server rendered */}
      <Navigation />       {/* Server rendered */}
      <main>{children}</main>
      <Footer />           {/* Server rendered */}
    </div>
  )
}
```

```typescript
// components/Navigation.tsx
import SearchButton from './SearchButton'

// Server Component
export default function Navigation() {
  return (
    <nav>
      <Logo />             {/* Server Component */}
      <NavLinks />         {/* Server Component */}
      <SearchButton />     {/* Only this is client-side */}
    </nav>
  )
}
```

```typescript
// components/SearchButton.tsx
'use client'

import { useState } from 'react'

// Minimal client component - just the interactive part
export default function SearchButton() {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <button onClick={() => setIsOpen(true)}>
      Search
    </button>
  )
}
```

**Pattern: Leaf components as client boundaries:**

```typescript
// Server Component renders list
export default async function ProductList() {
  const products = await getProducts()

  return (
    <ul>
      {products.map(p => (
        <li key={p.id}>
          <span>{p.name}</span>
          <AddToCartButton productId={p.id} />  {/* Client leaf */}
        </li>
      ))}
    </ul>
  )
}
```

**When NOT to use this pattern:**
- Component tree below needs significant interactivity (useState, useEffect throughout)
- Performance testing shows negligible difference

Reference: [Next.js Client Components](https://nextjs.org/docs/app/building-your-application/rendering/client-components)
