---
name: datadog-dashboards
description: Corrects the wrong defaults a model has when building Datadog dashboards, verified against Datadog's docs in July 2026. Use when creating, editing, or reviewing a Datadog dashboard — choosing widgets, writing metric/log/span queries, or emitting widget JSON. Covers the queries that render a plausible number and are still wrong — `.as_count()` is appended automatically in the graph editor but never through the API, so programmatic counts silently average; `p95` resolves only on distribution metrics, and averaging one is an average of averages; ratios need `.as_count()` on both sides or they divide interpolated averages. Also covers grounding queries in metrics that exist rather than invented names, wire type strings that diverge from UI names (Pie Chart is `sunburst`, Table is `query_table`), and Datadog's own layout standard. Assumes the Datadog MCP server is connected. NOT for Terraform or raw Dashboard API management, monitor and SLO authoring, or non-Datadog observability tools.
---

# Datadog Dashboards

The decisions Datadog forces when you build a dashboard, and how to settle them. Every rule names the wrong default it corrects; there is no rule for what the model already gets right.

**Pinned to a date, not a version.** Datadog ships continuously, so every claim here was verified against docs.datadoghq.com in **July 2026**. Re-verify before trusting anything version-shaped — deprecations here (`q`, `default`, `is_read_only`, `week_before()`) still parse today.

**Assumes the Datadog MCP server is connected** (`https://mcp.<site>/v1/mcp`, `toolsets=dashboards,widgets`). Widget schemas are deliberately *not* restated in this skill — `get_widget_reference` returns them current at call time, and a copy here would go stale. If the server is not connected, set it up first (`ship-endpoint-follows-the-site`); this skill does not cover Terraform or raw API management.

## When to Apply

Use this skill when:

- Creating or editing a Datadog dashboard, or reviewing one someone else built — especially a board assembled programmatically rather than in the graph editor, which is where the `.as_count()` divergence bites
- Writing any Datadog query destined for a widget: metric queries with space aggregators and modifiers, or `logs` / `spans` / `rum` queries with `search` + `compute` + `group_by`
- Choosing between visualizations, or being handed a request that says "graph" but wants a ranking, a single number, or an error budget
- A dashboard shows numbers nobody trusts, panels that render "No data", or a value that changes when the time frame changes
- Asked for "a dashboard for X" with no stated audience — the interview in `scope-ask-audience-and-decision` runs before anything is built

This skill is NOT for:

- Managing dashboards through Terraform or the raw Dashboard API (this skill assumes the MCP server)
- Authoring monitors or defining SLOs — though `scope-not-every-question-is-a-dashboard` covers recognising when the request is one of those
- Datadog instrumentation: agent config, tracer setup, or deciding which metrics to emit in the first place
- Non-Datadog observability platforms — the query semantics here do not transfer

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Purpose & Scope | `scope-` | Audience, the decision it drives, variables over duplication, when it should not be a dashboard |
| 2 | Grounding in the Account | `disco-` | Confirming metrics, tags, and facets exist before querying them |
| 3 | Query Semantics | `query-` | The queries that return a number and are wrong |
| 4 | Choosing the Widget | `widget-` | Matching question to visualization; the pairs that are not interchangeable |
| 5 | Dashboard JSON | `json-` | What widget validation cannot see or cannot explain |
| 6 | Layout & Readability | `layout-` | Datadog's own standard for structure, display types, titles, sizing |
| 7 | Shipping It | `ship-` | Validate-and-smoke-test before writing; region endpoints |

## Quick Reference

### 1. Purpose & Scope

- [`scope-ask-audience-and-decision`](references/scope-ask-audience-and-decision.md) — Four questions before the first widget; the answers belong in `description`, not in chat
- [`scope-one-dashboard-many-variables`](references/scope-one-dashboard-many-variables.md) — Six services is one dashboard; variable dropdowns only offer values the board's own widgets query
- [`scope-clone-before-building`](references/scope-clone-before-building.md) — Presets exist for 1000+ integrations and are invisible to `GET /dashboard`; search, don't list
- [`scope-not-every-question-is-a-dashboard`](references/scope-not-every-question-is-a-dashboard.md) — "Tell us when X" is a monitor; a narrative is a notebook

### 2. Grounding in the Account

- [`disco-never-invent-metric-names`](references/disco-never-invent-metric-names.md) — A wrong metric name renders an empty graph, never an error
- [`disco-read-type-and-unit-first`](references/disco-read-type-and-unit-first.md) — DogStatsD `increment()` is stored as a RATE; type decides the modifier, unit decides the title
- [`disco-absence-is-not-proof`](references/disco-absence-is-not-proof.md) — Metrics age out of discovery in 24h but are retained 15 months
- [`disco-log-attributes-need-facets`](references/disco-log-attributes-need-facets.md) — Unfaceted attributes cannot be grouped, and no API lists facets

### 3. Query Semantics

- [`query-append-as-count-explicitly`](references/query-append-as-count-explicitly.md) — **The costliest default.** The UI appends `.as_count()`; the API does not, and rolls up with `avg`
- [`query-percentiles-require-distributions`](references/query-percentiles-require-distributions.md) — `p95:` needs a distribution with percentiles enabled; `avg:` of a p95 is not a percentile
- [`query-aggregate-before-dividing`](references/query-aggregate-before-dividing.md) — A ratio without `.as_count()` sums per-interval ratios and can read 150%
- [`query-gauge-gaps-are-interpolated`](references/query-gauge-gaps-are-interpolated.md) — Up to 5 minutes of fabricated points fill each gap by default
- [`query-rollup-changes-the-number`](references/query-rollup-changes-the-number.md) — The same widget means something different at each time frame
- [`query-event-sources-take-objects`](references/query-event-sources-take-objects.md) — Logs and spans take `search`+`compute`+`group_by`; `interval` is milliseconds, percentiles are `pc95`
- [`query-scope-syntax-does-not-mix`](references/query-scope-syntax-does-not-mix.md) — `{env:prod AND !region:x}` is invalid; a wildcard after `$var` matches nothing
- [`query-top-n-subtotals-are-partial`](references/query-top-n-subtotals-are-partial.md) — The total under a top list is the sum of the visible rows

### 4. Choosing the Widget

- [`widget-match-the-question`](references/widget-match-the-question.md) — Timeseries answers one question; rankings, single values, and deltas want other widgets
- [`widget-heatmap-is-not-distribution`](references/widget-heatmap-is-not-distribution.md) — One has time on the x-axis, the other quantity
- [`widget-reuse-alerting-primitives`](references/widget-reuse-alerting-primitives.md) — Embed the SLO and monitor instead of guessing a threshold line

### 5. Dashboard JSON

- [`json-type-strings-differ-from-ui-names`](references/json-type-strings-differ-from-ui-names.md) — Pie Chart is `sunburst`, Table is `query_table`, Monitor Summary is `manage_status`
- [`json-queries-and-formulas-not-q`](references/json-queries-and-formulas-not-q.md) — `q` and every `*_query` field are deprecated; `data_source` is `profiles`, not `profile_metrics`
- [`json-layout-follows-reflow-type`](references/json-layout-follows-reflow-type.md) — Under `reflow_type: auto`, `layout` must be omitted, not merely ignored
- [`json-template-variables-take-defaults`](references/json-template-variables-take-defaults.md) — `defaults` is an array; singular `default` is deprecated
- [`json-dashboard-tags-are-constrained`](references/json-dashboard-tags-are-constrained.md) — Max 5, `team:`-shaped; `is_read_only` is deprecated but `restricted_roles` is not

### 6. Layout & Readability

- [`layout-put-widgets-in-groups`](references/layout-put-widgets-in-groups.md) — About and Overview first, streams last, nothing bare on the background
- [`layout-display-type-follows-metric-shape`](references/layout-display-type-follows-metric-shape.md) — Area for volume, bars for counts, lines for comparison
- [`layout-let-datadog-render-units`](references/layout-let-datadog-render-units.md) — Alias every formula; the axis already shows the unit
- [`layout-size-for-the-medium`](references/layout-size-for-the-medium.md) — A wallboard and a triage board cannot be the same dashboard

### 7. Shipping It

- [`ship-validate-before-upserting`](references/ship-validate-before-upserting.md) — Smoke-test the query and validate per widget before the write
- [`ship-endpoint-follows-the-site`](references/ship-endpoint-follows-the-site.md) — EU, AP, and UK orgs need their own MCP host; GovCloud is unsupported

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical form — with an incorrect/correct contrast only where the wrong way is a real trap.

Three shortcuts worth taking first:

- **Building a dashboard from a request?** Run `scope-ask-audience-and-decision`, then `disco-never-invent-metric-names`, before emitting anything. Skipping either produces a board that is fluent and useless.
- **Reviewing a dashboard whose numbers look wrong?** Start with `query-append-as-count-explicitly` and `query-percentiles-require-distributions`. Together they account for most Datadog panels that are confidently incorrect, and neither leaves a trace in the UI.
- **Porting dashboard JSON written before 2025?** `json-queries-and-formulas-not-q` and `json-template-variables-take-defaults` are the deprecations that still parse, so nothing points you at them.

- [Section definitions](references/_sections.md) — category structure and ordering rationale
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules
