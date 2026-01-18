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

1. [Module System & Imports](#1-module-system-imports) — **CRITICAL**
   - 1.1 [Avoid Circular Dependencies](#11-avoid-circular-dependencies)
   - 1.2 [Avoid Duplicate Import Statements](#12-avoid-duplicate-import-statements)
   - 1.3 [Avoid Unnecessary Import Aliasing](#13-avoid-unnecessary-import-aliasing)
   - 1.4 [Follow Source File Structure Order](#14-follow-source-file-structure-order)
   - 1.5 [Include File Extension in Import Paths](#15-include-file-extension-in-import-paths)
   - 1.6 [Prefer Named Exports Over Default Exports](#16-prefer-named-exports-over-default-exports)
2. [Language Features](#2-language-features) — **CRITICAL**
   - 2.1 [Always Use Explicit Semicolons](#21-always-use-explicit-semicolons)
   - 2.2 [Never Modify Built-in Prototypes](#22-never-modify-built-in-prototypes)
   - 2.3 [Never Use eval or Function Constructor](#23-never-use-eval-or-function-constructor)
   - 2.4 [Never Use Primitive Wrapper Objects](#24-never-use-primitive-wrapper-objects)
   - 2.5 [Never Use the with Statement](#25-never-use-the-with-statement)
   - 2.6 [Use const by Default, let When Needed, Never var](#26-use-const-by-default-let-when-needed-never-var)
   - 2.7 [Use ES6 Classes Over Prototype Manipulation](#27-use-es6-classes-over-prototype-manipulation)
   - 2.8 [Use Only Standard ECMAScript Features](#28-use-only-standard-ecmascript-features)
3. [Type Safety & JSDoc](#3-type-safety-jsdoc) — **HIGH**
   - 3.1 [Always Specify Template Parameters](#31-always-specify-template-parameters)
   - 3.2 [Annotate Enums with Static Literal Values](#32-annotate-enums-with-static-literal-values)
   - 3.3 [Require JSDoc for All Exported Functions](#33-require-jsdoc-for-all-exported-functions)
   - 3.4 [Use Explicit Nullability Modifiers](#34-use-explicit-nullability-modifiers)
   - 3.5 [Use Parentheses for Type Casts](#35-use-parentheses-for-type-casts)
   - 3.6 [Use typedef for Complex Object Types](#36-use-typedef-for-complex-object-types)
4. [Naming Conventions](#4-naming-conventions) — **HIGH**
   - 4.1 [Avoid Dollar Sign Prefix in Identifiers](#41-avoid-dollar-sign-prefix-in-identifiers)
   - 4.2 [Prefer Descriptive Names Over Brevity](#42-prefer-descriptive-names-over-brevity)
   - 4.3 [Use CONSTANT_CASE for Deeply Immutable Values](#43-use-constantcase-for-deeply-immutable-values)
   - 4.4 [Use lowerCamelCase for Methods and Variables](#44-use-lowercamelcase-for-methods-and-variables)
   - 4.5 [Use Lowercase with Dashes or Underscores for Files](#45-use-lowercase-with-dashes-or-underscores-for-files)
   - 4.6 [Use UpperCamelCase for Classes and Constructors](#46-use-uppercamelcase-for-classes-and-constructors)
5. [Control Flow & Error Handling](#5-control-flow-error-handling) — **MEDIUM-HIGH**
   - 5.1 [Always Include Default Case in Switch Statements](#51-always-include-default-case-in-switch-statements)
   - 5.2 [Always Throw Error Objects, Not Primitives](#52-always-throw-error-objects-not-primitives)
   - 5.3 [Document Empty Catch Blocks](#53-document-empty-catch-blocks)
   - 5.4 [Prefer for-of Over for-in for Iteration](#54-prefer-for-of-over-for-in-for-iteration)
   - 5.5 [Use Strict Equality Except for Null Checks](#55-use-strict-equality-except-for-null-checks)
6. [Functions & Parameters](#6-functions-parameters) — **MEDIUM**
   - 6.1 [Always Use Parentheses Around Arrow Function Parameters](#61-always-use-parentheses-around-arrow-function-parameters)
   - 6.2 [Prefer Arrow Functions for Nested Functions](#62-prefer-arrow-functions-for-nested-functions)
   - 6.3 [Use Default Parameters Instead of Conditional Assignment](#63-use-default-parameters-instead-of-conditional-assignment)
   - 6.4 [Use Rest Parameters Instead of arguments Object](#64-use-rest-parameters-instead-of-arguments-object)
   - 6.5 [Use Spread Operator Instead of Function.apply](#65-use-spread-operator-instead-of-functionapply)
7. [Objects & Arrays](#7-objects-arrays) — **MEDIUM**
   - 7.1 [Never Mix Quoted and Unquoted Object Keys](#71-never-mix-quoted-and-unquoted-object-keys)
   - 7.2 [Use Array Literals Instead of Array Constructor](#72-use-array-literals-instead-of-array-constructor)
   - 7.3 [Use Destructuring for Multiple Property Access](#73-use-destructuring-for-multiple-property-access)
   - 7.4 [Use Object Literals Instead of Object Constructor](#74-use-object-literals-instead-of-object-constructor)
   - 7.5 [Use Spread Over concat and slice](#75-use-spread-over-concat-and-slice)
   - 7.6 [Use Trailing Commas in Multi-line Literals](#76-use-trailing-commas-in-multi-line-literals)
8. [Formatting & Style](#8-formatting-style) — **LOW**
   - 8.1 [Always Use Braces for Control Structures](#81-always-use-braces-for-control-structures)
   - 8.2 [Limit Lines to 80 Characters](#82-limit-lines-to-80-characters)
   - 8.3 [Place One Statement Per Line](#83-place-one-statement-per-line)
   - 8.4 [Use Single Quotes for String Literals](#84-use-single-quotes-for-string-literals)
   - 8.5 [Use Two-Space Indentation](#85-use-two-space-indentation)

---

## 1. Module System & Imports

**Impact: CRITICAL**

Module structure, import ordering, and dependency management prevent loading failures and circular dependencies that break applications.

### 1.1 Avoid Circular Dependencies

**Impact: CRITICAL (prevents loading failures and undefined imports)**

Circular dependencies between ES modules cause one module to receive an incomplete export object, leading to undefined values and runtime errors that are difficult to debug.

**Incorrect (circular dependency causes undefined):**

```javascript
// userService.js
import { formatUser } from './userFormatter.js';

export function getUser(userId) {
  const user = database.findUser(userId);
  return formatUser(user);
}

// userFormatter.js
import { getUser } from './userService.js';  // Circular!

export function formatUser(user) {
  const manager = getUser(user.managerId);  // getUser is undefined here
  return { ...user, managerName: manager?.name };
}
```

**Correct (dependency extracted to shared module):**

```javascript
// userService.js
import { formatUser } from './userFormatter.js';

export function getUser(userId) {
  const user = database.findUser(userId);
  return formatUser(user);
}

// userFormatter.js
import { findUser } from './database.js';  // Direct dependency

export function formatUser(user) {
  const manager = findUser(user.managerId);
  return { ...user, managerName: manager?.name };
}
```

**When NOT to use this pattern:**
- CommonJS modules with dynamic `require()` may tolerate some circular refs
- Type-only imports in TypeScript don't cause runtime circular deps

Reference: [Google JavaScript Style Guide - ES modules](https://google.github.io/styleguide/jsguide.html#source-file-structure)

### 1.2 Avoid Duplicate Import Statements

**Impact: HIGH (reduces confusion and bundle overhead)**

Import from the same file only once. Multiple import statements for the same module create confusion and may cause subtle ordering issues with side effects.

**Incorrect (multiple imports from same module):**

```javascript
import { fetchUser } from './api/userApi.js';
import { UserRole } from './api/userApi.js';
import { validatePermissions } from './api/userApi.js';

export async function loadAdminUser(userId) {
  const user = await fetchUser(userId);
  if (user.role !== UserRole.ADMIN) {
    throw new Error('Not an admin');
  }
  validatePermissions(user);
  return user;
}
```

**Correct (single consolidated import):**

```javascript
import { fetchUser, UserRole, validatePermissions } from './api/userApi.js';

export async function loadAdminUser(userId) {
  const user = await fetchUser(userId);
  if (user.role !== UserRole.ADMIN) {
    throw new Error('Not an admin');
  }
  validatePermissions(user);
  return user;
}
```

**Alternative (namespace import for many exports):**

```javascript
import * as userApi from './api/userApi.js';

export async function loadAdminUser(userId) {
  const user = await userApi.fetchUser(userId);
  if (user.role !== userApi.UserRole.ADMIN) {
    throw new Error('Not an admin');
  }
  userApi.validatePermissions(user);
  return user;
}
```

Reference: [Google JavaScript Style Guide - ES module imports](https://google.github.io/styleguide/jsguide.html#es-module-imports)

### 1.3 Avoid Unnecessary Import Aliasing

**Impact: HIGH (maintains searchability and code comprehension)**

Keep original export names when importing. Aliasing creates a mental mapping burden and breaks global search/replace refactoring.

**Incorrect (unnecessary aliasing obscures origin):**

```javascript
import {
  OrderStatus as Status,
  createOrder as makeOrder,
  validateOrder as checkOrder
} from './orderService.js';

export function processNewOrder(items) {
  const order = makeOrder(items);  // What is makeOrder?
  checkOrder(order);
  return order.status === Status.PENDING;
}
```

**Correct (preserves original names):**

```javascript
import {
  OrderStatus,
  createOrder,
  validateOrder
} from './orderService.js';

export function processNewOrder(items) {
  const order = createOrder(items);  // Clear origin
  validateOrder(order);
  return order.status === OrderStatus.PENDING;
}
```

**When aliasing IS appropriate:**
- Name collisions between imports from different modules
- Adapting third-party API names to codebase conventions

```javascript
// Collision requires aliasing
import { Button as MuiButton } from '@mui/material';
import { Button as CustomButton } from './components/Button.js';
```

Reference: [Google JavaScript Style Guide - Naming imports](https://google.github.io/styleguide/jsguide.html#naming-module-local-names)

### 1.4 Follow Source File Structure Order

**Impact: HIGH (improves navigability and prevents declaration errors)**

Source files must follow a consistent structure: license/copyright, file overview, imports, then implementation. Mixing these sections causes confusion and potential hoisting issues.

**Incorrect (mixed structure):**

```javascript
import { logger } from './utils/logger.js';

const MAX_RETRIES = 3;

import { fetchData } from './api/client.js';  // Import after code

/**
 * @fileoverview Handles data synchronization.
 */

export async function syncData(endpoint) {
  for (let i = 0; i < MAX_RETRIES; i++) {
    try {
      return await fetchData(endpoint);
    } catch (error) {
      logger.warn(`Retry ${i + 1} failed`);
    }
  }
}
```

**Correct (proper structure order):**

```javascript
/**
 * @fileoverview Handles data synchronization.
 */

import { fetchData } from './api/client.js';
import { logger } from './utils/logger.js';

const MAX_RETRIES = 3;

export async function syncData(endpoint) {
  for (let i = 0; i < MAX_RETRIES; i++) {
    try {
      return await fetchData(endpoint);
    } catch (error) {
      logger.warn(`Retry ${i + 1} failed`);
    }
  }
}
```

**Structure order:**
1. License/copyright (if applicable)
2. `@fileoverview` JSDoc
3. All import statements
4. Constants and implementation code

Reference: [Google JavaScript Style Guide - Source file structure](https://google.github.io/styleguide/jsguide.html#source-file-structure)

### 1.5 Include File Extension in Import Paths

**Impact: CRITICAL (prevents module resolution failures)**

ES module import paths must include the `.js` file extension. Omitting extensions causes resolution failures in browsers and strict ESM environments.

**Incorrect (missing file extension):**

```javascript
// main.js
import { validateEmail } from './validators';  // Fails in browser ESM
import { formatDate } from './utils/dateFormatter';

export function processUserInput(email, date) {
  if (!validateEmail(email)) {
    throw new Error('Invalid email');
  }
  return formatDate(date);
}
```

**Correct (explicit file extensions):**

```javascript
// main.js
import { validateEmail } from './validators.js';
import { formatDate } from './utils/dateFormatter.js';

export function processUserInput(email, date) {
  if (!validateEmail(email)) {
    throw new Error('Invalid email');
  }
  return formatDate(date);
}
```

**Note:** Some bundlers (webpack, Vite) auto-resolve extensions during build, but native ESM and Closure Compiler require explicit extensions.

Reference: [Google JavaScript Style Guide - ES module imports](https://google.github.io/styleguide/jsguide.html#es-module-imports)

### 1.6 Prefer Named Exports Over Default Exports

**Impact: CRITICAL (enables better refactoring and prevents import inconsistencies)**

Named exports enforce consistent import names across the codebase, enable IDE auto-imports, and make refactoring safer. Default exports allow arbitrary local names that diverge over time.

**Incorrect (default export allows naming drift):**

```javascript
// userService.js
export default class UserService {
  async fetchUser(userId) {
    return await api.get(`/users/${userId}`);
  }
}

// component.js
import UserSvc from './userService.js';  // Arbitrary name

// anotherFile.js
import UsrService from './userService.js';  // Different name, same thing
```

**Correct (named export enforces consistency):**

```javascript
// userService.js
export class UserService {
  async fetchUser(userId) {
    return await api.get(`/users/${userId}`);
  }
}

// component.js
import { UserService } from './userService.js';

// anotherFile.js
import { UserService } from './userService.js';  // Same name everywhere
```

**Alternative (aliasing when needed):**

```javascript
import { UserService as AdminUserService } from './userService.js';
```

**When to use default exports:**
- When interoperating with libraries that expect default exports
- Single-export modules where the filename is descriptive (e.g., `Button.js`)

Reference: [Google JavaScript Style Guide - Named vs default exports](https://google.github.io/styleguide/jsguide.html#es-module-exports)

---

## 2. Language Features

**Impact: CRITICAL**

Proper use of modern JS features (const/let, classes, arrow functions) prevents subtle bugs, improves reliability, and enables tooling optimization.

### 2.1 Always Use Explicit Semicolons

**Impact: HIGH (prevents ASI-related parsing errors)**

Always terminate statements with semicolons. Relying on Automatic Semicolon Insertion (ASI) causes subtle parsing errors, especially with line-starting parentheses, brackets, or template literals.

**Incorrect (ASI causes unexpected behavior):**

```javascript
const getUser = () => ({ name: 'Alice' })
const processUser = (user) => console.log(user)

// ASI fails here - parsed as getUser()(processUser)
const user = getUser()
(processUser)(user)

// Another ASI pitfall
const message = 'Hello'
['error', 'warn'].forEach(level => console[level](message))
// Parsed as: 'Hello'['error', 'warn'].forEach(...)
```

**Correct (explicit semicolons):**

```javascript
const getUser = () => ({ name: 'Alice' });
const processUser = (user) => console.log(user);

const user = getUser();
processUser(user);

const message = 'Hello';
['error', 'warn'].forEach(level => console[level](message));
```

**Dangerous line starters:**
- `(` - parenthesis
- `[` - bracket
- `` ` `` - template literal
- `/` - regex or division
- `+` or `-` - unary operators

Reference: [Google JavaScript Style Guide - Semicolons are required](https://google.github.io/styleguide/jsguide.html#formatting-semicolons-are-required)

### 2.2 Never Modify Built-in Prototypes

**Impact: CRITICAL (prevents global conflicts and breaking changes)**

Never add, modify, or delete properties from built-in object prototypes. This causes conflicts between libraries and breaks future ECMAScript compatibility.

**Incorrect (modifying Array prototype):**

```javascript
// Adding custom method to Array prototype
Array.prototype.first = function() {
  return this[0];
};

Array.prototype.last = function() {
  return this[this.length - 1];
};

const orders = [{ id: 1 }, { id: 2 }, { id: 3 }];
console.log(orders.first().id);  // Works but pollutes global
```

**Correct (standalone utility functions):**

```javascript
function first(array) {
  return array[0];
}

function last(array) {
  return array[array.length - 1];
}

const orders = [{ id: 1 }, { id: 2 }, { id: 3 }];
console.log(first(orders).id);  // Explicit, no global pollution
```

**Alternative (class extension for custom types):**

```javascript
class OrderList extends Array {
  first() {
    return this[0];
  }

  last() {
    return this[this.length - 1];
  }
}

const orders = OrderList.from([{ id: 1 }, { id: 2 }]);
console.log(orders.first().id);
```

**Why this matters:**
- Future JS versions may add conflicting methods
- Other libraries may have different implementations
- Polyfills may behave unexpectedly

Reference: [Google JavaScript Style Guide - Modifying builtin objects](https://google.github.io/styleguide/jsguide.html#disallowed-features-modifying-builtin-objects)

### 2.3 Never Use eval or Function Constructor

**Impact: CRITICAL (prevents code injection and CSP violations)**

Dynamic code evaluation with `eval()` or `new Function()` creates security vulnerabilities, breaks static analysis, and violates Content Security Policy. Use safer alternatives.

**Incorrect (eval enables code injection):**

```javascript
function calculateDiscount(formula, price) {
  // User-controlled formula can execute arbitrary code
  return eval(formula.replace('price', price));
}

function createHandler(bodyCode) {
  // Dynamic function creation, same security issues
  return new Function('event', bodyCode);
}

const discount = calculateDiscount('price * 0.1; alert("hacked")', 100);
```

**Correct (safe alternatives):**

```javascript
const DISCOUNT_STRATEGIES = {
  percentage: (price, value) => price * value,
  fixed: (price, value) => Math.max(0, price - value),
  bogo: (price) => price / 2,
};

function calculateDiscount(strategyName, price, value) {
  const strategy = DISCOUNT_STRATEGIES[strategyName];
  if (!strategy) {
    throw new Error(`Unknown discount strategy: ${strategyName}`);
  }
  return strategy(price, value);
}

const discount = calculateDiscount('percentage', 100, 0.1);  // 10
```

**Alternative (JSON for data parsing):**

```javascript
// Instead of eval(jsonString)
const data = JSON.parse(jsonString);
```

Reference: [Google JavaScript Style Guide - Disallowed features](https://google.github.io/styleguide/jsguide.html#disallowed-features-code-not-in-strict-mode)

### 2.4 Never Use Primitive Wrapper Objects

**Impact: CRITICAL (prevents type confusion and equality bugs)**

Never instantiate primitive wrapper objects (`new Boolean()`, `new Number()`, `new String()`). They create objects instead of primitives, causing confusing truthiness and equality behavior.

**Incorrect (wrapper objects cause bugs):**

```javascript
function checkUserStatus(isActive) {
  const status = new Boolean(isActive);

  if (status) {  // Always truthy because it's an object!
    return 'User is active';
  }
  return 'User is inactive';
}

const emptyString = new String('');
if (emptyString) {  // Truthy! Object, not empty string
  console.log('This always runs');
}

const zero = new Number(0);
console.log(zero === 0);  // false (object !== primitive)
```

**Correct (use primitives directly):**

```javascript
function checkUserStatus(isActive) {
  const status = Boolean(isActive);  // Coercion, not construction

  if (status) {
    return 'User is active';
  }
  return 'User is inactive';
}

const emptyString = '';
if (emptyString) {  // Falsy as expected
  console.log('This never runs');
}

const zero = 0;
console.log(zero === 0);  // true
```

**Allowed (function calls for coercion):**

```javascript
const boolValue = Boolean(someValue);  // OK - coerces to primitive
const numValue = Number(inputString);  // OK - coerces to primitive
const strValue = String(numericId);    // OK - coerces to primitive
```

Reference: [Google JavaScript Style Guide - Wrapper objects](https://google.github.io/styleguide/jsguide.html#disallowed-features-wrapper-objects)

### 2.5 Never Use the with Statement

**Impact: CRITICAL (prevents scope ambiguity and strict mode errors)**

The `with` statement makes code ambiguous by creating unclear variable bindings. It's banned in strict mode and should never be used.

**Incorrect (with creates ambiguous scope):**

```javascript
function updateUserSettings(user, newSettings) {
  with (user.settings) {
    // Is 'theme' from user.settings or outer scope?
    theme = newSettings.theme;
    // Is 'language' being set on user.settings or global?
    language = newSettings.language;
    notifications = newSettings.notifications;
  }
}
```

**Correct (explicit property access):**

```javascript
function updateUserSettings(user, newSettings) {
  user.settings.theme = newSettings.theme;
  user.settings.language = newSettings.language;
  user.settings.notifications = newSettings.notifications;
}
```

**Alternative (destructuring for reading):**

```javascript
function displayUserSettings(user) {
  const { theme, language, notifications } = user.settings;
  console.log(`Theme: ${theme}, Language: ${language}`);
  return { theme, language, notifications };
}
```

**Note:** The `with` statement is a syntax error in strict mode (`'use strict'`) and ES modules.

Reference: [Google JavaScript Style Guide - Disallowed features](https://google.github.io/styleguide/jsguide.html#disallowed-features-with)

### 2.6 Use const by Default, let When Needed, Never var

**Impact: CRITICAL (prevents reassignment bugs and enables optimization)**

Declare variables with `const` by default. Use `let` only when reassignment is necessary. Never use `var` as it has confusing function-scoped hoisting behavior.

**Incorrect (var causes hoisting bugs):**

```javascript
function processOrders(orders) {
  for (var i = 0; i < orders.length; i++) {
    var order = orders[i];  // Hoisted to function scope
    setTimeout(() => {
      console.log(order.id);  // Always logs last order's id
    }, 100);
  }
  console.log(i);  // i is accessible here (function scoped)
}
```

**Correct (const/let with proper scoping):**

```javascript
function processOrders(orders) {
  for (let i = 0; i < orders.length; i++) {
    const order = orders[i];  // Block scoped, new binding each iteration
    setTimeout(() => {
      console.log(order.id);  // Logs correct order id
    }, 100);
  }
  // i is not accessible here (block scoped)
}
```

**Note:** Declare one variable per declaration statement. Never use `const a = 1, b = 2;`.

Reference: [Google JavaScript Style Guide - Local variable declarations](https://google.github.io/styleguide/jsguide.html#features-local-variable-declarations)

### 2.7 Use ES6 Classes Over Prototype Manipulation

**Impact: HIGH (improves readability and enables tooling support)**

Use ES6 `class` syntax instead of manually manipulating prototypes. Classes provide clearer syntax, proper inheritance semantics, and better tooling support.

**Incorrect (manual prototype manipulation):**

```javascript
function OrderProcessor(config) {
  this.config = config;
  this.processedCount = 0;
}

OrderProcessor.prototype.process = function(order) {
  this.processedCount++;
  return { ...order, processed: true };
};

OrderProcessor.prototype.getStats = function() {
  return { processed: this.processedCount };
};

function PriorityOrderProcessor(config) {
  OrderProcessor.call(this, config);
  this.priorityThreshold = config.priorityThreshold;
}

PriorityOrderProcessor.prototype = Object.create(OrderProcessor.prototype);
PriorityOrderProcessor.prototype.constructor = PriorityOrderProcessor;
```

**Correct (ES6 class syntax):**

```javascript
class OrderProcessor {
  constructor(config) {
    this.config = config;
    this.processedCount = 0;
  }

  process(order) {
    this.processedCount++;
    return { ...order, processed: true };
  }

  getStats() {
    return { processed: this.processedCount };
  }
}

class PriorityOrderProcessor extends OrderProcessor {
  constructor(config) {
    super(config);
    this.priorityThreshold = config.priorityThreshold;
  }
}
```

**Benefits:**
- Clearer inheritance chain
- `super` keyword for parent access
- Static methods with `static` keyword
- IDE autocompletion and refactoring support

Reference: [Google JavaScript Style Guide - Classes](https://google.github.io/styleguide/jsguide.html#features-classes)

### 2.8 Use Only Standard ECMAScript Features

**Impact: HIGH (prevents runtime errors on 100% of non-supporting platforms)**

Use only features defined in ECMA-262 or WHATWG standards. Avoid proprietary extensions, removed features, and unstable TC39 proposals that may change or break.

**Incorrect (non-standard or removed features):**

```javascript
// Non-standard Mozilla extension
const items = [1, 2, 3];
for each (let item in items) {  // Non-standard, Firefox-only
  console.log(item);
}

// Removed from spec
const cache = new WeakMap();
cache.clear();  // Removed method, doesn't exist

// Stage 2 proposal, may change
const value = obj.#privateField;  // Syntax may differ in final spec
```

**Correct (standard features only):**

```javascript
// Standard for-of loop
const items = [1, 2, 3];
for (const item of items) {
  console.log(item);
}

// Standard WeakMap usage (no clear method exists)
let cache = new WeakMap();
cache = new WeakMap();  // Create new map instead

// Use stable ES2022 private fields
class Counter {
  #count = 0;  // Standardized private field syntax

  increment() {
    this.#count++;
  }
}
```

**Exceptions:**
- Platform-specific APIs when targeting that platform (Node.js, Chrome extensions)
- Polyfilled features with stable TC39 Stage 4 status

Reference: [Google JavaScript Style Guide - Non-standard features](https://google.github.io/styleguide/jsguide.html#disallowed-features-non-standard-features)

---

## 3. Type Safety & JSDoc

**Impact: HIGH**

Type annotations and documentation enable IDE support, compiler checks, and prevent type-related runtime errors in large codebases.

### 3.1 Always Specify Template Parameters

**Impact: HIGH (improves type inference and prevents any-type degradation)**

Always provide explicit template parameters for generic types. Omitting them degrades to `unknown` or `any`, losing type safety benefits.

**Incorrect (missing template parameters):**

```javascript
/**
 * @param {Array} items - What type of items?
 * @param {Map} cache - Map of what to what?
 * @param {Promise} result - Promise of what?
 */
export function processItems(items, cache, result) {
  items.forEach(item => {
    cache.set(item.id, item);  // No type checking on item
  });
  return result;
}
```

**Correct (explicit template parameters):**

```javascript
/**
 * Processes product items and caches them by ID.
 * @param {!Array<!Product>} items The products to process.
 * @param {!Map<string, !Product>} cache The product cache keyed by ID.
 * @param {!Promise<!ProcessingResult>} result The async processing result.
 * @return {!Promise<!ProcessingResult>} The completed result.
 */
export function processItems(items, cache, result) {
  items.forEach(item => {
    cache.set(item.id, item);  // Type-safe: item is Product
  });
  return result;
}
```

**Common generic types requiring parameters:**
- `Array<T>` or `!Array<!T>`
- `Map<K, V>` or `!Map<string, !Value>`
- `Set<T>` or `!Set<!Item>`
- `Promise<T>` or `!Promise<!Result>`
- `Object<K, V>` for dict-style objects

Reference: [Google JavaScript Style Guide - Template parameter types](https://google.github.io/styleguide/jsguide.html#jsdoc-type-annotations)

### 3.2 Annotate Enums with Static Literal Values

**Impact: MEDIUM (enables compiler optimization and type checking)**

Define enums with `@enum` annotation on object literals. Values must be static literals (not computed). Enum names use UpperCamelCase, values use CONSTANT_CASE.

**Incorrect (computed values or missing annotation):**

```javascript
// Missing @enum annotation
const OrderStatus = {
  PENDING: 'pending',
  PROCESSING: 'processing',
  SHIPPED: 'shipped',
};

// Computed values not allowed in string enums
const BASE = 'order_';
/** @enum {string} */
const OrderType = {
  STANDARD: BASE + 'standard',  // Computed!
  EXPRESS: BASE + 'express',
};
```

**Correct (static literal enum values):**

```javascript
/**
 * Order processing status.
 * @enum {string}
 */
const OrderStatus = {
  PENDING: 'pending',
  PROCESSING: 'processing',
  SHIPPED: 'shipped',
  DELIVERED: 'delivered',
  CANCELLED: 'cancelled',
};

/**
 * Numeric priority levels.
 * @enum {number}
 */
const Priority = {
  LOW: 1,
  MEDIUM: 2,
  HIGH: 3,
  CRITICAL: 4,
};

/**
 * Updates order status.
 * @param {string} orderId The order ID.
 * @param {!OrderStatus} status The new status.
 */
export function updateOrderStatus(orderId, status) {
  database.orders.update(orderId, { status });
}
```

**Rules:**
- String enums: values must be string literals
- Number enums: may use arithmetic expressions
- No properties added after definition

Reference: [Google JavaScript Style Guide - Enums](https://google.github.io/styleguide/jsguide.html#features-enums)

### 3.3 Require JSDoc for All Exported Functions

**Impact: HIGH (enables IDE support and compiler type checking)**

All exported functions must have JSDoc with `@param` and `@return` type annotations. This enables IDE autocompletion, Closure Compiler type checking, and generates documentation.

**Incorrect (missing type annotations):**

```javascript
export function calculateShippingCost(items, destination) {
  const weight = items.reduce((sum, item) => sum + item.weight, 0);
  const rate = getShippingRate(destination);
  return weight * rate;
}

export function formatOrderSummary(order) {
  return `Order #${order.id}: ${order.items.length} items, $${order.total}`;
}
```

**Correct (complete JSDoc annotations):**

```javascript
/**
 * Calculates shipping cost based on item weights and destination.
 * @param {!Array<{weight: number, sku: string}>} items The items to ship.
 * @param {string} destination The destination postal code.
 * @return {number} The calculated shipping cost in dollars.
 */
export function calculateShippingCost(items, destination) {
  const weight = items.reduce((sum, item) => sum + item.weight, 0);
  const rate = getShippingRate(destination);
  return weight * rate;
}

/**
 * Formats an order into a human-readable summary string.
 * @param {{id: number, items: !Array, total: number}} order The order to format.
 * @return {string} The formatted order summary.
 */
export function formatOrderSummary(order) {
  return `Order #${order.id}: ${order.items.length} items, $${order.total}`;
}
```

**Note:** Private functions may omit JSDoc if the signature is self-explanatory.

Reference: [Google JavaScript Style Guide - JSDoc](https://google.github.io/styleguide/jsguide.html#jsdoc)

### 3.4 Use Explicit Nullability Modifiers

**Impact: HIGH (prevents null reference errors)**

Always specify nullability for reference types using `!` (non-null) or `?` (nullable). Ambiguous nullability causes runtime null reference errors.

**Incorrect (ambiguous nullability):**

```javascript
/**
 * @param {User} user - Is this nullable or not?
 * @param {Array<Order>} orders - Can this be null?
 * @return {Object} - What about the return type?
 */
export function processUserOrders(user, orders) {
  // Caller doesn't know if null checks are needed
  return {
    userId: user.id,
    orderCount: orders.length,
  };
}
```

**Correct (explicit nullability):**

```javascript
/**
 * Processes orders for a user. User must exist, orders may be empty.
 * @param {!User} user The user (required, non-null).
 * @param {!Array<!Order>} orders The orders (required array, non-null items).
 * @return {!{userId: number, orderCount: number}} The processed result.
 */
export function processUserOrders(user, orders) {
  return {
    userId: user.id,
    orderCount: orders.length,
  };
}

/**
 * Finds a user by email, returning null if not found.
 * @param {string} email The email to search for.
 * @return {?User} The user or null if not found.
 */
export function findUserByEmail(email) {
  return userDatabase.find(user => user.email === email) || null;
}
```

**Rules:**
- Primitives (`string`, `number`, `boolean`) are non-nullable by default
- Reference types (`Object`, `Array`, custom types) must use `!` or `?`
- `?` means the value can be `null` or `undefined`

Reference: [Google JavaScript Style Guide - Nullability](https://google.github.io/styleguide/jsguide.html#jsdoc-nullability)

### 3.5 Use Parentheses for Type Casts

**Impact: MEDIUM (prevents Closure Compiler type errors)**

When casting types, enclose the expression in parentheses with the type annotation. This ensures the cast applies to the entire expression and is recognized by tools.

**Incorrect (ambiguous or invalid casts):**

```javascript
// Cast may not apply to full expression
const element = /** @type {!HTMLInputElement} */ document.getElementById('email');

// Unclear what is being cast
const value = /** @type {number} */ input.value * 100;

// Missing parentheses
const items = /** @type {!Array<string>} */ rawData.items;
```

**Correct (parenthesized casts):**

```javascript
// Cast clearly applies to getElementById result
const element = /** @type {!HTMLInputElement} */ (document.getElementById('email'));

// Cast applies to input.value, then multiply
const value = /** @type {number} */ (input.value) * 100;

// Clear cast of rawData.items
const items = /** @type {!Array<string>} */ (rawData.items);
```

**Alternative (with assignment):**

```javascript
// Use intermediate variable for clarity
const rawElement = document.getElementById('email');
const emailInput = /** @type {!HTMLInputElement} */ (rawElement);
emailInput.value = 'user@example.com';
```

**When to cast:**
- DOM element access when specific type is known
- JSON parsing results with known structure
- Library return types that are too generic

Reference: [Google JavaScript Style Guide - Type casts](https://google.github.io/styleguide/jsguide.html#jsdoc-type-casts)

### 3.6 Use typedef for Complex Object Types

**Impact: MEDIUM-HIGH (enables reusable type definitions across files)**

Define reusable type definitions with `@typedef` for complex object shapes. Inline object types become unreadable and cannot be reused.

**Incorrect (inline complex types):**

```javascript
/**
 * @param {{id: number, email: string, profile: {name: string, avatar: ?string, preferences: {theme: string, notifications: boolean}}}} user
 * @param {{items: !Array<{sku: string, quantity: number, price: number}>, shipping: {address: string, method: string}, payment: {method: string, last4: string}}} order
 * @return {{success: boolean, orderId: string, estimatedDelivery: !Date}}
 */
export function processCheckout(user, order) {
  // Impossible to read the types
}
```

**Correct (typedef for reusable types):**

```javascript
/**
 * @typedef {{
 *   name: string,
 *   avatar: ?string,
 *   preferences: !UserPreferences,
 * }}
 */
let UserProfile;

/**
 * @typedef {{theme: string, notifications: boolean}}
 */
let UserPreferences;

/**
 * @typedef {{
 *   id: number,
 *   email: string,
 *   profile: !UserProfile,
 * }}
 */
let User;

/**
 * @typedef {{
 *   success: boolean,
 *   orderId: string,
 *   estimatedDelivery: !Date,
 * }}
 */
let CheckoutResult;

/**
 * Processes a checkout for the given user and order.
 * @param {!User} user The authenticated user.
 * @param {!Order} order The order to process.
 * @return {!CheckoutResult} The checkout result.
 */
export function processCheckout(user, order) {
  // Clear, readable parameter types
}
```

**Benefits:**
- Types can be imported and reused across files
- IDE provides better autocompletion
- Documentation is more maintainable

Reference: [Google JavaScript Style Guide - Typedef](https://google.github.io/styleguide/jsguide.html#jsdoc-typedef-annotations)

---

## 4. Naming Conventions

**Impact: HIGH**

Consistent naming improves code comprehension, prevents ambiguity, and enables effective code search across large codebases.

### 4.1 Avoid Dollar Sign Prefix in Identifiers

**Impact: MEDIUM (prevents confusion with framework conventions)**

Do not use `$` prefix in identifiers except when required by third-party frameworks (Angular, jQuery). Dollar signs create confusion with framework-specific conventions.

**Incorrect (arbitrary dollar signs):**

```javascript
class UserService {
  constructor() {
    this.$users = [];  // Looks like Angular service
    this.$cache = new Map();
  }

  $fetchUser(userId) {  // Confusing naming
    return this.$users.find(u => u.id === userId);
  }
}

const $element = document.getElementById('app');  // Looks like jQuery
const $data = { name: 'Alice' };
```

**Correct (no dollar signs):**

```javascript
class UserService {
  constructor() {
    this.users = [];
    this.cache = new Map();
  }

  fetchUser(userId) {
    return this.users.find(user => user.id === userId);
  }
}

const appElement = document.getElementById('app');
const userData = { name: 'Alice' };
```

**Exception (framework requirements):**

```javascript
// Angular dependency injection (required by framework)
class OrderComponent {
  constructor($http, $scope) {
    this.$http = $http;  // Framework convention
    this.$scope = $scope;
  }
}

// jQuery (if library is used)
const $modal = $('#modal');  // jQuery convention
```

Reference: [Google JavaScript Style Guide - Identifiers](https://google.github.io/styleguide/jsguide.html#naming-rules-common-to-all-identifiers)

### 4.2 Prefer Descriptive Names Over Brevity

**Impact: HIGH (significantly improves code comprehension)**

Use descriptive names that clearly convey purpose. Avoid ambiguous abbreviations and single letters except in very small scopes (under 10 lines).

**Incorrect (cryptic abbreviations):**

```javascript
function procUsrOrds(u, cb) {
  const ords = u.ords;
  for (let i = 0; i < ords.length; i++) {
    const o = ords[i];
    const r = calcTot(o);
    cb(r);
  }
}

function hndlBtnClk(e) {
  const t = e.target;
  const v = t.value;
  updSt(v);
}
```

**Correct (descriptive names):**

```javascript
function processUserOrders(user, callback) {
  const orders = user.orders;
  for (let index = 0; index < orders.length; index++) {
    const order = orders[index];
    const result = calculateTotal(order);
    callback(result);
  }
}

function handleButtonClick(event) {
  const targetElement = event.target;
  const inputValue = targetElement.value;
  updateState(inputValue);
}
```

**Acceptable short names (small scope):**

```javascript
// OK in arrow function with small scope
const totalPrice = items.reduce((sum, item) => sum + item.price, 0);

// OK for standard loop counters in simple loops
for (let i = 0; i < 5; i++) {
  console.log(i);
}
```

**Forbidden abbreviations:**
- Deleting internal letters: `msg` for `message`, `btn` for `button`
- Ambiguous: `tmp`, `data`, `info`, `str`, `num`

Reference: [Google JavaScript Style Guide - Naming rules](https://google.github.io/styleguide/jsguide.html#naming-rules-common-to-all-identifiers)

### 4.3 Use CONSTANT_CASE for Deeply Immutable Values

**Impact: HIGH (signals immutability and prevents accidental modification)**

Use CONSTANT_CASE (all caps with underscores) only for `@const` values that are deeply immutable. Regular `const` variables that hold mutable objects use lowerCamelCase.

**Incorrect (CONSTANT_CASE for mutable values):**

```javascript
// Array is mutable - wrong casing
const ALLOWED_ROLES = ['admin', 'editor', 'viewer'];
ALLOWED_ROLES.push('guest');  // Can still mutate!

// Object is mutable - wrong casing
const DEFAULT_CONFIG = {
  timeout: 5000,
  retries: 3,
};
DEFAULT_CONFIG.timeout = 10000;  // Can still mutate!

// Regular const binding - wrong casing
const USER_COUNT = users.length;  // Value computed at runtime
```

**Correct (CONSTANT_CASE only for truly immutable):**

```javascript
/** @const {number} */
const MAX_RETRY_COUNT = 3;

/** @const {string} */
const API_BASE_URL = 'https://api.example.com';

/** @const {!Object<string, number>} */
const HttpStatus = Object.freeze({
  OK: 200,
  NOT_FOUND: 404,
  SERVER_ERROR: 500,
});

// Mutable references use lowerCamelCase
const allowedRoles = ['admin', 'editor', 'viewer'];
const defaultConfig = { timeout: 5000, retries: 3 };
const userCount = users.length;
```

**Requirements for CONSTANT_CASE:**
- Value is a primitive literal, or
- Deeply immutable object (frozen or enum), and
- Annotated with `@const`

Reference: [Google JavaScript Style Guide - Constant names](https://google.github.io/styleguide/jsguide.html#naming-constant-names)

### 4.4 Use lowerCamelCase for Methods and Variables

**Impact: HIGH (maintains consistency and enables code search)**

Method names, parameter names, and local variables use lowerCamelCase. Names are descriptive verbs for methods and descriptive nouns for variables.

**Incorrect (wrong casing or unclear names):**

```javascript
class OrderService {
  // Snake_case method
  get_order_by_id(order_id) {
    return this.database.find(order_id);
  }

  // ALL_CAPS for non-constant
  ProcessOrders(ORDERS) {
    for (const ORDER of ORDERS) {
      this.process(ORDER);
    }
  }

  // Unclear abbreviations
  updUsrPrf(u, p) {
    u.profile = p;
  }
}
```

**Correct (lowerCamelCase with descriptive names):**

```javascript
class OrderService {
  getOrderById(orderId) {
    return this.database.find(orderId);
  }

  processOrders(orders) {
    for (const order of orders) {
      this.process(order);
    }
  }

  updateUserProfile(user, profile) {
    user.profile = profile;
  }
}
```

**Method naming patterns:**
- Getters: `getUser()`, `fetchOrders()`, `loadConfig()`
- Boolean getters: `isActive()`, `hasPermission()`, `canEdit()`
- Setters: `setTheme()`, `updateStatus()`, `assignRole()`
- Actions: `processOrder()`, `validateInput()`, `sendEmail()`

Reference: [Google JavaScript Style Guide - Method names](https://google.github.io/styleguide/jsguide.html#naming-method-names)

### 4.5 Use Lowercase with Dashes or Underscores for Files

**Impact: MEDIUM (prevents import resolution failures across platforms)**

File names must be all lowercase with only dashes or underscores as separators. No other punctuation, no spaces, no uppercase letters. This ensures cross-platform compatibility.

**Incorrect (case-sensitive or invalid characters):**

```text
UserService.js        // Uppercase letters
order-processor.JS    // Uppercase extension
user profile.js       // Space in name
order_$helper.js      // Special character
My-Component.jsx      // Uppercase letters
```

**Correct (lowercase with dashes or underscores):**

```text
user-service.js       // Dashes
order_processor.js    // Underscores
user-profile.js       // Dashes
order-helper.js       // Dashes
my-component.jsx      // Dashes
```

**Consistency rule:** Choose either dashes or underscores and use consistently throughout the project.

**Why this matters:**
- Case-insensitive filesystems (Windows, macOS default) cause silent failures
- Git may not detect case-only renames
- Import paths become unpredictable across platforms

Reference: [Google JavaScript Style Guide - File name](https://google.github.io/styleguide/jsguide.html#file-name)

### 4.6 Use UpperCamelCase for Classes and Constructors

**Impact: HIGH (prevents new keyword misuse on non-constructors)**

Classes, interfaces, records, and typedefs use UpperCamelCase (PascalCase). This visually distinguishes types that can be instantiated or used in type annotations.

**Incorrect (lowercase or mixed naming):**

```javascript
// Lowercase class name
class orderProcessor {
  constructor(config) {
    this.config = config;
  }
}

// Snake_case typedef
/** @typedef {{id: number, name: string}} */
let user_profile;

// Mixed naming
class HTTP_Client {
  fetch(url) {
    return globalThis.fetch(url);
  }
}
```

**Correct (UpperCamelCase for types):**

```javascript
class OrderProcessor {
  constructor(config) {
    this.config = config;
  }
}

/** @typedef {{id: number, name: string}} */
let UserProfile;

class HttpClient {
  fetch(url) {
    return globalThis.fetch(url);
  }
}

/** @interface */
class EventListener {
  /** @param {!Event} event */
  handleEvent(event) {}
}
```

**Camel case conversion rules:**
- `HTTP` becomes `Http` (not `HTTP`)
- `XMLParser` becomes `XmlParser`
- `IOStream` becomes `IoStream`

Reference: [Google JavaScript Style Guide - Class names](https://google.github.io/styleguide/jsguide.html#naming-class-names)

---

## 5. Control Flow & Error Handling

**Impact: MEDIUM-HIGH**

Proper exception handling, equality checks, and control structures prevent silent failures and hard-to-debug runtime errors.

### 5.1 Always Include Default Case in Switch Statements

**Impact: MEDIUM-HIGH (prevents silent failures on unexpected values)**

Every switch statement must have a `default` case as the last case. Document fall-through with a comment. This ensures all cases are handled explicitly.

**Incorrect (missing default, undocumented fall-through):**

```javascript
function getStatusLabel(status) {
  switch (status) {
    case 'pending':
      return 'Waiting...';
    case 'processing':
    case 'validating':  // Fall-through not documented
      return 'In progress';
    case 'complete':
      return 'Done';
    // Missing default - what if status is invalid?
  }
}
```

**Correct (default case, documented fall-through):**

```javascript
function getStatusLabel(status) {
  switch (status) {
    case 'pending':
      return 'Waiting...';
    case 'processing':
      // fall through
    case 'validating':
      return 'In progress';
    case 'complete':
      return 'Done';
    default:
      throw new Error(`Unknown status: ${status}`);
  }
}
```

**Alternative (empty default with comment):**

```javascript
function handleNotification(type) {
  switch (type) {
    case 'email':
      sendEmail();
      break;
    case 'sms':
      sendSms();
      break;
    case 'push':
      sendPush();
      break;
    default:
      // No action needed for unknown types
      break;
  }
}
```

**Note:** Use block statements (`{ }`) inside cases when declaring variables to create proper scope.

Reference: [Google JavaScript Style Guide - Switch statements](https://google.github.io/styleguide/jsguide.html#features-switch-statements)

### 5.2 Always Throw Error Objects, Not Primitives

**Impact: MEDIUM-HIGH (preserves stack traces for debugging)**

Always throw `Error` objects or subclasses, never strings or plain objects. Error objects capture stack traces essential for debugging.

**Incorrect (throwing primitives loses stack trace):**

```javascript
function validateOrder(order) {
  if (!order.items || order.items.length === 0) {
    throw 'Order must have items';  // No stack trace
  }
  if (order.total < 0) {
    throw { code: 'INVALID_TOTAL', message: 'Total cannot be negative' };
  }
}

async function fetchUserData(userId) {
  const response = await fetch(`/api/users/${userId}`);
  if (!response.ok) {
    throw response.status;  // Just a number, useless for debugging
  }
}
```

**Correct (throw Error objects):**

```javascript
function validateOrder(order) {
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items');
  }
  if (order.total < 0) {
    throw new RangeError('Total cannot be negative');
  }
}

class ApiError extends Error {
  constructor(status, message) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
  }
}

async function fetchUserData(userId) {
  const response = await fetch(`/api/users/${userId}`);
  if (!response.ok) {
    throw new ApiError(response.status, `Failed to fetch user: ${userId}`);
  }
  return response.json();
}
```

**Built-in Error types:**
- `Error` - generic errors
- `TypeError` - type mismatches
- `RangeError` - out of range values
- `ReferenceError` - undefined variable access

Reference: [Google JavaScript Style Guide - Exceptions](https://google.github.io/styleguide/jsguide.html#features-exceptions)

### 5.3 Document Empty Catch Blocks

**Impact: MEDIUM (prevents silent failure masking)**

Empty catch blocks must include a comment explaining why the exception is intentionally suppressed. Silently swallowing errors hides bugs.

**Incorrect (empty catch hides errors):**

```javascript
async function loadUserPreferences(userId) {
  try {
    const prefs = await fetchPreferences(userId);
    return prefs;
  } catch (error) {
    // Empty - error silently swallowed
  }
}

function parseConfigSafe(jsonString) {
  try {
    return JSON.parse(jsonString);
  } catch {
    // What failed? Why is it OK to ignore?
  }
  return null;
}
```

**Correct (documented suppression or proper handling):**

```javascript
async function loadUserPreferences(userId) {
  try {
    const prefs = await fetchPreferences(userId);
    return prefs;
  } catch (error) {
    // Preferences are optional; return defaults if unavailable.
    logger.debug(`Preferences not found for user ${userId}, using defaults`);
    return getDefaultPreferences();
  }
}

function parseConfigSafe(jsonString) {
  try {
    return JSON.parse(jsonString);
  } catch (error) {
    // Invalid JSON is expected when config file doesn't exist.
    // Return null to signal caller should use defaults.
    return null;
  }
}
```

**Alternative (rethrow with context):**

```javascript
async function processPayment(orderId, amount) {
  try {
    await chargeCard(orderId, amount);
  } catch (error) {
    // Add context before rethrowing
    throw new Error(`Payment failed for order ${orderId}: ${error.message}`);
  }
}
```

Reference: [Google JavaScript Style Guide - Empty catch blocks](https://google.github.io/styleguide/jsguide.html#features-exceptions)

### 5.4 Prefer for-of Over for-in for Iteration

**Impact: MEDIUM (prevents prototype property bugs)**

Use `for-of` to iterate arrays and iterables. Reserve `for-in` only for dict-style objects, and always check `hasOwnProperty`. Never use `for-in` on arrays.

**Incorrect (for-in on arrays, missing hasOwnProperty):**

```javascript
const orders = [{ id: 1 }, { id: 2 }, { id: 3 }];

// Iterates indices as strings, includes prototype properties
for (const index in orders) {
  console.log(orders[index].id);
}

const config = { timeout: 5000, retries: 3 };

// May include inherited properties
for (const key in config) {
  console.log(`${key}: ${config[key]}`);
}
```

**Correct (for-of for arrays, guarded for-in for objects):**

```javascript
const orders = [{ id: 1 }, { id: 2 }, { id: 3 }];

// for-of iterates values directly
for (const order of orders) {
  console.log(order.id);
}

const config = { timeout: 5000, retries: 3 };

// for-in with hasOwnProperty check
for (const key in config) {
  if (Object.prototype.hasOwnProperty.call(config, key)) {
    console.log(`${key}: ${config[key]}`);
  }
}
```

**Alternative (Object.entries for key-value pairs):**

```javascript
const config = { timeout: 5000, retries: 3 };

// Modern approach - no hasOwnProperty needed
for (const [key, value] of Object.entries(config)) {
  console.log(`${key}: ${value}`);
}

// Or with Object.keys
for (const key of Object.keys(config)) {
  console.log(`${key}: ${config[key]}`);
}
```

Reference: [Google JavaScript Style Guide - for-in loop](https://google.github.io/styleguide/jsguide.html#features-for-in-loop)

### 5.5 Use Strict Equality Except for Null Checks

**Impact: MEDIUM-HIGH (prevents type coercion bugs)**

Always use strict equality (`===`/`!==`) to avoid type coercion surprises. The only exception is `== null` which conveniently checks both `null` and `undefined`.

**Incorrect (loose equality causes bugs):**

```javascript
function validateAge(age) {
  if (age == '18') {  // Coerces string to number
    return true;
  }
  return false;
}

function checkPermission(user) {
  if (user.role == true) {  // Coerces boolean
    return 'admin';
  }
  if (user.id == 0) {  // '' == 0 is true!
    return 'guest';
  }
}
```

**Correct (strict equality):**

```javascript
function validateAge(age) {
  if (age === 18) {  // No coercion, type-safe
    return true;
  }
  return false;
}

function checkPermission(user) {
  if (user.role === true) {
    return 'admin';
  }
  if (user.id === 0) {
    return 'guest';
  }
}
```

**Exception (null/undefined check):**

```javascript
// OK: == null checks both null and undefined
function processValue(value) {
  if (value == null) {
    return 'No value provided';
  }
  return `Value: ${value}`;
}

// Equivalent but more verbose:
function processValueExplicit(value) {
  if (value === null || value === undefined) {
    return 'No value provided';
  }
  return `Value: ${value}`;
}
```

Reference: [Google JavaScript Style Guide - Equality checks](https://google.github.io/styleguide/jsguide.html#features-equality-checks)

---

## 6. Functions & Parameters

**Impact: MEDIUM**

Function design patterns (arrow functions, rest params, defaults) affect code clarity, this-binding behavior, and API ergonomics.

### 6.1 Always Use Parentheses Around Arrow Function Parameters

**Impact: LOW-MEDIUM (prevents errors when adding parameters)**

Always wrap arrow function parameters in parentheses, even for single parameters. This prevents errors when adding parameters later and maintains consistency.

**Incorrect (omitted parentheses):**

```javascript
const processOrder = order => {
  // Adding a second parameter requires restructuring
  return { ...order, processed: true };
};

const formatName = name => `Hello, ${name}!`;

const items = orders.map(order => order.items);

// Error-prone when adding parameters
const handleClick = e => e.preventDefault();  // Adding second param breaks this
```

**Correct (always use parentheses):**

```javascript
const processOrder = (order) => {
  return { ...order, processed: true };
};

const formatName = (name) => `Hello, ${name}!`;

const items = orders.map((order) => order.items);

const handleClick = (event) => event.preventDefault();
```

**Adding parameters is now trivial:**

```javascript
// Before: (order) => { ... }
// After:  (order, options) => { ... }
const processOrder = (order, options = {}) => {
  return { ...order, processed: true, ...options };
};
```

**Exception:** Omitting parentheses is allowed but not recommended:
```javascript
// Allowed but discouraged
const double = x => x * 2;
```

Reference: [Google JavaScript Style Guide - Arrow functions](https://google.github.io/styleguide/jsguide.html#features-functions-arrow-functions)

### 6.2 Prefer Arrow Functions for Nested Functions

**Impact: MEDIUM (simplifies this binding and reduces boilerplate)**

Use arrow functions instead of `function` keyword for nested functions. Arrow functions lexically bind `this`, eliminating common `this` binding bugs.

**Incorrect (function keyword loses this context):**

```javascript
class OrderProcessor {
  constructor(orders) {
    this.orders = orders;
    this.total = 0;
  }

  calculateTotal() {
    this.orders.forEach(function(order) {
      this.total += order.amount;  // this is undefined or window!
    });
    return this.total;
  }

  processAsync() {
    const self = this;  // Workaround for this binding
    return fetch('/api/process').then(function(response) {
      return self.handleResponse(response);  // Using self hack
    });
  }
}
```

**Correct (arrow functions preserve this):**

```javascript
class OrderProcessor {
  constructor(orders) {
    this.orders = orders;
    this.total = 0;
  }

  calculateTotal() {
    this.orders.forEach((order) => {
      this.total += order.amount;  // this is correctly bound
    });
    return this.total;
  }

  processAsync() {
    return fetch('/api/process').then((response) => {
      return this.handleResponse(response);  // No self hack needed
    });
  }
}
```

**When to use function keyword:**
- Top-level exported functions
- Object methods needing dynamic `this`
- Functions requiring `arguments` object

Reference: [Google JavaScript Style Guide - Arrow functions](https://google.github.io/styleguide/jsguide.html#features-functions-arrow-functions)

### 6.3 Use Default Parameters Instead of Conditional Assignment

**Impact: MEDIUM (clearer API and prevents falsy value bugs)**

Use default parameter syntax instead of conditionally assigning inside the function body. Defaults appear in the signature and avoid falsy value pitfalls.

**Incorrect (conditional assignment inside body):**

```javascript
function createUser(name, role, isActive) {
  name = name || 'Anonymous';  // '' is falsy, becomes 'Anonymous'
  role = role || 'viewer';
  isActive = isActive !== undefined ? isActive : true;  // Verbose

  return { name, role, isActive };
}

function formatCurrency(amount, currency, locale) {
  if (currency === undefined) {
    currency = 'USD';
  }
  if (locale === undefined) {
    locale = 'en-US';
  }
  return new Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);
}
```

**Correct (default parameters in signature):**

```javascript
function createUser(name = 'Anonymous', role = 'viewer', isActive = true) {
  return { name, role, isActive };
}

function formatCurrency(amount, currency = 'USD', locale = 'en-US') {
  return new Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);
}

// Allows passing empty string or 0 without triggering default
createUser('', 'admin', false);  // { name: '', role: 'admin', isActive: false }
```

**Rules for default parameters:**
- Place after required parameters
- Keep initializers simple (no side effects)
- Defaults must be provided in concrete implementations (not interfaces)

Reference: [Google JavaScript Style Guide - Default parameters](https://google.github.io/styleguide/jsguide.html#features-default-parameters)

### 6.4 Use Rest Parameters Instead of arguments Object

**Impact: MEDIUM (eliminates Array.prototype.slice.call boilerplate)**

Use rest parameters (`...args`) instead of the `arguments` object. Rest parameters are real arrays with proper methods and work with arrow functions.

**Incorrect (arguments object limitations):**

```javascript
function sum() {
  // arguments is not a real array
  const total = Array.prototype.reduce.call(arguments, (acc, val) => acc + val, 0);
  return total;
}

function logWithPrefix() {
  const prefix = arguments[0];
  // Slicing arguments is awkward
  const messages = Array.prototype.slice.call(arguments, 1);
  messages.forEach(msg => console.log(`${prefix}: ${msg}`));
}

// arguments doesn't work in arrow functions
const multiply = () => {
  return arguments[0] * arguments[1];  // ReferenceError in arrow function
};
```

**Correct (rest parameters):**

```javascript
function sum(...numbers) {
  // numbers is a real array
  return numbers.reduce((acc, val) => acc + val, 0);
}

function logWithPrefix(prefix, ...messages) {
  // Clean separation of named and rest params
  messages.forEach(msg => console.log(`${prefix}: ${msg}`));
}

// Works in arrow functions
const multiply = (...numbers) => {
  return numbers.reduce((acc, val) => acc * val, 1);
};
```

**JSDoc for rest parameters:**

```javascript
/**
 * Joins strings with a separator.
 * @param {string} separator The separator.
 * @param {...string} parts The parts to join.
 * @return {string} The joined string.
 */
function join(separator, ...parts) {
  return parts.join(separator);
}
```

Reference: [Google JavaScript Style Guide - Rest parameters](https://google.github.io/styleguide/jsguide.html#features-rest-parameters)

### 6.5 Use Spread Operator Instead of Function.apply

**Impact: MEDIUM (cleaner syntax, works with new operator)**

Use spread syntax (`...args`) when calling functions with array arguments. Spread is cleaner than `Function.prototype.apply()` and works with `new`.

**Incorrect (apply for array arguments):**

```javascript
function processItems(processor, items) {
  // Awkward apply syntax
  return processor.apply(null, items);
}

function findMax(numbers) {
  return Math.max.apply(Math, numbers);
}

function createWithArgs(Constructor, args) {
  // apply doesn't work with new
  return new (Function.prototype.bind.apply(Constructor, [null].concat(args)))();
}
```

**Correct (spread syntax):**

```javascript
function processItems(processor, items) {
  return processor(...items);
}

function findMax(numbers) {
  return Math.max(...numbers);
}

function createWithArgs(Constructor, args) {
  return new Constructor(...args);
}
```

**Common use cases:**

```javascript
// Combining arrays
const allOrders = [...pendingOrders, ...completedOrders];

// Copying arrays
const ordersCopy = [...originalOrders];

// Converting iterables to arrays
const chars = [...'hello'];  // ['h', 'e', 'l', 'l', 'o']

// Spreading into function calls
console.log(...['Debug:', errorMessage, stackTrace]);
```

Reference: [Google JavaScript Style Guide - Spread operator](https://google.github.io/styleguide/jsguide.html#features-spread-operator)

---

## 7. Objects & Arrays

**Impact: MEDIUM**

Data structure patterns (literals, destructuring, spread) impact code consistency, prevent mutation bugs, and enable VM optimizations.

### 7.1 Never Mix Quoted and Unquoted Object Keys

**Impact: MEDIUM (prevents compiler optimization issues)**

Never mix quoted and unquoted property keys in the same object. Choose struct-style (unquoted) or dict-style (quoted) and use consistently.

**Incorrect (mixed key styles):**

```javascript
const config = {
  apiUrl: 'https://api.example.com',
  'api-key': 'secret123',  // Quoted
  timeout: 5000,
  'max-retries': 3,  // Quoted
};

const user = {
  name: 'Alice',
  'e-mail': 'alice@example.com',  // Mixing styles
  role: 'admin',
};
```

**Correct (struct-style, unquoted keys):**

```javascript
const config = {
  apiUrl: 'https://api.example.com',
  apiKey: 'secret123',
  timeout: 5000,
  maxRetries: 3,
};

const user = {
  name: 'Alice',
  email: 'alice@example.com',
  role: 'admin',
};
```

**Correct (dict-style, all quoted keys):**

```javascript
// Use when keys must contain special characters
const headers = {
  'Content-Type': 'application/json',
  'X-Api-Key': 'secret123',
  'Accept-Language': 'en-US',
};

// Or when keys are dynamic/external
const translations = {
  'en-US': 'Hello',
  'es-ES': 'Hola',
  'fr-FR': 'Bonjour',
};
```

**Why this matters:**
- Closure Compiler optimizes unquoted keys differently than quoted
- Mixing prevents consistent property access patterns
- Makes refactoring more error-prone

Reference: [Google JavaScript Style Guide - Object literals](https://google.github.io/styleguide/jsguide.html#features-objects-mixing-keys)

### 7.2 Use Array Literals Instead of Array Constructor

**Impact: MEDIUM (avoids single-argument ambiguity)**

Use array literal syntax `[]` instead of `new Array()`. The constructor behaves unexpectedly with a single numeric argument, creating sparse arrays.

**Incorrect (Array constructor ambiguity):**

```javascript
// Creates array with 3 empty slots, not [3]!
const items = new Array(3);
console.log(items.length);  // 3
console.log(items[0]);       // undefined (sparse)

// This works but is inconsistent
const values = new Array(1, 2, 3);  // [1, 2, 3]

// Mixing styles
const orders = new Array();
orders.push({ id: 1 });
```

**Correct (array literals):**

```javascript
const items = [3];  // Array containing number 3
console.log(items.length);  // 1
console.log(items[0]);       // 3

const values = [1, 2, 3];

const orders = [];
orders.push({ id: 1 });
```

**Exception (pre-allocating fixed size):**

```javascript
// Explicitly creating fixed-size array is OK
const buffer = new Array(1024);
for (let i = 0; i < buffer.length; i++) {
  buffer[i] = 0;
}

// Or use Array.from for initialization
const zeros = Array.from({ length: 1024 }, () => 0);
```

**With spread and methods:**

```javascript
// Concatenating arrays
const allItems = [...itemsA, ...itemsB];

// Creating from iterable
const chars = [...'hello'];

// Array.of for single numeric value
const singleNumber = Array.of(3);  // [3]
```

Reference: [Google JavaScript Style Guide - Array literals](https://google.github.io/styleguide/jsguide.html#features-arrays-ctor)

### 7.3 Use Destructuring for Multiple Property Access

**Impact: MEDIUM (reduces repetition and improves clarity)**

Use destructuring to extract multiple properties from objects or arrays. This reduces repetition and makes data dependencies explicit.

**Incorrect (repeated property access):**

```javascript
function processOrder(order) {
  const orderId = order.id;
  const items = order.items;
  const shipping = order.shipping;
  const total = order.total;

  console.log(`Processing order ${orderId}`);
  return {
    orderId,
    itemCount: items.length,
    shippingMethod: shipping.method,
    grandTotal: total,
  };
}

function getCoordinates(point) {
  return `(${point.x}, ${point.y})`;
}
```

**Correct (destructuring):**

```javascript
function processOrder(order) {
  const { id: orderId, items, shipping, total } = order;

  console.log(`Processing order ${orderId}`);
  return {
    orderId,
    itemCount: items.length,
    shippingMethod: shipping.method,
    grandTotal: total,
  };
}

function getCoordinates({ x, y }) {
  return `(${x}, ${y})`;
}
```

**Array destructuring:**

```javascript
// Extracting specific positions
const [first, second, ...rest] = items;

// Swapping values
[a, b] = [b, a];

// Skipping elements
const [, , third] = ['a', 'b', 'c'];
```

**With defaults:**

```javascript
function createUser({ name, role = 'viewer', isActive = true } = {}) {
  return { name, role, isActive };
}

createUser({ name: 'Alice' });  // { name: 'Alice', role: 'viewer', isActive: true }
createUser();  // { name: undefined, role: 'viewer', isActive: true }
```

Reference: [Google JavaScript Style Guide - Destructuring](https://google.github.io/styleguide/jsguide.html#features-objects-destructuring)

### 7.4 Use Object Literals Instead of Object Constructor

**Impact: MEDIUM (clearer syntax and avoids edge cases)**

Use object literal syntax `{}` instead of `new Object()`. The constructor form is verbose and has edge cases with single arguments.

**Incorrect (Object constructor):**

```javascript
const user = new Object();
user.name = 'Alice';
user.email = 'alice@example.com';
user.role = 'admin';

const config = new Object();
config.timeout = 5000;
config.retries = 3;

// Mixed styles
const order = new Object({
  id: 123,
  items: [],
});
```

**Correct (object literals):**

```javascript
const user = {
  name: 'Alice',
  email: 'alice@example.com',
  role: 'admin',
};

const config = {
  timeout: 5000,
  retries: 3,
};

const order = {
  id: 123,
  items: [],
};
```

**With shorthand properties:**

```javascript
const name = 'Alice';
const email = 'alice@example.com';
const role = 'admin';

// Shorthand property names
const user = { name, email, role };

// Method shorthand
const calculator = {
  add(a, b) {
    return a + b;
  },
  multiply(a, b) {
    return a * b;
  },
};
```

Reference: [Google JavaScript Style Guide - Object literals](https://google.github.io/styleguide/jsguide.html#features-objects-no-new-wrappers)

### 7.5 Use Spread Over concat and slice

**Impact: LOW-MEDIUM (reduces array operation boilerplate by 50%)**

Use spread syntax for copying and concatenating arrays instead of `Array.prototype.slice.call()` or `concat()`. Spread is cleaner and works with any iterable.

**Incorrect (concat and slice methods):**

```javascript
function mergeOrders(pendingOrders, completedOrders) {
  return pendingOrders.concat(completedOrders);
}

function copyArray(original) {
  return original.slice();
}

function toArray(arrayLike) {
  return Array.prototype.slice.call(arrayLike);
}

function prependItem(item, items) {
  return [item].concat(items);
}
```

**Correct (spread syntax):**

```javascript
function mergeOrders(pendingOrders, completedOrders) {
  return [...pendingOrders, ...completedOrders];
}

function copyArray(original) {
  return [...original];
}

function toArray(arrayLike) {
  return [...arrayLike];
}

function prependItem(item, items) {
  return [item, ...items];
}
```

**More examples:**

```javascript
// Insert item at position
const insertAt = (array, index, item) => [
  ...array.slice(0, index),
  item,
  ...array.slice(index),
];

// Remove item at position
const removeAt = (array, index) => [
  ...array.slice(0, index),
  ...array.slice(index + 1),
];

// Clone with modifications
const updatedConfig = {
  ...config,
  timeout: 10000,
};
```

Reference: [Google JavaScript Style Guide - Spread operator](https://google.github.io/styleguide/jsguide.html#features-arrays-spread-operator)

### 7.6 Use Trailing Commas in Multi-line Literals

**Impact: MEDIUM (reduces git diff noise by 50% on additions)**

Include trailing commas after the last element in multi-line array and object literals. This produces cleaner git diffs and makes reordering easier.

**Incorrect (no trailing comma, noisy diffs):**

```javascript
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3  // Adding new property changes this line too
};

const roles = [
  'admin',
  'editor',
  'viewer'  // Adding new role changes this line
];
```

**Correct (trailing commas):**

```javascript
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3,  // Adding property only adds one line
};

const roles = [
  'admin',
  'editor',
  'viewer',  // Adding role only adds one line
];
```

**Git diff comparison:**

```diff
# Without trailing comma (2 lines changed)
  const roles = [
    'admin',
    'editor',
-   'viewer'
+   'viewer',
+   'guest'
  ];

# With trailing comma (1 line changed)
  const roles = [
    'admin',
    'editor',
    'viewer',
+   'guest',
  ];
```

**When NOT to use trailing comma:**
- Single-line literals: `const point = { x: 1, y: 2 };`
- Function parameters in declarations (different rule)

Reference: [Google JavaScript Style Guide - Trailing commas](https://google.github.io/styleguide/jsguide.html#features-arrays-trailing-comma)

---

## 8. Formatting & Style

**Impact: LOW**

Whitespace, braces, and line limits maintain visual consistency for team collaboration but have minimal runtime impact.

### 8.1 Always Use Braces for Control Structures

**Impact: LOW (prevents bugs when adding statements)**

Use braces for all control structures (`if`, `else`, `for`, `while`, `do`) even when the body is a single statement. This prevents bugs when adding statements later.

**Incorrect (missing braces):**

```javascript
function validateOrder(order) {
  if (!order.items)
    return false;

  for (const item of order.items)
    if (item.quantity <= 0)
      return false;  // Easy to break when adding logging

  if (order.total > 10000)
    applyDiscount(order);
    sendNotification(order);  // Always runs! Not part of if
}
```

**Correct (braces required):**

```javascript
function validateOrder(order) {
  if (!order.items) {
    return false;
  }

  for (const item of order.items) {
    if (item.quantity <= 0) {
      return false;
    }
  }

  if (order.total > 10000) {
    applyDiscount(order);
    sendNotification(order);  // Clearly part of if block
  }
}
```

**Exception (simple single-line if):**

```javascript
// OK when condition and body fit on one line with braces
if (!user) { return null; }

// Also acceptable
if (!user) {
  return null;
}
```

**Brace style (K&R):**
- Opening brace on same line as statement
- Closing brace on its own line
- `else` on same line as closing brace

Reference: [Google JavaScript Style Guide - Braces](https://google.github.io/styleguide/jsguide.html#formatting-braces)

### 8.2 Limit Lines to 80 Characters

**Impact: LOW (prevents horizontal scrolling in 80-column terminals)**

Keep lines under 80 characters. Long lines are hard to read and cause horizontal scrolling in code review tools and split-pane editors.

**Incorrect (exceeds 80 characters):**

```javascript
const userNotificationMessage = `Dear ${user.firstName}, your order #${order.id} has been shipped and will arrive by ${order.estimatedDelivery}`;

function processPaymentWithRetryAndNotification(userId, orderId, paymentMethod, billingAddress, shippingAddress) {
  // Long parameter list
}

import { validateUser, validateOrder, validatePayment, validateShipping, validateBilling } from './validators.js';
```

**Correct (wrapped at 80 characters):**

```javascript
const userNotificationMessage =
    `Dear ${user.firstName}, your order #${order.id} has been ` +
    `shipped and will arrive by ${order.estimatedDelivery}`;

function processPaymentWithRetryAndNotification(
    userId,
    orderId,
    paymentMethod,
    billingAddress,
    shippingAddress
) {
  // Parameters on separate lines
}

import {
  validateUser,
  validateOrder,
  validatePayment,
  validateShipping,
  validateBilling,
} from './validators.js';
```

**Exceptions (no line-wrapping required):**
- `import` and `export` statements (but wrapping is preferred)
- Long URLs in comments
- Shell commands in comments
- Long string literals that cannot be split

Reference: [Google JavaScript Style Guide - Column limit](https://google.github.io/styleguide/jsguide.html#formatting-column-limit)

### 8.3 Place One Statement Per Line

**Impact: LOW (reduces debugging time by 2-3× with clear breakpoints)**

Each statement should be on its own line. Multiple statements on one line reduce readability and make debugging harder.

**Incorrect (multiple statements per line):**

```javascript
const width = 1; const height = 2; const depth = 3;

if (isValid) { validateOrder(); processPayment(); }

for (let i = 0; i < 10; i++) { processItem(i); logProgress(i); }

let price = 1, quantity = 2, discount = 3;  // Multiple declarations
```

**Correct (one statement per line):**

```javascript
const width = 1;
const height = 2;
const depth = 3;

if (isValid) {
  validateOrder();
  processPayment();
}

for (let i = 0; i < 10; i++) {
  processItem(i);
  logProgress(i);
}

const price = 1;
const quantity = 2;
const discount = 3;
```

**Exception (related short statements):**

```javascript
// Simple guard clause on one line is acceptable
if (!user) { return null; }

// Switch case with single return
switch (type) {
  case 'a': return processA();
  case 'b': return processB();
  default: return null;
}
```

**Variable declarations:**
- One variable per `const`/`let` declaration
- Never use comma to declare multiple variables

Reference: [Google JavaScript Style Guide - One statement per line](https://google.github.io/styleguide/jsguide.html#formatting-one-statement-per-line)

### 8.4 Use Single Quotes for String Literals

**Impact: LOW (maintains consistency across codebase)**

Use single quotes (`'`) for ordinary string literals. Use template literals (backticks) for strings requiring interpolation or multiple lines.

**Incorrect (double quotes or inconsistent):**

```javascript
const name = "Alice";
const greeting = "Hello, " + name + "!";

const message = 'Welcome to the "Admin" panel';
const mixed = "Some use double" + ' and some use single';
```

**Correct (single quotes):**

```javascript
const name = 'Alice';
const greeting = 'Hello, ' + name + '!';

// Use template literals for interpolation
const greetingTemplate = `Hello, ${name}!`;

// Escape inner quotes or use template literal
const message = 'Welcome to the "Admin" panel';
const altMessage = `Welcome to the "Admin" panel`;
```

**Template literals for complex strings:**

```javascript
// Multi-line strings
const html = `
  <div class="user-card">
    <h2>${user.name}</h2>
    <p>${user.email}</p>
  </div>
`;

// Complex interpolation
const summary = `Order #${order.id}: ${order.items.length} items, $${order.total.toFixed(2)}`;
```

**When double quotes are acceptable:**
- JSON strings (required by spec)
- Strings containing many single quotes

Reference: [Google JavaScript Style Guide - String literals](https://google.github.io/styleguide/jsguide.html#features-strings)

### 8.5 Use Two-Space Indentation

**Impact: LOW (maintains consistent code appearance)**

Indent with 2 spaces per level. Never use tabs. Continuation lines should be indented at least 4 spaces from the original line.

**Incorrect (tabs or 4-space indent):**

```javascript
function processOrder(order) {
    // 4-space indent
    if (order.items) {
        for (const item of order.items) {
            validateItem(item);
        }
    }
}

function createUser(
  name,  // Only 2 spaces for continuation
  email,
  role
) {
  return { name, email, role };
}
```

**Correct (2-space indent):**

```javascript
function processOrder(order) {
  // 2-space indent
  if (order.items) {
    for (const item of order.items) {
      validateItem(item);
    }
  }
}

function createUser(
    name,  // 4-space continuation indent
    email,
    role
) {
  return { name, email, role };
}
```

**Array and object literals:**

```javascript
const config = {
  api: {
    baseUrl: 'https://api.example.com',
    timeout: 5000,
  },
  features: {
    darkMode: true,
    notifications: false,
  },
};

const items = [
  'first',
  'second',
  'third',
];
```

**Note:** Configure your editor to use spaces, not tabs. Most formatters (Prettier, clang-format) can enforce this automatically.

Reference: [Google JavaScript Style Guide - Block indentation](https://google.github.io/styleguide/jsguide.html#formatting-block-indentation)

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