---
title: Separate the Construct From the Proxy You Actually Compute
impact: CRITICAL
impactDescription: prevents the cyclomatic-equals-complexity category error
tags: def, construct, proxy, validity
---

## Separate the Construct From the Proxy You Actually Compute

Every computed metric is a proxy standing in for an unobservable construct. Collapsing the two — writing "this measures complexity" when the code measures decision count — quietly converts an empirical claim (the proxy tracks the construct) into a definition, so the claim is never tested and the proxy's blind spots become invisible. Keep three things explicitly distinct in the spec: the construct, the proxy, and the *assumed link* between them. That link is exactly what construct validity later has to earn.

**Incorrect (proxy presented as the construct):**

```yaml
# metric-spec.yaml
metric: maintainability
formula: 171 - 5.2*ln(halstead_volume) - 0.23*cyclomatic - 16.2*ln(loc)  # the classic MI
# "maintainability" IS this formula here, so its known weakness — it barely moves for
# genuinely tangled code that happens to be short — can never even be questioned.
```

**Correct (construct, proxy, and link kept separate):**

```yaml
metric: maintainability_index
construct: maintenance_effort      # engineer-hours to make an average change safely
proxy: 171 - 5.2*ln(halstead_volume) - 0.23*cyclomatic - 16.2*ln(loc)
assumed_link: proxy is monotonically decreasing in maintenance_effort   # a CLAIM
validity_evidence: references/valid-converge-with-accepted-measure.md   # must be measured
```

Reference: [Fenton & Bieman, *Software Metrics: A Rigorous and Practical Approach*, 3rd ed.](https://www.routledge.com/Software-Metrics-A-Rigorous-and-Practical-Approach-Third-Edition/Fenton-Bieman/p/book/9781439838228)
