---
title: Avoid Nested Frame Domains in the Widget
impact: MEDIUM-HIGH
impactDescription: prevents review rejection from embedding
tags: sec, frame-domains, iframe, review
---

## Avoid Nested Frame Domains in the Widget

Embedding third-party iframes via `frameDomains` widens the attack surface and draws extra review scrutiny; the platform documentation explicitly discourages it, and it is a frequent rejection cause. Render the content inline or from your own vetted, CSP-listed origin instead of nesting an untrusted frame inside the sandbox.

**Incorrect (embeds a third-party frame; discouraged and commonly rejected):**

```typescript
const csp = { frameDomains: ["https://widgets.thirdparty.example.com"] };
const html = `<iframe src="https://widgets.thirdparty.example.com/chart"></iframe>`;
```

**Correct (render the chart inline from your own bundle and origin):**

```typescript
const csp = { connectDomains: ["https://api.transit.example.com"] }; // no frameDomains
const html = `<div id="root"></div><script type="module">${chartBundle}</script>`;
```

**When NOT to apply:**
- A genuinely unavoidable embed (a payment provider's hosted field) may require a frame — declare the single origin, expect review questions, and document why.

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
