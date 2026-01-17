---
title: Wait for Hydration Before Interacting
impact: MEDIUM
impactDescription: prevents hydration mismatch errors
tags: next, hydration, ssr, client, interaction
---

## Wait for Hydration Before Interacting

Next.js renders HTML on the server, then hydrates it with JavaScript. Interacting before hydration completes can cause errors or unresponsive elements.

**Incorrect (interact before hydration):**

```typescript
test('submit form', async ({ page }) => {
  await page.goto('/contact');

  // May interact with server-rendered HTML before JS loads
  // Button might not have click handler attached yet
  await page.getByRole('button', { name: 'Submit' }).click();

  // Nothing happens - JS wasn't ready
});
```

**Correct (wait for hydration indicators):**

```typescript
test('submit form', async ({ page }) => {
  await page.goto('/contact');

  // Wait for hydration - JavaScript has loaded and attached handlers
  // Option 1: Wait for client-only element to appear
  await expect(page.getByTestId('hydration-complete')).toBeVisible();

  // Option 2: Wait for interactive element state
  await expect(page.getByRole('button', { name: 'Submit' })).toBeEnabled();

  // Now safe to interact
  await page.getByRole('button', { name: 'Submit' }).click();
});
```

**Add hydration marker in your app:**

```tsx
// components/HydrationMarker.tsx
'use client';

import { useEffect, useState } from 'react';

export function HydrationMarker() {
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    setHydrated(true);
  }, []);

  if (!hydrated) return null;

  return <div data-testid="hydration-complete" style={{ display: 'none' }} />;
}

// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <HydrationMarker />
      </body>
    </html>
  );
}
```

**Wait for specific interactive behavior:**

```typescript
test('interactive dropdown works', async ({ page }) => {
  await page.goto('/settings');

  const dropdown = page.getByRole('combobox', { name: 'Language' });

  // Wait for dropdown to be interactive (hydrated)
  await dropdown.waitFor({ state: 'visible' });

  // Verify it responds to click (JS attached)
  await dropdown.click();
  await expect(page.getByRole('option', { name: 'English' })).toBeVisible();
});
```

**Alternative: networkidle for full hydration:**

```typescript
test('fully hydrated page', async ({ page }) => {
  // networkidle waits for all JS to load and execute
  await page.goto('/dashboard', { waitUntil: 'networkidle' });

  // Page is fully hydrated
  await page.getByRole('button', { name: 'Action' }).click();
});
```

Reference: [Next.js Hydration](https://nextjs.org/docs/messages/react-hydration-error)
