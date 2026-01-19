# jscodeshift

**Version 0.1.0**  
Facebook/Meta  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for jscodeshift codemod development, designed for AI agents and LLMs. Contains 40+ rules across 8 categories, prioritized by impact from critical (parser configuration, AST traversal) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated codemod creation and code generation.

---

## Table of Contents

1. [Parser Configuration](references/_sections.md#1-parser-configuration) — **CRITICAL**
   - 1.1 [Avoid Default Babel5Compat Parser for Modern Syntax](references/parser-babel5-compat.md) — CRITICAL (prevents parse failures on post-ES2015 features)
   - 1.2 [Export Parser from Transform Module](references/parser-export-declaration.md) — CRITICAL (prevents 100% of parser mismatch failures)
   - 1.3 [Match AST Explorer Parser to jscodeshift Parser](references/parser-astexplorer-match.md) — CRITICAL (prevents AST structure mismatches during development)
   - 1.4 [Use Correct Parser for TypeScript Files](references/parser-typescript-config.md) — CRITICAL (prevents 100% transform failures on TypeScript codebases)
   - 1.5 [Use Flow Parser for Flow-Typed Code](references/parser-flow-annotation.md) — CRITICAL (prevents parse failures on Flow type annotations)
2. [AST Traversal Patterns](references/_sections.md#2-ast-traversal-patterns) — **CRITICAL**
   - 2.1 [Avoid Repeated find() Calls for Same Node Type](references/traverse-avoid-repeated-find.md) — CRITICAL (reduces traversal from N passes to 1 pass)
   - 2.2 [Return Early When No Transformation Needed](references/traverse-early-return.md) — CRITICAL (10-100× faster on files with no matches)
   - 2.3 [Use closestScope() for Scope-Aware Transforms](references/traverse-closest-scope.md) — CRITICAL (prevents incorrect transforms on shadowed variables)
   - 2.4 [Use find() with Filter Object Over filter() Chain](references/traverse-find-filter-pattern.md) — CRITICAL (2-5× faster than separate filter() calls)
   - 2.5 [Use Specific Node Types in find() Calls](references/traverse-find-specific-type.md) — CRITICAL (10-100× faster traversal on large files)
   - 2.6 [Use Two-Pass Pattern for Complex Transforms](references/traverse-two-pass-pattern.md) — CRITICAL (reduces O(n²) to O(n) on complex transformations)
3. [Node Filtering](references/_sections.md#3-node-filtering) — **HIGH**
   - 3.1 [Add Nullish Checks Before Property Access](references/filter-nullish-checks.md) — HIGH (prevents runtime crashes on optional AST properties)
   - 3.2 [Check Parent Path Before Transformation](references/filter-path-parent-check.md) — HIGH (prevents false positives on nested structures)
   - 3.3 [Distinguish JSX Context from Regular JavaScript](references/filter-jsx-context.md) — HIGH (prevents incorrect transforms in JSX attributes vs expressions)
   - 3.4 [Handle Computed Property Keys in Filters](references/filter-computed-properties.md) — HIGH (prevents missed transforms on dynamic object keys)
   - 3.5 [Track Import Bindings for Accurate Usage Detection](references/filter-import-binding.md) — HIGH (prevents missed transforms due to import aliases)
4. [AST Transformation](references/_sections.md#4-ast-transformation) — **HIGH**
   - 4.1 [Insert Imports at Correct Position](references/transform-insert-import.md) — HIGH (maintains valid module structure and import ordering)
   - 4.2 [Preserve Comments When Replacing Nodes](references/transform-preserve-comments.md) — HIGH (prevents loss of documentation and directives)
   - 4.3 [Remove Unused Imports After Transformation](references/transform-remove-unused-imports.md) — HIGH (prevents dead imports causing build warnings or errors)
   - 4.4 [Use Builder API for Creating AST Nodes](references/transform-builder-api.md) — HIGH (prevents malformed AST nodes that crash toSource())
   - 4.5 [Use renameTo for Variable Renaming](references/transform-renameto.md) — HIGH (prevents 100% of scope-related rename bugs)
   - 4.6 [Use replaceWith Callback for Context-Aware Transforms](references/transform-replacewith-callback.md) — HIGH (enables dynamic transformations based on original node)
5. [Code Generation](references/_sections.md#5-code-generation) — **MEDIUM**
   - 5.1 [Configure toSource() for Consistent Formatting](references/codegen-tosource-options.md) — MEDIUM (prevents unnecessary diffs and maintains code style)
   - 5.2 [Preserve Original Code Style with Recast](references/codegen-preserve-style.md) — MEDIUM (minimizes diff size by keeping unchanged code intact)
   - 5.3 [Set Appropriate Print Width for Long Lines](references/codegen-print-width.md) — MEDIUM (prevents overly long lines that break linting rules)
   - 5.4 [Use Template Literals for Complex Node Creation](references/codegen-template-literals.md) — MEDIUM (reduces node creation code by 70-90%)
6. [Testing Strategies](references/_sections.md#6-testing-strategies) — **MEDIUM**
   - 6.1 [Test for Parse Error Handling](references/test-parse-errors.md) — MEDIUM (prevents transform crashes on malformed files)
   - 6.2 [Use defineInlineTest for Input/Output Verification](references/test-inline-snapshots.md) — MEDIUM (catches 95%+ transform regressions automatically)
   - 6.3 [Use Dry Run Mode for Codebase Exploration](references/test-dry-run-exploration.md) — MEDIUM (enables safe exploration without modifying files)
   - 6.4 [Use Fixture Files for Complex Test Cases](references/test-fixture-files.md) — MEDIUM (catches 90%+ edge cases missed by inline tests)
   - 6.5 [Write Negative Test Cases First](references/test-negative-cases.md) — MEDIUM (prevents unintended transformations before they happen)
7. [Runner Optimization](references/_sections.md#7-runner-optimization) — **LOW-MEDIUM**
   - 7.1 [Configure Worker Count for Optimal Parallelization](references/runner-parallel-workers.md) — LOW-MEDIUM (2-4× speedup on multi-core systems)
   - 7.2 [Filter Files by Extension](references/runner-extensions-filter.md) — LOW-MEDIUM (prevents 100% of missed file type transforms)
   - 7.3 [Process Large Codebases in Batches](references/runner-batch-processing.md) — LOW-MEDIUM (prevents memory exhaustion on large codebases)
   - 7.4 [Use Ignore Patterns to Skip Non-Source Files](references/runner-ignore-patterns.md) — LOW-MEDIUM (prevents wasted processing on generated/vendor code)
   - 7.5 [Use Verbose Output for Debugging Transforms](references/runner-verbose-output.md) — LOW-MEDIUM (reduces debugging time by 50-80%)
8. [Advanced Patterns](references/_sections.md#8-advanced-patterns) — **LOW**
   - 8.1 [Compose Multiple Transforms into Pipelines](references/advanced-compose-transforms.md) — LOW (enables reusable, testable transform building blocks)
   - 8.2 [Create Custom Collection Methods](references/advanced-custom-collections.md) — LOW (reduces query code by 50-80% through reuse)
   - 8.3 [Share State Across Files with Options](references/advanced-multi-file-state.md) — LOW (enables cross-file analysis and coordinated transforms)
   - 8.4 [Use Scope Analysis for Safe Variable Transforms](references/advanced-scope-analysis.md) — LOW (prevents 100% of scope-related transform bugs)

---

## References

1. [https://github.com/facebook/jscodeshift](https://github.com/facebook/jscodeshift)
2. [https://jscodeshift.com/](https://jscodeshift.com/)
3. [https://jscodeshift.com/build/api-reference/](https://jscodeshift.com/build/api-reference/)
4. [https://martinfowler.com/articles/codemods-api-refactoring.html](https://martinfowler.com/articles/codemods-api-refactoring.html)
5. [https://github.com/benjamn/ast-types](https://github.com/benjamn/ast-types)
6. [https://github.com/benjamn/recast](https://github.com/benjamn/recast)
7. [https://astexplorer.net/](https://astexplorer.net/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |