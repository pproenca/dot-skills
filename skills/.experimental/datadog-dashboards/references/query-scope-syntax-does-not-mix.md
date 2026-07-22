---
title: Keep symbolic and functional filter syntax out of the same scope
tags: query, filters, scope, wildcards
---

## Keep symbolic and functional filter syntax out of the same scope

Datadog accepts two filter dialects and they cannot be combined inside one set of braces. The symbolic dialect uses `,` for AND and `!` for negation; the functional dialect uses `AND`, `OR`, `NOT`, `IN`, `NOT IN`. Mixing them produces a query Datadog rejects as invalid, and the natural thing to write mixes them — the comma form is what every simple example uses, and `!` is the obvious way to exclude something, so bolting an `AND` onto a familiar scope is the default move.

**Incorrect (symbolic `!` with functional `AND` — rejected as invalid):**

```text
avg:system.cpu.user{env:prod AND !region:us-east}
```

**Correct (functional throughout):**

```text
avg:system.cpu.user{env:prod AND NOT region:us-east}
```

The functional dialect is the one to reach for by default, because it is the only one that expresses grouping and set membership:

```text
avg:system.cpu.user{env:staging AND (availability-zone:us-east-1a OR availability-zone:us-east-1c)}
avg:system.cpu.user{env:prod AND location NOT IN (atlanta,seattle,las-vegas)}
```

Note the asymmetry in multi-tag semantics: including several tags is AND logic, excluding several is OR logic. Wildcards work as prefix, suffix, and substring, and combine with either dialect — `service:*-canary`, `region:*east*`, `!device:/dev/loop*`.

The one place a wildcard silently fails is after a template variable. `$env*` is not expanded and re-wildcarded; Datadog matches the literal string, so a variable resolving to `dev` searches for the exact value `dev*` and returns nothing. An empty graph produced this way reads as "no problem here", which is the worst possible failure for a scope filter. When the intent is a dynamic prefix, build it from the variable's value component instead:

```text
sum:kubernetes.pods.running{service:$service.value}.as_count()
```

Reference: [Advanced filtering](https://docs.datadoghq.com/metrics/advanced-filtering/) · [Template Variables](https://docs.datadoghq.com/dashboards/template_variables/)
