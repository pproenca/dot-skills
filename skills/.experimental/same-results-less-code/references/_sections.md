# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

These categories deliberately skip what linters and tools like `knip`, `eslint`,
`ruff`, `tsc --noUnusedLocals`, or formatters already catch. The focus is on
the parts of code volume that come from **judgment and modeling gaps** — the
things a senior engineer notices at review that no static analyser does.

---

## 1. Reinvention (reinvent)

**Impact:** CRITICAL  
**Description:** Code written to do what the platform, language, or a one-line stdlib call already does. Each instance is dozens of lines that could be one, and each one cascades into needing its own tests, naming, edge cases, and review attention.

## 2. Wrong Frame (frame)

**Impact:** CRITICAL  
**Description:** The wrong abstraction shape for the problem — a class where a function fits, a "Manager"/"Helper" noun hiding a verb, inheritance where composition fits, an interface with one implementer. Choosing the wrong frame multiplies every later decision against it.

## 3. Hidden Duplication (dup)

**Impact:** HIGH  
**Description:** Semantically identical code wearing different names — parallel types with relabeled fields, near-twin functions that differ by one literal, mirrored if/else branches. Linters see distinct tokens; the duplication lives at the meaning level.

## 4. Derived State Stored (derive)

**Impact:** HIGH  
**Description:** State variables, cached fields, or props that hold values which can be computed from other state. Every such field is a sync bug waiting to happen and an extra invariant to maintain across all writes.

## 5. Procedural Rebuilds (proc)

**Impact:** MEDIUM-HIGH  
**Description:** Imperative reimplementation of a declarative concept — for-loops building arrays that are `.map()`, if/elif chains that are lookup tables, hand-coded recursion of standard tree walks. The volume comes from operating at the wrong level of abstraction.

## 6. Speculative Generality (spec)

**Impact:** MEDIUM  
**Description:** Generality built for a second user who never arrived — an interface with one implementer, an options bag with one option, a flag that splits a function into two unrelated paths, a generic over one concrete type. Each speculation pays a permanent tax.

## 7. Defensive Excess (defense)

**Impact:** MEDIUM  
**Description:** Runtime checks for states the type system or surrounding control flow already rules out — `if (x === true)` for known booleans, null checks after non-null narrowing, try/catch around code that cannot throw, default branches in exhaustive unions.

## 8. Type System Underuse (types)

**Impact:** LOW-MEDIUM  
**Description:** Stringly-typed values where a small enum or literal union fits, runtime tag fields where a discriminated union does it for free, casts and `any` used to silence a problem that the type system could solve. Code volume grows to compensate for types the engineer didn't reach for.
