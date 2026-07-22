---
title: Pin the rollup when a number has to mean the same thing at every time frame
tags: query, rollup, time-frames, cardinality
---

## Pin the rollup when a number has to mean the same thing at every time frame

A widget is usually treated as showing a fixed quantity, with the time frame choosing only how much history is visible. It does not. Datadog picks the rollup interval from the visible window — 20 seconds at an hour, 5 minutes at a day, 4 hours at a month — so widening the window changes what each point aggregates and therefore what the number *is*. A count panel showing "orders" shows orders per 20 seconds at one zoom level and orders per 4 hours at another. Both are correct; neither is comparable to the other, and nothing on the widget says which one you are looking at.

This becomes an inconsistency rather than a curiosity when two widgets on the same board carry different local time frames. They are then aggregating over different intervals, so placing them side by side invites a comparison that is not valid. When a value must be stable and comparable, state the interval instead of inheriting it.

```text
sum:checkout.orders.placed{env:prod}.as_count().rollup(sum, 3600)
```

An explicit interval is a request, not a guarantee: the backend caps points per series, so a fine interval over a long window is silently raised rather than honoured. Datadog documents the cap as *"up to a limit of 1500 points,"* noting that this *"supports up to one point per minute over a day"* — so a one-minute rollup across two months returns something much coarser than asked for, with no indication on the widget. Published figures differ between pages (the querying docs say about 300), so pick the interval from the window you intend to display rather than working back from a cap. For period-over-period reporting, calendar-aligned rollups respect real month and week boundaries and daylight saving, which arithmetic offsets do not:

```text
sum:checkout.orders.placed{env:prod}.as_count().rollup(sum, weekly, monday, 'America/New_York')
```

Two related distortions. Unique counts do not sum across windows and cannot be fixed with modifiers — Datadog's worked example is seven days of 100 daily users totalling 400 unique users, not 700 — and a *ratio* of `cardinality` queries reads higher at a 30-minute rollup than at 5 minutes, because a subject recurring inside the window appears once in the denominator and repeatedly in the numerator. Treat any unique-count panel as valid only at the window it was designed for, and label it accordingly.

Separately, `week_before()`, `day_before()`, and `month_before()` are deprecated in favour of `calendar_shift()`. `month_before()` meant 28 days rather than a calendar month, so existing month-over-month panels built on it are comparing the wrong window:

```text
calendar_shift(sum:checkout.orders.placed{env:prod}.as_count(), "-1mo", "America/New_York")
```

Reference: [Rollup](https://docs.datadoghq.com/dashboards/functions/rollup/) · [Rollup and cardinality in visualizations](https://docs.datadoghq.com/dashboards/guide/rollup-cardinality-visualizations/) · [Timeshift functions](https://docs.datadoghq.com/dashboards/functions/timeshift/)
