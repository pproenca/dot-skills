---
title: Persist UI State Through setWidgetState
impact: HIGH
impactDescription: preserves selection across re-mounts
tags: state, set-widget-state, persistence, rehydrate
---

## Persist UI State Through setWidgetState

The host can unmount and re-mount the widget between turns, and component-local `useState` is wiped when it does. Anything you write with `setWidgetState` comes back on `window.openai.widgetState` after the re-mount, so persist the state the user would resent losing — active filters, a draft message, the selected tab. Seed component state from `widgetState` on mount and write through on every change.

**Incorrect (active tab is local state; it resets every time the host re-mounts):**

```tsx
const [tab, setTab] = useState<"map" | "list">("map");
```

**Correct (seed from persisted state and write through on change):**

```tsx
const [tab, setTab] = useState<"map" | "list">(window.openai.widgetState?.tab ?? "map");
const select = (t: "map" | "list") => {
  setTab(t);
  window.openai.setWidgetState({ ...window.openai.widgetState, tab: t });
};
```

Keep what you persist small and serializable (see [[state-keep-state-small]]) — `widgetState` is transported on every turn.

Reference: [Reference – Apps SDK](https://developers.openai.com/apps-sdk/reference)
