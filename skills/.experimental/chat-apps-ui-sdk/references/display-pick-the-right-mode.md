---
title: Pick the Display Mode That Fits the Task
impact: HIGH
impactDescription: prevents cramped or oversized widgets
tags: display, modes, layout, ux
---

## Pick the Display Mode That Fits the Task

The host offers four surfaces and each suits a different shape of task: an inline card for one quick result with at most two actions, a carousel for 3–8 browsable items, fullscreen for multi-step canvases and maps, and picture-in-picture for persistent, live activities. Forcing a 28-row table into an inline card makes everything tiny and clipped; opening fullscreen for a single confirmation steals the screen. Match the mode to the content density and interaction depth.

**Incorrect (28 listings stuffed into a fixed inline card; rows are tiny and clipped):**

```tsx
return <div className="card">{listings.map((l) => <Row key={l.id} listing={l} />)}</div>;
```

**Correct (few items browse as a carousel; a long list summarizes and opens fullscreen):**

```tsx
return listings.length <= 8
  ? <Carousel items={listings} />
  : <SummaryCard count={listings.length}
      onSeeAll={() => window.openai.requestDisplayMode({ mode: "fullscreen" })} />;
```

Reference: [UI guidelines – Apps SDK](https://developers.openai.com/apps-sdk/concepts/ui-guidelines)
