# React Feature-Based Architecture

**Version 0.1.0**  
Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive architecture guide for organizing React applications by features, enabling scalable development with independent teams. Contains 42 rules across 8 categories, prioritized by impact from critical (directory structure and import rules) to incremental (naming conventions). Each rule includes detailed explanations, production-realistic code examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Directory Structure](#1-directory-structure) — **CRITICAL**
   - 1.1 [Include Only Necessary Segments](#11-include-only-necessary-segments)
   - 1.2 [Keep Directory Hierarchy Flat](#12-keep-directory-hierarchy-flat)
   - 1.3 [Make Features Self-Contained](#13-make-features-self-contained)
   - 1.4 [Organize by Feature, Not Technical Type](#14-organize-by-feature-not-technical-type)
   - 1.5 [Separate App Layer from Features](#15-separate-app-layer-from-features)
   - 1.6 [Use Shared Layer for Truly Generic Code Only](#16-use-shared-layer-for-truly-generic-code-only)
2. [Import & Dependencies](#2-import-dependencies) — **CRITICAL**
   - 2.1 [Avoid Deep Barrel File Re-exports](#21-avoid-deep-barrel-file-re-exports)
   - 2.2 [Enforce Unidirectional Import Flow](#22-enforce-unidirectional-import-flow)
   - 2.3 [Export Through Public API Only](#23-export-through-public-api-only)
   - 2.4 [Prohibit Cross-Feature Imports](#24-prohibit-cross-feature-imports)
   - 2.5 [Use Consistent Path Aliases](#25-use-consistent-path-aliases)
   - 2.6 [Use Type-Only Imports for Types](#26-use-type-only-imports-for-types)
3. [Module Boundaries](#3-module-boundaries) — **HIGH**
   - 3.1 [Define Explicit Interface Contracts](#31-define-explicit-interface-contracts)
   - 3.2 [Enforce Feature Isolation](#32-enforce-feature-isolation)
   - 3.3 [Keep Features Appropriately Sized](#33-keep-features-appropriately-sized)
   - 3.4 [Minimize Shared State Between Features](#34-minimize-shared-state-between-features)
   - 3.5 [Scope Routing to Feature Concerns](#35-scope-routing-to-feature-concerns)
   - 3.6 [Use Events for Cross-Feature Communication](#36-use-events-for-cross-feature-communication)
4. [Data Fetching](#4-data-fetching) — **HIGH**
   - 4.1 [Avoid N+1 Query Patterns](#41-avoid-n1-query-patterns)
   - 4.2 [Colocate Data Fetching with Features](#42-colocate-data-fetching-with-features)
   - 4.3 [Fetch at Server Component Level](#43-fetch-at-server-component-level)
   - 4.4 [Fetch Independent Data in Parallel](#44-fetch-independent-data-in-parallel)
   - 4.5 [Keep Query Functions Single-Purpose](#45-keep-query-functions-single-purpose)
   - 4.6 [Use Feature-Scoped Query Keys](#46-use-feature-scoped-query-keys)
5. [Component Organization](#5-component-organization) — **MEDIUM-HIGH**
   - 5.1 [Apply Single Responsibility to Components](#51-apply-single-responsibility-to-components)
   - 5.2 [Colocate Styles with Components](#52-colocate-styles-with-components)
   - 5.3 [Prefer Composition Over Prop Drilling](#53-prefer-composition-over-prop-drilling)
   - 5.4 [Separate Container and Presentational Concerns](#54-separate-container-and-presentational-concerns)
   - 5.5 [Use Feature-Level Error Boundaries](#55-use-feature-level-error-boundaries)
   - 5.6 [Use Props as Feature Boundaries](#56-use-props-as-feature-boundaries)
6. [State Management](#6-state-management) — **MEDIUM**
   - 6.1 [Lift State Only as High as Necessary](#61-lift-state-only-as-high-as-necessary)
   - 6.2 [Reset Feature State on Unmount](#62-reset-feature-state-on-unmount)
   - 6.3 [Scope State Stores to Features](#63-scope-state-stores-to-features)
   - 6.4 [Separate Server State from Client State](#64-separate-server-state-from-client-state)
   - 6.5 [Use Context Sparingly for Feature State](#65-use-context-sparingly-for-feature-state)
7. [Testing Strategy](#7-testing-strategy) — **MEDIUM**
   - 7.1 [Colocate Tests with Features](#71-colocate-tests-with-features)
   - 7.2 [Create Feature-Specific Test Utilities](#72-create-feature-specific-test-utilities)
   - 7.3 [Test Features in Isolation](#73-test-features-in-isolation)
   - 7.4 [Write Integration Tests at App Layer](#74-write-integration-tests-at-app-layer)
8. [Naming Conventions](#8-naming-conventions) — **LOW**
   - 8.1 [Use Consistent File Naming Conventions](#81-use-consistent-file-naming-conventions)
   - 8.2 [Use Descriptive Export Names](#82-use-descriptive-export-names)
   - 8.3 [Use Domain-Driven Feature Names](#83-use-domain-driven-feature-names)

---

## 1. Directory Structure

**Impact: CRITICAL**

Foundation decisions that cascade through all development; wrong structure requires costly rewrites as application scales.

### 1.1 Include Only Necessary Segments

**Impact: HIGH (Prevents empty folder clutter; keeps features minimal and focused)**

Not every feature needs every segment (components/, hooks/, api/, utils/, types/). Start with only what the feature requires and add segments as complexity grows. Empty folders add noise and suggest over-engineering.

**Incorrect (every segment even when unused):**

```
src/features/notification/
├── api/           # Empty - notifications are client-side only
├── components/
│   └── Toast.tsx
├── hooks/
│   └── useNotification.ts
├── stores/        # Empty - using context instead
├── types/
│   └── index.ts   # Just re-exports one interface
└── utils/         # Empty
```

**Correct (only necessary segments):**

```
src/features/notification/
├── components/
│   └── Toast.tsx
├── hooks/
│   └── useNotification.ts
└── types.ts       # Single file, not a folder with one file
```

**Another example - simple feature:**

```
src/features/theme/
├── ThemeProvider.tsx
├── useTheme.ts
└── index.ts
```

**Complex feature with all segments:**

```
src/features/checkout/
├── api/
│   ├── submit-order.ts
│   └── validate-address.ts
├── components/
│   ├── CheckoutForm.tsx
│   ├── PaymentSection.tsx
│   └── ShippingSection.tsx
├── hooks/
│   ├── useCheckout.ts
│   └── usePaymentMethods.ts
├── stores/
│   └── checkout-store.ts
├── types/
│   └── index.ts
├── utils/
│   └── validation.ts
└── index.ts
```

**Guideline:** Add segments when you have 2+ files that would go there.

Reference: [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)

### 1.2 Keep Directory Hierarchy Flat

**Impact: CRITICAL (Reduces cognitive load; prevents 5+ level deep import paths)**

Deep nesting creates long import paths, makes file relocation difficult, and obscures the overall structure. Limit nesting to 2-3 levels within features.

**Incorrect (deep nesting):**

```
src/features/checkout/
├── components/
│   ├── form/
│   │   ├── fields/
│   │   │   ├── payment/
│   │   │   │   └── CardInput.tsx
│   │   │   └── shipping/
│   │   │       └── AddressInput.tsx
│   │   └── FormWrapper.tsx
│   └── summary/
│       └── OrderSummary.tsx
```

```typescript
// Import path is 6 levels deep
import { CardInput } from '../../../components/form/fields/payment/CardInput';
```

**Correct (flat hierarchy):**

```
src/features/checkout/
├── components/
│   ├── CardInput.tsx
│   ├── AddressInput.tsx
│   ├── FormWrapper.tsx
│   └── OrderSummary.tsx
```

```typescript
// Import path is 2 levels
import { CardInput } from '../components/CardInput';
```

**When deeper nesting is acceptable:**
- Feature has 20+ components (consider splitting into sub-features)
- Clear categorical distinction (e.g., `forms/` vs `displays/`)

**Guidelines:**
- Maximum 3 levels within a feature folder
- If you need deeper nesting, the feature is likely too large
- Prefer flat with clear naming over deep with vague naming

Reference: [Robin Wieruch - React Folder Structure](https://www.robinwieruch.de/react-folder-structure/)

### 1.3 Make Features Self-Contained

**Impact: CRITICAL (Enables independent deployment and parallel team development)**

Each feature folder should contain everything needed to implement that feature. When a feature requires code from multiple places, it becomes entangled with other features and cannot evolve independently.

**Incorrect (scattered feature code):**

```typescript
// src/components/checkout/CheckoutForm.tsx
import { useCart } from '../../hooks/useCart';
import { validateCard } from '../../utils/validation';
import { CartSummary } from '../cart/CartSummary';
import { paymentApi } from '../../api/payment';

export function CheckoutForm() {
  const cart = useCart();
  // Feature depends on 4 different locations
}
```

**Correct (self-contained feature):**

```typescript
// src/features/checkout/components/CheckoutForm.tsx
import { useCart } from '../hooks/useCart';
import { validateCard } from '../utils/validation';
import { CartSummary } from '../components/CartSummary';
import { submitPayment } from '../api/submit-payment';

export function CheckoutForm() {
  const cart = useCart();
  // All imports are within the feature
}
```

**Feature folder structure:**

```
features/checkout/
├── api/
│   └── submit-payment.ts
├── components/
│   ├── CheckoutForm.tsx
│   └── CartSummary.tsx
├── hooks/
│   └── useCart.ts
├── utils/
│   └── validation.ts
└── index.ts
```

**When NOT to use this pattern:**
- Truly generic utilities (date formatting, string helpers) belong in `shared/`
- UI primitives (Button, Input) belong in `shared/components/`

Reference: [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)

### 1.4 Organize by Feature, Not Technical Type

**Impact: CRITICAL (Eliminates cross-file navigation; reduces onboarding time by 50%+)**

Technical grouping (components/, hooks/, utils/) forces developers to navigate multiple directories for single features. Feature-based organization colocates all related code, making features self-documenting and independently deployable.

**Incorrect (technical grouping):**

```
src/
├── components/
│   ├── PostCard.tsx
│   ├── CommentList.tsx
│   └── UserAvatar.tsx
├── hooks/
│   ├── usePost.ts
│   ├── useComments.ts
│   └── useUser.ts
├── api/
│   ├── posts.ts
│   ├── comments.ts
│   └── users.ts
└── utils/
    ├── postHelpers.ts
    └── commentHelpers.ts
```

**Correct (feature-based grouping):**

```
src/
├── features/
│   ├── post/
│   │   ├── components/
│   │   │   └── PostCard.tsx
│   │   ├── hooks/
│   │   │   └── usePost.ts
│   │   ├── api/
│   │   │   └── get-post.ts
│   │   └── utils/
│   │       └── postHelpers.ts
│   ├── comment/
│   │   ├── components/
│   │   │   └── CommentList.tsx
│   │   ├── hooks/
│   │   │   └── useComments.ts
│   │   └── api/
│   │       └── get-comments.ts
│   └── user/
│       ├── components/
│       │   └── UserAvatar.tsx
│       └── hooks/
│           └── useUser.ts
└── shared/
    └── components/
        └── Button.tsx
```

**Benefits:**
- Adding a feature = adding one folder
- Removing a feature = removing one folder
- Feature ownership is immediately clear
- Teams can work on different features without conflicts

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)

### 1.5 Separate App Layer from Features

**Impact: HIGH (Isolates global concerns; enables feature modules to remain pure)**

The app layer handles global concerns: routing, providers, initialization, and global layouts. Features should not contain routing logic or provider setup. This separation allows features to be portable and testable in isolation.

**Incorrect (routing and providers mixed with features):**

```
src/features/user/
├── components/
│   └── UserProfile.tsx
├── UserRoutes.tsx        # Routing logic in feature
└── UserProvider.tsx      # Provider in feature
```

```typescript
// src/features/user/UserRoutes.tsx
import { Routes, Route } from 'react-router-dom';

export function UserRoutes() {
  return (
    <Routes>
      <Route path="/profile" element={<UserProfile />} />
      <Route path="/settings" element={<UserSettings />} />
    </Routes>
  );
}
```

**Correct (app layer owns routing and providers):**

```
src/
├── app/
│   ├── providers/
│   │   ├── AuthProvider.tsx
│   │   ├── QueryProvider.tsx
│   │   └── index.tsx
│   ├── routes/
│   │   ├── index.tsx
│   │   └── protected-routes.tsx
│   └── App.tsx
└── features/
    └── user/
        ├── components/
        │   ├── UserProfile.tsx
        │   └── UserSettings.tsx
        └── index.ts
```

```typescript
// src/app/routes/index.tsx
import { UserProfile, UserSettings } from '@/features/user';

export const routes = [
  { path: '/profile', element: <UserProfile /> },
  { path: '/settings', element: <UserSettings /> },
];
```

**App layer responsibilities:**
- Route definitions and navigation
- Provider composition (Auth, Query, Theme)
- Global error boundaries
- Application initialization

Reference: [Feature-Sliced Design](https://feature-sliced.design/)

### 1.6 Use Shared Layer for Truly Generic Code Only

**Impact: CRITICAL (Prevents shared/ from becoming a dumping ground; maintains feature boundaries)**

The shared layer should contain only code with high reusability and minimal business logic. When business-specific code lands in shared/, it creates hidden dependencies and prevents features from being truly independent.

**Incorrect (business logic in shared):**

```
src/shared/
├── components/
│   ├── Button.tsx          # Generic - OK
│   ├── ProductCard.tsx     # Business-specific - WRONG
│   └── UserBadge.tsx       # Business-specific - WRONG
├── hooks/
│   ├── useDebounce.ts      # Generic - OK
│   └── useCheckout.ts      # Business-specific - WRONG
└── utils/
    ├── formatDate.ts       # Generic - OK
    └── calculateTax.ts     # Business-specific - WRONG
```

**Correct (shared is generic only):**

```
src/shared/
├── components/
│   ├── Button.tsx
│   ├── Input.tsx
│   ├── Modal.tsx
│   └── Tooltip.tsx
├── hooks/
│   ├── useDebounce.ts
│   ├── useLocalStorage.ts
│   └── useMediaQuery.ts
└── utils/
    ├── formatDate.ts
    ├── formatCurrency.ts
    └── cn.ts
```

```
src/features/product/
├── components/
│   └── ProductCard.tsx     # Business component lives with feature
└── ...

src/features/checkout/
├── hooks/
│   └── useCheckout.ts      # Business hook lives with feature
├── utils/
│   └── calculateTax.ts     # Business util lives with feature
└── ...
```

**Litmus test for shared/:**
- Would this be useful in a completely different project?
- Does it contain zero business domain knowledge?
- Is it used by 3+ features?

If any answer is "no", it belongs in a feature folder.

Reference: [Feature-Sliced Design](https://feature-sliced.design/)

---

## 2. Import & Dependencies

**Impact: CRITICAL**

Enforces unidirectional data flow and prevents circular dependencies that cause build failures and runtime bugs.

### 2.1 Avoid Deep Barrel File Re-exports

**Impact: HIGH (Prevents tree-shaking failures; reduces bundle size by avoiding unused code)**

While feature index.ts files are useful for public APIs, avoid creating nested barrel files that re-export everything. Deep barrel chains prevent bundlers from tree-shaking unused code and can cause performance issues in development.

**Incorrect (barrel chain):**

```typescript
// src/features/user/components/index.ts
export * from './UserProfile';
export * from './UserSettings';
export * from './UserAvatar';
export * from './UserBadge';
// ... 20 more exports

// src/features/user/index.ts
export * from './components';  // Re-exports everything
export * from './hooks';
export * from './utils';

// Consumer imports one component but bundles all
import { UserAvatar } from '@/features/user';
```

**Correct (explicit exports):**

```typescript
// src/features/user/index.ts
// Explicit, named exports - bundler knows exactly what's used
export { UserProfile } from './components/UserProfile';
export { UserSettings } from './components/UserSettings';
export { UserAvatar } from './components/UserAvatar';
export { useUser } from './hooks/useUser';
export type { User } from './types';

// Consumer
import { UserAvatar } from '@/features/user';  // Only UserAvatar bundled
```

**Alternative for large features:**

```typescript
// Direct imports for specific needs
import { UserAvatar } from '@/features/user/components/UserAvatar';

// This is acceptable when:
// 1. Feature has 15+ exports
// 2. Consumer only needs one specific item
// 3. Bundle size is critical
```

**When barrel files are OK:**
- Feature public API (index.ts) with explicit exports
- Small features with < 10 exports
- Type-only exports (no runtime impact)

Reference: [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)

### 2.2 Enforce Unidirectional Import Flow

**Impact: CRITICAL (Prevents circular dependencies; enables deterministic build order)**

Imports must flow in one direction: `shared → features → app`. Features can import from shared, and app can import from both, but never the reverse. This prevents circular dependencies that cause build failures and makes the dependency graph predictable.

**Incorrect (bidirectional imports):**

```typescript
// src/shared/utils/analytics.ts
import { useAuth } from '@/features/auth/hooks/useAuth';  // WRONG: shared → features

export function trackEvent(event: string) {
  const { user } = useAuth();
  // ...
}
```

```typescript
// src/features/user/components/UserProfile.tsx
import { AppLayout } from '@/app/layouts/AppLayout';  // WRONG: features → app

export function UserProfile() {
  return <AppLayout>...</AppLayout>;
}
```

**Correct (unidirectional flow):**

```typescript
// Dependency flow: shared → features → app

// src/shared/utils/analytics.ts
export function trackEvent(event: string, userId?: string) {
  // No feature imports - userId passed as parameter
}

// src/features/user/components/UserProfile.tsx
import { formatDate } from '@/shared/utils/formatDate';  // OK: shared used by feature
import { trackEvent } from '@/shared/utils/analytics';

export function UserProfile({ user }) {
  useEffect(() => {
    trackEvent('profile_view', user.id);
  }, []);
  return <div>...</div>;
}

// src/app/pages/UserPage.tsx
import { UserProfile } from '@/features/user';  // OK: app uses features
import { AppLayout } from '@/app/layouts/AppLayout';

export function UserPage() {
  return (
    <AppLayout>
      <UserProfile />
    </AppLayout>
  );
}
```

**ESLint enforcement:**

```javascript
// .eslintrc.js
rules: {
  'import/no-restricted-paths': ['error', {
    zones: [
      { target: './src/shared', from: './src/features' },
      { target: './src/shared', from: './src/app' },
      { target: './src/features', from: './src/app' },
    ],
  }],
}
```

Reference: [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)

### 2.3 Export Through Public API Only

**Impact: CRITICAL (Prevents deep imports; enables internal refactoring without breaking consumers)**

Each feature should have a single entry point (index.ts) that exports its public API. External code should never import internal files directly. This allows internal restructuring without affecting consumers.

**Incorrect (deep imports into feature internals):**

```typescript
// src/app/pages/UserPage.tsx
import { UserProfile } from '@/features/user/components/UserProfile';
import { useUser } from '@/features/user/hooks/useUser';
import { formatUserName } from '@/features/user/utils/formatters';
import { User } from '@/features/user/types/user';
```

**Correct (import from public API):**

```typescript
// src/features/user/index.ts (public API)
export { UserProfile } from './components/UserProfile';
export { UserSettings } from './components/UserSettings';
export { useUser } from './hooks/useUser';
export type { User, UserRole } from './types';
// Note: formatUserName is NOT exported - it's internal

// src/app/pages/UserPage.tsx
import { UserProfile, useUser } from '@/features/user';
import type { User } from '@/features/user';
```

**Internal file can import freely:**

```typescript
// src/features/user/components/UserProfile.tsx
import { useUser } from '../hooks/useUser';
import { formatUserName } from '../utils/formatters';  // Internal util
import type { User } from '../types';
```

**ESLint enforcement:**

```javascript
// .eslintrc.js
rules: {
  'no-restricted-imports': ['error', {
    patterns: [
      {
        group: ['@/features/*/components/*', '@/features/*/hooks/*', '@/features/*/utils/*'],
        message: 'Import from feature index.ts instead',
      },
    ],
  }],
}
```

**Benefits:**
- Refactor internal structure without breaking external imports
- Clear contract of what a feature provides
- Smaller, focused public surface area

Reference: [Feature-Sliced Design](https://feature-sliced.design/)

### 2.4 Prohibit Cross-Feature Imports

**Impact: CRITICAL (Prevents feature coupling; enables independent feature development)**

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

### 2.5 Use Consistent Path Aliases

**Impact: HIGH (Eliminates ../../../ chains; makes imports self-documenting)**

Configure path aliases to avoid relative import chains. Aliases make imports self-documenting by showing feature ownership clearly and survive file relocations within the same feature.

**Incorrect (deep relative paths):**

```typescript
// src/features/checkout/components/PaymentForm.tsx
import { Button } from '../../../shared/components/Button';
import { useAuth } from '../../../features/auth/hooks/useAuth';  // Also wrong: cross-feature
import { formatCurrency } from '../../../shared/utils/formatCurrency';
import { useCheckout } from '../hooks/useCheckout';
```

**Correct (path aliases):**

```typescript
// src/features/checkout/components/PaymentForm.tsx
import { Button } from '@/shared/components/Button';
import { formatCurrency } from '@/shared/utils/formatCurrency';
import { useCheckout } from '../hooks/useCheckout';  // Same feature = relative OK
```

**tsconfig.json:**

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@/shared/*": ["src/shared/*"],
      "@/features/*": ["src/features/*"],
      "@/app/*": ["src/app/*"]
    }
  }
}
```

**Guidelines:**
- Use `@/` prefix for absolute imports from src
- Use relative imports (`./`, `../`) within the same feature
- Relative imports within a feature make the feature more portable

**Vite configuration:**

```typescript
// vite.config.ts
export default defineConfig({
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

Reference: [Robin Wieruch - React Folder Structure](https://www.robinwieruch.de/react-folder-structure/)

### 2.6 Use Type-Only Imports for Types

**Impact: MEDIUM (Enables cross-feature type sharing without runtime coupling)**

Use `import type` syntax when importing only TypeScript types. This ensures types are stripped at compile time and allows sharing types across features without creating runtime dependencies.

**Incorrect (mixing type and value imports):**

```typescript
// src/features/checkout/components/CheckoutForm.tsx
import { User, useUser } from '@/features/user';  // Creates runtime dependency for type

export function CheckoutForm({ userId }: { userId: string }) {
  // We only need the User type, not useUser
  const [user, setUser] = useState<User | null>(null);
}
```

**Correct (separate type imports):**

```typescript
// src/features/checkout/components/CheckoutForm.tsx
import type { User } from '@/features/user';  // Type-only, no runtime dependency

export function CheckoutForm({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
}
```

**Shared types for cross-feature contracts:**

```typescript
// src/shared/types/entities.ts
export interface User {
  id: string;
  email: string;
  name: string;
}

export interface Product {
  id: string;
  name: string;
  price: number;
}

// Features import shared types
// src/features/checkout/types.ts
import type { User, Product } from '@/shared/types/entities';

export interface CheckoutItem {
  product: Product;
  quantity: number;
}

export interface CheckoutSession {
  user: User;
  items: CheckoutItem[];
}
```

**Benefits:**
- No runtime bundle impact for type-only imports
- Clear distinction between runtime and compile-time dependencies
- Enables type sharing without architectural coupling

**TypeScript configuration:**

```json
{
  "compilerOptions": {
    "verbatimModuleSyntax": true  // Enforces type-only imports
  }
}
```

Reference: [TypeScript Handbook - Type-Only Imports](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-8.html#type-only-imports-and-export)

---

## 3. Module Boundaries

**Impact: HIGH**

Maintains feature isolation preventing changes in one area from causing regressions across the codebase.

### 3.1 Define Explicit Interface Contracts

**Impact: HIGH (Prevents implicit dependencies; enables parallel feature development)**

When features need to interact, define explicit interfaces that describe the contract. This makes dependencies visible and allows features to be developed in parallel against the contract.

**Incorrect (implicit interface):**

```typescript
// src/features/checkout/components/CheckoutForm.tsx
export function CheckoutForm({ onSuccess }) {
  // What shape does onSuccess expect?
  // What data should be passed?
  const handleSubmit = () => {
    onSuccess(someData);  // Caller must guess the shape
  };
}
```

**Correct (explicit contract):**

```typescript
// src/features/checkout/types.ts
export interface CheckoutResult {
  orderId: string;
  total: number;
  items: Array<{ id: string; quantity: number }>;
}

export interface CheckoutFormProps {
  userId: string;
  cartItems: CartItem[];
  onSuccess: (result: CheckoutResult) => void;
  onError: (error: CheckoutError) => void;
}

// src/features/checkout/components/CheckoutForm.tsx
export function CheckoutForm({ userId, cartItems, onSuccess, onError }: CheckoutFormProps) {
  const handleSubmit = async () => {
    try {
      const result = await processCheckout(userId, cartItems);
      onSuccess({
        orderId: result.id,
        total: result.total,
        items: result.items.map(i => ({ id: i.id, quantity: i.qty })),
      });
    } catch (err) {
      onError(normalizeError(err));
    }
  };
}
```

**Contract patterns:**

```typescript
// Render prop contract
interface UserListProps {
  renderUser: (user: User) => ReactNode;
  renderEmpty?: () => ReactNode;
}

// Slot contract
interface DashboardProps {
  header: ReactNode;
  sidebar: ReactNode;
  content: ReactNode;
}

// Data contract
interface AnalyticsEvent {
  name: string;
  properties: Record<string, string | number | boolean>;
  timestamp: number;
}
```

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)

### 3.2 Enforce Feature Isolation

**Impact: HIGH (Changes in one feature have zero impact on others; enables fearless refactoring)**

Each feature should be modifiable, testable, and deployable without affecting other features. When features are isolated, refactoring is safe and localized. When they're coupled, every change risks cascading failures.

**Incorrect (coupled features):**

```typescript
// src/features/order/hooks/useOrder.ts
import { useCart } from '@/features/cart/hooks/useCart';
import { useUser } from '@/features/user/hooks/useUser';
import { usePayment } from '@/features/payment/hooks/usePayment';

export function useOrder() {
  const cart = useCart();
  const user = useUser();
  const payment = usePayment();

  // Tightly coupled to 3 other features
  // Change in any feature can break orders
  async function submitOrder() {
    const order = {
      items: cart.items,
      userId: user.id,
      paymentMethod: payment.selectedMethod,
    };
    // ...
  }
}
```

**Correct (isolated with dependency injection):**

```typescript
// src/features/order/hooks/useOrder.ts
interface OrderDependencies {
  items: CartItem[];
  userId: string;
  paymentMethod: PaymentMethod;
}

export function useOrder() {
  async function submitOrder(deps: OrderDependencies) {
    const order = {
      items: deps.items,
      userId: deps.userId,
      paymentMethod: deps.paymentMethod,
    };
    // ...
  }

  return { submitOrder };
}

// src/app/pages/CheckoutPage.tsx - composition at app layer
import { useCart } from '@/features/cart';
import { useUser } from '@/features/user';
import { usePayment } from '@/features/payment';
import { useOrder } from '@/features/order';

export function CheckoutPage() {
  const cart = useCart();
  const user = useUser();
  const payment = usePayment();
  const order = useOrder();

  const handleSubmit = () => {
    order.submitOrder({
      items: cart.items,
      userId: user.id,
      paymentMethod: payment.selectedMethod,
    });
  };
}
```

**Benefits:**
- Order feature can be tested with mock dependencies
- Cart, user, and payment can change without breaking orders
- Clear contract between features

Reference: [Feature-Sliced Design](https://feature-sliced.design/)

### 3.3 Keep Features Appropriately Sized

**Impact: MEDIUM (Right-sized features balance cohesion and manageability)**

Features should be large enough to be meaningful but small enough to be maintainable. A feature that's too small creates unnecessary fragmentation; one that's too large becomes a mini-monolith.

**Incorrect (too granular):**

```
src/features/
├── user-avatar/          # Too small - just one component
├── user-name/            # Too small
├── user-email/           # Too small
├── user-profile/         # Could contain all of these
└── user-settings/
```

**Incorrect (too large):**

```
src/features/
└── user/
    ├── components/
    │   ├── UserAvatar.tsx
    │   ├── UserProfile.tsx
    │   ├── UserSettings.tsx
    │   ├── UserOrders.tsx        # Orders is a separate domain
    │   ├── UserPayments.tsx      # Payments is a separate domain
    │   ├── UserSubscription.tsx  # Subscription is a separate domain
    │   └── ... 30 more files
    └── hooks/
        └── ... 20 hooks
```

**Correct (cohesive features):**

```
src/features/
├── user/                # Core user identity
│   ├── components/
│   │   ├── UserAvatar.tsx
│   │   ├── UserProfile.tsx
│   │   └── UserSettings.tsx
│   └── hooks/
│       └── useUser.ts
├── orders/              # Separate domain
│   ├── components/
│   │   ├── OrderList.tsx
│   │   └── OrderDetail.tsx
│   └── hooks/
│       └── useOrders.ts
├── payments/            # Separate domain
│   └── ...
└── subscription/        # Separate domain
    └── ...
```

**Sizing guidelines:**
- 5-15 components per feature is typical
- If a feature has 20+ files, consider splitting
- If a feature has only 1-2 files, consider merging
- Features should map to business domains, not UI components

**Signs a feature is too large:**
- Multiple developers frequently conflict in the same feature
- Parts of the feature change at different rates
- Some parts are used independently of others

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)

### 3.4 Minimize Shared State Between Features

**Impact: HIGH (Reduces coupling surface area; prevents state synchronization bugs)**

When multiple features share state, they become implicitly coupled. Changes to that state affect all dependent features. Prefer passing data as props or using feature-local state with explicit synchronization points.

**Incorrect (shared global state):**

```typescript
// src/stores/globalStore.ts
export const globalStore = create((set) => ({
  user: null,
  cart: { items: [] },
  notifications: [],
  theme: 'light',
  // Every feature reaches into this store
}));

// src/features/checkout/components/CheckoutForm.tsx
import { globalStore } from '@/stores/globalStore';

export function CheckoutForm() {
  const cart = globalStore(s => s.cart);
  const user = globalStore(s => s.user);
  // Checkout is now coupled to global store shape
}
```

**Correct (feature-scoped state with explicit boundaries):**

```typescript
// src/features/cart/stores/cartStore.ts
export const useCartStore = create((set) => ({
  items: [],
  addItem: (item) => set(s => ({ items: [...s.items, item] })),
  removeItem: (id) => set(s => ({ items: s.items.filter(i => i.id !== id) })),
}));

// src/features/cart/index.ts
export { useCartStore } from './stores/cartStore';
export type { CartItem } from './types';

// src/app/pages/CheckoutPage.tsx
import { useCartStore } from '@/features/cart';
import { CheckoutForm } from '@/features/checkout';

export function CheckoutPage() {
  const items = useCartStore(s => s.items);
  // App layer reads cart and passes to checkout
  return <CheckoutForm items={items} />;
}

// src/features/checkout/components/CheckoutForm.tsx
interface CheckoutFormProps {
  items: CartItem[];  // Receives data via props, not global state
}

export function CheckoutForm({ items }: CheckoutFormProps) {
  // No knowledge of cart store
}
```

**When shared state is acceptable:**
- Auth state (current user) - rarely changes, many features need it
- Theme/locale - application-wide concerns
- Feature flags - read-only, system-level

Reference: [Feature-Sliced Design](https://feature-sliced.design/)

### 3.5 Scope Routing to Feature Concerns

**Impact: HIGH (Enables feature-level code splitting; prevents routing configuration sprawl)**

Route definitions belong in the app layer, but route parameters and navigation logic relevant to a feature can be encapsulated within that feature. This keeps routing concerns organized while maintaining the app layer's ownership of the route tree.

**Incorrect (routing logic scattered):**

```typescript
// src/features/user/components/UserProfile.tsx
import { useNavigate, useParams } from 'react-router-dom';

export function UserProfile() {
  const navigate = useNavigate();
  const { userId } = useParams();  // Feature assumes route structure

  const goToSettings = () => {
    navigate(`/users/${userId}/settings`);  // Hardcoded route
  };
}
```

**Correct (feature owns its route utilities):**

```typescript
// src/features/user/routes.ts
export const userRoutes = {
  profile: (userId: string) => `/users/${userId}`,
  settings: (userId: string) => `/users/${userId}/settings`,
  orders: (userId: string) => `/users/${userId}/orders`,
} as const;

// src/features/user/hooks/useUserParams.ts
import { useParams } from 'react-router-dom';

export function useUserParams() {
  const { userId } = useParams<{ userId: string }>();
  if (!userId) throw new Error('userId is required');
  return { userId };
}

// src/features/user/components/UserProfile.tsx
import { useNavigate } from 'react-router-dom';
import { userRoutes } from '../routes';
import { useUserParams } from '../hooks/useUserParams';

export function UserProfile() {
  const navigate = useNavigate();
  const { userId } = useUserParams();

  const goToSettings = () => {
    navigate(userRoutes.settings(userId));  // Uses feature's route builder
  };
}

// src/app/routes/index.tsx
import { userRoutes } from '@/features/user';
import { UserProfile, UserSettings } from '@/features/user';

export const routes = [
  { path: userRoutes.profile(':userId'), element: <UserProfile /> },
  { path: userRoutes.settings(':userId'), element: <UserSettings /> },
];
```

**Benefits:**
- Route paths are centralized per feature
- Refactoring routes only requires changes in one place
- Type-safe route parameters

Reference: [Feature-Sliced Design](https://feature-sliced.design/)

### 3.6 Use Events for Cross-Feature Communication

**Impact: MEDIUM-HIGH (Decouples features at runtime; enables loose coupling without direct imports)**

When features must communicate without direct dependencies, use an event-based approach. This keeps features loosely coupled while allowing them to react to each other's actions.

**Incorrect (direct coupling):**

```typescript
// src/features/order/hooks/useOrder.ts
import { clearCart } from '@/features/cart/stores/cartStore';
import { showNotification } from '@/features/notification/stores/notificationStore';
import { sendAnalytics } from '@/features/analytics/utils/analytics';

export function useOrder() {
  async function submitOrder(data: OrderData) {
    const order = await createOrder(data);

    // Directly calling into other features
    clearCart();
    showNotification({ type: 'success', message: 'Order placed!' });
    sendAnalytics('order_completed', { orderId: order.id });
  }
}
```

**Correct (event-based communication):**

```typescript
// src/shared/events/eventBus.ts
type EventMap = {
  'order:completed': { orderId: string; total: number };
  'order:failed': { error: string };
  'user:logged-in': { userId: string };
  'user:logged-out': void;
};

export const eventBus = createEventBus<EventMap>();

// src/features/order/hooks/useOrder.ts
import { eventBus } from '@/shared/events/eventBus';

export function useOrder() {
  async function submitOrder(data: OrderData) {
    const order = await createOrder(data);
    eventBus.emit('order:completed', { orderId: order.id, total: order.total });
  }
}

// src/features/cart/hooks/useCartSync.ts
import { eventBus } from '@/shared/events/eventBus';
import { useCartStore } from '../stores/cartStore';

export function useCartSync() {
  useEffect(() => {
    return eventBus.on('order:completed', () => {
      useCartStore.getState().clearCart();
    });
  }, []);
}

// src/features/notification/hooks/useOrderNotifications.ts
import { eventBus } from '@/shared/events/eventBus';

export function useOrderNotifications() {
  useEffect(() => {
    return eventBus.on('order:completed', ({ orderId }) => {
      showNotification({ type: 'success', message: `Order ${orderId} placed!` });
    });
  }, []);
}
```

**Benefits:**
- Order feature doesn't know about cart, notifications, or analytics
- New features can subscribe to events without modifying order
- Easy to test each feature in isolation

Reference: [Feature-Sliced Design](https://feature-sliced.design/)

---

## 4. Data Fetching

**Impact: HIGH**

Keeps data logic domain-focused and prevents N+1 query patterns that multiply as features grow.

### 4.1 Avoid N+1 Query Patterns

**Impact: HIGH (Prevents request count from scaling with data size; eliminates O(N) network calls)**

N+1 queries occur when you fetch a list and then individually fetch related data for each item. This creates N+1 requests instead of 2, causing performance to degrade with data growth.

**Incorrect (N+1 pattern):**

```typescript
// 1 request for posts + N requests for authors = N+1 total
export async function PostList() {
  const posts = await getPosts();  // 1 request

  // N additional requests!
  const postsWithAuthors = await Promise.all(
    posts.map(async (post) => ({
      ...post,
      author: await getUser(post.authorId),  // 1 request per post
    }))
  );

  return postsWithAuthors.map(post => <PostCard post={post} />);
}
```

**Correct (batched query):**

```typescript
// src/features/user/api/get-users-by-ids.ts
export async function getUsersByIds(ids: string[]) {
  return prisma.user.findMany({
    where: { id: { in: ids } },
  });
}

// 2 requests total regardless of post count
export async function PostList() {
  const posts = await getPosts();  // 1 request

  const authorIds = [...new Set(posts.map(p => p.authorId))];
  const authors = await getUsersByIds(authorIds);  // 1 request
  const authorsById = new Map(authors.map(a => [a.id, a]));

  const postsWithAuthors = posts.map(post => ({
    ...post,
    author: authorsById.get(post.authorId),
  }));

  return postsWithAuthors.map(post => <PostCard post={post} />);
}
```

**Alternative: Lazy load where appropriate:**

```typescript
// If authors are rarely viewed, lazy load on demand
export function PostCard({ post }: { post: Post }) {
  const [showAuthor, setShowAuthor] = useState(false);

  return (
    <article>
      <h2>{post.title}</h2>
      <button onClick={() => setShowAuthor(true)}>Show Author</button>
      {showAuthor && <AuthorInfo userId={post.authorId} />}
    </article>
  );
}
```

**When to accept N+1:**
- N is always small (< 5 items)
- Data is heavily cached and cache hits are near 100%
- Lazy loading is appropriate (user rarely views related data)

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)

### 4.2 Colocate Data Fetching with Features

**Impact: HIGH (Makes features self-contained; enables independent API evolution)**

Data fetching logic belongs within the feature that owns the data. When API calls are scattered in a central api/ folder, features lose independence and changes require coordinating across multiple locations.

**Incorrect (centralized API layer):**

```
src/
├── api/
│   ├── users.ts         # All user API calls
│   ├── posts.ts         # All post API calls
│   ├── comments.ts      # All comment API calls
│   └── orders.ts        # All order API calls
└── features/
    ├── user/
    │   └── components/  # Components import from ../../../api/users
    └── post/
        └── components/  # Components import from ../../../api/posts
```

**Correct (colocated with features):**

```
src/features/
├── user/
│   ├── api/
│   │   ├── get-user.ts
│   │   ├── update-user.ts
│   │   └── delete-user.ts
│   ├── components/
│   │   └── UserProfile.tsx
│   └── hooks/
│       └── useUser.ts
└── post/
    ├── api/
    │   ├── get-post.ts
    │   ├── get-posts.ts
    │   └── create-post.ts
    ├── components/
    │   └── PostList.tsx
    └── hooks/
        └── usePosts.ts
```

```typescript
// src/features/user/hooks/useUser.ts
import { getUser } from '../api/get-user';

export function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => getUser(userId),
  });
}
```

**Benefits:**
- Adding a feature includes its API calls
- Removing a feature removes its API calls
- Feature can evolve its API independently
- Related code is always together

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)

### 4.3 Fetch at Server Component Level

**Impact: MEDIUM-HIGH (Eliminates client-server waterfalls; reduces bundle size by keeping fetch logic on server)**

In React Server Component architectures, fetch data in server components and pass to client components as props. This eliminates client-server waterfalls and keeps data fetching off the client bundle.

**Incorrect (client component fetching):**

```typescript
// src/features/post/components/PostPage.tsx
'use client';

export function PostPage({ postId }: { postId: string }) {
  const [post, setPost] = useState<Post | null>(null);

  useEffect(() => {
    fetch(`/api/posts/${postId}`)  // Client-server waterfall
      .then(res => res.json())
      .then(setPost);
  }, [postId]);

  if (!post) return <Loading />;
  return <PostContent post={post} />;
}
```

**Correct (server component fetching):**

```typescript
// src/features/post/components/PostPage.tsx (Server Component)
import { getPost } from '../api/get-post';
import { PostContent } from './PostContent';  // Client component

export async function PostPage({ postId }: { postId: string }) {
  const post = await getPost(postId);  // Fetches on server

  return <PostContent post={post} />;
}

// src/features/post/components/PostContent.tsx
'use client';

interface PostContentProps {
  post: Post;  // Receives data as props, no fetching
}

export function PostContent({ post }: PostContentProps) {
  const [likes, setLikes] = useState(post.likes);

  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
      <LikeButton likes={likes} onLike={() => setLikes(l => l + 1)} />
    </article>
  );
}
```

**Composition pattern:**

```typescript
// src/app/posts/[id]/page.tsx (Server Component)
import { PostPage } from '@/features/post';
import { Comments } from '@/features/comment';

export default async function Page({ params }: { params: { id: string } }) {
  // Parallel fetch at app layer
  const [post, comments] = await Promise.all([
    getPost(params.id),
    getComments(params.id),
  ]);

  return (
    <>
      <PostPage post={post} />
      <Comments comments={comments} />
    </>
  );
}
```

Reference: [Next.js - Data Fetching](https://nextjs.org/docs/app/building-your-application/data-fetching)

### 4.4 Fetch Independent Data in Parallel

**Impact: HIGH (Reduces total load time by ~50% for pages with multiple data sources)**

When a component needs multiple pieces of unrelated data, fetch them in parallel using Promise.all(). Sequential fetching creates waterfalls where total time equals the sum of all requests.

**Incorrect (sequential waterfall):**

```typescript
// Each request waits for the previous one
// Total time: 200ms + 150ms + 100ms = 450ms
export async function DashboardPage() {
  const user = await getUser(userId);        // 200ms
  const orders = await getOrders(userId);    // 150ms
  const notifications = await getNotifications(userId);  // 100ms

  return <Dashboard user={user} orders={orders} notifications={notifications} />;
}
```

**Correct (parallel fetching):**

```typescript
// All requests start simultaneously
// Total time: max(200ms, 150ms, 100ms) = 200ms
export async function DashboardPage() {
  const [user, orders, notifications] = await Promise.all([
    getUser(userId),           // 200ms
    getOrders(userId),         // 150ms
    getNotifications(userId),  // 100ms
  ]);

  return <Dashboard user={user} orders={orders} notifications={notifications} />;
}
```

**With React Query:**

```typescript
// src/app/pages/DashboardPage.tsx
export function DashboardPage({ userId }: { userId: string }) {
  // These queries run in parallel automatically
  const userQuery = useUser(userId);
  const ordersQuery = useOrders(userId);
  const notificationsQuery = useNotifications(userId);

  if (userQuery.isLoading || ordersQuery.isLoading || notificationsQuery.isLoading) {
    return <Loading />;
  }

  return (
    <Dashboard
      user={userQuery.data}
      orders={ordersQuery.data}
      notifications={notificationsQuery.data}
    />
  );
}
```

**When sequential is necessary:**
- Second request depends on first request's result
- Rate limiting requires throttled requests
- User must complete a step before seeing next data

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)

### 4.5 Keep Query Functions Single-Purpose

**Impact: HIGH (Prevents query permutation explosion as features grow)**

Each query function should fetch one type of data. Avoid creating variations that combine multiple concerns. When features need combined data, fetch separately and compose at the component level.

**Incorrect (query permutations):**

```typescript
// src/features/post/api/queries.ts

// Creates combinatorial explosion as requirements grow
export async function getPost(id: string) { ... }
export async function getPostWithComments(id: string) { ... }
export async function getPostWithAuthor(id: string) { ... }
export async function getPostWithCommentsAndAuthor(id: string) { ... }
export async function getPostWithCommentsAndAuthorAndLikes(id: string) { ... }
// N relations = 2^N possible combinations
```

**Correct (single-purpose queries):**

```typescript
// src/features/post/api/get-post.ts
export async function getPost(id: string) {
  return prisma.post.findUnique({ where: { id } });
}

// src/features/comment/api/get-comments.ts
export async function getComments(postId: string) {
  return prisma.comment.findMany({ where: { postId } });
}

// src/features/user/api/get-user.ts
export async function getUser(id: string) {
  return prisma.user.findUnique({ where: { id } });
}

// Component composes what it needs
export async function PostPage({ postId }: { postId: string }) {
  const [post, comments] = await Promise.all([
    getPost(postId),
    getComments(postId),
  ]);

  return (
    <article>
      <PostContent post={post} />
      <CommentList comments={comments} />
    </article>
  );
}
```

**Benefits:**
- Linear growth: N relations = N query functions
- Each query is independently cacheable
- Parallel fetching via Promise.all()
- Each feature owns its own data fetching

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)

### 4.6 Use Feature-Scoped Query Keys

**Impact: MEDIUM-HIGH (Enables targeted cache invalidation; prevents accidental cache collisions)**

Query keys should be hierarchical with the feature name as the root. This enables precise cache invalidation and prevents key collisions between features.

**Incorrect (flat, collision-prone keys):**

```typescript
// src/features/user/hooks/useUser.ts
useQuery({ queryKey: ['user', userId], ... });

// src/features/admin/hooks/useUser.ts
useQuery({ queryKey: ['user', userId], ... });  // Collides with above!

// Hard to invalidate all user queries
queryClient.invalidateQueries({ queryKey: ['user'] });  // Might affect admin too
```

**Correct (feature-scoped key factory):**

```typescript
// src/features/user/query-keys.ts
export const userKeys = {
  all: ['user'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

// src/features/user/hooks/useUser.ts
import { userKeys } from '../query-keys';

export function useUser(userId: string) {
  return useQuery({
    queryKey: userKeys.detail(userId),
    queryFn: () => getUser(userId),
  });
}

// src/features/admin/query-keys.ts
export const adminUserKeys = {
  all: ['admin', 'user'] as const,
  detail: (id: string) => [...adminUserKeys.all, 'detail', id] as const,
};
```

**Invalidation patterns:**

```typescript
// Invalidate all user data
queryClient.invalidateQueries({ queryKey: userKeys.all });

// Invalidate only user lists (not details)
queryClient.invalidateQueries({ queryKey: userKeys.lists() });

// Invalidate specific user
queryClient.invalidateQueries({ queryKey: userKeys.detail(userId) });
```

**Benefits:**
- Clear ownership of cache keys
- Predictable invalidation scope
- No accidental cross-feature cache interference

Reference: [TanStack Query - Query Keys](https://tanstack.com/query/latest/docs/framework/react/guides/query-keys)

---

## 5. Component Organization

**Impact: MEDIUM-HIGH**

Single-responsibility components enable parallel development and isolated testing.

### 5.1 Apply Single Responsibility to Components

**Impact: MEDIUM-HIGH (Enables parallel development and isolated testing; reduces component complexity)**

Each component should do one thing well. When a component handles multiple concerns (rendering, data fetching, business logic), it becomes hard to test, reuse, and maintain. Split into focused components.

**Incorrect (multiple responsibilities):**

```typescript
// src/features/post/components/Post.tsx
export function Post({ postId }: { postId: string }) {
  // Data fetching
  const [post, setPost] = useState<Post | null>(null);
  const [comments, setComments] = useState<Comment[]>([]);

  useEffect(() => {
    fetchPost(postId).then(setPost);
    fetchComments(postId).then(setComments);
  }, [postId]);

  // Business logic
  const handleLike = async () => { ... };
  const handleComment = async () => { ... };

  // Rendering post AND comments AND forms
  return (
    <div>
      <h1>{post?.title}</h1>
      <p>{post?.content}</p>
      <button onClick={handleLike}>Like</button>
      <ul>
        {comments.map(c => <li key={c.id}>{c.text}</li>)}
      </ul>
      <CommentForm onSubmit={handleComment} />
    </div>
  );
}
```

**Correct (single responsibility each):**

```typescript
// src/features/post/components/PostContent.tsx
interface PostContentProps {
  post: Post;
  onLike: () => void;
}

export function PostContent({ post, onLike }: PostContentProps) {
  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
      <LikeButton count={post.likes} onClick={onLike} />
    </article>
  );
}

// src/features/comment/components/CommentList.tsx
interface CommentListProps {
  comments: Comment[];
}

export function CommentList({ comments }: CommentListProps) {
  return (
    <ul>
      {comments.map(c => <CommentItem key={c.id} comment={c} />)}
    </ul>
  );
}

// src/app/posts/[id]/page.tsx (composition at app layer)
export async function PostPage({ postId }: { postId: string }) {
  const [post, comments] = await Promise.all([
    getPost(postId),
    getComments(postId),
  ]);

  return (
    <>
      <PostContent post={post} onLike={() => likePost(postId)} />
      <CommentList comments={comments} />
      <CommentForm postId={postId} />
    </>
  );
}
```

**Benefits:**
- PostContent can be tested without comments
- CommentList can be reused elsewhere
- Each component is ~20-50 lines, easy to understand

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)

### 5.2 Colocate Styles with Components

**Impact: MEDIUM (Enables complete component portability; prevents orphaned styles)**

Keep component styles in the same location as the component. When styles are centralized or in a global stylesheet, components lose independence and style changes become risky.

**Incorrect (centralized styles):**

```
src/
├── styles/
│   ├── components/
│   │   ├── UserCard.css
│   │   ├── PostList.css
│   │   └── CommentSection.css
│   └── global.css
└── features/
    └── user/
        └── components/
            └── UserCard.tsx  # Imports from ../../styles/components/
```

**Correct (colocated styles):**

```
src/features/user/
├── components/
│   ├── UserCard.tsx
│   ├── UserCard.module.css   # CSS Modules
│   └── UserAvatar.tsx
└── ...
```

```typescript
// src/features/user/components/UserCard.tsx
import styles from './UserCard.module.css';

export function UserCard({ user }: { user: User }) {
  return (
    <div className={styles.card}>
      <UserAvatar user={user} className={styles.avatar} />
      <h2 className={styles.name}>{user.name}</h2>
    </div>
  );
}
```

**With Tailwind (styles in component):**

```typescript
// src/features/user/components/UserCard.tsx
export function UserCard({ user }: { user: User }) {
  return (
    <div className="rounded-lg border bg-white p-4 shadow-sm">
      <UserAvatar user={user} className="h-12 w-12 rounded-full" />
      <h2 className="mt-2 text-lg font-semibold">{user.name}</h2>
    </div>
  );
}
```

**Shared styles belong in shared:**

```
src/shared/
├── styles/
│   ├── reset.css         # Global reset
│   └── variables.css     # Design tokens
└── components/
    ├── Button/
    │   ├── Button.tsx
    │   └── Button.module.css
    └── Input/
        ├── Input.tsx
        └── Input.module.css
```

**Benefits:**
- Moving a component moves its styles
- Deleting a component deletes its styles
- No orphaned CSS

Reference: [CSS Modules Documentation](https://github.com/css-modules/css-modules)

### 5.3 Prefer Composition Over Prop Drilling

**Impact: MEDIUM-HIGH (Eliminates prop drilling; enables flexible slot-based component design)**

When components need to render content from different features, use composition (children, render props, slots) instead of passing data down through multiple layers. This keeps components decoupled and flexible.

**Incorrect (prop drilling):**

```typescript
// Props must pass through every layer
function Page({ user, cart, notifications }) {
  return <Layout user={user} cart={cart} notifications={notifications} />;
}

function Layout({ user, cart, notifications }) {
  return (
    <div>
      <Header user={user} cart={cart} notifications={notifications} />
      <Content />
    </div>
  );
}

function Header({ user, cart, notifications }) {
  return (
    <header>
      <UserMenu user={user} />
      <CartIcon cart={cart} />
      <NotificationBell notifications={notifications} />
    </header>
  );
}
```

**Correct (composition with slots):**

```typescript
// Layout accepts composed children
interface LayoutProps {
  header: ReactNode;
  children: ReactNode;
}

function Layout({ header, children }: LayoutProps) {
  return (
    <div>
      <header>{header}</header>
      <main>{children}</main>
    </div>
  );
}

// Page composes features at the top level
function Page() {
  return (
    <Layout
      header={
        <>
          <UserMenu />      {/* Feature handles its own data */}
          <CartIcon />      {/* Feature handles its own data */}
          <NotificationBell /> {/* Feature handles its own data */}
        </>
      }
    >
      <MainContent />
    </Layout>
  );
}
```

**Render props for flexible rendering:**

```typescript
interface DataTableProps<T> {
  data: T[];
  renderRow: (item: T) => ReactNode;
  renderEmpty?: () => ReactNode;
}

function DataTable<T>({ data, renderRow, renderEmpty }: DataTableProps<T>) {
  if (data.length === 0) {
    return renderEmpty?.() ?? <EmptyState />;
  }
  return <table><tbody>{data.map(renderRow)}</tbody></table>;
}

// Usage - feature controls rendering
<DataTable
  data={users}
  renderRow={(user) => <UserRow user={user} />}
  renderEmpty={() => <NoUsersMessage />}
/>
```

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)

### 5.4 Separate Container and Presentational Concerns

**Impact: MEDIUM (Enables design system reuse; keeps business logic testable)**

Distinguish between components that manage data/state (containers) and components that render UI (presentational). Presentational components are reusable and easy to test; containers coordinate business logic.

**Incorrect (mixed concerns):**

```typescript
// Component does everything - hard to reuse or test
function UserCard() {
  const [user, setUser] = useState<User | null>(null);
  const [isEditing, setIsEditing] = useState(false);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  const handleSave = async (data: UserData) => {
    await updateUser(userId, data);
    setUser({ ...user, ...data });
    setIsEditing(false);
  };

  if (!user) return <Loading />;

  return (
    <div className="card">
      {isEditing ? (
        <UserForm user={user} onSave={handleSave} />
      ) : (
        <>
          <Avatar src={user.avatar} />
          <h2>{user.name}</h2>
          <p>{user.email}</p>
          <button onClick={() => setIsEditing(true)}>Edit</button>
        </>
      )}
    </div>
  );
}
```

**Correct (separated concerns):**

```typescript
// Presentational - pure rendering, easy to test and reuse
interface UserCardProps {
  user: User;
  onEdit: () => void;
}

function UserCard({ user, onEdit }: UserCardProps) {
  return (
    <div className="card">
      <Avatar src={user.avatar} />
      <h2>{user.name}</h2>
      <p>{user.email}</p>
      <button onClick={onEdit}>Edit</button>
    </div>
  );
}

// Container - manages data and state
function UserCardContainer({ userId }: { userId: string }) {
  const { data: user, isLoading } = useUser(userId);
  const [isEditing, setIsEditing] = useState(false);
  const updateMutation = useUpdateUser();

  if (isLoading) return <UserCardSkeleton />;

  if (isEditing) {
    return (
      <UserForm
        user={user}
        onSave={(data) => {
          updateMutation.mutate({ userId, data });
          setIsEditing(false);
        }}
        onCancel={() => setIsEditing(false)}
      />
    );
  }

  return <UserCard user={user} onEdit={() => setIsEditing(true)} />;
}
```

**Benefits:**
- UserCard can be used in Storybook, tests, anywhere
- Business logic is concentrated in container
- Presentational components are pure functions of props

Reference: [React Patterns - Container/Presentational](https://reactpatterns.com/)

### 5.5 Use Feature-Level Error Boundaries

**Impact: MEDIUM (Isolates failures to single features; prevents full-page crashes)**

Wrap each feature's root component in an error boundary. When a feature fails, only that feature shows an error state while the rest of the page remains functional.

**Incorrect (single app-level boundary):**

```typescript
// Single error boundary - any feature crash takes down entire app
function App() {
  return (
    <ErrorBoundary fallback={<FullPageError />}>
      <Dashboard />
    </ErrorBoundary>
  );
}

function Dashboard() {
  return (
    <div>
      <UserProfile />     {/* Crash here = full page error */}
      <RecentOrders />
      <Notifications />
    </div>
  );
}
```

**Correct (feature-level boundaries):**

```typescript
// src/shared/components/FeatureErrorBoundary.tsx
interface FeatureErrorBoundaryProps {
  feature: string;
  children: ReactNode;
  fallback?: ReactNode;
}

export function FeatureErrorBoundary({
  feature,
  children,
  fallback,
}: FeatureErrorBoundaryProps) {
  return (
    <ErrorBoundary
      fallback={fallback ?? <FeatureErrorFallback feature={feature} />}
      onError={(error) => logError(error, { feature })}
    >
      {children}
    </ErrorBoundary>
  );
}

// src/app/pages/DashboardPage.tsx
function Dashboard() {
  return (
    <div>
      <FeatureErrorBoundary feature="user-profile">
        <UserProfile />  {/* Crash here = only this section shows error */}
      </FeatureErrorBoundary>

      <FeatureErrorBoundary feature="recent-orders">
        <RecentOrders />  {/* Still works even if UserProfile crashed */}
      </FeatureErrorBoundary>

      <FeatureErrorBoundary feature="notifications">
        <Notifications />  {/* Still works */}
      </FeatureErrorBoundary>
    </div>
  );
}
```

**Graceful fallback UI:**

```typescript
function FeatureErrorFallback({ feature }: { feature: string }) {
  return (
    <div className="rounded border border-red-200 bg-red-50 p-4">
      <p className="text-red-800">
        Unable to load {feature}. <button onClick={retry}>Try again</button>
      </p>
    </div>
  );
}
```

**Benefits:**
- One feature failing doesn't crash the page
- Errors are attributed to specific features
- Users can continue using working features

Reference: [React Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)

### 5.6 Use Props as Feature Boundaries

**Impact: MEDIUM-HIGH (Creates clear interfaces between features; enables feature composition)**

When features interact, use props to define the interface. The receiving component should not know about the providing feature's internals. This creates a clear boundary that allows either side to change independently.

**Incorrect (feature internals exposed):**

```typescript
// Checkout component knows about Cart's internal structure
import { useCartStore } from '@/features/cart/stores/cartStore';

function CheckoutSummary() {
  // Directly accessing cart's internal state structure
  const items = useCartStore(s => s.items);
  const appliedCoupons = useCartStore(s => s.coupons);
  const shippingMethod = useCartStore(s => s.shipping.method);

  // If cart store changes structure, this breaks
  return <div>...</div>;
}
```

**Correct (props as boundary):**

```typescript
// Define explicit interface for what checkout needs
interface CheckoutSummaryProps {
  items: Array<{
    id: string;
    name: string;
    price: number;
    quantity: number;
  }>;
  subtotal: number;
  discount: number;
  shipping: number;
  total: number;
}

function CheckoutSummary({ items, subtotal, discount, shipping, total }: CheckoutSummaryProps) {
  // Component only knows about its props, not cart internals
  return (
    <div>
      {items.map(item => (
        <LineItem key={item.id} item={item} />
      ))}
      <Subtotal amount={subtotal} />
      {discount > 0 && <Discount amount={discount} />}
      <Shipping amount={shipping} />
      <Total amount={total} />
    </div>
  );
}

// App layer transforms cart state to checkout props
function CheckoutPage() {
  const cart = useCartStore();

  // Transformation happens at composition point
  const summaryProps = {
    items: cart.items.map(i => ({
      id: i.id,
      name: i.product.name,
      price: i.product.price,
      quantity: i.quantity,
    })),
    subtotal: cart.getSubtotal(),
    discount: cart.getDiscount(),
    shipping: cart.getShippingCost(),
    total: cart.getTotal(),
  };

  return <CheckoutSummary {...summaryProps} />;
}
```

**Benefits:**
- CheckoutSummary doesn't import from cart feature
- Cart can restructure without breaking checkout
- CheckoutSummary is easily testable with mock props

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)

---

## 6. State Management

**Impact: MEDIUM**

Feature-scoped state prevents global coupling and enables features to be developed independently.

### 6.1 Lift State Only as High as Necessary

**Impact: MEDIUM (Reduces re-renders; keeps state close to where it's used)**

State should live in the lowest common ancestor of components that need it. Lifting state too high causes unnecessary re-renders and makes the state's purpose unclear.

**Incorrect (state lifted too high):**

```typescript
// State in app root - causes full tree re-render on every keystroke
function App() {
  const [searchQuery, setSearchQuery] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');
  const [selectedTab, setSelectedTab] = useState('all');

  return (
    <div>
      <Header />
      <Sidebar selectedTab={selectedTab} onSelectTab={setSelectedTab} />
      <ProductList
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
        sortOrder={sortOrder}
        onSortChange={setSortOrder}
      />
      <Footer />  {/* Re-renders on every search keystroke */}
    </div>
  );
}
```

**Correct (state at lowest necessary level):**

```typescript
function App() {
  return (
    <div>
      <Header />
      <MainContent />
      <Footer />  {/* Never re-renders due to search/sort */}
    </div>
  );
}

function MainContent() {
  const [selectedTab, setSelectedTab] = useState('all');

  return (
    <>
      <Sidebar selectedTab={selectedTab} onSelectTab={setSelectedTab} />
      <ProductList selectedTab={selectedTab} />
    </>
  );
}

function ProductList({ selectedTab }: { selectedTab: string }) {
  // Search and sort state only affects ProductList subtree
  const [searchQuery, setSearchQuery] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');

  return (
    <div>
      <SearchInput value={searchQuery} onChange={setSearchQuery} />
      <SortDropdown value={sortOrder} onChange={setSortOrder} />
      <ProductGrid tab={selectedTab} search={searchQuery} sort={sortOrder} />
    </div>
  );
}
```

**Decision guide:**

| Situation | Where to put state |
|-----------|-------------------|
| Single component uses it | In that component |
| Sibling components share it | In parent |
| Distant components share it | Context or store |
| Server data | Query library |

Reference: [React Docs - Sharing State](https://react.dev/learn/sharing-state-between-components)

### 6.2 Reset Feature State on Unmount

**Impact: MEDIUM (Prevents stale state bugs; ensures clean feature initialization)**

When a feature unmounts, reset its state to prevent stale data from appearing when the feature remounts. Persistent stores can cause bugs when users navigate away and back.

**Incorrect (stale state persists):**

```typescript
// User views checkout, abandons, browses, returns to checkout
// Sees old form data from previous session
const useCheckoutStore = create((set) => ({
  shippingAddress: null,
  paymentMethod: null,
  setShipping: (addr) => set({ shippingAddress: addr }),
}));

function CheckoutPage() {
  const { shippingAddress } = useCheckoutStore();
  // shippingAddress still has old data from previous visit
  return <CheckoutForm defaultAddress={shippingAddress} />;
}
```

**Correct (reset on unmount):**

```typescript
// src/features/checkout/stores/checkoutStore.ts
const initialState = {
  shippingAddress: null,
  paymentMethod: null,
  step: 1,
};

export const useCheckoutStore = create((set) => ({
  ...initialState,
  setShipping: (addr) => set({ shippingAddress: addr }),
  setPayment: (method) => set({ paymentMethod: method }),
  nextStep: () => set(s => ({ step: s.step + 1 })),
  reset: () => set(initialState),
}));

// src/features/checkout/components/CheckoutPage.tsx
function CheckoutPage() {
  const reset = useCheckoutStore(s => s.reset);

  useEffect(() => {
    // Reset when leaving checkout
    return () => reset();
  }, [reset]);

  return <CheckoutForm />;
}
```

**Alternative: Feature-scoped store instance:**

```typescript
// src/features/checkout/CheckoutProvider.tsx
const CheckoutContext = createContext<CheckoutStore | null>(null);

export function CheckoutProvider({ children }) {
  // New store instance created each mount
  const storeRef = useRef<CheckoutStore>();
  if (!storeRef.current) {
    storeRef.current = createCheckoutStore();
  }

  return (
    <CheckoutContext.Provider value={storeRef.current}>
      {children}
    </CheckoutContext.Provider>
  );
}

// Store is automatically fresh on each mount
```

**When NOT to reset:**
- User preferences (theme, language)
- Draft content (auto-saved forms)
- Explicitly preserved state (shopping cart)

Reference: [Zustand - Resetting State](https://zustand-demo.pmnd.rs/)

### 6.3 Scope State Stores to Features

**Impact: MEDIUM (Prevents global state coupling; enables feature-level state reset and testing)**

Each feature should own its state store. When state is global, features become coupled through shared state, making them impossible to develop, test, or remove independently.

**Incorrect (global monolithic store):**

```typescript
// src/stores/store.ts
export const useStore = create((set) => ({
  // User feature state
  user: null,
  userLoading: false,
  setUser: (user) => set({ user }),

  // Cart feature state
  cartItems: [],
  addToCart: (item) => set(s => ({ cartItems: [...s.cartItems, item] })),

  // Notification feature state
  notifications: [],
  addNotification: (n) => set(s => ({ notifications: [...s.notifications, n] })),

  // Everything mixed together - impossible to isolate
}));
```

**Correct (feature-scoped stores):**

```typescript
// src/features/user/stores/userStore.ts
export const useUserStore = create((set) => ({
  user: null,
  isLoading: false,
  setUser: (user) => set({ user }),
  clearUser: () => set({ user: null }),
}));

// src/features/cart/stores/cartStore.ts
export const useCartStore = create((set) => ({
  items: [],
  addItem: (item) => set(s => ({ items: [...s.items, item] })),
  removeItem: (id) => set(s => ({ items: s.items.filter(i => i.id !== id) })),
  clearCart: () => set({ items: [] }),
}));

// src/features/notification/stores/notificationStore.ts
export const useNotificationStore = create((set) => ({
  notifications: [],
  add: (n) => set(s => ({ notifications: [...s.notifications, n] })),
  dismiss: (id) => set(s => ({
    notifications: s.notifications.filter(n => n.id !== id),
  })),
}));
```

**Feature exposes store via public API:**

```typescript
// src/features/cart/index.ts
export { useCartStore } from './stores/cartStore';
export type { CartItem } from './types';

// Other features use the exported store
import { useCartStore } from '@/features/cart';
```

**Benefits:**
- Feature can be removed along with its store
- Tests can reset feature state independently
- Clear ownership of state

Reference: [Feature-Sliced Design](https://feature-sliced.design/)

### 6.4 Separate Server State from Client State

**Impact: MEDIUM (Eliminates manual cache sync; leverages query library optimizations)**

Server state (data from API) and client state (UI state, form state) have different characteristics. Server state should be managed by a query library; client state by local state or stores. Mixing them leads to stale data and sync bugs.

**Incorrect (server state in client store):**

```typescript
// src/stores/userStore.ts
export const useUserStore = create((set) => ({
  users: [],
  isLoading: false,

  // Manual fetching logic
  fetchUsers: async () => {
    set({ isLoading: true });
    const users = await api.getUsers();
    set({ users, isLoading: false });
  },

  // Manual cache invalidation
  invalidate: () => {
    // How do we know when to refetch?
    // What about stale data?
    // What about deduplication?
  },
}));
```

**Correct (server state in query library):**

```typescript
// src/features/user/hooks/useUsers.ts
// Server state - managed by TanStack Query
export function useUsers(filters: UserFilters) {
  return useQuery({
    queryKey: userKeys.list(filters),
    queryFn: () => getUsers(filters),
    staleTime: 60_000,  // Built-in cache management
  });
}

// src/features/user/stores/userUIStore.ts
// Client state - UI-only concerns
export const useUserUIStore = create((set) => ({
  selectedUserId: null,
  filterPanelOpen: false,
  sortOrder: 'asc' as const,

  selectUser: (id) => set({ selectedUserId: id }),
  toggleFilterPanel: () => set(s => ({ filterPanelOpen: !s.filterPanelOpen })),
  setSortOrder: (order) => set({ sortOrder: order }),
}));
```

**Usage:**

```typescript
function UserListPage() {
  // Server state
  const { data: users, isLoading } = useUsers({ active: true });

  // Client state
  const { selectedUserId, selectUser, sortOrder } = useUserUIStore();

  const sortedUsers = useMemo(() =>
    [...(users ?? [])].sort((a, b) =>
      sortOrder === 'asc' ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name)
    ),
    [users, sortOrder]
  );

  return <UserList users={sortedUsers} selected={selectedUserId} onSelect={selectUser} />;
}
```

**Server state characteristics:**
- Fetched from external source
- Can become stale
- Needs refetching, deduplication, caching

**Client state characteristics:**
- Created locally
- Never stale (source of truth is client)
- No network concerns

Reference: [TanStack Query - Overview](https://tanstack.com/query/latest/docs/framework/react/overview)

### 6.5 Use Context Sparingly for Feature State

**Impact: MEDIUM (Prevents context re-render cascades; keeps features portable)**

Context is useful for dependency injection and app-wide configuration, but causes re-render cascades when used for frequently-changing state. Prefer feature stores or local state for dynamic data.

**Incorrect (frequently changing data in context):**

```typescript
// Every context consumer re-renders on any cart change
const CartContext = createContext<CartContextValue | null>(null);

function CartProvider({ children }) {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);

  const addItem = (item) => {
    setItems([...items, item]);  // Re-renders all consumers
    setTotal(total + item.price);
  };

  return (
    <CartContext.Provider value={{ items, total, addItem }}>
      {children}  {/* Every consumer re-renders */}
    </CartContext.Provider>
  );
}

// Components re-render even if they only use `total`
function CartIcon() {
  const { total } = useContext(CartContext);  // Re-renders when items change
  return <span>{total}</span>;
}
```

**Correct (store with selectors):**

```typescript
// src/features/cart/stores/cartStore.ts
export const useCartStore = create((set, get) => ({
  items: [],
  addItem: (item) => set(s => ({ items: [...s.items, item] })),
  getTotal: () => get().items.reduce((sum, i) => sum + i.price, 0),
}));

// Only re-renders when selected state changes
function CartIcon() {
  const total = useCartStore(s => s.items.reduce((sum, i) => sum + i.price, 0));
  return <span>{total}</span>;
}

function CartItemCount() {
  const count = useCartStore(s => s.items.length);  // Only re-renders when count changes
  return <span>{count}</span>;
}
```

**When context is appropriate:**
- Dependency injection (API client, auth)
- Theme/locale (changes rarely)
- Feature flags (read-only)

**When to use stores:**
- Frequently updating state
- Multiple components need different slices
- Need fine-grained subscriptions

Reference: [Zustand Documentation](https://zustand-demo.pmnd.rs/)

---

## 7. Testing Strategy

**Impact: MEDIUM**

Feature isolation enables faster test execution and clearer failure attribution.

### 7.1 Colocate Tests with Features

**Impact: MEDIUM (Makes test coverage visible; ensures tests move with features)**

Tests should live in the same feature folder as the code they test. When tests are in a separate tests/ folder, they become disconnected from the code, leading to missing coverage and orphaned tests.

**Incorrect (centralized test folder):**

```
src/
├── features/
│   ├── user/
│   │   └── components/
│   │       └── UserProfile.tsx
│   └── cart/
│       └── hooks/
│           └── useCart.ts
└── tests/              # Disconnected from features
    ├── user/
    │   └── UserProfile.test.tsx
    └── cart/
        └── useCart.test.ts
```

**Correct (colocated tests):**

```
src/features/
├── user/
│   ├── components/
│   │   ├── UserProfile.tsx
│   │   └── __tests__/
│   │       └── UserProfile.test.tsx
│   └── hooks/
│       ├── useUser.ts
│       └── __tests__/
│           └── useUser.test.ts
└── cart/
    ├── hooks/
    │   ├── useCart.ts
    │   └── __tests__/
    │       └── useCart.test.ts
    └── api/
        ├── get-cart.ts
        └── __tests__/
            └── get-cart.test.ts
```

**Alternative: Adjacent files:**

```
src/features/user/components/
├── UserProfile.tsx
└── UserProfile.test.tsx   # Same folder, no __tests__ subfolder
```

**Benefits:**
- Moving a feature moves its tests
- Deleting a feature deletes its tests
- Test coverage is visible in the feature folder
- Easy to see what's tested at a glance

**vitest.config.ts:**

```typescript
export default defineConfig({
  test: {
    include: ['src/**/*.test.{ts,tsx}'],
  },
});
```

Reference: [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)

### 7.2 Create Feature-Specific Test Utilities

**Impact: MEDIUM (Reduces test boilerplate; ensures consistent test setup)**

Each feature should have its own test utilities: factories, fixtures, and render wrappers. Shared test utilities become coupled to all features and are hard to maintain.

**Incorrect (global test utilities):**

```typescript
// src/testing/utils.ts - One file for all features
export function createMockUser() { ... }
export function createMockProduct() { ... }
export function createMockOrder() { ... }
export function renderWithProviders(ui: ReactNode) {
  return render(ui, {
    wrapper: ({ children }) => (
      <QueryClientProvider client={queryClient}>
        <UserProvider>
          <CartProvider>
            <NotificationProvider>
              {children}
            </NotificationProvider>
          </CartProvider>
        </UserProvider>
      </QueryClientProvider>
    ),
  });
}
```

**Correct (feature-specific utilities):**

```typescript
// src/features/user/testing/factories.ts
export function createUser(overrides?: Partial<User>): User {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    ...overrides,
  };
}

// src/features/user/testing/render.tsx
export function renderUserFeature(ui: ReactNode) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  return render(ui, {
    wrapper: ({ children }) => (
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    ),
  });
}

// src/features/user/testing/index.ts
export { createUser } from './factories';
export { renderUserFeature } from './render';

// Usage in tests
import { createUser, renderUserFeature } from '../testing';

describe('UserProfile', () => {
  it('displays user name', () => {
    const user = createUser({ name: 'Jane Doe' });
    renderUserFeature(<UserProfile user={user} />);
    expect(screen.getByText('Jane Doe')).toBeInTheDocument();
  });
});
```

**Shared testing utilities (truly generic):**

```typescript
// src/shared/testing/query-client.ts
export function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
}
```

Reference: [Testing Library - Setup](https://testing-library.com/docs/react-testing-library/setup)

### 7.3 Test Features in Isolation

**Impact: MEDIUM (Enables faster tests; provides clear failure attribution)**

Feature tests should mock cross-feature dependencies. When tests use real implementations of other features, they become slow, flaky, and failures are hard to attribute.

**Incorrect (integrated feature tests):**

```typescript
// Testing checkout feature but using real cart and user features
describe('CheckoutForm', () => {
  it('submits order', async () => {
    // Test depends on cart and user working correctly
    render(
      <QueryClientProvider client={queryClient}>
        <CartProvider>
          <UserProvider>
            <CheckoutForm />
          </UserProvider>
        </CartProvider>
      </QueryClientProvider>
    );

    // If cart has a bug, checkout tests fail
    // Slow because it's testing 3 features
  });
});
```

**Correct (isolated feature tests):**

```typescript
// src/features/checkout/components/__tests__/CheckoutForm.test.tsx
describe('CheckoutForm', () => {
  const mockItems = [
    { id: '1', name: 'Product', price: 100, quantity: 2 },
  ];

  it('submits order with provided items', async () => {
    const onSubmit = vi.fn();

    render(
      <CheckoutForm
        items={mockItems}
        userId="user-123"
        onSubmit={onSubmit}
      />
    );

    await userEvent.click(screen.getByRole('button', { name: /submit/i }));

    expect(onSubmit).toHaveBeenCalledWith({
      items: mockItems,
      userId: 'user-123',
    });
  });

  it('shows empty state when no items', () => {
    render(<CheckoutForm items={[]} userId="user-123" onSubmit={vi.fn()} />);

    expect(screen.getByText(/cart is empty/i)).toBeInTheDocument();
  });
});
```

**Mock cross-feature hooks:**

```typescript
// Mock the cart feature's exported hook
vi.mock('@/features/cart', () => ({
  useCart: () => ({
    items: [{ id: '1', name: 'Test', price: 50, quantity: 1 }],
    total: 50,
  }),
}));
```

**Benefits:**
- Fast tests (no unnecessary dependencies)
- Clear failure attribution
- Tests document the feature's interface

Reference: [Testing Library - Guiding Principles](https://testing-library.com/docs/guiding-principles)

### 7.4 Write Integration Tests at App Layer

**Impact: MEDIUM (Verifies feature composition; catches integration bugs)**

While features should be tested in isolation, integration tests that verify features work together belong at the app layer. This matches the composition structure of the application.

**Incorrect (integration tests inside features):**

```typescript
// src/features/checkout/__tests__/checkout-integration.test.tsx
// WRONG: Integration test inside a feature folder
import { CartProvider } from '@/features/cart';
import { UserProvider } from '@/features/user';
import { CheckoutForm } from '../components/CheckoutForm';

describe('Checkout Integration', () => {
  it('completes checkout with cart and user', async () => {
    render(
      <CartProvider>
        <UserProvider>
          <CheckoutForm />
        </UserProvider>
      </CartProvider>
    );
    // Feature test depends on other features
  });
});
```

**Correct (integration tests at app layer):**

```typescript
// src/app/__tests__/checkout-flow.test.tsx
// Correct: Integration test at app layer where features are composed
describe('Checkout Flow Integration', () => {
  it('completes order from cart to confirmation', async () => {
    render(
      <AppProviders>
        <App />
      </AppProviders>
    );

    // Add product to cart (cart feature)
    await userEvent.click(screen.getByRole('button', { name: /add to cart/i }));

    // Navigate to checkout (routing)
    await userEvent.click(screen.getByRole('link', { name: /checkout/i }));

    // Fill checkout form (checkout feature)
    await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
    await userEvent.click(screen.getByRole('button', { name: /place order/i }));

    // Verify confirmation (order feature)
    expect(await screen.findByText(/order confirmed/i)).toBeInTheDocument();
  });
});
```

**E2E tests for critical paths:**

```typescript
// e2e/checkout.spec.ts
test('complete purchase flow', async ({ page }) => {
  await page.goto('/products');
  await page.click('[data-testid="add-to-cart"]');
  await page.click('[data-testid="go-to-checkout"]');
  await page.fill('[name="email"]', 'test@example.com');
  await page.click('text=Place Order');
  await expect(page.locator('text=Order Confirmed')).toBeVisible();
});
```

**Test layer structure:**

```
tests/
├── unit/           # Fast, isolated tests (run on every commit)
├── integration/    # Feature composition tests (run on PR)
└── e2e/           # Full user journeys (run before deploy)
```

Reference: [Testing Trophy - Kent C. Dodds](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)

---

## 8. Naming Conventions

**Impact: LOW**

Consistent naming aids navigation and onboarding but has no runtime impact.

### 8.1 Use Consistent File Naming Conventions

**Impact: LOW (Enables pattern-based tooling; reduces cognitive load)**

Establish and follow consistent file naming patterns. This enables automated tooling, makes files predictable, and reduces decision fatigue.

**Incorrect (inconsistent naming):**

```
src/features/user/
├── components/
│   ├── UserProfile.tsx      # PascalCase
│   ├── user-avatar.tsx      # kebab-case
│   ├── userBadge.tsx        # camelCase
│   └── User_Settings.tsx    # Snake_Case
├── hooks/
│   ├── useUser.ts           # camelCase
│   └── use-auth.ts          # kebab-case
└── api/
    ├── getUser.ts           # camelCase
    └── user-api.ts          # kebab-case
```

**Correct (consistent conventions):**

```
src/features/user/
├── components/
│   ├── UserProfile.tsx      # PascalCase for components
│   ├── UserAvatar.tsx
│   ├── UserBadge.tsx
│   └── UserSettings.tsx
├── hooks/
│   ├── useUser.ts           # camelCase with use prefix
│   └── useUserAuth.ts
├── api/
│   ├── get-user.ts          # kebab-case for non-components
│   ├── update-user.ts
│   └── delete-user.ts
├── stores/
│   └── user-store.ts        # kebab-case
├── types/
│   └── index.ts
└── utils/
    └── format-user-name.ts  # kebab-case
```

**Recommended conventions:**

| File Type | Convention | Example |
|-----------|------------|---------|
| React components | PascalCase | `UserProfile.tsx` |
| Hooks | camelCase with use prefix | `useUser.ts` |
| API functions | kebab-case | `get-user.ts` |
| Stores | kebab-case | `user-store.ts` |
| Utilities | kebab-case | `format-date.ts` |
| Types | index.ts or kebab-case | `types/index.ts` |
| Tests | match source + .test | `UserProfile.test.tsx` |

**ESLint enforcement:**

```javascript
// .eslintrc.js
rules: {
  'unicorn/filename-case': ['error', {
    cases: {
      pascalCase: true,  // For .tsx files
      kebabCase: true,   // For .ts files
    },
  }],
}
```

Reference: [Airbnb React Style Guide](https://github.com/airbnb/javascript/tree/master/react)

### 8.2 Use Descriptive Export Names

**Impact: LOW (Enables IDE autocomplete; makes imports self-documenting)**

Export names should be descriptive and unique across the codebase. Generic names like `Card`, `List`, or `Button` cause confusion when multiple features export similar components.

**Incorrect (generic export names):**

```typescript
// src/features/user/components/Card.tsx
export function Card({ user }) { ... }  // Which card?

// src/features/product/components/Card.tsx
export function Card({ product }) { ... }  // Collision!

// Import confusion
import { Card } from '@/features/user';    // UserCard? ProductCard?
import { Card as ProductCard } from '@/features/product';  // Requires alias
```

**Correct (descriptive export names):**

```typescript
// src/features/user/components/UserCard.tsx
export function UserCard({ user }: { user: User }) { ... }

// src/features/product/components/ProductCard.tsx
export function ProductCard({ product }: { product: Product }) { ... }

// Clear imports
import { UserCard } from '@/features/user';
import { ProductCard } from '@/features/product';
```

**Naming patterns:**

| Type | Pattern | Example |
|------|---------|---------|
| Feature component | `{Feature}{Component}` | `UserProfile`, `CartSummary` |
| Feature hook | `use{Feature}{Action}` | `useUserAuth`, `useCartItems` |
| Feature API | `{action}{Feature}` | `getUser`, `updateCart` |
| Feature store | `use{Feature}Store` | `useCartStore`, `useUserStore` |

**Exception for shared components:**

```typescript
// Shared components can use generic names - they're not feature-specific
// src/shared/components/Button.tsx
export function Button({ children, ...props }) { ... }

// src/shared/components/Card.tsx
export function Card({ children, ...props }) { ... }
```

**Benefits:**
- IDE autocomplete shows meaningful options
- Imports are self-documenting
- No aliasing required

Reference: [React Naming Conventions](https://react.dev/learn/thinking-in-react)

### 8.3 Use Domain-Driven Feature Names

**Impact: LOW (Improves discoverability; aligns code with business terminology)**

Name features after business domains, not technical implementations. This makes the codebase navigable for non-developers and ensures feature boundaries align with business boundaries.

**Incorrect (technical naming):**

```
src/features/
├── data-grid/          # What data? What domain?
├── form-handler/       # What form? What entity?
├── api-client/         # Generic technical concern
├── modal-manager/      # UI pattern, not domain
└── list-view/          # Generic view pattern
```

**Correct (domain naming):**

```
src/features/
├── user/               # User management domain
├── product/            # Product catalog domain
├── cart/               # Shopping cart domain
├── checkout/           # Checkout/payment domain
├── order/              # Order management domain
├── notification/       # Notification domain
└── search/             # Search domain
```

**Naming guidelines:**

| Domain | Good Name | Bad Name |
|--------|-----------|----------|
| User management | `user`, `account` | `profile-component` |
| Product catalog | `product`, `catalog` | `item-list` |
| Shopping | `cart`, `checkout` | `purchase-flow` |
| Authentication | `auth` | `login-system` |

**Sub-features:**

```
src/features/
├── user/
│   ├── ...            # Core user feature
├── user-preferences/  # Distinct sub-domain
└── user-notifications/ # Another sub-domain
```

**Ask these questions:**
- Would a product manager understand this name?
- Does this map to a business capability?
- Would this name make sense in a requirements document?

Reference: [Domain-Driven Design - Eric Evans](https://www.domainlanguage.com/ddd/)

---

## References

1. [https://www.robinwieruch.de/react-feature-architecture/](https://www.robinwieruch.de/react-feature-architecture/)
2. [https://feature-sliced.design/](https://feature-sliced.design/)
3. [https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)
4. [https://legacy.reactjs.org/docs/faq-structure.html](https://legacy.reactjs.org/docs/faq-structure.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |