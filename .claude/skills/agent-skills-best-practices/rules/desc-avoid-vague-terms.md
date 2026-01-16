---
title: Avoid Vague Terms in Descriptions
impact: CRITICAL
impactDescription: prevents false positives and misactivations
tags: desc, clarity, precision, anti-pattern
---

## Avoid Vague Terms in Descriptions

Generic words like "helps", "manages", "handles", and "works with" trigger on too many unrelated requests. Use precise action verbs that match specific user intents.

**Incorrect (vague verbs cause over-triggering):**

```yaml
---
name: data-helper
description: Helps with data. Works with various data formats and manages data operations.
---
# "Helps with data" - triggers on ANY data mention
# "Works with" - matches everything
# "Manages" - too generic
# User asks about database schema - wrong skill activates
```

**Correct (precise verbs limit scope):**

```yaml
---
name: csv-parser
description: Parses CSV files into structured data, validates column types, and converts to JSON or database records. This skill should be used when importing CSV data or converting spreadsheet exports.
---
# "Parses CSV" - specific format and action
# "validates column types" - specific operation
# "converts to JSON" - concrete output
# Only triggers on actual CSV work
```

**Replace vague terms:**
| Vague | Precise |
|-------|---------|
| helps with | extracts, validates, converts |
| manages | schedules, deploys, monitors |
| handles | parses, transforms, routes |
| works with | reads, writes, streams |
| deals with | resolves, retries, escalates |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
