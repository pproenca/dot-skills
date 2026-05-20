---
title: Request Fullscreen but Render Inline First
impact: HIGH
impactDescription: prevents an empty widget when the host denies
tags: display, request-display-mode, fallback, pip
---

## Request Fullscreen but Render Inline First

`requestDisplayMode` is a request the host can deny — on mobile, for policy, or because the user dismissed it. Calling it on mount and rendering nothing until it is granted leaves a blank widget whenever the request fails. Always paint a usable inline state first, then upgrade to fullscreen or picture-in-picture in response to an explicit user action, and keep working if the upgrade never happens.

**Incorrect (requests fullscreen on mount and renders nothing until granted):**

```tsx
useEffect(() => { window.openai.requestDisplayMode({ mode: "fullscreen" }); }, []);
if (window.openai.displayMode !== "fullscreen") return null; // blank if the host denies
```

**Correct (usable inline immediately; upgrade on user intent, tolerate denial):**

```tsx
return (
  <Card>
    <TripSummary trip={trip} />
    <button onClick={() => window.openai.requestDisplayMode({ mode: "fullscreen" })}>Open planner</button>
  </Card>
);
```

Reference: [UI guidelines – Apps SDK](https://developers.openai.com/apps-sdk/concepts/ui-guidelines)
