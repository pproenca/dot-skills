# Datadog Dashboards

**Version 0.1.0**  
community  
July 2026

---

## Abstract

Corrects the wrong defaults a capable model has when building Datadog dashboards, verified against docs.datadoghq.com in July 2026 and assuming the Datadog MCP server is connected. Covers the queries that render a plausible number and are silently wrong — .as_count() being appended in the graph editor but never through the API, percentiles that resolve only on distribution metrics, ratios that must aggregate before dividing, and rollup intervals that change what a widget means at each time frame — alongside grounding queries in metrics that exist rather than invented names, the wire type strings that diverge from UI widget names, and Datadog's own published standard for dashboard structure and readability.

---

## Table of Contents

1. [Purpose & Scope](references/_sections.md#1-purpose-&-scope)
   - 1.1 [Fix the audience and the decision before the first widget](references/scope-ask-audience-and-decision.md)
   - 1.2 [Route the request to a monitor, SLO, or notebook when it is not a dashboard](references/scope-not-every-question-is-a-dashboard.md)
   - 1.3 [Scope with template variables instead of duplicating the dashboard](references/scope-one-dashboard-many-variables.md)
   - 1.4 [Search for an existing dashboard before authoring a new one](references/scope-clone-before-building.md)
2. [Grounding in the Account](references/_sections.md#2-grounding-in-the-account)
   - 2.1 [Confirm every metric name against the account before querying it](references/disco-never-invent-metric-names.md)
   - 2.2 [Read a metric's type and unit before choosing how to aggregate it](references/disco-read-type-and-unit-first.md)
   - 2.3 [Treat a missing metric as stale, not as absent](references/disco-absence-is-not-proof.md)
   - 2.4 [Verify a log attribute is faceted before grouping a widget by it](references/disco-log-attributes-need-facets.md)
3. [Query Semantics That Silently Mislead](references/_sections.md#3-query-semantics-that-silently-mislead)
   - 3.1 [Aggregate both sides before dividing them into a ratio](references/query-aggregate-before-dividing.md)
   - 3.2 [Append as_count() explicitly when building queries outside the graph editor](references/query-append-as-count-explicitly.md)
   - 3.3 [Build log, span, and RUM queries as structured objects](references/query-event-sources-take-objects.md)
   - 3.4 [Disable interpolation when a gap in a gauge means something](references/query-gauge-gaps-are-interpolated.md)
   - 3.5 [Keep symbolic and functional filter syntax out of the same scope](references/query-scope-syntax-does-not-mix.md)
   - 3.6 [Pin the rollup when a number has to mean the same thing at every time frame](references/query-rollup-changes-the-number.md)
   - 3.7 [Read a top-N total as a subtotal of the rows shown](references/query-top-n-subtotals-are-partial.md)
   - 3.8 [Use distribution metrics for percentiles and never average one](references/query-percentiles-require-distributions.md)
4. [Choosing the Widget](references/_sections.md#4-choosing-the-widget)
   - 4.1 [Choose the widget from the question, not from habit](references/widget-match-the-question.md)
   - 4.2 [Embed the SLO and monitor that already exist instead of redrawing them](references/widget-reuse-alerting-primitives.md)
   - 4.3 [Keep heatmap and distribution apart — one axis is time, the other is quantity](references/widget-heatmap-is-not-distribution.md)
5. [Dashboard JSON That Validates](references/_sections.md#5-dashboard-json-that-validates)
   - 5.1 [Declare template variable defaults as an array](references/json-template-variables-take-defaults.md)
   - 5.2 [Keep dashboard tags to five team-scoped values](references/json-dashboard-tags-are-constrained.md)
   - 5.3 [Look up the wire type string rather than deriving it from the widget's name](references/json-type-strings-differ-from-ui-names.md)
   - 5.4 [Set widget layout only when reflow_type and layout_type require it](references/json-layout-follows-reflow-type.md)
   - 5.5 [Write requests as queries plus formulas, never as a q string](references/json-queries-and-formulas-not-q.md)
6. [Layout & Readability](references/_sections.md#6-layout-&-readability)
   - 6.1 [Alias every formula and leave units out of the title](references/layout-let-datadog-render-units.md)
   - 6.2 [Organise every widget into a group, starting with About and Overview](references/layout-put-widgets-in-groups.md)
   - 6.3 [Pick the display type from the shape of the metric](references/layout-display-type-follows-metric-shape.md)
   - 6.4 [Split the wallboard from the triage board rather than serving both](references/layout-size-for-the-medium.md)
7. [Shipping It](references/_sections.md#7-shipping-it)
   - 7.1 [Point the MCP server at the org's own Datadog site](references/ship-endpoint-follows-the-site.md)
   - 7.2 [Validate and smoke-test each widget before upserting the dashboard](references/ship-validate-before-upserting.md)

---

## References

1. [https://docs.datadoghq.com/dashboards/](https://docs.datadoghq.com/dashboards/)
2. [https://docs.datadoghq.com/dashboards/querying/](https://docs.datadoghq.com/dashboards/querying/)
3. [https://docs.datadoghq.com/dashboards/template_variables/](https://docs.datadoghq.com/dashboards/template_variables/)
4. [https://docs.datadoghq.com/dashboards/widgets/](https://docs.datadoghq.com/dashboards/widgets/)
5. [https://docs.datadoghq.com/dashboards/widgets/bar_chart/](https://docs.datadoghq.com/dashboards/widgets/bar_chart/)
6. [https://docs.datadoghq.com/dashboards/widgets/change/](https://docs.datadoghq.com/dashboards/widgets/change/)
7. [https://docs.datadoghq.com/dashboards/widgets/configuration/](https://docs.datadoghq.com/dashboards/widgets/configuration/)
8. [https://docs.datadoghq.com/dashboards/widgets/distribution/](https://docs.datadoghq.com/dashboards/widgets/distribution/)
9. [https://docs.datadoghq.com/dashboards/widgets/group/](https://docs.datadoghq.com/dashboards/widgets/group/)
10. [https://docs.datadoghq.com/dashboards/widgets/heatmap/](https://docs.datadoghq.com/dashboards/widgets/heatmap/)
11. [https://docs.datadoghq.com/dashboards/widgets/monitor_summary/](https://docs.datadoghq.com/dashboards/widgets/monitor_summary/)
12. [https://docs.datadoghq.com/dashboards/widgets/pie_chart/](https://docs.datadoghq.com/dashboards/widgets/pie_chart/)
13. [https://docs.datadoghq.com/dashboards/widgets/query_value/](https://docs.datadoghq.com/dashboards/widgets/query_value/)
14. [https://docs.datadoghq.com/dashboards/widgets/slo/](https://docs.datadoghq.com/dashboards/widgets/slo/)
15. [https://docs.datadoghq.com/dashboards/widgets/timeseries/](https://docs.datadoghq.com/dashboards/widgets/timeseries/)
16. [https://docs.datadoghq.com/dashboards/functions/](https://docs.datadoghq.com/dashboards/functions/)
17. [https://docs.datadoghq.com/dashboards/functions/exclusion/](https://docs.datadoghq.com/dashboards/functions/exclusion/)
18. [https://docs.datadoghq.com/dashboards/functions/interpolation/](https://docs.datadoghq.com/dashboards/functions/interpolation/)
19. [https://docs.datadoghq.com/dashboards/functions/rank/](https://docs.datadoghq.com/dashboards/functions/rank/)
20. [https://docs.datadoghq.com/dashboards/functions/rollup/](https://docs.datadoghq.com/dashboards/functions/rollup/)
21. [https://docs.datadoghq.com/dashboards/functions/timeshift/](https://docs.datadoghq.com/dashboards/functions/timeshift/)
22. [https://docs.datadoghq.com/dashboards/guide/how-to-graph-percentiles-in-datadog/](https://docs.datadoghq.com/dashboards/guide/how-to-graph-percentiles-in-datadog/)
23. [https://docs.datadoghq.com/dashboards/guide/maintain-relevant-dashboards/](https://docs.datadoghq.com/dashboards/guide/maintain-relevant-dashboards/)
24. [https://docs.datadoghq.com/dashboards/guide/powerpacks-best-practices/](https://docs.datadoghq.com/dashboards/guide/powerpacks-best-practices/)
25. [https://docs.datadoghq.com/dashboards/guide/rollup-cardinality-visualizations/](https://docs.datadoghq.com/dashboards/guide/rollup-cardinality-visualizations/)
26. [https://docs.datadoghq.com/dashboards/guide/tv_mode/](https://docs.datadoghq.com/dashboards/guide/tv_mode/)
27. [https://docs.datadoghq.com/dashboards/guide/unit-override/](https://docs.datadoghq.com/dashboards/guide/unit-override/)
28. [https://docs.datadoghq.com/dashboards/faq/historical-data/](https://docs.datadoghq.com/dashboards/faq/historical-data/)
29. [https://docs.datadoghq.com/api/latest/dashboards/](https://docs.datadoghq.com/api/latest/dashboards/)
30. [https://docs.datadoghq.com/getting_started/dashboards/](https://docs.datadoghq.com/getting_started/dashboards/)
31. [https://docs.datadoghq.com/getting_started/tagging/](https://docs.datadoghq.com/getting_started/tagging/)
32. [https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/](https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/)
33. [https://docs.datadoghq.com/metrics/types/](https://docs.datadoghq.com/metrics/types/)
34. [https://docs.datadoghq.com/metrics/distributions/](https://docs.datadoghq.com/metrics/distributions/)
35. [https://docs.datadoghq.com/metrics/summary/](https://docs.datadoghq.com/metrics/summary/)
36. [https://docs.datadoghq.com/metrics/advanced-filtering/](https://docs.datadoghq.com/metrics/advanced-filtering/)
37. [https://docs.datadoghq.com/metrics/custom_metrics/type_modifiers/](https://docs.datadoghq.com/metrics/custom_metrics/type_modifiers/)
38. [https://docs.datadoghq.com/metrics/faq/rollup-for-distributions-with-percentiles/](https://docs.datadoghq.com/metrics/faq/rollup-for-distributions-with-percentiles/)
39. [https://docs.datadoghq.com/metrics/guide/interpolation-the-fill-modifier-explained/](https://docs.datadoghq.com/metrics/guide/interpolation-the-fill-modifier-explained/)
40. [https://docs.datadoghq.com/monitors/guide/as-count-in-monitor-evaluations/](https://docs.datadoghq.com/monitors/guide/as-count-in-monitor-evaluations/)
41. [https://docs.datadoghq.com/logs/explorer/facets/](https://docs.datadoghq.com/logs/explorer/facets/)
42. [https://docs.datadoghq.com/logs/explorer/analytics/](https://docs.datadoghq.com/logs/explorer/analytics/)
43. [https://docs.datadoghq.com/logs/indexes/](https://docs.datadoghq.com/logs/indexes/)
44. [https://docs.datadoghq.com/logs/log_configuration/logs_to_metrics/](https://docs.datadoghq.com/logs/log_configuration/logs_to_metrics/)
45. [https://docs.datadoghq.com/tracing/metrics/metrics_namespace/](https://docs.datadoghq.com/tracing/metrics/metrics_namespace/)
46. [https://docs.datadoghq.com/tracing/trace_pipeline/trace_retention/](https://docs.datadoghq.com/tracing/trace_pipeline/trace_retention/)
47. [https://docs.datadoghq.com/real_user_monitoring/explorer/visualize/](https://docs.datadoghq.com/real_user_monitoring/explorer/visualize/)
48. [https://docs.datadoghq.com/data_security/data_retention_periods/](https://docs.datadoghq.com/data_security/data_retention_periods/)
49. [https://docs.datadoghq.com/notebooks/](https://docs.datadoghq.com/notebooks/)
50. [https://docs.datadoghq.com/mcp_server/](https://docs.datadoghq.com/mcp_server/)
51. [https://docs.datadoghq.com/mcp_server/setup/](https://docs.datadoghq.com/mcp_server/setup/)
52. [https://docs.datadoghq.com/mcp_server/tools/](https://docs.datadoghq.com/mcp_server/tools/)
53. [https://datadoghq.dev/integrations-core/guidelines/dashboards/](https://datadoghq.dev/integrations-core/guidelines/dashboards/)
54. [https://www.datadoghq.com/blog/dashboards-monitors-at-scale/](https://www.datadoghq.com/blog/dashboards-monitors-at-scale/)
55. [https://www.datadoghq.com/blog/monitoring-101-alerting/](https://www.datadoghq.com/blog/monitoring-101-alerting/)
56. [https://github.com/datadog-labs/mcp-server](https://github.com/datadog-labs/mcp-server)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |