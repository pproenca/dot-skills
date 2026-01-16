---
name: typescript-best-practices
description: TypeScript performance and type system optimization guidelines. This skill should be used when writing, reviewing, or refactoring TypeScript code to ensure optimal compilation performance and runtime efficiency. Triggers on tasks involving TypeScript configuration, type definitions, async patterns, module organization, or performance improvements.
---

# TypeScript Best Practices

Comprehensive performance optimization guide for TypeScript applications. Contains 42 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Configuring tsconfig.json for a new or existing project
- Writing complex type definitions or generics
- Optimizing async/await patterns and data fetching
- Organizing modules and managing imports
- Reviewing code for compilation or runtime performance

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Type System Performance | CRITICAL | `type-` |
| 2 | Compiler Configuration | CRITICAL | `config-` |
| 3 | Async Patterns | HIGH | `async-` |
| 4 | Module Organization | HIGH | `module-` |
| 5 | Type Safety Patterns | MEDIUM-HIGH | `safety-` |
| 6 | Memory Management | MEDIUM | `mem-` |
| 7 | Runtime Optimization | LOW-MEDIUM | `runtime-` |
| 8 | Advanced Patterns | LOW | `advanced-` |

## Quick Reference

### 1. Type System Performance (CRITICAL)

- `type-interfaces-over-intersections` - Prefer interfaces over type intersections for faster resolution
- `type-avoid-large-unions` - Avoid unions with 12+ members (O(n²) checking)
- `type-extract-conditional-types` - Extract conditional types to enable caching
- `type-limit-recursion-depth` - Add depth limits to recursive types
- `type-explicit-return-types` - Add explicit return types to exported functions
- `type-avoid-deep-generics` - Flatten deeply nested generic hierarchies
- `type-simplify-mapped-types` - Break complex mapped types into smaller utilities

### 2. Compiler Configuration (CRITICAL)

- `config-enable-incremental` - Enable incremental compilation for 50-90% faster rebuilds
- `config-skip-lib-check` - Skip declaration file checking for 20-40% faster builds
- `config-isolate-modules` - Enable single-file transpilation for bundler integration
- `config-project-references` - Split large codebases into independent projects
- `config-exclude-properly` - Configure include/exclude to avoid scanning unnecessary files
- `config-strict-function-types` - Enable strict mode for optimized variance checks

### 3. Async Patterns (HIGH)

- `async-parallel-promises` - Use Promise.all() for independent operations
- `async-defer-await` - Defer await until value is actually needed
- `async-avoid-loop-await` - Avoid await inside loops, use Promise.all with map
- `async-explicit-return-types` - Annotate async function return types
- `async-avoid-unnecessary-async` - Skip async wrapper when just returning a Promise

### 4. Module Organization (HIGH)

- `module-avoid-barrel-imports` - Import directly from source, not barrel files
- `module-avoid-circular-dependencies` - Extract shared types to break cycles
- `module-use-type-imports` - Use type-only imports for types
- `module-dynamic-imports` - Use dynamic import() for large modules
- `module-control-types-inclusion` - Explicitly list @types packages

### 5. Type Safety Patterns (MEDIUM-HIGH)

- `safety-prefer-unknown-over-any` - Use unknown instead of any for safer handling
- `safety-use-type-guards` - Use type guards for runtime type checking
- `safety-exhaustive-checks` - Use never for exhaustive union handling
- `safety-strict-null-checks` - Enable strictNullChecks for null safety
- `safety-const-assertions` - Use as const for literal type preservation
- `safety-assertion-functions` - Use assertion functions for validation

### 6. Memory Management (MEDIUM)

- `mem-use-weakmap-for-metadata` - Use WeakMap for object metadata
- `mem-avoid-closure-leaks` - Extract only needed data in closures
- `mem-cleanup-event-listeners` - Remove event listeners on cleanup
- `mem-avoid-global-state` - Use bounded caches, avoid unbounded globals
- `mem-clear-timers` - Clear intervals and timeouts when done

### 7. Runtime Optimization (LOW-MEDIUM)

- `runtime-use-set-for-lookups` - Use Set/Map for O(1) lookups
- `runtime-cache-property-access` - Cache property access in loops
- `runtime-avoid-object-spread-in-loops` - Avoid spreading objects in hot loops
- `runtime-use-for-of-for-iteration` - Use for-of for clean array iteration
- `runtime-prefer-array-methods` - Prefer native array methods over lodash
- `runtime-use-string-methods` - Use modern string methods (startsWith, includes)

### 8. Advanced Patterns (LOW)

- `advanced-branded-types` - Use branded types for type-safe IDs
- `advanced-template-literal-types` - Use template literals for string patterns
- `advanced-satisfies-operator` - Use satisfies for validation with inference

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/type-interfaces-over-intersections.md
rules/_sections.md
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
