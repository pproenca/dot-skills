---
title: Implement Breadcrumbs for Deep Navigation
impact: MEDIUM
impactDescription: provides location context and quick navigation to parent pages
tags: layout, breadcrumb, navigation, hierarchy, ux
---

## Implement Breadcrumbs for Deep Navigation

Use Breadcrumb component for pages more than one level deep. Users need context about their location and quick access to parent pages.

**Incorrect (no breadcrumbs on deep pages):**

```tsx
// pages/products/[id]/edit.tsx
function EditProductPage({ product }) {
  return (
    <div>
      <h1>Edit {product.name}</h1>
      {/* User has no idea how to get back to products list */}
    </div>
  )
}
```

**Correct (breadcrumb navigation):**

```tsx
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb"
import Link from "next/link"

function EditProductPage({ product }) {
  return (
    <div>
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbLink asChild>
              <Link href="/">Home</Link>
            </BreadcrumbLink>
          </BreadcrumbItem>
          <BreadcrumbSeparator />
          <BreadcrumbItem>
            <BreadcrumbLink asChild>
              <Link href="/products">Products</Link>
            </BreadcrumbLink>
          </BreadcrumbItem>
          <BreadcrumbSeparator />
          <BreadcrumbItem>
            <BreadcrumbLink asChild>
              <Link href={`/products/${product.id}`}>{product.name}</Link>
            </BreadcrumbLink>
          </BreadcrumbItem>
          <BreadcrumbSeparator />
          <BreadcrumbItem>
            <BreadcrumbPage>Edit</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      <h1 className="mt-4">Edit {product.name}</h1>
    </div>
  )
}
```

**Note:** Use `BreadcrumbPage` for the current page (not a link) and `BreadcrumbLink` with `asChild` for navigable items.

Reference: [shadcn/ui Breadcrumb](https://ui.shadcn.com/docs/components/breadcrumb)
