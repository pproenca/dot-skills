---
title: {Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: "{Quantified impact, e.g., 'prevents admin confusion', 'eliminates config-test surprises'}"
tags: {prefix}, {technique}, {related-concepts}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters for nginx admins. Focus on the admin experience and configuration clarity.}

**Incorrect ({what's wrong}):**

```c
/* ngx_command_t entry */
{Bad directive design — production-realistic, not strawman}
```

```nginx
# nginx.conf usage showing the admin-facing problem
{Bad config example showing confusion or error}
```

**Correct ({what's right}):**

```c
/* ngx_command_t entry */
{Good directive design — minimal diff from incorrect}
```

```nginx
# nginx.conf usage showing clear admin experience
{Good config example showing clarity}
```

{Optional sections as needed:}

**When NOT to use this pattern:**
- {Exception 1}
- {Exception 2}

**Benefits:**
- {Benefit 1 — from the admin's perspective}
- {Benefit 2 — from the module author's perspective}

Reference: [{Reference Title}]({Reference URL})
