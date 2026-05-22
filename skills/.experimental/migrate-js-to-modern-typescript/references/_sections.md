# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Migration Setup & tsconfig (setup)

**Impact:** CRITICAL  
**Description:** The entire migration strategy is chosen here — how JS and TS coexist, what order files convert in, and how the compiler resolves modules. A wrong tsconfig or a top-down conversion order forces you to re-type the same modules twice and cascades errors through every downstream file.

## 2. Strictness Ratcheting (strict)

**Impact:** CRITICAL  
**Description:** Strictness is the defining axis of "modern" TypeScript and the source of nearly all migration value. The order you enable strict flags determines whether you face an unbounded error flood or fixable batches; `strictNullChecks` alone catches the most common JS runtime crash.

## 3. Typing Public Surfaces (surface)

**Impact:** HIGH  
**Description:** Exported function signatures, class fields, and option objects are the contract every importer relies on. An untyped seam propagates `any` across the entire call graph, so typing the surfaces first restores inference everywhere downstream.

## 4. Replacing any & Unsafe Casts (unsafe)

**Impact:** HIGH  
**Description:** Auto-migration scatters implicit and explicit `any`, `as` casts, and `!` assertions used to silence errors. Each one disables checking and spreads silently; replacing them with `unknown` plus narrowing contains the damage at its source.

## 5. Runtime Data Validation (runtime)

**Impact:** MEDIUM-HIGH  
**Description:** External data — JSON, env vars, API responses, untyped library returns — is `any` at runtime no matter what the annotation claims. Validating at the boundary is the only way the type you wrote is actually true when the program runs.

## 6. JS-to-TS Idiom Conversion (idiom)

**Impact:** MEDIUM  
**Description:** CommonJS `require`, prototype constructors, the `arguments` object, and frozen-object enums are JS idioms TypeScript cannot type coherently. Converting them to ESM, classes, rest parameters, and `as const` unlocks inference and static analysis.

## 7. Tooling & Build Migration (tooling)

**Impact:** LOW-MEDIUM  
**Description:** The build chain must learn to run, type-check, and publish TypeScript. Ambient declarations, `@types` packages, a direct runner, declaration emit, and a dedicated type-check CI step keep the types you added enforced and available to consumers.
