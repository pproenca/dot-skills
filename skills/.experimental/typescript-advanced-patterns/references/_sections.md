# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Library Author / DSL Patterns (dsl)

**Impact:** CRITICAL  
**Description:** Public API surface design is the highest-leverage place to spend type-level effort — every consumer pays for mistakes here. Fluent builders, schema-first inference, route parsers, and overload design cascade to autocomplete quality for thousands of call sites.

## 2. Type-level Programming (tlp)

**Impact:** HIGH  
**Description:** The compositional toolkit for everything in this skill. Recursive conditionals, accumulator-pattern recursion, key remapping, variadic tuples, and type-level testing are the building blocks for DSLs and inference machinery. Without them, the advanced patterns in other categories cannot be built or verified.

## 3. Modern Features at Depth (mod)

**Impact:** HIGH  
**Description:** TypeScript 5.x added features that unlock new patterns — Stage 3 decorators, `using` / `await using`, `const` type parameters, `NoInfer`, variance annotations. The pitfalls only surface in real overload-heavy, capability-tracking, or disposal-composition scenarios. Surface usage is covered elsewhere; this category goes to the edge cases.

## 4. Feature Implementation Patterns (impl)

**Impact:** MEDIUM-HIGH  
**Description:** Applying advanced types when building features — tagged results, state-machine modeling with discriminated unions, type-safe API clients, form builders, typed config loaders. Bridges library-author primitives with everyday application code so app developers can adopt advanced types without writing the primitives themselves.

## 5. Declaration & Module System (decl)

**Impact:** MEDIUM  
**Description:** Module augmentation, declaration merging, ambient declarations, and modern library type publishing (`exports` map, `typesVersions`). Niche but irreplaceable: when you need them, no other technique works, and getting them wrong silently breaks consumers across module systems.
