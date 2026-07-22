---
title: Fix the audience and the decision before the first widget
tags: scope, requirements, audience, dashboard-purpose
---

## Fix the audience and the decision before the first widget

Asked for "a dashboard for the checkout service", the default is to start emitting widgets — CPU, memory, request rate, error rate — because those are the metrics that exist, not because anyone needs them. The result is a plausible board that answers no question in particular, which is why Datadog's dashboard-hygiene guidance is largely about finding and deleting them. The audience determines the altitude and therefore every subsequent choice: an on-call engineer needs symptom-level signals at the top and resource detail below, while a director needs outcomes with no implementation detail at all. Datadog states the constraint directly — *"An executive who owns company-wide revenue needs a very different view from a product director responsible for a single line of business"* — and frames the design task as surfacing answers to questions you already ask regularly, adding that it is *"important not to cram all of those thoughts into the same dashboard."*

Get four answers before building. If the answer to the second is "none", the artifact is wrong — see `scope-not-every-question-is-a-dashboard`.

```text
1. Who opens this, and when?
   on-call during an incident | service team weekly | platform/SRE | leadership
2. What decision or action does it drive?
   "page someone" | "roll back" | "approve the capacity spend" | "none"
3. What 3-7 questions must it answer, in priority order?
   each one becomes a widget; a widget with no question behind it gets cut
4. Fixed scope, or scoped at read time?
   which env / service / team values, and which of those become variables
```

Those answers are not scratch notes — they belong in the dashboard itself, so the next person inherits the intent rather than re-deriving it. The `description` field renders Markdown and is the documented place for *"what a dashboard is for and how to use it"*, and a title carrying service and purpose (`Checkout - Prod On-Call`) is what makes it findable among thousands.

```json
{
  "title": "Checkout - Prod On-Call",
  "description": "Answers: are we burning error budget, is checkout latency degraded, and did a deploy cause it?\n\nOpen this first during a checkout page. Resource panels are below the fold and are causes, not symptoms.\n\nOwner: #team-checkout",
  "tags": ["team:checkout"],
  "layout_type": "ordered"
}
```

Reference: [Getting Started with Dashboards](https://docs.datadoghq.com/getting_started/dashboards/) · [Building dashboards and monitors at scale](https://www.datadoghq.com/blog/dashboards-monitors-at-scale/)
