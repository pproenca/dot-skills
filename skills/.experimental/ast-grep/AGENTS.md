# ast-grep

**Version 0.1.0**  
ast-grep Community  
January 2026

> **Note:** This ast-grep guide is primarily for agents and LLMs to follow when writing,
> reviewing, or debugging rules. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for ast-grep rule writing and usage, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (pattern correctness, meta variable usage) to incremental (testing and debugging). Each rule includes detailed explanations, YAML examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated rule generation and code transformation.

---

## Table of Contents

1. [Pattern Correctness](#1-pattern-correctness) — **CRITICAL**
   - 1.1 [Account for Language-Specific Syntax Differences](#11-account-for-language-specific-syntax-differences)
   - 1.2 [Avoid Matching Inside Comments and Strings](#12-avoid-matching-inside-comments-and-strings)
   - 1.3 [Choose Kind or Pattern Based on Specificity Needs](#13-choose-kind-or-pattern-based-on-specificity-needs)
   - 1.4 [Configure Pattern Strictness Appropriately](#14-configure-pattern-strictness-appropriately)
   - 1.5 [Use Context and Selector for Code Fragments](#15-use-context-and-selector-for-code-fragments)
   - 1.6 [Use Debug Query to Inspect AST Structure](#16-use-debug-query-to-inspect-ast-structure)
   - 1.7 [Use Valid Parseable Code as Patterns](#17-use-valid-parseable-code-as-patterns)
2. [Meta Variable Usage](#2-meta-variable-usage) — **CRITICAL**
   - 2.1 [Follow Meta Variable Naming Conventions](#21-follow-meta-variable-naming-conventions)
   - 2.2 [Match Single AST Nodes with Meta Variables](#22-match-single-ast-nodes-with-meta-variables)
   - 2.3 [Reuse Meta Variables to Enforce Equality](#23-reuse-meta-variables-to-enforce-equality)
   - 2.4 [Understand Multi-Match Variables Are Lazy](#24-understand-multi-match-variables-are-lazy)
   - 2.5 [Use Double Dollar for Unnamed Node Matching](#25-use-double-dollar-for-unnamed-node-matching)
   - 2.6 [Use Underscore Prefix for Non-Capturing Matches](#26-use-underscore-prefix-for-non-capturing-matches)
3. [Rule Composition](#3-rule-composition) — **HIGH**
   - 3.1 [Use All for AND Logic Between Rules](#31-use-all-for-and-logic-between-rules)
   - 3.2 [Use Any for OR Logic Between Rules](#32-use-any-for-or-logic-between-rules)
   - 3.3 [Use Has for Child Node Requirements](#33-use-has-for-child-node-requirements)
   - 3.4 [Use Inside for Contextual Matching](#34-use-inside-for-contextual-matching)
   - 3.5 [Use Matches for Rule Reusability](#35-use-matches-for-rule-reusability)
   - 3.6 [Use Not for Exclusion Patterns](#36-use-not-for-exclusion-patterns)
4. [Constraint Design](#4-constraint-design) — **HIGH**
   - 4.1 [Avoid Constraints Inside Not Rules](#41-avoid-constraints-inside-not-rules)
   - 4.2 [Understand Constraints Apply After Matching](#42-understand-constraints-apply-after-matching)
   - 4.3 [Use Kind Constraints to Filter Meta Variables](#43-use-kind-constraints-to-filter-meta-variables)
   - 4.4 [Use Pattern Constraints for Structural Filtering](#44-use-pattern-constraints-for-structural-filtering)
   - 4.5 [Use Regex Constraints for Text Patterns](#45-use-regex-constraints-for-text-patterns)
5. [Rewrite Correctness](#5-rewrite-correctness) — **MEDIUM-HIGH**
   - 5.1 [Ensure Fix Templates Produce Valid Syntax](#51-ensure-fix-templates-produce-valid-syntax)
   - 5.2 [Preserve Program Semantics in Rewrites](#52-preserve-program-semantics-in-rewrites)
   - 5.3 [Reference All Necessary Meta Variables in Fix](#53-reference-all-necessary-meta-variables-in-fix)
   - 5.4 [Test Rewrites on Representative Code](#54-test-rewrites-on-representative-code)
   - 5.5 [Use Transform for Complex Rewrites](#55-use-transform-for-complex-rewrites)
6. [Project Organization](#6-project-organization) — **MEDIUM**
   - 6.1 [Assign Appropriate Severity Levels](#61-assign-appropriate-severity-levels)
   - 6.2 [Use File Filtering for Targeted Rules](#62-use-file-filtering-for-targeted-rules)
   - 6.3 [Use Standard Project Directory Structure](#63-use-standard-project-directory-structure)
   - 6.4 [Use Unique Descriptive Rule IDs](#64-use-unique-descriptive-rule-ids)
   - 6.5 [Write Clear Actionable Messages](#65-write-clear-actionable-messages)
7. [Performance Optimization](#7-performance-optimization) — **MEDIUM**
   - 7.1 [Avoid Heavy Regex in Hot Paths](#71-avoid-heavy-regex-in-hot-paths)
   - 7.2 [Leverage Parallel Scanning with Threads](#72-leverage-parallel-scanning-with-threads)
   - 7.3 [Use Specific Patterns Over Generic Ones](#73-use-specific-patterns-over-generic-ones)
   - 7.4 [Use StopBy to Limit Search Depth](#74-use-stopby-to-limit-search-depth)
8. [Testing & Debugging](#8-testing-debugging) — **LOW-MEDIUM**
   - 8.1 [Test Edge Cases and Boundary Conditions](#81-test-edge-cases-and-boundary-conditions)
   - 8.2 [Test Patterns in Playground First](#82-test-patterns-in-playground-first)
   - 8.3 [Use Snapshot Testing for Fix Verification](#83-use-snapshot-testing-for-fix-verification)
   - 8.4 [Write Both Valid and Invalid Test Cases](#84-write-both-valid-and-invalid-test-cases)

---

## 1. Pattern Correctness

**Impact: CRITICAL**

Invalid patterns cause parse failures or silent mismatches. Patterns must be valid, parseable code that tree-sitter can process.

### 1.1 Account for Language-Specific Syntax Differences

**Impact: CRITICAL (prevents cross-language pattern failures)**

Identical pattern strings parse differently across languages. Single quotes denote strings in JavaScript but character literals in C/Java.

**Incorrect (assumes JavaScript semantics in C):**

```yaml
id: find-char-literal
language: c
rule:
  pattern: 'a'  # Matches char literal, not string
message: Found character literal
```

**Correct (uses language-appropriate syntax):**

```yaml
id: find-string-literal
language: c
rule:
  pattern: '"hello"'  # C strings use double quotes
message: Found string literal
```

**When working with multiple languages:**
- Test each pattern in language-specific playground
- Create separate rules for similar languages (TypeScript vs JavaScript)
- Use `languageGlobs` only for true supersets

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

### 1.2 Avoid Matching Inside Comments and Strings

**Impact: CRITICAL (prevents false positives on non-code content)**

ast-grep matches AST nodes, not text. Patterns will never match content inside comments or string literals because those are leaf nodes without children matching code structure.

**Incorrect (expects to match commented code):**

```yaml
id: find-todo-console
language: javascript
rule:
  pattern: console.log($MSG)
# Will NOT match: // console.log("debugging")
```

**Correct (use regex for comment/string content):**

```yaml
id: find-todo-comments
language: javascript
rule:
  kind: comment
  regex: 'TODO|FIXME'
```

**For matching inside strings:**

```yaml
id: find-sql-injection-risk
language: javascript
rule:
  kind: string
  regex: 'SELECT.*FROM.*WHERE'
```

**Note:** Comments and strings are terminal AST nodes - their content is not parsed into sub-nodes.

Reference: [Core Concepts](https://ast-grep.github.io/advanced/core-concepts.html)

### 1.3 Choose Kind or Pattern Based on Specificity Needs

**Impact: CRITICAL (prevents overly broad or narrow matching)**

Use `kind` for broad node-type matching and `pattern` for specific code structures. Combining them incorrectly causes unexpected results.

**Incorrect (kind + pattern together fails):**

```yaml
id: find-specific-call
language: javascript
rule:
  kind: call_expression
  pattern: console.log($MSG)  # These don't compose directly
```

**Correct (use pattern object or all):**

```yaml
id: find-specific-call
language: javascript
rule:
  all:
    - kind: call_expression
    - pattern: console.log($MSG)
```

**Alternative (pattern with kind constraint):**

```yaml
id: find-identifier-usage
language: javascript
rule:
  pattern: $VAR
constraints:
  VAR:
    kind: identifier
```

**When to use each:**
- `kind` alone: Match all nodes of a type (all function declarations)
- `pattern` alone: Match specific code structure (console.log calls)
- `all` with both: Filter pattern matches by kind
- Constraints: Filter captured meta variables by kind

Reference: [Atomic Rules](https://ast-grep.github.io/reference/rule.html#atomic-rules)

### 1.4 Configure Pattern Strictness Appropriately

**Impact: CRITICAL (2-5× more matches with relaxed mode)**

The `strictness` parameter controls how precisely patterns must match AST structure. Looser settings match more variations but risk false positives.

**Incorrect (default strictness misses valid variations):**

```yaml
id: find-await-fetch
language: typescript
rule:
  pattern: await fetch($URL)
# Misses: await (fetch(url))
# Misses: await fetch(url, options)
```

**Correct (relaxed strictness catches variations):**

```yaml
id: find-await-fetch
language: typescript
rule:
  pattern:
    context: await fetch($URL)
    strictness: relaxed
```

**Strictness levels:**
- `cst`: Exact match including punctuation (most strict)
- `smart`: Ignores unnamed nodes like parentheses (default)
- `ast`: Ignores node kinds, focuses on structure
- `relaxed`: Matches if pattern is subtree (most lenient)
- `signature`: Ignores non-essential nodes like async/visibility

**When to adjust:**
- Use `relaxed` when matching expressions that may be wrapped in parens
- Use `signature` for function signatures with optional modifiers
- Use `cst` when punctuation matters (template literals, regex)

Reference: [Pattern Strictness](https://ast-grep.github.io/guide/rule-config/atomic-rule.html#strictness)

### 1.5 Use Context and Selector for Code Fragments

**Impact: CRITICAL (enables matching incomplete code patterns)**

Code fragments like object keys or function parameters cannot be parsed standalone. Use `context` to provide surrounding structure and `selector` to target the specific node.

**Incorrect (fragment cannot be parsed):**

```yaml
id: find-json-key
language: json
rule:
  pattern: '"name"'  # Invalid standalone JSON
```

**Correct (context provides structure, selector targets node):**

```yaml
id: find-json-key
language: json
rule:
  pattern:
    context: '{"name": $VAL}'
    selector: pair
```

**Common use cases:**
- Object keys: `context: '{key: $VAL}'` with `selector: pair`
- Function parameters: `context: 'function($PARAM) {}'` with `selector: formal_parameters`
- Array elements: `context: '[$ELEM]'` with `selector: array`

Reference: [Rule Configuration](https://ast-grep.github.io/guide/rule-config.html)

### 1.6 Use Debug Query to Inspect AST Structure

**Impact: CRITICAL (5-10× faster pattern debugging)**

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

### 1.7 Use Valid Parseable Code as Patterns

**Impact: CRITICAL (prevents silent pattern failures)**

Patterns must be syntactically valid code that tree-sitter can parse. Invalid patterns silently fail to match anything, wasting debugging time.

**Incorrect (incomplete expression, unparseable):**

```yaml
id: find-console-log
language: javascript
rule:
  pattern: console.log(  # Missing closing paren
```

**Correct (valid, complete expression):**

```yaml
id: find-console-log
language: javascript
rule:
  pattern: console.log($ARG)
```

**Note:** Test patterns in the [ast-grep playground](https://ast-grep.github.io/playground.html) to verify parseability before deployment.

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

---

## 2. Meta Variable Usage

**Impact: CRITICAL**

Incorrect meta variable syntax causes capture failures and unexpected matches. Meta variables are the foundation of pattern flexibility.

### 2.1 Follow Meta Variable Naming Conventions

**Impact: CRITICAL (prevents capture failures)**

Meta variables must start with `$` followed by uppercase letters, underscores, or digits. Invalid names silently fail to capture.

**Incorrect (lowercase, kebab-case, numbers first):**

```yaml
id: find-function-calls
language: javascript
rule:
  pattern: $func($args)        # lowercase fails
  # pattern: $KEBAB-CASE       # hyphens invalid
  # pattern: $123ABC           # numbers first invalid
```

**Correct (uppercase with underscores):**

```yaml
id: find-function-calls
language: javascript
rule:
  pattern: $FUNC($ARGS)
```

**Valid meta variable formats:**
- `$META` - basic uppercase
- `$META_VAR` - with underscores
- `$META_VAR1` - with trailing digits
- `$_` - single underscore wildcard
- `$_123` - underscore prefix with digits

**Invalid formats:**
- `$invalid` - lowercase letters
- `$Svalue` - mixed case
- `$123` - starts with digit
- `$KEBAB-CASE` - contains hyphen

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

### 2.2 Match Single AST Nodes with Meta Variables

**Impact: CRITICAL (prevents multi-node capture failures)**

A single `$VAR` matches exactly one AST node. It cannot match multiple consecutive nodes like function arguments or statements.

**Incorrect (expects $ARGS to match multiple arguments):**

```yaml
id: find-multi-arg-call
language: javascript
rule:
  pattern: console.log($ARGS)  # Only matches single-arg calls
# Won't match: console.log(a, b, c)
```

**Correct (use $$$ for multiple nodes):**

```yaml
id: find-any-log-call
language: javascript
rule:
  pattern: console.log($$$ARGS)  # Matches zero or more args
```

**Understanding node boundaries:**
- `$VAR` = exactly one node (like regex `.`)
- `$$$` or `$$$VAR` = zero or more nodes (like regex `.*`)
- Each meta variable captures the entire subtree of its matched node

**Common mistake:**

```yaml
# This only matches: fn(singleArg)
pattern: fn($ARG)

# This matches: fn(), fn(a), fn(a, b, c)
pattern: fn($$$ARGS)
```

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

### 2.3 Reuse Meta Variables to Enforce Equality

**Impact: CRITICAL (prevents false positives on asymmetric code)**

When the same meta variable name appears multiple times in a pattern, all occurrences must match identical code. Use different names for independent captures.

**Incorrect (reuses $VAR for independent values):**

```yaml
id: find-assignment
language: javascript
rule:
  pattern: $VAR = $VAR  # Only matches self-assignment like x = x
# Won't match: x = y
```

**Correct (uses distinct names for different captures):**

```yaml
id: find-assignment
language: javascript
rule:
  pattern: $TARGET = $VALUE  # Matches any assignment
```

**Intentional reuse for equality checks:**

```yaml
id: find-self-comparison
language: javascript
rule:
  pattern: $EXPR === $EXPR
message: Comparing expression to itself is always true
# Matches: x === x, foo.bar === foo.bar
```

**Practical use cases:**
- Detect redundant comparisons: `$A == $A`
- Find self-assignment bugs: `$X = $X`
- Match symmetric operations: `$A + $A`

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

### 2.4 Understand Multi-Match Variables Are Lazy

**Impact: CRITICAL (prevents unexpected short matches)**

The `$$$` multi-match operator is lazy, not greedy. It stops at the first valid match to ensure linear-time performance.

**Incorrect (expects greedy matching):**

```yaml
id: extract-all-but-last
language: javascript
rule:
  pattern: fn($$$FIRST, $LAST)
# For fn(a, b, c): $$$FIRST = a, $LAST = b, c is unmatched!
```

**Correct (understand lazy semantics):**

```yaml
id: match-any-call
language: javascript
rule:
  pattern: fn($$$ARGS)  # Matches entire argument list
```

**Working with multi-match:**

```yaml
# Match calls with at least 2 args
id: find-two-plus-args
rule:
  pattern: fn($FIRST, $$$REST)  # $FIRST is required, $$$REST is 0+

# Match calls with at least 3 args
id: find-three-plus-args
rule:
  pattern: fn($A, $B, $$$REST)
```

**Important:** Multi-match variables cannot be used in rewrites directly because they represent multiple nodes, not a single value.

Reference: [FAQ](https://ast-grep.github.io/advanced/faq.html)

### 2.5 Use Double Dollar for Unnamed Node Matching

**Impact: CRITICAL (enables matching operators and punctuation)**

Single `$VAR` only matches named AST nodes. Use `$$VAR` to match unnamed nodes like operators and punctuation.

**Incorrect (single dollar misses operators):**

```yaml
id: find-binary-operator
language: javascript
rule:
  pattern: $LEFT $OP $RIGHT  # $OP won't match + or -
```

**Correct (double dollar matches unnamed nodes):**

```yaml
id: find-binary-operator
language: javascript
rule:
  pattern: $LEFT $$OP $RIGHT  # $$OP matches +, -, *, etc.
```

**Named vs Unnamed nodes:**
- **Named nodes**: Have a `kind` property (e.g., `identifier`, `call_expression`)
- **Unnamed nodes**: Operators (`+`, `-`), punctuation (`;`, `,`), keywords

**Common use cases for `$$VAR`:**

```yaml
# Match any binary expression
pattern: $A $$OP $B

# Match any assignment operator
pattern: $TARGET $$ASSIGN $VALUE  # =, +=, -=, etc.

# Match array access brackets
pattern: $ARR$$OPEN$IDX$$CLOSE
```

**Tip:** Use `--debug-query` to see which nodes are named vs unnamed.

Reference: [Core Concepts](https://ast-grep.github.io/advanced/core-concepts.html)

### 2.6 Use Underscore Prefix for Non-Capturing Matches

**Impact: CRITICAL (reduces memory allocation in hot paths)**

Prefix meta variables with underscore (`$_`) when you don't need their captured value. This avoids HashMap creation during matching, improving performance.

**Incorrect (captures values never used):**

```yaml
id: find-console-usage
language: javascript
rule:
  pattern: console.$METHOD($ARGS)
# $METHOD and $ARGS captured but never referenced
```

**Correct (underscore signals no capture needed):**

```yaml
id: find-console-usage
language: javascript
rule:
  pattern: console.$_METHOD($_ARGS)
message: Avoid console statements in production
```

**When to capture vs non-capture:**

```yaml
# Need the value for rewrite - capture it
id: migrate-console-to-logger
rule:
  pattern: console.log($MSG)
fix: logger.info($MSG)  # $MSG referenced in fix

# Just detecting presence - don't capture
id: find-console
rule:
  pattern: console.$_METHOD($_ARGS)
```

**Performance note:** Non-capturing variables can match different content at each occurrence in the same pattern, unlike capturing variables which enforce equality.

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

---

## 3. Rule Composition

**Impact: HIGH**

Poor rule composition leads to missed matches or over-matching. Combining atomic, relational, and composite rules requires understanding execution semantics.

### 3.1 Use All for AND Logic Between Rules

**Impact: HIGH (reduces false positives by 50-90%)**

The `all` composite rule requires a node to satisfy every sub-rule. Use it to combine multiple conditions that must all be true.

**Incorrect (relies on implicit YAML field merging):**

```yaml
id: find-async-arrow
language: javascript
rule:
  kind: arrow_function
  pattern: async () => $BODY  # YAML fields don't AND together
```

**Correct (explicit all for AND):**

```yaml
id: find-async-arrow
language: javascript
rule:
  all:
    - kind: arrow_function
    - has:
        pattern: async
```

**Key behaviors:**
- All sub-rules must match the same single node
- Meta variables from all sub-rules are merged into final match
- Order in `all` array can matter for relational rules

**Common AND patterns:**

```yaml
# Match console.log inside async functions
rule:
  all:
    - pattern: console.log($MSG)
    - inside:
        kind: function_declaration
        has:
          pattern: async

# Match identifier that's a function parameter
rule:
  all:
    - kind: identifier
    - inside:
        kind: formal_parameters
```

Reference: [Composite Rules](https://ast-grep.github.io/reference/rule.html#composite-rules)

### 3.2 Use Any for OR Logic Between Rules

**Impact: HIGH (3-10× fewer duplicate rules)**

The `any` composite rule matches if at least one sub-rule succeeds. Use it for alternative patterns that should trigger the same action.

**Incorrect (multiple separate rules for variations):**

```yaml
# Rule 1
id: find-console-log
rule:
  pattern: console.log($MSG)
---
# Rule 2
id: find-console-warn
rule:
  pattern: console.warn($MSG)
```

**Correct (single rule with any):**

```yaml
id: find-console-usage
language: javascript
rule:
  any:
    - pattern: console.log($MSG)
    - pattern: console.warn($MSG)
    - pattern: console.error($MSG)
message: Avoid console statements in production
```

**Key behaviors:**
- First matching sub-rule determines the captured variables
- Meta variables from non-matching sub-rules are not available
- Use consistent variable names across alternatives for uniform rewrites

**Common OR patterns:**

```yaml
# Match various loop types
rule:
  any:
    - kind: for_statement
    - kind: while_statement
    - kind: do_statement

# Match function declarations or expressions
rule:
  any:
    - kind: function_declaration
    - kind: function_expression
    - kind: arrow_function
```

Reference: [Composite Rules](https://ast-grep.github.io/reference/rule.html#composite-rules)

### 3.3 Use Has for Child Node Requirements

**Impact: HIGH (reduces false positives by 60-80%)**

The `has` relational rule confirms that a matched node contains specific descendant nodes. Use it to filter parent nodes by their content.

**Incorrect (pattern can't express child requirements):**

```yaml
id: find-function-with-await
language: javascript
rule:
  pattern: function $NAME() { $$$BODY }  # Can't require await in body
```

**Correct (has checks for descendants):**

```yaml
id: find-function-with-await
language: javascript
rule:
  all:
    - kind: function_declaration
    - has:
        pattern: await $EXPR
```

**Specifying which children via field:**

```yaml
# Only check function body, not parameters
rule:
  kind: function_declaration
  has:
    field: body
    pattern: return $VAL

# Only check condition, not consequent
rule:
  kind: if_statement
  has:
    field: condition
    pattern: $A === null
```

**Controlling search depth:**

```yaml
# Avoids matching nested returns in inner functions
rule:
  kind: block_statement
  has:
    kind: return_statement
    stopBy: neighbor

# Searches entire function body including nested callbacks
rule:
  kind: function_declaration
  has:
    pattern: console.log($MSG)
```

Reference: [Relational Rules](https://ast-grep.github.io/reference/rule.html#relational-rules)

### 3.4 Use Inside for Contextual Matching

**Impact: HIGH (reduces false positives by 70-95%)**

The `inside` relational rule verifies that matched nodes appear within a specific parent structure. Use it to limit pattern matches to relevant contexts.

**Incorrect (matches everywhere):**

```yaml
id: find-this-usage
language: javascript
rule:
  pattern: this.$PROP
# Matches in classes, objects, functions - too broad
```

**Correct (scoped to class methods):**

```yaml
id: find-this-in-class
language: javascript
rule:
  all:
    - pattern: this.$PROP
    - inside:
        kind: class_declaration
```

**Controlling search depth with stopBy:**

```yaml
# Match only direct children (immediate parent)
rule:
  pattern: $EXPR
  inside:
    kind: if_statement
    stopBy: neighbor  # Only immediate parent

# Match anywhere in function (default)
rule:
  pattern: $EXPR
  inside:
    kind: function_declaration
    stopBy: end  # Search to root

# Stop at specific boundary
rule:
  pattern: await $EXPR
  inside:
    kind: function_declaration
    stopBy:
      kind: arrow_function  # Don't cross nested arrow functions
```

Reference: [Relational Rules](https://ast-grep.github.io/reference/rule.html#relational-rules)

### 3.5 Use Matches for Rule Reusability

**Impact: HIGH (enables DRY rule composition)**

The `matches` rule references utility rules by ID. Define common patterns once and reuse them across multiple rules.

**Incorrect (duplicates pattern logic):**

```yaml
id: rule-1
rule:
  all:
    - pattern: console.log($MSG)
    - inside:
        any:
          - kind: function_declaration
          - kind: arrow_function
---
id: rule-2
rule:
  all:
    - pattern: console.warn($MSG)
    - inside:
        any:
          - kind: function_declaration
          - kind: arrow_function
```

**Correct (utility rule for reuse):**

```yaml
# utils/inside-function.yml
id: inside-function
language: javascript
rule:
  inside:
    any:
      - kind: function_declaration
      - kind: arrow_function
---
# rules/no-console-log.yml
id: no-console-log
rule:
  all:
    - pattern: console.log($MSG)
    - matches: inside-function
---
# rules/no-console-warn.yml
id: no-console-warn
rule:
  all:
    - pattern: console.warn($MSG)
    - matches: inside-function
```

**Utility rule best practices:**
- Place in `utils/` directory
- Use descriptive IDs: `inside-function`, `is-exported`, `has-type-annotation`
- Reference with `matches: rule-id`
- Configure `utilsDirs` in `sgconfig.yml`

Reference: [Utility Rules](https://ast-grep.github.io/guide/project/utility-rule.html)

### 3.6 Use Not for Exclusion Patterns

**Impact: HIGH (reduces false positives by 30-70%)**

The `not` rule inverts matching logic. Use it to exclude specific patterns from broader matches.

**Incorrect (relies on post-processing to filter):**

```yaml
id: find-all-functions
language: javascript
rule:
  kind: function_declaration
# Then manually filter out async functions
```

**Correct (not excludes at match time):**

```yaml
id: find-sync-functions
language: javascript
rule:
  all:
    - kind: function_declaration
    - not:
        has:
          pattern: async
```

**Key behaviors:**
- `not` succeeds when its sub-rule fails to match
- Cannot capture meta variables (nothing matched)
- Often combined with `all` for filter patterns

**Common exclusion patterns:**

```yaml
# Match console.log but not inside catch blocks
rule:
  all:
    - pattern: console.log($MSG)
    - not:
        inside:
          kind: catch_clause

# Match await but not inside try blocks
rule:
  all:
    - pattern: await $EXPR
    - not:
        inside:
          kind: try_statement

# Match identifiers that aren't parameters
rule:
  all:
    - kind: identifier
    - not:
        inside:
          kind: formal_parameters
```

Reference: [Composite Rules](https://ast-grep.github.io/reference/rule.html#composite-rules)

---

## 4. Constraint Design

**Impact: HIGH**

Missing or incorrect constraints cause false positives or negatives. Constraints filter matches after pattern matching.

### 4.1 Avoid Constraints Inside Not Rules

**Impact: HIGH (prevents unexpected constraint behavior)**

Constraints cannot be used inside `not` rules because `not` succeeds when nothing matches, leaving no node to constrain.

**Incorrect (constraint inside not):**

```yaml
id: find-non-private
language: javascript
rule:
  all:
    - kind: identifier
    - not:
        pattern: $NAME
        constraints:
          NAME:
            regex: ^_  # This won't work as expected!
```

**Correct (constrain outside not):**

```yaml
id: find-non-private
language: javascript
rule:
  all:
    - kind: identifier
    - pattern: $NAME
    - not:
        regex: ^_
constraints:
  NAME:
    kind: identifier
```

**Alternative (use regex directly in not):**

```yaml
id: find-non-private
language: javascript
rule:
  all:
    - kind: identifier
    - not:
        regex: ^_
```

**Why this happens:** Constraints filter captured meta variables. When `not` succeeds, nothing was captured, so there's nothing to constrain.

**Workaround strategies:**
1. Move constraint to outer rule
2. Use `regex` directly in `not` (atomic rule)
3. Restructure as positive match with constraint

Reference: [FAQ](https://ast-grep.github.io/advanced/faq.html)

### 4.2 Understand Constraints Apply After Matching

**Impact: HIGH (prevents confusion about match failures)**

Constraints filter results after pattern matching completes. A pattern must first match successfully before constraints are evaluated.

**Incorrect (expects constraint to guide matching):**

```yaml
id: find-specific-call
language: javascript
rule:
  pattern: $FN()
constraints:
  FN:
    pattern: console.log  # Constraints don't make pattern more specific
```

**Correct (use specific pattern, constrain captures):**

```yaml
id: find-console-log
language: javascript
rule:
  pattern: console.log()  # Specific pattern
```

**Alternative (pattern then filter):**

```yaml
id: find-console-methods
language: javascript
rule:
  pattern: console.$METHOD($$$ARGS)
constraints:
  METHOD:
    regex: ^(log|warn|error)$  # Filter which methods
```

**Execution flow:**
1. Pattern matches against code → captures meta variables
2. Constraints evaluate against captured values
3. Match succeeds only if both pass

**When constraints are useful:**
- Pattern is necessarily generic (can't express specificity)
- Need to filter by properties pattern can't express
- Want different rules for same pattern, different constraints

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

### 4.3 Use Kind Constraints to Filter Meta Variables

**Impact: HIGH (reduces false positives by node type)**

Constraints filter captured meta variables after pattern matching. Use `kind` constraints to ensure variables match expected node types.

**Incorrect (accepts any node type):**

```yaml
id: find-function-call
language: javascript
rule:
  pattern: $FN($ARGS)
# Matches: getUser(), obj.method(), new Class() - too broad
```

**Correct (constrain to identifiers only):**

```yaml
id: find-simple-call
language: javascript
rule:
  pattern: $FN($ARGS)
constraints:
  FN:
    kind: identifier
# Only matches: getUser(), validate() - not obj.method()
```

**Multiple kind constraints:**

```yaml
id: find-callable-usage
language: javascript
rule:
  pattern: $FN($ARGS)
constraints:
  FN:
    any:
      - kind: identifier
      - kind: member_expression
```

**Important:** Constraints apply after pattern matching. The pattern must first match, then constraints filter the results.

**When to use kind constraints:**
- Filter function calls by callee type
- Distinguish variable declarations from parameters
- Separate property access from subscript access

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

### 4.4 Use Pattern Constraints for Structural Filtering

**Impact: HIGH (reduces false positives by 40-80%)**

Use `pattern` constraints to verify that captured meta variables match a specific code structure, not just kind or text.

**Incorrect (kind constraint too broad):**

```yaml
id: find-null-check
language: javascript
rule:
  pattern: if ($COND) { $$$BODY }
constraints:
  COND:
    kind: binary_expression  # Matches any binary expression
```

**Correct (pattern constraint for specific structure):**

```yaml
id: find-null-check
language: javascript
rule:
  pattern: if ($COND) { $$$BODY }
constraints:
  COND:
    pattern: $VAR === null
```

**Combining multiple constraint types:**

```yaml
id: find-hook-call-with-deps
language: javascript
rule:
  pattern: $HOOK($CALLBACK, $DEPS)
constraints:
  HOOK:
    regex: ^use(Effect|Callback|Memo)$
  DEPS:
    pattern: '[$$$ITEMS]'  # Must be array literal
```

**Structural constraint use cases:**
- Verify function arguments have specific shape
- Match only certain binary operators
- Filter by nested structure depth

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

### 4.5 Use Regex Constraints for Text Patterns

**Impact: HIGH (reduces false positives by 50-90%)**

Use `regex` constraints to filter meta variables by their text content. The regex must match the entire node text.

**Incorrect (pattern can't filter by name):**

```yaml
id: find-hook-usage
language: javascript
rule:
  pattern: use$HOOK()  # Invalid! Can't mix text and meta vars
```

**Correct (use regex constraint):**

```yaml
id: find-hook-usage
language: javascript
rule:
  pattern: $HOOK()
constraints:
  HOOK:
    regex: ^use[A-Z]
```

**Common regex patterns:**

```yaml
# Match React hooks (useEffect, useState, etc.)
constraints:
  FN:
    regex: ^use[A-Z]\w*$

# Match private fields (_name, _value)
constraints:
  PROP:
    regex: ^_

# Match test functions (test_*, *_test)
constraints:
  NAME:
    regex: (^test_|_test$)

# Match specific prefixes
constraints:
  VAR:
    regex: ^(temp|tmp|_)
```

**Important:** Regex matches against the full text representation of the captured node, including nested content.

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

---

## 5. Rewrite Correctness

**Impact: MEDIUM-HIGH**

Incorrect rewrite patterns can introduce bugs into codebases. Rewrites must preserve program semantics while making intended changes.

### 5.1 Ensure Fix Templates Produce Valid Syntax

**Impact: MEDIUM-HIGH (prevents generating unparseable code)**

Fix templates are inserted textually without parsing. Ensure meta variable substitutions produce syntactically valid code for all possible matches.

**Incorrect (fix may produce invalid syntax):**

```yaml
id: wrap-in-array
language: javascript
rule:
  pattern: $EXPR
fix: '[$EXPR]'
# If $EXPR is "a, b", produces "[a, b]" - different meaning!
```

**Correct (account for expression types):**

```yaml
id: wrap-single-value
language: javascript
rule:
  pattern: $EXPR
constraints:
  EXPR:
    not:
      kind: sequence_expression  # Exclude comma expressions
fix: '[$EXPR]'
```

**Syntax validation checklist:**
- Parentheses balance after substitution
- Quote escaping in string contexts
- Comma placement for multi-match variables
- Statement terminators (semicolons)

**Handling edge cases:**

```yaml
# Multi-match needs comma handling
id: spread-args
rule:
  pattern: fn($$$ARGS)
fix: newFn(...[$$$ARGS])  # Commas preserved from original

# Statement vs expression context
id: add-return
rule:
  pattern: $EXPR
  inside:
    kind: arrow_function
    field: body
fix: '{ return $EXPR; }'  # Add braces and semicolon
```

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

### 5.2 Preserve Program Semantics in Rewrites

**Impact: MEDIUM-HIGH (prevents introducing bugs during transformation)**

Rewrites replace matched code textually. Ensure the replacement maintains identical behavior to avoid introducing subtle bugs.

**Incorrect (changes evaluation order):**

```yaml
id: simplify-ternary
language: javascript
rule:
  pattern: $COND ? $THEN : $ELSE
fix: $COND && $THEN || $ELSE
# Bug: if $THEN is falsy, $ELSE executes even when $COND is true
```

**Correct (semantically equivalent transformation):**

```yaml
id: convert-to-if
language: javascript
rule:
  pattern: $COND ? true : false
fix: Boolean($COND)
```

**Semantic preservation checklist:**
- Does the replacement evaluate the same expressions?
- Are side effects executed in the same order?
- Are variables captured in the same scope?
- Does short-circuit evaluation change?

**Safe transformations:**

```yaml
# Safe: !! to Boolean()
pattern: '!!$EXPR'
fix: Boolean($EXPR)

# Safe: array spread for concat
pattern: $ARR.concat($ITEM)
fix: '[...$ARR, $ITEM]'

# Unsafe: may change behavior
pattern: $A || $B
fix: $A ?? $B  # Different for falsy vs nullish!
```

Reference: [Transformation](https://ast-grep.github.io/reference/yaml/transformation.html)

### 5.3 Reference All Necessary Meta Variables in Fix

**Impact: MEDIUM-HIGH (prevents loss of captured code)**

The `fix` template replaces matched code textually. Any captured meta variable not referenced in the fix is lost.

**Incorrect (loses the message argument):**

```yaml
id: migrate-console
language: javascript
rule:
  pattern: console.log($MSG, $$$REST)
fix: logger.info()  # $MSG and $$$REST are lost!
```

**Correct (preserves all captures):**

```yaml
id: migrate-console
language: javascript
rule:
  pattern: console.log($MSG, $$$REST)
fix: logger.info($MSG, $$$REST)
```

**Intentional omission for cleanup:**

```yaml
# Remove debug statements entirely (intentional loss)
id: remove-debug
language: javascript
rule:
  pattern: console.debug($$$ARGS)
fix: ''  # Empty fix removes the statement
```

**Checking for completeness:**

```yaml
# Before deploying, verify fix includes:
# 1. All single meta variables ($VAR)
# 2. All multi-match variables ($$$VAR) if needed
# 3. Proper syntax around insertions
rule:
  pattern: old($A, $B, $C)
fix: new($A, $B, $C)  # All three preserved
```

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

### 5.4 Test Rewrites on Representative Code

**Impact: MEDIUM-HIGH (prevents 90% of rewrite bugs)**

Always test rewrites with `--interactive` mode on representative samples before running on entire codebase. Edge cases in real code often break assumptions.

**Incorrect (deploys untested rewrite):**

```bash
# Dangerous: applies to entire codebase without verification
ast-grep scan --rule migrate.yml --update-all
```

**Correct (interactive testing first):**

```bash
# Step 1: Test on sample file
ast-grep run -p 'console.log($MSG)' -r 'logger.info($MSG)' sample.js

# Step 2: Interactive review on subset
ast-grep scan --rule migrate.yml --interactive src/module/

# Step 3: Full deployment after confidence
ast-grep scan --rule migrate.yml --update-all
```

**Testing workflow:**

```yaml
# 1. Create test file for rule
# tests/migrate-console-test.yml
id: migrate-console
valid:
  - 'logger.info(msg)'
  - 'console.debug(msg)'  # Should not match
invalid:
  - 'console.log(msg)'
  - 'console.log("test", data)'
```

```bash
# 2. Run rule tests
ast-grep test -c sgconfig.yml

# 3. Dry run on codebase
ast-grep scan --rule migrate.yml  # View matches only

# 4. Interactive apply
ast-grep scan --rule migrate.yml --interactive
```

Reference: [CLI Reference](https://ast-grep.github.io/reference/cli.html)

### 5.5 Use Transform for Complex Rewrites

**Impact: MEDIUM-HIGH (enables sophisticated code transformations)**

The `transform` section modifies captured meta variables before inserting into the fix. Use it for case conversion, substring extraction, and regex replacement.

**Incorrect (manual string manipulation not possible):**

```yaml
id: convert-case
language: javascript
rule:
  pattern: const $VAR = $VAL
fix: const $VAR_UPPER = $VAL  # Can't uppercase in fix template
```

**Correct (use transform):**

```yaml
id: convert-to-screaming-case
language: javascript
rule:
  pattern: const $VAR = $VAL
transform:
  UPPER_VAR:
    convert:
      source: $VAR
      toCase: upperCase
fix: const $UPPER_VAR = $VAL
```

**Transform operations:**

```yaml
# Replace with regex
transform:
  NEW_NAME:
    replace:
      source: $NAME
      replace: 'old'
      by: 'new'

# Extract substring
transform:
  PREFIX:
    substring:
      source: $VAR
      startChar: 0
      endChar: 3

# Case conversion
transform:
  CAMEL:
    convert:
      source: $VAR
      toCase: camelCase
      # Options: lowerCase, upperCase, capitalize,
      # camelCase, snakeCase, kebabCase, pascalCase
```

**Chaining transforms:** Create intermediate variables to chain multiple operations.

Reference: [Transformation](https://ast-grep.github.io/reference/yaml/transformation.html)

---

## 6. Project Organization

**Impact: MEDIUM**

Poor organization leads to maintenance burden and rule conflicts. Well-structured projects enable team collaboration and rule reuse.

### 6.1 Assign Appropriate Severity Levels

**Impact: MEDIUM (enables prioritized issue triage)**

Set severity levels that reflect the actual impact of rule violations. This enables developers to prioritize fixes and configure CI appropriately.

**Incorrect (everything is error):**

```yaml
id: prefer-const
severity: error  # Style preference shouldn't block CI

id: sql-injection
severity: warning  # Security issue should be error
```

**Correct (severity matches impact):**

```yaml
id: prefer-const
language: javascript
severity: hint  # Style suggestion
rule:
  pattern: let $VAR = $VAL
message: Consider using const for variables that are never reassigned
---
id: sql-injection
language: javascript
severity: error  # Security vulnerability
rule:
  pattern: db.query($QUERY)
message: Potential SQL injection vulnerability
```

**Severity level guidelines:**

| Severity | Use Case | CI Behavior |
|----------|----------|-------------|
| error | Security, correctness bugs | Fail build |
| warning | Likely bugs, deprecated usage | Warn, may fail |
| hint | Style preferences | Informational |
| off | Temporarily disabled | Skipped |

**Note field for context:**

```yaml
severity: error
message: Avoid eval() for security
note: |
  eval() executes arbitrary code, enabling code injection attacks.
  Use JSON.parse() for data or Function constructor for dynamic code.
```

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

### 6.2 Use File Filtering for Targeted Rules

**Impact: MEDIUM (reduces false positives and scan time)**

Use `files` and `ignores` globs to apply rules only to relevant files. This reduces false positives and improves scan performance.

**Incorrect (applies to all files):**

```yaml
id: react-hooks-rules
language: tsx
rule:
  pattern: useEffect($$$ARGS)
# Runs on all .tsx files including non-React code
```

**Correct (targeted to React components):**

```yaml
id: react-hooks-rules
language: tsx
files:
  - 'src/components/**/*.tsx'
  - 'src/hooks/**/*.tsx'
ignores:
  - '**/*.test.tsx'
  - '**/*.stories.tsx'
rule:
  pattern: useEffect($$$ARGS)
```

**Glob pattern tips:**
- Paths are relative to `sgconfig.yml` location
- Don't use `./` prefix
- Use `**` for recursive matching
- Use `*` for single directory level

**Common filtering patterns:**

```yaml
# Only source files, not tests
files:
  - 'src/**/*.ts'
ignores:
  - '**/*.test.ts'
  - '**/*.spec.ts'
  - '**/__tests__/**'

# Only test files
files:
  - '**/*.test.ts'
  - '**/*.spec.ts'

# Specific directories
files:
  - 'packages/core/**/*.ts'
ignores:
  - '**/node_modules/**'
  - '**/dist/**'
```

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

### 6.3 Use Standard Project Directory Structure

**Impact: MEDIUM (enables team collaboration and tool discovery)**

Organize ast-grep projects with standard directories for rules, utilities, and tests. The `sgconfig.yml` file defines project root and directories.

**Incorrect (flat structure, no config):**

```text
project/
├── rule1.yml
├── rule2.yml
├── test1.yml
└── some-code.js
```

**Correct (organized with sgconfig.yml):**

```text
project/
├── sgconfig.yml
├── rules/
│   ├── security/
│   │   └── no-eval.yml
│   └── style/
│       └── prefer-const.yml
├── utils/
│   └── inside-function.yml
└── tests/
    ├── no-eval-test.yml
    └── prefer-const-test.yml
```

**sgconfig.yml example:**

```yaml
ruleDirs:
  - rules
utilsDirs:
  - utils
testConfigs:
  - testDir: tests
```

**Directory purposes:**
- `rules/` - Lint rules that produce diagnostics
- `utils/` - Reusable rule fragments (utility rules)
- `tests/` - Test cases for rule validation

**Initialize with:**

```bash
ast-grep new project  # Creates sgconfig.yml
ast-grep new rule     # Scaffolds rule file
ast-grep new test     # Creates test file
```

Reference: [Tooling Overview](https://ast-grep.github.io/guide/tooling-overview.html)

### 6.4 Use Unique Descriptive Rule IDs

**Impact: MEDIUM (prevents rule conflicts and enables suppression)**

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

### 6.5 Write Clear Actionable Messages

**Impact: MEDIUM (2-5× faster issue resolution)**

Write messages that explain what's wrong and how to fix it. Use `note` for detailed guidance and `labels` for precise highlighting.

**Incorrect (vague, unhelpful message):**

```yaml
id: bad-code
message: Bad code detected
```

**Correct (specific, actionable):**

```yaml
id: no-console-in-production
language: javascript
rule:
  pattern: console.$METHOD($$$ARGS)
message: Remove console.$METHOD() before deploying to production
note: |
  Console statements slow down execution and expose debugging
  information in production. Use a logging library instead:

  - logger.info() for informational messages
  - logger.error() for error tracking

  Or wrap in environment check: if (process.env.NODE_ENV === 'development')
```

**Using labels for precision:**

```yaml
id: missing-await
rule:
  pattern: $PROMISE
  inside:
    kind: expression_statement
    has:
      kind: call_expression
labels:
  - source: $PROMISE
    style: primary
    message: This promise is not awaited
```

**Message writing guidelines:**
- State the problem clearly
- Reference captured variables: `$METHOD`
- Provide the fix in `note`
- Include code examples in `note` when helpful
- Use labels to highlight specific code regions

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

---

## 7. Performance Optimization

**Impact: MEDIUM**

Inefficient rules slow down scans on large codebases. Pattern specificity and rule structure affect matching performance.

### 7.1 Avoid Heavy Regex in Hot Paths

**Impact: MEDIUM (2-10× faster matching with AST patterns)**

Regex matching is slower than AST pattern matching. Use patterns and kind filters first, then apply regex only when necessary.

**Incorrect (regex as primary filter):**

```yaml
id: find-variables
language: javascript
rule:
  kind: identifier
  regex: '.*'  # Matches all identifiers, then filters
constraints:
  # Complex regex on every identifier
```

**Correct (pattern first, regex to refine):**

```yaml
id: find-prefixed-variables
language: javascript
rule:
  pattern: $VAR
  inside:
    kind: variable_declarator
constraints:
  VAR:
    regex: ^(cache|pending|_)
```

**Regex optimization tips:**

```yaml
# Anchor patterns for faster matching
regex: ^prefix  # Faster than: .*prefix
regex: suffix$  # Faster than: suffix.*

# Use character classes efficiently
regex: ^[a-z_][a-zA-Z0-9_]*$  # Identifier pattern

# Avoid catastrophic backtracking
# Bad: (a+)+b
# Good: a+b
```

**When to use regex vs pattern:**

| Use Case | Prefer |
|----------|--------|
| Structural matching | pattern |
| Node type filtering | kind |
| Text content filtering | regex (in constraints) |
| Partial name matching | regex |

**Performance hierarchy:**
1. `kind` - fastest (direct node type check)
2. `pattern` - fast (tree comparison)
3. `regex` - slower (string matching)

Reference: [Atomic Rules](https://ast-grep.github.io/reference/rule.html#atomic-rules)

### 7.2 Leverage Parallel Scanning with Threads

**Impact: MEDIUM (utilizes multi-core CPUs for faster scans)**

ast-grep scans files in parallel by default. Tune thread count for optimal performance on your hardware and codebase size.

**Incorrect (single-threaded on large codebase):**

```bash
ast-grep scan -c sgconfig.yml -j 1  # Forces single thread
```

**Correct (use optimal thread count):**

```bash
# Let ast-grep choose (default - usually optimal)
ast-grep scan -c sgconfig.yml

# Explicit for CPU-bound machines
ast-grep scan -c sgconfig.yml -j 8  # 8 threads

# Check available cores
ast-grep scan -c sgconfig.yml -j $(nproc)
```

**Thread tuning guidelines:**
- Default heuristic works well for most cases
- I/O-bound (SSD): More threads than cores can help
- CPU-bound (complex rules): Match thread count to cores
- Memory-constrained: Reduce threads to lower peak memory

**CI/CD optimization:**

```yaml
# GitHub Actions example
- name: Lint with ast-grep
  run: |
    ast-grep scan -c sgconfig.yml -j 4 --json > results.json
```

**Measuring performance:**

```bash
# Time the scan
time ast-grep scan -c sgconfig.yml

# Compare thread counts
time ast-grep scan -c sgconfig.yml -j 1
time ast-grep scan -c sgconfig.yml -j 4
time ast-grep scan -c sgconfig.yml -j 8
```

Reference: [CLI Reference](https://ast-grep.github.io/reference/cli.html)

### 7.3 Use Specific Patterns Over Generic Ones

**Impact: MEDIUM (reduces matching iterations on large codebases)**

More specific patterns match fewer nodes, improving scan performance. Avoid overly generic patterns that match most of the codebase.

**Incorrect (matches every expression):**

```yaml
id: find-issues
language: javascript
rule:
  pattern: $EXPR  # Matches every expression in codebase
  # Then filters with complex constraints
constraints:
  EXPR:
    kind: call_expression
    has:
      pattern: console
```

**Correct (specific pattern, fewer matches):**

```yaml
id: find-console-calls
language: javascript
rule:
  pattern: console.$METHOD($$$ARGS)
```

**Pattern specificity hierarchy (fastest to slowest):**
1. Literal patterns: `console.log("debug")`
2. Partial literals: `console.log($MSG)`
3. Kind-specific: `kind: call_expression`
4. Generic captures: `$EXPR`

**Balancing specificity:**

```yaml
# Too specific - misses variations
pattern: console.log($MSG)
# Misses: console.log(a, b)

# Right balance - specific enough, flexible
pattern: console.log($$$ARGS)

# Too generic - matches too much
pattern: $FUNC($$$ARGS)
```

**When generic patterns are unavoidable:**
- Add `kind` to narrow node types
- Use `inside` to limit search scope
- Apply file filtering to reduce scan area

Reference: [Core Concepts](https://ast-grep.github.io/advanced/core-concepts.html)

### 7.4 Use StopBy to Limit Search Depth

**Impact: MEDIUM (reduces tree traversal in relational rules)**

Relational rules like `inside` and `has` search the entire tree by default. Use `stopBy` to limit search depth and improve performance.

**Incorrect (searches to root):**

```yaml
id: find-nested-await
language: javascript
rule:
  pattern: await $EXPR
  inside:
    kind: function_declaration
    # Searches all the way up the tree - expensive
```

**Correct (bounded search):**

```yaml
id: find-await-in-function
language: javascript
rule:
  pattern: await $EXPR
  inside:
    kind: function_declaration
    stopBy:
      kind: arrow_function  # Don't cross nested functions
```

**StopBy options:**

```yaml
# Stop at immediate parent only
inside:
  kind: block_statement
  stopBy: neighbor

# Stop at end (default - searches entire tree)
inside:
  kind: function_declaration
  stopBy: end

# Stop at specific node type
inside:
  kind: class_declaration
  stopBy:
    kind: function_declaration
```

**Performance impact:**
- `stopBy: neighbor` - O(1), checks parent only
- `stopBy: {kind: X}` - O(depth to X)
- `stopBy: end` - O(tree height), slowest

**Common boundaries:**
- Functions: `stopBy: { any: [{ kind: function_declaration }, { kind: arrow_function }] }`
- Classes: `stopBy: { kind: class_declaration }`
- Blocks: `stopBy: { kind: block_statement }`

Reference: [Relational Rules](https://ast-grep.github.io/reference/rule.html#relational-rules)

---

## 8. Testing & Debugging

**Impact: LOW-MEDIUM**

Lack of testing leads to regressions and hard-to-diagnose issues. Testing rules before deployment prevents production surprises.

### 8.1 Test Edge Cases and Boundary Conditions

**Impact: LOW-MEDIUM (catches 80% of production bugs)**

Include edge cases that stress pattern boundaries. Real codebases contain unusual but valid code that breaks naive patterns.

**Incorrect (only happy path):**

```yaml
id: no-console-log
valid:
  - logger.info(msg)
invalid:
  - console.log(msg)
# Missing: multiline, nested, chained, commented
```

**Correct (comprehensive edge cases):**

```yaml
id: no-console-log
valid:
  # Similar patterns that shouldn't match
  - logger.info(msg)
  - window.console  # Just property access
  - 'const console = mock'  # Shadowed
  # Commented code (doesn't match)
  - '// console.log(debug)'

invalid:
  # Basic cases
  - console.log(msg)
  - console.log()
  - console.log(a, b, c)

  # Multiline
  - |
    console.log(
      longMessage
    )

  # Chained
  - console.log(msg) || fallback

  # Nested
  - fn(console.log(msg))

  # In expressions
  - 'x = console.log(y)'

  # Template literals
  - 'console.log(`template ${var}`)'
```

**Edge case categories:**

| Category | Examples |
|----------|----------|
| Whitespace | Multiline, extra spaces |
| Nesting | Inside functions, callbacks |
| Chaining | Method chains, pipelines |
| Context | Different statement types |
| Literals | Strings, templates, regex |
| Comments | Near matches (shouldn't match) |

Reference: [Testing Rules](https://ast-grep.github.io/guide/project/test-rule.html)

### 8.2 Test Patterns in Playground First

**Impact: LOW-MEDIUM (5-10× faster pattern iteration)**

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

### 8.3 Use Snapshot Testing for Fix Verification

**Impact: LOW-MEDIUM (prevents 95% of rewrite regressions)**

Snapshot testing captures expected rewrite output. Use `--update-all` to regenerate snapshots when intentionally changing fixes.

**Incorrect (no fix verification):**

```yaml
id: migrate-import
rule:
  pattern: require($PATH)
fix: import $PATH  # Fix applied but never tested!
```

**Correct (snapshot test for fix):**

```yaml
# tests/migrate-import-test.yml
id: migrate-import
valid:
  - import 'lodash'
invalid:
  - require('lodash')

# Run test to generate snapshot
# ast-grep test -c sgconfig.yml
```

**Generated snapshot file:**

```yaml
# __snapshots__/migrate-import-test.yml.snap
id: migrate-import
snapshots:
  require('lodash'):
    fixed: import 'lodash'
    labels: []
```

**Snapshot workflow:**

```bash
# 1. Write rule with fix
# 2. Write test cases

# 3. Generate initial snapshots
ast-grep test -c sgconfig.yml -U

# 4. Review snapshots in __snapshots__/

# 5. Commit both test and snapshot files

# 6. CI runs tests against snapshots
ast-grep test -c sgconfig.yml
```

**Updating after intentional changes:**

```bash
# After modifying fix template
ast-grep test -c sgconfig.yml --update-all
# Review changes, then commit
```

Reference: [Testing Rules](https://ast-grep.github.io/guide/project/test-rule.html)

### 8.4 Write Both Valid and Invalid Test Cases

**Impact: LOW-MEDIUM (catches 70% of false positive/negative bugs)**

Test files must include both `valid` (should not match) and `invalid` (should match) cases. This verifies both precision and recall.

**Incorrect (only invalid cases):**

```yaml
id: no-console
valid: []  # No valid cases - doesn't test for false positives
invalid:
  - console.log(msg)
  - console.warn(msg)
```

**Correct (both valid and invalid):**

```yaml
id: no-console
valid:
  - logger.info(msg)          # Alternative approach
  - console                   # Just the identifier, not a call
  - 'const console = {}'      # Shadowed variable
invalid:
  - console.log(msg)
  - console.warn(msg)
  - console.error(a, b, c)
```

**Test case categories:**

```yaml
valid:
  # Similar but different patterns
  - logger.log(msg)
  # Edge cases that shouldn't match
  - 'obj.console.log(msg)'
  # Already fixed code
  - 'if (DEBUG) console.log(msg)'

invalid:
  # Basic case
  - console.log(msg)
  # Variations
  - console.log()
  - console.log(a, b)
  # Edge cases that should match
  - 'console.log("literal")'
```

**Running tests:**

```bash
ast-grep test -c sgconfig.yml
# Or for specific test file
ast-grep test -t tests/no-console-test.yml
```

Reference: [Testing Rules](https://ast-grep.github.io/guide/project/test-rule.html)

---

## References

1. [https://ast-grep.github.io/](https://ast-grep.github.io/)
2. [https://ast-grep.github.io/guide/rule-config.html](https://ast-grep.github.io/guide/rule-config.html)
3. [https://ast-grep.github.io/reference/cli.html](https://ast-grep.github.io/reference/cli.html)
4. [https://github.com/ast-grep/ast-grep](https://github.com/ast-grep/ast-grep)
5. [https://github.com/coderabbitai/ast-grep-essentials](https://github.com/coderabbitai/ast-grep-essentials)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |