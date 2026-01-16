---
title: Differentiate Similar Skills with Distinct Triggers
impact: CRITICAL
impactDescription: prevents skill conflicts and unpredictable activation
tags: desc, conflicts, disambiguation, multiple-skills
---

## Differentiate Similar Skills with Distinct Triggers

When multiple skills cover overlapping domains, use distinct trigger terms to ensure the right skill activates. Overlapping descriptions cause unpredictable behavior—sometimes one skill wins, sometimes the other.

**Incorrect (overlapping descriptions cause conflicts):**

```yaml
# skills/excel-export/SKILL.md
---
name: excel-export
description: Works with Excel files and data export
---

# skills/data-analysis/SKILL.md
---
name: data-analysis
description: Analyzes data and exports to Excel
---
# Both mention "Excel" and "data"
# User says "export to Excel" - which skill wins?
# Unpredictable activation on every request
```

**Correct (distinct trigger domains):**

```yaml
# skills/excel-export/SKILL.md
---
name: excel-export
description: Exports query results and datasets to Excel spreadsheets with formatting. This skill should be used when the user wants to create Excel reports or download data as .xlsx files.
---

# skills/data-analysis/SKILL.md
---
name: data-analysis
description: Analyzes datasets using statistical methods, generates insights, and creates visualizations. This skill should be used when the user wants to explore data, find patterns, or create charts.
---
# "Excel reports" vs "explore data"
# ".xlsx files" vs "create charts"
# Clear separation of concerns
```

**Disambiguation strategies:**
- Use different file formats as triggers
- Reference different workflow stages (create vs. analyze)
- Mention different output types (spreadsheet vs. visualization)

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
