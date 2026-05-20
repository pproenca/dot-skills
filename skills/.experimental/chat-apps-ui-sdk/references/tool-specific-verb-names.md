---
title: Name Tools as Specific Action Verbs
impact: CRITICAL
impactDescription: prevents misrouted or unselectable tools
tags: tool, naming, discovery, schema
---

## Name Tools as Specific Action Verbs

The model routes to a tool by reading its name and description against the user's intent. A generic name like `search` or `run` collides with every other installed app and rarely gets selected, while a specific verb-plus-noun name (`get_flight_status`) makes routing deterministic. Vague names are also a documented directory-review rejection cause.

**Incorrect (generic name competes with every app):**

```typescript
// The model can't tell when to pick this over a dozen other "search" tools:
server.registerTool("search", { description: "Search and return results" }, lookupHandler);
```

**Correct (verb + domain noun the model routes to unambiguously):**

```typescript
server.registerTool("get_flight_status", {
  title: "Get Flight Status",
  description: "Look up live status, gate, and delay for one flight number on a given date.",
}, getFlightStatus);
```

Keep names unique within your app and human-readable; the title is shown in UI affordances while the name is the routing key.

Reference: [App submission guidelines – Apps SDK](https://developers.openai.com/apps-sdk/app-submission-guidelines)
