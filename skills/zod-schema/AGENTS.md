# Zod

**Version 1.0.0**  
community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive schema validation guide for Zod in TypeScript applications, designed for AI agents and LLMs. Contains 43 rules across 8 categories, prioritized by impact from critical (schema definition, parsing) to incremental (performance, bundle optimization). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Schema Definition](#1-schema-definition) — **CRITICAL**
   - 1.1 [Apply String Validations at Schema Definition](#11-apply-string-validations-at-schema-definition)
   - 1.2 [Avoid Overusing Optional Fields](#12-avoid-overusing-optional-fields)
   - 1.3 [Use Coercion for Form and Query Data](#13-use-coercion-for-form-and-query-data)
   - 1.4 [Use Enums for Fixed String Values](#14-use-enums-for-fixed-string-values)
   - 1.5 [Use Primitive Schemas Correctly](#15-use-primitive-schemas-correctly)
   - 1.6 [Use z.unknown() Instead of z.any()](#16-use-zunknown-instead-of-zany)
2. [Parsing & Validation](#2-parsing-validation) — **CRITICAL**
   - 2.1 [Avoid Double Validation](#21-avoid-double-validation)
   - 2.2 [Handle All Validation Issues Not Just First](#22-handle-all-validation-issues-not-just-first)
   - 2.3 [Never Trust JSON.parse Output](#23-never-trust-jsonparse-output)
   - 2.4 [Use parseAsync for Async Refinements](#24-use-parseasync-for-async-refinements)
   - 2.5 [Use safeParse() for User Input](#25-use-safeparse-for-user-input)
   - 2.6 [Validate at System Boundaries](#26-validate-at-system-boundaries)
3. [Type Inference](#3-type-inference) — **HIGH**
   - 3.1 [Distinguish z.input from z.infer for Transforms](#31-distinguish-zinput-from-zinfer-for-transforms)
   - 3.2 [Enable TypeScript Strict Mode](#32-enable-typescript-strict-mode)
   - 3.3 [Export Both Schemas and Inferred Types](#33-export-both-schemas-and-inferred-types)
   - 3.4 [Use Branded Types for Domain Safety](#34-use-branded-types-for-domain-safety)
   - 3.5 [Use z.infer Instead of Manual Types](#35-use-zinfer-instead-of-manual-types)
4. [Error Handling](#4-error-handling) — **HIGH**
   - 4.1 [Implement Internationalized Error Messages](#41-implement-internationalized-error-messages)
   - 4.2 [Provide Custom Error Messages](#42-provide-custom-error-messages)
   - 4.3 [Return False Instead of Throwing in Refine](#43-return-false-instead-of-throwing-in-refine)
   - 4.4 [Use flatten() for Form Error Display](#44-use-flatten-for-form-error-display)
   - 4.5 [Use issue.path for Nested Error Location](#45-use-issuepath-for-nested-error-location)
5. [Object Schemas](#5-object-schemas) — **MEDIUM-HIGH**
   - 5.1 [Choose strict() vs strip() for Unknown Keys](#51-choose-strict-vs-strip-for-unknown-keys)
   - 5.2 [Distinguish optional() from nullable()](#52-distinguish-optional-from-nullable)
   - 5.3 [Use Discriminated Unions for Type Narrowing](#53-use-discriminated-unions-for-type-narrowing)
   - 5.4 [Use extend() for Adding Fields](#54-use-extend-for-adding-fields)
   - 5.5 [Use partial() for Update Schemas](#55-use-partial-for-update-schemas)
   - 5.6 [Use pick() and omit() for Schema Variants](#56-use-pick-and-omit-for-schema-variants)
6. [Schema Composition](#6-schema-composition) — **MEDIUM**
   - 6.1 [Extract Shared Schemas into Reusable Modules](#61-extract-shared-schemas-into-reusable-modules)
   - 6.2 [Use intersection() for Type Combinations](#62-use-intersection-for-type-combinations)
   - 6.3 [Use pipe() for Multi-Stage Validation](#63-use-pipe-for-multi-stage-validation)
   - 6.4 [Use preprocess() for Data Normalization](#64-use-preprocess-for-data-normalization)
   - 6.5 [Use z.lazy() for Recursive Schemas](#65-use-zlazy-for-recursive-schemas)
7. [Refinements & Transforms](#7-refinements-transforms) — **MEDIUM**
   - 7.1 [Add Path to Refinement Errors](#71-add-path-to-refinement-errors)
   - 7.2 [Choose refine() vs superRefine() Correctly](#72-choose-refine-vs-superrefine-correctly)
   - 7.3 [Distinguish transform() from refine() and coerce()](#73-distinguish-transform-from-refine-and-coerce)
   - 7.4 [Use catch() for Fault-Tolerant Parsing](#74-use-catch-for-fault-tolerant-parsing)
   - 7.5 [Use default() for Optional Fields with Defaults](#75-use-default-for-optional-fields-with-defaults)
8. [Performance & Bundle](#8-performance-bundle) — **LOW-MEDIUM**
   - 8.1 [Avoid Dynamic Schema Creation in Hot Paths](#81-avoid-dynamic-schema-creation-in-hot-paths)
   - 8.2 [Cache Schema Instances](#82-cache-schema-instances)
   - 8.3 [Lazy Load Large Schemas](#83-lazy-load-large-schemas)
   - 8.4 [Optimize Large Array Validation](#84-optimize-large-array-validation)
   - 8.5 [Use Zod Mini for Bundle-Sensitive Applications](#85-use-zod-mini-for-bundle-sensitive-applications)

---

## 1. Schema Definition

**Impact: CRITICAL**

Schema definition is the foundation of all Zod validation; incorrect or overly permissive schemas cascade errors through your entire application, allowing invalid data to corrupt downstream logic.

### 1.1 Apply String Validations at Schema Definition

**Impact: CRITICAL (Unvalidated strings allow SQL injection, XSS, and malformed data; validating at schema level catches issues at the boundary)**

Plain `z.string()` accepts any string including empty strings, extremely long strings, and malicious content. Apply constraints like `min()`, `max()`, `email()`, `url()`, or `regex()` at schema definition to reject invalid data at the boundary.

**Incorrect (no string validations):**

```typescript
import { z } from 'zod'

const commentSchema = z.object({
  author: z.string(),  // Empty string passes
  email: z.string(),  // "not-an-email" passes
  content: z.string(),  // 10MB string passes, script tags pass
  website: z.string().optional(),  // "javascript:alert(1)" passes
})

// All of these pass validation
commentSchema.parse({
  author: '',  // Empty - who wrote this?
  email: 'invalid',  // Not a real email
  content: '<script>alert("XSS")</script>'.repeat(100000),  // XSS + huge
  website: 'javascript:void(0)',  // Dangerous URL
})
```

**Correct (string validations applied):**

```typescript
import { z } from 'zod'

const commentSchema = z.object({
  author: z.string()
    .min(1, 'Author is required')
    .max(100, 'Author name too long'),

  email: z.string()
    .email('Invalid email address'),

  content: z.string()
    .min(1, 'Comment cannot be empty')
    .max(5000, 'Comment too long'),

  website: z.string()
    .url('Invalid URL')
    .refine(
      url => url.startsWith('http://') || url.startsWith('https://'),
      'Only http/https URLs allowed'
    )
    .optional(),
})

// Invalid data is rejected
commentSchema.parse({
  author: '',
  email: 'invalid',
  content: '',
})
// ZodError with all violations listed
```

**Common string validations:**

```typescript
z.string().min(1)  // Non-empty (most common need)
z.string().max(255)  // Database varchar limit
z.string().length(36)  // Exact length (UUIDs)
z.string().email()  // Email format
z.string().url()  // URL format
z.string().uuid()  // UUID format
z.string().cuid()  // CUID format
z.string().regex(/^[a-z0-9-]+$/)  // Custom pattern (slugs)
z.string().startsWith('https://')  // Prefix check
z.string().endsWith('.pdf')  // Suffix check
z.string().includes('@')  // Contains check
z.string().trim()  // Strips whitespace (transform)
z.string().toLowerCase()  // Normalizes case (transform)
```

**When NOT to use this pattern:**
- When accepting arbitrary user content for display only (sanitize on output instead)
- When building a passthrough/proxy that shouldn't validate content

Reference: [Zod API - Strings](https://zod.dev/api#strings)

### 1.2 Avoid Overusing Optional Fields

**Impact: CRITICAL (Excessive optional fields create schemas that accept almost anything; forces null checks throughout codebase)**

Making too many fields optional creates overly permissive schemas that validate almost any input. This pushes validation downstream into business logic, requiring defensive null checks everywhere instead of guaranteeing data shape at the boundary.

**Incorrect (optional abuse):**

```typescript
import { z } from 'zod'

// Every field optional - almost anything passes
const userSchema = z.object({
  id: z.string().optional(),
  name: z.string().optional(),
  email: z.string().optional(),
  role: z.string().optional(),
})

type User = z.infer<typeof userSchema>
// { id?: string; name?: string; email?: string; role?: string }

// Empty object passes validation!
userSchema.parse({})  // ✓ Valid: {}

function greetUser(user: User) {
  // Forced to add null checks everywhere
  if (user.name) {
    console.log(`Hello, ${user.name}`)
  } else {
    console.log('Hello, stranger')  // Shouldn't happen if data is clean
  }
}
```

**Correct (explicit required vs optional):**

```typescript
import { z } from 'zod'

// Required fields are required, optional fields are intentional
const userSchema = z.object({
  id: z.string().uuid(),  // Required
  name: z.string().min(1),  // Required, non-empty
  email: z.string().email(),  // Required
  role: z.enum(['admin', 'user', 'guest']),  // Required
  nickname: z.string().optional(),  // Intentionally optional
  bio: z.string().nullable(),  // Can be explicitly null
})

type User = z.infer<typeof userSchema>

// Empty object fails validation
userSchema.parse({})  // ✗ Throws ZodError

function greetUser(user: User) {
  // user.name is guaranteed to exist
  console.log(`Hello, ${user.name}`)

  // Only optional fields need checks
  if (user.nickname) {
    console.log(`Also known as: ${user.nickname}`)
  }
}
```

**Use `.partial()` for update schemas:**

```typescript
// Base schema with required fields
const userSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
})

// All fields optional for PATCH updates
const updateUserSchema = userSchema.partial()

// Only specific fields optional
const createUserSchema = userSchema.partial({ id: true })
```

**When NOT to use this pattern:**
- When modeling partial updates (PATCH endpoints)
- When fields genuinely may not exist (legacy data, external APIs)

Reference: [Zod API - optional](https://zod.dev/api#optional)

### 1.3 Use Coercion for Form and Query Data

**Impact: CRITICAL (Form data and query params are always strings; without coercion, z.number() rejects "42" and z.boolean() rejects "true")**

HTML forms and URL query parameters always transmit data as strings. Using `z.number()` on form data will fail because `"42"` is not a number. Use `z.coerce.number()` to automatically convert strings to the correct type.

**Incorrect (no coercion for form data):**

```typescript
import { z } from 'zod'

const searchSchema = z.object({
  query: z.string(),
  page: z.number(),  // Expects actual number
  limit: z.number(),
  showDeleted: z.boolean(),  // Expects actual boolean
})

// Form data / query params are strings
const formData = new URLSearchParams('query=test&page=1&limit=10&showDeleted=true')
const params = Object.fromEntries(formData)
// { query: 'test', page: '1', limit: '10', showDeleted: 'true' }

searchSchema.parse(params)
// ZodError: Expected number, received string at "page"
// ZodError: Expected number, received string at "limit"
// ZodError: Expected boolean, received string at "showDeleted"
```

**Correct (using coercion):**

```typescript
import { z } from 'zod'

const searchSchema = z.object({
  query: z.string(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  showDeleted: z.coerce.boolean().default(false),
})

// Form data / query params are strings
const formData = new URLSearchParams('query=test&page=1&limit=10&showDeleted=true')
const params = Object.fromEntries(formData)

const result = searchSchema.parse(params)
// { query: 'test', page: 1, limit: 10, showDeleted: true }
// Types are correct: number, number, boolean
```

**Available coercion types:**

```typescript
z.coerce.string()  // Converts anything to string via String(value)
z.coerce.number()  // Converts via Number(value), NaN fails validation
z.coerce.boolean()  // Truthy/falsy conversion
z.coerce.bigint()  // Converts via BigInt(value)
z.coerce.date()  // Converts via new Date(value)
```

**Coercion edge cases:**

```typescript
// z.coerce.number() behavior
z.coerce.number().parse("42")  // 42
z.coerce.number().parse("")  // 0 (empty string becomes 0!)
z.coerce.number().parse("abc")  // ZodError (NaN fails)

// z.coerce.boolean() behavior
z.coerce.boolean().parse("true")  // true
z.coerce.boolean().parse("false")  // true! (non-empty string is truthy)
z.coerce.boolean().parse("")  // false
z.coerce.boolean().parse("0")  // true! (non-empty string)

// For strict boolean parsing from strings:
const strictBooleanSchema = z.enum(['true', 'false']).transform(v => v === 'true')
```

**When NOT to use this pattern:**
- When receiving JSON payloads (already typed correctly)
- When you want strict type checking without conversion

Reference: [Zod API - Coercion](https://zod.dev/api#coercion)

### 1.4 Use Enums for Fixed String Values

**Impact: CRITICAL (Plain strings accept any value including typos; enums restrict to valid values and enable autocomplete)**

When a field should only accept specific values (status, role, type), use `z.enum()` or `z.literal()` instead of `z.string()`. Plain strings accept any value including typos, while enums provide validation, type safety, and IDE autocomplete.

**Incorrect (plain string for fixed values):**

```typescript
import { z } from 'zod'

const orderSchema = z.object({
  id: z.string(),
  status: z.string(),  // Accepts any string
  priority: z.string(),  // No constraints
})

type Order = z.infer<typeof orderSchema>
// { id: string; status: string; priority: string }

// Typos and invalid values pass validation
orderSchema.parse({
  id: '123',
  status: 'pendng',  // Typo passes
  priority: 'super-urgent',  // Invalid value passes
})

function processOrder(order: Order) {
  if (order.status === 'pending') {  // Might never match due to typos
    // ...
  }
}
```

**Correct (using z.enum):**

```typescript
import { z } from 'zod'

const OrderStatus = z.enum(['pending', 'processing', 'shipped', 'delivered'])
const Priority = z.enum(['low', 'medium', 'high'])

const orderSchema = z.object({
  id: z.string(),
  status: OrderStatus,
  priority: Priority,
})

type Order = z.infer<typeof orderSchema>
// { id: string; status: 'pending' | 'processing' | 'shipped' | 'delivered'; priority: 'low' | 'medium' | 'high' }

// Typos are caught at validation
orderSchema.parse({
  id: '123',
  status: 'pendng',  // ZodError: Invalid enum value
  priority: 'super-urgent',  // ZodError: Invalid enum value
})

// Extract enum values for reuse
OrderStatus.options  // ['pending', 'processing', 'shipped', 'delivered']
type OrderStatusType = z.infer<typeof OrderStatus>  // 'pending' | 'processing' | ...
```

**For native TypeScript enums:**

```typescript
enum Role {
  Admin = 'admin',
  User = 'user',
  Guest = 'guest',
}

// Use z.nativeEnum for TS enums
const userSchema = z.object({
  role: z.nativeEnum(Role),
})
```

**For single literal values (discriminated unions):**

```typescript
const successResponse = z.object({
  status: z.literal('success'),
  data: z.unknown(),
})

const errorResponse = z.object({
  status: z.literal('error'),
  message: z.string(),
})

const response = z.discriminatedUnion('status', [
  successResponse,
  errorResponse,
])
```

**When NOT to use this pattern:**
- When the set of valid values is dynamic or user-defined
- When values come from a database that may have more options

Reference: [Zod API - Enums](https://zod.dev/api#enums)

### 1.5 Use Primitive Schemas Correctly

**Impact: CRITICAL (Incorrect primitive selection causes validation to pass on wrong types; using z.any() or z.unknown() loses all type safety)**

Zod provides specific schemas for each primitive type. Using the wrong schema (e.g., `z.string()` when you need `z.number()`) or falling back to `z.any()` defeats the purpose of validation entirely, allowing corrupt data through.

**Incorrect (wrong primitive or any):**

```typescript
import { z } from 'zod'

// Using any loses all type safety
const userSchema = z.object({
  id: z.any(),  // Accepts anything - no validation
  age: z.string(),  // Wrong type - age should be number
  active: z.any(),  // Should be boolean
})

// This passes validation but data is wrong
userSchema.parse({ id: null, age: "twenty", active: "yes" })
// Result: { id: null, age: "twenty", active: "yes" }
```

**Correct (specific primitives):**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  id: z.string().uuid(),  // Specific format validation
  age: z.number().int().positive(),  // Correct type with constraints
  active: z.boolean(),  // Exact boolean type
})

// Now invalid data is rejected
userSchema.parse({ id: null, age: "twenty", active: "yes" })
// Throws ZodError with specific field errors
```

**Available primitive schemas:**
- `z.string()` - strings with optional regex, min, max, email, url, uuid
- `z.number()` - numbers with optional int, positive, negative, min, max
- `z.bigint()` - BigInt values
- `z.boolean()` - true/false only
- `z.date()` - Date objects
- `z.symbol()` - Symbol type
- `z.undefined()` - undefined only
- `z.null()` - null only
- `z.void()` - undefined (for function returns)
- `z.never()` - no valid value

**When NOT to use this pattern:**
- When you genuinely need to accept any value (rare - consider `z.unknown()` instead)
- When migrating legacy code incrementally (use `z.any()` temporarily, then fix)

Reference: [Zod Primitives](https://zod.dev/api#primitives)

### 1.6 Use z.unknown() Instead of z.any()

**Impact: CRITICAL (z.any() bypasses TypeScript's type system entirely; z.unknown() forces type narrowing before use)**

`z.any()` infers to `any` type, disabling TypeScript's type checking for that value. `z.unknown()` infers to `unknown`, which forces you to narrow the type before using it. This preserves type safety while still allowing any input.

**Incorrect (using z.any):**

```typescript
import { z } from 'zod'

const eventSchema = z.object({
  type: z.string(),
  payload: z.any(),  // Infers to 'any'
})

type Event = z.infer<typeof eventSchema>
// { type: string; payload: any }

function handleEvent(event: Event) {
  // No type error - TypeScript allows anything
  console.log(event.payload.foo.bar.baz)  // Runtime crash if structure is wrong
}
```

**Correct (using z.unknown):**

```typescript
import { z } from 'zod'

const eventSchema = z.object({
  type: z.string(),
  payload: z.unknown(),  // Infers to 'unknown'
})

type Event = z.infer<typeof eventSchema>
// { type: string; payload: unknown }

function handleEvent(event: Event) {
  // TypeScript error: Object is of type 'unknown'
  console.log(event.payload.foo)  // Won't compile

  // Must narrow type first
  if (typeof event.payload === 'object' && event.payload !== null) {
    // Now TypeScript knows it's an object
  }
}
```

**Better approach with discriminated unions:**

```typescript
import { z } from 'zod'

const userCreatedSchema = z.object({
  type: z.literal('user.created'),
  payload: z.object({
    userId: z.string(),
    email: z.string().email(),
  }),
})

const orderPlacedSchema = z.object({
  type: z.literal('order.placed'),
  payload: z.object({
    orderId: z.string(),
    amount: z.number(),
  }),
})

const eventSchema = z.discriminatedUnion('type', [
  userCreatedSchema,
  orderPlacedSchema,
])

// Full type safety for each event type
```

**When NOT to use this pattern:**
- When you're consuming a third-party API where you truly don't know the shape
- When prototyping and will add proper types later

Reference: [Zod API - unknown](https://zod.dev/api#unknown)

---

## 2. Parsing & Validation

**Impact: CRITICAL**

Parsing is the core Zod operation; using `parse()` vs `safeParse()` incorrectly causes either unhandled exceptions crashing your app or silent failures that let invalid data through.

### 2.1 Avoid Double Validation

**Impact: HIGH (Parsing the same data twice wastes CPU cycles; in hot paths this adds measurable latency)**

Once data is validated by Zod, trust the result. Re-validating the same data in multiple layers doubles CPU usage and adds latency. Pass the typed result through your application instead.

**Incorrect (validating at every layer):**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string(),
})

// Controller validates
export async function POST(req: NextRequest) {
  const body = await req.json()
  const user = userSchema.parse(body)  // First parse
  return await userService.create(user)
}

// Service validates again
const userService = {
  async create(data: unknown) {
    const user = userSchema.parse(data)  // Second parse - redundant
    return await userRepository.insert(user)
  }
}

// Repository validates again
const userRepository = {
  async insert(data: unknown) {
    const user = userSchema.parse(data)  // Third parse - wasteful
    return await db.users.create({ data: user })
  }
}
```

**Correct (validate once, pass typed data):**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string(),
})

type User = z.infer<typeof userSchema>

// Controller validates at boundary
export async function POST(req: NextRequest) {
  const body = await req.json()

  const result = userSchema.safeParse(body)
  if (!result.success) {
    return NextResponse.json({ errors: result.error.issues }, { status: 400 })
  }

  // Pass validated, typed data
  return await userService.create(result.data)
}

// Service receives typed data, no re-validation needed
const userService = {
  async create(user: User) {
    // user is guaranteed to match schema
    return await userRepository.insert(user)
  }
}

// Repository receives typed data
const userRepository = {
  async insert(user: User) {
    return await db.users.create({ data: user })
  }
}
```

**When you might validate at multiple layers:**

```typescript
// Different schemas for different layers
const apiUserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),  // Only in API layer
})

const dbUserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  passwordHash: z.string(),  // Transformed before storage
})

// API validates input format
export async function POST(req: NextRequest) {
  const input = apiUserSchema.parse(await req.json())
  const user = await userService.create(input)
  return NextResponse.json(user)
}

// Service transforms and validates for storage
const userService = {
  async create(input: z.infer<typeof apiUserSchema>) {
    const dbUser = dbUserSchema.parse({
      id: crypto.randomUUID(),
      email: input.email,
      passwordHash: await hash(input.password),
    })
    return await userRepository.insert(dbUser)
  }
}
```

**When NOT to use this pattern:**
- When schemas differ between layers (API vs DB shape)
- When data crosses trust boundaries (external service response)
- During development when debugging data flow

Reference: [Zod Performance](https://zod.dev/v4#performance)

### 2.2 Handle All Validation Issues Not Just First

**Impact: CRITICAL (Showing only the first error forces users to fix-submit-fix repeatedly; collecting all errors improves UX dramatically)**

Zod collects all validation failures, not just the first one. When displaying errors to users, show all issues so they can fix everything at once instead of playing whack-a-mole with one error at a time.

**Incorrect (showing only first error):**

```typescript
import { z } from 'zod'

const formSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be 8+ characters'),
  confirmPassword: z.string(),
  age: z.number().min(18, 'Must be 18 or older'),
})

function validateForm(data: unknown) {
  const result = formSchema.safeParse(data)

  if (!result.success) {
    // Only shows first error - terrible UX
    return { error: result.error.issues[0].message }
  }

  return { data: result.data }
}

// User submits empty form
validateForm({})
// Returns: { error: 'Invalid email' }
// User fixes email, submits again
// Returns: { error: 'Password must be 8+ characters' }
// User fixes password, submits again...
// 4 round trips to fix 4 errors!
```

**Correct (showing all errors):**

```typescript
import { z } from 'zod'

const formSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be 8+ characters'),
  confirmPassword: z.string(),
  age: z.number().min(18, 'Must be 18 or older'),
})

function validateForm(data: unknown) {
  const result = formSchema.safeParse(data)

  if (!result.success) {
    // Collect errors by field for form display
    const fieldErrors: Record<string, string[]> = {}

    for (const issue of result.error.issues) {
      const field = issue.path.join('.')
      if (!fieldErrors[field]) {
        fieldErrors[field] = []
      }
      fieldErrors[field].push(issue.message)
    }

    return { errors: fieldErrors }
  }

  return { data: result.data }
}

// User submits empty form
validateForm({})
// Returns: {
//   errors: {
//     email: ['Invalid email'],
//     password: ['Password must be 8+ characters'],
//     confirmPassword: ['Required'],
//     age: ['Expected number, received undefined']
//   }
// }
// User sees ALL errors, fixes everything, submits once!
```

**Using flatten() for simpler error structure:**

```typescript
const result = formSchema.safeParse(data)

if (!result.success) {
  const flattened = result.error.flatten()
  // {
  //   formErrors: [],  // Top-level errors
  //   fieldErrors: {
  //     email: ['Invalid email'],
  //     password: ['Password must be 8+ characters'],
  //     ...
  //   }
  // }
  return { errors: flattened.fieldErrors }
}
```

**With React Hook Form integration:**

```typescript
import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'

const form = useForm({
  resolver: zodResolver(formSchema),
  // All errors are automatically collected and displayed
})
```

**When NOT to use this pattern:**
- Rate-limited APIs where you want to fail fast on first error
- Large batch processing where full validation is expensive

Reference: [Zod Error Handling](https://zod.dev/error-handling)

### 2.3 Never Trust JSON.parse Output

**Impact: CRITICAL (JSON.parse returns any type; unvalidated JSON allows type confusion attacks and runtime crashes)**

`JSON.parse()` returns `any` (or `unknown` in strict mode), providing no type guarantees. Always validate JSON output with Zod before using it, even if you control the JSON source. This catches corruption, version mismatches, and ensures type safety.

**Incorrect (trusting JSON.parse):**

```typescript
// JSON.parse returns any - no type safety
const config = JSON.parse(fs.readFileSync('config.json', 'utf-8'))
// config is 'any' - TypeScript allows anything

// This might crash at runtime if structure changed
console.log(config.database.host)  // TypeError: Cannot read property 'host' of undefined

// API response - also unvalidated
const response = await fetch('/api/user')
const user = await response.json()  // any type
console.log(user.name.toUpperCase())  // Crash if name is null/undefined
```

**Correct (validate after JSON.parse):**

```typescript
import { z } from 'zod'

const configSchema = z.object({
  database: z.object({
    host: z.string(),
    port: z.number(),
    name: z.string(),
  }),
  api: z.object({
    key: z.string(),
    timeout: z.number().default(5000),
  }),
})

// Parse JSON then validate
const rawConfig = JSON.parse(fs.readFileSync('config.json', 'utf-8'))
const config = configSchema.parse(rawConfig)
// config is fully typed: { database: { host: string, ... }, ... }

// API response validation
const userSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
})

const response = await fetch('/api/user')
const rawUser = await response.json()
const user = userSchema.parse(rawUser)
// user is fully typed and validated
```

**Helper for validated JSON parsing:**

```typescript
function parseJSON<T>(schema: z.ZodType<T>, json: string): T {
  return schema.parse(JSON.parse(json))
}

function safeParseJSON<T>(schema: z.ZodType<T>, json: string) {
  try {
    return { success: true as const, data: schema.parse(JSON.parse(json)) }
  } catch (error) {
    if (error instanceof SyntaxError) {
      return { success: false as const, error: 'Invalid JSON' }
    }
    if (error instanceof z.ZodError) {
      return { success: false as const, error: error.issues }
    }
    throw error
  }
}

// Usage
const config = parseJSON(configSchema, fs.readFileSync('config.json', 'utf-8'))
```

**Validate localStorage/sessionStorage:**

```typescript
const cartSchema = z.array(z.object({
  productId: z.string(),
  quantity: z.number().int().positive(),
}))

function getCart() {
  const raw = localStorage.getItem('cart')
  if (!raw) return []

  const result = cartSchema.safeParse(JSON.parse(raw))
  if (!result.success) {
    // Corrupted cart data - clear it
    localStorage.removeItem('cart')
    return []
  }
  return result.data
}
```

**When NOT to use this pattern:**
- When you genuinely need to pass through arbitrary JSON without processing

Reference: [Zod API - parse](https://zod.dev/api#parse)

### 2.4 Use parseAsync for Async Refinements

**Impact: CRITICAL (Using parse() with async refinements throws an error; async validation silently fails or crashes the application)**

If your schema uses `refine()` or `superRefine()` with async validation (like database lookups), you must use `parseAsync()` or `safeParseAsync()`. Using synchronous `parse()` with async refinements throws an error.

**Incorrect (sync parse with async refinement):**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  email: z.string().email(),
  username: z.string().min(3),
}).refine(
  async (data) => {
    // Async database check
    const exists = await db.users.findByEmail(data.email)
    return !exists
  },
  { message: 'Email already registered' }
)

// This throws an error!
const user = userSchema.parse(formData)
// Error: Async refinement encountered during synchronous parse operation.
// Use .parseAsync instead.
```

**Correct (using parseAsync):**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  email: z.string().email(),
  username: z.string().min(3),
}).refine(
  async (data) => {
    const exists = await db.users.findByEmail(data.email)
    return !exists
  },
  { message: 'Email already registered' }
)

// Use parseAsync for async refinements
const user = await userSchema.parseAsync(formData)

// Or safeParseAsync for error handling
const result = await userSchema.safeParseAsync(formData)
if (!result.success) {
  console.log(result.error.issues)
}
```

**Async transforms also require parseAsync:**

```typescript
const enrichedUserSchema = z.object({
  userId: z.string().uuid(),
}).transform(async (data) => {
  // Async data enrichment
  const user = await db.users.findById(data.userId)
  return {
    ...data,
    email: user.email,
    name: user.name,
  }
})

// Must use parseAsync
const enrichedUser = await enrichedUserSchema.parseAsync({ userId: '123' })
```

**Pattern for API routes:**

```typescript
import { z } from 'zod'
import { NextRequest, NextResponse } from 'next/server'

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
}).superRefine(async (data, ctx) => {
  const existingUser = await db.users.findByEmail(data.email)
  if (existingUser) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['email'],
      message: 'Email already registered',
    })
  }
})

export async function POST(req: NextRequest) {
  const body = await req.json()

  // Always use safeParseAsync with async schemas
  const result = await registerSchema.safeParseAsync(body)

  if (!result.success) {
    return NextResponse.json({ errors: result.error.issues }, { status: 400 })
  }

  // Proceed with registration
}
```

**When NOT to use this pattern:**
- Schemas with only synchronous validation (use parse/safeParse)
- When async validation can be moved outside Zod (validate, then check)

Reference: [Zod API - parseAsync](https://zod.dev/api#parseasync)

### 2.5 Use safeParse() for User Input

**Impact: CRITICAL (parse() throws exceptions on invalid data; unhandled exceptions crash servers and expose stack traces to users)**

`parse()` throws a `ZodError` when validation fails, which crashes your application if not caught. `safeParse()` returns a result object that you can inspect without try/catch. Use `safeParse()` for any user-provided or external data.

**Incorrect (parse without error handling):**

```typescript
import { z } from 'zod'
import { NextRequest, NextResponse } from 'next/server'

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
})

export async function POST(req: NextRequest) {
  const body = await req.json()

  // If validation fails, this throws and crashes the handler
  const user = createUserSchema.parse(body)

  // Never reached if parse throws
  await db.users.create({ data: user })
  return NextResponse.json({ success: true })
}
// Result: 500 Internal Server Error with stack trace
```

**Correct (using safeParse):**

```typescript
import { z } from 'zod'
import { NextRequest, NextResponse } from 'next/server'

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
})

export async function POST(req: NextRequest) {
  const body = await req.json()

  const result = createUserSchema.safeParse(body)

  if (!result.success) {
    // Return structured error response
    return NextResponse.json(
      { error: 'Validation failed', issues: result.error.issues },
      { status: 400 }
    )
  }

  // result.data is typed correctly
  await db.users.create({ data: result.data })
  return NextResponse.json({ success: true })
}
```

**The result object structure:**

```typescript
// Success case
{ success: true, data: T }

// Error case
{ success: false, error: ZodError }

// Type narrowing works automatically
if (result.success) {
  result.data  // T - fully typed
} else {
  result.error  // ZodError
  result.error.issues  // Array of validation issues
}
```

**When parse() is acceptable:**

```typescript
// Internal data you control - parse is fine
const config = configSchema.parse(JSON.parse(process.env.CONFIG))

// Test assertions - parse throws helpful errors
expect(() => schema.parse(invalidData)).toThrow()

// Schema development - see errors immediately
schema.parse(testData)  // See what fails during development
```

**When NOT to use this pattern:**
- Internal configuration parsing where invalid data should crash early
- Tests where you want exceptions to fail the test
- Scripts where you want to see the full error

Reference: [Zod API - safeParse](https://zod.dev/api#safeparse)

### 2.6 Validate at System Boundaries

**Impact: CRITICAL (Validating deep in business logic allows corrupt data to propagate; validating at boundaries catches issues before they spread)**

Validate external data immediately when it enters your system—at API endpoints, form handlers, message queue consumers, and configuration loaders. Validating deep in business logic allows corrupt data to propagate and makes debugging harder.

**Incorrect (validating deep in business logic):**

```typescript
import { z } from 'zod'

// No validation at API boundary
export async function POST(req: NextRequest) {
  const body = await req.json()
  // Raw unknown data passed through
  return await processOrder(body)
}

async function processOrder(data: unknown) {
  // Data passed around unvalidated
  const items = await calculateTotals(data)
  return await chargeCustomer(data, items)
}

async function calculateTotals(data: unknown) {
  // Finally validating way too late
  const order = orderSchema.parse(data)  // Throws here, far from entry point
  // ...
}
// Hard to trace where bad data came from
```

**Correct (validating at boundary):**

```typescript
import { z } from 'zod'

const orderSchema = z.object({
  customerId: z.string().uuid(),
  items: z.array(z.object({
    productId: z.string(),
    quantity: z.number().int().positive(),
  })).min(1),
  shippingAddress: z.object({
    street: z.string(),
    city: z.string(),
    country: z.string(),
  }),
})

type Order = z.infer<typeof orderSchema>

// Validate immediately at boundary
export async function POST(req: NextRequest) {
  const body = await req.json()

  const result = orderSchema.safeParse(body)
  if (!result.success) {
    return NextResponse.json(
      { error: 'Invalid order', issues: result.error.issues },
      { status: 400 }
    )
  }

  // Now data is validated and typed
  return await processOrder(result.data)
}

// Business logic receives typed, validated data
async function processOrder(order: Order) {
  // order is guaranteed to match schema
  const items = await calculateTotals(order)
  return await chargeCustomer(order, items)
}

async function calculateTotals(order: Order) {
  // No validation needed - type guarantees shape
  return order.items.map(item => ({
    ...item,
    total: item.quantity * getPrice(item.productId),
  }))
}
```

**Boundaries to validate:**

```typescript
// API endpoints
export async function POST(req: NextRequest) {
  const data = await req.json()
  const validated = requestSchema.safeParse(data)
  // ...
}

// Message queue consumers
async function handleMessage(rawMessage: string) {
  const data = JSON.parse(rawMessage)
  const validated = messageSchema.safeParse(data)
  // ...
}

// Configuration loading
const config = configSchema.parse(JSON.parse(process.env.CONFIG!))

// External API responses
const response = await fetch('/api/users')
const data = await response.json()
const users = usersResponseSchema.parse(data)
```

**When NOT to use this pattern:**
- Internal function calls with already-validated data
- Performance-critical hot paths (validate once, trust afterward)

Reference: [Zod with TypeScript for Server-side Validation](https://stack.convex.dev/typescript-zod-function-validation)

---

## 3. Type Inference

**Impact: HIGH**

Zod's TypeScript integration eliminates duplicate type definitions; poor inference practices force manual type declarations that drift from schemas, losing the core benefit of Zod.

### 3.1 Distinguish z.input from z.infer for Transforms

**Impact: HIGH (Using wrong type with transforms causes TypeScript errors; z.input captures pre-transform shape, z.infer captures post-transform)**

When schemas use `.transform()`, the input and output types differ. `z.infer` (same as `z.output`) gives the post-transform type, while `z.input` gives the pre-transform type. Using the wrong one causes confusing TypeScript errors.

**Incorrect (using infer for input type):**

```typescript
import { z } from 'zod'

const dateSchema = z.string().transform(s => new Date(s))

type DateOutput = z.infer<typeof dateSchema>
// Date (post-transform)

// Wrong! Expecting Date but should accept string
function handleDate(input: DateOutput) {
  return dateSchema.parse(input)  // Error: Argument of type 'Date' is not assignable to type 'string'
}

// Caller passes string, but type says Date
handleDate('2024-01-15')  // TypeScript error
```

**Correct (using z.input for pre-transform type):**

```typescript
import { z } from 'zod'

const dateSchema = z.string().transform(s => new Date(s))

// Input type = what parse() accepts
type DateInput = z.input<typeof dateSchema>
// string (pre-transform)

// Output type = what parse() returns
type DateOutput = z.output<typeof dateSchema>
// Date (post-transform)

// Use input type for function parameters
function handleDate(input: DateInput) {
  const parsed = dateSchema.parse(input)  // parsed is Date
  return parsed
}

handleDate('2024-01-15')  // Works - string input
```

**Complex example with object transforms:**

```typescript
const apiUserSchema = z.object({
  id: z.string(),
  created_at: z.string().transform(s => new Date(s)),
  tags: z.string().transform(s => s.split(',')),
  is_active: z.union([z.boolean(), z.literal(1), z.literal(0)])
    .transform(v => Boolean(v)),
})

// What the API sends
type ApiUserInput = z.input<typeof apiUserSchema>
// {
//   id: string
//   created_at: string
//   tags: string
//   is_active: boolean | 1 | 0
// }

// What your code works with
type ApiUser = z.infer<typeof apiUserSchema>
// {
//   id: string
//   created_at: Date
//   tags: string[]
//   is_active: boolean
// }

// API response handler
function handleApiResponse(rawData: ApiUserInput) {
  const user = apiUserSchema.parse(rawData)
  // user.created_at is Date
  // user.tags is string[]
  // user.is_active is boolean
  return user
}
```

**Using with function types:**

```typescript
const formSchema = z.object({
  amount: z.string().transform(s => parseFloat(s)),
  quantity: z.string().transform(s => parseInt(s, 10)),
})

type FormInput = z.input<typeof formSchema>
type FormOutput = z.output<typeof formSchema>

// Form handler receives raw strings
type FormHandler = (input: FormInput) => Promise<void>

// Business logic receives parsed values
type OrderProcessor = (order: FormOutput) => Promise<void>
```

**When NOT to use this pattern:**
- Schemas without transforms (input and output are identical)
- When you only work with validated data (just use z.infer)

Reference: [Zod - Type Inference](https://zod.dev/api#type-inference)

### 3.2 Enable TypeScript Strict Mode

**Impact: HIGH (Without strict mode, Zod's type inference is unreliable; undefined and null slip through, defeating the purpose of validation)**

Zod requires TypeScript's strict mode to work correctly. Without it, `undefined` sneaks into types, `null` checks are bypassed, and type inference becomes unreliable. This undermines the type safety that Zod provides.

**Incorrect (strict mode disabled):**

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": false
  }
}
```

```typescript
import { z } from 'zod'

const userSchema = z.object({
  name: z.string(),
  email: z.string().email(),
})

type User = z.infer<typeof userSchema>
// With strict:false, type might include undefined implicitly

function processUser(user: User) {
  // No error even if user.name could be undefined
  console.log(user.name.toUpperCase())  // Potential runtime crash
}

// TypeScript allows calling with undefined
processUser(undefined as any)  // No warning
```

**Correct (strict mode enabled):**

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true
  }
}
```

```typescript
import { z } from 'zod'

const userSchema = z.object({
  name: z.string(),
  email: z.string().email(),
})

type User = z.infer<typeof userSchema>
// { name: string; email: string } - no implicit undefined

function processUser(user: User) {
  // TypeScript knows name is always string
  console.log(user.name.toUpperCase())  // Safe
}

// TypeScript catches potential undefined
processUser(undefined as any)  // Error with strict null checks
```

**Minimum strict settings for Zod:**

```json
// tsconfig.json
{
  "compilerOptions": {
    // Full strict mode (recommended)
    "strict": true,

    // Or at minimum, enable these:
    "strictNullChecks": true,
    "noImplicitAny": true
  }
}
```

**Common errors when strict mode is disabled:**

```typescript
// Without strictNullChecks
const schema = z.string().optional()
type MaybeString = z.infer<typeof schema>
// Should be: string | undefined
// Without strict: just string (undefined is implicit)

// Without noImplicitAny
const schema = z.object({ name: z.string() })
schema.parse(data)  // data could be 'any', bypassing validation
```

**Migrating to strict mode:**

```typescript
// If enabling strict breaks existing code, fix issues incrementally
// Common fixes:

// 1. Add null checks
if (user.name !== undefined) {
  console.log(user.name.toUpperCase())
}

// 2. Add explicit types
function processData(data: unknown) {  // Was implicit any
  const validated = schema.parse(data)
}

// 3. Handle optional fields
const user: User = {
  name: 'John',
  email: 'john@example.com',  // Now required, was optional without strict
}
```

**When NOT to use this pattern:**
- Never - always enable strict mode for Zod projects

Reference: [Zod Requirements](https://zod.dev/#requirements)

### 3.3 Export Both Schemas and Inferred Types

**Impact: HIGH (Exporting only schemas forces consumers to derive types themselves; exporting both reduces boilerplate and improves DX)**

When defining schemas in shared modules, export both the schema and its inferred type. This saves consumers from writing `z.infer<typeof schema>` repeatedly and makes imports cleaner.

**Incorrect (exporting only schema):**

```typescript
// schemas/user.ts
import { z } from 'zod'

export const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string(),
  role: z.enum(['admin', 'user']),
})

// Every consumer must derive the type
// api/users.ts
import { userSchema } from '@/schemas/user'
import type { z } from 'zod'

type User = z.infer<typeof userSchema>  // Repeated everywhere

// components/UserCard.tsx
import { userSchema } from '@/schemas/user'
import type { z } from 'zod'

type User = z.infer<typeof userSchema>  // Same boilerplate again
```

**Correct (exporting schema and type):**

```typescript
// schemas/user.ts
import { z } from 'zod'

export const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string(),
  role: z.enum(['admin', 'user']),
})

export type User = z.infer<typeof userSchema>

// For schemas with transforms, export both
export const apiUserSchema = z.object({
  id: z.string(),
  created_at: z.string().transform(s => new Date(s)),
})

export type ApiUserInput = z.input<typeof apiUserSchema>
export type ApiUser = z.infer<typeof apiUserSchema>
```

```typescript
// api/users.ts - clean import
import { userSchema, type User } from '@/schemas/user'

async function getUser(id: string): Promise<User> {
  const data = await db.users.findUnique({ where: { id } })
  return userSchema.parse(data)
}

// components/UserCard.tsx - just the type
import type { User } from '@/schemas/user'

function UserCard({ user }: { user: User }) {
  return <div>{user.name}</div>
}
```

**Organizing schema exports:**

```typescript
// schemas/index.ts - barrel file for schemas
export { userSchema, type User, type UserInput } from './user'
export { orderSchema, type Order } from './order'
export { productSchema, type Product } from './product'

// Usage
import { userSchema, type User, type Order } from '@/schemas'
```

**With enums, export the enum values too:**

```typescript
// schemas/user.ts
export const UserRole = z.enum(['admin', 'user', 'guest'])
export type UserRole = z.infer<typeof UserRole>

export const userSchema = z.object({
  id: z.string(),
  role: UserRole,
})

export type User = z.infer<typeof userSchema>

// Access enum values
UserRole.options  // ['admin', 'user', 'guest']
UserRole.enum.admin  // 'admin'
```

**When NOT to use this pattern:**
- Internal schemas that won't be used outside the module
- Transient schemas used only for validation (not as types)

Reference: [Zod API - Type Inference](https://zod.dev/api#type-inference)

### 3.4 Use Branded Types for Domain Safety

**Impact: HIGH (Plain string IDs are interchangeable, allowing userId where orderId is expected; branded types catch these bugs at compile time)**

Plain strings and numbers are interchangeable in TypeScript's structural type system—a `userId` can be passed where an `orderId` is expected. Zod's `.brand()` creates nominal types that prevent mixing up semantically different values.

**Incorrect (plain IDs are interchangeable):**

```typescript
import { z } from 'zod'

const userIdSchema = z.string().uuid()
const orderIdSchema = z.string().uuid()

type UserId = z.infer<typeof userIdSchema>  // string
type OrderId = z.infer<typeof orderIdSchema>  // string - same type!

async function getOrder(orderId: OrderId) {
  return db.orders.findUnique({ where: { id: orderId } })
}

const userId: UserId = '550e8400-e29b-41d4-a716-446655440000'
getOrder(userId)  // No error! TypeScript allows this bug
// Runtime: queries orders table with user ID, returns nothing or wrong data
```

**Correct (using branded types):**

```typescript
import { z } from 'zod'

const userIdSchema = z.string().uuid().brand<'UserId'>()
const orderIdSchema = z.string().uuid().brand<'OrderId'>()

type UserId = z.infer<typeof userIdSchema>
// string & { __brand: 'UserId' }

type OrderId = z.infer<typeof orderIdSchema>
// string & { __brand: 'OrderId' }

async function getOrder(orderId: OrderId) {
  return db.orders.findUnique({ where: { id: orderId } })
}

const userId = userIdSchema.parse('550e8400-e29b-41d4-a716-446655440000')
getOrder(userId)  // TypeScript error: Argument of type 'UserId' is not assignable to parameter of type 'OrderId'

const orderId = orderIdSchema.parse('660e8400-e29b-41d4-a716-446655440001')
getOrder(orderId)  // Works correctly
```

**Common branded types:**

```typescript
// IDs for different entities
const UserId = z.string().uuid().brand<'UserId'>()
const ProductId = z.string().uuid().brand<'ProductId'>()
const OrderId = z.string().uuid().brand<'OrderId'>()

// Email (validated and branded)
const Email = z.string().email().brand<'Email'>()

// Positive numbers
const PositiveInt = z.number().int().positive().brand<'PositiveInt'>()

// Money amounts (in cents)
const Cents = z.number().int().nonnegative().brand<'Cents'>()

// Slugs
const Slug = z.string().regex(/^[a-z0-9-]+$/).brand<'Slug'>()
```

**Using with object schemas:**

```typescript
const User = z.object({
  id: z.string().uuid().brand<'UserId'>(),
  email: z.string().email().brand<'Email'>(),
  referredBy: z.string().uuid().brand<'UserId'>().optional(),
})

type User = z.infer<typeof User>

function sendReferralBonus(
  referrerId: z.infer<typeof User>['id'],
  refereeId: z.infer<typeof User>['id']
) {
  // Can't accidentally swap these - both are UserId but distinct values
}
```

**When NOT to use this pattern:**
- Simple applications without ID confusion risk
- When interoperating with external systems that expect plain strings
- Performance-critical paths (brand adds tiny overhead)

Reference: [Zod API - brand](https://zod.dev/api#brand)

### 3.5 Use z.infer Instead of Manual Types

**Impact: HIGH (Manual type definitions drift from schemas over time; z.infer guarantees types match validation exactly)**

Defining TypeScript types separately from Zod schemas creates duplication that inevitably drifts. When you update a schema, you must remember to update the type—and you will forget. Use `z.infer<typeof schema>` to derive types from schemas automatically.

**Incorrect (manual type definitions):**

```typescript
import { z } from 'zod'

// Manual type definition
interface User {
  id: string
  name: string
  email: string
  age: number
}

// Separate schema
const userSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive(),
  role: z.enum(['admin', 'user']),  // Added to schema, forgot to add to interface!
})

// Type and schema are now out of sync
function createUser(user: User) {
  const validated = userSchema.parse(user)  // Has role
  saveToDb(user)  // Missing role - TypeScript doesn't warn
}
```

**Correct (using z.infer):**

```typescript
import { z } from 'zod'

// Schema is the single source of truth
const userSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive(),
  role: z.enum(['admin', 'user']),
})

// Type is always in sync with schema
type User = z.infer<typeof userSchema>
// { id: string; name: string; email: string; age: number; role: 'admin' | 'user' }

function createUser(user: User) {
  // user.role exists because type is derived from schema
  const validated = userSchema.parse(user)
  saveToDb(validated)
}
```

**Input vs Output types with transforms:**

```typescript
const userSchema = z.object({
  name: z.string(),
  createdAt: z.string().transform(s => new Date(s)),  // String in, Date out
})

// z.infer gives output type (after transforms)
type User = z.infer<typeof userSchema>
// { name: string; createdAt: Date }

// z.input gives input type (before transforms)
type UserInput = z.input<typeof userSchema>
// { name: string; createdAt: string }

// Use input type for function parameters accepting raw data
function processUser(input: UserInput) {
  const user = userSchema.parse(input)  // user is User type
  return user.createdAt.getTime()  // Date methods available
}
```

**Naming convention:**

```typescript
// Schema named with Schema suffix
const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
})

// Type named without suffix
type User = z.infer<typeof UserSchema>

// Alternative: lowercase schema, uppercase type
const userSchema = z.object({/*...*/})
type User = z.infer<typeof userSchema>
```

**When NOT to use this pattern:**
- When you need a type that's different from the validation schema
- When interfacing with external types you don't control

Reference: [Zod - Type Inference](https://zod.dev/api#type-inference)

---

## 4. Error Handling

**Impact: HIGH**

Error handling determines user experience; poorly structured error handling produces cryptic messages that harm UX and make debugging validation failures nearly impossible.

### 4.1 Implement Internationalized Error Messages

**Impact: HIGH (Hardcoded English messages exclude non-English users; error maps enable localized messages for global applications)**

Hardcoded error messages in English exclude users who speak other languages. Use Zod's error map feature to provide localized messages based on user locale, making your application accessible globally.

**Incorrect (hardcoded English messages):**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  email: z.string().email('Invalid email address'),
  age: z.number().min(18, 'You must be at least 18 years old'),
})

// French users see English errors - poor UX
```

**Correct (localized error messages):**

```typescript
import { z } from 'zod'

// Translation dictionaries
const translations = {
  en: {
    required: 'This field is required',
    invalidEmail: 'Please enter a valid email address',
    tooShort: (min: number) => `Must be at least ${min} characters`,
    tooYoung: (min: number) => `You must be at least ${min} years old`,
  },
  fr: {
    required: 'Ce champ est obligatoire',
    invalidEmail: 'Veuillez entrer une adresse email valide',
    tooShort: (min: number) => `Doit contenir au moins ${min} caractères`,
    tooYoung: (min: number) => `Vous devez avoir au moins ${min} ans`,
  },
  es: {
    required: 'Este campo es requerido',
    invalidEmail: 'Por favor ingrese un correo electrónico válido',
    tooShort: (min: number) => `Debe tener al menos ${min} caracteres`,
    tooYoung: (min: number) => `Debes tener al menos ${min} años`,
  },
} as const

type Locale = keyof typeof translations

function createErrorMap(locale: Locale): z.ZodErrorMap {
  const t = translations[locale]

  return (issue, ctx) => {
    switch (issue.code) {
      case z.ZodIssueCode.invalid_type:
        if (issue.received === 'undefined') {
          return { message: t.required }
        }
        break

      case z.ZodIssueCode.invalid_string:
        if (issue.validation === 'email') {
          return { message: t.invalidEmail }
        }
        break

      case z.ZodIssueCode.too_small:
        if (issue.type === 'string') {
          return { message: t.tooShort(issue.minimum as number) }
        }
        if (issue.type === 'number') {
          return { message: t.tooYoung(issue.minimum as number) }
        }
        break
    }

    return { message: ctx.defaultError }
  }
}

// Usage with user's locale
const userLocale: Locale = 'fr'
const errorMap = createErrorMap(userLocale)

const userSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().min(18),
})

const result = userSchema.safeParse(
  { name: '', email: 'bad', age: 15 },
  { errorMap }
)

// French error messages:
// - "Ce champ est obligatoire"
// - "Veuillez entrer une adresse email valide"
// - "Vous devez avoir au moins 18 ans"
```

**Setting error map globally:**

```typescript
// At application startup
const userLocale = getUserLocale()  // From cookie, header, etc.
z.setErrorMap(createErrorMap(userLocale))

// All schemas now use localized messages
```

**With i18n libraries (react-intl, i18next):**

```typescript
import { useIntl } from 'react-intl'

function useZodErrorMap() {
  const intl = useIntl()

  return (issue: z.ZodIssue, ctx: z.ErrorMapCtx) => {
    switch (issue.code) {
      case z.ZodIssueCode.too_small:
        return {
          message: intl.formatMessage(
            { id: 'validation.tooShort' },
            { min: issue.minimum }
          )
        }
      // ...
    }
    return { message: ctx.defaultError }
  }
}
```

**When NOT to use this pattern:**
- Internal tools used only by your team
- Single-language applications

Reference: [Zod Error Customization - Internationalization](https://zod.dev/error-customization#internationalization)

### 4.2 Provide Custom Error Messages

**Impact: HIGH (Default messages like "Expected string, received number" confuse users; custom messages like "Email is required" are actionable)**

Zod's default error messages are technical and confusing for end users. Provide custom messages that are clear, specific, and actionable. This dramatically improves user experience when validation fails.

**Incorrect (default error messages):**

```typescript
import { z } from 'zod'

const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  age: z.number().min(18),
})

signupSchema.parse({ email: 'bad', password: '123', age: 15 })
// ZodError issues:
// - "Invalid email"
// - "String must contain at least 8 character(s)"
// - "Number must be greater than or equal to 18"
// Users see: "String must contain at least 8 character(s)" - what string?
```

**Correct (custom error messages):**

```typescript
import { z } from 'zod'

const signupSchema = z.object({
  email: z.string({
    required_error: 'Email is required',
    invalid_type_error: 'Email must be text',
  }).email('Please enter a valid email address'),

  password: z.string({
    required_error: 'Password is required',
  }).min(8, 'Password must be at least 8 characters'),

  age: z.number({
    required_error: 'Age is required',
    invalid_type_error: 'Age must be a number',
  }).min(18, 'You must be at least 18 years old'),
})

signupSchema.parse({ email: 'bad', password: '123', age: 15 })
// ZodError issues:
// - "Please enter a valid email address"
// - "Password must be at least 8 characters"
// - "You must be at least 18 years old"
```

**Message types and when they trigger:**

```typescript
const schema = z.string({
  // When field is undefined
  required_error: 'This field is required',

  // When field is wrong type (e.g., number instead of string)
  invalid_type_error: 'This field must be text',

  // Fallback for any other error
  message: 'Invalid value',
})
.min(1, 'Cannot be empty')  // When length < 1
.max(100, 'Too long')  // When length > 100
.email('Invalid email format')  // When format fails
```

**Using error maps for consistent messaging:**

```typescript
const customErrorMap: z.ZodErrorMap = (issue, ctx) => {
  // Customize messages by error code
  if (issue.code === z.ZodIssueCode.too_small) {
    if (issue.type === 'string') {
      return { message: `Must be at least ${issue.minimum} characters` }
    }
    if (issue.type === 'number') {
      return { message: `Must be at least ${issue.minimum}` }
    }
  }

  if (issue.code === z.ZodIssueCode.invalid_type) {
    if (issue.expected === 'string') {
      return { message: 'Must be text' }
    }
  }

  // Default to Zod's message
  return { message: ctx.defaultError }
}

// Apply globally
z.setErrorMap(customErrorMap)

// Or per-schema
schema.parse(data, { errorMap: customErrorMap })
```

**Good error message principles:**
- Say what's wrong: "Password too short" not "Invalid password"
- Say how to fix it: "at least 8 characters" not just "too short"
- Use user's language: "email" not "string field at path .email"
- Be specific: "Must be a positive number" not "Invalid"

**When NOT to use this pattern:**
- Internal development scripts where technical errors are fine
- When you'll map errors to user-facing messages in the UI layer

Reference: [Zod Error Customization](https://zod.dev/error-customization)

### 4.3 Return False Instead of Throwing in Refine

**Impact: HIGH (Throwing in refine stops validation early, hiding other errors; returning false allows Zod to collect all issues)**

When using `.refine()` for custom validation, return `false` for invalid data instead of throwing an error. Throwing stops validation immediately, preventing Zod from collecting other validation errors. This results in poor UX where users fix one error only to discover another.

**Incorrect (throwing in refine):**

```typescript
import { z } from 'zod'

const passwordSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine((data) => {
  if (data.password !== data.confirmPassword) {
    // Throwing stops all further validation
    throw new Error('Passwords do not match')
  }
  return true
})

const formSchema = z.object({
  email: z.string().email(),
  passwords: passwordSchema,
  terms: z.boolean().refine((v) => v === true, 'Must accept terms'),
})

// If passwords don't match, user never learns about other errors
formSchema.safeParse({
  email: 'bad-email',
  passwords: { password: '12345678', confirmPassword: 'different' },
  terms: false,
})
// Only shows: "Passwords do not match"
// Hidden: "Invalid email", "Must accept terms"
```

**Correct (returning false in refine):**

```typescript
import { z } from 'zod'

const passwordSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine(
  (data) => data.password === data.confirmPassword,
  { message: 'Passwords do not match', path: ['confirmPassword'] }
)

const formSchema = z.object({
  email: z.string().email(),
  passwords: passwordSchema,
  terms: z.boolean().refine((v) => v === true, 'Must accept terms'),
})

// All errors are collected
formSchema.safeParse({
  email: 'bad-email',
  passwords: { password: '12345678', confirmPassword: 'different' },
  terms: false,
})
// Shows all errors:
// - "Invalid email"
// - "Passwords do not match"
// - "Must accept terms"
```

**For multiple validation rules, use superRefine:**

```typescript
const passwordSchema = z.string().superRefine((password, ctx) => {
  // Check multiple rules, report all failures
  if (password.length < 8) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Password must be at least 8 characters',
    })
  }

  if (!/[A-Z]/.test(password)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Password must contain an uppercase letter',
    })
  }

  if (!/[0-9]/.test(password)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Password must contain a number',
    })
  }

  // Don't return anything - issues are added via ctx
})

passwordSchema.safeParse('weak')
// All three errors reported at once
```

**Correct pattern for async validation:**

```typescript
const schema = z.object({
  email: z.string().email(),
}).refine(
  async (data) => {
    // Return boolean, don't throw
    const exists = await checkEmailExists(data.email)
    return !exists
  },
  { message: 'Email already registered', path: ['email'] }
)
```

**When NOT to use this pattern:**
- When you need to abort validation entirely (security issues)
- When subsequent validations depend on current check passing

Reference: [Zod API - Refine](https://zod.dev/api#refine)

### 4.4 Use flatten() for Form Error Display

**Impact: HIGH (Raw ZodError.issues requires manual path parsing; flatten() provides field-keyed errors ready for form display)**

`ZodError.issues` is an array that requires manual processing to map errors to form fields. `ZodError.flatten()` returns an object with `fieldErrors` keyed by field name, ready for form libraries and UI display.

**Incorrect (manual issue processing):**

```typescript
import { z } from 'zod'

const formSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password too short'),
  profile: z.object({
    name: z.string().min(1, 'Name required'),
  }),
})

function getFieldErrors(error: z.ZodError) {
  const errors: Record<string, string> = {}

  for (const issue of error.issues) {
    // Manual path joining - error prone
    const field = issue.path.join('.')
    if (!errors[field]) {
      errors[field] = issue.message
    }
  }

  return errors
}

const result = formSchema.safeParse(data)
if (!result.success) {
  const errors = getFieldErrors(result.error)
  // { email: 'Invalid email', 'profile.name': 'Name required' }
}
```

**Correct (using flatten):**

```typescript
import { z } from 'zod'

const formSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password too short'),
  profile: z.object({
    name: z.string().min(1, 'Name required'),
  }),
})

const result = formSchema.safeParse(data)

if (!result.success) {
  const { formErrors, fieldErrors } = result.error.flatten()

  // formErrors: string[] - top-level errors (from .refine on the object)
  // fieldErrors: { [key]: string[] } - errors by field

  // Ready for form display
  console.log(fieldErrors)
  // {
  //   email: ['Invalid email'],
  //   password: ['Password too short'],
  //   'profile.name': ['Name required']
  // }
}
```

**With React Hook Form:**

```typescript
import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'

const { register, formState: { errors } } = useForm({
  resolver: zodResolver(formSchema),
})

// errors are already flattened by the resolver
// <input {...register('email')} />
// {errors.email && <span>{errors.email.message}</span>}
```

**Customizing flatten output:**

```typescript
const flattened = result.error.flatten((issue) => ({
  message: issue.message,
  code: issue.code,
}))

// fieldErrors now contains custom objects
// {
//   email: [{ message: 'Invalid email', code: 'invalid_string' }],
// }
```

**For deeply nested objects, use format():**

```typescript
const result = formSchema.safeParse(data)

if (!result.success) {
  const formatted = result.error.format()
  // {
  //   _errors: [],
  //   email: { _errors: ['Invalid email'] },
  //   profile: {
  //     _errors: [],
  //     name: { _errors: ['Name required'] }
  //   }
  // }

  // Access nested errors naturally
  formatted.profile?.name?._errors  // ['Name required']
}
```

**When NOT to use this pattern:**
- When you need access to full issue metadata (code, path as array)
- When using a form library that expects different error format

Reference: [Zod Error Handling](https://zod.dev/error-handling)

### 4.5 Use issue.path for Nested Error Location

**Impact: HIGH (Without path information, users can't identify which nested field failed; path provides exact location in complex objects)**

When validating nested objects or arrays, `issue.path` tells you exactly where the error occurred. This is essential for highlighting the correct form field or providing precise error messages in complex data structures.

**Incorrect (ignoring path information):**

```typescript
import { z } from 'zod'

const orderSchema = z.object({
  customer: z.object({
    name: z.string().min(1, 'Name required'),
    address: z.object({
      street: z.string().min(1, 'Street required'),
      city: z.string().min(1, 'City required'),
    }),
  }),
  items: z.array(z.object({
    productId: z.string(),
    quantity: z.number().positive('Quantity must be positive'),
  })),
})

const result = orderSchema.safeParse({
  customer: { name: '', address: { street: '', city: '' } },
  items: [{ productId: 'abc', quantity: -1 }],
})

if (!result.success) {
  // Only showing message, not WHERE the error is
  result.error.issues.forEach(issue => {
    console.log(issue.message)  // 'Name required', 'Street required', 'Quantity must be positive'
    // User: "Which quantity? Which field?"
  })
}
```

**Correct (using path information):**

```typescript
import { z } from 'zod'

const orderSchema = z.object({
  customer: z.object({
    name: z.string().min(1, 'Name required'),
    address: z.object({
      street: z.string().min(1, 'Street required'),
      city: z.string().min(1, 'City required'),
    }),
  }),
  items: z.array(z.object({
    productId: z.string(),
    quantity: z.number().positive('Quantity must be positive'),
  })),
})

const result = orderSchema.safeParse({
  customer: { name: '', address: { street: '', city: '' } },
  items: [{ productId: 'abc', quantity: -1 }],
})

if (!result.success) {
  result.error.issues.forEach(issue => {
    // path is an array of keys/indices
    console.log(`${issue.path.join('.')}: ${issue.message}`)
    // 'customer.name: Name required'
    // 'customer.address.street: Street required'
    // 'customer.address.city: City required'
    // 'items.0.quantity: Quantity must be positive'
  })
}
```

**Building field-specific error mapping:**

```typescript
function mapErrorsToFields(error: z.ZodError) {
  const fieldErrors: Map<string, string[]> = new Map()

  for (const issue of error.issues) {
    const fieldPath = issue.path.join('.')
    const existing = fieldErrors.get(fieldPath) ?? []
    fieldErrors.set(fieldPath, [...existing, issue.message])
  }

  return fieldErrors
}

// Usage
const errors = mapErrorsToFields(result.error)
errors.get('customer.name')  // ['Name required']
errors.get('items.0.quantity')  // ['Quantity must be positive']
```

**For array items, get index from path:**

```typescript
const itemsWithErrors: Set<number> = new Set()

result.error.issues.forEach(issue => {
  if (issue.path[0] === 'items' && typeof issue.path[1] === 'number') {
    itemsWithErrors.add(issue.path[1])
  }
})

// Highlight items at indices: Set { 0 }
```

**Using path with format():**

```typescript
const formatted = result.error.format()

// Access errors at any path level
formatted.customer?.address?.city?._errors  // ['City required']
formatted.items?.[0]?.quantity?._errors  // ['Quantity must be positive']
```

**When NOT to use this pattern:**
- Flat objects where field name is obvious
- When using form libraries that handle path mapping

Reference: [Zod Error Handling](https://zod.dev/error-handling)

---

## 5. Object Schemas

**Impact: MEDIUM-HIGH**

Objects are the most common schema type; misconfiguring strict/passthrough/strip modes either leaks unexpected data to clients or fails validation on legitimate requests.

### 5.1 Choose strict() vs strip() for Unknown Keys

**Impact: MEDIUM-HIGH (Default passthrough mode leaks unexpected data; strict() catches schema mismatches, strip() silently removes extras)**

By default, Zod objects use `.strip()` behavior, silently removing unrecognized keys. This can hide schema/data mismatches. Use `.strict()` to reject unknown keys (catching errors) or explicitly use `.strip()` to document the intention.

**Default behavior (strip - silent removal):**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  id: z.string(),
  name: z.string(),
})

const input = {
  id: '123',
  name: 'John',
  role: 'admin',  // Extra field
  secretToken: 'abc123',  // Another extra field
}

const user = userSchema.parse(input)
// { id: '123', name: 'John' }
// Extra fields silently removed - was this intentional?
```

**Using strict() to catch schema mismatches:**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  id: z.string(),
  name: z.string(),
}).strict()

const input = {
  id: '123',
  name: 'John',
  role: 'admin',
}

userSchema.parse(input)
// ZodError: Unrecognized key(s) in object: 'role'

// This catches:
// - Client sending fields the server doesn't expect
// - Schema out of sync with actual data structure
// - Typos in field names
```

**When to use each mode:**

```typescript
// strict() - Catch unexpected data (API contracts)
const apiRequestSchema = z.object({
  action: z.string(),
  payload: z.unknown(),
}).strict()  // Fail if client sends unknown fields

// strip() - Clean up data (explicit intention)
const dbInsertSchema = z.object({
  name: z.string(),
  email: z.string(),
}).strip()  // Explicitly remove metadata before insert

// passthrough() - Keep everything (pass-through proxy)
const proxySchema = z.object({
  id: z.string(),
}).passthrough()  // Keep fields we don't validate

const input = { id: '123', extra: 'data' }
proxySchema.parse(input)  // { id: '123', extra: 'data' }
```

**Choosing the right mode:**

| Mode | Behavior | Use When |
|------|----------|----------|
| `.strict()` | Reject unknown keys | API contracts, security-sensitive, debugging |
| `.strip()` (default) | Remove unknown keys | General validation, data cleaning |
| `.passthrough()` | Keep unknown keys | Proxying, partial validation |

**Handling specific unknown keys:**

```typescript
const schema = z.object({
  id: z.string(),
  name: z.string(),
}).catchall(z.unknown())  // Allow any additional fields of any type

// Or restrict additional fields to specific type
const metadataSchema = z.object({
  id: z.string(),
}).catchall(z.string())  // Only allow string extras
```

**When NOT to use this pattern:**
- `.strict()`: When forwarding data to another system that may add fields
- `.passthrough()`: When you need to ensure only known fields are stored

Reference: [Zod API - Objects](https://zod.dev/api#objects)

### 5.2 Distinguish optional() from nullable()

**Impact: MEDIUM-HIGH (Confusing undefined and null semantics causes "property does not exist" vs "property is null" bugs; choose deliberately)**

`.optional()` allows `undefined` (field can be missing), while `.nullable()` allows `null` (field must be present but can be null). Choosing the wrong one causes subtle bugs in database operations, JSON serialization, and API contracts.

**Incorrect (confusing optional and nullable):**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  name: z.string(),
  // Intended: field might not exist
  nickname: z.string().nullable(),  // Wrong! Requires field to be present
  // Intended: field exists but might be null
  deletedAt: z.date().optional(),  // Wrong! Allows field to be missing
})

// This fails - nickname is required
userSchema.parse({ name: 'John' })
// ZodError: Required at "nickname"

// This passes but loses semantic meaning
userSchema.parse({ name: 'John', nickname: null, deletedAt: undefined })
// Is deletedAt undefined because not deleted, or because data is incomplete?
```

**Correct (using optional and nullable deliberately):**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  name: z.string(),

  // optional() - field might not exist in the object
  nickname: z.string().optional(),
  // Type: string | undefined

  // nullable() - field must exist, but value can be null
  deletedAt: z.date().nullable(),
  // Type: Date | null
})

// Field can be omitted
userSchema.parse({ name: 'John', deletedAt: null })  // Valid

// Field must be present (even if null)
userSchema.parse({ name: 'John', nickname: 'Johnny' })
// ZodError: Required at "deletedAt"

// Correct usage
userSchema.parse({
  name: 'John',
  nickname: 'Johnny',  // Or omit entirely
  deletedAt: null,  // Must be present, null means "not deleted"
})
```

**When to use each:**

```typescript
// optional() - field may not exist
// Use for: Optional form fields, sparse updates, optional config
z.object({
  bio: z.string().optional(),  // User might not have filled this
  middleName: z.string().optional(),  // Not everyone has one
})

// nullable() - field exists but value can be null
// Use for: Database nullable columns, "cleared" values, explicit absence
z.object({
  deletedAt: z.date().nullable(),  // null = not deleted, Date = when deleted
  parentId: z.string().nullable(),  // null = root node, string = has parent
  approvedBy: z.string().nullable(),  // null = pending, string = approver
})

// nullish() - either undefined or null
// Use for: Lenient APIs, legacy data, optional nullable DB columns
z.object({
  legacyField: z.string().nullish(),  // string | null | undefined
})
```

**API response patterns:**

```typescript
// API includes null for "no value" (good for explicit absence)
const apiResponseSchema = z.object({
  data: z.object({
    user: z.object({
      name: z.string(),
      avatar: z.string().nullable(),  // null = no avatar set
    }).nullable(),  // null = user not found
  }),
})

// Type: { data: { user: { name: string; avatar: string | null } | null } }

// Partial updates send only changed fields
const updateSchema = z.object({
  name: z.string().optional(),  // Omitted = don't change
  avatar: z.string().nullable().optional(),  // null = clear avatar
})
```

**When NOT to use this pattern:**
- When interacting with systems that treat null and undefined as equivalent
- When using nullish() for maximum flexibility is acceptable

Reference: [Zod API - optional/nullable](https://zod.dev/api#optional)

### 5.3 Use Discriminated Unions for Type Narrowing

**Impact: MEDIUM-HIGH (Regular unions require manual type guards; discriminated unions enable TypeScript's automatic narrowing and Zod's optimized parsing)**

When a field's type depends on another field's value (e.g., `type: 'success'` means `data` exists, `type: 'error'` means `error` exists), use `z.discriminatedUnion()`. This enables TypeScript's automatic type narrowing and Zod's optimized O(1) parsing instead of trying each variant.

**Incorrect (regular union - no automatic narrowing):**

```typescript
import { z } from 'zod'

const successSchema = z.object({
  type: z.literal('success'),
  data: z.object({ id: z.string() }),
})

const errorSchema = z.object({
  type: z.literal('error'),
  message: z.string(),
})

// Regular union - Zod tries each option in order
const responseSchema = z.union([successSchema, errorSchema])

type Response = z.infer<typeof responseSchema>

function handleResponse(response: Response) {
  // TypeScript doesn't narrow automatically
  if (response.type === 'success') {
    response.data  // Error: Property 'data' does not exist on type 'Response'
    // Must cast or use type guards
  }
}
```

**Correct (discriminated union):**

```typescript
import { z } from 'zod'

const successSchema = z.object({
  type: z.literal('success'),
  data: z.object({ id: z.string() }),
})

const errorSchema = z.object({
  type: z.literal('error'),
  message: z.string(),
})

// Discriminated union - Zod uses 'type' field for O(1) dispatch
const responseSchema = z.discriminatedUnion('type', [
  successSchema,
  errorSchema,
])

type Response = z.infer<typeof responseSchema>

function handleResponse(response: Response) {
  // TypeScript narrows automatically!
  if (response.type === 'success') {
    response.data.id  // Works - TypeScript knows data exists
  } else {
    response.message  // Works - TypeScript knows message exists
  }
}
```

**Common use cases:**

```typescript
// API responses
const apiResponse = z.discriminatedUnion('status', [
  z.object({ status: z.literal('success'), data: z.unknown() }),
  z.object({ status: z.literal('error'), error: z.string(), code: z.number() }),
  z.object({ status: z.literal('loading') }),
])

// Event types
const event = z.discriminatedUnion('type', [
  z.object({ type: z.literal('click'), x: z.number(), y: z.number() }),
  z.object({ type: z.literal('keypress'), key: z.string() }),
  z.object({ type: z.literal('scroll'), delta: z.number() }),
])

// Database records with polymorphic types
const notification = z.discriminatedUnion('channel', [
  z.object({ channel: z.literal('email'), address: z.string().email() }),
  z.object({ channel: z.literal('sms'), phoneNumber: z.string() }),
  z.object({ channel: z.literal('push'), deviceToken: z.string() }),
])
```

**Type-safe handling:**

```typescript
const paymentSchema = z.discriminatedUnion('method', [
  z.object({
    method: z.literal('card'),
    cardNumber: z.string(),
    expiryDate: z.string(),
  }),
  z.object({
    method: z.literal('bank'),
    accountNumber: z.string(),
    routingNumber: z.string(),
  }),
  z.object({
    method: z.literal('crypto'),
    walletAddress: z.string(),
  }),
])

type Payment = z.infer<typeof paymentSchema>

function processPayment(payment: Payment) {
  switch (payment.method) {
    case 'card':
      return chargeCard(payment.cardNumber, payment.expiryDate)
    case 'bank':
      return initiateBankTransfer(payment.accountNumber, payment.routingNumber)
    case 'crypto':
      return sendCrypto(payment.walletAddress)
    // TypeScript exhaustiveness check - no default needed
  }
}
```

**When NOT to use this pattern:**
- When variants don't share a common discriminator field
- When the discriminator isn't a literal type (use regular union)

Reference: [Zod API - Discriminated Unions](https://zod.dev/api#discriminated-unions)

### 5.4 Use extend() for Adding Fields

**Impact: MEDIUM-HIGH (Merging objects manually loses type information; extend() preserves types and allows overriding fields safely)**

When building on existing schemas, use `.extend()` to add new fields rather than manually spreading. Extend preserves type information, allows overriding existing fields, and keeps the schema relationship explicit.

**Incorrect (manual object spreading):**

```typescript
import { z } from 'zod'

const baseUserSchema = z.object({
  id: z.string(),
  name: z.string(),
})

// Manual spreading loses Zod's schema relationship
const adminUserSchema = z.object({
  ...baseUserSchema.shape,  // Accessing internal .shape
  role: z.literal('admin'),
  permissions: z.array(z.string()),
})

// Problems:
// 1. If baseUserSchema changes, TypeScript might not catch issues
// 2. Can't override fields easily
// 3. Loses schema methods and metadata
```

**Correct (using extend):**

```typescript
import { z } from 'zod'

const baseUserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
})

// Extend to add fields
const adminUserSchema = baseUserSchema.extend({
  role: z.literal('admin'),
  permissions: z.array(z.string()),
})

type AdminUser = z.infer<typeof adminUserSchema>
// {
//   id: string;
//   name: string;
//   email: string;
//   role: 'admin';
//   permissions: string[];
// }

// Override existing fields
const strictEmailSchema = baseUserSchema.extend({
  email: z.string().email().endsWith('@company.com'),  // Stricter validation
})
```

**Building hierarchies with extend:**

```typescript
// Base entity with common fields
const entitySchema = z.object({
  id: z.string().uuid(),
  createdAt: z.date(),
  updatedAt: z.date(),
})

// User extends entity
const userSchema = entitySchema.extend({
  email: z.string().email(),
  name: z.string(),
})

// Product extends entity
const productSchema = entitySchema.extend({
  name: z.string(),
  price: z.number().positive(),
  sku: z.string(),
})

// Order extends entity with references
const orderSchema = entitySchema.extend({
  userId: z.string().uuid(),
  items: z.array(z.object({
    productId: z.string().uuid(),
    quantity: z.number().int().positive(),
  })),
  total: z.number().positive(),
})
```

**Combining extend with other methods:**

```typescript
const baseSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string(),
})

// Create input: no id, add password
const createSchema = baseSchema
  .omit({ id: true })
  .extend({
    password: z.string().min(8),
  })

// Update input: all optional except id
const updateSchema = baseSchema
  .partial()
  .extend({
    id: z.string(),  // Override to make required
  })
```

**Merge for combining independent schemas:**

```typescript
const addressSchema = z.object({
  street: z.string(),
  city: z.string(),
})

const contactSchema = z.object({
  email: z.string().email(),
  phone: z.string(),
})

// Merge combines two schemas (both required)
const customerSchema = addressSchema.merge(contactSchema)
// { street: string; city: string; email: string; phone: string }
```

**When NOT to use this pattern:**
- When schemas are genuinely independent (use merge or intersection)
- When you need to remove fields (use omit)

Reference: [Zod API - extend](https://zod.dev/api#extend)

### 5.5 Use partial() for Update Schemas

**Impact: MEDIUM-HIGH (Creating separate update schemas duplicates definitions; partial() derives update schema from base, staying in sync)**

When handling PATCH/PUT updates, you need a schema where all fields are optional. Instead of duplicating the schema with optional fields, use `.partial()` to derive it from your base schema. This keeps both schemas in sync automatically.

**Incorrect (duplicating schemas):**

```typescript
import { z } from 'zod'

// Base schema
const userSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive(),
  role: z.enum(['admin', 'user']),
})

// Manually duplicated for updates - will drift!
const updateUserSchema = z.object({
  name: z.string().min(1).optional(),
  email: z.string().email().optional(),
  age: z.number().int().positive().optional(),
  // Forgot to add role - schemas out of sync!
})

// Later, you add a field to userSchema but forget updateUserSchema
// Now updates silently ignore the new field
```

**Correct (using partial):**

```typescript
import { z } from 'zod'

// Base schema - single source of truth
const userSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive(),
  role: z.enum(['admin', 'user']),
})

// All fields optional for updates
const updateUserSchema = userSchema.partial()

type User = z.infer<typeof userSchema>
// { name: string; email: string; age: number; role: 'admin' | 'user' }

type UpdateUser = z.infer<typeof updateUserSchema>
// { name?: string; email?: string; age?: number; role?: 'admin' | 'user' }

// Validate partial updates
updateUserSchema.parse({ email: 'new@example.com' })  // Valid
updateUserSchema.parse({})  // Valid - all fields optional
```

**Partial specific fields only:**

```typescript
// Only name and email are optional for updates
const updateUserSchema = userSchema.partial({
  name: true,
  email: true,
})

type UpdateUser = z.infer<typeof updateUserSchema>
// { name?: string; email?: string; age: number; role: 'admin' | 'user' }
// age and role still required
```

**Deep partial for nested objects:**

```typescript
const addressSchema = z.object({
  street: z.string(),
  city: z.string(),
  country: z.string(),
})

const userSchema = z.object({
  name: z.string(),
  address: addressSchema,
})

// .partial() only makes top-level fields optional
const shallowPartial = userSchema.partial()
// { name?: string; address?: { street: string; city: string; country: string } }
// If address is provided, all its fields are still required!

// Use deepPartial for nested optionality
const deepPartialSchema = userSchema.deepPartial()
// { name?: string; address?: { street?: string; city?: string; country?: string } }
```

**Combining with required() for create vs update:**

```typescript
const baseSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string().email(),
  createdAt: z.date(),
})

// Create: id and createdAt are generated, rest required
const createSchema = baseSchema.omit({ id: true, createdAt: true })

// Update: all user-editable fields optional
const updateSchema = baseSchema.partial().omit({ id: true, createdAt: true })
```

**When NOT to use this pattern:**
- When update logic differs significantly from create (different validations)
- When using GraphQL with explicit input types

Reference: [Zod API - partial](https://zod.dev/api#partial)

### 5.6 Use pick() and omit() for Schema Variants

**Impact: MEDIUM-HIGH (Copying fields between schemas creates duplication; pick/omit derive variants that stay in sync with base schema)**

When you need different views of the same data (public vs private, create vs response), use `.pick()` and `.omit()` instead of duplicating fields. This ensures derived schemas stay in sync with the base schema.

**Incorrect (duplicating for variants):**

```typescript
import { z } from 'zod'

// Full user schema
const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  passwordHash: z.string(),
  name: z.string(),
  createdAt: z.date(),
  isAdmin: z.boolean(),
})

// Public view - manually duplicated
const publicUserSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  // Forgot email - now users can't see it
  // Added avatar field - doesn't exist in base schema
  avatar: z.string().optional(),
})

// Create input - manually duplicated
const createUserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),  // Different from passwordHash
  name: z.string(),
  // Missing isAdmin - can't set on create? Intentional?
})
```

**Correct (using pick and omit):**

```typescript
import { z } from 'zod'

// Full user schema - single source of truth
const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  passwordHash: z.string(),
  name: z.string(),
  createdAt: z.date(),
  isAdmin: z.boolean(),
})

// Public view - explicitly pick public fields
const publicUserSchema = userSchema.pick({
  id: true,
  email: true,
  name: true,
})

type PublicUser = z.infer<typeof publicUserSchema>
// { id: string; email: string; name: string }

// API response - omit sensitive fields
const userResponseSchema = userSchema.omit({
  passwordHash: true,
})

type UserResponse = z.infer<typeof userResponseSchema>
// { id: string; email: string; name: string; createdAt: Date; isAdmin: boolean }

// Create input - omit generated fields
const createUserInputSchema = userSchema
  .omit({ id: true, createdAt: true, passwordHash: true })
  .extend({
    password: z.string().min(8),  // Add password (different from hash)
  })

type CreateUserInput = z.infer<typeof createUserInputSchema>
// { email: string; name: string; isAdmin: boolean; password: string }
```

**Common patterns:**

```typescript
// Database row → API response (hide internal fields)
const dbRowSchema = z.object({
  id: z.number(),
  public_id: z.string().uuid(),
  email: z.string(),
  password_hash: z.string(),
  internal_notes: z.string(),
  created_at: z.date(),
})

const apiResponseSchema = dbRowSchema.omit({
  id: true,  // Internal DB id
  password_hash: true,  // Sensitive
  internal_notes: true,  // Staff only
})

// Form data → Database insert (add generated fields)
const formSchema = z.object({
  title: z.string(),
  content: z.string(),
})

const dbInsertSchema = formSchema.extend({
  id: z.string().uuid(),
  authorId: z.string().uuid(),
  createdAt: z.date(),
  updatedAt: z.date(),
})
```

**Chaining operations:**

```typescript
const baseSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string(),
  role: z.enum(['admin', 'user']),
  secret: z.string(),
})

// Combine pick, omit, partial, extend
const updateSchema = baseSchema
  .omit({ id: true, secret: true })  // Remove immutable/sensitive
  .partial()  // Make all optional for updates
  .extend({
    updatedAt: z.date().optional(),  // Add update timestamp
  })
```

**When NOT to use this pattern:**
- When derived schemas need different validation rules (not just different fields)
- When the relationship between schemas is not subset/superset

Reference: [Zod API - pick/omit](https://zod.dev/api#pickomit)

---

## 6. Schema Composition

**Impact: MEDIUM**

Schema composition enables reuse and maintainability; poor composition patterns lead to duplicated schemas that drift apart or deeply nested structures that are impossible to maintain.

### 6.1 Extract Shared Schemas into Reusable Modules

**Impact: MEDIUM (Duplicating schemas across files leads to inconsistency; shared schemas ensure single source of truth)**

When the same schema pattern appears in multiple places, extract it into a shared module. This ensures consistency, reduces duplication, and makes changes propagate automatically across your codebase.

**Incorrect (duplicating schemas):**

```typescript
// api/users.ts
import { z } from 'zod'

const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1),
  createdAt: z.date(),
})

// api/orders.ts
import { z } from 'zod'

const orderSchema = z.object({
  id: z.string().uuid(),  // Duplicated
  userId: z.string().uuid(),  // Same pattern
  items: z.array(z.object({
    productId: z.string().uuid(),  // Duplicated
    quantity: z.number().int().positive(),
  })),
  createdAt: z.date(),  // Duplicated
})

// api/comments.ts
import { z } from 'zod'

const commentSchema = z.object({
  id: z.string().uuid(),  // Same duplication
  userId: z.string().uuid(),
  content: z.string().min(1),
  createdAt: z.date(),  // Inconsistency risk
})
```

**Correct (shared schema modules):**

```typescript
// schemas/common.ts
import { z } from 'zod'

// Reusable ID types
export const uuid = z.string().uuid()
export type UUID = z.infer<typeof uuid>

// Timestamps
export const timestamps = z.object({
  createdAt: z.date(),
  updatedAt: z.date(),
})

// Base entity with ID
export const baseEntity = z.object({
  id: uuid,
}).merge(timestamps)

export type BaseEntity = z.infer<typeof baseEntity>

// Pagination
export const paginationParams = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
})
```

```typescript
// schemas/user.ts
import { z } from 'zod'
import { baseEntity, uuid } from './common'

export const userSchema = baseEntity.extend({
  email: z.string().email(),
  name: z.string().min(1),
})

export type User = z.infer<typeof userSchema>
```

```typescript
// schemas/order.ts
import { z } from 'zod'
import { baseEntity, uuid } from './common'

const orderItemSchema = z.object({
  productId: uuid,
  quantity: z.number().int().positive(),
})

export const orderSchema = baseEntity.extend({
  userId: uuid,
  items: z.array(orderItemSchema).min(1),
  total: z.number().positive(),
})

export type Order = z.infer<typeof orderSchema>
```

**Organizing schema modules:**

```
schemas/
├── common.ts       # Shared primitives and base schemas
├── user.ts         # User-related schemas
├── order.ts        # Order-related schemas
├── product.ts      # Product-related schemas
└── index.ts        # Re-exports for convenience
```

```typescript
// schemas/index.ts
export * from './common'
export * from './user'
export * from './order'
export * from './product'

// Usage
import { userSchema, orderSchema, uuid, type User } from '@/schemas'
```

**When NOT to use this pattern:**
- One-off schemas used only in a single file
- When schemas look similar but have different semantics (don't over-abstract)

Reference: [Zod - Type Inference](https://zod.dev/api#type-inference)

### 6.2 Use intersection() for Type Combinations

**Impact: MEDIUM (Manual field combination loses type relationships; intersection creates proper TypeScript intersection types)**

When you need an object that satisfies multiple schemas simultaneously (like combining a base type with mixins), use `.and()` or `z.intersection()`. This creates proper TypeScript intersection types and validates against all schemas.

**Incorrect (manual combination):**

```typescript
import { z } from 'zod'

const timestampsSchema = z.object({
  createdAt: z.date(),
  updatedAt: z.date(),
})

const softDeleteSchema = z.object({
  deletedAt: z.date().nullable(),
  deletedBy: z.string().nullable(),
})

const userSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
})

// Manual combination - verbose and error-prone
const fullUserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  createdAt: z.date(),
  updatedAt: z.date(),
  deletedAt: z.date().nullable(),
  deletedBy: z.string().nullable(),
})
```

**Correct (using intersection):**

```typescript
import { z } from 'zod'

const timestampsSchema = z.object({
  createdAt: z.date(),
  updatedAt: z.date(),
})

const softDeleteSchema = z.object({
  deletedAt: z.date().nullable(),
  deletedBy: z.string().nullable(),
})

const userSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
})

// Using .and() for intersection
const fullUserSchema = userSchema
  .and(timestampsSchema)
  .and(softDeleteSchema)

// Or using z.intersection()
const fullUserSchema2 = z.intersection(
  z.intersection(userSchema, timestampsSchema),
  softDeleteSchema
)

type FullUser = z.infer<typeof fullUserSchema>
// {
//   id: string;
//   name: string;
//   email: string;
//   createdAt: Date;
//   updatedAt: Date;
//   deletedAt: Date | null;
//   deletedBy: string | null;
// }
```

**Creating mixins:**

```typescript
// Reusable mixins
const auditable = z.object({
  createdBy: z.string(),
  updatedBy: z.string(),
})

const versioned = z.object({
  version: z.number().int().positive(),
})

const tagged = z.object({
  tags: z.array(z.string()),
})

// Apply mixins to any schema
function withAudit<T extends z.ZodRawShape>(schema: z.ZodObject<T>) {
  return schema.and(auditable).and(timestampsSchema)
}

function withVersioning<T extends z.ZodRawShape>(schema: z.ZodObject<T>) {
  return schema.and(versioned)
}

// Usage
const documentSchema = z.object({
  id: z.string(),
  title: z.string(),
  content: z.string(),
})

const fullDocumentSchema = withAudit(withVersioning(documentSchema))
```

**Intersection vs Merge:**

```typescript
// .merge() - replaces fields from first with second
const a = z.object({ x: z.string(), y: z.number() })
const b = z.object({ y: z.string() })  // y is string, not number

a.merge(b)  // { x: string, y: string } - b's y wins

// .and() - requires fields to be compatible
// If both have y with different types, intersection fails at runtime
a.and(b)  // Validation will fail - y can't be both number and string
```

**When NOT to use this pattern:**
- When schemas have overlapping fields with different types (use merge)
- When you need to override fields (use extend)
- Simple cases where extend works fine

Reference: [Zod API - intersection](https://zod.dev/api#intersection)

### 6.3 Use pipe() for Multi-Stage Validation

**Impact: MEDIUM (Chaining transforms loses intermediate type info; pipe() explicitly shows data flow through validation stages)**

When data needs to pass through multiple validation stages (coerce string to number, then validate range, then transform to currency), use `.pipe()` to chain schemas. This makes the data transformation pipeline explicit and each stage's type clear.

**Incorrect (unclear transformation chain):**

```typescript
import { z } from 'zod'

// All transforms in one long chain - hard to understand stages
const priceSchema = z
  .string()
  .transform((s) => parseFloat(s.replace(/[$,]/g, '')))
  .refine((n) => !isNaN(n), 'Invalid number')
  .refine((n) => n >= 0, 'Must be positive')
  .refine((n) => n <= 1000000, 'Too large')
  .transform((n) => Math.round(n * 100))

// What type is n at each stage? Hard to tell
```

**Correct (using pipe for clear stages):**

```typescript
import { z } from 'zod'

// Stage 1: Coerce string to number
const parsePrice = z.string().transform((s) => {
  const cleaned = s.replace(/[$,]/g, '')
  const parsed = parseFloat(cleaned)
  if (isNaN(parsed)) throw new Error('Invalid number')
  return parsed
})

// Stage 2: Validate number constraints
const validPrice = z.number().min(0, 'Must be positive').max(1000000, 'Too large')

// Stage 3: Transform to cents
const centsPrice = z.number().transform((n) => Math.round(n * 100))

// Pipe them together - clear data flow
const priceSchema = parsePrice.pipe(validPrice).pipe(centsPrice)

// Type at each stage is clear:
// string -> number (parsePrice)
// number -> number (validPrice)
// number -> number (centsPrice, but semantically cents)
```

**Coercion with validation:**

```typescript
// Without pipe - validation runs on raw input
const schema1 = z.coerce.number().min(1)
schema1.parse('')  // Passes! Empty string coerces to 0, but then... wait, 0 < 1

// With pipe - validation runs on coerced value
const schema2 = z.coerce.number().pipe(z.number().min(1))
schema2.parse('')  // Fails correctly: 0 is less than 1
```

**Complex data transformation:**

```typescript
// Input: CSV string of emails
// Output: Array of normalized, validated email objects

const emailArraySchema = z
  .string()
  // Stage 1: Split CSV
  .transform((s) => s.split(',').map((e) => e.trim()))
  // Stage 2: Validate as email array
  .pipe(z.array(z.string().email()))
  // Stage 3: Transform to objects
  .pipe(
    z.array(z.string()).transform((emails) =>
      emails.map((email) => ({
        address: email.toLowerCase(),
        domain: email.split('@')[1],
      }))
    )
  )

emailArraySchema.parse('John@Example.com, jane@test.com')
// [
//   { address: 'john@example.com', domain: 'Example.com' },
//   { address: 'jane@test.com', domain: 'test.com' }
// ]
```

**Type inference with pipe:**

```typescript
const schema = z.string().pipe(z.coerce.number()).pipe(z.number().positive())

type Input = z.input<typeof schema>  // string
type Output = z.output<typeof schema>  // number

// Each pipe stage has clear input/output types
```

**When NOT to use this pattern:**
- Simple single-stage validation (adds unnecessary complexity)
- When `.refine()` chain is sufficient and readable

Reference: [Zod API - pipe](https://zod.dev/api#pipe)

### 6.4 Use preprocess() for Data Normalization

**Impact: MEDIUM (Validating before cleaning data causes false rejections; preprocess() normalizes input before schema validation runs)**

When incoming data needs normalization before validation (trimming whitespace, parsing JSON strings, converting formats), use `z.preprocess()`. This runs a function on the raw input before Zod's type checking, allowing you to clean data that would otherwise fail validation.

**Incorrect (validation fails on unnormalized data):**

```typescript
import { z } from 'zod'

const userSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  config: z.object({
    theme: z.string(),
  }),
})

// Raw form data
const formData = {
  name: '  John Doe  ',  // Has whitespace
  email: 'JOHN@EXAMPLE.COM',  // Uppercase
  config: '{"theme": "dark"}',  // JSON string, not object
}

userSchema.parse(formData)
// ZodError: Expected object, received string at "config"
```

**Correct (using preprocess):**

```typescript
import { z } from 'zod'

// Preprocess normalizes before validation
const trimmedString = z.preprocess(
  (val) => (typeof val === 'string' ? val.trim() : val),
  z.string()
)

const lowercaseEmail = z.preprocess(
  (val) => (typeof val === 'string' ? val.toLowerCase().trim() : val),
  z.string().email()
)

const jsonObject = z.preprocess(
  (val) => {
    if (typeof val === 'string') {
      try {
        return JSON.parse(val)
      } catch {
        return val  // Let Zod report the error
      }
    }
    return val
  },
  z.object({ theme: z.string() })
)

const userSchema = z.object({
  name: trimmedString.pipe(z.string().min(1)),
  email: lowercaseEmail,
  config: jsonObject,
})

const formData = {
  name: '  John Doe  ',
  email: 'JOHN@EXAMPLE.COM',
  config: '{"theme": "dark"}',
}

const user = userSchema.parse(formData)
// { name: 'John Doe', email: 'john@example.com', config: { theme: 'dark' } }
```

**Common preprocessing patterns:**

```typescript
// Trim all strings
const trimmedString = z.preprocess(
  (val) => (typeof val === 'string' ? val.trim() : val),
  z.string()
)

// Parse numeric strings
const numericString = z.preprocess(
  (val) => (typeof val === 'string' ? Number(val) : val),
  z.number()
)

// Parse boolean-like values
const booleanLike = z.preprocess(
  (val) => {
    if (val === 'true' || val === '1' || val === 1) return true
    if (val === 'false' || val === '0' || val === 0) return false
    return val
  },
  z.boolean()
)

// Parse date strings
const dateString = z.preprocess(
  (val) => (typeof val === 'string' ? new Date(val) : val),
  z.date()
)

// Split comma-separated strings into arrays
const csvArray = z.preprocess(
  (val) => (typeof val === 'string' ? val.split(',').map(s => s.trim()) : val),
  z.array(z.string())
)
```

**Preprocess vs Transform:**

```typescript
// preprocess() runs BEFORE type checking
// Use for: Normalizing input format before validation
z.preprocess(val => String(val).trim(), z.string().min(1))

// transform() runs AFTER type checking
// Use for: Converting validated data to different format
z.string().transform(s => s.toUpperCase())

// Order of operations:
// 1. preprocess receives raw unknown input
// 2. Zod validates the preprocessed value
// 3. transform converts the validated value
```

**When NOT to use this pattern:**
- When `.coerce` methods handle the conversion (simpler)
- When transformation should happen after validation (use transform)
- When normalization could hide validation errors

Reference: [Zod API - preprocess](https://zod.dev/api#preprocess)

### 6.5 Use z.lazy() for Recursive Schemas

**Impact: MEDIUM (Recursive types reference themselves before definition; z.lazy() defers evaluation to enable self-referential schemas)**

TypeScript can't infer recursive Zod schema types automatically. Use `z.lazy()` to defer schema evaluation and manually provide the type annotation. This enables tree structures, nested comments, and other self-referential data.

**Incorrect (direct self-reference):**

```typescript
import { z } from 'zod'

// This fails - categorySchema used before it's defined
const categorySchema = z.object({
  id: z.string(),
  name: z.string(),
  children: z.array(categorySchema),  // Error: Block-scoped variable used before declaration
})
```

**Correct (using z.lazy with type annotation):**

```typescript
import { z } from 'zod'

// Define the type manually
interface Category {
  id: string
  name: string
  children: Category[]
}

// Use z.lazy() to defer schema reference
const categorySchema: z.ZodType<Category> = z.object({
  id: z.string(),
  name: z.string(),
  children: z.lazy(() => z.array(categorySchema)),
})

// Now it works
const tree = categorySchema.parse({
  id: '1',
  name: 'Electronics',
  children: [
    {
      id: '2',
      name: 'Phones',
      children: [
        { id: '3', name: 'iPhones', children: [] },
        { id: '4', name: 'Android', children: [] },
      ],
    },
  ],
})
```

**Common recursive patterns:**

```typescript
// Comments with replies
interface Comment {
  id: string
  content: string
  author: string
  replies: Comment[]
}

const commentSchema: z.ZodType<Comment> = z.object({
  id: z.string(),
  content: z.string(),
  author: z.string(),
  replies: z.lazy(() => z.array(commentSchema)),
})

// Binary tree
interface TreeNode {
  value: number
  left: TreeNode | null
  right: TreeNode | null
}

const treeNodeSchema: z.ZodType<TreeNode> = z.object({
  value: z.number(),
  left: z.lazy(() => treeNodeSchema.nullable()),
  right: z.lazy(() => treeNodeSchema.nullable()),
})

// Nested menu structure
interface MenuItem {
  label: string
  href?: string
  children?: MenuItem[]
}

const menuItemSchema: z.ZodType<MenuItem> = z.object({
  label: z.string(),
  href: z.string().url().optional(),
  children: z.lazy(() => z.array(menuItemSchema)).optional(),
})
```

**JSON Schema (any valid JSON):**

```typescript
type JSONValue =
  | string
  | number
  | boolean
  | null
  | JSONValue[]
  | { [key: string]: JSONValue }

const jsonValueSchema: z.ZodType<JSONValue> = z.lazy(() =>
  z.union([
    z.string(),
    z.number(),
    z.boolean(),
    z.null(),
    z.array(jsonValueSchema),
    z.record(jsonValueSchema),
  ])
)
```

**Performance consideration:**

```typescript
// z.lazy() has minimal overhead - the function is called once
// and the schema is cached. Safe to use in hot paths.

// If validating many recursive structures, the schema itself
// is only built once. Validation performance depends on data depth.
```

**When NOT to use this pattern:**
- Non-recursive schemas (lazy adds unnecessary indirection)
- When you can flatten the structure instead

Reference: [Zod API - Recursive Types](https://zod.dev/api#recursive-types)

---

## 7. Refinements & Transforms

**Impact: MEDIUM**

Refinements and transforms handle custom validation and data coercion; choosing the wrong method causes performance issues, incorrect error aggregation, or async parsing failures.

### 7.1 Add Path to Refinement Errors

**Impact: MEDIUM (Errors without path show at object level; adding path highlights the specific field that failed)**

When using `.refine()` on object schemas for cross-field validation, add a `path` option to indicate which field the error relates to. Without it, the error appears at the object level, making form error display confusing.

**Incorrect (error at object level):**

```typescript
import { z } from 'zod'

const formSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine(
  (data) => data.password === data.confirmPassword,
  { message: 'Passwords do not match' }  // No path specified
)

const result = formSchema.safeParse({
  password: 'secret123',
  confirmPassword: 'different',
})

if (!result.success) {
  const flattened = result.error.flatten()
  // {
  //   formErrors: ['Passwords do not match'],  // At form level!
  //   fieldErrors: {}  // Empty - no field association
  // }
}

// Form UI can't highlight which field has the error
```

**Correct (error with path):**

```typescript
import { z } from 'zod'

const formSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine(
  (data) => data.password === data.confirmPassword,
  {
    message: 'Passwords do not match',
    path: ['confirmPassword'],  // Error appears on this field
  }
)

const result = formSchema.safeParse({
  password: 'secret123',
  confirmPassword: 'different',
})

if (!result.success) {
  const flattened = result.error.flatten()
  // {
  //   formErrors: [],
  //   fieldErrors: {
  //     confirmPassword: ['Passwords do not match']  // Associated with field
  //   }
  // }
}

// Form can now show error next to confirmPassword input
```

**Multiple cross-field validations:**

```typescript
const dateRangeSchema = z.object({
  startDate: z.coerce.date(),
  endDate: z.coerce.date(),
  minDays: z.number().optional(),
  maxDays: z.number().optional(),
}).refine(
  (data) => data.endDate >= data.startDate,
  { message: 'End date must be after start date', path: ['endDate'] }
).refine(
  (data) => {
    if (!data.minDays) return true
    const days = (data.endDate.getTime() - data.startDate.getTime()) / 86400000
    return days >= data.minDays
  },
  { message: 'Date range is too short', path: ['endDate'] }
).refine(
  (data) => {
    if (!data.maxDays) return true
    const days = (data.endDate.getTime() - data.startDate.getTime()) / 86400000
    return days <= data.maxDays
  },
  { message: 'Date range is too long', path: ['endDate'] }
)
```

**With superRefine for multiple path errors:**

```typescript
const orderSchema = z.object({
  billingAddress: z.object({
    street: z.string(),
    city: z.string(),
  }),
  shippingAddress: z.object({
    street: z.string(),
    city: z.string(),
  }),
  sameAsBilling: z.boolean(),
}).superRefine((data, ctx) => {
  if (data.sameAsBilling) {
    // If sameAsBilling but addresses differ, show errors on shipping
    if (data.shippingAddress.street !== data.billingAddress.street) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Must match billing address',
        path: ['shippingAddress', 'street'],  // Nested path
      })
    }
    if (data.shippingAddress.city !== data.billingAddress.city) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Must match billing address',
        path: ['shippingAddress', 'city'],
      })
    }
  }
})
```

**When NOT to use this pattern:**
- When the error genuinely applies to the whole object
- Simple single-field refinements (path is implicit)

Reference: [Zod API - refine](https://zod.dev/api#refine)

### 7.2 Choose refine() vs superRefine() Correctly

**Impact: MEDIUM (refine() only reports one error; superRefine() enables multiple issues and custom error codes)**

`.refine()` is for simple single-condition validation returning boolean. `.superRefine()` gives you a context object to add multiple issues with custom error codes and paths. Choose based on your error reporting needs.

**Incorrect (using refine for multiple checks):**

```typescript
import { z } from 'zod'

// refine can only report one error at a time
const passwordSchema = z.string().refine(
  (password) => {
    // Checks all conditions but only reports first failure
    if (password.length < 8) return false  // Only this error shown
    if (!/[A-Z]/.test(password)) return false
    if (!/[0-9]/.test(password)) return false
    return true
  },
  { message: 'Password does not meet requirements' }
)

passwordSchema.parse('weak')
// Only shows: "Password does not meet requirements"
// User doesn't know WHICH requirements failed
```

**Correct (using superRefine for multiple issues):**

```typescript
import { z } from 'zod'

const passwordSchema = z.string().superRefine((password, ctx) => {
  if (password.length < 8) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Password must be at least 8 characters',
    })
  }

  if (!/[A-Z]/.test(password)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Password must contain an uppercase letter',
    })
  }

  if (!/[0-9]/.test(password)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Password must contain a number',
    })
  }

  if (!/[!@#$%^&*]/.test(password)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Password must contain a special character',
    })
  }
})

passwordSchema.safeParse('weak')
// Shows ALL failures:
// - "Password must be at least 8 characters"
// - "Password must contain an uppercase letter"
// - "Password must contain a number"
// - "Password must contain a special character"
```

**When to use refine():**

```typescript
// Simple boolean condition with one error message
const adultSchema = z.number().refine(
  (age) => age >= 18,
  { message: 'Must be 18 or older' }
)

// Cross-field validation with single outcome
const formSchema = z.object({
  password: z.string(),
  confirmPassword: z.string(),
}).refine(
  (data) => data.password === data.confirmPassword,
  { message: 'Passwords must match', path: ['confirmPassword'] }
)

// Async validation
const emailSchema = z.string().email().refine(
  async (email) => {
    const exists = await checkEmailExists(email)
    return !exists
  },
  { message: 'Email already registered' }
)
```

**When to use superRefine():**

```typescript
// Multiple independent checks on same value
// Cross-field validation with multiple possible errors
// Need custom error codes for i18n or client handling
// Need to add issues at specific paths

const orderSchema = z.object({
  items: z.array(z.object({
    productId: z.string(),
    quantity: z.number(),
  })),
  promoCode: z.string().optional(),
}).superRefine(async (order, ctx) => {
  // Check each item's availability
  for (let i = 0; i < order.items.length; i++) {
    const item = order.items[i]
    const available = await checkInventory(item.productId, item.quantity)

    if (!available) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['items', i, 'quantity'],  // Specific path
        message: `Only ${available} units available`,
      })
    }
  }

  // Validate promo code
  if (order.promoCode) {
    const valid = await validatePromoCode(order.promoCode)
    if (!valid) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['promoCode'],
        message: 'Invalid or expired promo code',
      })
    }
  }
})
```

**When NOT to use this pattern:**
- Simple single-condition checks (use refine for simplicity)
- Transform needed instead of validation (use transform)

Reference: [Zod API - refine/superRefine](https://zod.dev/api#refine)

### 7.3 Distinguish transform() from refine() and coerce()

**Impact: MEDIUM (Using wrong method causes validation to pass with wrong data; each method has distinct purpose)**

`.refine()` validates and returns boolean, `.transform()` converts data to new format, and `.coerce` converts input before validation. Using the wrong one causes bugs where validation passes but data is wrong.

**Purpose of each method:**

```typescript
import { z } from 'zod'

// coerce: Convert type BEFORE validation
// Input: unknown -> Output: validated type
z.coerce.number().parse('42')  // Converts "42" to 42, then validates as number

// refine: Validate with custom logic, return boolean
// Input: T -> Output: T (unchanged, but validated)
z.number().refine((n) => n > 0)  // Validates n > 0, returns n unchanged

// transform: Convert to different type AFTER validation
// Input: T -> Output: U (different type)
z.string().transform((s) => s.length)  // Validates string, returns length
```

**Incorrect (using transform for validation):**

```typescript
// Wrong: transform should convert, not validate
const schema = z.number().transform((n) => {
  if (n < 0) throw new Error('Must be positive')  // Don't throw in transform
  return n
})
```

**Correct (using appropriate method):**

```typescript
import { z } from 'zod'

// VALIDATION: Use refine - returns boolean, data unchanged
const positiveNumber = z.number().refine(
  (n) => n > 0,
  { message: 'Must be positive' }
)

positiveNumber.parse(5)  // 5
positiveNumber.parse(-1)  // ZodError: Must be positive

// CONVERSION: Use transform - returns new value
const stringLength = z.string().transform((s) => s.length)

type StringLength = z.infer<typeof stringLength>  // number
stringLength.parse('hello')  // 5

// COERCION: Use coerce - converts input type
const coercedNumber = z.coerce.number()

coercedNumber.parse('42')  // 42 (from string)
coercedNumber.parse(42)  // 42 (already number)
```

**Combining methods correctly:**

```typescript
// Input: string -> Coerce to number -> Validate positive -> Transform to dollars
const priceSchema = z.coerce
  .number()
  .refine((n) => n >= 0, 'Price cannot be negative')
  .transform((cents) => `$${(cents / 100).toFixed(2)}`)

priceSchema.parse('1999')  // "$19.99"
priceSchema.parse('-100')  // ZodError: Price cannot be negative
```

**Order of operations:**

```typescript
const schema = z
  .preprocess(val => val, z.string())  // 1. preprocess (before type check)
  .transform(s => s.trim())             // 2. transform (after type check)
  .refine(s => s.length > 0)            // 3. refine (custom validation)
  .transform(s => s.toUpperCase())      // 4. another transform

// Input flows: preprocess -> type check -> transforms/refines in order
```

**Use case comparison:**

| Need | Method | Example |
|------|--------|---------|
| Convert string to number | `z.coerce.number()` | Form input |
| Validate number is positive | `.refine(n => n > 0)` | Business rule |
| Convert cents to dollars | `.transform(n => n/100)` | Display format |
| Trim whitespace before check | `z.preprocess` | Input cleanup |

**When NOT to use this pattern:**
- Simple type coercion: use `z.coerce.*`
- Simple validation: use built-in methods like `.min()`, `.email()`

Reference: [Zod API - transform](https://zod.dev/api#transform)

### 7.4 Use catch() for Fault-Tolerant Parsing

**Impact: MEDIUM (parse() fails on first invalid field; catch() provides fallback values, enabling partial success with degraded data)**

When parsing data that might have some invalid fields but you want to accept what's valid, use `.catch()` to provide fallback values instead of failing entirely. This enables graceful degradation for partially corrupted data.

**Incorrect (all-or-nothing parsing):**

```typescript
import { z } from 'zod'

const userPrefsSchema = z.object({
  theme: z.enum(['light', 'dark']),
  fontSize: z.number().min(8).max(32),
  language: z.string(),
  notifications: z.boolean(),
})

// Corrupted localStorage data
const stored = {
  theme: 'invalid-theme',  // Bad
  fontSize: 200,  // Bad
  language: 'en',  // Good
  notifications: 'yes',  // Bad - should be boolean
}

userPrefsSchema.parse(stored)
// ZodError: Invalid enum value at "theme"
// User loses ALL their preferences because one field is bad
```

**Correct (fault-tolerant with catch):**

```typescript
import { z } from 'zod'

const userPrefsSchema = z.object({
  theme: z.enum(['light', 'dark']).catch('light'),
  fontSize: z.number().min(8).max(32).catch(16),
  language: z.string().catch('en'),
  notifications: z.boolean().catch(true),
})

// Corrupted data
const stored = {
  theme: 'invalid-theme',
  fontSize: 200,
  language: 'en',
  notifications: 'yes',
}

const prefs = userPrefsSchema.parse(stored)
// {
//   theme: 'light',      // Fallback used
//   fontSize: 16,        // Fallback used
//   language: 'en',      // Original value preserved
//   notifications: true  // Fallback used
// }
// User gets mostly working preferences instead of error
```

**Catch with factory function:**

```typescript
// Factory function receives the caught error
const schema = z.object({
  data: z.array(z.number()).catch((ctx) => {
    console.warn('Invalid data array:', ctx.error)
    return []  // Return empty array as fallback
  }),
})
```

**Use case: API response resilience:**

```typescript
const productSchema = z.object({
  id: z.string(),
  name: z.string(),
  price: z.number().positive(),
  // Legacy field that might be missing or wrong format
  legacyCode: z.string().catch('UNKNOWN'),
  // External data that might be malformed
  metadata: z.record(z.string()).catch({}),
})

// API returns partial data
const apiResponse = {
  id: 'prod-123',
  name: 'Widget',
  price: 29.99,
  legacyCode: null,  // Bad - should be string
  metadata: 'invalid',  // Bad - should be object
}

const product = productSchema.parse(apiResponse)
// Works! Returns product with fallbacks for bad fields
```

**Difference between catch() and default():**

```typescript
// .default() - only fills in undefined
z.string().default('fallback')
// undefined -> 'fallback'
// null -> ZodError
// '' -> '' (empty string is valid)

// .catch() - fallback for ANY parse failure
z.string().catch('fallback')
// undefined -> 'fallback'
// null -> 'fallback'
// 123 -> 'fallback'
// Even valid strings pass through unchanged
```

**Combining catch with validation:**

```typescript
// Catch only specific validation failures
const schema = z.string()
  .email()
  .catch('invalid@example.com')  // Fallback if not valid email

// Chain for complex defaults
const ageSchema = z.coerce.number()
  .int()
  .min(0)
  .max(120)
  .catch(0)  // Invalid ages become 0
```

**When NOT to use this pattern:**
- When invalid data should cause errors (strict validation)
- When you need to know which fields failed (use safeParse)
- Critical fields that must be valid

Reference: [Zod API - catch](https://zod.dev/api#catch)

### 7.5 Use default() for Optional Fields with Defaults

**Impact: MEDIUM (Manual default handling spreads logic across codebase; .default() centralizes defaults in schema)**

When a field is optional but should have a default value when missing, use `.default()` instead of handling defaults in business logic. This keeps default values centralized in the schema and ensures consistent behavior.

**Incorrect (defaults spread across codebase):**

```typescript
import { z } from 'zod'

const configSchema = z.object({
  timeout: z.number().optional(),
  retries: z.number().optional(),
  debug: z.boolean().optional(),
})

type Config = z.infer<typeof configSchema>

function createClient(config: Config) {
  // Defaults handled in business logic - duplicated everywhere
  const timeout = config.timeout ?? 5000
  const retries = config.retries ?? 3
  const debug = config.debug ?? false

  // ...
}

function createOtherClient(config: Config) {
  // Same defaults duplicated - risk of inconsistency
  const timeout = config.timeout ?? 5000
  const retries = config.retries ?? 3  // What if someone uses 2 here?
  const debug = config.debug ?? false

  // ...
}
```

**Correct (defaults in schema):**

```typescript
import { z } from 'zod'

const configSchema = z.object({
  timeout: z.number().default(5000),
  retries: z.number().default(3),
  debug: z.boolean().default(false),
})

type Config = z.infer<typeof configSchema>
// { timeout: number; retries: number; debug: boolean }
// No optional - defaults fill in missing values

function createClient(config: Config) {
  // config.timeout is guaranteed to exist
  console.log(config.timeout)  // 5000 if not provided
  console.log(config.retries)  // 3 if not provided
  console.log(config.debug)    // false if not provided
}

// Parse fills in defaults
configSchema.parse({})
// { timeout: 5000, retries: 3, debug: false }

configSchema.parse({ timeout: 10000 })
// { timeout: 10000, retries: 3, debug: false }
```

**Input type vs Output type with defaults:**

```typescript
const schema = z.object({
  name: z.string(),
  role: z.enum(['admin', 'user']).default('user'),
})

type SchemaInput = z.input<typeof schema>
// { name: string; role?: 'admin' | 'user' }

type SchemaOutput = z.output<typeof schema>
// { name: string; role: 'admin' | 'user' }

// Input type is optional, output type is required
```

**Default with factory function:**

```typescript
// Static default
const schema1 = z.object({
  id: z.string().default('temp-id'),
})

// Factory function for dynamic defaults
const schema2 = z.object({
  id: z.string().default(() => crypto.randomUUID()),
  createdAt: z.date().default(() => new Date()),
})

// Each parse creates new values
schema2.parse({})  // { id: 'abc-123...', createdAt: 2024-01-15... }
schema2.parse({})  // { id: 'def-456...', createdAt: 2024-01-15... }
```

**Combining with optional/nullable:**

```typescript
// .optional().default() - if undefined, use default
z.string().optional().default('fallback')

// .nullable().default() - null stays null, only undefined gets default
z.string().nullable().default('fallback')
// null -> null
// undefined -> 'fallback'

// .nullish().default() - both null and undefined get default
z.string().nullish().default('fallback')
// null -> 'fallback'
// undefined -> 'fallback'
```

**When NOT to use this pattern:**
- When absence of value has different meaning than default
- When defaults depend on other fields (use transform)

Reference: [Zod API - default](https://zod.dev/api#default)

---

## 8. Performance & Bundle

**Impact: LOW-MEDIUM**

Zod's performance and bundle size affect application startup and validation throughput; understanding when to use Zod Mini or cache schemas prevents unnecessary overhead in performance-critical paths.

### 8.1 Avoid Dynamic Schema Creation in Hot Paths

**Impact: LOW-MEDIUM (Zod 4's JIT compilation makes schema creation slower; creating schemas in loops adds ~0.15ms per creation)**

Zod 4 uses JIT (Just-In-Time) compilation to speed up repeated parsing, but this makes initial schema creation slower. Avoid creating schemas inside loops or frequently-called functions—pre-create them instead.

**Incorrect (schema creation in hot path):**

```typescript
import { z } from 'zod'

async function validateBatch(items: unknown[]) {
  const results = []

  for (const item of items) {
    // Schema created for EACH item - slow!
    const schema = z.object({
      id: z.string(),
      value: z.number(),
    })

    results.push(schema.safeParse(item))
  }

  return results
}

// 1000 items = 1000 schema creations = ~150ms overhead
```

**Correct (pre-created schema):**

```typescript
import { z } from 'zod'

// Schema created ONCE
const itemSchema = z.object({
  id: z.string(),
  value: z.number(),
})

async function validateBatch(items: unknown[]) {
  // Reuse the same schema instance
  return items.map(item => itemSchema.safeParse(item))
}

// 1000 items = 1 schema creation + 1000 fast parses
```

**Dynamic schemas with caching:**

```typescript
import { z } from 'zod'

// Cache for dynamically-configured schemas
const schemaCache = new WeakMap<object, z.ZodType>()

function getSchemaForConfig(config: { fields: string[] }) {
  // Check cache first
  if (schemaCache.has(config)) {
    return schemaCache.get(config)!
  }

  // Create and cache
  const shape: Record<string, z.ZodString> = {}
  for (const field of config.fields) {
    shape[field] = z.string()
  }

  const schema = z.object(shape)
  schemaCache.set(config, schema)
  return schema
}

// Subsequent calls with same config reuse cached schema
```

**Lazy schema creation:**

```typescript
import { z } from 'zod'

// Schema created only when first used
let _userSchema: z.ZodObject<any> | null = null

function getUserSchema() {
  if (!_userSchema) {
    _userSchema = z.object({
      id: z.string().uuid(),
      email: z.string().email(),
      profile: z.object({
        name: z.string(),
        avatar: z.string().url().optional(),
      }),
    })
  }
  return _userSchema
}

// Or use a getter
const schemas = {
  _user: null as z.ZodType | null,
  get user() {
    if (!this._user) {
      this._user = z.object({ /* ... */ })
    }
    return this._user
  }
}
```

**Benchmark considerations:**

```typescript
// Zod 4 JIT compilation:
// - Schema creation: ~0.15ms per schema
// - First parse: triggers JIT compile
// - Subsequent parses: 7-14x faster

// For schemas used once:
// - Creation + parse: ~0.15ms + first-parse overhead
// - Consider if validation is even needed

// For schemas used many times:
// - Create once, parse many: optimal
// - JIT compilation amortized over all parses
```

**When NOT to use this pattern:**
- One-off validation where schema is used once
- Dynamically generated forms where fields change per request
- Test files where performance doesn't matter

Reference: [Zod v4 Performance](https://zod.dev/v4#performance)

### 8.2 Cache Schema Instances

**Impact: LOW-MEDIUM (Creating schemas on every render/call wastes CPU; module-level or memoized schemas are created once)**

Schema creation has overhead. Creating schemas inside render functions or on every function call wastes CPU cycles. Define schemas at module level or memoize them so they're created once and reused.

**Incorrect (creating schema every render):**

```typescript
import { z } from 'zod'

function UserForm() {
  // Schema created on EVERY render - wasteful
  const userSchema = z.object({
    name: z.string().min(1),
    email: z.string().email(),
    age: z.number().int().positive(),
  })

  const handleSubmit = (data: unknown) => {
    const result = userSchema.safeParse(data)
    // ...
  }

  return <form onSubmit={handleSubmit}>...</form>
}
```

**Correct (module-level schema):**

```typescript
import { z } from 'zod'

// Schema created ONCE at module load
const userSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive(),
})

type User = z.infer<typeof userSchema>

function UserForm() {
  const handleSubmit = (data: unknown) => {
    const result = userSchema.safeParse(data)
    // ...
  }

  return <form onSubmit={handleSubmit}>...</form>
}
```

**For dynamic schemas, use useMemo:**

```typescript
import { z } from 'zod'
import { useMemo } from 'react'

function DynamicForm({ minAge }: { minAge: number }) {
  // Schema only recreated when minAge changes
  const userSchema = useMemo(() =>
    z.object({
      name: z.string().min(1),
      age: z.number().min(minAge),
    }),
    [minAge]
  )

  // ...
}
```

**For server-side, use module cache:**

```typescript
// schemas/user.ts - created once per process
import { z } from 'zod'

export const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
})

// api/users.ts
import { userSchema } from '@/schemas/user'

export async function POST(req: Request) {
  const body = await req.json()
  const result = userSchema.safeParse(body)  // Reuses cached schema
  // ...
}
```

**Avoid schema factories in hot paths:**

```typescript
// BAD: Factory called on every validation
function createUserSchema(role: string) {
  return z.object({
    name: z.string(),
    permissions: z.array(z.string()),
  })
}

// Called in hot loop
users.forEach(user => {
  createUserSchema(user.role).parse(user)  // New schema every iteration!
})

// GOOD: Cache by key
const schemaCache = new Map<string, z.ZodObject<any>>()

function getUserSchema(role: string) {
  if (!schemaCache.has(role)) {
    schemaCache.set(role, z.object({
      name: z.string(),
      permissions: z.array(z.string()),
    }))
  }
  return schemaCache.get(role)!
}

// Reuses cached schemas
users.forEach(user => {
  getUserSchema(user.role).parse(user)
})
```

**When NOT to use this pattern:**
- One-off validation where schema is used once
- Test files where performance doesn't matter

Reference: [Zod Performance](https://zod.dev/v4#performance)

### 8.3 Lazy Load Large Schemas

**Impact: LOW-MEDIUM (Large schemas increase initial bundle and parse time; dynamic imports defer loading until needed)**

For applications with many complex schemas, importing all of them upfront increases initial bundle size and startup time. Use dynamic imports to lazy load schemas that aren't needed immediately.

**Incorrect (importing all schemas upfront):**

```typescript
// schemas/index.ts - barrel file with everything
export * from './user'
export * from './order'
export * from './product'
export * from './analytics'  // Large, complex schema
export * from './reports'    // Another large schema
export * from './admin'      // Admin-only schemas

// app/page.tsx
import { userSchema, orderSchema, analyticsSchema, reportsSchema } from '@/schemas'
// All schemas loaded even if not used on this page
```

**Correct (lazy loading schemas):**

```typescript
// Only import what's immediately needed
import { userSchema } from '@/schemas/user'

async function loadAnalyticsSchema() {
  const { analyticsSchema } = await import('@/schemas/analytics')
  return analyticsSchema
}

// Use when needed
async function handleAnalyticsData(data: unknown) {
  const schema = await loadAnalyticsSchema()
  return schema.safeParse(data)
}
```

**Route-based schema loading:**

```typescript
// app/admin/reports/page.tsx
'use client'

import { useEffect, useState } from 'react'
import type { z } from 'zod'

export default function ReportsPage() {
  const [schema, setSchema] = useState<z.ZodType | null>(null)

  useEffect(() => {
    // Load schema only when this route is accessed
    import('@/schemas/reports').then(({ reportsSchema }) => {
      setSchema(reportsSchema)
    })
  }, [])

  if (!schema) return <Loading />

  // Use schema...
}
```

**Better pattern with React Suspense:**

```typescript
// schemas/reports.ts
import { z } from 'zod'

export const reportsSchema = z.object({
  // Large complex schema
})

// app/admin/reports/page.tsx
import { lazy, Suspense } from 'react'

const ReportsForm = lazy(() => import('./ReportsForm'))

export default function ReportsPage() {
  return (
    <Suspense fallback={<Loading />}>
      <ReportsForm />
    </Suspense>
  )
}

// ReportsForm.tsx - schema imported with component
import { reportsSchema } from '@/schemas/reports'

export default function ReportsForm() {
  // Schema available when component loads
}
```

**Schema registry for conditional loading:**

```typescript
// schemas/registry.ts
const schemaLoaders = {
  user: () => import('./user').then(m => m.userSchema),
  order: () => import('./order').then(m => m.orderSchema),
  analytics: () => import('./analytics').then(m => m.analyticsSchema),
  reports: () => import('./reports').then(m => m.reportsSchema),
} as const

type SchemaName = keyof typeof schemaLoaders

const schemaCache = new Map<SchemaName, z.ZodType>()

export async function getSchema(name: SchemaName) {
  if (!schemaCache.has(name)) {
    const schema = await schemaLoaders[name]()
    schemaCache.set(name, schema)
  }
  return schemaCache.get(name)!
}

// Usage
const schema = await getSchema('analytics')
schema.parse(data)
```

**When NOT to use this pattern:**
- Server-side rendering where all code is available
- Small applications with few schemas
- Schemas used on every page (defeats purpose)

Reference: [Next.js Dynamic Imports](https://nextjs.org/docs/app/building-your-application/optimizing/lazy-loading)

### 8.4 Optimize Large Array Validation

**Impact: LOW-MEDIUM (Validating 10,000 items takes ~100ms; early exits, sampling, or batching reduce time for large datasets)**

Validating large arrays (thousands of items) can become a performance bottleneck. For batch imports, streaming data, or large datasets, consider strategies like early exit, sampling, or batched validation.

**Baseline performance:**

```typescript
import { z } from 'zod'

const itemSchema = z.object({
  id: z.string(),
  value: z.number(),
})

const arraySchema = z.array(itemSchema)

// 10,000 items: ~100ms
// 100,000 items: ~1000ms
arraySchema.parse(largeArray)
```

**Early exit on first error:**

```typescript
import { z } from 'zod'

function validateArrayFastFail<T>(
  schema: z.ZodType<T>,
  items: unknown[]
): { success: true; data: T[] } | { success: false; error: z.ZodError; index: number } {
  const validated: T[] = []

  for (let i = 0; i < items.length; i++) {
    const result = schema.safeParse(items[i])
    if (!result.success) {
      return { success: false, error: result.error, index: i }
    }
    validated.push(result.data)
  }

  return { success: true, data: validated }
}

// Stops at first invalid item instead of validating all
```

**Sample validation for large datasets:**

```typescript
function validateSample<T>(
  schema: z.ZodType<T>,
  items: unknown[],
  sampleSize: number = 100
): { valid: boolean; sampleErrors?: z.ZodIssue[] } {
  // Validate random sample
  const indices = new Set<number>()
  while (indices.size < Math.min(sampleSize, items.length)) {
    indices.add(Math.floor(Math.random() * items.length))
  }

  const errors: z.ZodIssue[] = []

  for (const i of indices) {
    const result = schema.safeParse(items[i])
    if (!result.success) {
      errors.push(...result.error.issues)
    }
  }

  return errors.length > 0
    ? { valid: false, sampleErrors: errors }
    : { valid: true }
}

// Check 100 random items from 100,000 - very fast
const check = validateSample(itemSchema, hugeArray)
```

**Batched validation with progress:**

```typescript
async function validateInBatches<T>(
  schema: z.ZodType<T>,
  items: unknown[],
  batchSize: number = 1000,
  onProgress?: (percent: number) => void
): Promise<z.SafeParseReturnType<unknown, T[]>> {
  const validated: T[] = []
  const errors: z.ZodIssue[] = []

  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize)

    // Validate batch
    for (let j = 0; j < batch.length; j++) {
      const result = schema.safeParse(batch[j])
      if (result.success) {
        validated.push(result.data)
      } else {
        errors.push(...result.error.issues.map(issue => ({
          ...issue,
          path: [i + j, ...issue.path],
        })))
      }
    }

    // Report progress and yield to event loop
    onProgress?.(Math.min(100, ((i + batchSize) / items.length) * 100))
    await new Promise(resolve => setTimeout(resolve, 0))
  }

  if (errors.length > 0) {
    return { success: false, error: new z.ZodError(errors) }
  }
  return { success: true, data: validated }
}

// Use with progress reporting
await validateInBatches(itemSchema, largeArray, 1000, (percent) => {
  console.log(`Validating: ${percent.toFixed(1)}%`)
})
```

**Streaming validation:**

```typescript
async function* validateStream<T>(
  schema: z.ZodType<T>,
  items: AsyncIterable<unknown>
): AsyncGenerator<T, void, unknown> {
  for await (const item of items) {
    yield schema.parse(item)  // Throws on invalid
  }
}

// Process items as they arrive
for await (const validItem of validateStream(itemSchema, dataStream)) {
  await processItem(validItem)
}
```

**When NOT to use this pattern:**
- Small arrays (< 1000 items) - standard validation is fine
- When all items must be validated for correctness guarantees

Reference: [Zod Performance](https://zod.dev/v4#performance)

### 8.5 Use Zod Mini for Bundle-Sensitive Applications

**Impact: LOW-MEDIUM (Full Zod is ~17kb gzipped; Zod Mini is ~1.9kb - 85% smaller for frontend-critical bundles)**

For frontend applications where bundle size is critical, use `@zod/mini` instead of `zod`. Zod Mini provides the same validation capabilities with a functional API that tree-shakes better, reducing bundle size by ~85%.

**When to consider Zod Mini:**

```typescript
// Your app if:
// - Bundle size is critical (mobile-first, slow networks)
// - Edge functions with size limits
// - Simple validation needs (no complex transforms)
// - Tree-shaking is important

// Zod: ~17kb gzipped
import { z } from 'zod'

// Zod Mini: ~1.9kb gzipped (when tree-shaken)
import * as z from '@zod/mini'
```

**Standard Zod (method chaining):**

```typescript
import { z } from 'zod'

// Methods are attached to schema objects - hard to tree-shake
const userSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().positive(),
})

const result = userSchema.safeParse(data)
```

**Zod Mini (functional API):**

```typescript
import * as z from '@zod/mini'

// Functions are imported individually - tree-shakeable
const userSchema = z.object({
  name: z.pipe(z.string(), z.minLength(1), z.maxLength(100)),
  email: z.pipe(z.string(), z.email()),
  age: z.pipe(z.number(), z.int(), z.positive()),
})

const result = z.safeParse(userSchema, data)
```

**API differences:**

```typescript
// Standard Zod
z.string().min(5).max(100).email()
z.number().int().positive()
z.array(z.string()).min(1)
schema.parse(data)
schema.safeParse(data)

// Zod Mini
z.pipe(z.string(), z.minLength(5), z.maxLength(100), z.email())
z.pipe(z.number(), z.int(), z.positive())
z.pipe(z.array(z.string()), z.minLength(1))
z.parse(schema, data)
z.safeParse(schema, data)
```

**When to stick with regular Zod:**

```typescript
// Use regular Zod when:
// - Server-side where bundle size doesn't matter
// - Complex schemas with many transforms
// - Need full method chaining ergonomics
// - Bundle size isn't a constraint

// The 17kb isn't huge - only optimize if needed
// Server: 17kb is negligible
// Browser: 17kb ≈ 0.6ms additional startup on 3G
```

**Shared schemas between packages:**

```typescript
// shared-schemas/package.json
{
  "dependencies": {
    "@zod/mini": "^4.0.0"  // Mini for frontend-shared schemas
  }
}

// If you need both, Zod Mini schemas work with regular Zod
// But prefer consistency - pick one for your codebase
```

**Bundle size comparison:**

| Package | Gzipped Size | Use Case |
|---------|--------------|----------|
| `zod@3` | ~13kb | Legacy, stable |
| `zod@4` | ~17kb | Full features |
| `@zod/mini` | ~1.9kb | Bundle-critical |

**When NOT to use this pattern:**
- Server-side applications (bundle size irrelevant)
- When method chaining ergonomics are preferred
- Complex schemas that benefit from full API

Reference: [Zod Mini](https://zod.dev/packages/mini)

---

## References

1. [https://zod.dev/](https://zod.dev/)
2. [https://zod.dev/v4](https://zod.dev/v4)
3. [https://github.com/colinhacks/zod](https://github.com/colinhacks/zod)
4. [https://zod.dev/packages/mini](https://zod.dev/packages/mini)
5. [https://www.totaltypescript.com/tutorials/zod](https://www.totaltypescript.com/tutorials/zod)
6. [https://zod.dev/error-handling](https://zod.dev/error-handling)
7. [https://zod.dev/api](https://zod.dev/api)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |