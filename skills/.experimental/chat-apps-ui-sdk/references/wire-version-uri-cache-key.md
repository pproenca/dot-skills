---
title: Version the Resource URI as a Cache Key
impact: HIGH
impactDescription: prevents stale widgets after a deploy
tags: wire, cache, versioning, deploy
---

## Version the Resource URI as a Cache Key

Hosts cache UI resources by their URI. If you ship new markup or a new bundle under the same `ui://` URI, returning users keep rendering the old cached widget while you see the new one locally — a confusing split that looks like a flaky deploy. Treat the URI as your cache key and bump a version segment whenever the contents change so the host fetches fresh bytes.

**Incorrect (markup changed but the URI did not; cached old widget keeps rendering):**

```typescript
const SEATMAP_URI = "ui://seatmap/board.html";
function template() { return renderBoardV3(); } // new code, same key -> users still see the old layout
```

**Correct (version in the URI; a new bundle gets a new cache key and reaches users):**

```typescript
const SEATMAP_URI = "ui://seatmap/board-v3.html";
function template() { return renderBoardV3(); }
```

A content hash (`ui://seatmap/board-7f3a.html`) works equally well and automates the bump in CI.

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
