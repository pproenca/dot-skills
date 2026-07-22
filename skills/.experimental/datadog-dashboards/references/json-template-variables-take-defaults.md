---
title: Declare template variable defaults as an array
tags: json, template-variables, deprecation, presets
---

## Declare template variable defaults as an array

The singular `default` field is the one in older examples, and it still parses — but it is deprecated, and the API notes it *"Cannot be used in conjunction with `defaults`."* The replacement is a plural array, and the change is not cosmetic: multiple defaults are **unioned with OR**, so a variable can open scoped to staging *and* prod, which the singular form cannot express at all. Writing `default` forgoes that and leaves a deprecated field in a dashboard someone will have to migrate.

**Incorrect (deprecated singular field, cannot express multiple values):**

```json
{
  "template_variables": [
    { "name": "env", "prefix": "env", "default": "prod" }
  ]
}
```

**Correct (plural array, values OR'd together):**

```json
{
  "template_variables": [
    { "name": "env", "prefix": "env", "defaults": ["prod", "staging"] },
    { "name": "service", "prefix": "service", "defaults": ["checkout"] },
    { "name": "region", "prefix": "region", "type": "group" }
  ]
}
```

Presets carry the identical deprecation one level down — `value` singular is deprecated in favour of `values`, an array requiring at least one entry. A preset is the right home for "the prod view" and "the staging view" of one dashboard, and gets them without duplicating the board:

```json
{
  "template_variable_presets": [
    { "name": "Production",
      "template_variables": [
        { "name": "env", "values": ["prod"] },
        { "name": "service", "values": ["checkout", "payments-api"] }
      ] }
  ]
}
```

The `type` field distinguishes what a variable does to the query: filter variables interpolate into the scope, while `group` variables interpolate into the `by` clause, so one dashboard can offer "break this down by region" as a control rather than as a second widget. `prefix` restricts the dropdown to tags with that key, and `available_values` restricts further to an explicit list — both worth setting, because an unfiltered dropdown on a large org is unusable. The wildcard `*` is always present regardless.

Reference: [Create a new dashboard](https://docs.datadoghq.com/api/latest/dashboards/) · [Template Variables](https://docs.datadoghq.com/dashboards/template_variables/)
