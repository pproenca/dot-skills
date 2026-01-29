---
title: Use Plugin Entry Points for Frameworks
impact: CRITICAL
impactDescription: automatically detects framework-specific entry patterns
tags: entry, plugins, frameworks, next, remix
---

## Use Plugin Entry Points for Frameworks

Frameworks like Next.js, Remix, and Astro have non-standard entry patterns. Enable plugins to detect these automatically instead of manual configuration.

**Incorrect (manual Next.js entries, incomplete coverage):**

```json
{
  "entry": [
    "pages/**/*.tsx",
    "app/**/*.tsx"
  ]
}
```

**Correct (plugin handles all Next.js entry patterns):**

```json
{
  "next": true
}
```

The Next.js plugin automatically includes:
- `pages/**/*.{js,jsx,ts,tsx}`
- `app/**/*.{js,jsx,ts,tsx}`
- `middleware.{js,ts}`
- `instrumentation.{js,ts}`
- API routes, loading, error, and layout files

**Override plugin entries when needed:**

```json
{
  "next": {
    "entry": ["app/**/*.tsx", "!app/**/not-a-page.tsx"]
  }
}
```

Reference: [Knip Plugins](https://knip.dev/reference/plugins)
