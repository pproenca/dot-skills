---
title: Point the MCP server at the org's own Datadog site
tags: ship, mcp, regions, setup
---

## Point the MCP server at the org's own Datadog site

`mcp.datadoghq.com` is the endpoint in every example, so it is the one that gets configured — and for an org on EU, AP, or UK it addresses a tenant that does not contain their data. The failure is not an obvious one: authentication is per-site, so the usual outcome is a connection that never authorises or a tool set that returns nothing, which reads as "the MCP server is broken" rather than "this is the wrong region". Confirm the site before configuring, from the domain the team uses to open Datadog in a browser.

```bash
claude mcp add --transport http datadog https://mcp.datadoghq.eu/v1/mcp
```

The `mcp.` prefix goes at the front of the whole domain, which is the opposite of what the app URL suggests: a US3 org browses at `us3.datadoghq.com`, so the natural guess is `us3.mcp.datadoghq.com`, and that host does not resolve. Use the list rather than deriving it.

```text
US1   https://mcp.datadoghq.com/v1/mcp
EU1   https://mcp.datadoghq.eu/v1/mcp
US3   https://mcp.us3.datadoghq.com/v1/mcp
US5   https://mcp.us5.datadoghq.com/v1/mcp
AP1   https://mcp.ap1.datadoghq.com/v1/mcp
AP2   https://mcp.ap2.datadoghq.com/v1/mcp
UK1   https://mcp.uk1.datadoghq.com/v1/mcp
```

Government sites — `app.ddog-gov.com` and `us2.ddog-gov.com` — are **not supported** at all, so an org on GovCloud needs a different route to dashboard authoring entirely. Say so early rather than debugging a connection that was never going to work.

Toolsets beyond core are opt-in through a query parameter, and the dashboards toolset is one of them — without it, the widget reference and validation tools this skill depends on are absent:

```bash
claude mcp add --transport http datadog \
  "https://mcp.datadoghq.com/v1/mcp?toolsets=dashboards,widgets,alerting"
```

`toolsets=all` enables every generally-available toolset. Authentication is OAuth by default and handled during client setup, so there are no long-lived credentials to place in config; a personal or service access token passed as a bearer token is the alternative where OAuth is not available.

Reference: [Set up the Datadog MCP Server](https://docs.datadoghq.com/mcp_server/setup/) · [Datadog MCP Server](https://docs.datadoghq.com/mcp_server/)
