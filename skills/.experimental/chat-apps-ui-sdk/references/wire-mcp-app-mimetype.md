---
title: Serve UI Resources With the mcp-app MIME Type
impact: CRITICAL
impactDescription: prevents the host from rendering markup as text
tags: wire, mime-type, resource, skybridge
---

## Serve UI Resources With the mcp-app MIME Type

The host decides whether an HTML resource becomes an interactive widget purely from its MIME type. The MCP Apps standard is `text/html;profile=mcp-app` (older ChatGPT builds used `text/html+skybridge`). Serve a generic `text/html` and the host has no signal that this is a renderable component, so it prints your markup as a code block in the transcript.

**Incorrect (generic html type; the host shows the markup as text):**

```typescript
return { contents: [{ uri: "ui://seatmap/v2.html", mimeType: "text/html", text: html }] };
```

**Correct (the mcp-app profile tells the host to render a widget):**

```typescript
return { contents: [{ uri: "ui://seatmap/v2.html", mimeType: "text/html;profile=mcp-app", text: html }] };
```

If you must support older ChatGPT clients alongside the standard, detect the host and fall back to `text/html+skybridge`; new integrations target the profile MIME type.

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
