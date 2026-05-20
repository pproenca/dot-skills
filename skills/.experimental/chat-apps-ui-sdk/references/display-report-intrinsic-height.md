---
title: Report Intrinsic Height and Respect maxHeight
impact: HIGH
impactDescription: prevents clipped content and dead space
tags: display, height, layout, resize
---

## Report Intrinsic Height and Respect maxHeight

The host sizes the iframe from the height the widget reports — `notifyIntrinsicHeight` on the Apps SDK, or `autoResizeIframe` on MCP-UI — and caps it at `window.openai.maxHeight`. Hardcoding a pixel height clips tall content behind an invisible boundary or leaves a band of empty space below short content. Measure the rendered content, report it, and clamp to the host maximum.

**Incorrect (fixed height clips long content and wastes space on short content):**

```tsx
return <div style={{ height: 600 }}>{children}</div>;
```

**Correct (report measured height, clamped to the host maximum):**

```tsx
const ref = useRef<HTMLDivElement>(null);
useEffect(() => {
  const measured = ref.current!.scrollHeight;
  window.openai.notifyIntrinsicHeight?.(Math.min(measured, window.openai.maxHeight ?? measured));
});
return <div ref={ref}>{children}</div>;
```

On MCP-UI, pass `htmlProps={{ autoResizeIframe: true }}` to `UIResourceRenderer` to get the same behavior without manual measurement.

Reference: [Reference – Apps SDK](https://developers.openai.com/apps-sdk/reference)
