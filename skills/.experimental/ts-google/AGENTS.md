# TypeScript

**Version 0.1.0**  
Google  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive TypeScript style guide based on Google's internal standards, designed for AI agents and LLMs. Contains 45 rules across 8 categories, prioritized by impact from critical (module organization, type safety) to incremental (literals and coercion). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Module Organization](#1-module-organization) — **CRITICAL**
   - 1.1 [Avoid Mutable Exports](#11-avoid-mutable-exports)
   - 1.2 [Avoid TypeScript Namespaces](#12-avoid-typescript-namespaces)
   - 1.3 [Minimize Exported API Surface](#13-minimize-exported-api-surface)
   - 1.4 [Use ES6 Modules Exclusively](#14-use-es6-modules-exclusively)
   - 1.5 [Use Import Type for Type-Only Imports](#15-use-import-type-for-type-only-imports)
   - 1.6 [Use Named Exports Over Default Exports](#16-use-named-exports-over-default-exports)
   - 1.7 [Use Relative Paths for Project Imports](#17-use-relative-paths-for-project-imports)
2. [Type Safety](#2-type-safety) — **CRITICAL**
   - 2.1 [Avoid Empty Object Type](#21-avoid-empty-object-type)
   - 2.2 [Explicitly Annotate Structural Types](#22-explicitly-annotate-structural-types)
   - 2.3 [Handle Nullable Types Correctly](#23-handle-nullable-types-correctly)
   - 2.4 [Never Use the any Type](#24-never-use-the-any-type)
   - 2.5 [Never Use Wrapper Object Types](#25-never-use-wrapper-object-types)
   - 2.6 [Prefer Interfaces Over Type Aliases for Objects](#26-prefer-interfaces-over-type-aliases-for-objects)
   - 2.7 [Prefer Map and Set Over Index Signatures](#27-prefer-map-and-set-over-index-signatures)
   - 2.8 [Use Consistent Array Type Syntax](#28-use-consistent-array-type-syntax)
3. [Class Design](#3-class-design) — **HIGH**
   - 3.1 [Always Use Parentheses in Constructor Calls](#31-always-use-parentheses-in-constructor-calls)
   - 3.2 [Avoid Container Classes with Only Static Members](#32-avoid-container-classes-with-only-static-members)
   - 3.3 [Mark Properties Readonly When Never Reassigned](#33-mark-properties-readonly-when-never-reassigned)
   - 3.4 [Never Manipulate Prototypes Directly](#34-never-manipulate-prototypes-directly)
   - 3.5 [Use Parameter Properties for Constructor Assignment](#35-use-parameter-properties-for-constructor-assignment)
   - 3.6 [Use TypeScript Private Over Private Fields](#36-use-typescript-private-over-private-fields)
4. [Function Patterns](#4-function-patterns) — **HIGH**
   - 4.1 [Avoid Rebinding this](#41-avoid-rebinding-this)
   - 4.2 [Prefer Function Declarations Over Expressions](#42-prefer-function-declarations-over-expressions)
   - 4.3 [Use Concise Arrow Function Bodies Appropriately](#43-use-concise-arrow-function-bodies-appropriately)
   - 4.4 [Use Correct Generator Function Syntax](#44-use-correct-generator-function-syntax)
   - 4.5 [Use Default Parameters Sparingly](#45-use-default-parameters-sparingly)
   - 4.6 [Use Rest Parameters Over arguments](#46-use-rest-parameters-over-arguments)
5. [Control Flow](#5-control-flow) — **MEDIUM-HIGH**
   - 5.1 [Always Include Default Case in Switch](#51-always-include-default-case-in-switch)
   - 5.2 [Always Use Braces for Control Structures](#52-always-use-braces-for-control-structures)
   - 5.3 [Always Use Triple Equals](#53-always-use-triple-equals)
   - 5.4 [Avoid Assignment in Conditional Expressions](#54-avoid-assignment-in-conditional-expressions)
   - 5.5 [Prefer for-of Over for-in for Arrays](#55-prefer-for-of-over-for-in-for-arrays)
6. [Error Handling](#6-error-handling) — **MEDIUM**
   - 6.1 [Always Throw Error Instances](#61-always-throw-error-instances)
   - 6.2 [Avoid Type and Non-Null Assertions](#62-avoid-type-and-non-null-assertions)
   - 6.3 [Document Empty Catch Blocks](#63-document-empty-catch-blocks)
   - 6.4 [Type Catch Clause Variables as Unknown](#64-type-catch-clause-variables-as-unknown)
7. [Naming & Style](#7-naming-style) — **MEDIUM**
   - 7.1 [Avoid Decorative Underscores](#71-avoid-decorative-underscores)
   - 7.2 [No I Prefix for Interfaces](#72-no-i-prefix-for-interfaces)
   - 7.3 [Use CONSTANT_CASE for True Constants](#73-use-constantcase-for-true-constants)
   - 7.4 [Use Correct Identifier Naming Styles](#74-use-correct-identifier-naming-styles)
   - 7.5 [Use Descriptive Names](#75-use-descriptive-names)
8. [Literals & Coercion](#8-literals-coercion) — **LOW-MEDIUM**
   - 8.1 [Avoid Array Constructor](#81-avoid-array-constructor)
   - 8.2 [Use Correct Number Literal Formats](#82-use-correct-number-literal-formats)
   - 8.3 [Use Explicit Type Coercion](#83-use-explicit-type-coercion)
   - 8.4 [Use Single Quotes for Strings](#84-use-single-quotes-for-strings)

---

## 1. Module Organization

**Impact: CRITICAL**

Import/export patterns affect build times, tree-shaking, and error detection at scale. Named exports catch typos at import time.

### 1.1 Avoid Mutable Exports

**Impact: CRITICAL (prevents hard-to-track state mutations)**

Mutable exports create hidden state that can be modified from anywhere, making code behavior unpredictable and bugs difficult to trace.

**Incorrect (mutable export):**

```typescript
// config.ts
export let currentUser: User | null = null
export let apiEndpoint = 'https://api.example.com'

// somewhere.ts
import { currentUser, apiEndpoint } from './config'
apiEndpoint = 'https://staging.example.com'  // Mutates global state
```

**Correct (immutable exports with explicit setters):**

```typescript
// config.ts
let _currentUser: User | null = null
const _apiEndpoint = 'https://api.example.com'

export function getCurrentUser(): User | null {
  return _currentUser
}

export function setCurrentUser(user: User | null): void {
  _currentUser = user
}

export const apiEndpoint = _apiEndpoint  // const export
```

**Alternative (readonly object):**

```typescript
export const config = {
  apiEndpoint: 'https://api.example.com',
  timeout: 5000,
} as const
```

Reference: [Google TypeScript Style Guide - Mutable exports](https://google.github.io/styleguide/tsguide.html#mutable-exports)

### 1.2 Avoid TypeScript Namespaces

**Impact: CRITICAL (prevents runtime overhead and enables tree-shaking)**

TypeScript namespaces create runtime objects that prevent tree-shaking and add unnecessary overhead. Use ES6 modules for code organization.

**Incorrect (TypeScript namespace):**

```typescript
namespace MyApp {
  export interface User {
    name: string
  }

  export function createUser(name: string): User {
    return { name }
  }
}

// Usage
const user = MyApp.createUser('Alice')
// Compiles to runtime object with all exports bundled
```

**Correct (ES6 modules):**

```typescript
// user.ts
export interface User {
  name: string
}

export function createUser(name: string): User {
  return { name }
}

// main.ts
import { createUser } from './user'
const user = createUser('Alice')
// Tree-shakeable, no runtime overhead
```

**Exception:** Namespaces may be required when interfacing with external third-party code that uses them.

Reference: [Google TypeScript Style Guide - Namespaces vs Modules](https://google.github.io/styleguide/tsguide.html#namespaces-vs-modules)

### 1.3 Minimize Exported API Surface

**Impact: HIGH (reduces coupling and maintenance burden)**

Export only what consumers need. Internal implementation details should remain private to allow refactoring without breaking changes.

**Incorrect (over-exporting):**

```typescript
// user-service.ts
export const API_ENDPOINT = '/api/users'
export const MAX_RETRIES = 3

export function validateUser(user: User): boolean {
  return user.name.length > 0
}

export function formatUserForApi(user: User): ApiUser {
  return { userName: user.name, userId: user.id }
}

export async function createUser(name: string): Promise<User> {
  const user = { name, id: generateId() }
  if (!validateUser(user)) throw new Error('Invalid')
  const apiUser = formatUserForApi(user)
  return sendToApi(apiUser)
}
```

**Correct (minimal exports):**

```typescript
// user-service.ts
const API_ENDPOINT = '/api/users'
const MAX_RETRIES = 3

function validateUser(user: User): boolean {
  return user.name.length > 0
}

function formatUserForApi(user: User): ApiUser {
  return { userName: user.name, userId: user.id }
}

// Only export the public API
export async function createUser(name: string): Promise<User> {
  const user = { name, id: generateId() }
  if (!validateUser(user)) throw new Error('Invalid')
  const apiUser = formatUserForApi(user)
  return sendToApi(apiUser)
}
```

**Benefits:**
- Internal functions can be refactored freely
- Smaller public API is easier to document
- Clearer boundary between public and private code

Reference: [Google TypeScript Style Guide - Export visibility](https://google.github.io/styleguide/tsguide.html#export-visibility)

### 1.4 Use ES6 Modules Exclusively

**Impact: CRITICAL (enables tree-shaking and static analysis)**

ES6 modules enable static analysis, tree-shaking, and consistent behavior across environments. Never use legacy module systems.

**Incorrect (legacy patterns):**

```typescript
// CommonJS - no static analysis possible
const fs = require('fs')

// TypeScript namespaces - creates runtime overhead
namespace MyApp {
  export class User {}
}

// Triple-slash references - fragile path resolution
/// <reference path="./types.d.ts" />
```

**Correct (ES6 modules):**

```typescript
// Named imports
import { readFile, writeFile } from 'fs'

// Namespace imports for large APIs
import * as fs from 'fs'

// Side-effect imports (use sparingly)
import './polyfills'
```

**When to use each import style:**
- Named imports: accessing few symbols frequently
- Namespace imports: accessing many symbols from large APIs
- Side-effect imports: libraries requiring initialization

Reference: [Google TypeScript Style Guide - Imports](https://google.github.io/styleguide/tsguide.html#imports)

### 1.5 Use Import Type for Type-Only Imports

**Impact: HIGH (reduces bundle size by eliminating runtime imports)**

When importing types that are only used for type annotations (not at runtime), use `import type` to ensure they're removed during compilation.

**Incorrect (regular import for types):**

```typescript
import { User, UserService } from './user'

// User is only used as type, UserService is used at runtime
function getUser(service: UserService, id: string): User {
  return service.get(id)
}
// 'User' import may remain in bundle depending on transpiler
```

**Correct (explicit type import):**

```typescript
import type { User } from './user'
import { UserService } from './user'

function getUser(service: UserService, id: string): User {
  return service.get(id)
}
// 'User' guaranteed to be removed from bundle
```

**Alternative (inline type modifier):**

```typescript
import { type User, UserService } from './user'
```

**Benefits:**
- Guaranteed removal of type-only imports
- Clearer intent in code review
- Prevents accidental runtime usage of types

Reference: [TypeScript 3.8 - Type-Only Imports](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-8.html)

### 1.6 Use Named Exports Over Default Exports

**Impact: CRITICAL (catches import typos at compile time)**

Named exports error when import statements try to import something that hasn't been declared, catching typos and refactoring mistakes at compile time.

**Incorrect (default export allows any import name):**

```typescript
// user.ts
export default class User {
  constructor(public name: string) {}
}

// main.ts
import Usr from './user'  // Typo not caught - silently works
```

**Correct (named export catches typos):**

```typescript
// user.ts
export class User {
  constructor(public name: string) {}
}

// main.ts
import { Usr } from './user'  // Error: Module has no exported member 'Usr'
import { User } from './user'  // Correct
```

**Benefits:**
- Compile-time error detection for typos
- Better tree-shaking in bundlers
- Consistent import names across codebase
- Easier refactoring with IDE support

Reference: [Google TypeScript Style Guide - Export visibility](https://google.github.io/styleguide/tsguide.html#export-visibility)

### 1.7 Use Relative Paths for Project Imports

**Impact: HIGH (improves refactoring flexibility and reduces coupling)**

Use relative paths (`./foo`) for imports within your project to maintain flexibility when moving code between directories.

**Incorrect (absolute or alias paths for local code):**

```typescript
// Tightly coupled to project structure
import { User } from '@app/models/user'
import { createUser } from 'src/services/user-service'
```

**Correct (relative paths):**

```typescript
// Flexible, works when files are moved together
import { User } from './models/user'
import { createUser } from '../services/user-service'
```

**When to use non-relative imports:**
- External npm packages: `import { useState } from 'react'`
- Configured path aliases for truly shared code
- Generated code or type definitions

**Benefits:**
- Files can be moved together without breaking imports
- No build configuration required
- Clear dependency direction visible in path

Reference: [Google TypeScript Style Guide - Module imports](https://google.github.io/styleguide/tsguide.html#imports)

---

## 2. Type Safety

**Impact: CRITICAL**

Proper typing prevents runtime errors and enables compiler optimizations. Avoiding `any` is the foundation of type safety.

### 2.1 Avoid Empty Object Type

**Impact: HIGH (prevents unexpected type widening)**

Never use `{}` as a type. It matches almost everything except `null` and `undefined`, which is almost never the intended behavior.

**Incorrect (empty object type):**

```typescript
// Matches strings, numbers, arrays - anything non-nullish
function process(value: {}) {
  // No useful operations available
}

process('string')  // Allowed!
process(123)       // Allowed!
process([1, 2, 3]) // Allowed!
```

**Correct (use appropriate types):**

```typescript
// For any value including null/undefined
function processAnything(value: unknown) {
  // Must narrow type before use
}

// For non-null objects only
function processObject(value: object) {
  // Excludes primitives
}

// For dictionaries with known value type
function processDictionary(value: Record<string, unknown>) {
  // Can iterate over properties
}

// For specific shape
interface Config {
  timeout: number
  retries: number
}
function processConfig(value: Config) {
  // Full type safety
}
```

**Type comparison:**
- `{}` - Everything except `null`/`undefined`
- `object` - Non-primitive values only
- `unknown` - Everything, requires narrowing
- `Record<K, V>` - Dictionary with typed values

Reference: [Google TypeScript Style Guide - {} type](https://google.github.io/styleguide/tsguide.html#the--type)

### 2.2 Explicitly Annotate Structural Types

**Impact: CRITICAL (catches type mismatches at declaration site)**

Always explicitly declare structural types for objects. This catches field mismatches at the declaration site rather than at usage.

**Incorrect (inferred type):**

```typescript
interface User {
  name: string
  email: string
}

// Type is inferred, typo not caught here
const user = {
  name: 'Alice',
  emial: 'alice@example.com',  // Typo!
}

function sendEmail(user: User) {
  console.log(user.email)
}

sendEmail(user)  // Error here, far from source
```

**Correct (explicit annotation):**

```typescript
interface User {
  name: string
  email: string
}

// Error caught immediately at declaration
const user: User = {
  name: 'Alice',
  emial: 'alice@example.com',  // Error: 'emial' does not exist in type 'User'
}
```

**Alternative (satisfies for inference with checking):**

```typescript
const user = {
  name: 'Alice',
  email: 'alice@example.com',
} satisfies User
// Type is inferred but validated against User
```

**Benefits:**
- Errors appear at the source, not at usage
- Self-documenting code
- Better refactoring support

Reference: [Google TypeScript Style Guide - Structural types](https://google.github.io/styleguide/tsguide.html#structural-types-vs-nominal-types)

### 2.3 Handle Nullable Types Correctly

**Impact: CRITICAL (prevents null reference errors)**

Type aliases must NOT include `|null` or `|undefined`. Add nullability only at usage sites. Prefer optional properties over `|undefined`.

**Incorrect (nullability in type alias):**

```typescript
// Nullability baked into type
type CoffeeResponse = Latte | Americano | undefined

interface UserCache {
  user: User | null  // Forces all consumers to handle null
}
```

**Correct (nullability at usage site):**

```typescript
// Clean base type
type CoffeeResponse = Latte | Americano

// Nullability added where needed
class CoffeeService {
  getOrder(): CoffeeResponse | undefined {
    // May not find an order
  }
}

interface UserCache {
  user?: User  // Optional property preferred
}
```

**Guidelines:**
- Use `undefined` for JavaScript APIs (more idiomatic)
- Use `null` for DOM and Google APIs (conventional)
- Prefer `field?: Type` over `field: Type | undefined`
- Check for both with `value == null` when appropriate

**Incorrect (redundant undefined):**

```typescript
interface Config {
  timeout: number | undefined  // Redundant
}
```

**Correct (optional property):**

```typescript
interface Config {
  timeout?: number  // Cleaner, same semantics
}
```

Reference: [Google TypeScript Style Guide - Null vs Undefined](https://google.github.io/styleguide/tsguide.html#null-vs-undefined)

### 2.4 Never Use the any Type

**Impact: CRITICAL (prevents undetected type errors throughout codebase)**

The `any` type allows assignment into any other type and dereferencing any property, completely disabling type checking and enabling undetected errors.

**Incorrect (using any):**

```typescript
function processData(data: any) {
  return data.items.map((item: any) => item.value)
  // No type checking - typos, wrong properties, all pass silently
}

const result = processData({ itms: [] })  // Typo not caught
```

**Correct (use specific types or unknown):**

```typescript
interface DataPayload {
  items: Array<{ value: number }>
}

function processData(data: DataPayload) {
  return data.items.map((item) => item.value)
  // Full type checking
}

const result = processData({ itms: [] })  // Error: 'itms' not in DataPayload
```

**Alternative (use unknown for truly unknown values):**

```typescript
function processUnknown(data: unknown) {
  // Must narrow type before use
  if (typeof data === 'object' && data !== null && 'items' in data) {
    // Safe to access data.items
  }
}
```

**When you think you need any:**
1. Define an interface for the expected shape
2. Use `unknown` with type narrowing
3. Use generics for flexible typing

Reference: [Google TypeScript Style Guide - Any type](https://google.github.io/styleguide/tsguide.html#any)

### 2.5 Never Use Wrapper Object Types

**Impact: CRITICAL (prevents type confusion and boxing overhead)**

Never use wrapper types (`String`, `Boolean`, `Number`, `Symbol`, `BigInt`). Use lowercase primitive types. Never instantiate wrappers with `new`.

**Incorrect (wrapper types):**

```typescript
// Wrapper types as annotations
function greet(name: String): Boolean {
  return name.length > 0
}

// Instantiating wrapper objects
const message = new String('hello')
const count = new Number(42)
const flag = new Boolean(true)

// These create objects, not primitives!
typeof message  // 'object', not 'string'
```

**Correct (primitive types):**

```typescript
// Primitive type annotations
function greet(name: string): boolean {
  return name.length > 0
}

// Literal values
const message = 'hello'
const count = 42
const flag = true

// Coercion without new
const str = String(someValue)
const num = Number(someValue)
const bool = Boolean(someValue)
```

**Why this matters:**
- `String !== string` in TypeScript
- Wrapper objects have different identity semantics
- Unnecessary memory allocation
- Confusing behavior in comparisons

Reference: [Google TypeScript Style Guide - Wrapper types](https://google.github.io/styleguide/tsguide.html#wrapper-types)

### 2.6 Prefer Interfaces Over Type Aliases for Objects

**Impact: CRITICAL (better error messages and IDE performance)**

Interfaces provide better error messages (at declaration vs usage), better IDE support, and clearer semantics for object shapes.

**Incorrect (type alias for object):**

```typescript
type User = {
  firstName: string
  lastName: string
  email: string
}

type UserWithId = User & {
  id: string
}
```

**Correct (interface):**

```typescript
interface User {
  firstName: string
  lastName: string
  email: string
}

interface UserWithId extends User {
  id: string
}
```

**When to use type aliases:**
- Union types: `type Status = 'pending' | 'active' | 'inactive'`
- Mapped types: `type Readonly<T> = { readonly [K in keyof T]: T[K] }`
- Tuple types: `type Point = [number, number]`
- Function types: `type Handler = (event: Event) => void`

**Benefits of interfaces:**
- Declaration merging for extending third-party types
- Better error locality (errors at interface, not usage)
- More intuitive `extends` vs `&` for inheritance
- Better TypeScript compiler performance

Reference: [Google TypeScript Style Guide - Interfaces vs Type Aliases](https://google.github.io/styleguide/tsguide.html#interfaces-vs-type-aliases)

### 2.7 Prefer Map and Set Over Index Signatures

**Impact: HIGH (O(1) operations with proper typing)**

Use `Map` and `Set` instead of objects with index signatures for better type safety, predictable iteration order, and O(1) operations.

**Incorrect (index signature objects):**

```typescript
// Loose typing, prototype pollution risk
const userScores: { [key: string]: number } = {}
userScores['alice'] = 100
userScores['bob'] = 85

// Checking existence is awkward
if (userScores['charlie'] !== undefined) {
  // ...
}

// toString, hasOwnProperty are valid keys (prototype issues)
```

**Correct (Map/Set):**

```typescript
// Type-safe, no prototype pollution
const userScores = new Map<string, number>()
userScores.set('alice', 100)
userScores.set('bob', 85)

// Clear existence check
if (userScores.has('charlie')) {
  const score = userScores.get('charlie')!
}

// For unique values
const activeUsers = new Set<string>()
activeUsers.add('alice')
activeUsers.add('bob')
```

**When to use index signatures:**
- JSON serialization (Map doesn't serialize cleanly)
- Known, finite set of keys: use Record type instead

```typescript
type UserRole = 'admin' | 'user' | 'guest'
const permissions: Record<UserRole, string[]> = {
  admin: ['read', 'write', 'delete'],
  user: ['read', 'write'],
  guest: ['read'],
}
```

Reference: [Google TypeScript Style Guide - Indexable types](https://google.github.io/styleguide/tsguide.html#indexable-types)

### 2.8 Use Consistent Array Type Syntax

**Impact: HIGH (improves readability and consistency)**

Use `T[]` for simple types and `Array<T>` for complex types (unions, objects). This improves readability and prevents parsing ambiguity.

**Incorrect (inconsistent or complex syntax):**

```typescript
// Generic for simple types
const numbers: Array<number> = [1, 2, 3]
const names: Array<string> = ['Alice', 'Bob']

// Bracket syntax for complex types (hard to read)
const items: { id: number; name: string }[] = []
const mixed: (string | number)[] = []
```

**Correct (appropriate syntax):**

```typescript
// Bracket syntax for simple types
const numbers: number[] = [1, 2, 3]
const names: string[] = ['Alice', 'Bob']
const matrix: number[][] = [[1, 2], [3, 4]]

// Generic syntax for complex types
const items: Array<{ id: number; name: string }> = []
const mixed: Array<string | number> = []
const callbacks: Array<(value: number) => void> = []

// Readonly arrays
const constants: readonly number[] = [1, 2, 3]
```

**Summary:**
- Simple types: `T[]`, `readonly T[]`
- Multi-dimensional: `T[][]`
- Complex/union types: `Array<T>`
- Tuples: `[T, U]`

Reference: [Google TypeScript Style Guide - Array type](https://google.github.io/styleguide/tsguide.html#array-type)

---

## 3. Class Design

**Impact: HIGH**

Class structure affects memory layout, VM optimization, and API surface. Parameter properties reduce boilerplate while maintaining safety.

### 3.1 Always Use Parentheses in Constructor Calls

**Impact: MEDIUM (consistent syntax and prevents parsing ambiguity)**

Always use parentheses when calling constructors, even when there are no arguments. This improves consistency and prevents potential parsing issues.

**Incorrect (missing parentheses):**

```typescript
const date = new Date
const user = new User
const map = new Map
```

**Correct (with parentheses):**

```typescript
const date = new Date()
const user = new User()
const map = new Map()
const set = new Set<string>()
```

**Why it matters:**
- Consistent with function call syntax
- Avoids ASI (Automatic Semicolon Insertion) edge cases
- Clearer that construction is happening
- Required for generic type arguments

Reference: [Google TypeScript Style Guide - Constructor](https://google.github.io/styleguide/tsguide.html#constructors)

### 3.2 Avoid Container Classes with Only Static Members

**Impact: HIGH (reduces unnecessary abstraction and enables tree-shaking)**

Classes with only static methods add unnecessary indirection. Export functions directly instead for better tree-shaking and simpler code.

**Incorrect (static container class):**

```typescript
class StringUtils {
  static capitalize(str: string): string {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  static truncate(str: string, length: number): string {
    return str.length > length ? str.slice(0, length) + '...' : str
  }

  static isEmpty(str: string): boolean {
    return str.trim().length === 0
  }
}

// Usage
StringUtils.capitalize('hello')
```

**Correct (exported functions):**

```typescript
// string-utils.ts
export function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

export function truncate(str: string, length: number): string {
  return str.length > length ? str.slice(0, length) + '...' : str
}

export function isEmpty(str: string): boolean {
  return str.trim().length === 0
}

// Usage
import { capitalize, truncate } from './string-utils'
capitalize('hello')
```

**Benefits:**
- Better tree-shaking (unused functions removed)
- No class instantiation overhead
- Simpler imports
- Works with function composition

Reference: [Google TypeScript Style Guide - Static methods](https://google.github.io/styleguide/tsguide.html#static-methods)

### 3.3 Mark Properties Readonly When Never Reassigned

**Impact: HIGH (prevents accidental mutations and enables optimizations)**

Properties that are never reassigned outside of the constructor should be marked `readonly` to prevent accidental mutations and communicate intent.

**Incorrect (mutable when not needed):**

```typescript
class User {
  id: string
  name: string
  createdAt: Date

  constructor(id: string, name: string) {
    this.id = id
    this.name = name
    this.createdAt = new Date()
  }

  updateName(name: string) {
    this.name = name
    this.id = 'new-id'  // Bug: accidentally mutated id
  }
}
```

**Correct (readonly for immutable properties):**

```typescript
class User {
  readonly id: string
  name: string  // Only name is mutable
  readonly createdAt: Date

  constructor(id: string, name: string) {
    this.id = id
    this.name = name
    this.createdAt = new Date()
  }

  updateName(name: string) {
    this.name = name
    this.id = 'new-id'  // Error: Cannot assign to 'id' because it is read-only
  }
}
```

**Benefits:**
- Compile-time protection against accidental mutation
- Documents immutability intent
- Enables compiler optimizations
- Safer refactoring

Reference: [Google TypeScript Style Guide - Field initialization](https://google.github.io/styleguide/tsguide.html#field-initialization)

### 3.4 Never Manipulate Prototypes Directly

**Impact: HIGH (prevents VM deoptimization and unpredictable behavior)**

Never modify prototypes directly. It breaks VM optimizations, creates unpredictable behavior, and makes code difficult to understand.

**Incorrect (prototype manipulation):**

```typescript
// Extending built-in prototypes
String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1)
}

// Dynamic prototype modification
function User(name: string) {
  this.name = name
}
User.prototype.greet = function() {
  return `Hello, ${this.name}`
}

// Modifying prototype chain
Object.setPrototypeOf(child, parent)
```

**Correct (use classes or composition):**

```typescript
// Utility function instead of prototype extension
function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

// Class-based inheritance
class User {
  constructor(public name: string) {}

  greet(): string {
    return `Hello, ${this.name}`
  }
}

// Composition for shared behavior
class UserWithLogging {
  constructor(
    private user: User,
    private logger: Logger
  ) {}

  greet(): string {
    this.logger.log('greet called')
    return this.user.greet()
  }
}
```

**Why avoid prototype manipulation:**
- Breaks VM hidden class optimizations
- Pollutes global scope
- Creates maintenance nightmares
- Incompatible with strict mode in some cases

Reference: [Google TypeScript Style Guide - Modifying prototypes](https://google.github.io/styleguide/tsguide.html#disallowed-features)

### 3.5 Use Parameter Properties for Constructor Assignment

**Impact: HIGH (reduces boilerplate by 50%)**

Use parameter properties to combine parameter declaration and property assignment into a single declaration, eliminating boilerplate.

**Incorrect (manual assignment):**

```typescript
class UserService {
  private readonly httpClient: HttpClient
  private readonly logger: Logger
  private readonly config: Config

  constructor(
    httpClient: HttpClient,
    logger: Logger,
    config: Config
  ) {
    this.httpClient = httpClient
    this.logger = logger
    this.config = config
  }
}
```

**Correct (parameter properties):**

```typescript
class UserService {
  constructor(
    private readonly httpClient: HttpClient,
    private readonly logger: Logger,
    private readonly config: Config
  ) {}
}
```

**Rules for parameter properties:**
- Use `private readonly` for dependencies (most common)
- Use `public readonly` for immutable public properties
- Use `protected readonly` for properties needed by subclasses
- Never use `public` without `readonly` (exposes mutable state)

Reference: [Google TypeScript Style Guide - Parameter properties](https://google.github.io/styleguide/tsguide.html#parameter-properties)

### 3.6 Use TypeScript Private Over Private Fields

**Impact: HIGH (consistent access control without runtime overhead)**

Use TypeScript's `private` modifier instead of JavaScript private fields (`#field`). Private fields have runtime costs and interact poorly with TypeScript features.

**Incorrect (JavaScript private fields):**

```typescript
class Counter {
  #count = 0  // JavaScript private field

  increment() {
    this.#count++
  }

  getCount() {
    return this.#count
  }
}
// Compiles to WeakMap usage, adds runtime overhead
// Cannot be accessed in tests, even with type assertions
```

**Correct (TypeScript private modifier):**

```typescript
class Counter {
  private count = 0  // TypeScript private

  increment() {
    this.count++
  }

  getCount() {
    return this.count
  }
}
// No runtime overhead, compile-time enforcement
// Can be accessed in tests via type assertions if needed
```

**Visibility guidelines:**
- Use `private` for internal implementation details
- Use `protected` for subclass-accessible members
- Omit `public` modifier (it's the default)
- Exception: `public readonly` for parameter properties

Reference: [Google TypeScript Style Guide - Private fields](https://google.github.io/styleguide/tsguide.html#private-fields)

---

## 4. Function Patterns

**Impact: HIGH**

Function design affects call overhead, `this` binding, and readability. Prefer declarations over expressions for named functions.

### 4.1 Avoid Rebinding this

**Impact: HIGH (prevents subtle bugs from this binding issues)**

Never use `function()` expressions that access `this`. Never rebind `this` unnecessarily. Use arrow functions or explicit parameters instead.

**Incorrect (this binding issues):**

```typescript
class Counter {
  count = 0

  // Function expression loses this context
  increment() {
    setTimeout(function() {
      this.count++  // this is undefined or wrong
    }, 1000)
  }

  // Unnecessary bind
  setupHandler() {
    button.addEventListener('click', this.handleClick.bind(this))
  }
}
```

**Correct (proper this handling):**

```typescript
class Counter {
  count = 0

  // Arrow function preserves this
  increment() {
    setTimeout(() => {
      this.count++  // this is correctly bound
    }, 1000)
  }

  // Arrow property for event handlers
  handleClick = () => {
    this.count++
  }

  setupHandler() {
    button.addEventListener('click', this.handleClick)
  }
}
```

**Alternative (explicit parameter):**

```typescript
// Pass context explicitly instead of relying on this
function processUser(user: User, logger: Logger) {
  logger.log(user.name)
}

// Instead of
class UserProcessor {
  process() {
    this.logger.log(this.user.name)  // Depends on this binding
  }
}
```

Reference: [Google TypeScript Style Guide - this](https://google.github.io/styleguide/tsguide.html#rebinding-this)

### 4.2 Prefer Function Declarations Over Expressions

**Impact: HIGH (hoisting enables cleaner code organization)**

Use function declarations for named functions. They are hoisted, making code organization more flexible, and provide better stack traces.

**Incorrect (function expression):**

```typescript
// Arrow function stored in const
const calculateTotal = (items: Item[]): number => {
  return items.reduce((sum, item) => sum + item.price, 0)
}

// Anonymous function expression
const formatDate = function(date: Date): string {
  return date.toISOString()
}
```

**Correct (function declaration):**

```typescript
// Function declaration - hoisted, better stack traces
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0)
}

function formatDate(date: Date): string {
  return date.toISOString()
}
```

**When to use arrow functions:**
- Callbacks: `items.map(item => item.price)`
- When explicit typing is needed: `const handler: EventHandler = (e) => {}`
- Preserving `this` context

**When to use function expressions:**
- Conditional function assignment
- Functions passed directly to other functions

Reference: [Google TypeScript Style Guide - Function declarations](https://google.github.io/styleguide/tsguide.html#function-declarations)

### 4.3 Use Concise Arrow Function Bodies Appropriately

**Impact: MEDIUM (improves readability for simple transforms)**

Use concise arrow function bodies (without braces) only when the return value is used. Use block bodies when the return value is ignored or when multiple statements are needed.

**Incorrect (mismatched body style):**

```typescript
// Block body when concise would work
const doubled = numbers.map(n => {
  return n * 2
})

// Concise body when return value is ignored
button.addEventListener('click', e => console.log(e))
// Return value of console.log is ignored but expression returns it
```

**Correct (appropriate body style):**

```typescript
// Concise body when return value is used
const doubled = numbers.map(n => n * 2)
const names = users.map(user => user.name)
const filtered = items.filter(item => item.active)

// Block body when return value is ignored
button.addEventListener('click', (e) => {
  console.log(e)
})

// Block body for multiple statements
const processed = items.map((item) => {
  const normalized = normalize(item)
  return transform(normalized)
})
```

**Using void operator to clarify intent:**

```typescript
// Explicitly discard return value with void
myPromise.then(v => void console.log(v))
// Makes it clear return value is intentionally ignored
```

Reference: [Google TypeScript Style Guide - Arrow function bodies](https://google.github.io/styleguide/tsguide.html#rebinding-this)

### 4.4 Use Correct Generator Function Syntax

**Impact: MEDIUM (consistent, readable generator definitions)**

Attach the `*` to the `function` keyword with no space. For `yield*`, attach to the `yield` keyword. This provides visual consistency.

**Incorrect (inconsistent asterisk placement):**

```typescript
// Space before asterisk
function * generator() {
  yield 1
}

// Asterisk attached to name
function *generator() {
  yield 1
}

// Inconsistent yield* spacing
function* delegate() {
  yield * otherGenerator()
}
```

**Correct (asterisk on keyword):**

```typescript
// Generator function
function* numberGenerator(): Generator<number> {
  yield 1
  yield 2
  yield 3
}

// Delegating generator
function* combined(): Generator<number> {
  yield* numberGenerator()
  yield* [4, 5, 6]
}

// Generator method in class
class DataStream {
  *[Symbol.iterator](): Generator<Data> {
    for (const item of this.items) {
      yield item
    }
  }
}

// Async generator
async function* fetchPages(): AsyncGenerator<Page> {
  let page = 1
  while (true) {
    const data = await fetchPage(page++)
    if (!data) break
    yield data
  }
}
```

Reference: [Google TypeScript Style Guide - Generator functions](https://google.github.io/styleguide/tsguide.html#generator-functions)

### 4.5 Use Default Parameters Sparingly

**Impact: MEDIUM (prevents side effects in parameter defaults)**

Default parameter initializers should be simple values. Avoid side effects, complex expressions, or mutable default values.

**Incorrect (complex or side-effect defaults):**

```typescript
// Side effect in default
function createUser(name: string, id = generateId()) {
  // generateId() called even when id is provided as undefined
}

// Mutable default object
function processConfig(config = { timeout: 5000 }) {
  config.timeout = 10000  // Mutates default object
}

// Complex expression
function calculate(
  value: number,
  multiplier = getGlobalMultiplier() * localFactor
) {}
```

**Correct (simple defaults):**

```typescript
// Simple literal defaults
function createUser(name: string, id?: string) {
  const userId = id ?? generateId()  // Explicit generation
}

// Spread to avoid mutation
function processConfig(config: Partial<Config> = {}) {
  const fullConfig = { timeout: 5000, ...config }
}

// Simple defaults only
function greet(name: string, greeting = 'Hello') {
  return `${greeting}, ${name}`
}

// Optional parameter with explicit handling
function fetchData(url: string, timeout?: number) {
  const actualTimeout = timeout ?? DEFAULT_TIMEOUT
}
```

**Guidelines:**
- Use literals, constants, or simple references
- Avoid function calls in defaults
- Never mutate default values
- Consider optional parameters with explicit handling

Reference: [Google TypeScript Style Guide - Default parameters](https://google.github.io/styleguide/tsguide.html#default-and-rest-parameters)

### 4.6 Use Rest Parameters Over arguments

**Impact: HIGH (type-safe variadic functions)**

Use rest parameters (`...args`) instead of the `arguments` object. Rest parameters are typed, work with arrow functions, and are more intuitive.

**Incorrect (arguments object):**

```typescript
function sum() {
  let total = 0
  for (let i = 0; i < arguments.length; i++) {
    total += arguments[i]  // No type checking
  }
  return total
}

// arguments doesn't work in arrow functions
const multiply = () => {
  return Array.from(arguments).reduce((a, b) => a * b, 1)
  // Error: 'arguments' is not defined
}
```

**Correct (rest parameters):**

```typescript
function sum(...numbers: number[]): number {
  return numbers.reduce((total, n) => total + n, 0)
}

// Works with arrow functions
const multiply = (...numbers: number[]): number => {
  return numbers.reduce((a, b) => a * b, 1)
}

// Typed variadic function
function log(level: string, ...messages: unknown[]): void {
  console.log(`[${level}]`, ...messages)
}
```

**Calling variadic functions with spread:**

```typescript
const values = [1, 2, 3, 4, 5]
const total = sum(...values)  // Spread array into arguments
```

**Never:**
- Name any parameter `arguments`
- Use `Function.prototype.apply()` for variadic calls

Reference: [Google TypeScript Style Guide - Rest parameters](https://google.github.io/styleguide/tsguide.html#rest-and-spread-parameters)

---

## 5. Control Flow

**Impact: MEDIUM-HIGH**

Proper control flow prevents bugs and improves code predictability. Always use braces and triple equals.

### 5.1 Always Include Default Case in Switch

**Impact: MEDIUM (prevents silent failures on unexpected values)**

All switch statements must include a `default` case, even if it's empty. All cases must terminate with `break`, `return`, or throw.

**Incorrect (missing default or fall-through):**

```typescript
function getStatusText(status: number): string {
  switch (status) {
    case 200:
      return 'OK'
    case 404:
      return 'Not Found'
    // Missing default - silent failure on unknown status
  }
}

switch (action) {
  case 'start':
    initialize()
    // Missing break - falls through!
  case 'stop':
    cleanup()
    break
}
```

**Correct (with default and explicit termination):**

```typescript
function getStatusText(status: number): string {
  switch (status) {
    case 200:
      return 'OK'
    case 404:
      return 'Not Found'
    case 500:
      return 'Server Error'
    default:
      return 'Unknown'
  }
}

// Empty default with comment explaining why
switch (knownStatus) {
  case Status.Active:
    activate()
    break
  case Status.Inactive:
    deactivate()
    break
  default:
    // All cases handled, default unreachable
    break
}
```

**Empty case fall-through is allowed:**

```typescript
switch (char) {
  case 'a':
  case 'e':
  case 'i':
  case 'o':
  case 'u':
    return true  // All vowels
  default:
    return false
}
```

Reference: [Google TypeScript Style Guide - Switch statements](https://google.github.io/styleguide/tsguide.html#switch-statements)

### 5.2 Always Use Braces for Control Structures

**Impact: MEDIUM-HIGH (prevents bugs from misleading indentation)**

Always use braces for control structures, even when the body is a single statement. This prevents bugs from misleading indentation.

**Incorrect (missing braces):**

```typescript
if (condition)
  doSomething()
  doSomethingElse()  // Always executes! Misleading indent

for (const item of items)
  process(item)

while (hasMore)
  fetchNext()
```

**Correct (with braces):**

```typescript
if (condition) {
  doSomething()
}
doSomethingElse()

for (const item of items) {
  process(item)
}

while (hasMore) {
  fetchNext()
}
```

**Exception (single-line if):**

```typescript
// Allowed only when entire statement fits on one line
if (isEmpty) return null
if (isReady) start()
```

**Why braces matter:**
- Prevents Apple's "goto fail" style bugs
- Makes code structure explicit
- Safer when adding statements later
- Consistent with other control structures

Reference: [Google TypeScript Style Guide - Control structures](https://google.github.io/styleguide/tsguide.html#control-structures)

### 5.3 Always Use Triple Equals

**Impact: MEDIUM-HIGH (prevents type coercion bugs)**

Always use `===` and `!==` instead of `==` and `!=`. The loose equality operators perform type coercion, leading to unexpected results.

**Incorrect (loose equality):**

```typescript
if (value == null) {
  // Matches both null and undefined - sometimes intentional
}

if (count == '0') {
  // true! Number coerced to string
}

if (arr == false) {
  // Empty array is truthy, but this can be true in edge cases
}
```

**Correct (strict equality):**

```typescript
if (value === null || value === undefined) {
  // Explicit null/undefined check
}

// Or use nullish check when intentional
if (value == null) {  // ONLY exception - checking null OR undefined
  // Clearly checking for both null and undefined
}

if (count === 0) {
  // Type-safe comparison
}

if (arr.length === 0) {
  // Explicit empty array check
}
```

**The only acceptable use of ==:**

```typescript
// Checking for both null and undefined simultaneously
if (value == null) {
  // Equivalent to: value === null || value === undefined
}
```

Reference: [Google TypeScript Style Guide - Equality checks](https://google.github.io/styleguide/tsguide.html#equality-checks)

### 5.4 Avoid Assignment in Conditional Expressions

**Impact: MEDIUM (prevents accidental assignment bugs)**

Never use assignment within conditional expressions. It's difficult to distinguish from comparison and leads to bugs.

**Incorrect (assignment in condition):**

```typescript
// Easy to mistake for comparison
if (user = getUser()) {
  // Is this assignment or typo'd comparison?
}

// Assignment in while condition
while (line = reader.readLine()) {
  process(line)
}
```

**Correct (separate assignment):**

```typescript
// Clear assignment before condition
const user = getUser()
if (user) {
  process(user)
}

// Clear loop structure
let line = reader.readLine()
while (line) {
  process(line)
  line = reader.readLine()
}

// Or use for-of for iterables
for (const line of reader) {
  process(line)
}
```

**Why this matters:**
- `=` vs `==` vs `===` are easy to confuse
- Assignment returns the assigned value (truthy/falsy check)
- Code review becomes harder
- Some linters warn/error on this pattern

Reference: [Google TypeScript Style Guide - Assignment in conditionals](https://google.github.io/styleguide/tsguide.html#assignment-in-control-structures)

### 5.5 Prefer for-of Over for-in for Arrays

**Impact: MEDIUM-HIGH (prevents prototype property enumeration bugs)**

Use `for-of` loops for arrays and iterables. Use `Object.keys()`, `Object.values()`, or `Object.entries()` for objects. Never use unfiltered `for-in`.

**Incorrect (for-in on array):**

```typescript
const items = ['a', 'b', 'c']

for (const i in items) {
  console.log(items[i])  // i is string, enumerates inherited properties
}

// If Array.prototype is extended, this iterates those too
```

**Correct (for-of for arrays):**

```typescript
const items = ['a', 'b', 'c']

// Direct value access
for (const item of items) {
  console.log(item)
}

// When index is needed
for (const [index, item] of items.entries()) {
  console.log(index, item)
}
```

**Correct (Object methods for objects):**

```typescript
const config = { timeout: 5000, retries: 3 }

// Keys only
for (const key of Object.keys(config)) {
  console.log(key)
}

// Values only
for (const value of Object.values(config)) {
  console.log(value)
}

// Key-value pairs
for (const [key, value] of Object.entries(config)) {
  console.log(key, value)
}
```

**If for-in is required, always filter:**

```typescript
for (const key in obj) {
  if (Object.prototype.hasOwnProperty.call(obj, key)) {
    // Safe to use obj[key]
  }
}
```

Reference: [Google TypeScript Style Guide - Iterating objects](https://google.github.io/styleguide/tsguide.html#iterating-objects)

---

## 6. Error Handling

**Impact: MEDIUM**

Consistent error handling enables debugging and prevents silent failures. Always throw Error instances with stack traces.

### 6.1 Always Throw Error Instances

**Impact: MEDIUM (provides stack traces for debugging)**

Always throw `Error` or `Error` subclass instances. Never throw strings, objects, or other primitives. Error instances provide stack traces.

**Incorrect (non-Error throws):**

```typescript
// String - no stack trace
throw 'Something went wrong'

// Object - no stack trace
throw { message: 'Failed', code: 500 }

// Number - no context
throw 404
```

**Correct (Error instances):**

```typescript
// Standard Error
throw new Error('Something went wrong')

// Built-in error types
throw new TypeError('Expected string, got number')
throw new RangeError('Index out of bounds')

// Custom error class
class ValidationError extends Error {
  constructor(
    message: string,
    public readonly field: string
  ) {
    super(message)
    this.name = 'ValidationError'
  }
}

throw new ValidationError('Invalid email format', 'email')
```

**Catching unknown errors:**

```typescript
try {
  riskyOperation()
} catch (e: unknown) {
  // Always catch as unknown
  if (e instanceof Error) {
    console.error(e.message, e.stack)
  } else {
    // Handle non-Error throws from third-party code
    throw new Error(`Unexpected error: ${String(e)}`)
  }
}
```

Reference: [Google TypeScript Style Guide - Exceptions](https://google.github.io/styleguide/tsguide.html#exceptions)

### 6.2 Avoid Type and Non-Null Assertions

**Impact: MEDIUM (prevents hiding type errors)**

Minimize use of type assertions (`as`) and non-null assertions (`!`). They suppress compiler checks and can hide real bugs.

**Incorrect (unnecessary assertions):**

```typescript
// Non-null assertion hiding potential bug
const name = user!.name  // What if user is null?

// Type assertion without validation
const data = response as UserData  // What if response shape is wrong?

// Double assertion (especially dangerous)
const element = unknownValue as unknown as HTMLElement
```

**Correct (runtime checks or proper typing):**

```typescript
// Runtime check instead of assertion
if (!user) {
  throw new Error('User is required')
}
const name = user.name  // TypeScript knows user is not null

// Type guard for validation
function isUserData(value: unknown): value is UserData {
  return (
    typeof value === 'object' &&
    value !== null &&
    'name' in value &&
    'email' in value
  )
}

if (!isUserData(response)) {
  throw new Error('Invalid user data')
}
const data = response  // Properly typed

// Explicit annotation instead of assertion
const config: Config = { timeout: 5000, retries: 3 }
```

**When assertions are acceptable:**

```typescript
// With explanatory comment
const element = document.getElementById('app')
// Element exists because we control the HTML
const root = element as HTMLElement
```

Reference: [Google TypeScript Style Guide - Type assertions](https://google.github.io/styleguide/tsguide.html#type-assertions)

### 6.3 Document Empty Catch Blocks

**Impact: MEDIUM (explains intentional error suppression)**

Empty catch blocks are allowed only with comments explaining why the error is intentionally suppressed.

**Incorrect (unexplained empty catch):**

```typescript
try {
  parseJSON(input)
} catch (e) {
  // Silent failure - why?
}

try {
  await deleteFile(path)
} catch {
  // What errors are we ignoring?
}
```

**Correct (documented empty catch):**

```typescript
try {
  cachedValue = parseJSON(localStorage.getItem('cache'))
} catch (e: unknown) {
  // Cache may be corrupted or missing; continue with empty cache
}

try {
  await deleteFile(tempPath)
} catch (e: unknown) {
  // File may already be deleted; safe to ignore
}

// Alternative: explicit fallback
let config: Config
try {
  config = parseConfig(rawInput)
} catch (e: unknown) {
  // Invalid config format; use defaults
  config = DEFAULT_CONFIG
}
```

**When empty catch is appropriate:**
- Optional cleanup operations
- Cache operations that can fail silently
- Fallback to default behavior
- Operations where failure is expected and handled elsewhere

**When NOT to use empty catch:**
- Critical operations
- User-facing errors
- Debugging/development

Reference: [Google TypeScript Style Guide - Empty catch blocks](https://google.github.io/styleguide/tsguide.html#exceptions)

### 6.4 Type Catch Clause Variables as Unknown

**Impact: MEDIUM (enforces safe error handling)**

Always type catch clause variables as `unknown` and narrow before use. This prevents accessing properties that may not exist.

**Incorrect (assuming Error type):**

```typescript
try {
  await fetchData()
} catch (e) {
  // e is implicitly 'any' or 'unknown'
  console.log(e.message)  // Might not have message property
  console.log(e.stack)    // Might not have stack property
}
```

**Correct (explicit unknown with narrowing):**

```typescript
try {
  await fetchData()
} catch (e: unknown) {
  // Type guard to safely access Error properties
  if (e instanceof Error) {
    console.error(e.message)
    console.error(e.stack)
  } else {
    // Handle unexpected throw types
    console.error('Unknown error:', String(e))
  }
}
```

**Helper function for error handling:**

```typescript
function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message
  }
  if (typeof error === 'string') {
    return error
  }
  return 'Unknown error occurred'
}

try {
  riskyOperation()
} catch (e: unknown) {
  console.error(getErrorMessage(e))
}
```

Reference: [Google TypeScript Style Guide - Exception handling](https://google.github.io/styleguide/tsguide.html#exceptions)

---

## 7. Naming & Style

**Impact: MEDIUM**

Consistent naming improves readability and tooling support. Use descriptive names and follow case conventions.

### 7.1 Avoid Decorative Underscores

**Impact: MEDIUM (cleaner code without misleading conventions)**

Never use leading or trailing underscores for identifiers. Use TypeScript's `private` modifier for private members instead.

**Incorrect (decorative underscores):**

```typescript
class UserService {
  _users: User[] = []  // Leading underscore for "private"
  __internalState = {}  // Double underscore
  users_ = []  // Trailing underscore

  _loadUsers() {
    // Leading underscore for "private" method
  }
}

// Underscore prefix for unused variables
function process(_unused: string, value: number) {
  return value * 2
}
```

**Correct (TypeScript modifiers):**

```typescript
class UserService {
  private users: User[] = []
  private internalState = {}

  private loadUsers() {
    // Truly private with TypeScript
  }
}

// Omit unused parameters or use explicit void
function process(value: number) {
  return value * 2
}

// Or use void for required unused params
function callback(_event: Event) {
  // Parameter required by signature but unused
  void _event  // Explicit acknowledgment
}
```

**Exception - external API requirements:**

```typescript
// Some external libraries require specific naming
interface WindowWithGlobals extends Window {
  __REDUX_DEVTOOLS_EXTENSION__?: DevToolsExtension
}
```

Reference: [Google TypeScript Style Guide - Naming conventions](https://google.github.io/styleguide/tsguide.html#naming-style)

### 7.2 No I Prefix for Interfaces

**Impact: MEDIUM (cleaner type names without Hungarian notation)**

Never prefix interface names with `I` or suffix with `Interface`. TypeScript's structural typing makes these markers unnecessary.

**Incorrect (Hungarian notation):**

```typescript
interface IUser {
  name: string
  email: string
}

interface IUserService {
  getUser(id: string): IUser
}

interface UserInterface {
  name: string
}

// Leads to awkward usage
function processUser(user: IUser): void {}
```

**Correct (clean names):**

```typescript
interface User {
  name: string
  email: string
}

interface UserService {
  getUser(id: string): User
}

// Clean usage
function processUser(user: User): void {}

// Class implementing interface
class DefaultUserService implements UserService {
  getUser(id: string): User {
    return { name: 'Alice', email: 'alice@example.com' }
  }
}
```

**Why avoid prefixes:**
- TypeScript uses structural typing, not nominal
- Interfaces and types are interchangeable in many contexts
- Prefixes add noise without value
- Modern IDEs show type information on hover

Reference: [Google TypeScript Style Guide - Naming conventions](https://google.github.io/styleguide/tsguide.html#naming-style)

### 7.3 Use CONSTANT_CASE for True Constants

**Impact: MEDIUM (distinguishes immutable values from variables)**

Use `CONSTANT_CASE` only for deeply immutable values at module scope or as static readonly class properties. Local constants use `lowerCamelCase`.

**Incorrect (wrong case for scope):**

```typescript
// Local variable shouldn't be CONSTANT_CASE
function calculate() {
  const MAX_VALUE = 100  // This is a local const
  return MAX_VALUE * 2
}

// Mutable object in CONSTANT_CASE
const DEFAULT_CONFIG = {
  timeout: 5000,
  retries: 3,
}
DEFAULT_CONFIG.timeout = 10000  // Mutated!
```

**Correct (appropriate case):**

```typescript
// Module-level true constants
const MAX_RETRY_COUNT = 3
const API_BASE_URL = 'https://api.example.com'
const HTTP_STATUS_OK = 200

// Immutable object constant
const DEFAULT_CONFIG = {
  timeout: 5000,
  retries: 3,
} as const  // Truly immutable

// Local constants use camelCase
function calculate() {
  const maxValue = 100
  return maxValue * 2
}

// Class static readonly
class HttpClient {
  static readonly DEFAULT_TIMEOUT = 5000
  static readonly MAX_RETRIES = 3
}
```

**CONSTANT_CASE requirements:**
- Module-level or static readonly
- Deeply immutable (primitives or `as const`)
- Never reassigned
- Represents a true constant value, not just a `const` binding

Reference: [Google TypeScript Style Guide - Constants](https://google.github.io/styleguide/tsguide.html#constants)

### 7.4 Use Correct Identifier Naming Styles

**Impact: MEDIUM (improves code readability and consistency)**

Follow consistent naming conventions based on identifier type. This improves readability and makes code intent clear.

**Naming conventions:**

| Style | Usage |
|-------|-------|
| `UpperCamelCase` | Classes, interfaces, types, enums, decorators, type parameters |
| `lowerCamelCase` | Variables, parameters, functions, methods, properties, module aliases |
| `CONSTANT_CASE` | Global constants, enum values, static readonly properties |

**Incorrect (wrong case for identifier type):**

```typescript
// Wrong case for type
interface user_data {
  user_name: string
}

// Wrong case for constant
const maxRetries = 3

// Wrong case for class
class userService {}

// Leading underscore for "private"
const _internalValue = 42
```

**Correct (proper case by identifier type):**

```typescript
// Interface - UpperCamelCase
interface UserData {
  userName: string
}

// Global constant - CONSTANT_CASE
const MAX_RETRIES = 3

// Class - UpperCamelCase
class UserService {}

// Variable - lowerCamelCase
const internalValue = 42

// Enum - UpperCamelCase with CONSTANT_CASE values
enum HttpStatus {
  OK = 200,
  NOT_FOUND = 404,
  INTERNAL_ERROR = 500,
}
```

**Treat acronyms as words:**

```typescript
// Correct
loadHttpUrl()
parseXmlDocument()
class HtmlParser {}

// Incorrect
loadHTTPURL()
parseXMLDocument()
class HTMLParser {}
```

Reference: [Google TypeScript Style Guide - Naming style](https://google.github.io/styleguide/tsguide.html#naming-style)

### 7.5 Use Descriptive Names

**Impact: MEDIUM (improves code maintainability)**

Use descriptive names that clearly communicate purpose. Avoid ambiguous abbreviations. Short names are acceptable only in very limited scopes.

**Incorrect (ambiguous or abbreviated):**

```typescript
// Unclear abbreviations
const usr = getUser()
const cfg = loadConfig()
const btn = document.querySelector('button')

// Single letters in wide scope
function processData(d: Data) {
  const r = transform(d)
  return format(r)
}

// Meaningless names
const temp = calculateValue()
const data = fetchData()  // What kind of data?
```

**Correct (descriptive):**

```typescript
// Clear, full words
const currentUser = getUser()
const appConfig = loadConfig()
const submitButton = document.querySelector('button')

// Descriptive names
function processUserData(userData: UserData) {
  const transformedData = transform(userData)
  return format(transformedData)
}

// Specific names
const discountedPrice = calculateDiscountedPrice()
const userPreferences = fetchUserPreferences()
```

**When short names are acceptable:**

```typescript
// Very limited scope (≤10 lines)
users.map(u => u.name)
items.filter(x => x.active)

// Conventional loop variables
for (let i = 0; i < count; i++) {}

// Mathematical/domain conventions
const x = point.x
const y = point.y
```

Reference: [Google TypeScript Style Guide - Descriptive names](https://google.github.io/styleguide/tsguide.html#descriptive-names)

---

## 8. Literals & Coercion

**Impact: LOW-MEDIUM**

Proper literal usage prevents type coercion bugs. Use explicit coercion functions instead of implicit coercion.

### 8.1 Avoid Array Constructor

**Impact: LOW-MEDIUM (prevents confusing Array constructor behavior)**

Never use the `Array()` constructor. Its behavior is confusing (single number creates sparse array). Use array literals or `Array.from()`.

**Incorrect (Array constructor):**

```typescript
// Single number creates sparse array of that length
const arr = new Array(3)  // [empty × 3], not [3]

// Multiple arguments create array with those elements
const arr2 = new Array(1, 2, 3)  // [1, 2, 3]

// Inconsistent behavior is confusing
const a = Array(3)      // [empty × 3]
const b = Array('3')    // ['3']
```

**Correct (array literals and Array.from):**

```typescript
// Array literals
const empty: number[] = []
const numbers = [1, 2, 3]
const strings = ['a', 'b', 'c']

// Array.from for creating arrays with specific length
const fiveZeros = Array.from({ length: 5 }, () => 0)  // [0, 0, 0, 0, 0]
const indices = Array.from({ length: 5 }, (_, i) => i)  // [0, 1, 2, 3, 4]

// Array.from with typed generics
const typed = Array.from<number>({ length: 3 })  // [undefined, undefined, undefined]

// Spread for copying
const copy = [...original]

// fill() for same value
const threes = new Array(5).fill(3)  // [3, 3, 3, 3, 3] - fill() makes it dense
```

**Object constructor also forbidden:**

```typescript
// Incorrect
const obj = new Object()
const obj2 = Object()

// Correct
const obj = {}
const obj2: Record<string, unknown> = {}
```

Reference: [Google TypeScript Style Guide - Array constructor](https://google.github.io/styleguide/tsguide.html#array-constructor)

### 8.2 Use Correct Number Literal Formats

**Impact: LOW-MEDIUM (consistent and readable numeric literals)**

Use lowercase prefixes for non-decimal numbers. Never use leading zeros for decimal numbers. Use underscores for readability in long numbers.

**Incorrect (inconsistent or hard-to-read formats):**

```typescript
// Uppercase prefix
const hex = 0XABC

// Leading zero (looks like octal in some languages)
const port = 0080

// Hard to read large numbers
const billion = 1000000000
```

**Correct (consistent lowercase prefixes):**

```typescript
// Hexadecimal - lowercase 0x
const hexColor = 0xffffff
const permissions = 0x755

// Binary - lowercase 0b
const flags = 0b1010
const mask = 0b11110000

// Octal - lowercase 0o
const fileMode = 0o755

// Decimal - no leading zeros
const port = 80
const count = 42

// Underscores for readability (ES2021+)
const billion = 1_000_000_000
const bytes = 0xff_ff_ff_ff
const binary = 0b1111_0000_1111_0000
```

**Numeric parsing:**

```typescript
// Use Number() for parsing
const parsed = Number(input)
if (!Number.isFinite(parsed)) {
  throw new Error('Invalid number')
}

// Never use parseInt without radix (except radix 10)
const decimal = Number(str)  // Preferred
const hex = parseInt(hexStr, 16)  // When radix needed
```

Reference: [Google TypeScript Style Guide - Number literals](https://google.github.io/styleguide/tsguide.html#number-literals)

### 8.3 Use Explicit Type Coercion

**Impact: LOW-MEDIUM (prevents unexpected coercion behavior)**

Use explicit coercion functions (`String()`, `Number()`, `Boolean()`) instead of implicit coercion or unary operators.

**Incorrect (implicit coercion):**

```typescript
// Unary + for number coercion
const num = +inputString

// String concatenation for coercion
const str = '' + value

// Double negation for boolean
const bool = !!value

// parseInt without validation
const parsed = parseInt(input)
```

**Correct (explicit coercion):**

```typescript
// Explicit String coercion
const str = String(value)

// Explicit Number coercion with validation
const num = Number(inputString)
if (!Number.isFinite(num)) {
  throw new Error('Invalid number')
}

// Explicit Boolean coercion
const bool = Boolean(value)

// Template literal for string conversion
const message = `Value: ${value}`
```

**Implicit coercion allowed in conditionals:**

```typescript
// Truthy/falsy checks are acceptable
if (array.length) {
  // Non-empty array
}

if (str) {
  // Non-empty string
}

// Exception: enums require explicit comparison
enum Status {
  NONE = 0,
  ACTIVE = 1,
}

// Incorrect - implicit coercion of enum
if (status) {}  // NONE (0) is falsy!

// Correct - explicit comparison
if (status !== Status.NONE) {}
```

Reference: [Google TypeScript Style Guide - Type coercion](https://google.github.io/styleguide/tsguide.html#type-coercion)

### 8.4 Use Single Quotes for Strings

**Impact: LOW-MEDIUM (consistent string syntax throughout codebase)**

Use single quotes for ordinary string literals. Use template literals for strings that contain interpolation or span multiple lines.

**Incorrect (double quotes and concatenation):**

```typescript
// Double quotes for ordinary strings
const name = "Alice"
const message = "Hello, world"

// String concatenation instead of template
const greeting = "Hello, " + name + "!"

// Line continuation with backslash
const longString = "This is a very long \
string that continues"
```

**Correct (single quotes and template literals):**

```typescript
// Single quotes for ordinary strings
const name = 'Alice'
const message = 'Hello, world'

// Template literal for interpolation
const greeting = `Hello, ${name}!`

// Template literal for multi-line
const longString = `
  This is a very long
  string that spans
  multiple lines
`

// Single quotes with escaping when needed
const quote = 'She said, "Hello"'
const apostrophe = "It's working"  // Double quotes to avoid escaping
```

**When to use template literals:**
- String interpolation: `\`Hello, ${name}\``
- Multi-line strings
- Complex string building

Reference: [Google TypeScript Style Guide - String literals](https://google.github.io/styleguide/tsguide.html#string-literals)

---

## References

1. [https://google.github.io/styleguide/tsguide.html](https://google.github.io/styleguide/tsguide.html)
2. [https://www.typescriptlang.org/docs/handbook/](https://www.typescriptlang.org/docs/handbook/)
3. [https://google.github.io/styleguide/jsguide.html](https://google.github.io/styleguide/jsguide.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |