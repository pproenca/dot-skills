---
title: Preload Critical Resources
impact: LOW-MEDIUM
impactDescription: faster resource loading, improved LCP
tags: dom, preload, performance, resources
---

## Preload Critical Resources

React 19 provides APIs to preload resources (scripts, stylesheets, fonts) before they're needed. Use these to improve loading performance for critical assets.

**Incorrect (resources load on demand):**

```tsx
function VideoPlayer({ videoId }: { videoId: string }) {
  return (
    <div>
      {/* Video player script loads only when component renders */}
      <script src="/video-player.js" />
      <div id="player" data-video={videoId} />
    </div>
  )
}
```

**Correct (preload critical resources):**

```tsx
import { preload, preconnect, prefetchDNS } from 'react-dom'

function VideoPlayer({ videoId }: { videoId: string }) {
  // Preload the video player script
  preload('/video-player.js', { as: 'script' })

  // Preconnect to video CDN
  preconnect('https://cdn.video-service.com')

  // Prefetch DNS for analytics
  prefetchDNS('https://analytics.example.com')

  return <div id="player" data-video={videoId} />
}
```

**Preload fonts:**

```tsx
import { preload } from 'react-dom'

function App() {
  preload('/fonts/inter.woff2', {
    as: 'font',
    type: 'font/woff2',
    crossOrigin: 'anonymous'
  })

  return <div className="font-inter">...</div>
}
```

**Preload stylesheets with precedence:**

```tsx
import { preinit } from 'react-dom'

function ThemeSwitcher({ theme }: { theme: 'light' | 'dark' }) {
  preinit(`/themes/${theme}.css`, {
    as: 'style',
    precedence: 'high'
  })

  return <div data-theme={theme}>...</div>
}
```

Reference: [Resource Preloading APIs](https://react.dev/blog/2024/12/05/react-19#support-for-preloading-resources)
