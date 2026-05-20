---
title: Render From Tool Output, Not First Paint
impact: HIGH
impactDescription: prevents a blank widget before data arrives
tags: bridge, notifications, tool-output, rendering
---

## Render From Tool Output, Not First Paint

The component's data may not be present at the very first paint, and updates arrive as events — `openai:set_globals` on the Apps SDK, or `ui/notifications/tool-result` on the MCP Apps bridge. Snapshotting `window.openai.toolOutput` once at module load captures whatever happened to be there and ignores everything after, so the widget shows empty until something unrelated forces a re-render. Read on mount and subscribe to updates.

**Incorrect (snapshots data once at module load; later updates never reach the UI):**

```tsx
const out = window.openai.toolOutput; // may be undefined here
render(<Seatmap seats={out.seats} />);
```

**Correct (read on mount, then re-render whenever the host pushes new globals):**

```tsx
function Seatmap() {
  const [out, setOut] = useState(window.openai.toolOutput);
  useEffect(() => {
    const onSet = () => setOut(window.openai.toolOutput);
    window.addEventListener("openai:set_globals", onSet);
    return () => window.removeEventListener("openai:set_globals", onSet);
  }, []);
  return <SeatGrid seats={out?.seats ?? []} />;
}
```

Always guard against missing data (`out?.seats ?? []`) and render a loading state until it arrives (see [[design-render-loading-empty-error]]).

Reference: [Reference – Apps SDK](https://developers.openai.com/apps-sdk/reference)
