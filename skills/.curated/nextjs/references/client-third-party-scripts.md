---
title: Wrap third-party scripts in `next/script` with the right `strategy` — never `<script src=...>` in the layout `<head>`
impact: LOW-MEDIUM
impactDescription: removes render-blocking from analytics/chat/social scripts; improves LCP by deferring non-critical work
tags: client, next-script, script-strategy, lcp
---

## Wrap third-party scripts in `next/script` with the right `strategy` — never `<script src=...>` in the layout `<head>`

**Pattern intent:** third-party scripts (analytics, A/B testing, chat widgets, social embeds) should run at a moment that matches their purpose — not block the critical render path. `next/script` exposes `strategy` so each script declares its loading priority.

### Shapes to recognize

- `<script src="https://analytics.example.com/script.js" />` rendered in `<head>` inside `layout.tsx` — blocks render until script loads.
- A `useEffect(() => { const s = document.createElement('script'); ... }, [])` to load a script — works but loses Next.js's lifecycle integration and SSR-safe insertion.
- Every third-party script using the same `strategy` ("afterInteractive" everywhere) — chat widget loads as eagerly as analytics, but doesn't need to.
- A workaround using `dynamic(() => import(...))` on a component that wraps a third-party script — overengineered; `<Script>` handles it.
- A `<Script>` with no `strategy` (defaults to `afterInteractive`, fine) but missing `id` for inline scripts — inline scripts need `id` to dedupe.
- Tag Manager `(function(w,d,s,l,i)...)` snippet pasted inline in `<head>` — should be `<Script id="gtm" strategy="beforeInteractive">` with the snippet as `dangerouslySetInnerHTML`.

The canonical resolution: `<Script src=...>` for external scripts, `<Script id=...>{inline}</Script>` for inline; pick `strategy`: `beforeInteractive` for critical (rare), `afterInteractive` for analytics/tracking (default), `lazyOnload` for chat/social/widgets, `worker` (experimental) to offload to a web worker.

**Incorrect (blocking script in head):**

```typescript
// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <head>
        <script src="https://analytics.example.com/script.js" />
        {/* Blocks rendering until script loads */}
      </head>
      <body>{children}</body>
    </html>
  )
}
```

**Correct (next/script with strategy):**

```typescript
// app/layout.tsx
import Script from 'next/script'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}

        {/* Analytics - load after page is interactive */}
        <Script
          src="https://analytics.example.com/script.js"
          strategy="afterInteractive"
        />

        {/* Chat widget - load when idle */}
        <Script
          src="https://chat.example.com/widget.js"
          strategy="lazyOnload"
        />

        {/* Critical script - load before interactive */}
        <Script
          id="gtm"
          strategy="beforeInteractive"
          dangerouslySetInnerHTML={{
            __html: `(function(w,d,s,l,i){...})(window,document,'script','dataLayer','GTM-XXX');`
          }}
        />
      </body>
    </html>
  )
}
```

**Strategy guide:**
- `beforeInteractive` - Critical scripts (rare)
- `afterInteractive` - Analytics, tracking (default)
- `lazyOnload` - Chat widgets, social buttons
- `worker` - Offload to web worker (experimental)
