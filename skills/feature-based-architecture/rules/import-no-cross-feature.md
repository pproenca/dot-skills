---
title: Prohibit Cross-Feature Imports
impact: CRITICAL
impactDescription: Prevents feature coupling; enables independent feature development
tags: import, cross-feature, coupling, isolation
---

## Prohibit Cross-Feature Imports

Features must not import directly from other features. When features need to interact, compose them at the app layer. Direct cross-feature imports create hidden dependencies that make features impossible to modify independently.

**Incorrect (cross-feature imports):**

```typescript
// src/features/checkout/components/CheckoutSummary.tsx
import { ProductCard } from '@/features/product/components/ProductCard';  // WRONG
import { useCart } from '@/features/cart/hooks/useCart';  // WRONG
import { UserAddress } from '@/features/user/components/UserAddress';  // WRONG

export function CheckoutSummary() {
  const cart = useCart();
  return (
    <div>
      {cart.items.map(item => <ProductCard product={item} />)}
      <UserAddress />
    </div>
  );
}
```

**Correct (composition at app layer):**

```typescript
// src/features/checkout/components/CheckoutSummary.tsx
interface CheckoutSummaryProps {
  items: CartItem[];
  renderProduct: (item: CartItem) => ReactNode;
  addressSection: ReactNode;
}

export function CheckoutSummary({ items, renderProduct, addressSection }: CheckoutSummaryProps) {
  return (
    <div>
      {items.map(renderProduct)}
      {addressSection}
    </div>
  );
}

// src/app/pages/CheckoutPage.tsx
import { CheckoutSummary } from '@/features/checkout';
import { ProductCard } from '@/features/product';
import { UserAddress } from '@/features/user';
import { useCart } from '@/features/cart';

export function CheckoutPage() {
  const cart = useCart();
  return (
    <CheckoutSummary
      items={cart.items}
      renderProduct={(item) => <ProductCard product={item} />}
      addressSection={<UserAddress />}
    />
  );
}
```

**ESLint enforcement per feature:**

```javascript
// .eslintrc.js
rules: {
  'import/no-restricted-paths': ['error', {
    zones: [
      { target: './src/features/checkout', from: './src/features/product' },
      { target: './src/features/checkout', from: './src/features/cart' },
      { target: './src/features/checkout', from: './src/features/user' },
      // Add for each feature combination
    ],
  }],
}
```

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
