---
title: Use Debug Query to Inspect AST Structure
impact: CRITICAL
impactDescription: 5-10× faster pattern debugging
tags: pattern, debugging, ast, tree-sitter
---

## Use Debug Query to Inspect AST Structure

When patterns don't match expected code, use `--debug-query` to inspect the actual AST structure. Misunderstanding node types is the most common pattern failure.

**Incorrect (assumes wrong AST structure):**

```yaml
id: find-arrow-function
language: javascript
rule:
  kind: function  # Wrong! Arrow functions are arrow_function
```

**Correct (verified with debug-query):**

```bash
# First, inspect the AST
ast-grep run --debug-query '() => {}' -l javascript
# Output shows: arrow_function

# Then use correct kind
```

```yaml
id: find-arrow-function
language: javascript
rule:
  kind: arrow_function
```

**Debugging workflow:**
1. Write minimal code example containing the pattern
2. Run `ast-grep run --debug-query 'your code' -l language`
3. Examine node kinds and structure in output
4. Adjust pattern to match actual AST

**Tip:** Use the playground's AST viewer tab for interactive exploration.

Reference: [CLI Reference](https://ast-grep.github.io/reference/cli.html)
