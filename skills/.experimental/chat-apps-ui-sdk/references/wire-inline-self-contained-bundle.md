---
title: Inline the Component Bundle Into the Resource
impact: HIGH
impactDescription: eliminates a blank frame on cold boot
tags: wire, bundle, esbuild, self-contained
---

## Inline the Component Bundle Into the Resource

The iframe loads the resource HTML in isolation. If that HTML pulls your JavaScript or CSS from your own origin at runtime, a CSP gap or a cold cache shows a blank frame before anything paints, and you have introduced a network dependency on a surface that should boot instantly. Bundle the component and inline it into the HTML so the document is self-sufficient and renders the moment the host mounts it.

**Incorrect (the iframe must fetch your origin before it can paint):**

```typescript
const html = `<div id="root"></div><script src="https://flighty.example.com/seatmap.js"></script>`;
return { contents: [{ uri, mimeType: "text/html;profile=mcp-app", text: html }] };
```

**Correct (single self-contained document; nothing to fetch to boot):**

```typescript
const bundle = await readFile("dist/seatmap.js", "utf8"); // built with esbuild --bundle --format=esm
const html = `<div id="root"></div><script type="module">${bundle}</script>`;
return { contents: [{ uri, mimeType: "text/html;profile=mcp-app", text: html }] };
```

Runtime data still comes through the bridge — only the code is inlined, not the dataset (see [[tool-feed-widget-in-response]]).

Reference: [Build your ChatGPT UI – Apps SDK](https://developers.openai.com/apps-sdk/build/chatgpt-ui)
