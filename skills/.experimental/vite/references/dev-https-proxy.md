---
title: Configure HTTPS and Proxy for Development
impact: MEDIUM
impactDescription: eliminates CORS issues, enables secure contexts
tags: dev, https, proxy, api
---

## Configure HTTPS and Proxy for Development

Configure dev server proxy to avoid CORS issues and HTTPS for APIs requiring secure contexts.

**Incorrect (CORS errors block development):**

```typescript
// api.ts
fetch('https://api.example.com/users')
// CORS error: No 'Access-Control-Allow-Origin' header
// Development blocked, need backend changes
```

**Correct (proxy through Vite):**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'https://api.example.com',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})
```

```typescript
// api.ts
fetch('/api/users')  // Proxied to https://api.example.com/users
// No CORS issues - same origin from browser's perspective
```

**Enable HTTPS:**

```javascript
// vite.config.js
import basicSsl from '@vitejs/plugin-basic-ssl'

export default defineConfig({
  plugins: [basicSsl()],
  server: {
    https: true
  }
})
// Required for: WebAuthn, Geolocation, Service Workers
```

**WebSocket proxy:**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    proxy: {
      '/socket.io': {
        target: 'ws://localhost:3001',
        ws: true
      }
    }
  }
})
```

Reference: [Server Options | Vite](https://vite.dev/config/server-options)
