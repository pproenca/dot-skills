---
title: Guard Browser APIs with typeof window Check
impact: MEDIUM
impactDescription: prevents SSR crashes from browser-only APIs
tags: ssr, window, browser, guards
---

## Guard Browser APIs with typeof window Check

When stores use browser-only APIs like `localStorage`, `window`, or `document`, guard them with `typeof window !== 'undefined'` to prevent crashes during server-side rendering.

**Incorrect (crashes on server):**

```typescript
const useThemeStore = create<ThemeState>((set) => ({
  // Crashes on server: localStorage is not defined
  theme: localStorage.getItem('theme') || 'light',

  setTheme: (theme) => {
    localStorage.setItem('theme', theme)
    set({ theme })
  },
}))
```

**Correct (guarded browser API access):**

```typescript
const getInitialTheme = (): Theme => {
  if (typeof window === 'undefined') {
    return 'light' // SSR default
  }
  return (localStorage.getItem('theme') as Theme) || 'light'
}

const useThemeStore = create<ThemeState>((set) => ({
  theme: getInitialTheme(),

  setTheme: (theme) => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('theme', theme)
    }
    set({ theme })
  },
}))
```

**Alternative (use persist middleware which handles this):**

```typescript
import { persist, createJSONStorage } from 'zustand/middleware'

const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      theme: 'light',
      setTheme: (theme) => set({ theme }),
    }),
    {
      name: 'theme-storage',
      // createJSONStorage handles SSR safely
      storage: createJSONStorage(() => localStorage),
      skipHydration: true,
    }
  )
)
```

**Common browser APIs to guard:**
- `localStorage` / `sessionStorage`
- `window.matchMedia()`
- `document.cookie`
- `navigator.userAgent`
- `window.innerWidth` / `innerHeight`

Reference: [Next.js Documentation](https://nextjs.org/docs/messages/react-hydration-error)
