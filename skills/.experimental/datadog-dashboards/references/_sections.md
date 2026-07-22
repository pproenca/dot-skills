# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance ×
frequency** — the decisions that come up on every dashboard, and cost most when
wrong, go first.

Datadog is a continuously-released SaaS product, so these rules are pinned to a
**date, not a version**: verified against docs.datadoghq.com in **July 2026**.
Every rule assumes the **Datadog MCP server** is connected; this skill does not
cover Terraform or raw Dashboard API management.

The ordering reflects the sequence in which a dashboard actually gets built —
decide what it is for, find out what data exists, write queries that mean what
you think, choose visualizations, serialize them, lay them out, ship them — and
that sequence happens to match the cost of getting each step wrong.

---

## 1. Purpose & Scope (scope)

**Description:** What the dashboard is for, who reads it, and whether it should
exist at all. First because it is the only category that can delete the work: a
question that wants a notification wants a monitor, and a one-off investigation
wants a notebook. It is also the step an agent skips entirely — asked for "a
dashboard for the checkout service" it will start emitting widgets without ever
learning what decision the dashboard drives, and produce something plausible
that nobody opens.

## 2. Grounding in the Account (disco)

**Description:** Confirming that the metrics, tags, and facets a query names
actually exist in this org before writing the query. The highest-frequency total
failure: a model asked for a latency dashboard will confidently emit
`avg:app.request.latency{env:prod}` — a name it invented, that no agent in the
account has ever submitted. The result renders as an empty graph rather than an
error, so nothing in the build loop catches it. This category also covers the
metadata that decides every downstream choice: a metric's type determines the
rollup modifier, and its unit determines the display.

## 3. Query Semantics That Silently Mislead (query)

**Description:** The queries that return a number, render a plausible line, and
are wrong. The costliest category because there is no failure signal at all —
no error, no empty graph, just a wrong value that gets trusted and acted on.
Datadog's evaluation model (time aggregation per series first, then space
aggregation, then functions) differs from the PromQL-shaped intuition most
engineers carry, and several of its conveniences apply *only in the UI*, so a
query authored programmatically behaves differently from the identical query
typed into the graph editor.

## 4. Choosing the Widget (widget)

**Description:** Matching the question to the visualization. A model defaults to
a timeseries for everything, which answers "how did this change over time" even
when the question was "which of these is worst right now" or "are we inside our
error budget". Also covers the two widget pairs whose names suggest they are
interchangeable and are not, and the alerting primitives that already exist and
should be embedded rather than reimplemented as threshold lines.

## 5. Dashboard JSON That Validates (json)

**Description:** The parts of the dashboard payload that `validate_dashboard_widget`
either cannot see or cannot explain. Deliberately narrow: the MCP server supplies
live widget schemas through `get_widget_reference`, so re-stating them here would
add a copy that goes stale. What remains is the divergence between UI names and
wire `type` strings (a validation failure tells you the type is wrong, not that
Pie Chart is spelled `sunburst`), the request shape that replaced the deprecated
one, the layout fields whose legality depends on a sibling field, and the
dashboard-level constraints that widget validation never inspects.

## 6. Layout & Readability (layout)

**Description:** Turning a correct set of widgets into something a human can read
under pressure. Grounded in the standard Datadog publishes for the dashboards it
ships with its own integrations, which is more prescriptive than anything in the
main docs. The wrong default here is not an error but an absence: widgets dropped
on the background in creation order, arbitrary display types, and titles that
restate what the axis already says.

## 7. Shipping It (ship)

**Description:** Getting the dashboard into the account correctly on the first
attempt. Narrow by design — two things a model gets wrong that cost real time:
skipping the validate-and-smoke-test step and shipping widgets that render "No
data", and assuming the US1 endpoint for an org that is on EU, AP, or UK.
