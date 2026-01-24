---
title: Use Unique Descriptive Rule IDs
impact: MEDIUM
impactDescription: prevents rule conflicts and enables suppression
tags: org, rule-id, naming, uniqueness
---

## Use Unique Descriptive Rule IDs

Rule IDs must be unique across the entire project. Use descriptive names that indicate the rule's purpose and enable targeted suppression.

**Incorrect (vague IDs that may conflict):**

```yaml
id: rule1
# or
id: no-bad-code
# or
id: check
```

**Correct (descriptive, namespaced IDs):**

```yaml
id: security/no-eval-usage
# or
id: react-hooks/exhaustive-deps
# or
id: typescript/no-explicit-any
```

**ID naming conventions:**
- Use lowercase with hyphens: `no-console-log`
- Add category prefix: `security/`, `style/`, `react/`
- Be specific: `no-dynamic-require` not `no-require`
- Match file name to ID when possible

**Why unique IDs matter:**

```javascript
// Developers suppress by ID
// ast-grep-ignore: security/no-eval-usage
eval(userInput)

// Vague IDs make suppression dangerous
// ast-grep-ignore: check  // What does this suppress?
```

**Validation:**

```bash
# ast-grep test will fail on duplicate IDs
ast-grep test -c sgconfig.yml
```

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)
