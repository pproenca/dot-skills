---
title: Include File Type Patterns in Description
impact: HIGH
impactDescription: enables context-aware skill activation
tags: trigger, file-types, extensions, context
---

## Include File Type Patterns in Description

When a skill processes specific file types, mention those extensions and formats. Claude uses file context to select appropriate skills, so explicit file type mentions improve activation accuracy.

**Incorrect (no file types mentioned):**

```yaml
---
name: spreadsheet-analyzer
description: Analyzes data and generates reports from spreadsheets.
---
```

```text
# User has .xlsx file open - skill doesn't know
# User mentions "Excel file" - might trigger
# User mentions ".csv" - doesn't trigger
# File context not leveraged
```

**Correct (explicit file types in description):**

```yaml
---
name: spreadsheet-analyzer
description: Analyzes data from Excel (.xlsx, .xls) and CSV files, generating statistical reports and visualizations. This skill should be used when working with spreadsheet files, Excel documents, or CSV data exports.
---
```

```text
# User has .xlsx file - skill knows it applies
# User mentions "CSV" - skill triggers
# File context enables smart activation
```

**File type patterns to include:**
| Domain | Extensions to mention |
|--------|----------------------|
| Documents | .pdf, .docx, .doc, .txt |
| Spreadsheets | .xlsx, .xls, .csv, .tsv |
| Code | .ts, .js, .py, .go, .rs |
| Config | .json, .yaml, .toml, .env |
| Images | .png, .jpg, .svg, .webp |

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
