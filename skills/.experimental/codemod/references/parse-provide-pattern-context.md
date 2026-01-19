---
title: Provide Context for Ambiguous Patterns
impact: CRITICAL
impactDescription: prevents 100% of ambiguous pattern failures
tags: parse, ambiguity, context, pattern-object
---

## Provide Context for Ambiguous Patterns

Some code snippets are syntactically ambiguous without context. Use the pattern object form to provide surrounding context that disambiguates the pattern.

**Incorrect (ambiguous pattern):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Is '{a, b}' an object or destructuring?
  const matches = root.findAll({
    rule: { pattern: "{ $A, $B }" }
  });
  // Parser guesses wrong, matches fail silently

  // Is '() => x' a return or function body?
  const arrows = root.findAll({
    rule: { pattern: "() => $EXPR" }
  });
  // Ambiguous without statement context
  return null;
};
```

**Correct (context-providing pattern object):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Explicit: match object literal destructuring in assignment
  const destructuring = root.findAll({
    rule: {
      pattern: {
        context: "const { $A, $B } = obj",
        selector: "object_pattern"
      }
    }
  });

  // Explicit: match object literal in expression position
  const objectLiterals = root.findAll({
    rule: {
      pattern: {
        context: "const x = { $A, $B }",
        selector: "object"
      }
    }
  });

  // Explicit: arrow function with implicit return
  const arrows = root.findAll({
    rule: {
      pattern: {
        context: "const fn = () => $EXPR",
        selector: "arrow_function"
      }
    }
  });

  return null;
};
```

**When to use pattern object:**
- Destructuring patterns (`{ a, b }` vs `{ a: 1 }`)
- Arrow functions (implicit vs block body)
- JSX fragments vs comparison operators
- Generic syntax (`<T>` type vs JSX)

Reference: [ast-grep Pattern Parse](https://ast-grep.github.io/advanced/pattern-parse.html)
