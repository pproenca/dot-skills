---
title: Treat a missing metric as stale, not as absent
tags: disco, discovery, retention, age-out
---

## Treat a missing metric as stale, not as absent

Discovery returning nothing for `batch.nightly.duration` invites the conclusion "that metric does not exist, I will use something else" — and for any metric that reports on a schedule rather than continuously, that conclusion is usually wrong. Datadog's discovery surfaces are windowed, and the windows are short: metrics that have not reported in the last **24 hours** drop out of the query editor, tag values age out of non-template dropdowns after **12 hours**, and hosts disappear after **2 hours**. A nightly job, a weekly reconciliation, a seasonal metric, anything behind a feature flag that is currently off — all are absent from discovery while being perfectly real.

The data is still there. Retention is measured in months, not hours: metric tags and values are retained for **15 months**. Datadog states the gap plainly — *"Even though the data is not listed, you can still query the data with the JSON editor."* So the correct response to an empty discovery result is to widen the window and ask the user, not to substitute a different metric or report the metric as nonexistent.

```text
empty discovery result -> widen the search window before concluding anything
                       -> ask: "does <metric> report on a schedule, or is it off right now?"
                       -> if it is real, write the query anyway; it will populate when it reports
never                  -> silently substitute a metric that happens to be reporting
```

The same asymmetry governs template variables and is the more common trip hazard, because it degrades a *working* dashboard rather than blocking a new one. Values for metric and cloud-cost variables come from the last **48 hours**; values for every other source come from **the dashboard's current time frame**. A board opened at "last 15 minutes" offers only the log and APM tag values seen in those 15 minutes, so a `$service` dropdown looks short and wrong on a quiet Sunday and complete on a Tuesday afternoon.

```json
{
  "template_variables": [
    { "name": "service", "prefix": "service", "defaults": ["checkout"] }
  ],
  "default_timeframe": { "type": "live", "value": 4, "unit": "hour" }
}
```

Setting a default time frame wide enough to populate the variables is the fix — a dashboard whose variables only work after the reader widens the window will be read as broken.

Reference: [Historical data FAQ](https://docs.datadoghq.com/dashboards/faq/historical-data/) · [Template Variables](https://docs.datadoghq.com/dashboards/template_variables/) · [Data retention periods](https://docs.datadoghq.com/data_security/data_retention_periods/)
