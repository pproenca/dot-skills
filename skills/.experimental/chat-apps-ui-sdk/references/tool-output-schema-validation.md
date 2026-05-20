---
title: Declare an Output Schema for structuredContent
impact: CRITICAL
impactDescription: prevents widget render crashes from shape drift
tags: tool, output-schema, zod, validation
---

## Declare an Output Schema for structuredContent

Declaring an `outputSchema` turns the shape of `structuredContent` into a contract the host can validate and the widget can trust. Without it, a backend field rename or a null from an upstream API silently ships malformed data, and the component renders `undefined` or throws on first paint with no useful error in the chat. Validate against the schema before returning so failures surface on the server, not in the user's iframe.

**Incorrect (no declared shape; a renamed field reaches the widget as undefined):**

```typescript
server.registerTool("get_portfolio", { inputSchema: { accountId: z.string() } },
  async ({ accountId }) => ({ structuredContent: await fetchPortfolio(accountId) }));
```

**Correct (typed contract, validated before it leaves the server):**

```typescript
const PortfolioOut = z.object({
  totalUsd: z.number(),
  holdings: z.array(z.object({ ticker: z.string(), shares: z.number() })),
});
server.registerTool("get_portfolio",
  { inputSchema: { accountId: z.string() }, outputSchema: PortfolioOut.shape },
  async ({ accountId }) => ({ structuredContent: PortfolioOut.parse(await fetchPortfolio(accountId)) }));
```

The same schema that protects the widget also documents the data shape for the model, improving how it reasons about and narrates the result.

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
