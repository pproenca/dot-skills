# JavaScript

**Version 0.1.0**  
Google  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive JavaScript style and best practices guide based on Google's official JavaScript Style Guide, designed for AI agents and LLMs. Contains 47 rules across 8 categories, prioritized by impact from critical (module system, language features) to incremental (formatting). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Module System & Imports](references/_sections.md#1-module-system-&-imports) — **CRITICAL**
   - 1.1 [Avoid Circular Dependencies](references/module-avoid-circular-dependencies.md) — CRITICAL (prevents loading failures and undefined imports)
   - 1.2 [Avoid Duplicate Import Statements](references/module-no-duplicate-imports.md) — HIGH (reduces confusion and bundle overhead)
   - 1.3 [Avoid Unnecessary Import Aliasing](references/module-no-import-aliasing.md) — HIGH (maintains searchability and code comprehension)
   - 1.4 [Follow Source File Structure Order](references/module-source-file-structure.md) — HIGH (improves navigability and prevents declaration errors)
   - 1.5 [Include File Extension in Import Paths](references/module-file-extension-in-imports.md) — CRITICAL (prevents module resolution failures)
   - 1.6 [Prefer Named Exports Over Default Exports](references/module-named-exports-over-default.md) — CRITICAL (enables better refactoring and prevents import inconsistencies)
2. [Language Features](references/_sections.md#2-language-features) — **CRITICAL**
   - 2.1 [Always Use Explicit Semicolons](references/lang-explicit-semicolons.md) — HIGH (prevents ASI-related parsing errors)
   - 2.2 [Never Modify Built-in Prototypes](references/lang-no-modify-builtins.md) — CRITICAL (prevents global conflicts and breaking changes)
   - 2.3 [Never Use eval or Function Constructor](references/lang-no-eval.md) — CRITICAL (prevents code injection and CSP violations)
   - 2.4 [Never Use Primitive Wrapper Objects](references/lang-no-primitive-wrappers.md) — CRITICAL (prevents type confusion and equality bugs)
   - 2.5 [Never Use the with Statement](references/lang-no-with-statement.md) — CRITICAL (prevents scope ambiguity and strict mode errors)
   - 2.6 [Use const by Default, let When Needed, Never var](references/lang-const-over-let-over-var.md) — CRITICAL (prevents reassignment bugs and enables optimization)
   - 2.7 [Use ES6 Classes Over Prototype Manipulation](references/lang-es6-classes-over-prototypes.md) — HIGH (improves readability and enables tooling support)
   - 2.8 [Use Only Standard ECMAScript Features](references/lang-no-non-standard-features.md) — HIGH (prevents runtime errors on 100% of non-supporting platforms)
3. [Type Safety & JSDoc](references/_sections.md#3-type-safety-&-jsdoc) — **HIGH**
   - 3.1 [Always Specify Template Parameters](references/type-template-parameters.md) — HIGH (improves type inference and prevents any-type degradation)
   - 3.2 [Annotate Enums with Static Literal Values](references/type-enum-annotations.md) — MEDIUM (enables compiler optimization and type checking)
   - 3.3 [Require JSDoc for All Exported Functions](references/type-jsdoc-required-for-exports.md) — HIGH (enables IDE support and compiler type checking)
   - 3.4 [Use Explicit Nullability Modifiers](references/type-explicit-nullability.md) — HIGH (prevents null reference errors)
   - 3.5 [Use Parentheses for Type Casts](references/type-cast-with-parentheses.md) — MEDIUM (prevents Closure Compiler type errors)
   - 3.6 [Use typedef for Complex Object Types](references/type-typedef-for-complex-types.md) — MEDIUM-HIGH (enables reusable type definitions across files)
4. [Naming Conventions](references/_sections.md#4-naming-conventions) — **HIGH**
   - 4.1 [Avoid Dollar Sign Prefix in Identifiers](references/naming-no-dollar-prefix.md) — MEDIUM (prevents confusion with framework conventions)
   - 4.2 [Prefer Descriptive Names Over Brevity](references/naming-descriptive-over-brief.md) — HIGH (significantly improves code comprehension)
   - 4.3 [Use CONSTANT_CASE for Deeply Immutable Values](references/naming-constant-case-for-constants.md) — HIGH (signals immutability and prevents accidental modification)
   - 4.4 [Use lowerCamelCase for Methods and Variables](references/naming-lowercamelcase-for-methods.md) — HIGH (maintains consistency and enables code search)
   - 4.5 [Use Lowercase with Dashes or Underscores for Files](references/naming-file-naming-conventions.md) — MEDIUM (prevents import resolution failures across platforms)
   - 4.6 [Use UpperCamelCase for Classes and Constructors](references/naming-uppercamelcase-for-classes.md) — HIGH (prevents new keyword misuse on non-constructors)
5. [Control Flow & Error Handling](references/_sections.md#5-control-flow-&-error-handling) — **MEDIUM-HIGH**
   - 5.1 [Always Include Default Case in Switch Statements](references/control-switch-default-last.md) — MEDIUM-HIGH (prevents silent failures on unexpected values)
   - 5.2 [Always Throw Error Objects, Not Primitives](references/control-throw-error-objects.md) — MEDIUM-HIGH (preserves stack traces for debugging)
   - 5.3 [Document Empty Catch Blocks](references/control-comment-empty-catch.md) — MEDIUM (prevents silent failure masking)
   - 5.4 [Prefer for-of Over for-in for Iteration](references/control-for-of-over-for-in.md) — MEDIUM (prevents prototype property bugs)
   - 5.5 [Use Strict Equality Except for Null Checks](references/control-strict-equality.md) — MEDIUM-HIGH (prevents type coercion bugs)
6. [Functions & Parameters](references/_sections.md#6-functions-&-parameters) — **MEDIUM**
   - 6.1 [Always Use Parentheses Around Arrow Function Parameters](references/func-arrow-parentheses.md) — LOW-MEDIUM (prevents errors when adding parameters)
   - 6.2 [Prefer Arrow Functions for Nested Functions](references/func-arrow-functions-for-nested.md) — MEDIUM (simplifies this binding and reduces boilerplate)
   - 6.3 [Use Default Parameters Instead of Conditional Assignment](references/func-default-parameters.md) — MEDIUM (clearer API and prevents falsy value bugs)
   - 6.4 [Use Rest Parameters Instead of arguments Object](references/func-rest-parameters-over-arguments.md) — MEDIUM (eliminates Array.prototype.slice.call boilerplate)
   - 6.5 [Use Spread Operator Instead of Function.apply](references/func-spread-over-apply.md) — MEDIUM (cleaner syntax, works with new operator)
7. [Objects & Arrays](references/_sections.md#7-objects-&-arrays) — **MEDIUM**
   - 7.1 [Never Mix Quoted and Unquoted Object Keys](references/data-no-mixing-quoted-unquoted-keys.md) — MEDIUM (prevents compiler optimization issues)
   - 7.2 [Use Array Literals Instead of Array Constructor](references/data-array-literals-over-constructor.md) — MEDIUM (avoids single-argument ambiguity)
   - 7.3 [Use Destructuring for Multiple Property Access](references/data-destructuring-for-multiple-values.md) — MEDIUM (reduces repetition and improves clarity)
   - 7.4 [Use Object Literals Instead of Object Constructor](references/data-object-literals-over-constructor.md) — MEDIUM (clearer syntax and avoids edge cases)
   - 7.5 [Use Spread Over concat and slice](references/data-spread-over-concat-slice.md) — LOW-MEDIUM (reduces array operation boilerplate by 50%)
   - 7.6 [Use Trailing Commas in Multi-line Literals](references/data-trailing-commas.md) — MEDIUM (reduces git diff noise by 50% on additions)
8. [Formatting & Style](references/_sections.md#8-formatting-&-style) — **LOW**
   - 8.1 [Always Use Braces for Control Structures](references/format-braces-required.md) — LOW (prevents bugs when adding statements)
   - 8.2 [Limit Lines to 80 Characters](references/format-column-limit.md) — LOW (prevents horizontal scrolling in 80-column terminals)
   - 8.3 [Place One Statement Per Line](references/format-one-statement-per-line.md) — LOW (reduces debugging time by 2-3× with clear breakpoints)
   - 8.4 [Use Single Quotes for String Literals](references/format-single-quotes.md) — LOW (maintains consistency across codebase)
   - 8.5 [Use Two-Space Indentation](references/format-two-space-indent.md) — LOW (maintains consistent code appearance)

---

## References

1. [https://google.github.io/styleguide/jsguide.html](https://google.github.io/styleguide/jsguide.html)
2. [https://tc39.es/ecma262/](https://tc39.es/ecma262/)
3. [https://developer.mozilla.org/en-US/docs/Web/JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |