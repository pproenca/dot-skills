---
title: Use next/font for Zero-CLS Fonts
impact: LOW-MEDIUM
impactDescription: Self-hosts fonts with automatic display:swap; eliminates layout shift and removes render-blocking font requests
tags: advanced, fonts, CLS, performance
---

## Use next/font for Zero-CLS Fonts

`next/font` automatically self-hosts fonts, applies CSS `font-display: swap`, and generates fallback fonts with matching metrics. This eliminates Cumulative Layout Shift from font loading.

**Incorrect (external font import):**

```css
/* globals.css */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700');

/* ❌ External request blocks render
   ❌ Flash of unstyled text (FOUT)
   ❌ Layout shift when font loads
   ❌ Privacy concerns (Google tracks) */
```

**Correct (next/font):**

```typescript
// app/layout.tsx
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',        // Show fallback immediately
})

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={inter.className}>
      <body>{children}</body>
    </html>
  )
}
// ✓ Font self-hosted (no external request)
// ✓ Automatic fallback font with matching metrics
// ✓ Zero layout shift
```

**Multiple fonts:**

```typescript
import { Inter, Roboto_Mono } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
})

const robotoMono = Roboto_Mono({
  subsets: ['latin'],
  variable: '--font-roboto-mono',
})

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${inter.variable} ${robotoMono.variable}`}>
      <body>{children}</body>
    </html>
  )
}
```

```css
/* Use with CSS variables */
body {
  font-family: var(--font-inter);
}

code {
  font-family: var(--font-roboto-mono);
}
```

**Local fonts:**

```typescript
import localFont from 'next/font/local'

const customFont = localFont({
  src: [
    {
      path: './fonts/CustomFont-Regular.woff2',
      weight: '400',
      style: 'normal',
    },
    {
      path: './fonts/CustomFont-Bold.woff2',
      weight: '700',
      style: 'normal',
    },
  ],
  display: 'swap',
})

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={customFont.className}>
      <body>{children}</body>
    </html>
  )
}
```

**Variable fonts (smaller bundle):**

```typescript
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  // Variable font - single file for all weights
  // Much smaller than loading regular + bold + light separately
})
```

**When NOT to use next/font:**
- Icon fonts (use SVG icons instead)
- Fonts loaded conditionally based on user preference
- Extremely large font families where you need only 1-2 weights

Reference: [Next.js Font Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/fonts)
