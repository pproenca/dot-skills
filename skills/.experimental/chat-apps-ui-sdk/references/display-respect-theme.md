---
title: Respect the Host Theme and Color Scheme
impact: MEDIUM-HIGH
impactDescription: prevents unreadable dark-mode widgets
tags: display, theme, dark-mode, color-scheme
---

## Respect the Host Theme and Color Scheme

The host exposes `window.openai.theme` and updates it through the `openai:set_globals` event when the user toggles appearance. A widget hardcoded to a white background with dark text turns into dark-on-dark — unreadable — the moment the user switches to dark mode. Drive colors from the theme and the CSS `color-scheme` property, and re-render when the theme changes.

**Incorrect (hardcoded light palette becomes unreadable in dark mode):**

```tsx
return <div style={{ background: "#ffffff", color: "#111111" }}>{children}</div>;
```

**Correct (drive colors from the host theme and update on change):**

```tsx
const [theme, setTheme] = useState(window.openai.theme);
useEffect(() => {
  const on = () => setTheme(window.openai.theme);
  window.addEventListener("openai:set_globals", on);
  return () => window.removeEventListener("openai:set_globals", on);
}, []);
return <div style={{ colorScheme: theme, background: "var(--surface)", color: "var(--text)" }}>{children}</div>;
```

Reference: [Design components – Apps SDK](https://developers.openai.com/apps-sdk/plan/components)
