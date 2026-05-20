---
title: Match the ui:// URI to a Registered Resource
impact: CRITICAL
impactDescription: prevents blank frames from URI mismatches
tags: wire, ui-scheme, resource-handler, registration
---

## Match the ui:// URI to a Registered Resource

The string in a tool's `resourceUri` must be byte-for-byte equal to a resource you actually register under the `ui://` scheme. A typo, a stray hyphen, or a tool pointing at a URI no resource serves resolves to nothing — the frame stays blank with no error surfaced in the chat, which makes this failure maddening to debug. Share one constant between the tool and the resource so they cannot drift.

**Incorrect (tool and resource disagree by one character; the frame stays blank):**

```typescript
server.registerTool("show_seatmap", { _meta: { ui: { resourceUri: "ui://seat-map/v2.html" } } }, getSeatmap);
server.registerResource("seatmap", "ui://seatmap/v2.html", {}, serveSeatmap); // note: seatmap vs seat-map
```

**Correct (a single shared constant guarantees they agree):**

```typescript
const SEATMAP_URI = "ui://seatmap/v2.html";
server.registerTool("show_seatmap", { _meta: { ui: { resourceUri: SEATMAP_URI } } }, getSeatmap);
server.registerResource("seatmap", SEATMAP_URI, {}, serveSeatmap);
```

Reference: [MCP-UI server overview](https://mcpui.dev/guide/server/typescript/overview)
