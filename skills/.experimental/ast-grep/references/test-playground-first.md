---
title: Test Patterns in Playground First
impact: LOW-MEDIUM
impactDescription: 5-10× faster pattern iteration
tags: test, playground, debugging, iteration
---

## Test Patterns in Playground First

Use the ast-grep playground for rapid pattern iteration. The interactive environment shows matches immediately and displays AST structure.

**Incorrect (edit-deploy-test cycle):**

```bash
# Slow feedback loop
vim rule.yml
ast-grep scan --rule rule.yml src/
# No matches... why?
vim rule.yml
# Repeat...
```

**Correct (playground iteration):**

```text
1. Open https://ast-grep.github.io/playground.html
2. Select target language
3. Paste sample code in Code panel
4. Write pattern in Pattern panel
5. See immediate match highlighting
6. Refine until pattern works
7. Export to YAML rule file
```

**Playground features:**
- Real-time match highlighting
- AST viewer tab shows node structure
- Share patterns via URL
- Multiple language support
- Pattern object support (context/selector)

**Debugging workflow:**

```text
# Pattern not matching?

1. Check AST tab - verify node types
2. Simplify pattern to minimum
3. Add complexity incrementally
4. Use --debug-query for CLI comparison:

ast-grep run --debug-query 'your pattern' -l javascript
```

**When playground differs from CLI:**
- Parser versions may differ
- UTF-8 vs UTF-16 encoding differences
- Use `--debug-query` for authoritative AST

Reference: [Playground](https://ast-grep.github.io/playground.html)
