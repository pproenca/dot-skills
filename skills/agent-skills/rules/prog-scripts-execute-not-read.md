---
title: Execute Scripts Instead of Reading Code
impact: MEDIUM-HIGH
impactDescription: reduces token usage by 90% for complex operations
tags: prog, scripts, execution, tokens
---

## Execute Scripts Instead of Reading Code

Place executable scripts in `scripts/` directory and have Claude run them rather than reading code into context. Script execution uses zero context tokens while delivering the same results.

**Incorrect (reading script into context):**

```markdown
# SKILL.md

## Data Processing

Read the processing script and follow its logic:

```python
# scripts/process.py - 200 lines
import pandas as pd
import json

def process_data(input_file, output_format):
    df = pd.read_csv(input_file)
    # ... 180 more lines of processing logic
    return result
```

Use this logic to process user's data.
```

```text
# 200 lines of code in context
# ~400 tokens consumed
# Claude tries to mentally execute code
# Error-prone and slow
```

**Correct (execute script, describe interface):**

```markdown
# SKILL.md

## Data Processing

Process data using the bundled script:

```bash
python scripts/process.py --input data.csv --format json
```

**Arguments:**
- `--input`: Input CSV file path
- `--format`: Output format (json, csv, markdown)
- `--output`: Optional output file (defaults to stdout)

The script handles data validation, transformation, and formatting.
```

```text
# ~10 lines describing interface
# ~20 tokens consumed
# Script executes with full capability
# Results returned directly
```

**When to read vs. execute:**
| Scenario | Approach |
|----------|----------|
| Complex data processing | Execute script |
| API interactions | Execute script |
| Simple transformations | Inline instructions |
| Teaching/explaining | Read into context |

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
