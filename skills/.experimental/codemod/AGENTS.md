# Codemod

**Version 0.1.0**  
Codemod Community  
January 2026

> **Note:** Codemod best practices guide for agents and LLMs.
> This document is optimized for AI-assisted writing, reviewing, and debugging of
> Codemod transformations. Humans may also find it useful as a comprehensive reference.

---

## Abstract

Comprehensive best practices guide for Codemod (JSSG, ast-grep, workflows), designed for AI agents and LLMs. Contains 48 rules across 11 categories, prioritized by impact from critical (AST understanding, pattern efficiency, parsing strategy) to incremental (security, package structure). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [AST Understanding](#1-ast-understanding) — **CRITICAL**
   - 1.1 [Check Null Before Property Access](#11-check-null-before-property-access)
   - 1.2 [Understand Named vs Anonymous Nodes](#12-understand-named-vs-anonymous-nodes)
   - 1.3 [Use AST Explorer Before Writing Patterns](#13-use-ast-explorer-before-writing-patterns)
   - 1.4 [Use Field Access for Structural Queries](#14-use-field-access-for-structural-queries)
   - 1.5 [Use kind Constraint for Precision](#15-use-kind-constraint-for-precision)
2. [Pattern Efficiency](#2-pattern-efficiency) — **CRITICAL**
   - 2.1 [Avoid Overly Generic Patterns](#21-avoid-overly-generic-patterns)
   - 2.2 [Combine Patterns with Rule Operators](#22-combine-patterns-with-rule-operators)
   - 2.3 [Ensure Patterns Are Idempotent](#23-ensure-patterns-are-idempotent)
   - 2.4 [Use Constraints for Reusable Matching Logic](#24-use-constraints-for-reusable-matching-logic)
   - 2.5 [Use Meta Variables for Flexible Matching](#25-use-meta-variables-for-flexible-matching)
   - 2.6 [Use Relational Patterns for Context](#26-use-relational-patterns-for-context)
3. [Parsing Strategy](#3-parsing-strategy) — **CRITICAL**
   - 3.1 [Early Return for Non-Applicable Files](#31-early-return-for-non-applicable-files)
   - 3.2 [Handle Embedded Languages with parseAsync](#32-handle-embedded-languages-with-parseasync)
   - 3.3 [Provide Context for Ambiguous Patterns](#33-provide-context-for-ambiguous-patterns)
   - 3.4 [Select the Correct Parser for File Type](#34-select-the-correct-parser-for-file-type)
4. [Node Traversal](#4-node-traversal) — **HIGH**
   - 4.1 [Cache Repeated Node Lookups](#41-cache-repeated-node-lookups)
   - 4.2 [Collect Multiple Patterns in Single Traversal](#42-collect-multiple-patterns-in-single-traversal)
   - 4.3 [Use find() for Single Match, findAll() for Multiple](#43-use-find-for-single-match-findall-for-multiple)
   - 4.4 [Use Sibling Navigation Efficiently](#44-use-sibling-navigation-efficiently)
   - 4.5 [Use stopBy to Control Traversal Depth](#45-use-stopby-to-control-traversal-depth)
5. [Semantic Analysis](#5-semantic-analysis) — **HIGH**
   - 5.1 [Cache Semantic Analysis Results](#51-cache-semantic-analysis-results)
   - 5.2 [Handle Null Semantic Analysis Results](#52-handle-null-semantic-analysis-results)
   - 5.3 [Use File Scope Semantic Analysis First](#53-use-file-scope-semantic-analysis-first)
   - 5.4 [Verify File Ownership Before Cross-File Edits](#54-verify-file-ownership-before-cross-file-edits)
6. [Edit Operations](#6-edit-operations) — **MEDIUM-HIGH**
   - 6.1 [Add Imports at Correct Position](#61-add-imports-at-correct-position)
   - 6.2 [Batch Edits Before Committing](#62-batch-edits-before-committing)
   - 6.3 [Handle Overlapping Edit Ranges](#63-handle-overlapping-edit-ranges)
   - 6.4 [Preserve Surrounding Formatting in Edits](#64-preserve-surrounding-formatting-in-edits)
   - 6.5 [Use flatMap for Conditional Edits](#65-use-flatmap-for-conditional-edits)
7. [Workflow Design](#7-workflow-design) — **MEDIUM-HIGH**
   - 7.1 [Order Nodes by Dependency](#71-order-nodes-by-dependency)
   - 7.2 [Use Conditional Steps for Dynamic Workflows](#72-use-conditional-steps-for-dynamic-workflows)
   - 7.3 [Use Manual Gates for Critical Steps](#73-use-manual-gates-for-critical-steps)
   - 7.4 [Use Matrix Strategy for Parallelism](#74-use-matrix-strategy-for-parallelism)
   - 7.5 [Validate Workflows Before Running](#75-validate-workflows-before-running)
8. [Testing Strategy](#8-testing-strategy) — **MEDIUM**
   - 8.1 [Choose Appropriate Test Strictness Level](#81-choose-appropriate-test-strictness-level)
   - 8.2 [Cover Edge Cases in Test Fixtures](#82-cover-edge-cases-in-test-fixtures)
   - 8.3 [Test on File Subset Before Full Run](#83-test-on-file-subset-before-full-run)
   - 8.4 [Update Test Fixtures Intentionally](#84-update-test-fixtures-intentionally)
   - 8.5 [Use Input/Expected Fixture Pairs](#85-use-inputexpected-fixture-pairs)
9. [State Management](#9-state-management) — **MEDIUM**
   - 9.1 [Log Progress for Long-Running Migrations](#91-log-progress-for-long-running-migrations)
   - 9.2 [Make Transforms Idempotent for Safe Reruns](#92-make-transforms-idempotent-for-safe-reruns)
   - 9.3 [Use State for Resumable Migrations](#93-use-state-for-resumable-migrations)
10. [Security and Capabilities](#10-security-and-capabilities) — **LOW-MEDIUM**
   - 10.1 [Minimize Requested Capabilities](#101-minimize-requested-capabilities)
   - 10.2 [Review Third-Party Codemods Before Running](#102-review-third-party-codemods-before-running)
   - 10.3 [Validate External Inputs Before Use](#103-validate-external-inputs-before-use)
11. [Package Structure](#11-package-structure) — **LOW**
   - 11.1 [Organize Package by Convention](#111-organize-package-by-convention)
   - 11.2 [Use Semantic Versioning for Packages](#112-use-semantic-versioning-for-packages)
   - 11.3 [Write Descriptive Package Metadata](#113-write-descriptive-package-metadata)

---

## 1. AST Understanding

**Impact: CRITICAL**

Understanding AST structure is foundational for all transformations. Wrong tree interpretation leads to incorrect matches, missed transformations, and broken code.

### 1.1 Check Null Before Property Access

**Impact: CRITICAL (prevents runtime crashes in transforms)**

AST navigation methods return `null` when nodes don't exist. Always check for null before accessing properties to prevent runtime crashes.

**Incorrect (assumes nodes exist):**

```typescript
const transform: Transform<TSX> = (root) => {
  const calls = root.findAll({ rule: { kind: "call_expression" } });

  const edits = calls.map(call => {
    // Crashes if callee is computed: obj[method]()
    const methodName = call.field("function").field("property").text();
    // Crashes if no arguments
    const firstArg = call.field("arguments").children()[0].text();

    return call.replace(`newMethod(${firstArg})`);
  });

  return root.commitEdits(edits);
};
```

**Correct (null-safe access):**

```typescript
const transform: Transform<TSX> = (root) => {
  const calls = root.findAll({ rule: { kind: "call_expression" } });

  const edits = calls.flatMap(call => {
    const callee = call.field("function");
    if (!callee) return [];

    const property = callee.field("property");
    if (!property) return [];

    const args = call.field("arguments");
    const firstArg = args?.children()[0];
    if (!firstArg) return [];

    const methodName = property.text();
    return [call.replace(`newMethod(${firstArg.text()})`)];
  });

  return root.commitEdits(edits);
};
```

**Best practices:**
- Use optional chaining (`?.`) for exploratory access
- Use explicit null checks before transformations
- Return empty arrays from `flatMap` for invalid nodes
- Use TypeScript's narrowing with `if` statements

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 1.2 Understand Named vs Anonymous Nodes

**Impact: CRITICAL (eliminates 80% of pattern matching failures)**

Tree-sitter distinguishes between named nodes (semantic) and anonymous nodes (punctuation, keywords). ast-grep patterns skip anonymous nodes by default, which affects pattern matching behavior.

**Incorrect (matching anonymous nodes explicitly):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Tries to match punctuation literally
  const matches = root.findAll({
    rule: { pattern: "{ $KEY: $VALUE }" }
  });
  // Fails because '{', ':', '}' are anonymous nodes
  // ast-grep skips them by default
  return null;
};
```

**Correct (matching named nodes only):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Match the named 'object' node with pair children
  const matches = root.findAll({
    rule: {
      kind: "object",
      has: {
        kind: "pair",
        has: [
          { field: "key", pattern: "$KEY" },
          { field: "value", pattern: "$VALUE" }
        ]
      }
    }
  });
  return null;
};
```

**Named vs Anonymous:**
- **Named**: `function_declaration`, `identifier`, `string` (semantic meaning)
- **Anonymous**: `{`, `}`, `:`, `;`, `const` (syntax punctuation)

Use `node.isNamed()` to check node type programmatically.

Reference: [ast-grep Core Concepts](https://ast-grep.github.io/advanced/core-concepts.html)

### 1.3 Use AST Explorer Before Writing Patterns

**Impact: CRITICAL (prevents hours of debugging invalid patterns)**

Always visualize the AST structure using AST Explorer before writing patterns. The tree structure often differs from what you expect based on source code appearance.

**Incorrect (guessing AST structure):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Assumes 'const x = 1' has a direct 'identifier' child
  const matches = root.findAll({
    rule: { pattern: "const $NAME = $VALUE" }
  });
  // Pattern fails because 'const' creates a lexical_declaration
  // with variable_declarator children, not direct identifiers
  return null;
};
```

**Correct (verified in AST Explorer):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Verified: lexical_declaration > variable_declarator > name, value
  const matches = root.findAll({
    rule: {
      kind: "variable_declarator",
      has: { field: "name", pattern: "$NAME" }
    }
  });
  // Pattern matches actual tree structure
  return null;
};
```

**Workflow:**
1. Paste target code in [astexplorer.net](https://astexplorer.net)
2. Select the correct parser (tree-sitter for ast-grep)
3. Click nodes to see their `kind` and field names
4. Write patterns matching the actual structure

Reference: [ast-grep Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

### 1.4 Use Field Access for Structural Queries

**Impact: CRITICAL (enables precise child selection in complex nodes)**

Tree-sitter nodes have named fields that provide semantic access to children. Use `field()` and field constraints instead of index-based child access.

**Incorrect (index-based access):**

```typescript
const transform: Transform<TSX> = (root) => {
  const functions = root.findAll({ rule: { kind: "function_declaration" } });

  for (const fn of functions) {
    // Index-based access is fragile
    const name = fn.children()[0];  // Might be 'async' keyword
    const params = fn.children()[1]; // Might be name if no async
    // Breaks with async functions, generators, type annotations
  }
  return null;
};
```

**Correct (field-based access):**

```typescript
const transform: Transform<TSX> = (root) => {
  const functions = root.findAll({ rule: { kind: "function_declaration" } });

  for (const fn of functions) {
    // Field access is semantic and stable
    const name = fn.field("name");      // Always the function name
    const params = fn.field("parameters"); // Always the params list
    const body = fn.field("body");      // Always the function body

    if (name && params) {
      console.log(`Function ${name.text()} has ${params.children().length} params`);
    }
  }
  return null;
};
```

**Common field names:**
- Functions: `name`, `parameters`, `body`, `return_type`
- Variables: `name`, `value`, `type`
- Calls: `function`, `arguments`
- Classes: `name`, `body`, `superclass`

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 1.5 Use kind Constraint for Precision

**Impact: CRITICAL (reduces false positives by 10x)**

Combine pattern matching with `kind` constraints to eliminate false positives. Patterns alone can match unintended code structures with similar text.

**Incorrect (pattern without kind constraint):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Pattern matches too broadly
  const matches = root.findAll({
    rule: { pattern: "console.log($ARG)" }
  });
  // Also matches: const console = { log: fn }; console.log(x)
  // And: "console.log(test)" in strings
  // And: // console.log(debug) in comments
  return null;
};
```

**Correct (pattern with kind constraint):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Constrain to actual call expressions only
  const matches = root.findAll({
    rule: {
      kind: "call_expression",
      pattern: "console.log($ARG)"
    }
  });
  // Only matches real console.log() calls
  // Ignores strings, comments, and shadowed variables
  return null;
};
```

**Common kind values:**
- `call_expression` - function calls
- `member_expression` - property access (a.b)
- `arrow_function` - arrow functions
- `function_declaration` - named functions
- `jsx_element` - JSX tags

Reference: [ast-grep Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

---

## 2. Pattern Efficiency

**Impact: CRITICAL**

Patterns are evaluated millions of times across large codebases. Inefficient or overly generic patterns create multiplicative performance problems.

### 2.1 Avoid Overly Generic Patterns

**Impact: CRITICAL (reduces matching time from minutes to seconds)**

Generic patterns match too many nodes, causing performance degradation and false positives. Add constraints to narrow the search space.

**Incorrect (too generic):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Matches EVERY function call in the codebase
  const matches = root.findAll({
    rule: { pattern: "$FN($$$ARGS)" }
  });
  // On a 10k file codebase: matches millions of nodes
  // Takes minutes to process

  // Then filters in JS - wasteful
  const consoleCalls = matches.filter(m =>
    m.getMatch("FN")?.text().startsWith("console")
  );
  return null;
};
```

**Correct (specific pattern):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Pattern specifies exact target
  const matches = root.findAll({
    rule: {
      kind: "call_expression",
      pattern: "console.$METHOD($$$ARGS)"
    }
  });
  // Matches only console.* calls
  // 1000x fewer matches, milliseconds to process

  return null;
};
```

**Specificity guidelines:**
- Include literal text where known (object names, method prefixes)
- Add `kind` constraints to limit node types
- Use `inside`/`has` to require structural context
- Avoid standalone `$VAR` patterns without context

Reference: [ast-grep Match Algorithm](https://ast-grep.github.io/advanced/match-algorithm.html)

### 2.2 Combine Patterns with Rule Operators

**Impact: CRITICAL (enables complex matching without multiple passes)**

Use rule operators (`any`, `all`, `not`) to compose complex matching logic in a single pass instead of multiple separate queries.

**Incorrect (multiple passes):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Three separate traversals
  const logCalls = root.findAll({ rule: { pattern: "console.log($$$)" } });
  const warnCalls = root.findAll({ rule: { pattern: "console.warn($$$)" } });
  const errorCalls = root.findAll({ rule: { pattern: "console.error($$$)" } });

  // Combine results manually
  const allCalls = [...logCalls, ...warnCalls, ...errorCalls];
  // 3x traversal time, complex deduplication needed
  return null;
};
```

**Correct (single pass with rule operators):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Single traversal with 'any' operator
  const allCalls = root.findAll({
    rule: {
      any: [
        { pattern: "console.log($$$ARGS)" },
        { pattern: "console.warn($$$ARGS)" },
        { pattern: "console.error($$$ARGS)" }
      ]
    }
  });

  // Or use pattern with meta variable
  const consoleCalls = root.findAll({
    rule: {
      pattern: "console.$METHOD($$$ARGS)",
      all: [
        { kind: "call_expression" },
        { not: { pattern: "console.table($$$)" } }
      ]
    }
  });

  return null;
};
```

**Rule operators:**
- `any: [rules]` - matches if ANY rule matches (OR)
- `all: [rules]` - matches if ALL rules match (AND)
- `not: rule` - matches if rule does NOT match
- `matches: "name"` - references named utility rule

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 2.3 Ensure Patterns Are Idempotent

**Impact: CRITICAL (prevents infinite transformation loops)**

Patterns should match only pre-transformation code, never post-transformation code. Running a codemod twice should produce the same result as running it once.

**Incorrect (non-idempotent pattern):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Pattern matches both old and new format
  const matches = root.findAll({
    rule: { pattern: "logger($$$ARGS)" }
  });

  const edits = matches.map(match => {
    const args = match.getMultipleMatches("ARGS");
    // Wraps logger() calls with timestamp
    return match.replace(`logger(Date.now(), ${args.map(a => a.text()).join(", ")})`);
  });

  // Running twice: logger(x) -> logger(Date.now(), x) -> logger(Date.now(), Date.now(), x)
  return root.commitEdits(edits);
};
```

**Correct (idempotent pattern):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Pattern specifically excludes already-transformed code
  const matches = root.findAll({
    rule: {
      pattern: "logger($$$ARGS)",
      not: {
        // Skip if first arg is Date.now()
        has: {
          field: "arguments",
          has: {
            kind: "call_expression",
            pattern: "Date.now()"
          }
        }
      }
    }
  });

  const edits = matches.map(match => {
    const args = match.getMultipleMatches("ARGS");
    return match.replace(`logger(Date.now(), ${args.map(a => a.text()).join(", ")})`);
  });

  // Running twice: logger(x) -> logger(Date.now(), x) -> no change
  return root.commitEdits(edits);
};
```

**Idempotency strategies:**
- Use `not` to exclude already-transformed patterns
- Check for sentinel values or markers
- Match specific old API signatures only
- Test by running codemod twice on same input

Reference: [Hypermod Best Practices](https://www.hypermod.io/docs/guides/best-practices)

### 2.4 Use Constraints for Reusable Matching Logic

**Impact: CRITICAL (eliminates pattern duplication across rules)**

Define named constraints for commonly used matching conditions. Reference them with `matches` to keep patterns DRY and maintainable.

**Incorrect (duplicated pattern logic):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Same string type check repeated everywhere
  const stringConcats = root.findAll({
    rule: {
      pattern: "$LEFT + $RIGHT",
      all: [
        { has: { pattern: "$LEFT", any: [
          { kind: "string" },
          { kind: "template_string" }
        ]}},
        { has: { pattern: "$RIGHT", any: [
          { kind: "string" },
          { kind: "template_string" }
        ]}}
      ]
    }
  });
  // Repeated in 10 other rules...
  return null;
};
```

**Correct (reusable constraints):**

```typescript
const transform: Transform<TSX> = (root) => {
  const stringConcats = root.findAll({
    rule: {
      pattern: "$LEFT + $RIGHT"
    },
    constraints: {
      LEFT: { matches: "STRING_LIKE" },
      RIGHT: { matches: "STRING_LIKE" }
    },
    utils: {
      STRING_LIKE: {
        any: [
          { kind: "string" },
          { kind: "template_string" },
          { kind: "string_fragment" }
        ]
      }
    }
  });
  // Reuse STRING_LIKE in other rules
  return null;
};
```

**Constraint patterns:**
- Define common type checks in `utils`
- Reference with `matches: "UTIL_NAME"`
- Use in `constraints` to bind meta variables
- Share across multiple rules in the same transform

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 2.5 Use Meta Variables for Flexible Matching

**Impact: CRITICAL (enables pattern reuse across variations)**

Meta variables (`$NAME`, `$$$ARGS`) capture arbitrary AST nodes, enabling flexible patterns that match code variations. Use single `$` for one node, triple `$$$` for multiple.

**Incorrect (hardcoded literals):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Only matches exact string "error"
  const matches = root.findAll({
    rule: { pattern: 'console.error("error")' }
  });
  // Misses: console.error(message), console.error(err.message)
  // Misses: console.error("Error:", details)
  return null;
};
```

**Correct (meta variables for flexibility):**

```typescript
const transform: Transform<TSX> = (root) => {
  // $ARG captures any single argument
  const singleArg = root.findAll({
    rule: { pattern: "console.error($ARG)" }
  });

  // $$$ARGS captures zero or more arguments
  const anyArgs = root.findAll({
    rule: { pattern: "console.error($$$ARGS)" }
  });

  // Access captured values
  for (const match of anyArgs) {
    const args = match.getMultipleMatches("ARGS");
    console.log(`Found ${args.length} arguments`);
  }

  return null;
};
```

**Meta variable syntax:**
- `$NAME` - captures exactly one node
- `$$$NAME` - captures zero or more nodes
- `$_` - anonymous single capture (don't need value)
- `$$$` - anonymous multiple capture

Reference: [ast-grep Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

### 2.6 Use Relational Patterns for Context

**Impact: CRITICAL (enables context-aware matching without manual filtering)**

Relational patterns (`inside`, `has`, `precedes`, `follows`) match nodes based on their structural context. Use them to avoid manual post-filtering.

**Incorrect (manual context filtering):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Find all setState calls
  const setStateCalls = root.findAll({
    rule: { pattern: "this.setState($$$ARGS)" }
  });

  // Manually filter to those inside useEffect
  const inUseEffect = setStateCalls.filter(call => {
    let parent = call.parent();
    while (parent) {
      if (parent.text().includes("useEffect")) return true;
      parent = parent.parent();
    }
    return false;
  });
  // Slow, error-prone, misses edge cases
  return null;
};
```

**Correct (relational pattern):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Single query with context requirement
  const setStateInEffect = root.findAll({
    rule: {
      pattern: "this.setState($$$ARGS)",
      inside: {
        kind: "call_expression",
        pattern: "useEffect($$$)"
      }
    }
  });
  // Correct, fast, handles all nesting levels
  return null;
};
```

**Relational operators:**
- `inside: rule` - node is descendant of matching ancestor
- `has: rule` - node has matching descendant
- `precedes: rule` - node appears before sibling
- `follows: rule` - node appears after sibling
- `stopBy: "neighbor" | "end"` - controls search depth

Reference: [ast-grep Relational Patterns](https://ast-grep.github.io/guide/rule-config.html)

---

## 3. Parsing Strategy

**Impact: CRITICAL**

Parser selection determines AST structure. Wrong parser choice cascades through the entire pipeline, producing invalid matches and failed transforms.

### 3.1 Early Return for Non-Applicable Files

**Impact: CRITICAL (10-100x speedup by skipping irrelevant files)**

Check file applicability before performing expensive traversals. Return early when files cannot possibly contain relevant patterns.

**Incorrect (full traversal for all files):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Full AST traversal on every file
  const matches = root.findAll({
    rule: { pattern: "React.Component" }
  });

  if (matches.length === 0) {
    return null; // Wasted traversal time
  }

  // Transform logic...
  return root.commitEdits([]);
};
// 1000 files × full traversal = slow
```

**Correct (early return with quick check):**

```typescript
const transform: Transform<TSX> = (root) => {
  const source = root.root().text();

  // Quick string checks before expensive traversal
  if (!source.includes("React.Component") &&
      !source.includes("extends Component")) {
    return null; // Skip file entirely
  }

  // Only traverse files that might match
  const matches = root.findAll({
    rule: { pattern: "React.Component" }
  });

  // Transform logic...
  return root.commitEdits([]);
};
// 50 relevant files × full traversal = fast
```

**Better: use getSelector export:**

```typescript
// Pre-filter files at the engine level
export const getSelector = {
  rule: {
    any: [
      { pattern: "React.Component" },
      { pattern: "extends Component" }
    ]
  }
};

const transform: Transform<TSX> = (root, options) => {
  // Only called for files that match selector
  // options.matches contains pre-matched nodes
  const matches = options.matches || [];
  // Transform logic...
  return root.commitEdits([]);
};
```

**Early return strategies:**
- String `includes()` for keywords
- `getSelector` export for engine-level filtering
- Filename checks for path-specific transforms

Reference: [JSSG Advanced Patterns](https://docs.codemod.com/jssg/advanced)

### 3.2 Handle Embedded Languages with parseAsync

**Impact: CRITICAL (enables transformations in template literals and CSS-in-JS)**

Code often contains embedded languages (CSS in styled-components, SQL in template literals, GraphQL queries). Use `parseAsync` to create sub-parsers for these contexts.

**Incorrect (treating embedded code as strings):**

```typescript
const transform: Transform<TSX> = (root) => {
  const styledComponents = root.findAll({
    rule: { pattern: "styled.$TAG`$$$CSS`" }
  });

  const edits = styledComponents.map(match => {
    const css = match.getMatch("CSS")?.text() || "";
    // Regex-based CSS transformation - fragile, misses edge cases
    const newCss = css.replace(/color:\s*red/g, "color: blue");
    return match.replace(`styled.${match.getMatch("TAG")?.text()}\`${newCss}\``);
  });

  return root.commitEdits(edits);
};
```

**Correct (parsing embedded CSS):**

```typescript
import { parseAsync } from "codemod:ast-grep";

const transform: Transform<TSX> = async (root) => {
  const styledComponents = root.findAll({
    rule: { pattern: "styled.$TAG`$$$CSS`" }
  });

  const edits = await Promise.all(styledComponents.map(async match => {
    const cssText = match.getMatch("CSS")?.text() || "";

    // Parse CSS content as actual CSS
    const cssRoot = await parseAsync("css", cssText);
    const colorDecls = cssRoot.root().findAll({
      rule: { pattern: "color: red" }
    });

    if (colorDecls.length === 0) return null;

    // Transform CSS using AST
    const cssEdits = colorDecls.map(decl => decl.replace("color: blue"));
    const newCss = cssRoot.commitEdits(cssEdits);

    const tag = match.getMatch("TAG")?.text();
    return match.replace(`styled.${tag}\`${newCss}\``);
  }));

  return root.commitEdits(edits.filter(Boolean) as Edit[]);
};
```

**Embedded language scenarios:**
- `styled-components` / `emotion` → CSS parser
- Template literal SQL → SQL parser (if supported)
- GraphQL tagged templates → GraphQL parser
- HTML in template strings → HTML parser

Reference: [JSSG Advanced Patterns](https://docs.codemod.com/jssg/advanced)

### 3.3 Provide Context for Ambiguous Patterns

**Impact: CRITICAL (prevents 100% of ambiguous pattern failures)**

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

### 3.4 Select the Correct Parser for File Type

**Impact: CRITICAL (prevents 100% transform failures from AST mismatch)**

Parser selection determines AST structure. Using the wrong parser produces an invalid or incomplete AST that causes all downstream pattern matching to fail silently.

**Incorrect (wrong parser for file type):**

```bash
# Using 'javascript' parser for TypeScript files
npx codemod jssg run ./transform.ts ./src --language javascript

# TypeScript-specific syntax is parsed incorrectly:
# - Type annotations become syntax errors
# - Generic parameters are misinterpreted
# - Interface declarations are skipped
```

```typescript
// Transform fails to match typed code
const matches = root.findAll({
  rule: { pattern: "const $NAME: string = $VALUE" }
});
// Returns empty - 'javascript' parser doesn't understand ': string'
```

**Correct (matching parser to file type):**

```bash
# Use 'tsx' for .tsx files (includes .ts and .js support)
npx codemod jssg run ./transform.ts ./src --language tsx

# Use 'typescript' for .ts files without JSX
npx codemod jssg run ./transform.ts ./src --language typescript
```

```typescript
import type { Transform } from "codemod:ast-grep";
import type TSX from "codemod:ast-grep/langs/tsx";

// Explicitly type the transform for proper autocomplete
const transform: Transform<TSX> = (root) => {
  const matches = root.findAll({
    rule: { pattern: "const $NAME: string = $VALUE" }
  });
  // Correctly matches TypeScript code
  return null;
};
```

**Parser selection guide:**
- `.tsx` files → `tsx` (TypeScript + JSX)
- `.ts` files → `typescript` or `tsx`
- `.jsx` files → `jsx` (JavaScript + JSX)
- `.js` files → `javascript` or `jsx`

Reference: [JSSG Quickstart](https://docs.codemod.com/jssg/quickstart)

---

## 4. Node Traversal

**Impact: HIGH**

Efficient navigation reduces O(n^2) to O(n) operations. Proper traversal strategies prevent redundant work across large codebases.

### 4.1 Cache Repeated Node Lookups

**Impact: HIGH (eliminates redundant traversals in transform loops)**

When transforming multiple nodes that share context, cache common lookups to avoid repeated traversals.

**Incorrect (repeated lookups):**

```typescript
const transform: Transform<TSX> = (root) => {
  const apiCalls = root.findAll({
    rule: { pattern: "api.$METHOD($$$ARGS)" }
  });

  const edits = apiCalls.map(call => {
    // Each iteration re-traverses to find imports
    const hasErrorImport = root.find({
      rule: { pattern: 'import { ApiError } from "api"' }
    });

    // Each iteration re-traverses to find config
    const config = root.find({
      rule: { pattern: "const config = $VALUE" }
    });

    // N calls × 2 traversals = 2N unnecessary traversals
    return call.replace(`wrappedApi.${call.getMatch("METHOD")?.text()}()`);
  });

  return root.commitEdits(edits);
};
```

**Correct (cached lookups):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Cache lookups before the loop
  const hasErrorImport = root.find({
    rule: { pattern: 'import { ApiError } from "api"' }
  });

  const config = root.find({
    rule: { pattern: "const config = $VALUE" }
  });

  const apiCalls = root.findAll({
    rule: { pattern: "api.$METHOD($$$ARGS)" }
  });

  // Reuse cached values
  const edits = apiCalls.map(call => {
    if (!hasErrorImport) {
      // Use cached result
    }
    return call.replace(`wrappedApi.${call.getMatch("METHOD")?.text()}()`);
  });

  return root.commitEdits(edits);
};
```

**What to cache:**
- Import statements (checked for many nodes)
- Configuration declarations
- Type definitions
- Any context used across multiple transformations

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 4.2 Collect Multiple Patterns in Single Traversal

**Impact: HIGH (reduces N traversals to 1 traversal)**

When you need to find multiple different patterns, combine them into a single query with `any` instead of making separate traversals.

**Incorrect (multiple traversals):**

```typescript
const transform: Transform<TSX> = (root) => {
  // 4 separate traversals of the AST
  const requires = root.findAll({ rule: { pattern: "require($PATH)" } });
  const imports = root.findAll({ rule: { kind: "import_statement" } });
  const exports = root.findAll({ rule: { kind: "export_statement" } });
  const dynamicImports = root.findAll({ rule: { pattern: "import($PATH)" } });

  // Each traversal walks the entire tree
  // 4N time complexity
  return null;
};
```

**Correct (single traversal):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Single traversal collecting all patterns
  const moduleStatements = root.findAll({
    rule: {
      any: [
        { pattern: "require($PATH)" },
        { kind: "import_statement" },
        { kind: "export_statement" },
        { pattern: "import($PATH)" }
      ]
    }
  });

  // Categorize after collection
  const requires = moduleStatements.filter(n => n.text().startsWith("require"));
  const imports = moduleStatements.filter(n => n.kind() === "import_statement");
  const exports = moduleStatements.filter(n => n.kind() === "export_statement");
  const dynamicImports = moduleStatements.filter(n =>
    n.kind() === "call_expression" && n.text().includes("import(")
  );

  // 1N time complexity + fast array filtering
  return null;
};
```

**When to combine:**
- Searching for related patterns (all module syntax)
- Collecting nodes for analysis (all function definitions)
- Building a manifest (all API usages)

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 4.3 Use find() for Single Match, findAll() for Multiple

**Impact: HIGH (find() short-circuits, reducing traversal by up to 99%)**

Use `find()` when you only need the first match - it stops traversal immediately. Use `findAll()` only when you need all occurrences.

**Incorrect (findAll when only first needed):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Finds ALL imports, then takes first
  const imports = root.findAll({
    rule: { kind: "import_statement" }
  });

  // Only needed the first import location for insertion
  const firstImport = imports[0];
  if (!firstImport) return null;

  // findAll traversed entire file unnecessarily
  return null;
};
```

**Correct (find for single match):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Stops at first match
  const firstImport = root.find({
    rule: { kind: "import_statement" }
  });

  if (!firstImport) return null;

  // Short-circuited traversal - much faster for large files
  return null;
};
```

**Use find() when:**
- Checking if any match exists
- Finding insertion point (first/last import)
- Validating presence of a pattern
- Getting a single representative node

**Use findAll() when:**
- Transforming all occurrences
- Counting matches
- Collecting nodes for batch operations

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 4.4 Use Sibling Navigation Efficiently

**Impact: HIGH (O(1) sibling access vs O(n) re-traversal)**

Use `next()`, `prev()`, `nextAll()`, and `prevAll()` for sibling navigation instead of re-traversing from parent. Sibling methods are O(1) operations.

**Incorrect (re-traversing from parent):**

```typescript
const transform: Transform<TSX> = (root) => {
  const statements = root.findAll({ rule: { kind: "expression_statement" } });

  const edits = statements.flatMap(stmt => {
    // Re-traverse parent to find siblings
    const parent = stmt.parent();
    if (!parent) return [];

    const siblings = parent.children();
    const index = siblings.findIndex(s => s.id() === stmt.id());
    const nextSibling = siblings[index + 1];

    // O(n) per statement = O(n²) total
    if (nextSibling?.kind() === "comment") {
      return [stmt.replace(stmt.text() + " // has comment")];
    }
    return [];
  });

  return root.commitEdits(edits);
};
```

**Correct (direct sibling access):**

```typescript
const transform: Transform<TSX> = (root) => {
  const statements = root.findAll({ rule: { kind: "expression_statement" } });

  const edits = statements.flatMap(stmt => {
    // O(1) sibling access
    const nextSibling = stmt.next();

    if (nextSibling?.kind() === "comment") {
      return [stmt.replace(stmt.text() + " // has comment")];
    }
    return [];
  });

  return root.commitEdits(edits);
};
```

**Sibling navigation methods:**
- `next()` - immediately following sibling
- `prev()` - immediately preceding sibling
- `nextAll()` - all following siblings
- `prevAll()` - all preceding siblings

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 4.5 Use stopBy to Control Traversal Depth

**Impact: HIGH (prevents unbounded searches in deeply nested code)**

Relational patterns (`inside`, `has`) traverse unbounded by default. Use `stopBy` to limit search depth and improve performance.

**Incorrect (unbounded search):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Searches through ALL ancestors up to root
  const awaitInTry = root.findAll({
    rule: {
      kind: "await_expression",
      inside: {
        kind: "try_statement"
      }
      // Without stopBy, climbs entire ancestor chain
      // In deeply nested code, this is expensive
    }
  });

  return null;
};
```

**Correct (bounded search):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Stop at nearest function boundary
  const awaitInTry = root.findAll({
    rule: {
      kind: "await_expression",
      inside: {
        kind: "try_statement",
        stopBy: {
          any: [
            { kind: "function_declaration" },
            { kind: "arrow_function" },
            { kind: "method_definition" }
          ]
        }
      }
    }
  });

  // Or use "neighbor" to check only immediate parent
  const directChild = root.findAll({
    rule: {
      kind: "identifier",
      inside: {
        kind: "variable_declarator",
        stopBy: "neighbor"  // Only checks direct parent
      }
    }
  });

  return null;
};
```

**stopBy options:**
- `"neighbor"` - check only immediate parent/children
- `"end"` - search to tree boundary (default)
- `{ kind: "x" }` - stop at specific node type
- Rule object - stop when rule matches

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

---

## 5. Semantic Analysis

**Impact: HIGH**

Cross-file symbol resolution enables safe refactoring. Understanding definitions and references prevents breaking changes during migrations.

### 5.1 Cache Semantic Analysis Results

**Impact: HIGH (avoids redundant cross-file resolution)**

Semantic analysis operations are expensive. Cache results when analyzing multiple related symbols to avoid redundant cross-file resolution.

**Incorrect (repeated analysis):**

```typescript
const transform: Transform<TSX> = async (root) => {
  const apiCalls = root.findAll({
    rule: { pattern: "$API.$METHOD($$$ARGS)" }
  });

  const edits = await Promise.all(apiCalls.map(async call => {
    const apiId = call.getMatch("API");
    if (!apiId) return null;

    // Each call re-resolves the same API symbol
    const def = apiId.definition();  // Expensive!

    // Each call re-finds all references
    const refs = apiId.references();  // Very expensive!

    return call.replace(`newApi.${call.getMatch("METHOD")?.text()}()`);
  }));

  return root.commitEdits(edits.filter(Boolean) as Edit[]);
};
```

**Correct (cached analysis):**

```typescript
const transform: Transform<TSX> = async (root) => {
  // Cache for definitions by symbol text
  const defCache = new Map<string, DefinitionResult | null>();

  // Cache for references by definition location
  const refCache = new Map<string, FileReference[]>();

  const apiCalls = root.findAll({
    rule: { pattern: "$API.$METHOD($$$ARGS)" }
  });

  const edits = await Promise.all(apiCalls.map(async call => {
    const apiId = call.getMatch("API");
    if (!apiId) return null;

    const apiName = apiId.text();

    // Check cache before expensive operation
    if (!defCache.has(apiName)) {
      defCache.set(apiName, apiId.definition());
    }
    const def = defCache.get(apiName);

    if (def) {
      const defKey = `${def.root.filename()}:${def.node.range().start}`;
      if (!refCache.has(defKey)) {
        refCache.set(defKey, def.node.references() || []);
      }
    }

    return call.replace(`newApi.${call.getMatch("METHOD")?.text()}()`);
  }));

  return root.commitEdits(edits.filter(Boolean) as Edit[]);
};
```

**What to cache:**
- `definition()` results by symbol name
- `references()` results by definition location
- Cross-file root objects for repeated writes
- Import resolution results

Reference: [JSSG Semantic Analysis](https://docs.codemod.com/jssg/semantic-analysis)

### 5.2 Handle Null Semantic Analysis Results

**Impact: HIGH (prevents crashes when symbols are unresolvable)**

Semantic analysis methods return `null` when symbols cannot be resolved. Always handle null results gracefully - not all code can be statically analyzed.

**Incorrect (assumes resolution succeeds):**

```typescript
const transform: Transform<TSX> = (root) => {
  const identifiers = root.findAll({ rule: { kind: "identifier" } });

  const edits = identifiers.map(id => {
    // Crashes on unresolvable symbols
    const def = id.definition();
    const defNode = def.node;  // TypeError: Cannot read property 'node' of null

    // External imports, globals, and dynamic code return null
    return id.replace(defNode.text().toUpperCase());
  });

  return root.commitEdits(edits);
};
```

**Correct (null-safe semantic access):**

```typescript
const transform: Transform<TSX> = (root) => {
  const identifiers = root.findAll({ rule: { kind: "identifier" } });

  const edits = identifiers.flatMap(id => {
    const def = id.definition();

    // Handle unresolvable symbols
    if (!def) {
      // Could be: external import, global, dynamic, or analysis limitation
      console.log(`Could not resolve: ${id.text()}`);
      return [];
    }

    // Check definition kind for appropriate handling
    if (def.kind === "external") {
      // Symbol defined in node_modules or external file
      return [];
    }

    if (def.kind === "import") {
      // Symbol imported from another file
      const importDef = def.node;
      // Handle import-specific logic
    }

    return [id.replace(def.node.text().toUpperCase())];
  });

  return root.commitEdits(edits);
};
```

**Definition kinds:**
- `"local"` - defined in same file
- `"import"` - imported from another file
- `"external"` - from node_modules or outside project
- `null` - unresolvable (dynamic, global, etc.)

Reference: [JSSG Semantic Analysis](https://docs.codemod.com/jssg/semantic-analysis)

### 5.3 Use File Scope Semantic Analysis First

**Impact: HIGH (10-100x faster than workspace scope for local transforms)**

Start with file-scope semantic analysis, which is fast and requires no configuration. Only upgrade to workspace scope when cross-file resolution is necessary.

**Incorrect (workspace scope for local variables):**

```yaml
# workflow.yaml - unnecessary workspace scope
nodes:
  - id: rename-locals
    steps:
      - type: js-ast-grep
        codemod: ./scripts/rename.ts
        semantic_analysis: workspace  # Overkill for file-local transforms
        # Indexes entire project even for local renames
```

```typescript
const transform: Transform<TSX> = (root) => {
  const localVars = root.findAll({
    rule: { pattern: "const $NAME = $VALUE" }
  });
  // Only renaming within this file
  // Workspace indexing was wasted work
  return null;
};
```

**Correct (file scope for local, workspace for cross-file):**

```yaml
# workflow.yaml - appropriate scoping
nodes:
  - id: rename-locals
    steps:
      - type: js-ast-grep
        codemod: ./scripts/rename-locals.ts
        semantic_analysis: file  # Fast, local-only

  - id: rename-exports
    depends_on: [rename-locals]
    steps:
      - type: js-ast-grep
        codemod: ./scripts/rename-exports.ts
        semantic_analysis: workspace  # Needed for cross-file refs
```

```typescript
// rename-exports.ts - needs workspace scope
const transform: Transform<TSX> = async (root) => {
  const exportedFn = root.find({
    rule: { pattern: "export function $NAME($$$PARAMS) { $$$BODY }" }
  });

  if (!exportedFn) return null;

  // Cross-file reference finding requires workspace scope
  const refs = exportedFn.field("name")?.references();
  // refs contains references from other files
  return null;
};
```

**When to use workspace scope:**
- Renaming exported symbols
- Finding all usages across project
- Analyzing import/export relationships
- Refactoring public APIs

Reference: [JSSG Semantic Analysis](https://docs.codemod.com/jssg/semantic-analysis)

### 5.4 Verify File Ownership Before Cross-File Edits

**Impact: HIGH (prevents editing node_modules and external files)**

When using semantic analysis for cross-file transformations, verify that target files are within your project before editing. Never modify node_modules or external dependencies.

**Incorrect (editing without ownership check):**

```typescript
const transform: Transform<TSX> = async (root) => {
  const exportedFn = root.find({
    rule: { pattern: "export function deprecatedApi($$$)" }
  });

  if (!exportedFn) return null;

  const refs = exportedFn.field("name")?.references() || [];

  // Blindly edits all references
  for (const fileRef of refs) {
    for (const ref of fileRef.refs) {
      // Might edit node_modules!
      fileRef.root.write(
        fileRef.root.commitEdits([ref.replace("newApi")])
      );
    }
  }

  return null;
};
```

**Correct (ownership verification):**

```typescript
const transform: Transform<TSX> = async (root) => {
  const projectRoot = process.cwd();

  const exportedFn = root.find({
    rule: { pattern: "export function deprecatedApi($$$)" }
  });

  if (!exportedFn) return null;

  const refs = exportedFn.field("name")?.references() || [];

  for (const fileRef of refs) {
    const filePath = fileRef.root.filename();

    // Skip external files
    if (!filePath.startsWith(projectRoot)) {
      console.log(`Skipping external: ${filePath}`);
      continue;
    }

    // Skip node_modules
    if (filePath.includes("node_modules")) {
      console.log(`Skipping dependency: ${filePath}`);
      continue;
    }

    // Skip generated files
    if (filePath.includes("/dist/") || filePath.includes("/build/")) {
      continue;
    }

    // Safe to edit
    for (const ref of fileRef.refs) {
      fileRef.root.write(
        fileRef.root.commitEdits([ref.replace("newApi")])
      );
    }
  }

  return null;
};
```

**File ownership checks:**
- `startsWith(projectRoot)` - within project
- `!includes("node_modules")` - not a dependency
- `!includes("/dist/")` - not generated code
- `!endsWith(".d.ts")` - not type declarations

Reference: [JSSG Semantic Analysis](https://docs.codemod.com/jssg/semantic-analysis)

---

## 6. Edit Operations

**Impact: MEDIUM-HIGH**

Proper edit batching prevents conflicts and preserves formatting. Edit ordering affects transform reliability in multi-step operations.

### 6.1 Add Imports at Correct Position

**Impact: MEDIUM-HIGH (maintains valid module structure)**

When adding new imports, insert them at the correct position relative to existing imports. Respect import ordering conventions.

**Incorrect (appending to end):**

```typescript
const transform: Transform<TSX> = (root) => {
  const needsLogger = root.find({
    rule: { pattern: "logger.$METHOD($$$)" }
  });

  if (!needsLogger) return null;

  const source = root.root().text();

  // Appending import at end breaks module structure
  return source + '\nimport { logger } from "utils/logger";';
  // Import appears after code - invalid syntax!
};
```

**Correct (inserting with existing imports):**

```typescript
const transform: Transform<TSX> = (root) => {
  const needsLogger = root.find({
    rule: { pattern: "logger.$METHOD($$$)" }
  });

  if (!needsLogger) return null;

  // Check if import already exists
  const existingImport = root.find({
    rule: { pattern: 'import { logger } from "utils/logger"' }
  });

  if (existingImport) return null;  // Already imported

  // Find last import statement
  const imports = root.findAll({ rule: { kind: "import_statement" } });
  const lastImport = imports[imports.length - 1];

  if (lastImport) {
    // Insert after last import
    const range = lastImport.range();
    const source = root.root().text();
    const before = source.slice(0, range.end);
    const after = source.slice(range.end);

    return before + '\nimport { logger } from "utils/logger";' + after;
  }

  // No imports exist - add at top after any comments/directives
  const firstNode = root.root().children()[0];
  if (firstNode) {
    const range = firstNode.range();
    const source = root.root().text();
    return 'import { logger } from "utils/logger";\n\n' + source;
  }

  return null;
};
```

**Import ordering conventions:**
1. Node built-ins (`fs`, `path`)
2. External packages (`react`, `lodash`)
3. Internal aliases (`@/utils`, `~/lib`)
4. Relative imports (`./`, `../`)

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 6.2 Batch Edits Before Committing

**Impact: MEDIUM-HIGH (prevents edit conflicts and improves performance)**

Collect all edits into an array and call `commitEdits()` once at the end. Multiple commits can cause conflicts and performance degradation.

**Incorrect (committing inside loop):**

```typescript
const transform: Transform<TSX> = (root) => {
  const consoleCalls = root.findAll({
    rule: { pattern: "console.log($$$ARGS)" }
  });

  let result = root.root().text();

  for (const call of consoleCalls) {
    // Each commit regenerates the entire source string
    result = root.commitEdits([call.replace("logger.info()")]);
    // Edits applied sequentially - O(n²) string operations
    // Later edits may use stale positions
  }

  return result;
};
```

**Correct (batched commits):**

```typescript
const transform: Transform<TSX> = (root) => {
  const consoleCalls = root.findAll({
    rule: { pattern: "console.log($$$ARGS)" }
  });

  // Collect all edits first
  const edits = consoleCalls.map(call => {
    const args = call.getMultipleMatches("ARGS");
    const argsText = args.map(a => a.text()).join(", ");
    return call.replace(`logger.info(${argsText})`);
  });

  // Single commit with all edits
  return root.commitEdits(edits);
  // Edits applied atomically - O(n) string operations
  // Position calculations are accurate
};
```

**Why batching matters:**
- Single string reconstruction pass
- Correct position calculations for overlapping ranges
- Atomic application (all or nothing)
- Better performance for large edit sets

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 6.3 Handle Overlapping Edit Ranges

**Impact: MEDIUM-HIGH (prevents corrupted output from conflicting edits)**

When multiple edits target overlapping source ranges, later edits may corrupt earlier ones. Detect and resolve conflicts before committing.

**Incorrect (overlapping edits):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Find both outer and inner expressions
  const outer = root.findAll({
    rule: { pattern: "outer($INNER)" }
  });
  const inner = root.findAll({
    rule: { pattern: "inner($ARG)" }
  });

  // Both match overlapping ranges in: outer(inner(x))
  const edits = [
    ...outer.map(o => o.replace("newOuter()")),
    ...inner.map(i => i.replace("newInner()"))
  ];

  // Result is corrupted: overlapping replacements
  return root.commitEdits(edits);
};
```

**Correct (conflict detection):**

```typescript
const transform: Transform<TSX> = (root) => {
  const outer = root.findAll({
    rule: { pattern: "outer($INNER)" }
  });
  const inner = root.findAll({
    rule: { pattern: "inner($ARG)" }
  });

  // Collect edits with range info
  const outerEdits = outer.map(o => ({
    node: o,
    range: o.range(),
    edit: o.replace("newOuter()")
  }));

  const innerEdits = inner.map(i => ({
    node: i,
    range: i.range(),
    edit: i.replace("newInner()")
  }));

  // Filter out inner edits that overlap with outer
  const nonOverlapping = innerEdits.filter(inner =>
    !outerEdits.some(outer =>
      rangesOverlap(inner.range, outer.range)
    )
  );

  const finalEdits = [
    ...outerEdits.map(e => e.edit),
    ...nonOverlapping.map(e => e.edit)
  ];

  return root.commitEdits(finalEdits);
};

function rangesOverlap(a: Range, b: Range): boolean {
  return a.start < b.end && b.start < a.end;
}
```

**Strategies for overlapping edits:**
- Prefer outer/parent edits over inner/child
- Process innermost first if preserving hierarchy
- Skip conflicting edits with filter
- Transform parent to include child changes

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 6.4 Preserve Surrounding Formatting in Edits

**Impact: MEDIUM-HIGH (maintains code style consistency)**

When replacing nodes, preserve the surrounding whitespace and formatting to maintain code style consistency.

**Incorrect (ignoring formatting context):**

```typescript
const transform: Transform<TSX> = (root) => {
  const functions = root.findAll({
    rule: { pattern: "function $NAME() { $$$BODY }" }
  });

  const edits = functions.map(fn => {
    const name = fn.getMatch("NAME")?.text();
    // Hardcoded formatting ignores original style
    return fn.replace(`const ${name} = () => {}`);
    // Original: function   foo()  { ... }
    // Result:   const foo = () => {}
    // Lost: extra spacing, newlines, etc.
  });

  return root.commitEdits(edits);
};
```

**Correct (preserving formatting):**

```typescript
const transform: Transform<TSX> = (root) => {
  const functions = root.findAll({
    rule: { pattern: "function $NAME() { $$$BODY }" }
  });

  const edits = functions.map(fn => {
    const name = fn.getMatch("NAME");
    const body = fn.getMultipleMatches("BODY");

    if (!name) return fn.replace(fn.text());

    // Preserve body formatting exactly
    const bodyText = body.map(b => b.text()).join("");

    // Match the original node's formatting
    const original = fn.text();
    const leadingSpace = original.match(/^(\s*)/)?.[1] || "";

    return fn.replace(`${leadingSpace}const ${name.text()} = () => {${bodyText}}`);
  });

  return root.commitEdits(edits);
};
```

**Better: Use getTransformed for captured nodes:**

```typescript
const transform: Transform<TSX> = (root) => {
  const functions = root.findAll({
    rule: { pattern: "function $NAME() { $$$BODY }" }
  });

  const edits = functions.map(fn => {
    // getTransformed preserves original text exactly
    const nameText = fn.getTransformed("NAME") || "anonymous";
    const bodyText = fn.getTransformed("BODY") || "";

    return fn.replace(`const ${nameText} = () => {${bodyText}}`);
  });

  return root.commitEdits(edits);
};
```

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

### 6.5 Use flatMap for Conditional Edits

**Impact: MEDIUM-HIGH (eliminates null filtering, reduces code by 30%)**

Use `flatMap` instead of `map` + `filter` when some nodes don't produce edits. Return empty arrays for skipped nodes.

**Incorrect (map with nulls):**

```typescript
const transform: Transform<TSX> = (root) => {
  const calls = root.findAll({
    rule: { pattern: "api.$METHOD($$$ARGS)" }
  });

  const edits = calls.map(call => {
    const method = call.getMatch("METHOD");
    if (!method) return null;

    const methodName = method.text();
    // Only transform deprecated methods
    if (!deprecatedMethods.includes(methodName)) {
      return null;
    }

    return call.replace(`newApi.${methodName}()`);
  });

  // Must filter out nulls
  return root.commitEdits(edits.filter(Boolean) as Edit[]);
  // Type assertion needed, filter doesn't narrow
};
```

**Correct (flatMap with empty arrays):**

```typescript
const transform: Transform<TSX> = (root) => {
  const calls = root.findAll({
    rule: { pattern: "api.$METHOD($$$ARGS)" }
  });

  const edits = calls.flatMap(call => {
    const method = call.getMatch("METHOD");
    if (!method) return [];  // Skip gracefully

    const methodName = method.text();
    if (!deprecatedMethods.includes(methodName)) {
      return [];  // Not deprecated, skip
    }

    // Return array with single edit
    return [call.replace(`newApi.${methodName}()`)];
  });

  // No filtering needed, proper types
  return root.commitEdits(edits);
};
```

**Benefits of flatMap:**
- No null/undefined handling
- Proper TypeScript types without assertions
- Can return multiple edits per node if needed
- Cleaner functional style

**Pattern:**
```typescript
nodes.flatMap(node => {
  if (shouldSkip(node)) return [];
  if (needsMultipleEdits(node)) return [edit1, edit2];
  return [singleEdit];
});
```

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)

---

## 7. Workflow Design

**Impact: MEDIUM-HIGH**

Workflow structure determines parallelization, state management, and resumability. Poor design leads to failed migrations and manual intervention.

### 7.1 Order Nodes by Dependency

**Impact: MEDIUM-HIGH (prevents failed transforms due to missing prerequisites)**

Define explicit `depends_on` relationships between workflow nodes. The engine executes nodes in topological order based on dependencies.

**Incorrect (implicit ordering):**

```yaml
# workflow.yaml - assumes sequential execution
version: "1"
nodes:
  - id: add-types
    steps:
      - type: js-ast-grep
        codemod: ./scripts/add-types.ts

  - id: update-imports
    # No depends_on - might run before add-types!
    steps:
      - type: js-ast-grep
        codemod: ./scripts/update-imports.ts
        # Fails if types aren't added yet

  - id: run-tests
    steps:
      - type: run
        command: npm test
        # Might run before transforms complete
```

**Correct (explicit dependencies):**

```yaml
# workflow.yaml - explicit DAG
version: "1"
nodes:
  - id: add-types
    steps:
      - type: js-ast-grep
        codemod: ./scripts/add-types.ts

  - id: update-imports
    depends_on: [add-types]  # Explicit dependency
    steps:
      - type: js-ast-grep
        codemod: ./scripts/update-imports.ts

  - id: fix-lint
    depends_on: [update-imports]
    steps:
      - type: run
        command: npx eslint --fix .

  - id: run-tests
    depends_on: [fix-lint]  # Waits for all transforms
    steps:
      - type: run
        command: npm test
```

**Dependency patterns:**
- Transform order: `[parse] → [transform] → [format] → [test]`
- Parallel-safe nodes can omit mutual dependencies
- Use arrays for multiple dependencies: `depends_on: [a, b]`
- Cyclic dependencies are detected and rejected

Reference: [Codemod Workflow Reference](https://docs.codemod.com/workflows/reference)

### 7.2 Use Conditional Steps for Dynamic Workflows

**Impact: MEDIUM-HIGH (reduces execution time by 30-70% for partial migrations)**

Use `if` expressions to conditionally execute steps based on state, parameters, or previous results.

**Incorrect (always running all steps):**

```yaml
# workflow.yaml - runs everything regardless
version: "1"
nodes:
  - id: migrate
    steps:
      - type: js-ast-grep
        codemod: ./scripts/react-18.ts

      - type: js-ast-grep
        codemod: ./scripts/react-19.ts
        # Runs even if not needed

      - type: run
        command: npm run typecheck
        # Runs even if no changes were made
```

**Correct (conditional execution):**

```yaml
# workflow.yaml - smart step execution
version: "1"

params:
  react_version:
    type: string
    default: "19"
  skip_typecheck:
    type: boolean
    default: false

nodes:
  - id: migrate
    steps:
      - type: js-ast-grep
        codemod: ./scripts/react-18.ts
        if: ${{ params.react_version == "18" }}

      - type: js-ast-grep
        codemod: ./scripts/react-19.ts
        if: ${{ params.react_version == "19" }}

      - type: run
        command: npm run typecheck
        if: ${{ !params.skip_typecheck }}
```

**Conditional based on state:**

```yaml
version: "1"

state:
  has_typescript: false

nodes:
  - id: detect-typescript
    steps:
      - type: run
        command: test -f tsconfig.json && echo "true" || echo "false"
        output: has_typescript

  - id: type-migration
    depends_on: [detect-typescript]
    steps:
      - type: js-ast-grep
        codemod: ./scripts/add-types.ts
        if: ${{ state.has_typescript == "true" }}
```

**Conditional expressions:**
- `${{ params.x == "value" }}`
- `${{ state.flag == true }}`
- `${{ !params.skip }}`
- `${{ matrix.value == "special" }}`

Reference: [Codemod Workflow Reference](https://docs.codemod.com/workflows/reference)

### 7.3 Use Manual Gates for Critical Steps

**Impact: MEDIUM-HIGH (prevents runaway migrations with human checkpoints)**

Add manual approval gates before destructive or irreversible operations. Gates pause execution until human approval.

**Incorrect (fully automatic):**

```yaml
# workflow.yaml - no human checkpoints
version: "1"
nodes:
  - id: migrate-database
    steps:
      - type: run
        command: npm run db:migrate
        # Runs immediately, no review

  - id: deploy-production
    depends_on: [migrate-database]
    steps:
      - type: run
        command: npm run deploy:prod
        # Deploys without approval!
```

**Correct (manual gates):**

```yaml
# workflow.yaml - human checkpoints
version: "1"
nodes:
  - id: migrate-database
    steps:
      - type: run
        command: npm run db:migrate:dry-run
        # Dry run first

  - id: review-migration
    type: manual  # Pauses for approval
    depends_on: [migrate-database]

  - id: apply-migration
    depends_on: [review-migration]
    steps:
      - type: run
        command: npm run db:migrate

  - id: review-deployment
    type: manual  # Another checkpoint
    depends_on: [apply-migration]

  - id: deploy-production
    depends_on: [review-deployment]
    steps:
      - type: run
        command: npm run deploy:prod
```

**Resume after approval:**

```bash
# Check workflow status
npx codemod workflow status

# Resume after manual review
npx codemod workflow resume -w ./workflow.yaml
```

**When to use manual gates:**
- Before database migrations
- Before production deployments
- After large-scale transforms (review diffs)
- Before irreversible operations

Reference: [Codemod Workflow Reference](https://docs.codemod.com/workflows/reference)

### 7.4 Use Matrix Strategy for Parallelism

**Impact: MEDIUM-HIGH (3-10x speedup for independent transformations)**

Use matrix strategies to parallelize transforms across teams, directories, or configurations. Independent work items run concurrently.

**Incorrect (sequential processing):**

```yaml
# workflow.yaml - processes teams one by one
version: "1"
nodes:
  - id: migrate-team-a
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        target: ./packages/team-a

  - id: migrate-team-b
    depends_on: [migrate-team-a]  # Unnecessary wait
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        target: ./packages/team-b

  - id: migrate-team-c
    depends_on: [migrate-team-b]
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        target: ./packages/team-c
# Total time: A + B + C
```

**Correct (parallel matrix execution):**

```yaml
# workflow.yaml - parallel team processing
version: "1"

state:
  teams:
    - team-a
    - team-b
    - team-c

nodes:
  - id: migrate-teams
    strategy:
      type: matrix
      from_state: teams
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        target: ./packages/${{ matrix.value }}
# Total time: max(A, B, C)

  - id: run-tests
    depends_on: [migrate-teams]
    steps:
      - type: run
        command: npm test
```

**Access matrix values in transforms:**

```typescript
const transform: Transform<TSX> = (root, options) => {
  const team = options.matrixValues?.value;

  // Apply team-specific rules
  if (team === "team-a") {
    // Special handling for team-a
  }

  return null;
};
```

**Matrix use cases:**
- Team/directory sharding
- Multi-variant transforms (different configs)
- Language-specific processing
- Repository-parallel execution

Reference: [Codemod Workflow Reference](https://docs.codemod.com/workflows/reference)

### 7.5 Validate Workflows Before Running

**Impact: MEDIUM-HIGH (prevents 100% of schema and dependency errors)**

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

---

## 8. Testing Strategy

**Impact: MEDIUM**

Comprehensive testing prevents production incidents. Fixture-based validation catches edge cases before deployment.

### 8.1 Choose Appropriate Test Strictness Level

**Impact: MEDIUM (reduces false test failures by 50-90%)**

Use the `--strictness` flag to control how output is compared to expected. Stricter levels catch more issues but may fail on formatting differences.

**Incorrect (wrong strictness for transform type):**

```bash
# Using strict mode for a transform that reorders imports
npx codemod jssg test ./import-sorter.ts --strictness strict

# Test fails even though output is semantically correct:
# Expected: import { a, b } from 'x';
# Actual:   import { b, a } from 'x';
# These are functionally identical but strict mode fails
```

**Correct (appropriate strictness for transform type):**

```bash
# Use loose mode for transforms that may reorder elements
npx codemod jssg test ./import-sorter.ts --strictness loose
# Passes: ignores import ordering differences

# Use strict mode for formatting-sensitive transforms
npx codemod jssg test ./preserve-whitespace.ts --strictness strict
# Catches: any whitespace changes that shouldn't happen

# Use ast mode for semantic transforms
npx codemod jssg test ./api-migration.ts --strictness ast
# Passes: as long as AST is equivalent
```

**Strictness level guide:**

| Level | Compares | Use When |
|-------|----------|----------|
| `strict` | Exact string | Formatting must be preserved |
| `cst` | Syntax tree | Whitespace changes acceptable |
| `ast` | Abstract tree | Only semantics matter |
| `loose` | Semantic | Reordering is acceptable |

**Recommendation:** Start with `strict`, relax only when the transform naturally produces equivalent but differently-formatted output.

Reference: [JSSG Testing](https://docs.codemod.com/jssg/testing)

### 8.2 Cover Edge Cases in Test Fixtures

**Impact: MEDIUM (prevents production failures on unusual code)**

Create fixtures for edge cases that production code might contain. Real codebases have unusual patterns that simple examples miss.

**Incorrect (only happy path):**

```text
tests/
└── basic-case/
    ├── input.tsx     # Simple, clean code
    └── expected.tsx
# Misses: comments, formatting, edge cases
```

**Correct (comprehensive edge cases):**

```text
tests/
├── basic-case/
│   ├── input.tsx
│   └── expected.tsx
├── with-inline-comments/
│   ├── input.tsx    # Code with // comments
│   └── expected.tsx
├── with-block-comments/
│   ├── input.tsx    # Code with /* */ comments
│   └── expected.tsx
├── multiline-expression/
│   ├── input.tsx    # Spans multiple lines
│   └── expected.tsx
├── already-transformed/
│   ├── input.tsx    # Should be no-op
│   └── expected.tsx # Same as input
├── mixed-patterns/
│   ├── input.tsx    # Some match, some don't
│   └── expected.tsx
├── empty-file/
│   ├── input.tsx    # Empty content
│   └── expected.tsx
├── syntax-edge-cases/
│   ├── input.tsx    # Optional chaining, nullish coalescing
│   └── expected.tsx
└── typescript-specific/
    ├── input.tsx    # Generics, type assertions
    └── expected.tsx
```

**Edge cases to always test:**
- Empty files
- Files with only comments
- Already-transformed code (idempotency)
- Code with unusual formatting
- TypeScript-specific syntax
- JSX variations
- Dynamic/computed expressions

Reference: [JSSG Testing](https://docs.codemod.com/jssg/testing)

### 8.3 Test on File Subset Before Full Run

**Impact: MEDIUM (catches errors 10-100x faster before full run)**

Run transforms on a small subset of files first. Validate results manually before applying to the entire codebase.

**Incorrect (full run immediately):**

```bash
# Run on entire codebase first time
npx codemod jssg run ./transform.ts ./src --language tsx

# 1,847 files modified
# Discover bug after 10 minutes
# Must revert everything and restart
```

**Correct (incremental validation):**

```bash
# 1. Test with fixture tests first
npx codemod jssg test ./transform.ts --language tsx

# 2. Run on single file
npx codemod jssg run ./transform.ts ./src/components/Button.tsx --language tsx
cat ./src/components/Button.tsx  # Review output

# 3. Run on small directory
npx codemod jssg run ./transform.ts ./src/components --language tsx
git diff  # Review all changes

# 4. Run on representative sample
find ./src -name "*.tsx" | head -20 | xargs dirname | sort -u | head -5
npx codemod jssg run ./transform.ts ./src/pages --language tsx

# 5. Full run after validation
npx codemod jssg run ./transform.ts ./src --language tsx
```

**Subset selection strategies:**
- Start with smallest files
- Include files with known edge cases
- Test each file type (`.ts`, `.tsx`, `.js`)
- Include files from different teams/modules

**Quick revert if needed:**

```bash
# Git makes it easy to undo
git checkout -- src/
# Or for unstaged changes
git stash
```

Reference: [JSSG CLI](https://docs.codemod.com/cli)

### 8.4 Update Test Fixtures Intentionally

**Impact: MEDIUM (prevents accidental regressions from auto-updates)**

Use the `-u` flag to update expected files, but always review changes before committing. Auto-updated fixtures can hide regressions.

**Incorrect (blindly updating):**

```bash
# Tests fail after transform change
npx codemod jssg test ./transform.ts
# 3 tests failed

# Blindly accept all changes
npx codemod jssg test ./transform.ts -u
# 3 fixtures updated

git add -A && git commit -m "fix tests"
# Might have committed regressions!
```

**Correct (review before committing):**

```bash
# Tests fail after transform change
npx codemod jssg test ./transform.ts
# ✗ basic-transform: output differs from expected

# Update fixtures
npx codemod jssg test ./transform.ts -u
# Updated: tests/basic-transform/expected.tsx

# Review what changed
git diff tests/

# Verify changes are intentional
# - Is the new output correct?
# - Does it match the intended behavior change?
# - Are there unexpected side effects?

# Only then commit
git add tests/ && git commit -m "Update fixtures for new format"
```

**Fixture review checklist:**
- [ ] New output is semantically correct
- [ ] Formatting matches project style
- [ ] No unintended side effects
- [ ] Comments are preserved appropriately
- [ ] Edge cases still handled correctly

**CI protection:**

```yaml
# Fail CI if fixtures need updating
- run: npx codemod jssg test ./transform.ts
# Don't use -u in CI - force explicit updates
```

Reference: [JSSG Testing](https://docs.codemod.com/jssg/testing)

### 8.5 Use Input/Expected Fixture Pairs

**Impact: MEDIUM (enables repeatable, automated validation)**

Organize tests as paired input/expected files. The test runner compares actual output against expected files for automated validation.

**Incorrect (ad-hoc testing):**

```typescript
// Manual testing in console
const result = transform(parse("tsx", "const x = 1"));
console.log(result);  // "Looks right..."
// No persistent record, not reproducible
```

**Correct (fixture-based testing):**

```text
tests/
├── basic-transform/
│   ├── input.tsx
│   └── expected.tsx
├── handles-async/
│   ├── input.tsx
│   └── expected.tsx
├── preserves-comments/
│   ├── input.tsx
│   └── expected.tsx
└── no-op-when-already-migrated/
    ├── input.tsx
    └── expected.tsx
```

```typescript
// tests/basic-transform/input.tsx
const user = await fetchUser();
const posts = await fetchPosts();
```

```typescript
// tests/basic-transform/expected.tsx
const [user, posts] = await Promise.all([
  fetchUser(),
  fetchPosts()
]);
```

**Run tests:**

```bash
npx codemod jssg test ./transform.ts --language tsx

# Output:
# ✓ basic-transform
# ✓ handles-async
# ✓ preserves-comments
# ✓ no-op-when-already-migrated
# 4 tests passed
```

**Test naming conventions:**
- Describe the scenario: `handles-nested-callbacks`
- Describe expected behavior: `converts-require-to-import`
- Describe edge cases: `preserves-dynamic-imports`

Reference: [JSSG Testing](https://docs.codemod.com/jssg/testing)

---

## 9. State Management

**Impact: MEDIUM**

Proper state handling enables resumable, idempotent migrations. State persistence is critical for large-scale, multi-day transformations.

### 9.1 Log Progress for Long-Running Migrations

**Impact: MEDIUM (enables monitoring and debugging of multi-hour migrations)**

Add progress logging for transforms that process many files. Logs help monitor progress and debug issues.

**Incorrect (silent processing):**

```typescript
const transform: Transform<TSX> = (root) => {
  const matches = root.findAll({
    rule: { pattern: "oldApi($$$ARGS)" }
  });

  const edits = matches.map(m => m.replace("newApi()"));

  return root.commitEdits(edits);
};

// Running on 5000 files:
// ... silence for 30 minutes ...
// No idea if it's working, stuck, or almost done
```

**Correct (progress logging):**

```typescript
const transform: Transform<TSX> = (root, options) => {
  const filename = root.filename();

  // Log file being processed
  console.log(`Processing: ${filename}`);

  const matches = root.findAll({
    rule: { pattern: "oldApi($$$ARGS)" }
  });

  if (matches.length === 0) {
    console.log(`  No matches in ${filename}`);
    return null;
  }

  console.log(`  Found ${matches.length} matches`);

  const edits = matches.map((m, i) => {
    const line = m.range().start.line;
    console.log(`  [${i + 1}/${matches.length}] Line ${line}: ${m.text().slice(0, 50)}...`);
    return m.replace("newApi()");
  });

  console.log(`  Transformed ${edits.length} occurrences`);

  return root.commitEdits(edits);
};

// Output:
// Processing: src/components/Header.tsx
//   Found 3 matches
//   [1/3] Line 15: oldApi(user)...
//   [2/3] Line 28: oldApi(config)...
//   [3/3] Line 42: oldApi()...
//   Transformed 3 occurrences
```

**Logging best practices:**
- Log filename at start of each file
- Log match counts for debugging
- Include line numbers for review
- Use consistent format for parsing
- Consider verbosity flag for detail control

Reference: [JSSG Advanced Patterns](https://docs.codemod.com/jssg/advanced)

### 9.2 Make Transforms Idempotent for Safe Reruns

**Impact: MEDIUM (prevents infinite loops and double-transformation)**

Transforms should produce the same result when run multiple times. This allows safe reruns after partial failures.

**Incorrect (non-idempotent transform):**

```typescript
const transform: Transform<TSX> = (root) => {
  const imports = root.findAll({ rule: { kind: "import_statement" } });

  // Adds comment on every run
  const edits = imports.map(imp =>
    imp.replace(`// Migrated\n${imp.text()}`)
  );

  // Run twice:
  // Before:      import x from 'y';
  // After 1:     // Migrated
  //              import x from 'y';
  // After 2:     // Migrated
  //              // Migrated
  //              import x from 'y';

  return root.commitEdits(edits);
};
```

**Correct (idempotent transform):**

```typescript
const transform: Transform<TSX> = (root) => {
  const imports = root.findAll({ rule: { kind: "import_statement" } });

  const edits = imports.flatMap(imp => {
    const text = imp.text();

    // Check if already migrated
    const prev = imp.prev();
    if (prev?.text().includes("// Migrated")) {
      return [];  // Skip already-processed imports
    }

    return [imp.replace(`// Migrated\n${text}`)];
  });

  // Run twice:
  // Before:      import x from 'y';
  // After 1:     // Migrated
  //              import x from 'y';
  // After 2:     (no change)

  return root.commitEdits(edits);
};
```

**Idempotency patterns:**
- Check for transformation markers before applying
- Use `not` in patterns to exclude already-transformed code
- Track processed files in workflow state
- Design transforms to match only pre-transformation patterns

Reference: [Hypermod Best Practices](https://www.hypermod.io/docs/guides/best-practices)

### 9.3 Use State for Resumable Migrations

**Impact: MEDIUM (enables restart from failure point in long migrations)**

Persist migration progress in workflow state. When migrations fail mid-way, you can resume from the last successful point.

**Incorrect (no state tracking):**

```yaml
# workflow.yaml - no progress tracking
version: "1"
nodes:
  - id: migrate-all
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        # Processes all 5000 files
        # Fails at file 3000
        # Must restart from beginning
```

**Correct (state-tracked progress):**

```yaml
# workflow.yaml - resumable migration
version: "1"

state:
  processed_files: []
  failed_files: []
  current_batch: 0

nodes:
  - id: list-files
    steps:
      - type: run
        command: find ./src -name "*.tsx" | sort
        output: all_files

  - id: process-batch
    depends_on: [list-files]
    strategy:
      type: matrix
      from_state: all_files
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        target: ${{ matrix.value }}
        on_success: processed_files@=${{ matrix.value }}
        on_failure: failed_files@=${{ matrix.value }}
```

**Resume after failure:**

```bash
# Check status
npx codemod workflow status -w ./workflow.yaml
# Shows: 3000/5000 files processed

# Resume from last state
npx codemod workflow resume -w ./workflow.yaml
# Continues from file 3001
```

**State operations:**
- `KEY=VALUE` - set value
- `KEY@=VALUE` - append to array
- `KEY.nested=VALUE` - set nested property

Reference: [Codemod Workflow Reference](https://docs.codemod.com/workflows/reference)

---

## 10. Security and Capabilities

**Impact: LOW-MEDIUM**

JSSG's deny-by-default security model requires explicit capability grants. Minimal permissions reduce attack surface for untrusted codemods.

### 10.1 Minimize Requested Capabilities

**Impact: LOW-MEDIUM (reduces attack surface for untrusted codemods)**

JSSG uses deny-by-default security. Only request capabilities your codemod actually needs. Each capability expands the attack surface.

**Incorrect (requesting all capabilities):**

```yaml
# codemod.yaml - over-permissioned
schema_version: "1.0"
name: simple-rename
capabilities:
  - fs           # Not needed for simple AST transform
  - fetch        # Not needed
  - child_process # Definitely not needed!
```

```typescript
// Transform doesn't use any capabilities
const transform: Transform<TSX> = (root) => {
  const matches = root.findAll({
    rule: { pattern: "oldName" }
  });
  const edits = matches.map(m => m.replace("newName"));
  return root.commitEdits(edits);
};
```

**Correct (minimal capabilities):**

```yaml
# codemod.yaml - least-privilege
schema_version: "1.0"
name: simple-rename
# No capabilities needed for pure AST transforms
# capabilities: []  (implicit)
```

```yaml
# codemod.yaml - only what's needed
schema_version: "1.0"
name: config-migrator
capabilities:
  - fs  # Only fs, needed to read config file
# No fetch or child_process
```

**When each capability is needed:**
- `fs` - Reading config files, writing reports
- `fetch` - Downloading schemas, API validation
- `child_process` - Running external tools (rare)

**CLI equivalent:**

```bash
# Only enable specific capability
npx codemod jssg run ./transform.ts ./src --allow-fs
# NOT: --allow-fs --allow-fetch --allow-child-process
```

Reference: [JSSG Security](https://docs.codemod.com/jssg/security)

### 10.2 Review Third-Party Codemods Before Running

**Impact: LOW-MEDIUM (prevents malicious code execution from untrusted sources)**

Inspect third-party codemod source code before running. Codemods with capabilities can execute arbitrary operations on your system.

**Incorrect (running without review):**

```bash
# Running random codemod from registry
npx codemod @unknown-author/mysterious-migration
# What does it do? What permissions does it have?
# Could be mining crypto, stealing credentials, etc.
```

**Correct (review first):**

```bash
# 1. Search and inspect metadata
npx codemod search "react upgrade"
# Review: author, downloads, last update, capabilities

# 2. Check requested capabilities
cat node_modules/@org/codemod/codemod.yaml
# capabilities:
#   - fs          # Why does it need filesystem?
#   - fetch       # Why network access?
#   - child_process  # RED FLAG - why shell access?

# 3. Read the source code
cat node_modules/@org/codemod/scripts/transform.ts
# Look for suspicious:
# - eval(), Function()
# - fetch() to unknown URLs
# - execSync() with dynamic input
# - fs.writeFile() outside project

# 4. Run only after review
npx codemod @trusted-org/reviewed-migration
```

**Warning signs in codemods:**
- Requests `child_process` capability
- Fetches from non-official URLs
- Writes files outside project directory
- Obfuscated or minified source
- No test suite or documentation

**Trusted sources:**
- Official framework maintainers
- Well-known organizations
- Codemods with visible source and tests
- High download counts and recent updates

Reference: [JSSG Security](https://docs.codemod.com/jssg/security)

### 10.3 Validate External Inputs Before Use

**Impact: LOW-MEDIUM (prevents injection attacks from malicious input)**

When codemods accept external input (parameters, config files), validate before use. Untrusted input can cause injection attacks.

**Incorrect (unsanitized parameter use):**

```typescript
const transform: Transform<TSX> = async (root, options) => {
  const targetModule = options.params?.module;

  // Direct use of user input in pattern - dangerous!
  const matches = root.findAll({
    rule: { pattern: `import { $$$NAMES } from "${targetModule}"` }
  });

  // User input in shell command - injection vulnerability!
  const { execSync } = await import("child_process");
  execSync(`npm info ${targetModule}`);  // Dangerous!

  return null;
};
```

**Correct (validated inputs):**

```typescript
const transform: Transform<TSX> = async (root, options) => {
  const targetModule = options.params?.module;

  // Validate module name format
  if (!targetModule || !/^[@a-z0-9\-\/]+$/i.test(targetModule)) {
    console.error(`Invalid module name: ${targetModule}`);
    return null;
  }

  // Safe to use in pattern after validation
  const matches = root.findAll({
    rule: { pattern: `import { $$$NAMES } from "${targetModule}"` }
  });

  // Escape for shell if needed
  const safeModule = targetModule.replace(/[^a-zA-Z0-9@\/-]/g, "");
  const { execSync } = await import("child_process");
  execSync(`npm info "${safeModule}"`);  // Quoted and sanitized

  return null;
};
```

**Input validation patterns:**
- Module names: `/^[@a-z0-9\-\/]+$/i`
- File paths: Resolve and check within project root
- Identifiers: `/^[a-zA-Z_][a-zA-Z0-9_]*$/`
- Always escape shell arguments

Reference: [JSSG Security](https://docs.codemod.com/jssg/security)

---

## 11. Package Structure

**Impact: LOW**

Proper packaging enables discoverability, version management, and CI/CD integration. Well-structured packages are reusable and maintainable.

### 11.1 Organize Package by Convention

**Impact: LOW (enables tooling support and contributor onboarding)**

Follow the standard codemod package structure. Consistent organization enables tooling support and helps contributors navigate.

**Incorrect (ad-hoc structure):**

```text
my-codemod/
├── transform.js        # Where are tests?
├── config.json         # Non-standard config
└── utils/              # Unclear purpose
    └── helper.js
```

**Correct (standard structure):**

```text
my-codemod/
├── codemod.yaml          # Package metadata
├── workflow.yaml         # Workflow definition
├── scripts/              # JSSG transform files
│   ├── main.ts
│   └── helpers/
│       └── patterns.ts
├── rules/                # YAML ast-grep rules
│   └── deprecated-api.yaml
├── tests/                # Test fixtures
│   ├── basic-case/
│   │   ├── input.tsx
│   │   └── expected.tsx
│   └── edge-case/
│       ├── input.tsx
│       └── expected.tsx
├── README.md             # Usage documentation
└── CHANGELOG.md          # Version history
```

**Directory purposes:**

| Directory | Purpose |
|-----------|---------|
| `scripts/` | TypeScript/JavaScript transforms (JSSG) |
| `rules/` | Declarative YAML ast-grep rules |
| `tests/` | Input/expected fixture pairs |
| Root | Metadata and documentation |

**Workflow referencing:**

```yaml
# workflow.yaml
version: "1"
nodes:
  - id: transform
    steps:
      - type: js-ast-grep
        codemod: ./scripts/main.ts  # Relative to package root

      - type: ast-grep
        rule: ./rules/deprecated-api.yaml
```

Reference: [Codemod Package Structure](https://docs.codemod.com/package-structure)

### 11.2 Use Semantic Versioning for Packages

**Impact: LOW (enables safe dependency management and updates)**

Follow semantic versioning (semver) for codemod packages. Version numbers communicate compatibility and change scope to consumers.

**Incorrect (arbitrary versioning):**

```yaml
# codemod.yaml - meaningless version
schema_version: "1.0"
name: react-migration
version: "42"  # What does this mean?
# Or:
version: "2024.01.15"  # Date-based, no compatibility info
```

**Correct (semantic versioning):**

```yaml
# codemod.yaml - semver
schema_version: "1.0"
name: react-migration
version: "1.2.3"
# 1 = Major (breaking changes to transform behavior)
# 2 = Minor (new features, backward compatible)
# 3 = Patch (bug fixes, no behavior change)
```

**Version bump guidelines:**

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Fix bug in existing pattern | Patch: 1.2.3 → 1.2.4 | Fix edge case handling |
| Add new transformation rule | Minor: 1.2.3 → 1.3.0 | Support new API pattern |
| Change output format | Major: 1.2.3 → 2.0.0 | Different code style |
| Remove pattern support | Major: 1.2.3 → 2.0.0 | Drop legacy format |

**Pre-release versions:**

```yaml
version: "2.0.0-beta.1"  # Pre-release testing
version: "2.0.0-rc.1"    # Release candidate
```

**Publishing workflow:**

```bash
# Validate before version bump
npx codemod jssg test ./transform.ts

# Update version in codemod.yaml
# Commit and tag
git tag v1.2.4
git push --tags

# Publish
npx codemod publish
```

Reference: [Codemod Package Structure](https://docs.codemod.com/package-structure)

### 11.3 Write Descriptive Package Metadata

**Impact: LOW (3-5x better search ranking in registry)**

Write clear descriptions and keywords in codemod.yaml. Good metadata helps users find your codemod in registry search.

**Incorrect (minimal metadata):**

```yaml
# codemod.yaml - unhelpful
schema_version: "1.0"
name: my-codemod
version: "1.0.0"
# No description, author, keywords
# Users can't tell what it does
```

**Correct (comprehensive metadata):**

```yaml
# codemod.yaml - discoverable
schema_version: "1.0"
name: "@myorg/react-18-to-19"
version: "1.0.0"
description: |
  Migrates React 18 applications to React 19.
  Handles: useEffect cleanup, Suspense boundaries,
  Server Components imports, and deprecated API removal.
author: "Team Name <team@example.com>"
license: "MIT"
category: "migration"

targets:
  languages:
    - TypeScript
    - JavaScript
  frameworks:
    - React

keywords:
  - upgrade
  - breaking-change
  - v18-to-v19
  - react
  - server-components
  - suspense

repository:
  url: "https://github.com/myorg/codemods"
  directory: "packages/react-18-to-19"
```

**Keyword best practices:**
- Include version tags: `v18-to-v19`
- Include transformation type: `upgrade`, `migration`
- Include framework name: `react`, `nextjs`
- Include specific features: `server-components`, `suspense`

**Registry discoverability:**

```bash
# Good keywords enable search
npx codemod search "react 19 upgrade"
# Finds: @myorg/react-18-to-19

npx codemod search "server components migration"
# Also finds: @myorg/react-18-to-19
```

Reference: [Codemod Package Structure](https://docs.codemod.com/package-structure)

---

## References

1. [https://docs.codemod.com](https://docs.codemod.com)
2. [https://ast-grep.github.io](https://ast-grep.github.io)
3. [https://github.com/codemod/codemod](https://github.com/codemod/codemod)
4. [https://github.com/facebook/jscodeshift](https://github.com/facebook/jscodeshift)
5. [https://martinfowler.com/articles/codemods-api-refactoring.html](https://martinfowler.com/articles/codemods-api-refactoring.html)
6. [https://www.hypermod.io/docs/guides/best-practices](https://www.hypermod.io/docs/guides/best-practices)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |