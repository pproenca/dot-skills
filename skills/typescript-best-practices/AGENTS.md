# TypeScript

**Version 0.1.1**  
TypeScript Best Practices  
January 2026

> **Note:**
> This TypeScript guide is for agents and LLMs to follow when maintaining,
> generating, or refactoring codebases. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for TypeScript applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (type system performance, compiler configuration) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Type System Performance](#1-type-system-performance) — **CRITICAL**
   - 1.1 [Add Explicit Return Types to Exported Functions](#11-add-explicit-return-types-to-exported-functions)
   - 1.2 [Avoid Deeply Nested Generic Types](#12-avoid-deeply-nested-generic-types)
   - 1.3 [Avoid Large Union Types](#13-avoid-large-union-types)
   - 1.4 [Extract Conditional Types to Named Aliases](#14-extract-conditional-types-to-named-aliases)
   - 1.5 [Limit Type Recursion Depth](#15-limit-type-recursion-depth)
   - 1.6 [Prefer Interfaces Over Type Intersections](#16-prefer-interfaces-over-type-intersections)
   - 1.7 [Simplify Complex Mapped Types](#17-simplify-complex-mapped-types)
2. [Compiler Configuration](#2-compiler-configuration) — **CRITICAL**
   - 2.1 [Configure Include and Exclude Properly](#21-configure-include-and-exclude-properly)
   - 2.2 [Enable Incremental Compilation](#22-enable-incremental-compilation)
   - 2.3 [Enable skipLibCheck for Faster Builds](#23-enable-skiplibcheck-for-faster-builds)
   - 2.4 [Enable strictFunctionTypes for Faster Variance Checks](#24-enable-strictfunctiontypes-for-faster-variance-checks)
   - 2.5 [Use isolatedModules for Single-File Transpilation](#25-use-isolatedmodules-for-single-file-transpilation)
   - 2.6 [Use Project References for Large Codebases](#26-use-project-references-for-large-codebases)
3. [Async Patterns](#3-async-patterns) — **HIGH**
   - 3.1 [Annotate Async Function Return Types](#31-annotate-async-function-return-types)
   - 3.2 [Avoid await Inside Loops](#32-avoid-await-inside-loops)
   - 3.3 [Avoid Unnecessary async/await](#33-avoid-unnecessary-asyncawait)
   - 3.4 [Defer await Until Value Is Needed](#34-defer-await-until-value-is-needed)
   - 3.5 [Use Promise.all for Independent Operations](#35-use-promiseall-for-independent-operations)
4. [Module Organization](#4-module-organization) — **HIGH**
   - 4.1 [Avoid Barrel File Imports](#41-avoid-barrel-file-imports)
   - 4.2 [Avoid Circular Dependencies](#42-avoid-circular-dependencies)
   - 4.3 [Control @types Package Inclusion](#43-control-types-package-inclusion)
   - 4.4 [Use Dynamic Imports for Large Modules](#44-use-dynamic-imports-for-large-modules)
   - 4.5 [Use Type-Only Imports for Types](#45-use-type-only-imports-for-types)
5. [Type Safety Patterns](#5-type-safety-patterns) — **MEDIUM-HIGH**
   - 5.1 [Enable strictNullChecks](#51-enable-strictnullchecks)
   - 5.2 [Prefer unknown Over any](#52-prefer-unknown-over-any)
   - 5.3 [Use Assertion Functions for Validation](#53-use-assertion-functions-for-validation)
   - 5.4 [Use const Assertions for Literal Types](#54-use-const-assertions-for-literal-types)
   - 5.5 [Use Exhaustive Checks for Union Types](#55-use-exhaustive-checks-for-union-types)
   - 5.6 [Use Type Guards for Runtime Type Checking](#56-use-type-guards-for-runtime-type-checking)
6. [Memory Management](#6-memory-management) — **MEDIUM**
   - 6.1 [Avoid Closure Memory Leaks](#61-avoid-closure-memory-leaks)
   - 6.2 [Avoid Global State Accumulation](#62-avoid-global-state-accumulation)
   - 6.3 [Clean Up Event Listeners](#63-clean-up-event-listeners)
   - 6.4 [Clear Timers and Intervals](#64-clear-timers-and-intervals)
   - 6.5 [Use WeakMap for Object Metadata](#65-use-weakmap-for-object-metadata)
7. [Runtime Optimization](#7-runtime-optimization) — **LOW-MEDIUM**
   - 7.1 [Avoid Object Spread in Hot Loops](#71-avoid-object-spread-in-hot-loops)
   - 7.2 [Cache Property Access in Loops](#72-cache-property-access-in-loops)
   - 7.3 [Prefer Native Array Methods Over Lodash](#73-prefer-native-array-methods-over-lodash)
   - 7.4 [Use for-of for Simple Iteration](#74-use-for-of-for-simple-iteration)
   - 7.5 [Use Modern String Methods](#75-use-modern-string-methods)
   - 7.6 [Use Set/Map for O(1) Lookups](#76-use-setmap-for-o1-lookups)
8. [Advanced Patterns](#8-advanced-patterns) — **LOW**
   - 8.1 [Use Branded Types for Type-Safe IDs](#81-use-branded-types-for-type-safe-ids)
   - 8.2 [Use satisfies for Type Validation with Inference](#82-use-satisfies-for-type-validation-with-inference)
   - 8.3 [Use Template Literal Types for String Patterns](#83-use-template-literal-types-for-string-patterns)

---

## 1. Type System Performance

**Impact: CRITICAL**

Complex types, deep generics, and large unions cause quadratic compilation time. Simplifying type definitions yields the largest compile-time gains.

### 1.1 Add Explicit Return Types to Exported Functions

**Impact: CRITICAL (30-50% faster declaration emit)**

Explicit return types accelerate compilation by eliminating inference overhead. Named types are more compact than inferred anonymous types, speeding up declaration file generation and consumption.

**Incorrect (inferred return type, slow declaration emit):**

```typescript
export function fetchUserProfile(userId: string) {
  // Compiler must analyze entire function body to infer return type
  return fetch(`/api/users/${userId}`)
    .then(res => res.json())
    .then(data => ({
      id: data.id as string,
      name: data.name as string,
      email: data.email as string,
      createdAt: new Date(data.created_at),
      permissions: data.permissions as Permission[],
    }))
}
// Inferred: Promise<{ id: string; name: string; email: string; createdAt: Date; permissions: Permission[] }>
```

**Correct (explicit return type, fast compilation):**

```typescript
interface UserProfile {
  id: string
  name: string
  email: string
  createdAt: Date
  permissions: Permission[]
}

export function fetchUserProfile(userId: string): Promise<UserProfile> {
  return fetch(`/api/users/${userId}`)
    .then(res => res.json())
    .then(data => ({
      id: data.id,
      name: data.name,
      email: data.email,
      createdAt: new Date(data.created_at),
      permissions: data.permissions,
    }))
}
```

**When to skip explicit return types:**
- Private/internal functions with simple returns
- Arrow functions in local scope
- Functions where the return type is obvious (e.g., `(): void`)

**Benefits:**
- Declaration files use named type instead of expanded inline type
- Faster incremental compilation when function body changes
- Better error messages pointing to return type mismatch

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#using-type-annotations)

### 1.2 Avoid Deeply Nested Generic Types

**Impact: CRITICAL (prevents exponential instantiation cost)**

Each layer of generic nesting multiplies type instantiation cost. Flatten generic hierarchies or use intermediate type aliases to reduce the combinatorial explosion of type checking.

**Incorrect (deeply nested generics):**

```typescript
type ApiResponse<T> = {
  data: T
  meta: ResponseMeta
}

type PaginatedResponse<T> = ApiResponse<{
  items: T[]
  pagination: PaginationInfo
}>

type CachedResponse<T> = PaginatedResponse<{
  value: T
  cachedAt: Date
}>

// Usage creates 4+ levels of nesting
function fetchUsers(): CachedResponse<User> { }
// Compiler must resolve: CachedResponse<User> → PaginatedResponse<...> → ApiResponse<...>
```

**Correct (flattened with composition):**

```typescript
interface PaginationInfo {
  page: number
  totalPages: number
}

interface CacheInfo {
  cachedAt: Date
}

interface PaginatedData<T> {
  items: T[]
  pagination: PaginationInfo
}

interface ApiResponse<T> {
  data: T
  meta: ResponseMeta
}

// Compose at usage site instead of nesting
type UserListResponse = ApiResponse<PaginatedData<User> & CacheInfo>

function fetchUsers(): UserListResponse { }
// Single-level generic instantiation
```

**Alternative (builder pattern for complex responses):**

```typescript
interface ResponseBuilder<T> {
  data: T
  meta: ResponseMeta
}

function withPagination<T>(items: T[], pagination: PaginationInfo): PaginatedData<T> {
  return { items, pagination }
}

function withCache<T>(value: T): T & CacheInfo {
  return { ...value, cachedAt: new Date() }
}
```

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance)

### 1.3 Avoid Large Union Types

**Impact: CRITICAL (quadratic O(n²) comparison cost)**

Union type checking is quadratic—TypeScript compares each union member pairwise. Unions with more than 12 elements cause measurable compilation slowdowns. Use discriminated unions or base types instead.

**Incorrect (large union, O(n²) checks):**

```typescript
type HttpStatus =
  | 100 | 101 | 102 | 103
  | 200 | 201 | 202 | 203 | 204 | 205 | 206
  | 300 | 301 | 302 | 303 | 304 | 307 | 308
  | 400 | 401 | 402 | 403 | 404 | 405 | 406 | 407 | 408 | 409 | 410
  | 500 | 501 | 502 | 503 | 504 | 505
// 35+ members = 1000+ pairwise comparisons

type EventType = 'click' | 'hover' | 'focus' | /* ...50 more events... */
```

**Correct (discriminated union with base interface):**

```typescript
interface HttpStatusBase {
  code: number
  category: 'info' | 'success' | 'redirect' | 'clientError' | 'serverError'
}

interface SuccessStatus extends HttpStatusBase {
  category: 'success'
  code: 200 | 201 | 202 | 203 | 204
}

interface ClientErrorStatus extends HttpStatusBase {
  category: 'clientError'
  code: 400 | 401 | 403 | 404
}

type HttpStatus = SuccessStatus | ClientErrorStatus // Small union of interfaces
```

**Alternative (branded number type):**

```typescript
type HttpStatusCode = number & { readonly brand: unique symbol }

function isValidStatus(code: number): code is HttpStatusCode {
  return code >= 100 && code < 600
}
```

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#preferring-base-types-over-unions)

### 1.4 Extract Conditional Types to Named Aliases

**Impact: CRITICAL (enables compiler caching, prevents re-evaluation)**

Inline conditional types are re-evaluated on every function call. Extracting them to named type aliases allows the compiler to cache results and reuse them across multiple call sites.

**Incorrect (inline conditional, re-evaluated each call):**

```typescript
function processResponse<T>(
  response: T
): T extends { data: infer D }
   ? D extends Array<infer Item>
     ? Item[]
     : D
   : never {
  // Compiler re-computes this complex conditional on every call
  return response.data
}

function getResult<T>(value: T): T extends Promise<infer R> ? R : T {
  // Re-evaluated for each getResult() usage
}
```

**Correct (extracted, cacheable):**

```typescript
type ExtractData<T> = T extends { data: infer D }
  ? D extends Array<infer Item>
    ? Item[]
    : D
  : never

function processResponse<T>(response: T): ExtractData<T> {
  // Compiler caches ExtractData<T> resolution
  return response.data
}

type Awaited<T> = T extends Promise<infer R> ? R : T

function getResult<T>(value: T): Awaited<T> {
  // Reuses cached Awaited<T> computation
}
```

**Benefits:**
- Type alias acts as a cache boundary
- Reduces duplicate computation across multiple call sites
- Improves IDE responsiveness for autocomplete

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#using-type-aliases)

### 1.5 Limit Type Recursion Depth

**Impact: CRITICAL (prevents exponential type expansion)**

Recursive types without depth limits can cause exponential type expansion, leading to compilation hangs or out-of-memory errors. Add explicit depth counters or use tail-recursive patterns.

**Incorrect (unbounded recursion):**

```typescript
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P]
}
// No depth limit - deeply nested objects cause exponential expansion

type JSONValue =
  | string
  | number
  | boolean
  | null
  | JSONValue[]
  | { [key: string]: JSONValue }
// Infinite recursion potential
```

**Correct (bounded recursion with depth counter):**

```typescript
type DeepPartial<T, Depth extends number[] = []> = Depth['length'] extends 5
  ? T  // Stop at depth 5
  : {
      [P in keyof T]?: T[P] extends object
        ? DeepPartial<T[P], [...Depth, 1]>
        : T[P]
    }

type JSONValue<Depth extends number[] = []> = Depth['length'] extends 10
  ? unknown
  : | string
    | number
    | boolean
    | null
    | JSONValue<[...Depth, 1]>[]
    | { [key: string]: JSONValue<[...Depth, 1]> }
```

**Alternative (use built-in utilities):**

```typescript
// For simple cases, prefer built-in Partial over custom DeepPartial
type Config = Partial<AppConfig>

// Use libraries like ts-toolbelt for complex recursive types
// They implement optimized depth-limited versions
```

**When unbounded recursion is acceptable:**
- Types with guaranteed shallow depth (max 2-3 levels)
- Internal types not exposed in public APIs

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance)

### 1.6 Prefer Interfaces Over Type Intersections

**Impact: CRITICAL (2-5× faster type resolution)**

Interfaces create a single flat object type that detects property conflicts at declaration. Intersections recursively merge properties on every use, forcing the compiler to recompute the combined type repeatedly.

**Incorrect (recursive intersection merging):**

```typescript
type UserWithPermissions = User & Permissions & AuditInfo
// Compiler merges all properties on every reference

type ExtendedOrder = Order & {
  metadata: OrderMetadata
} & Timestamps
// Each intersection adds another layer of computation
```

**Correct (single flat interface):**

```typescript
interface UserWithPermissions extends User, Permissions, AuditInfo {}
// Single flat type, computed once

interface ExtendedOrder extends Order, Timestamps {
  metadata: OrderMetadata
}
// Extends create efficient inheritance chain
```

**When to use intersections:**
- Combining function types or primitives (interfaces cannot extend these)
- Creating mapped or conditional types
- One-off type combinations not reused elsewhere

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#preferring-interfaces-over-intersections)

### 1.7 Simplify Complex Mapped Types

**Impact: CRITICAL (reduces type computation by 50-80%)**

Overly complex mapped types with multiple conditional branches slow compilation significantly. Break them into smaller, focused utility types and compose them.

**Incorrect (monolithic mapped type):**

```typescript
type ComplexTransform<T> = {
  [K in keyof T]: T[K] extends Function
    ? T[K]
    : T[K] extends Array<infer U>
      ? U extends object
        ? ComplexTransform<U>[]
        : T[K]
      : T[K] extends object
        ? T[K] extends Date
          ? string
          : ComplexTransform<T[K]>
        : T[K] extends number
          ? string
          : T[K]
}
// Multiple nested conditionals evaluated for every property
```

**Correct (composed utility types):**

```typescript
type TransformValue<T> = T extends Date
  ? string
  : T extends number
    ? string
    : T

type TransformObject<T> = {
  [K in keyof T]: TransformProperty<T[K]>
}

type TransformProperty<T> = T extends Function
  ? T
  : T extends Array<infer U>
    ? TransformArray<U>
    : T extends object
      ? TransformObject<T>
      : TransformValue<T>

type TransformArray<T> = T extends object
  ? TransformObject<T>[]
  : T[]

// Each utility is cached independently
type TransformedUser = TransformObject<User>
```

**Benefits:**
- Each small utility type is cached separately
- Easier to debug type errors
- More reusable across the codebase

**When complex mapped types are acceptable:**
- Internal utility types used in few places
- Types that genuinely require complex logic

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance)

---

## 2. Compiler Configuration

**Impact: CRITICAL**

Misconfigured tsconfig causes full rebuilds and unnecessary file scanning. Proper configuration reduces compile time by 50-80%.

### 2.1 Configure Include and Exclude Properly

**Impact: CRITICAL (prevents scanning thousands of unnecessary files)**

TypeScript walks through all included directories to discover files. Overly broad `include` patterns or missing `exclude` patterns force the compiler to scan irrelevant directories, significantly slowing startup.

**Incorrect (scans entire project tree):**

```json
{
  "compilerOptions": {
    "outDir": "dist"
  },
  "include": ["**/*"]
}
```

```bash
# Scans node_modules, dist, coverage, .git...
# Discovery time: 5+ seconds on large projects
```

**Correct (targeted include with explicit exclude):**

```json
{
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src/**/*"],
  "exclude": [
    "node_modules",
    "dist",
    "coverage",
    "**/*.test.ts",
    "**/*.spec.ts",
    "**/__tests__/**"
  ]
}
```

```bash
# Only scans src/ directory
# Discovery time: <1 second
```

**For separate test configuration:**

```json
// tsconfig.json (production)
{
  "include": ["src/**/*"],
  "exclude": ["**/*.test.ts"]
}

// tsconfig.test.json
{
  "extends": "./tsconfig.json",
  "include": ["src/**/*", "tests/**/*"]
}
```

**Diagnostic commands:**

```bash
# List all files TypeScript will compile
tsc --listFiles

# Explain why each file was included
tsc --explainFiles
```

**Common files to exclude:**
- `node_modules` (always)
- Build output directories (`dist`, `build`, `out`)
- Test files for production builds
- Generated files (`.generated.ts`)
- Coverage reports (`coverage`)

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#configuring-tsconfigjson-or-jsconfigjson)

### 2.2 Enable Incremental Compilation

**Impact: CRITICAL (50-90% faster rebuilds)**

Incremental compilation caches project graph information between builds in a `.tsbuildinfo` file. Subsequent compilations only recheck changed files and their dependents.

**Incorrect (full rebuild every time):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "strict": true
  }
}
```

```bash
tsc  # 15 seconds every build
```

**Correct (incremental builds):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "strict": true,
    "incremental": true,
    "tsBuildInfoFile": "./dist/.tsbuildinfo"
  }
}
```

```bash
tsc  # 15s first build, 1-3s subsequent builds
```

**For monorepos (composite projects):**

```json
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "declarationMap": true
  },
  "references": [
    { "path": "../shared" },
    { "path": "../utils" }
  ]
}
```

**Note:** The `composite` flag implies `incremental: true` and requires `declaration: true`.

**When to disable incremental:**
- CI environments where cache isn't preserved between runs
- One-off type-checking scripts

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#incremental-project-emit)

### 2.3 Enable skipLibCheck for Faster Builds

**Impact: CRITICAL (20-40% faster compilation)**

The `skipLibCheck` option skips type-checking of declaration files (`.d.ts`). Since these files are pre-verified by library authors, checking them is redundant and wastes compilation time.

**Incorrect (checks all declaration files):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "strict": true
  }
}
```

```bash
# Checks thousands of .d.ts files in node_modules
# Compilation time: 25 seconds
```

**Correct (skips declaration file checks):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "strict": true,
    "skipLibCheck": true
  }
}
```

```bash
# Only checks your source files
# Compilation time: 15 seconds (40% faster)
```

**Alternative (more conservative):**

```json
{
  "compilerOptions": {
    "skipDefaultLibCheck": true
  }
}
```

This only skips checking the default library files (lib.d.ts), not third-party declarations.

**When to disable skipLibCheck:**
- Debugging type conflicts between declaration files
- Publishing a library where you want to verify `.d.ts` output
- Encountering mysterious type errors that might originate in declarations

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#skipping-d-ts-checking)

### 2.4 Enable strictFunctionTypes for Faster Variance Checks

**Impact: CRITICAL (enables optimized variance checking)**

With `strictFunctionTypes` enabled, TypeScript uses fast variance-based checking for function parameters. Without it, TypeScript falls back to slower structural comparison for every function type.

**Incorrect (slow structural checking):**

```json
{
  "compilerOptions": {
    "strict": false,
    "strictFunctionTypes": false
  }
}
```

```typescript
type Handler<T> = (event: T) => void

// Without strictFunctionTypes, TypeScript uses bidirectional
// (bivariant) checking - comparing structures both ways
const handler: Handler<MouseEvent> = (e: Event) => { }  // Allowed but unsafe
```

**Correct (fast variance checking):**

```json
{
  "compilerOptions": {
    "strict": true
  }
}
```

```typescript
type Handler<T> = (event: T) => void

// With strictFunctionTypes, TypeScript uses contravariant
// checking for parameters - faster and type-safe
const handler: Handler<MouseEvent> = (e: Event) => { }  // Error: Event is not MouseEvent
```

**Note:** The `strict` flag enables `strictFunctionTypes` along with other strict options. Enable `strict` for all new projects.

**When bivariance is needed:**

```typescript
// Use method syntax for intentional bivariance
interface EventEmitter<T> {
  emit(event: T): void  // Method syntax = bivariant
}

// vs property syntax for contravariance
interface StrictEmitter<T> {
  emit: (event: T) => void  // Property syntax = contravariant
}
```

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#controlling-types-inclusion)

### 2.5 Use isolatedModules for Single-File Transpilation

**Impact: CRITICAL (80-90% faster transpilation with bundlers)**

The `isolatedModules` flag ensures each file can be transpiled independently, enabling parallel transpilation by bundlers like esbuild, swc, or Babel. This bypasses TypeScript's slower multi-file analysis.

**Incorrect (requires cross-file analysis):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext"
  }
}
```

```typescript
// constants.ts
export const enum Status {
  Active = 'active',
  Inactive = 'inactive'
}

// user.ts
import { Status } from './constants'
const status = Status.Active  // Requires reading constants.ts to inline
```

**Correct (single-file transpilable):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "isolatedModules": true,
    "verbatimModuleSyntax": true
  }
}
```

```typescript
// constants.ts
export enum Status {  // Regular enum, not const enum
  Active = 'active',
  Inactive = 'inactive'
}

// user.ts
import { Status } from './constants'
const status = Status.Active  // Reference preserved, no cross-file read
```

**Build pipeline integration:**

```javascript
// vite.config.ts
export default {
  esbuild: {
    // esbuild transpiles files in parallel
    // TypeScript only runs type-checking
  }
}
```

**Code patterns blocked by isolatedModules:**
- `const enum` (use regular `enum` instead)
- `export =` / `import =` syntax
- Re-exporting types without `type` keyword

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#isolated-file-emit)

### 2.6 Use Project References for Large Codebases

**Impact: CRITICAL (60-80% faster incremental builds)**

Project references split a codebase into independent compilation units. Each project compiles separately, enabling parallel builds and preventing the compiler from loading the entire codebase at once.

**Incorrect (monolithic tsconfig):**

```text
my-app/
├── tsconfig.json        # Single config for entire app
├── packages/
│   ├── api/src/
│   ├── web/src/
│   └── shared/src/
```

```json
{
  "compilerOptions": { "outDir": "dist" },
  "include": ["packages/*/src/**/*"]
}
```

```bash
# Loads ALL files into memory for every change
# Change in api/ triggers full recompile
```

**Correct (project references):**

```text
my-app/
├── tsconfig.json              # Root config with references
├── packages/
│   ├── api/
│   │   └── tsconfig.json      # References shared
│   ├── web/
│   │   └── tsconfig.json      # References shared
│   └── shared/
│       └── tsconfig.json      # No references (leaf)
```

```json
// packages/shared/tsconfig.json
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "outDir": "dist"
  },
  "include": ["src/**/*"]
}
```

```json
// packages/api/tsconfig.json
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "outDir": "dist"
  },
  "references": [
    { "path": "../shared" }
  ],
  "include": ["src/**/*"]
}
```

```json
// tsconfig.json (root)
{
  "files": [],
  "references": [
    { "path": "packages/shared" },
    { "path": "packages/api" },
    { "path": "packages/web" }
  ]
}
```

```bash
tsc --build  # Builds only changed projects
```

**Benefits:**
- Parallel compilation of independent projects
- Change in `shared/` only rebuilds dependents
- Declaration files used as API boundaries

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#using-project-references)

---

## 3. Async Patterns

**Impact: HIGH**

Sequential awaits create runtime waterfalls. Parallelizing async operations yields 2-10× improvement in I/O-bound code.

### 3.1 Annotate Async Function Return Types

**Impact: HIGH (prevents runtime errors, improves inference)**

Explicit return types on async functions catch mismatches at the function boundary rather than at call sites. They also improve IDE performance by avoiding full function body inference.

**Incorrect (inferred Promise type):**

```typescript
async function fetchUserOrders(userId: string) {
  const response = await fetch(`/api/users/${userId}/orders`)
  if (!response.ok) {
    return null  // Implicit: Promise<Order[] | null>
  }
  return response.json()  // Implicit: Promise<any>
}

// Caller has unclear type: Promise<any>
const orders = await fetchUserOrders('123')
orders.map(o => o.id)  // No type error even if orders is null
```

**Correct (explicit Promise type):**

```typescript
interface Order {
  id: string
  total: number
  status: OrderStatus
}

async function fetchUserOrders(userId: string): Promise<Order[] | null> {
  const response = await fetch(`/api/users/${userId}/orders`)
  if (!response.ok) {
    return null
  }
  return response.json() as Promise<Order[]>
}

// Caller knows the exact type
const orders = await fetchUserOrders('123')
if (orders) {
  orders.map(o => o.id)  // Type-safe access
}
```

**For functions that might throw:**

```typescript
type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E }

async function fetchUserOrders(userId: string): Promise<Result<Order[]>> {
  try {
    const response = await fetch(`/api/users/${userId}/orders`)
    if (!response.ok) {
      return { ok: false, error: new Error(`HTTP ${response.status}`) }
    }
    const orders = await response.json() as Order[]
    return { ok: true, value: orders }
  } catch (error) {
    return { ok: false, error: error as Error }
  }
}
```

**Benefits:**
- Errors caught at function definition, not call sites
- Better IDE autocomplete for consumers
- Self-documenting API contracts

Reference: [TypeScript Handbook - Async Functions](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-1-7.html)

### 3.2 Avoid await Inside Loops

**Impact: HIGH (N× faster for N iterations, 10 users = 10× improvement)**

Using `await` inside a loop creates N sequential operations. Collect promises and await them together, or use `Promise.all()` with `map()` for parallel execution.

**Incorrect (N sequential requests):**

```typescript
async function enrichUsers(userIds: string[]): Promise<EnrichedUser[]> {
  const enrichedUsers: EnrichedUser[] = []

  for (const userId of userIds) {
    const user = await fetchUser(userId)  // Waits for each request
    const profile = await fetchProfile(userId)
    enrichedUsers.push({ ...user, profile })
  }
  // 10 users × 2 requests × 100ms = 2000ms

  return enrichedUsers
}
```

**Correct (parallel execution):**

```typescript
async function enrichUsers(userIds: string[]): Promise<EnrichedUser[]> {
  const enrichedUsers = await Promise.all(
    userIds.map(async (userId) => {
      const [user, profile] = await Promise.all([
        fetchUser(userId),
        fetchProfile(userId),
      ])
      return { ...user, profile }
    })
  )
  // 10 users processed in parallel = 100ms total

  return enrichedUsers
}
```

**For rate-limited APIs (chunked batching):**

```typescript
async function enrichUsers(userIds: string[]): Promise<EnrichedUser[]> {
  const BATCH_SIZE = 5
  const results: EnrichedUser[] = []

  for (let i = 0; i < userIds.length; i += BATCH_SIZE) {
    const batch = userIds.slice(i, i + BATCH_SIZE)
    const batchResults = await Promise.all(
      batch.map(async (userId) => {
        const [user, profile] = await Promise.all([
          fetchUser(userId),
          fetchProfile(userId),
        ])
        return { ...user, profile }
      })
    )
    results.push(...batchResults)
  }

  return results
}
```

**When sequential loop await is acceptable:**
- Each iteration depends on the previous result
- API strictly requires sequential calls
- Processing order affects correctness

Reference: [ESLint no-await-in-loop](https://eslint.org/docs/rules/no-await-in-loop)

### 3.3 Avoid Unnecessary async/await

**Impact: HIGH (eliminates microtask queue overhead)**

Every `async` function wraps its return in a Promise, and every `await` schedules a microtask. For functions that just return a Promise, skip the wrapper.

**Incorrect (unnecessary Promise wrapping):**

```typescript
async function getUser(userId: string): Promise<User> {
  return await userRepository.findById(userId)
  // Creates extra Promise + microtask for no benefit
}

async function getUserName(userId: string): Promise<string> {
  const user = await getUser(userId)
  return user.name
  // Another unnecessary async wrapper
}

// Chain of 3 async functions = 3 extra microtasks
async function displayUserName(userId: string): Promise<void> {
  const name = await getUserName(userId)
  console.log(name)
}
```

**Correct (direct Promise return):**

```typescript
function getUser(userId: string): Promise<User> {
  return userRepository.findById(userId)
  // Returns Promise directly, no wrapping
}

function getUserName(userId: string): Promise<string> {
  return getUser(userId).then(user => user.name)
  // Single Promise chain
}

// Only use async where you need sequential await
async function displayUserName(userId: string): Promise<void> {
  const name = await getUserName(userId)
  console.log(name)
}
```

**When async/await IS needed:**
- Multiple sequential await statements
- Try/catch around await
- Conditional await logic
- Better readability for complex flows

**Note:** Modern V8 optimizes simple `return await` patterns, but the overhead still exists for function setup. The bigger win is avoiding async wrappers that don't need them.

Reference: [V8 Blog - Fast Async](https://v8.dev/blog/fast-async)

### 3.4 Defer await Until Value Is Needed

**Impact: HIGH (enables implicit parallelization)**

Start async operations immediately but defer `await` until the value is actually required. This allows work to proceed while promises resolve in the background.

**Incorrect (blocks immediately):**

```typescript
async function processOrder(orderId: string): Promise<OrderResult> {
  const order = await fetchOrder(orderId)  // Blocks here
  const inventory = await checkInventory(order.items)  // Must wait for order

  // Could have started inventory check earlier
  if (order.priority === 'express') {
    return processExpress(order, inventory)
  }
  return processStandard(order, inventory)
}
```

**Correct (deferred await):**

```typescript
async function processOrder(orderId: string): Promise<OrderResult> {
  const orderPromise = fetchOrder(orderId)  // Start immediately, don't await

  // Do other work while order fetches
  const config = loadProcessingConfig()

  const order = await orderPromise  // Now await when needed
  const inventory = await checkInventory(order.items)

  if (order.priority === 'express') {
    return processExpress(order, inventory)
  }
  return processStandard(order, inventory)
}
```

**Pattern for dependent-then-independent operations:**

```typescript
async function loadUserContent(userId: string): Promise<Content> {
  // Start user fetch (needed for dependent calls)
  const userPromise = fetchUser(userId)

  // Start independent operations immediately
  const settingsPromise = fetchGlobalSettings()
  const featuresPromise = fetchFeatureFlags()

  // Await user for dependent operations
  const user = await userPromise
  const ordersPromise = fetchOrders(user.id)
  const prefsPromise = fetchPreferences(user.id)

  // Await all remaining
  const [settings, features, orders, prefs] = await Promise.all([
    settingsPromise,
    featuresPromise,
    ordersPromise,
    prefsPromise,
  ])

  return { user, settings, features, orders, prefs }
}
```

Reference: [V8 Blog - Fast Async](https://v8.dev/blog/fast-async)

### 3.5 Use Promise.all for Independent Operations

**Impact: HIGH (2-10× improvement in I/O-bound code)**

Sequential `await` statements create request waterfalls—each operation waits for the previous one to complete. Use `Promise.all()` to execute independent async operations concurrently.

**Incorrect (sequential execution, N round trips):**

```typescript
async function loadDashboard(userId: string): Promise<Dashboard> {
  const user = await fetchUser(userId)           // 200ms
  const orders = await fetchOrders(userId)       // 300ms
  const notifications = await fetchNotifications(userId)  // 150ms
  // Total: 650ms (sequential)

  return { user, orders, notifications }
}
```

**Correct (parallel execution, wall-clock time = max latency):**

```typescript
async function loadDashboard(userId: string): Promise<Dashboard> {
  const [user, orders, notifications] = await Promise.all([
    fetchUser(userId),           // 200ms ─┐
    fetchOrders(userId),         // 300ms ─┼─ Run in parallel
    fetchNotifications(userId),  // 150ms ─┘
  ])
  // Total: 300ms (max of all operations)

  return { user, orders, notifications }
}
```

**For error handling with partial success:**

```typescript
async function loadDashboard(userId: string): Promise<Dashboard> {
  const results = await Promise.allSettled([
    fetchUser(userId),
    fetchOrders(userId),
    fetchNotifications(userId),
  ])

  return {
    user: results[0].status === 'fulfilled' ? results[0].value : null,
    orders: results[1].status === 'fulfilled' ? results[1].value : [],
    notifications: results[2].status === 'fulfilled' ? results[2].value : [],
  }
}
```

**When sequential is correct:**
- Operations have data dependencies (need result A to make request B)
- Rate limiting requires sequential requests
- Order of execution matters for side effects

Reference: [MDN Promise.all](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all)

---

## 4. Module Organization

**Impact: HIGH**

Barrel files and circular dependencies force excessive module loading. Direct imports reduce bundle size and improve tree-shaking.

### 4.1 Avoid Barrel File Imports

**Impact: HIGH (200-800ms import cost, 30-50% larger bundles)**

Barrel files (index.ts re-exports) defeat tree-shaking and force bundlers to load entire module graphs. Import directly from source files to enable proper dead-code elimination.

**Incorrect (imports entire module tree):**

```typescript
// utils/index.ts (barrel file)
export * from './string'
export * from './date'
export * from './validation'
export * from './crypto'  // Heavy, rarely used

// consumer.ts
import { formatDate } from '@/utils'
// Loads ALL utils modules, including crypto
// Bundle includes 50KB of unused code
```

**Correct (direct imports):**

```typescript
// consumer.ts
import { formatDate } from '@/utils/date'
// Loads only the date module
// Bundle includes only what's used
```

**For icon libraries (common barrel offender):**

```typescript
// Incorrect - loads all 1500+ icons
import { Check, X } from 'lucide-react'

// Correct - loads only 2 icons
import Check from 'lucide-react/dist/esm/icons/check'
import X from 'lucide-react/dist/esm/icons/x'
```

**Alternative (configure bundler optimization):**

```javascript
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: ['lucide-react', '@mui/material', 'lodash']
  }
}

// vite.config.ts
export default {
  optimizeDeps: {
    include: ['lucide-react']
  }
}
```

**When barrels are acceptable:**
- Internal modules with few exports (< 10)
- Package entry points for library consumers
- When bundler is configured to optimize them

Reference: [Vercel - How we optimized package imports](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)

### 4.2 Avoid Circular Dependencies

**Impact: HIGH (prevents runtime undefined errors and slow compilation)**

Circular dependencies cause undefined values at runtime (due to incomplete module initialization) and slow TypeScript compilation as the checker resolves cycles repeatedly.

**Incorrect (circular dependency):**

```typescript
// user.ts
import { Order } from './order'

export interface User {
  id: string
  orders: Order[]
}

export function createUser(): User { /* ... */ }

// order.ts
import { User } from './user'  // Circular!

export interface Order {
  id: string
  user: User
}

export function createOrder(user: User): Order {
  // 'createUser' might be undefined if order.ts loads first
}
```

**Correct (extract shared types):**

```typescript
// types.ts (no dependencies)
export interface User {
  id: string
  orders: Order[]
}

export interface Order {
  id: string
  user: User
}

// user.ts
import { User, Order } from './types'

export function createUser(): User { /* ... */ }

// order.ts
import { User, Order } from './types'

export function createOrder(user: User): Order { /* ... */ }
```

**Alternative (interface segregation):**

```typescript
// user-types.ts
export interface UserBase {
  id: string
  name: string
}

// order.ts
import { UserBase } from './user-types'

export interface Order {
  id: string
  user: UserBase  // Only needs base interface, not full User
}
```

**Detection tools:**

```bash
# Madge - visualize circular dependencies
npx madge --circular --extensions ts ./src

# ESLint plugin
npm install eslint-plugin-import
# Rule: import/no-cycle
```

Reference: [Node.js Cycles Documentation](https://nodejs.org/api/modules.html#cycles)

### 4.3 Control @types Package Inclusion

**Impact: HIGH (prevents type conflicts and reduces memory usage)**

By default, TypeScript loads all `@types/*` packages from `node_modules`. This causes conflicts between incompatible type versions and wastes memory loading unused declarations.

**Incorrect (loads all @types automatically):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext"
  }
}
```

```bash
# All @types/* packages loaded:
# @types/node, @types/react, @types/express, @types/lodash,
# @types/jest, @types/mocha (conflict!), @types/jasmine (conflict!)
```

**Correct (explicit types inclusion):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "types": ["node", "react", "jest"]
  }
}
```

```bash
# Only specified @types loaded
# No conflicts between test frameworks
```

**For different environments:**

```json
// tsconfig.json (base)
{
  "compilerOptions": {
    "types": []
  }
}

// tsconfig.node.json (Node.js scripts)
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "types": ["node"]
  }
}

// tsconfig.test.json (Jest tests)
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "types": ["node", "jest"]
  }
}
```

**Using typeRoots for custom declarations:**

```json
{
  "compilerOptions": {
    "typeRoots": [
      "./types",           // Custom declarations first
      "./node_modules/@types"  // Then @types
    ],
    "types": ["node"]
  }
}
```

**Benefits:**
- Prevents type conflicts between similar packages
- Reduces memory usage during compilation
- Faster IDE responsiveness

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance#controlling-types-inclusion)

### 4.4 Use Dynamic Imports for Large Modules

**Impact: HIGH (reduces initial bundle by 30-70%)**

Dynamic `import()` creates separate chunks that load on demand. Use them for large dependencies, route-specific code, and features that aren't needed immediately.

**Incorrect (static import, always loaded):**

```typescript
import { PDFGenerator } from 'pdfkit'  // 500KB
import { ExcelExporter } from 'exceljs'  // 800KB
import { ChartLibrary } from 'chart.js'  // 300KB

export async function exportReport(format: 'pdf' | 'excel' | 'chart') {
  if (format === 'pdf') {
    return new PDFGenerator().generate()
  }
  // All 1.6MB loaded even if user never exports
}
```

**Correct (dynamic import, loaded on demand):**

```typescript
export async function exportReport(format: 'pdf' | 'excel' | 'chart') {
  if (format === 'pdf') {
    const { PDFGenerator } = await import('pdfkit')
    return new PDFGenerator().generate()
  }

  if (format === 'excel') {
    const { ExcelExporter } = await import('exceljs')
    return new ExcelExporter().export()
  }

  const { ChartLibrary } = await import('chart.js')
  return new ChartLibrary().render()
}
// Only loads the module needed for the specific format
```

**With TypeScript typing:**

```typescript
async function loadPdfGenerator(): Promise<typeof import('pdfkit')> {
  return import('pdfkit')
}

// Or with type-only import for the interface
import type { PDFDocument } from 'pdfkit'

async function generatePdf(): Promise<PDFDocument> {
  const { default: PDFDocument } = await import('pdfkit')
  return new PDFDocument()
}
```

**Framework-specific patterns:**

```typescript
// Next.js
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false  // Skip server-side rendering
})

// React
const HeavyChart = React.lazy(() => import('@/components/HeavyChart'))
```

Reference: [MDN Dynamic Import](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import)

### 4.5 Use Type-Only Imports for Types

**Impact: HIGH (eliminates runtime imports for type information)**

Type-only imports (`import type`) are completely erased during compilation, preventing unnecessary runtime module loading. Regular imports of types can force module execution even when only the type is needed.

**Incorrect (runtime import for type-only usage):**

```typescript
// config.ts
import { DatabaseConfig } from './database'  // Loads entire database module
import { Logger } from './logger'  // Loads entire logger module

interface AppConfig {
  db: DatabaseConfig
  logger: Logger
}

// Runtime: database.js and logger.js are both loaded
// even though we only use their types
```

**Correct (type-only imports):**

```typescript
// config.ts
import type { DatabaseConfig } from './database'
import type { Logger } from './logger'

interface AppConfig {
  db: DatabaseConfig
  logger: Logger
}

// Runtime: no modules loaded, types are erased
```

**Mixed imports (types and values):**

```typescript
// Incorrect - unclear what's type vs value
import { User, createUser, UserRole } from './user'

// Correct - explicit separation
import { createUser } from './user'
import type { User, UserRole } from './user'

// Or inline type imports (TypeScript 4.5+)
import { createUser, type User, type UserRole } from './user'
```

**Enable enforcement:**

```json
// tsconfig.json
{
  "compilerOptions": {
    "verbatimModuleSyntax": true
  }
}

// .eslintrc
{
  "rules": {
    "@typescript-eslint/consistent-type-imports": "error"
  }
}
```

**Benefits:**
- Smaller bundles (unused modules not included)
- Faster cold starts (fewer modules to parse)
- Clearer code intent (types vs runtime values)

Reference: [TypeScript 3.8 Release Notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-8.html#type-only-imports-and-export)

---

## 5. Type Safety Patterns

**Impact: MEDIUM-HIGH**

Type guards, narrowing, and strict mode prevent runtime errors. Proper patterns eliminate defensive runtime checks.

### 5.1 Enable strictNullChecks

**Impact: MEDIUM-HIGH (prevents null/undefined runtime errors)**

With `strictNullChecks`, TypeScript distinguishes between `T`, `T | null`, and `T | undefined`. This catches null pointer exceptions at compile time instead of runtime.

**Incorrect (strictNullChecks disabled):**

```typescript
// tsconfig.json: { "strictNullChecks": false }

function getUser(id: string): User {
  return userMap.get(id)  // Returns User | undefined, but typed as User
}

const user = getUser('123')
console.log(user.email)  // No error, but crashes if user is undefined
```

**Correct (strictNullChecks enabled):**

```typescript
// tsconfig.json: { "strict": true } (includes strictNullChecks)

function getUser(id: string): User | undefined {
  return userMap.get(id)  // Correctly typed as User | undefined
}

const user = getUser('123')
console.log(user.email)  // Error: 'user' is possibly 'undefined'

// Must handle the undefined case
if (user) {
  console.log(user.email)  // Type narrowed to User
}

// Or use optional chaining
console.log(user?.email)  // string | undefined

// Or assert when you're certain
const confirmedUser = getUser('123')!  // Non-null assertion (use sparingly)
```

**Common patterns with strictNullChecks:**

```typescript
// Default values
function greet(name: string | undefined): string {
  return `Hello, ${name ?? 'Guest'}`
}

// Guard clauses
function processOrder(order: Order | null): void {
  if (!order) {
    throw new Error('Order is required')
  }
  // order is narrowed to Order
  ship(order)
}

// Optional chaining with nullish coalescing
const street = user?.address?.street ?? 'Unknown'
```

**Note:** Always enable `strict: true` which includes `strictNullChecks` along with other safety checks.

Reference: [TypeScript Handbook - Strict Null Checks](https://www.typescriptlang.org/tsconfig#strictNullChecks)

### 5.2 Prefer unknown Over any

**Impact: MEDIUM-HIGH (forces type narrowing, prevents runtime errors)**

The `any` type disables all type checking, allowing unsafe operations to pass silently. Use `unknown` to require explicit type narrowing before operations.

**Incorrect (any bypasses all checks):**

```typescript
function processApiResponse(data: any): string {
  return data.user.name.toUpperCase()
  // No error even if data is null, has no user, or name isn't a string
  // Runtime: TypeError: Cannot read property 'name' of undefined
}

async function fetchData(): Promise<any> {
  const response = await fetch('/api/data')
  return response.json()  // Returns Promise<any>, loses all type info
}
```

**Correct (unknown requires narrowing):**

```typescript
interface ApiResponse {
  user: {
    name: string
  }
}

function isApiResponse(data: unknown): data is ApiResponse {
  return (
    typeof data === 'object' &&
    data !== null &&
    'user' in data &&
    typeof (data as ApiResponse).user?.name === 'string'
  )
}

function processApiResponse(data: unknown): string {
  if (!isApiResponse(data)) {
    throw new Error('Invalid API response')
  }
  return data.user.name.toUpperCase()  // Type-safe access
}
```

**For JSON parsing:**

```typescript
// Incorrect
const config = JSON.parse(configString) as AppConfig  // Unsafe assertion

// Correct
function parseConfig(configString: string): AppConfig {
  const parsed: unknown = JSON.parse(configString)

  if (!isValidConfig(parsed)) {
    throw new Error('Invalid config format')
  }

  return parsed
}
```

**When any is acceptable:**
- Migrating JavaScript to TypeScript incrementally
- Third-party library workarounds (with `// @ts-expect-error`)
- Truly dynamic code where type is unknowable

Reference: [TypeScript Handbook - Unknown](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#the-unknown-type)

### 5.3 Use Assertion Functions for Validation

**Impact: MEDIUM-HIGH (reduces validation boilerplate by 50-70%)**

Assertion functions (`asserts` return type) tell TypeScript that if the function returns, the condition is true. This narrows types in the calling scope without explicit if-checks.

**Incorrect (repeated if-throw pattern):**

```typescript
function processOrder(order: Order | null): void {
  if (!order) {
    throw new Error('Order is required')
  }
  if (order.status !== 'pending') {
    throw new Error('Order must be pending')
  }
  if (!order.items.length) {
    throw new Error('Order must have items')
  }

  // Finally can use order safely
  submitOrder(order)
}

// Same checks repeated in every function that needs a valid order
function shipOrder(order: Order | null): void {
  if (!order) throw new Error('Order is required')
  if (order.status !== 'pending') throw new Error('Order must be pending')
  // ...duplicate validation
}
```

**Correct (assertion function):**

```typescript
interface ValidOrder extends Order {
  status: 'pending'
  items: [OrderItem, ...OrderItem[]]  // Non-empty array
}

function assertValidOrder(order: Order | null): asserts order is ValidOrder {
  if (!order) {
    throw new Error('Order is required')
  }
  if (order.status !== 'pending') {
    throw new Error('Order must be pending')
  }
  if (!order.items.length) {
    throw new Error('Order must have items')
  }
}

function processOrder(order: Order | null): void {
  assertValidOrder(order)
  // order is now typed as ValidOrder
  submitOrder(order)  // Type-safe
}

function shipOrder(order: Order | null): void {
  assertValidOrder(order)
  // Reuses validation, order is ValidOrder
  ship(order)
}
```

**For generic assertions:**

```typescript
function assertDefined<T>(value: T | null | undefined, name: string): asserts value is T {
  if (value === null || value === undefined) {
    throw new Error(`${name} must be defined`)
  }
}

function processUser(user: User | null): void {
  assertDefined(user, 'user')
  // user is now User, not User | null
  console.log(user.email)
}
```

**Benefits:**
- Centralizes validation logic
- Automatic type narrowing after assertion
- Clearer intent than if-throw patterns

Reference: [TypeScript 3.7 Assertion Functions](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html#assertion-functions)

### 5.4 Use const Assertions for Literal Types

**Impact: MEDIUM-HIGH (preserves literal types, enables better inference)**

The `as const` assertion preserves literal types and makes arrays/objects readonly. This enables precise type inference and prevents accidental mutations.

**Incorrect (widened types):**

```typescript
const config = {
  apiUrl: 'https://api.example.com',
  retries: 3,
  methods: ['GET', 'POST']
}
// Type: { apiUrl: string; retries: number; methods: string[] }

function makeRequest(method: 'GET' | 'POST'): void { }

makeRequest(config.methods[0])
// Error: Argument of type 'string' is not assignable to 'GET' | 'POST'

const STATUS = {
  PENDING: 'pending',
  ACTIVE: 'active'
}
// Type: { PENDING: string; ACTIVE: string }
```

**Correct (const assertion preserves literals):**

```typescript
const config = {
  apiUrl: 'https://api.example.com',
  retries: 3,
  methods: ['GET', 'POST']
} as const
// Type: { readonly apiUrl: 'https://api.example.com'; readonly retries: 3; readonly methods: readonly ['GET', 'POST'] }

function makeRequest(method: 'GET' | 'POST'): void { }

makeRequest(config.methods[0])  // Works: 'GET' is assignable to 'GET' | 'POST'

const STATUS = {
  PENDING: 'pending',
  ACTIVE: 'active'
} as const
// Type: { readonly PENDING: 'pending'; readonly ACTIVE: 'active' }

type StatusType = typeof STATUS[keyof typeof STATUS]  // 'pending' | 'active'
```

**For function parameters:**

```typescript
// Incorrect - tuple becomes array
function setCoordinates(coords: [number, number]): void { }
setCoordinates([10, 20])  // Error: number[] not assignable to [number, number]

// Correct - const preserves tuple
setCoordinates([10, 20] as const)  // Works

// Or inline
function setCoordinates(coords: readonly [number, number]): void { }
```

**When to use const assertions:**
- Configuration objects that shouldn't change
- Enum-like objects with string values
- Array/tuple literals passed to functions expecting specific types
- Creating type-safe lookup tables

Reference: [TypeScript 3.4 Const Assertions](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions)

### 5.5 Use Exhaustive Checks for Union Types

**Impact: MEDIUM-HIGH (prevents 100% of missing case errors at compile time)**

Exhaustive checks ensure all union members are handled. When a new member is added, TypeScript errors on unhandled cases rather than falling through silently at runtime.

**Incorrect (missing case compiles but fails at runtime):**

```typescript
type OrderStatus = 'pending' | 'processing' | 'shipped' | 'delivered'

function getStatusMessage(status: OrderStatus): string {
  switch (status) {
    case 'pending':
      return 'Order received'
    case 'processing':
      return 'Preparing your order'
    case 'shipped':
      return 'On the way'
    // 'delivered' case missing - no compile error
    // Returns undefined at runtime
  }
}

// Later, someone adds 'cancelled' to OrderStatus
// This function silently returns undefined for 'cancelled' and 'delivered'
```

**Correct (exhaustive check with never):**

```typescript
type OrderStatus = 'pending' | 'processing' | 'shipped' | 'delivered'

function assertNever(value: never): never {
  throw new Error(`Unhandled value: ${value}`)
}

function getStatusMessage(status: OrderStatus): string {
  switch (status) {
    case 'pending':
      return 'Order received'
    case 'processing':
      return 'Preparing your order'
    case 'shipped':
      return 'On the way'
    case 'delivered':
      return 'Order complete'
    default:
      return assertNever(status)  // Compile error if case missed
  }
}

// Adding 'cancelled' to OrderStatus now causes compile error:
// Argument of type 'string' is not assignable to parameter of type 'never'
```

**For object mapping (alternative pattern):**

```typescript
const statusMessages: Record<OrderStatus, string> = {
  pending: 'Order received',
  processing: 'Preparing your order',
  shipped: 'On the way',
  delivered: 'Order complete',
  // Missing key causes: Property 'cancelled' is missing in type
}

function getStatusMessage(status: OrderStatus): string {
  return statusMessages[status]
}
```

**Benefits:**
- Compile-time error when union expands
- Self-documenting: all cases explicitly handled
- Runtime safety via assertNever fallback

Reference: [TypeScript Handbook - Exhaustiveness Checking](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#exhaustiveness-checking)

### 5.6 Use Type Guards for Runtime Type Checking

**Impact: MEDIUM-HIGH (eliminates type assertions, catches errors at boundaries)**

Type guards provide runtime validation that TypeScript can use for static narrowing. They replace unsafe type assertions with checked operations.

**Incorrect (type assertions without validation):**

```typescript
interface User {
  id: string
  email: string
  role: 'admin' | 'user'
}

function handleUserEvent(event: MessageEvent): void {
  const user = event.data as User  // Unsafe assertion
  sendEmail(user.email)  // Crashes if data isn't actually a User
}

function processResponse(data: unknown): User[] {
  return data as User[]  // No runtime check
}
```

**Correct (type guard with validation):**

```typescript
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    typeof (value as User).id === 'string' &&
    typeof (value as User).email === 'string' &&
    ['admin', 'user'].includes((value as User).role)
  )
}

function handleUserEvent(event: MessageEvent): void {
  if (!isUser(event.data)) {
    console.error('Invalid user data received')
    return
  }
  sendEmail(event.data.email)  // Type-safe: event.data is User
}

function processResponse(data: unknown): User[] {
  if (!Array.isArray(data)) return []
  return data.filter(isUser)
}
```

**For discriminated unions:**

```typescript
interface SuccessResult {
  status: 'success'
  data: User
}

interface ErrorResult {
  status: 'error'
  message: string
}

type ApiResult = SuccessResult | ErrorResult

function isSuccess(result: ApiResult): result is SuccessResult {
  return result.status === 'success'
}

function handleResult(result: ApiResult): void {
  if (isSuccess(result)) {
    console.log(result.data.email)  // Type narrowed to SuccessResult
  } else {
    console.error(result.message)  // Type narrowed to ErrorResult
  }
}
```

Reference: [TypeScript Handbook - Narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html)

---

## 6. Memory Management

**Impact: MEDIUM**

Object pooling, WeakMap usage, and closure hygiene reduce GC pressure and memory leaks in long-running applications.

### 6.1 Avoid Closure Memory Leaks

**Impact: MEDIUM (prevents retained references in long-lived callbacks)**

Closures retain references to their outer scope variables. Long-lived callbacks can accidentally keep large objects alive, causing memory to grow unboundedly.

**Incorrect (closure retains entire scope):**

```typescript
function createDataProcessor(largeDataset: DataRecord[]): () => void {
  const processedIds = new Set<string>()

  return function processNext(): void {
    // This closure retains reference to largeDataset
    // even though it only needs processedIds
    const next = largeDataset.find(r => !processedIds.has(r.id))
    if (next) {
      processedIds.add(next.id)
      sendToServer(next)
    }
  }
}

// largeDataset (100MB) stays in memory as long as processNext exists
const processor = createDataProcessor(hugeDataset)
setInterval(processor, 1000)  // Runs forever, 100MB never freed
```

**Correct (extract only needed data):**

```typescript
function createDataProcessor(largeDataset: DataRecord[]): () => void {
  // Extract only what the closure needs
  const pendingIds = new Set(largeDataset.map(r => r.id))
  const recordById = new Map(largeDataset.map(r => [r.id, r]))

  // largeDataset can now be GC'd if caller releases it
  return function processNext(): void {
    const nextId = pendingIds.values().next().value
    if (nextId) {
      pendingIds.delete(nextId)
      const record = recordById.get(nextId)
      if (record) {
        sendToServer(record)
        recordById.delete(nextId)  // Allow record to be GC'd
      }
    }
  }
}
```

**For event handlers:**

```typescript
// Incorrect - handler retains component instance forever
class Dashboard {
  private largeCache: Map<string, Data> = new Map()

  initialize(): void {
    window.addEventListener('resize', () => {
      this.handleResize()  // 'this' keeps entire Dashboard alive
    })
  }
}

// Correct - remove listener when done, or use weak reference pattern
class Dashboard {
  private largeCache: Map<string, Data> = new Map()
  private resizeHandler: () => void

  initialize(): void {
    this.resizeHandler = () => this.handleResize()
    window.addEventListener('resize', this.resizeHandler)
  }

  destroy(): void {
    window.removeEventListener('resize', this.resizeHandler)
    this.largeCache.clear()
  }
}
```

Reference: [Node.js Memory Diagnostics](https://nodejs.org/en/learn/diagnostics/memory)

### 6.2 Avoid Global State Accumulation

**Impact: MEDIUM (prevents unbounded memory growth)**

Global variables and module-level state persist for the application's lifetime. Unbounded caches or collections at module scope grow indefinitely, causing memory exhaustion.

**Incorrect (unbounded global cache):**

```typescript
// cache.ts
const userCache = new Map<string, User>()  // Never cleared

export function getCachedUser(id: string): User | undefined {
  return userCache.get(id)
}

export function cacheUser(user: User): void {
  userCache.set(user.id, user)
  // Cache grows forever, never evicts old entries
}

// After 1 million users, cache holds 1 million User objects
```

**Correct (bounded cache with eviction):**

```typescript
// cache.ts
class LRUCache<K, V> {
  private cache = new Map<K, V>()
  private maxSize: number

  constructor(maxSize: number) {
    this.maxSize = maxSize
  }

  get(key: K): V | undefined {
    const value = this.cache.get(key)
    if (value !== undefined) {
      // Move to end (most recently used)
      this.cache.delete(key)
      this.cache.set(key, value)
    }
    return value
  }

  set(key: K, value: V): void {
    if (this.cache.has(key)) {
      this.cache.delete(key)
    } else if (this.cache.size >= this.maxSize) {
      // Evict oldest (first) entry
      const oldest = this.cache.keys().next().value
      this.cache.delete(oldest)
    }
    this.cache.set(key, value)
  }
}

const userCache = new LRUCache<string, User>(1000)  // Max 1000 entries

export function getCachedUser(id: string): User | undefined {
  return userCache.get(id)
}

export function cacheUser(user: User): void {
  userCache.set(user.id, user)
}
```

**For request-scoped state (Node.js):**

```typescript
import { AsyncLocalStorage } from 'async_hooks'

interface RequestContext {
  userId: string
  cache: Map<string, unknown>
}

const requestContext = new AsyncLocalStorage<RequestContext>()

export function runWithContext<T>(context: RequestContext, fn: () => T): T {
  return requestContext.run(context, fn)
  // Context is automatically cleaned up when request ends
}

export function getRequestCache(): Map<string, unknown> {
  return requestContext.getStore()?.cache ?? new Map()
}
```

Reference: [Node.js Memory Management](https://nodejs.org/en/learn/diagnostics/memory)

### 6.3 Clean Up Event Listeners

**Impact: MEDIUM (prevents unbounded memory growth)**

Event listeners hold references to their callback functions and bound objects. Failing to remove them when components unmount causes memory to grow with each mount/unmount cycle.

**Incorrect (listeners never removed):**

```typescript
class WebSocketManager {
  private socket: WebSocket

  connect(url: string): void {
    this.socket = new WebSocket(url)

    this.socket.addEventListener('message', (event) => {
      this.handleMessage(event.data)
    })

    this.socket.addEventListener('error', (event) => {
      this.handleError(event)
    })
    // Listeners keep 'this' alive even after disconnect
  }

  disconnect(): void {
    this.socket.close()
    // Listeners still attached, WebSocketManager can't be GC'd
  }
}
```

**Correct (listeners removed on cleanup):**

```typescript
class WebSocketManager {
  private socket: WebSocket
  private messageHandler: (event: MessageEvent) => void
  private errorHandler: (event: Event) => void

  connect(url: string): void {
    this.socket = new WebSocket(url)

    this.messageHandler = (event) => this.handleMessage(event.data)
    this.errorHandler = (event) => this.handleError(event)

    this.socket.addEventListener('message', this.messageHandler)
    this.socket.addEventListener('error', this.errorHandler)
  }

  disconnect(): void {
    this.socket.removeEventListener('message', this.messageHandler)
    this.socket.removeEventListener('error', this.errorHandler)
    this.socket.close()
  }
}
```

**Using AbortController (modern pattern):**

```typescript
class WebSocketManager {
  private socket: WebSocket
  private abortController: AbortController

  connect(url: string): void {
    this.abortController = new AbortController()
    const { signal } = this.abortController

    this.socket = new WebSocket(url)

    this.socket.addEventListener('message', (e) => this.handleMessage(e.data), { signal })
    this.socket.addEventListener('error', (e) => this.handleError(e), { signal })
    // All listeners automatically removed when signal is aborted
  }

  disconnect(): void {
    this.abortController.abort()  // Removes all listeners at once
    this.socket.close()
  }
}
```

**React useEffect pattern:**

```typescript
function useWebSocket(url: string): Data | null {
  const [data, setData] = useState<Data | null>(null)

  useEffect(() => {
    const socket = new WebSocket(url)
    const handler = (event: MessageEvent) => setData(JSON.parse(event.data))

    socket.addEventListener('message', handler)

    return () => {
      socket.removeEventListener('message', handler)
      socket.close()
    }
  }, [url])

  return data
}
```

Reference: [MDN AbortController](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)

### 6.4 Clear Timers and Intervals

**Impact: MEDIUM (prevents callback retention and repeated execution)**

`setInterval` and `setTimeout` callbacks retain references to their closure scope. Failing to clear them causes callbacks to execute indefinitely and prevents garbage collection of referenced objects.

**Incorrect (intervals never cleared):**

```typescript
class DataPoller {
  private data: LargeDataset

  start(): void {
    setInterval(() => {
      this.data = fetchLatestData()
      this.updateDashboard()
    }, 5000)
    // No reference to interval ID, can't clear it
  }

  stop(): void {
    // Can't stop the interval - it runs forever
    // 'this' is retained, DataPoller can't be GC'd
  }
}

// Each new DataPoller instance creates another interval
// Old instances can't be cleaned up
```

**Correct (intervals tracked and cleared):**

```typescript
class DataPoller {
  private data: LargeDataset
  private intervalId: ReturnType<typeof setInterval> | null = null

  start(): void {
    if (this.intervalId) return  // Prevent duplicate intervals

    this.intervalId = setInterval(() => {
      this.data = fetchLatestData()
      this.updateDashboard()
    }, 5000)
  }

  stop(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId)
      this.intervalId = null
    }
  }
}
```

**For multiple timers:**

```typescript
class AnimationController {
  private timers = new Set<ReturnType<typeof setTimeout>>()

  scheduleAnimation(delay: number, callback: () => void): void {
    const timerId = setTimeout(() => {
      this.timers.delete(timerId)
      callback()
    }, delay)
    this.timers.add(timerId)
  }

  cancelAll(): void {
    for (const timerId of this.timers) {
      clearTimeout(timerId)
    }
    this.timers.clear()
  }
}
```

**React hook pattern:**

```typescript
function usePolling(callback: () => void, interval: number): void {
  useEffect(() => {
    const id = setInterval(callback, interval)
    return () => clearInterval(id)  // Cleanup on unmount
  }, [callback, interval])
}

function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(timer)  // Clear on value change or unmount
  }, [value, delay])

  return debouncedValue
}
```

Reference: [MDN clearInterval](https://developer.mozilla.org/en-US/docs/Web/API/clearInterval)

### 6.5 Use WeakMap for Object Metadata

**Impact: MEDIUM (prevents memory leaks, enables automatic cleanup)**

WeakMap allows garbage collection of keys when no other references exist. Use it for associating metadata with objects without preventing their cleanup.

**Incorrect (Map retains object references):**

```typescript
const userMetadata = new Map<User, UserMetadata>()

function trackUser(user: User): void {
  userMetadata.set(user, {
    lastSeen: Date.now(),
    pageViews: 0
  })
}

function removeUser(user: User): void {
  // Even after user is "removed" from app state,
  // Map still holds reference, preventing GC
  userMetadata.delete(user)  // Must manually clean up
}

// If delete is forgotten, user objects leak forever
```

**Correct (WeakMap allows GC):**

```typescript
const userMetadata = new WeakMap<User, UserMetadata>()

function trackUser(user: User): void {
  userMetadata.set(user, {
    lastSeen: Date.now(),
    pageViews: 0
  })
}

// No cleanup needed - when user object is GC'd,
// WeakMap entry is automatically removed
function processUsers(users: User[]): void {
  for (const user of users) {
    trackUser(user)
  }
  // When users array is cleared, all metadata is cleaned up automatically
}
```

**Common use cases:**

```typescript
// DOM element metadata
const elementState = new WeakMap<HTMLElement, ElementState>()

function attachState(element: HTMLElement): void {
  elementState.set(element, { isExpanded: false })
  // When element is removed from DOM and GC'd, state is cleaned up
}

// Caching computed values
const computedCache = new WeakMap<Config, ComputedConfig>()

function getComputedConfig(config: Config): ComputedConfig {
  let computed = computedCache.get(config)
  if (!computed) {
    computed = expensiveComputation(config)
    computedCache.set(config, computed)
  }
  return computed
}
```

**Limitations of WeakMap:**
- Keys must be objects (not primitives)
- Not iterable (no `.keys()`, `.values()`, `.entries()`)
- No `.size` property

Reference: [MDN WeakMap](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap)

---

## 7. Runtime Optimization

**Impact: LOW-MEDIUM**

Loop optimization, property caching, and collection choice improve hot-path performance.

### 7.1 Avoid Object Spread in Hot Loops

**Impact: LOW-MEDIUM (reduces object allocations by N×)**

Object spread (`...`) creates a new object on each use. In loops, this causes N object allocations and copies. Mutate objects directly when creating new instances isn't required.

**Incorrect (N object allocations):**

```typescript
function enrichOrders(orders: Order[]): EnrichedOrder[] {
  return orders.map(order => ({
    ...order,  // Creates new object
    ...calculateTotals(order),  // Spreads another object
    processedAt: new Date()
  }))
}
// 10,000 orders = 10,000 object spreads = significant GC pressure
```

**Correct (direct assignment):**

```typescript
interface EnrichedOrder extends Order {
  tax: number
  shipping: number
  total: number
  processedAt: Date
}

function enrichOrders(orders: Order[]): EnrichedOrder[] {
  return orders.map(order => {
    const totals = calculateTotals(order)

    return {
      id: order.id,
      customerId: order.customerId,
      items: order.items,
      subtotal: order.subtotal,
      tax: totals.tax,
      shipping: totals.shipping,
      total: totals.total,
      processedAt: new Date()
    }
  })
}
```

**Note:** For immutable object creation, explicit property listing is the only spread-free option. This trades verbosity for performance in hot paths. If immutability isn't required, mutating the original object is faster still.

**For accumulation patterns:**

```typescript
// Incorrect - spreads on every iteration
const result = items.reduce((acc, item) => ({
  ...acc,
  [item.id]: item.value
}), {})
// O(n²) - each spread copies growing object

// Correct - mutate accumulator
const result = items.reduce((acc, item) => {
  acc[item.id] = item.value
  return acc
}, {} as Record<string, number>)
// O(n) - direct property assignment
```

**When spread is acceptable:**
- Outside hot paths
- Small objects (< 10 properties)
- When immutability is required for state management
- When readability significantly improves

Reference: [V8 Object Shapes](https://mathiasbynens.be/notes/shapes-ics)

### 7.2 Cache Property Access in Loops

**Impact: LOW-MEDIUM (reduces property lookups by N×)**

Repeated property access inside loops adds overhead. Cache frequently accessed properties before the loop, especially for nested properties and array lengths.

**Incorrect (repeated property access):**

```typescript
function processOrders(orders: Order[], config: AppConfig): ProcessedOrder[] {
  const results: ProcessedOrder[] = []

  for (let i = 0; i < orders.length; i++) {  // orders.length accessed each iteration
    const tax = orders[i].total * config.tax.rate  // Nested access each time
    const shipping = config.shipping.rates[orders[i].region]  // Multiple nested accesses

    results.push({
      ...orders[i],
      tax,
      shipping,
      final: orders[i].total + tax + shipping
    })
  }

  return results
}
```

**Correct (cached property access):**

```typescript
function processOrders(orders: Order[], config: AppConfig): ProcessedOrder[] {
  const results: ProcessedOrder[] = []
  const { length } = orders
  const { rate: taxRate } = config.tax
  const { rates: shippingRates } = config.shipping

  for (let i = 0; i < length; i++) {
    const order = orders[i]
    const tax = order.total * taxRate
    const shipping = shippingRates[order.region]

    results.push({
      ...order,
      tax,
      shipping,
      final: order.total + tax + shipping
    })
  }

  return results
}
```

**For functional loops:**

```typescript
// Property access is implicit but still repeated
orders.forEach(order => {
  const tax = order.total * config.tax.rate
})

// Cache outside the callback
const taxRate = config.tax.rate
orders.forEach(order => {
  const tax = order.total * taxRate
})
```

**When this matters:**
- Large arrays (1000+ items)
- Hot paths executed frequently
- Deeply nested property access

**When to skip optimization:**
- Small arrays or infrequent execution
- When readability suffers significantly
- Modern engines optimize many common patterns

Reference: [V8 Hidden Classes](https://v8.dev/blog/fast-properties)

### 7.3 Prefer Native Array Methods Over Lodash

**Impact: LOW-MEDIUM (eliminates library overhead, enables tree-shaking)**

Modern JavaScript includes most common array operations. Native methods are faster (no function call overhead) and don't add bundle weight. Use native methods when they provide equivalent functionality.

**Incorrect (lodash for native operations):**

```typescript
import _ from 'lodash'  // Imports entire library

const activeUsers = _.filter(users, u => u.isActive)
const userNames = _.map(activeUsers, u => u.name)
const firstAdmin = _.find(users, u => u.role === 'admin')
const hasAdmin = _.some(users, u => u.role === 'admin')
const allActive = _.every(users, u => u.isActive)
const userIds = _.uniq(users.map(u => u.id))
```

**Correct (native methods):**

```typescript
const activeUsers = users.filter(u => u.isActive)
const userNames = activeUsers.map(u => u.name)
const firstAdmin = users.find(u => u.role === 'admin')
const hasAdmin = users.some(u => u.role === 'admin')
const allActive = users.every(u => u.isActive)
const userIds = [...new Set(users.map(u => u.id))]
```

**Native replacements for common Lodash functions:**

```typescript
// _.flatten / _.flattenDeep
const flat = nestedArrays.flat(Infinity)

// _.chunk (still useful from lodash)
function chunk<T>(array: T[], size: number): T[][] {
  return Array.from({ length: Math.ceil(array.length / size) }, (_, i) =>
    array.slice(i * size, i * size + size)
  )
}

// _.groupBy
function groupBy<T>(array: T[], key: keyof T): Record<string, T[]> {
  return array.reduce((groups, item) => {
    const group = String(item[key])
    groups[group] = groups[group] ?? []
    groups[group].push(item)
    return groups
  }, {} as Record<string, T[]>)
}

// Object.groupBy (ES2024)
const grouped = Object.groupBy(users, user => user.role)

// _.pick / _.omit
const { password, ...userWithoutPassword } = user  // omit
const { id, name } = user  // pick
```

**When Lodash is still valuable:**
- `_.debounce`, `_.throttle` - complex timing logic
- `_.cloneDeep` - deep object cloning
- `_.merge` - deep object merging
- `_.get` with default values (but optional chaining often suffices)

Reference: [You Don't Need Lodash](https://github.com/you-dont-need/You-Dont-Need-Lodash-Underscore)

### 7.4 Use for-of for Simple Iteration

**Impact: LOW-MEDIUM (reduces iteration boilerplate by 30-50%)**

`for-of` provides clean syntax for array iteration with performance comparable to traditional `for` loops. Use it when you don't need the index and aren't modifying the array.

**Incorrect (index-based when index isn't needed):**

```typescript
function calculateTotal(orders: Order[]): number {
  let total = 0
  for (let i = 0; i < orders.length; i++) {
    total += orders[i].amount
  }
  return total
}

function processUsers(users: User[]): void {
  for (let i = 0; i < users.length; i++) {
    sendNotification(users[i])
  }
}
```

**Correct (for-of for clean iteration):**

```typescript
function calculateTotal(orders: Order[]): number {
  let total = 0
  for (const order of orders) {
    total += order.amount
  }
  return total
}

function processUsers(users: User[]): void {
  for (const user of users) {
    sendNotification(user)
  }
}
```

**When to use each pattern:**

```typescript
// for-of: when you only need values
for (const item of items) {
  process(item)
}

// forEach: when you want functional style (but can't break/return)
items.forEach(item => process(item))

// for-in: only for object keys (never for arrays)
for (const key in config) {
  console.log(key, config[key])
}

// Traditional for: when you need index, or need to modify loop
for (let i = 0; i < items.length; i++) {
  if (items[i].id === targetId) {
    items[i] = updatedItem  // Modifying array
    break  // Early exit
  }
}

// entries(): when you need both index and value
for (const [index, item] of items.entries()) {
  console.log(`${index}: ${item.name}`)
}
```

**Avoid for-in for arrays:**

```typescript
// NEVER do this
for (const index in items) {
  // index is a string, not number
  // Iterates inherited properties
  // Wrong order not guaranteed
}
```

Reference: [MDN for...of](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...of)

### 7.5 Use Modern String Methods

**Impact: LOW-MEDIUM (2-5× faster than regex for simple patterns)**

Modern string methods like `startsWith()`, `endsWith()`, `includes()`, and `padStart()` are clearer and often faster than regex or manual substring operations.

**Incorrect (regex or substring for simple checks):**

```typescript
function isImageFile(filename: string): boolean {
  return /\.(jpg|png|gif)$/.test(filename)
}

function hasHttpPrefix(url: string): boolean {
  return url.substring(0, 7) === 'http://' || url.substring(0, 8) === 'https://'
}

function containsSearchTerm(text: string, term: string): boolean {
  return text.indexOf(term) !== -1
}

function formatOrderId(id: number): string {
  return ('000000' + id).slice(-6)  // Pad to 6 digits
}
```

**Correct (modern string methods):**

```typescript
function isImageFile(filename: string): boolean {
  return filename.endsWith('.jpg') ||
         filename.endsWith('.png') ||
         filename.endsWith('.gif')
}

function hasHttpPrefix(url: string): boolean {
  return url.startsWith('http://') || url.startsWith('https://')
}

function containsSearchTerm(text: string, term: string): boolean {
  return text.includes(term)
}

function formatOrderId(id: number): string {
  return String(id).padStart(6, '0')
}
```

**Additional useful methods:**

```typescript
// replaceAll (no global regex needed)
const sanitized = input.replaceAll('<', '&lt;').replaceAll('>', '&gt;')

// at() for negative indexing
const lastChar = filename.at(-1)  // Last character
const extension = filename.split('.').at(-1)  // Last segment

// trimStart/trimEnd for directional trimming
const trimmedLeft = '   text   '.trimStart()   // 'text   '
const trimmedRight = '   text   '.trimEnd()    // '   text'

// repeat for string multiplication
const separator = '-'.repeat(40)
const indent = '  '.repeat(depth)
```

**When regex is still needed:**
- Complex pattern matching
- Capture groups
- Case-insensitive matching (`/pattern/i`)
- Multiple conditions in one check

Reference: [MDN String Methods](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String)

### 7.6 Use Set/Map for O(1) Lookups

**Impact: LOW-MEDIUM (O(n) to O(1) per lookup)**

Array methods like `.includes()` and `.find()` are O(n) operations. For frequent lookups, convert arrays to Set or Map for O(1) access.

**Incorrect (O(n) per lookup):**

```typescript
const allowedRoles = ['admin', 'editor', 'viewer', 'moderator']

function hasPermission(userRole: string): boolean {
  return allowedRoles.includes(userRole)  // O(n) every call
}

// In a loop, this becomes O(n × m)
function filterAuthorizedUsers(users: User[]): User[] {
  return users.filter(user => allowedRoles.includes(user.role))
  // 1000 users × 4 roles = 4000 comparisons
}
```

**Correct (O(1) per lookup):**

```typescript
const allowedRoles = new Set(['admin', 'editor', 'viewer', 'moderator'])

function hasPermission(userRole: string): boolean {
  return allowedRoles.has(userRole)  // O(1) every call
}

function filterAuthorizedUsers(users: User[]): User[] {
  return users.filter(user => allowedRoles.has(user.role))
  // 1000 users × O(1) = 1000 operations
}
```

**For object lookups by key:**

```typescript
// Incorrect - O(n) search
const users: User[] = [/* ... */]
function findUserById(id: string): User | undefined {
  return users.find(u => u.id === id)  // Scans entire array
}

// Correct - O(1) lookup
const userById = new Map<string, User>(users.map(u => [u.id, u]))
function findUserById(id: string): User | undefined {
  return userById.get(id)
}
```

**When to stick with arrays:**
- Small collections (< 10 items)
- One-time lookups where conversion cost exceeds benefit
- When you need array methods like `.map()`, `.filter()`, `.slice()`

Reference: [MDN Set](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set)

---

## 8. Advanced Patterns

**Impact: LOW**

Branded types, variance annotations, and declaration merging for specialized use cases.

### 8.1 Use Branded Types for Type-Safe IDs

**Impact: LOW (prevents mixing incompatible ID types)**

TypeScript uses structural typing, so `string` types are interchangeable even when they represent different concepts. Branded types add a unique marker to prevent mixing incompatible values.

**Incorrect (structural typing allows mixing):**

```typescript
type UserId = string
type OrderId = string
type ProductId = string

function fetchUser(id: UserId): Promise<User> { /* ... */ }
function fetchOrder(id: OrderId): Promise<Order> { /* ... */ }

const userId: UserId = 'user-123'
const orderId: OrderId = 'order-456'

// No error - all strings are interchangeable
fetchUser(orderId)  // Bug: passed OrderId to UserId parameter
fetchOrder(userId)  // Bug: passed UserId to OrderId parameter
```

**Correct (branded types prevent mixing):**

```typescript
type Brand<K, T> = K & { __brand: T }

type UserId = Brand<string, 'UserId'>
type OrderId = Brand<string, 'OrderId'>
type ProductId = Brand<string, 'ProductId'>

function createUserId(id: string): UserId {
  return id as UserId
}

function createOrderId(id: string): OrderId {
  return id as OrderId
}

function fetchUser(id: UserId): Promise<User> { /* ... */ }
function fetchOrder(id: OrderId): Promise<Order> { /* ... */ }

const userId = createUserId('user-123')
const orderId = createOrderId('order-456')

fetchUser(orderId)  // Error: Argument of type 'OrderId' is not assignable to 'UserId'
fetchOrder(userId)  // Error: Argument of type 'UserId' is not assignable to 'OrderId'
fetchUser(userId)   // OK
```

**For numeric types:**

```typescript
type Cents = Brand<number, 'Cents'>
type Dollars = Brand<number, 'Dollars'>

function toCents(dollars: Dollars): Cents {
  return (dollars * 100) as Cents
}

function formatPrice(cents: Cents): string {
  return `$${(cents / 100).toFixed(2)}`
}

const price = 29.99 as Dollars
formatPrice(price)  // Error: Dollars not assignable to Cents
formatPrice(toCents(price))  // OK: '$29.99'
```

**When to use branded types:**
- Entity IDs that shouldn't be mixed
- Currency/unit conversions
- Validated strings (email, URL, slug)
- Sensitive data that needs tracking

Reference: [TypeScript Handbook - Branded Types](https://www.typescriptlang.org/docs/handbook/2/types-from-types.html)

### 8.2 Use satisfies for Type Validation with Inference

**Impact: LOW (prevents property access errors, enables 100% autocomplete accuracy)**

The `satisfies` operator validates that a value conforms to a type while preserving the narrower inferred type. This gives you both type safety and precise autocomplete.

**Incorrect (type annotation loses literal types):**

```typescript
type ColorConfig = Record<string, [number, number, number]>

const colors: ColorConfig = {
  red: [255, 0, 0],
  green: [0, 255, 0],
  blue: [0, 0, 255],
  // Can't access colors.red - it's just string keys
}

// TypeScript doesn't know 'red' is a valid key
const redValue = colors.red    // Type: [number, number, number]
const pinkValue = colors.pink  // No error! Type: [number, number, number]
```

**Correct (satisfies preserves literal types):**

```typescript
type ColorConfig = Record<string, [number, number, number]>

const colors = {
  red: [255, 0, 0],
  green: [0, 255, 0],
  blue: [0, 0, 255],
} satisfies ColorConfig

// TypeScript knows exact keys
const redValue = colors.red    // Type: [number, number, number]
const pinkValue = colors.pink  // Error: Property 'pink' does not exist
```

**For configuration objects:**

```typescript
interface Route {
  path: string
  component: () => JSX.Element
  auth?: boolean
}

// Without satisfies - loses literal path types
const routes: Route[] = [
  { path: '/', component: Home },
  { path: '/users', component: Users },
]
// routes[0].path is just 'string'

// With satisfies - preserves literal paths
const routes = [
  { path: '/', component: Home },
  { path: '/users', component: Users },
] satisfies Route[]
// routes[0].path is '/'

type RoutePath = typeof routes[number]['path']  // '/' | '/users'
```

**Combining with as const:**

```typescript
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3,
} as const satisfies {
  apiUrl: string
  timeout: number
  retries: number
}

// Both validated AND readonly with literal types
config.apiUrl  // Type: 'https://api.example.com' (not just string)
config.timeout = 3000  // Error: Cannot assign to 'timeout' (readonly)
```

**When to use satisfies vs type annotation:**
- Use `satisfies` when you want validation but need literal types
- Use type annotation (`:`) when you want the variable to be exactly that type
- Use `as const satisfies` for readonly config with validation

Reference: [TypeScript 4.9 satisfies](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html#the-satisfies-operator)

### 8.3 Use Template Literal Types for String Patterns

**Impact: LOW (prevents 100% of string format errors at compile time)**

Template literal types allow defining string patterns at the type level. TypeScript validates that strings match the expected format at compile time.

**Incorrect (plain string allows any value):**

```typescript
type EventHandler = {
  event: string
  handler: () => void
}

const handler: EventHandler = {
  event: 'click',  // OK
  handler: () => {}
}

const badHandler: EventHandler = {
  event: 'clck',  // Typo - no error
  handler: () => {}
}

function addEventListener(event: string, handler: () => void): void { }
addEventListener('onlcick', () => {})  // Typo compiles fine
```

**Correct (template literal type validates pattern):**

```typescript
type DOMEvent = 'click' | 'focus' | 'blur' | 'submit' | 'change'
type EventHandlerName = `on${Capitalize<DOMEvent>}`

type EventHandler = {
  event: EventHandlerName
  handler: () => void
}

const handler: EventHandler = {
  event: 'onClick',  // OK
  handler: () => {}
}

const badHandler: EventHandler = {
  event: 'onClck',  // Error: Type '"onClck"' is not assignable to type 'EventHandlerName'
  handler: () => {}
}
```

**For CSS-like patterns:**

```typescript
type CSSUnit = 'px' | 'em' | 'rem' | '%' | 'vh' | 'vw'
type CSSValue = `${number}${CSSUnit}`

function setWidth(element: HTMLElement, width: CSSValue): void {
  element.style.width = width
}

setWidth(div, '100px')   // OK
setWidth(div, '2.5rem')  // OK
setWidth(div, '100')     // Error: Type '"100"' is not assignable to type 'CSSValue'
setWidth(div, '100pixels')  // Error
```

**For API route patterns:**

```typescript
type APIVersion = 'v1' | 'v2'
type Resource = 'users' | 'orders' | 'products'
type APIRoute = `/api/${APIVersion}/${Resource}`

function fetchResource(route: APIRoute): Promise<Response> {
  return fetch(route)
}

fetchResource('/api/v1/users')    // OK
fetchResource('/api/v2/orders')   // OK
fetchResource('/api/v3/users')    // Error: 'v3' not in APIVersion
fetchResource('/users')           // Error: doesn't match pattern
```

**Combining with mapped types:**

```typescript
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K]
}

interface User {
  name: string
  age: number
}

type UserGetters = Getters<User>
// { getName: () => string; getAge: () => number }
```

Reference: [TypeScript 4.1 Template Literal Types](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html)

---

## References

1. [https://github.com/microsoft/TypeScript/wiki/Performance](https://github.com/microsoft/TypeScript/wiki/Performance)
2. [https://www.typescriptlang.org/docs/handbook/](https://www.typescriptlang.org/docs/handbook/)
3. [https://v8.dev/blog](https://v8.dev/blog)
4. [https://nodejs.org/en/learn/diagnostics/memory](https://nodejs.org/en/learn/diagnostics/memory)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |