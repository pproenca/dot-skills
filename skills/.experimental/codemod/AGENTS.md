# Codemod

**Version 0.1.0**  
Codemod Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for Codemod (JSSG, ast-grep, workflows), designed for AI agents and LLMs. Contains 48 rules across 11 categories, prioritized by impact from critical (AST understanding, pattern efficiency, parsing strategy) to incremental (security, package structure). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [AST Understanding](references/_sections.md#1-ast-understanding) — **CRITICAL**
   - 1.1 [Check Null Before Property Access](references/ast-check-null-before-access.md) — CRITICAL (prevents runtime crashes in transforms)
   - 1.2 [Understand Named vs Anonymous Nodes](references/ast-understand-named-vs-anonymous.md) — CRITICAL (eliminates 80% of pattern matching failures)
   - 1.3 [Use AST Explorer Before Writing Patterns](references/ast-explore-before-writing.md) — CRITICAL (prevents hours of debugging invalid patterns)
   - 1.4 [Use Field Access for Structural Queries](references/ast-field-access-for-structure.md) — CRITICAL (enables precise child selection in complex nodes)
   - 1.5 [Use kind Constraint for Precision](references/ast-use-kind-for-precision.md) — CRITICAL (reduces false positives by 10x)
2. [Pattern Efficiency](references/_sections.md#2-pattern-efficiency) — **CRITICAL**
   - 2.1 [Avoid Overly Generic Patterns](references/pattern-avoid-overly-generic.md) — CRITICAL (reduces matching time from minutes to seconds)
   - 2.2 [Combine Patterns with Rule Operators](references/pattern-combine-with-rules.md) — CRITICAL (enables complex matching without multiple passes)
   - 2.3 [Ensure Patterns Are Idempotent](references/pattern-ensure-idempotency.md) — CRITICAL (prevents infinite transformation loops)
   - 2.4 [Use Constraints for Reusable Matching Logic](references/pattern-use-constraints.md) — CRITICAL (eliminates pattern duplication across rules)
   - 2.5 [Use Meta Variables for Flexible Matching](references/pattern-use-meta-variables.md) — CRITICAL (enables pattern reuse across variations)
   - 2.6 [Use Relational Patterns for Context](references/pattern-use-relational-patterns.md) — CRITICAL (enables context-aware matching without manual filtering)
3. [Parsing Strategy](references/_sections.md#3-parsing-strategy) — **CRITICAL**
   - 3.1 [Early Return for Non-Applicable Files](references/parse-early-return-non-applicable.md) — CRITICAL (10-100x speedup by skipping irrelevant files)
   - 3.2 [Handle Embedded Languages with parseAsync](references/parse-handle-embedded-languages.md) — CRITICAL (enables transformations in template literals and CSS-in-JS)
   - 3.3 [Provide Context for Ambiguous Patterns](references/parse-provide-pattern-context.md) — CRITICAL (prevents 100% of ambiguous pattern failures)
   - 3.4 [Select the Correct Parser for File Type](references/parse-select-correct-parser.md) — CRITICAL (prevents 100% transform failures from AST mismatch)
4. [Node Traversal](references/_sections.md#4-node-traversal) — **HIGH**
   - 4.1 [Cache Repeated Node Lookups](references/traverse-cache-repeated-lookups.md) — HIGH (eliminates redundant traversals in transform loops)
   - 4.2 [Collect Multiple Patterns in Single Traversal](references/traverse-single-pass-collection.md) — HIGH (reduces N traversals to 1 traversal)
   - 4.3 [Use find() for Single Match, findAll() for Multiple](references/traverse-use-find-vs-findall.md) — HIGH (find() short-circuits, reducing traversal by up to 99%)
   - 4.4 [Use Sibling Navigation Efficiently](references/traverse-use-siblings-efficiently.md) — HIGH (O(1) sibling access vs O(n) re-traversal)
   - 4.5 [Use stopBy to Control Traversal Depth](references/traverse-use-stopby-for-depth.md) — HIGH (prevents unbounded searches in deeply nested code)
5. [Semantic Analysis](references/_sections.md#5-semantic-analysis) — **HIGH**
   - 5.1 [Cache Semantic Analysis Results](references/semantic-cache-cross-file-results.md) — HIGH (avoids redundant cross-file resolution)
   - 5.2 [Handle Null Semantic Analysis Results](references/semantic-check-null-results.md) — HIGH (prevents crashes when symbols are unresolvable)
   - 5.3 [Use File Scope Semantic Analysis First](references/semantic-use-file-scope-first.md) — HIGH (10-100x faster than workspace scope for local transforms)
   - 5.4 [Verify File Ownership Before Cross-File Edits](references/semantic-verify-file-ownership.md) — HIGH (prevents editing node_modules and external files)
6. [Edit Operations](references/_sections.md#6-edit-operations) — **MEDIUM-HIGH**
   - 6.1 [Add Imports at Correct Position](references/edit-add-imports-correctly.md) — MEDIUM-HIGH (maintains valid module structure)
   - 6.2 [Batch Edits Before Committing](references/edit-batch-before-commit.md) — MEDIUM-HIGH (prevents edit conflicts and improves performance)
   - 6.3 [Handle Overlapping Edit Ranges](references/edit-handle-overlapping-ranges.md) — MEDIUM-HIGH (prevents corrupted output from conflicting edits)
   - 6.4 [Preserve Surrounding Formatting in Edits](references/edit-preserve-formatting.md) — MEDIUM-HIGH (maintains code style consistency)
   - 6.5 [Use flatMap for Conditional Edits](references/edit-use-flatmap-for-conditional.md) — MEDIUM-HIGH (eliminates null filtering, reduces code by 30%)
7. [Workflow Design](references/_sections.md#7-workflow-design) — **MEDIUM-HIGH**
   - 7.1 [Order Nodes by Dependency](references/workflow-order-nodes-by-dependency.md) — MEDIUM-HIGH (prevents failed transforms due to missing prerequisites)
   - 7.2 [Use Conditional Steps for Dynamic Workflows](references/workflow-use-conditional-steps.md) — MEDIUM-HIGH (reduces execution time by 30-70% for partial migrations)
   - 7.3 [Use Manual Gates for Critical Steps](references/workflow-use-manual-gates.md) — MEDIUM-HIGH (prevents runaway migrations with human checkpoints)
   - 7.4 [Use Matrix Strategy for Parallelism](references/workflow-use-matrix-for-parallelism.md) — MEDIUM-HIGH (3-10x speedup for independent transformations)
   - 7.5 [Validate Workflows Before Running](references/workflow-validate-before-run.md) — MEDIUM-HIGH (prevents 100% of schema and dependency errors)
8. [Testing Strategy](references/_sections.md#8-testing-strategy) — **MEDIUM**
   - 8.1 [Choose Appropriate Test Strictness Level](references/test-use-strictness-levels.md) — MEDIUM (reduces false test failures by 50-90%)
   - 8.2 [Cover Edge Cases in Test Fixtures](references/test-cover-edge-cases.md) — MEDIUM (prevents production failures on unusual code)
   - 8.3 [Test on File Subset Before Full Run](references/test-run-on-subset-first.md) — MEDIUM (catches errors 10-100x faster before full run)
   - 8.4 [Update Test Fixtures Intentionally](references/test-update-fixtures-intentionally.md) — MEDIUM (prevents accidental regressions from auto-updates)
   - 8.5 [Use Input/Expected Fixture Pairs](references/test-use-fixture-pairs.md) — MEDIUM (enables repeatable, automated validation)
9. [State Management](references/_sections.md#9-state-management) — **MEDIUM**
   - 9.1 [Log Progress for Long-Running Migrations](references/state-log-progress-for-observability.md) — MEDIUM (enables monitoring and debugging of multi-hour migrations)
   - 9.2 [Make Transforms Idempotent for Safe Reruns](references/state-make-transforms-idempotent.md) — MEDIUM (prevents infinite loops and double-transformation)
   - 9.3 [Use State for Resumable Migrations](references/state-use-for-resumability.md) — MEDIUM (enables restart from failure point in long migrations)
10. [Security and Capabilities](references/_sections.md#10-security-and-capabilities) — **LOW-MEDIUM**
   - 10.1 [Minimize Requested Capabilities](references/security-minimize-capabilities.md) — LOW-MEDIUM (reduces attack surface for untrusted codemods)
   - 10.2 [Review Third-Party Codemods Before Running](references/security-review-before-running-third-party.md) — LOW-MEDIUM (prevents malicious code execution from untrusted sources)
   - 10.3 [Validate External Inputs Before Use](references/security-validate-external-inputs.md) — LOW-MEDIUM (prevents injection attacks from malicious input)
11. [Package Structure](references/_sections.md#11-package-structure) — **LOW**
   - 11.1 [Organize Package by Convention](references/pkg-organize-by-convention.md) — LOW (enables tooling support and contributor onboarding)
   - 11.2 [Use Semantic Versioning for Packages](references/pkg-use-semantic-versioning.md) — LOW (enables safe dependency management and updates)
   - 11.3 [Write Descriptive Package Metadata](references/pkg-write-descriptive-metadata.md) — LOW (3-5x better search ranking in registry)

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