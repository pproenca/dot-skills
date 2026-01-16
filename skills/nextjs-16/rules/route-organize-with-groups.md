---
title: Organize Routes with Route Groups
impact: MEDIUM
impactDescription: Enables multiple layouts without URL pollution; keeps related routes together for maintainability
tags: route, route-groups, organization, layouts
---

## Organize Routes with Route Groups

Route groups (folders wrapped in parentheses) organize routes without affecting the URL structure. Use them for multiple root layouts, logical grouping, and separating concerns.

**Incorrect (flat structure with URL pollution):**

```
app/
  marketing-home/
    page.tsx              # /marketing-home ❌ pollutes URL
  marketing-about/
    page.tsx              # /marketing-about ❌
  shop-products/
    page.tsx              # /shop-products ❌
  shop-cart/
    page.tsx              # /shop-cart ❌
```

**Correct (route groups for organization):**

```
app/
  (marketing)/
    page.tsx              # / ✓ clean URL
    about/
      page.tsx            # /about ✓
    layout.tsx            # Marketing-specific layout
  (shop)/
    products/
      page.tsx            # /products ✓
    cart/
      page.tsx            # /cart ✓
    layout.tsx            # Shop-specific layout
```

**Multiple root layouts:**

```typescript
// app/(marketing)/layout.tsx
export default function MarketingLayout({ children }) {
  return (
    <html>
      <body className="marketing-theme">
        <MarketingHeader />
        {children}
        <MarketingFooter />
      </body>
    </html>
  )
}

// app/(shop)/layout.tsx
export default function ShopLayout({ children }) {
  return (
    <html>
      <body className="shop-theme">
        <ShopHeader />
        <CartProvider>
          {children}
        </CartProvider>
        <ShopFooter />
      </body>
    </html>
  )
}
```

**Auth-based route groups:**

```
app/
  (authenticated)/
    dashboard/
      page.tsx            # /dashboard (requires auth)
    settings/
      page.tsx            # /settings (requires auth)
    layout.tsx            # Auth check, sidebar, etc.
  (public)/
    page.tsx              # / (public)
    login/
      page.tsx            # /login (public)
    layout.tsx            # Public header/footer
```

**Combining with private folders:**

```
app/
  (marketing)/
    _components/          # Not routable, colocated components
      Hero.tsx
      FeatureList.tsx
    page.tsx
    layout.tsx
```

**When NOT to use route groups:**
- Simple apps with single layout
- When URL segments actually make sense
- Premature organization (wait for patterns to emerge)

Reference: [Next.js Route Groups](https://nextjs.org/docs/app/building-your-application/routing/route-groups)
