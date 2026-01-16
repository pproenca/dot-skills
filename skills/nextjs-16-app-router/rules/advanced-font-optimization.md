---
title: Use next/font for Self-Hosted Fonts
impact: LOW
impactDescription: Eliminates layout shift from font loading and removes external font requests
tags: advanced, fonts, cls, performance, web-fonts
---

## Use next/font for Self-Hosted Fonts

External font services like Google Fonts add render-blocking requests and cause layout shift when fonts swap. Using `next/font` self-hosts fonts, eliminates external network requests, and applies `font-display: swap` automatically to prevent invisible text during loading.

**Incorrect (external font causes layout shift and extra requests):**

```tsx
// app/layout.tsx
import './globals.css'

// globals.css contains:
// @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&display=swap');
// Adds 100-300ms blocking request + causes CLS when font loads

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="font-inter">{children}</body>
    </html>
  )
}
```

**Correct (self-hosted with next/font):**

```tsx
// app/layout.tsx
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap', // Ensures text visible during font load
  variable: '--font-inter',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body className={inter.className}>{children}</body>
    </html>
  )
}
```

**Alternative (local custom fonts):**

```tsx
import localFont from 'next/font/local'

const brandFont = localFont({
  src: [
    { path: './fonts/Brand-Regular.woff2', weight: '400' },
    { path: './fonts/Brand-Bold.woff2', weight: '700' },
  ],
  display: 'swap',
  variable: '--font-brand',
})
```

**Benefits:**
- Zero external network requests for fonts
- Automatic font subsetting reduces file size
- No Cumulative Layout Shift from font swapping
- Fonts are cached with your application assets

**Best practices:**
- Use `subsets` to include only needed character sets
- Specify only the `weight` values your design uses
- Use CSS variables for flexible font application

Reference: [Font Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/fonts)
