---
title: Keep Secrets and PII Out of Widget State
impact: HIGH
impactDescription: prevents leaking tokens through state
tags: state, secrets, pii, security
---

## Keep Secrets and PII Out of Widget State

`widgetState`, `structuredContent`, and `content` are all delivered to the user's browser, and `widgetState` additionally round-trips through the host on every turn. Storing an access token or full personal data there exposes it in devtools and in transport. Persist only opaque identifiers and let the server resolve them to the sensitive value behind authentication.

**Incorrect (token and PII persisted in widget state; visible in devtools and transport):**

```tsx
window.openai.setWidgetState({ accessToken: "atk_live_8Q2x…", userEmail });
```

**Correct (persist an opaque id; the server maps it to the token):**

```tsx
window.openai.setWidgetState({ sessionId });
```

The same rule applies to anything you return from a tool — never embed secrets in payloads the user can read (see [[sec-no-secrets-in-payloads]]).

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
