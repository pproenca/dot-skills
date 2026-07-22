---
title: Read a top-N total as a subtotal of the rows shown
tags: query, top-n, grouping, truncation
---

## Read a top-N total as a subtotal of the rows shown

A top list with a total at the bottom invites reading that total as the total. It is the sum of the displayed rows only, and Datadog says so: *"The subtotal may differ from the actual sum of values in a group since only a subset (top or bottom) is displayed. Events with a null or empty value for this dimension are not displayed as a sub-group."* Two separate exclusions are folded into that sentence — everything below the cut, and everything with no value for the grouping dimension at all. On a metric where half the series lack the tag, a "total" can be short by half with nothing on the widget indicating it.

Group-by truncation is not optional. `top()` caps at 100 series, event-platform `group_by` carries its own `limit`, and the widget itself may sort and cut again. So the question is never whether truncation happened but whether the widget's label admits it.

```text
top(sum:aws.s3.bucket_size_bytes{env:prod} by {bucketname}, 10, 'max', 'desc')
```

Title that panel "Top 10 buckets by size", not "Storage by bucket". The honest title costs nothing and stops the number being read as complete. When the true total genuinely matters, put it in its own ungrouped `query_value` widget beside the list, where no grouping can truncate it.

Two grouping behaviours compound this and are easy to miss. With multiple dimensions the top-N is **nested**, not global — top values are found for the first dimension, then the top values of the second *within* those, so a global outlier hiding under an unpopular first-level group never appears. And a log or event carrying multiple values for the grouping tag is counted in each group: Datadog notes *"a log with the `team:sre` and the `team:marketplace` tags are counted once in each aggregate"*, so group totals can exceed the true total while each row is individually correct.

`exclude_null()` removes groups with N/A tag values, which cleans up a graph but is aggressive with several group-by keys — it drops any group with an N/A in **any** of them, halving the group count in Datadog's own example. That is a display decision, and it moves the subtotal again.

Reference: [Rank functions](https://docs.datadoghq.com/dashboards/functions/rank/) · [RUM visualizations](https://docs.datadoghq.com/real_user_monitoring/explorer/visualize/) · [Log analytics](https://docs.datadoghq.com/logs/explorer/analytics/) · [Exclusion functions](https://docs.datadoghq.com/dashboards/functions/exclusion/)
