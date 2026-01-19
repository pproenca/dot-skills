---
title: Validate Workflows Before Running
impact: MEDIUM-HIGH
impactDescription: prevents 100% of schema and dependency errors
tags: workflow, validation, schema, errors
---

## Validate Workflows Before Running

Always run `workflow validate` before executing workflows. Validation catches schema errors, missing dependencies, and cyclic references.

**Incorrect (running without validation):**

```bash
# Directly run without checking
npx codemod workflow run -w ./workflow.yaml

# Errors discovered mid-execution:
# - Missing codemod file at step 3
# - Invalid YAML syntax at line 47
# - Cyclic dependency between nodes
# - Unknown step type "jscodeshift"
```

**Correct (validate first):**

```bash
# Validate workflow configuration
npx codemod workflow validate -w ./workflow.yaml

# Output shows all issues:
# ✓ Schema validation passed
# ✓ All codemod files exist
# ✓ No cyclic dependencies
# ✗ Error: Unknown step type "jscodeshift" at node "migrate"
#   Hint: Did you mean "js-ast-grep"?

# Fix errors, then run
npx codemod workflow run -w ./workflow.yaml
```

**Validation checks:**
- YAML syntax and schema compliance
- Node dependency DAG (no cycles)
- Referenced files exist (codemods, rules)
- Step types are valid
- Parameter schemas match usage

**CI integration:**

```yaml
# .github/workflows/validate.yml
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npx codemod workflow validate -w ./workflow.yaml
```

Reference: [Codemod CLI](https://docs.codemod.com/cli)
