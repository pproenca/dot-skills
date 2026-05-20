---
title: Offload Layout and Heavy Draw to a Worker
impact: HIGH
impactDescription: prevents main-thread freezes beyond the 16ms budget
tags: perf, web-worker, offscreencanvas, main-thread, jank
---

## Offload Layout and Heavy Draw to a Worker

Projection math, trie aggregation ([[nav-level-of-detail-aggregation]]), and attribute packing for hundreds of thousands of cells can blow past 16 ms; doing them on the main thread freezes scrolling and input. Move that work to a Web Worker, transfer results as a typed-array buffer (zero-copy), and — where supported — render on an `OffscreenCanvas` inside the worker so even the draw stays off the main thread. The UI thread stays responsive while heavy work proceeds in parallel.

**Incorrect (heavy projection on the main thread):**

```typescript
const packed = projectAndPack(cells);   // blocks the UI thread for ~100ms
render(packed);
```

**Correct (worker does the heavy work; transfer the buffer zero-copy):**

```typescript
worker.postMessage({ cells });
worker.onmessage = (e) => render(e.data.packed);   // ArrayBuffer transferred, not cloned
// inside the worker:
//   const packed = projectAndPack(cells);
//   postMessage({ packed }, [packed.buffer]);      // transfer ownership, no copy
```

**When NOT to apply:**
- Tiny datasets where the worker round-trip and serialisation cost more than the work they offload.

Reference: [MDN — Web Workers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers); [MDN — OffscreenCanvas](https://developer.mozilla.org/en-US/docs/Web/API/OffscreenCanvas)
