---
title: Detect Host Capabilities Before Use
impact: MEDIUM
impactDescription: prevents crashes on hosts lacking an API
tags: dist, feature-detection, capabilities, portability
---

## Detect Host Capabilities Before Use

Not every host implements every bridge method. Calling `window.openai.requestDisplayMode` or `uploadFile` on a host that lacks it throws and white-screens the widget. Probe for the method before calling it and provide a graceful path when it is absent, so the same component degrades cleanly instead of crashing on the hosts that support fewer extensions.

**Incorrect (throws on a host that doesn't implement picture-in-picture):**

```tsx
const goPip = () => window.openai.requestDisplayMode({ mode: "pip" });
```

**Correct (probe first, fall back to an inline expansion):**

```tsx
const goPip = () => {
  if (typeof window.openai?.requestDisplayMode === "function") {
    window.openai.requestDisplayMode({ mode: "pip" });
  } else {
    setExpanded(true); // inline fallback where PiP is unavailable
  }
};
```

Reference: [Reference – Apps SDK](https://developers.openai.com/apps-sdk/reference)
