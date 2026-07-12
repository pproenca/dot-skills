---
title: Honor the hook id and phx-update ignore contract
tags: ui, hooks, phx-update, dom-patching
---

## Honor the hook id and phx-update ignore contract

Client hooks and third-party widgets live inside DOM that LiveView patches, and the integration contract has three legs the docs state verbatim: "when using `phx-hook`, a unique DOM ID must always be set" (LiveView tracks the hook's lifecycle across patches by that id); DOM a hook or external library builds in `mounted()` needs `phx-update="ignore"` on its container, or the next server diff wipes the widget's mutations; and on an ignored element, updates are skipped "except for data attributes" — so server-to-widget data flows through `data-*` attributes only, and anything passed via other attributes silently never arrives. Colocated hooks (`<script :type={Phoenix.LiveView.ColocatedHook} name=".BidChart">`, LiveView 1.1+) are the modern placement, but placement is not gated — an `app.js` hook passes equally.

**Evidence of violation:** an element with `phx-hook` and no `id`; a `phx-update` container without an `id`; a hook whose `mounted()` creates or mutates child DOM (chart, editor, map) on a container lacking `phx-update="ignore"`; or an ignored element receiving changing server state through a non-`data-*` attribute. PASS: cite the id + `phx-update="ignore"` + `data-*` wiring per hook. N/A: no hooks and no `phx-update` containers in the target. Carve-out (citable): a hook that only reads or listens (no DOM writes in any callback) needs no `ignore` — cite the hook body, otherwise fail closed.

```heex
<div
  id={"bid-chart-#{@lot.id}"}
  phx-hook=".BidChart"
  phx-update="ignore"
  data-points={Jason.encode!(@bid_points)}
>
</div>
<script :type={Phoenix.LiveView.ColocatedHook} name=".BidChart">
  export default {
    mounted() { this.chart = renderChart(this.el, this.el.dataset.points) },
    updated() { this.chart.update(this.el.dataset.points) }
  }
</script>
```

Reference: [JS interop — client hooks](https://hexdocs.pm/phoenix_live_view/js-interop.html), [Bindings — DOM patching](https://hexdocs.pm/phoenix_live_view/bindings.html)
