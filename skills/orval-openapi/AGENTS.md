# Orval OpenAPI

**Version 0.1.0**  
Orval Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for Orval OpenAPI TypeScript client generation, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (OpenAPI spec quality, configuration architecture) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated configuration and code generation.

---

## Table of Contents

1. [OpenAPI Specification Quality](#1-openapi-specification-quality) — **CRITICAL**
   - 1.1 [Define All Response Types Explicitly](#11-define-all-response-types-explicitly)
   - 1.2 [Define Reusable Schemas in Components](#12-define-reusable-schemas-in-components)
   - 1.3 [Mark Required Fields Explicitly](#13-mark-required-fields-explicitly)
   - 1.4 [Organize Operations with Tags](#14-organize-operations-with-tags)
   - 1.5 [Use Unique and Descriptive operationIds](#15-use-unique-and-descriptive-operationids)
2. [Configuration Architecture](#2-configuration-architecture) — **CRITICAL**
   - 2.1 [Choose Output Mode Based on API Size](#21-choose-output-mode-based-on-api-size)
   - 2.2 [Configure Base URL Properly](#22-configure-base-url-properly)
   - 2.3 [Enable Automatic Code Formatting](#23-enable-automatic-code-formatting)
   - 2.4 [Select Client Based on Framework Requirements](#24-select-client-based-on-framework-requirements)
   - 2.5 [Separate Schemas into Dedicated Directory](#25-separate-schemas-into-dedicated-directory)
   - 2.6 [Validate OpenAPI Spec Before Generation](#26-validate-openapi-spec-before-generation)
3. [Output Structure & Organization](#3-output-structure-organization) — **HIGH**
   - 3.1 [Configure Consistent Naming Conventions](#31-configure-consistent-naming-conventions)
   - 3.2 [Enable Clean Mode for Consistent Regeneration](#32-enable-clean-mode-for-consistent-regeneration)
   - 3.3 [Enable Headers in Generated Functions](#33-enable-headers-in-generated-functions)
   - 3.4 [Generate Index Files for Clean Imports](#34-generate-index-files-for-clean-imports)
   - 3.5 [Use Distinct File Extensions for Generated Code](#35-use-distinct-file-extensions-for-generated-code)
4. [Custom Client & Mutators](#4-custom-client-mutators) — **HIGH**
   - 4.1 [Export Body Type Wrapper for Request Transformation](#41-export-body-type-wrapper-for-request-transformation)
   - 4.2 [Export Custom Error Types from Mutator](#42-export-custom-error-types-from-mutator)
   - 4.3 [Handle Token Refresh in Mutator](#43-handle-token-refresh-in-mutator)
   - 4.4 [Use Custom Mutator for HTTP Client Configuration](#44-use-custom-mutator-for-http-client-configuration)
   - 4.5 [Use Fetch Mutator for Smaller Bundle Size](#45-use-fetch-mutator-for-smaller-bundle-size)
   - 4.6 [Use Interceptors for Cross-Cutting Concerns](#46-use-interceptors-for-cross-cutting-concerns)
5. [Query Library Integration](#5-query-library-integration) — **MEDIUM-HIGH**
   - 5.1 [Configure Default Query Options Globally](#51-configure-default-query-options-globally)
   - 5.2 [Enable Infinite Queries for Paginated Endpoints](#52-enable-infinite-queries-for-paginated-endpoints)
   - 5.3 [Enable Suspense Mode for Streaming UX](#53-enable-suspense-mode-for-streaming-ux)
   - 5.4 [Export Query Keys for Cache Invalidation](#54-export-query-keys-for-cache-invalidation)
   - 5.5 [Pass AbortSignal for Request Cancellation](#55-pass-abortsignal-for-request-cancellation)
   - 5.6 [Use Generated Mutation Options Types](#56-use-generated-mutation-options-types)
6. [Type Safety & Validation](#6-type-safety-validation) — **MEDIUM**
   - 6.1 [Enable useBigInt for Large Integer Support](#61-enable-usebigint-for-large-integer-support)
   - 6.2 [Enable useDates for Date Type Generation](#62-enable-usedates-for-date-type-generation)
   - 6.3 [Enable Zod Strict Mode for Safer Validation](#63-enable-zod-strict-mode-for-safer-validation)
   - 6.4 [Generate Zod Schemas for Runtime Validation](#64-generate-zod-schemas-for-runtime-validation)
   - 6.5 [Use Zod Coercion for Type Transformations](#65-use-zod-coercion-for-type-transformations)
7. [Mock Generation & Testing](#7-mock-generation-testing) — **MEDIUM**
   - 7.1 [Configure Mock Response Delays](#71-configure-mock-response-delays)
   - 7.2 [Generate Mock Index Files for Easy Setup](#72-generate-mock-index-files-for-easy-setup)
   - 7.3 [Generate Mocks for All HTTP Status Codes](#73-generate-mocks-for-all-http-status-codes)
   - 7.4 [Generate MSW Handlers for Testing](#74-generate-msw-handlers-for-testing)
   - 7.5 [Use OpenAPI Examples for Realistic Mocks](#75-use-openapi-examples-for-realistic-mocks)
8. [Advanced Patterns](#8-advanced-patterns) — **LOW**
   - 8.1 [Configure Form Data Serialization](#81-configure-form-data-serialization)
   - 8.2 [Override Settings per Operation](#82-override-settings-per-operation)
   - 8.3 [Use Input Transformer for Spec Preprocessing](#83-use-input-transformer-for-spec-preprocessing)
   - 8.4 [Use Output Transformer for Generated Code Modification](#84-use-output-transformer-for-generated-code-modification)

---

## 1. OpenAPI Specification Quality

**Impact: CRITICAL**

Poor specification quality cascades into broken types, missing models, and runtime errors. Fixing upstream prevents downstream pain.

### 1.1 Define All Response Types Explicitly

**Impact: CRITICAL (prevents unknown/any types in generated code)**

Define response schemas for all status codes your API returns. Missing response definitions generate `unknown` or `any` types, eliminating type safety benefits.

**Incorrect (missing response schemas):**

```yaml
paths:
  /users:
    post:
      operationId: createUser
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: Created
          # No schema - generates unknown type
        '400':
          description: Bad request
          # No error schema
        '500':
          description: Server error
```

**Correct (explicit response schemas):**

```yaml
paths:
  /users:
    post:
      operationId: createUser
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: Created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          description: Bad request
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ValidationError'
        '500':
          description: Server error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ServerError'

components:
  schemas:
    ValidationError:
      type: object
      properties:
        message:
          type: string
        errors:
          type: array
          items:
            type: object
            properties:
              field:
                type: string
              message:
                type: string
```

**Benefits:**
- Generated hooks have proper return types
- Error handling can be type-safe
- IDE autocomplete works for all responses

Reference: [OpenAPI Responses](https://swagger.io/docs/specification/describing-responses/)

### 1.2 Define Reusable Schemas in Components

**Impact: CRITICAL (reduces generated code by 50-80%, enables type reuse)**

Define shared data structures in `components/schemas` and reference them with `$ref`. Inline schemas generate duplicate TypeScript interfaces, bloating output and breaking type consistency.

**Incorrect (inline schema definitions):**

```yaml
paths:
  /users:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object
                properties:
                  id:
                    type: string
                  email:
                    type: string
                  name:
                    type: string
  /users/{id}:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object  # Duplicated definition
                properties:
                  id:
                    type: string
                  email:
                    type: string
                  name:
                    type: string
```

**Correct (reusable schema references):**

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        email:
          type: string
        name:
          type: string
      required:
        - id
        - email

paths:
  /users:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
  /users/{id}:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
```

**Benefits:**
- Single TypeScript `User` type generated once
- Changes propagate to all usages automatically
- Smaller bundle, better IDE autocomplete

Reference: [OpenAPI Components](https://swagger.io/docs/specification/components/)

### 1.3 Mark Required Fields Explicitly

**Impact: CRITICAL (prevents optional chaining everywhere, improves type narrowing)**

Always specify the `required` array for object schemas. Without it, Orval generates all properties as optional (`field?: type`), forcing unnecessary null checks throughout your code.

**Incorrect (missing required specification):**

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        email:
          type: string
        name:
          type: string
        avatar:
          type: string
      # No required array - all fields become optional
```

**Generated TypeScript (all optional):**

```typescript
interface User {
  id?: string;
  email?: string;
  name?: string;
  avatar?: string;
}

// Forces defensive coding everywhere
const displayName = user.name ?? user.email ?? 'Unknown';
```

**Correct (explicit required fields):**

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        email:
          type: string
        name:
          type: string
        avatar:
          type: string
      required:
        - id
        - email
        - name
```

**Generated TypeScript (correct nullability):**

```typescript
interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;  // Only truly optional field
}

// Clean code without defensive checks
const displayName = user.name;
```

**When NOT to use this pattern:**
- Fields that are genuinely optional in API responses
- Partial update request bodies where any field can be omitted

Reference: [OpenAPI Required Properties](https://swagger.io/docs/specification/data-models/data-types/)

### 1.4 Organize Operations with Tags

**Impact: CRITICAL (enables tags-split mode, improves code organization)**

Apply meaningful tags to every operation. Orval's `tags` and `tags-split` modes use these to organize generated code into logical files and folders, enabling better tree-shaking and imports.

**Incorrect (missing or inconsistent tags):**

```yaml
paths:
  /users:
    get:
      operationId: listUsers
      # No tag - goes into default bucket
      responses:
        '200':
          description: Success
  /orders:
    get:
      operationId: listOrders
      tags:
        - order  # Inconsistent casing
      responses:
        '200':
          description: Success
    post:
      operationId: createOrder
      tags:
        - Orders  # Different tag for same resource
      responses:
        '201':
          description: Created
```

**Correct (consistent, meaningful tags):**

```yaml
tags:
  - name: users
    description: User management operations
  - name: orders
    description: Order processing operations

paths:
  /users:
    get:
      operationId: listUsers
      tags:
        - users
      responses:
        '200':
          description: Success
  /orders:
    get:
      operationId: listOrders
      tags:
        - orders
      responses:
        '200':
          description: Success
    post:
      operationId: createOrder
      tags:
        - orders
      responses:
        '201':
          description: Created
```

**Generated structure with `tags-split` mode:**
```plaintext
src/gen/
├── users/
│   ├── users.ts
│   └── users.msw.ts
└── orders/
    ├── orders.ts
    └── orders.msw.ts
```

Reference: [Orval tags-split mode](https://orval.dev/reference/configuration/output)

### 1.5 Use Unique and Descriptive operationIds

**Impact: CRITICAL (prevents duplicate function names and import collisions)**

Every OpenAPI operation must have a unique `operationId`. Orval uses this as the generated function and hook name. Duplicates cause compilation errors; vague names hurt discoverability.

**Incorrect (missing or vague operationIds):**

```yaml
paths:
  /users:
    get:
      summary: Get users
      # No operationId - Orval will auto-generate an ugly name
      responses:
        '200':
          description: Success
  /users/{id}:
    get:
      operationId: get  # Too vague, may collide
      responses:
        '200':
          description: Success
```

**Correct (unique, descriptive operationIds):**

```yaml
paths:
  /users:
    get:
      operationId: listUsers
      summary: Get users
      responses:
        '200':
          description: Success
  /users/{id}:
    get:
      operationId: getUserById
      summary: Get user by ID
      responses:
        '200':
          description: Success
```

**Naming convention:**
- Use camelCase: `listUsers`, `createOrder`, `deleteUserById`
- Include the resource: `getUser` not just `get`
- Include action context: `getUserById` vs `listUsers`

Reference: [OpenAPI operationId](https://www.apimatic.io/openapi/operationid)

---

## 2. Configuration Architecture

**Impact: CRITICAL**

Wrong mode, client, or structure choices multiply into bundle bloat, poor developer experience, and maintenance nightmares.

### 2.1 Choose Output Mode Based on API Size

**Impact: CRITICAL (2-5× bundle size difference, affects tree-shaking)**

Select the appropriate output mode based on your API size. Wrong choices cause bundle bloat or unnecessary complexity.

**Incorrect (single mode for large API):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: './openapi.yaml',  // 200+ endpoints
    output: {
      target: 'src/api.ts',
      mode: 'single',  // Everything in one massive file
    },
  },
});
```

**Problem:** Single 50KB+ file imported everywhere, no tree-shaking possible.

**Correct (tags-split for large APIs):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: './openapi.yaml',
    output: {
      target: 'src/api',
      schemas: 'src/api/models',
      mode: 'tags-split',  // Separate folders per tag
      client: 'react-query',
    },
  },
});
```

**Mode selection guide:**

| API Size | Endpoints | Recommended Mode |
|----------|-----------|------------------|
| Small | 1-20 | `single` or `split` |
| Medium | 20-100 | `split` or `tags` |
| Large | 100+ | `tags-split` |

**Benefits of `tags-split`:**
- Each tag becomes its own folder
- Unused endpoints are tree-shaken
- Imports are more explicit: `import { useGetUser } from '@/api/users'`

Reference: [Orval Output Modes](https://orval.dev/reference/configuration/output)

### 2.2 Configure Base URL Properly

**Impact: CRITICAL (prevents 404 errors in production, enables environment switching)**

Configure the base URL through the mutator or config, not hardcoded in generated code. Orval's default fetch functions don't include a base URL, causing 404s when frontend and backend are on different domains.

**Incorrect (no base URL configuration):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // No baseUrl - requests go to relative paths
    },
  },
});
```

**Generated code makes relative requests:**
```typescript
// Calls /users instead of https://api.example.com/users
fetch('/users')  // 404 if frontend is on different domain
```

**Correct (base URL via mutator):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      override: {
        mutator: {
          path: './src/api/mutator.ts',
          name: 'customFetch',
        },
      },
    },
  },
});
```

```typescript
// src/api/mutator.ts
const BASE_URL = import.meta.env.VITE_API_URL || 'https://api.example.com';

export const customFetch = async <T>(config: RequestInit & { url: string }): Promise<T> => {
  const response = await fetch(`${BASE_URL}${config.url}`, config);

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }

  return response.json();
};
```

**Alternative (from OpenAPI servers):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      baseUrl: {
        getFromServers: true,  // Use servers[0].url from spec
      },
    },
  },
});
```

Reference: [Orval baseUrl Configuration](https://orval.dev/reference/configuration/output)

### 2.3 Enable Automatic Code Formatting

**Impact: HIGH (ensures consistent code style, prevents lint errors)**

Configure Orval to format generated code with Prettier or Biome. Unformatted generated code causes CI failures and clutters diffs.

**Incorrect (no formatting):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // No prettier config - generated code may not match project style
    },
  },
});
```

**Generated code has inconsistent formatting:**
```typescript
export const getUsers=()=>fetch('/users').then(res=>res.json())
```

**Correct (with Prettier):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      prettier: true,  // Use project's .prettierrc
    },
  },
});
```

**Or with explicit config:**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      prettier: {
        singleQuote: true,
        trailingComma: 'es5',
        tabWidth: 2,
      },
    },
  },
});
```

**For Biome users:**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      biome: true,  // Use project's biome.json
    },
  },
});
```

Reference: [Orval Formatting Options](https://orval.dev/reference/configuration/output)

### 2.4 Select Client Based on Framework Requirements

**Impact: CRITICAL (determines bundle size, DX, and caching capabilities)**

Choose the right client option for your framework. Each generates different code with different dependencies and capabilities.

**Incorrect (wrong client for use case):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      client: 'axios',  // Plain axios for React app using TanStack Query
    },
  },
});
```

**Problem:** Manual query setup, no caching, no automatic refetching.

**Correct (framework-appropriate client):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      client: 'react-query',  // Generates useQuery/useMutation hooks
      httpClient: 'fetch',    // Underlying HTTP client
    },
  },
});
```

**Client selection guide:**

| Framework | Client | What's Generated |
|-----------|--------|------------------|
| React + TanStack Query | `react-query` | `useQuery`, `useMutation` hooks |
| React + SWR | `swr` | `useSWR`, `useSWRMutation` hooks |
| Vue + TanStack | `vue-query` | Vue composition API hooks |
| Svelte + TanStack | `svelte-query` | Svelte store-based hooks |
| Angular | `angular` | Injectable services |
| Vanilla JS/Node | `axios` or `fetch` | Plain functions |
| Validation only | `zod` | Zod schemas |

**httpClient options:**
- `fetch` (default): Smaller bundle, native browser API
- `axios`: More features (interceptors, progress), larger bundle

Reference: [Orval Client Options](https://orval.dev/reference/configuration/output)

### 2.5 Separate Schemas into Dedicated Directory

**Impact: CRITICAL (enables clean imports, prevents circular dependencies)**

Configure a separate `schemas` directory for generated TypeScript interfaces. Mixing schemas with endpoint code creates import confusion and potential circular dependencies.

**Incorrect (schemas mixed with endpoints):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api/endpoints',
      // No schemas config - types mixed in with endpoints
    },
  },
});
```

**Resulting structure:**
```plaintext
src/api/endpoints/
├── users.ts        # Contains both User type AND useGetUser hook
├── orders.ts       # Contains both Order type AND useGetOrder hook
└── index.ts
```

**Problem:** Importing just the `User` type pulls in React Query as a dependency.

**Correct (dedicated schemas directory):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api/endpoints',
      schemas: 'src/api/models',  // Separate directory
      mode: 'tags-split',
    },
  },
});
```

**Resulting structure:**
```plaintext
src/api/
├── endpoints/
│   ├── users/
│   │   └── users.ts    # Only hooks
│   └── orders/
│       └── orders.ts
└── models/
    ├── user.ts         # Only types
    ├── order.ts
    └── index.ts
```

**Benefits:**
- Import types without pulling in runtime dependencies
- Share types with backend (monorepo)
- Cleaner dependency graph

Reference: [Orval schemas option](https://orval.dev/reference/configuration/output)

### 2.6 Validate OpenAPI Spec Before Generation

**Impact: CRITICAL (prevents silent failures and incorrect type generation)**

Enable input validation to catch OpenAPI spec issues before code generation. Silent failures from invalid specs create subtle bugs that surface at runtime.

**Incorrect (no validation):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: {
      target: './openapi.yaml',
      // No validation - invalid specs generate broken code
    },
    output: {
      target: 'src/api',
    },
  },
});
```

**Correct (with validation):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: {
      target: './openapi.yaml',
      validation: true,  // Validate spec before generation
    },
    output: {
      target: 'src/api',
    },
  },
});
```

**For remote specs, add filters:**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: {
      target: 'https://api.example.com/openapi.json',
      validation: true,
      filters: {
        tags: ['users', 'orders'],  // Only generate for specific tags
      },
    },
    output: {
      target: 'src/api',
    },
  },
});
```

**Common validation catches:**
- Missing `$ref` targets
- Invalid schema types
- Duplicate operationIds
- Malformed response definitions

Reference: [Orval Input Configuration](https://orval.dev/reference/configuration/input)

---

## 3. Output Structure & Organization

**Impact: HIGH**

File organization directly affects tree-shaking effectiveness, import ergonomics, and long-term maintainability.

### 3.1 Configure Consistent Naming Conventions

**Impact: HIGH (prevents casing mismatches, improves code consistency)**

Configure naming conventions to match your codebase style. APIs often use snake_case while TypeScript prefers camelCase, causing inconsistent property access.

**Incorrect (no naming convention):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // No namingConvention - uses whatever API returns
    },
  },
});
```

**Generated types mirror API casing:**
```typescript
interface User {
  first_name: string;  // snake_case from API
  last_name: string;
  created_at: string;
}

// Inconsistent with TypeScript conventions
const fullName = `${user.first_name} ${user.last_name}`;
```

**Correct (with camelCase conversion):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      override: {
        namingConvention: {
          property: 'camelCase',
        },
      },
    },
  },
});
```

**Generated types use camelCase:**
```typescript
interface User {
  firstName: string;
  lastName: string;
  createdAt: string;
}

// Consistent TypeScript style
const fullName = `${user.firstName} ${user.lastName}`;
```

**Important:** You need a mutator to transform runtime data:

```typescript
// mutator.ts
import { camelizeKeys } from 'humps';

export const customFetch = async <T>(config: RequestConfig): Promise<T> => {
  const response = await fetch(config.url, config);
  const data = await response.json();
  return camelizeKeys(data) as T;
};
```

Reference: [Orval namingConvention](https://orval.dev/reference/configuration/output)

### 3.2 Enable Clean Mode for Consistent Regeneration

**Impact: HIGH (prevents stale files, ensures deterministic output)**

Enable `clean` mode to remove old generated files before regeneration. Without it, deleted endpoints leave orphan files that cause import errors or ship dead code.

**Incorrect (no clean mode):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // No clean - old files persist
    },
  },
});
```

**Problem scenario:**
1. API has `/users` and `/orders` endpoints
2. Orval generates `users.ts` and `orders.ts`
3. Backend removes `/orders` endpoint
4. Regenerate: `users.ts` updated, `orders.ts` still exists
5. Code still imports from `orders.ts` - builds but crashes at runtime

**Correct (with clean mode):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      clean: true,  // Delete target directory before generation
    },
  },
});
```

**For selective cleaning:**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      clean: ['src/api/endpoints'],  // Only clean specific directories
    },
  },
});
```

**When NOT to use this pattern:**
- When target directory contains hand-written code
- Use selective array syntax to protect specific paths

Reference: [Orval clean Option](https://orval.dev/reference/configuration/output)

### 3.3 Enable Headers in Generated Functions

**Impact: HIGH (enables custom headers per request without mutator hacks)**

Enable the `headers` option when you need to pass custom headers per request. Without it, all header customization must go through a global mutator.

**Incorrect (headers disabled):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // headers not enabled - can't pass per-request headers
    },
  },
});
```

**No way to pass request-specific headers:**
```typescript
// Can't add custom header for this specific call
const { data } = useGetUserDocuments(userId);
```

**Correct (headers enabled):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      headers: true,
    },
  },
});
```

**Generated functions accept headers:**
```typescript
// Pass custom headers per request
const { data } = useGetUserDocuments(userId, {
  headers: {
    'X-Custom-Header': 'value',
    'Accept-Language': userLocale,
  },
});
```

**Use cases:**
- Per-request authorization tokens
- Content negotiation headers
- Correlation IDs for tracing
- Feature flags via headers

**When NOT to use this pattern:**
- All headers are global (use mutator instead)
- API doesn't require per-request header customization

Reference: [Orval headers Option](https://orval.dev/reference/configuration/output)

### 3.4 Generate Index Files for Clean Imports

**Impact: HIGH (simplifies imports, enables barrel exports)**

Enable index file generation for cleaner imports. Without index files, consumers must import from deeply nested paths.

**Incorrect (no index files):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      mode: 'tags-split',
      // No indexFiles - deep imports required
    },
  },
});
```

**Consumer must use deep imports:**
```typescript
import { useGetUser } from '@/api/users/users';
import { useGetOrder } from '@/api/orders/orders';
import { User } from '@/api/users/users.schemas';
```

**Correct (with index files):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      mode: 'tags-split',
      indexFiles: true,
    },
  },
});
```

**Generated structure:**
```plaintext
src/api/
├── index.ts          # Re-exports all
├── users/
│   ├── index.ts      # Re-exports users hooks
│   └── users.ts
└── orders/
    ├── index.ts
    └── orders.ts
```

**Clean consumer imports:**
```typescript
import { useGetUser, useGetOrder } from '@/api';
// Or scoped:
import { useGetUser } from '@/api/users';
```

**When NOT to use this pattern:**
- When using `single` mode (already one file)
- When tree-shaking is critical and barrel files hurt bundler analysis

Reference: [Orval indexFiles Option](https://orval.dev/reference/configuration/output)

### 3.5 Use Distinct File Extensions for Generated Code

**Impact: HIGH (prevents accidental edits, enables gitignore patterns)**

Configure a distinct file extension like `.gen.ts` for generated files. This prevents accidental manual edits and enables easy gitignore patterns for CI regeneration strategies.

**Incorrect (default .ts extension):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api/endpoints',
      // Default .ts extension - indistinguishable from hand-written code
    },
  },
});
```

**Problems:**
- Developers may accidentally edit generated files
- Hard to set up lint/format rules specifically for generated code
- No clear visual indicator in file explorer

**Correct (distinct extension):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api/endpoints',
      fileExtension: '.gen.ts',
    },
  },
});
```

**Resulting files:**
```plaintext
src/api/endpoints/
├── users.gen.ts
├── orders.gen.ts
└── models.gen.ts
```

**Configure tooling:**

```gitignore
# .gitignore (for CI regeneration strategy)
*.gen.ts
```

```json
// .eslintrc.json
{
  "ignorePatterns": ["*.gen.ts"]
}
```

**When NOT to use this pattern:**
- Small projects where generated code is committed
- When team prefers standard `.ts` extension

Reference: [Orval fileExtension Option](https://orval.dev/reference/configuration/output)

---

## 4. Custom Client & Mutators

**Impact: HIGH**

HTTP client setup affects authentication, error handling, request/response transformation, and cross-cutting concerns.

### 4.1 Export Body Type Wrapper for Request Transformation

**Impact: HIGH (enables consistent request body preprocessing)**

Export a `BodyType` wrapper when you need to preprocess all request bodies. This is essential when your API expects a different format than your TypeScript types.

**Incorrect (no body transformation):**

```typescript
// mutator.ts
export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return axios(config).then(({ data }) => data);
};
// API expects snake_case but TypeScript uses camelCase
```

**Request bodies sent in wrong format:**
```typescript
// TypeScript type uses camelCase
const user = { firstName: 'John', lastName: 'Doe' };
createUser(user);
// API receives { firstName, lastName } but expects { first_name, last_name }
```

**Correct (with body wrapper):**

```typescript
// mutator.ts
import Axios, { AxiosRequestConfig } from 'axios';
import { decamelizeKeys } from 'humps';

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return Axios(config).then(({ data }) => data);
};

// Wrapper that converts camelCase to snake_case
export type BodyType<D> = D;

export const bodySerializer = <D>(data: D): unknown => {
  return decamelizeKeys(data as Record<string, unknown>);
};
```

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      override: {
        mutator: {
          path: './src/api/mutator.ts',
          name: 'customInstance',
        },
        requestBodyTransformer: {
          path: './src/api/mutator.ts',
          name: 'bodySerializer',
        },
      },
    },
  },
});
```

**Now works correctly:**
```typescript
const user = { firstName: 'John', lastName: 'Doe' };
createUser(user);
// API receives { first_name: 'John', last_name: 'Doe' }
```

Reference: [Orval Body Type](https://orval.dev/guides/custom-axios)

### 4.2 Export Custom Error Types from Mutator

**Impact: HIGH (enables type-safe error handling in hooks)**

Export `ErrorType` from your mutator to enable type-safe error handling. Without it, caught errors are typed as `unknown`, requiring unsafe type assertions.

**Incorrect (no error type export):**

```typescript
// mutator.ts
export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return axios(config).then(({ data }) => data);
};
// No ErrorType export
```

**Error handling is untyped:**
```typescript
const { error } = useCreateUser();

if (error) {
  // error is unknown - no type safety
  console.log(error.response?.data?.message);  // TypeScript error
}
```

**Correct (with error type export):**

```typescript
// mutator.ts
import Axios, { AxiosError, AxiosRequestConfig } from 'axios';

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return Axios(config).then(({ data }) => data);
};

// Export error type for generated hooks
export type ErrorType<E> = AxiosError<E>;
```

**Type-safe error handling:**
```typescript
interface ApiError {
  message: string;
  code: string;
  errors?: Record<string, string[]>;
}

const { error } = useCreateUser<ApiError>();

if (error) {
  // error is AxiosError<ApiError> - fully typed
  const message = error.response?.data?.message;
  const fieldErrors = error.response?.data?.errors;
}
```

**For fetch-based clients:**

```typescript
// mutator.ts
export type ErrorType<E> = Error & { data?: E; status?: number };

export const customFetch = async <T>(config: RequestConfig): Promise<T> => {
  const response = await fetch(config.url, config);

  if (!response.ok) {
    const error = new Error('Request failed') as ErrorType<unknown>;
    error.data = await response.json();
    error.status = response.status;
    throw error;
  }

  return response.json();
};
```

Reference: [Orval Error Types](https://orval.dev/guides/custom-axios)

### 4.3 Handle Token Refresh in Mutator

**Impact: HIGH (prevents 401 cascades, automatic retry on token expiry)**

Implement token refresh logic in your mutator's interceptors. This handles expired tokens transparently without requiring retry logic in every component.

**Incorrect (no refresh handling):**

```typescript
// mutator.ts
AXIOS_INSTANCE.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  config.headers.Authorization = `Bearer ${token}`;
  return config;
});
// 401 errors bubble up to every component
```

**Correct (automatic token refresh):**

```typescript
// mutator.ts
import Axios, { AxiosError, AxiosRequestConfig } from 'axios';

let isRefreshing = false;
let failedQueue: Array<{ resolve: (t: string) => void; reject: (e: Error) => void }> = [];

const processQueue = (error: Error | null, token: string | null) => {
  failedQueue.forEach((p) => error ? p.reject(error) : p.resolve(token!));
  failedQueue = [];
};

export const AXIOS_INSTANCE = Axios.create({ baseURL: import.meta.env.VITE_API_URL });

AXIOS_INSTANCE.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as AxiosRequestConfig & { _retry?: boolean };

    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        }).then((token) => {
          originalRequest.headers!.Authorization = `Bearer ${token}`;
          return AXIOS_INSTANCE(originalRequest);
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        const { data } = await Axios.post('/auth/refresh', {
          refreshToken: localStorage.getItem('refreshToken'),
        });
        localStorage.setItem('accessToken', data.accessToken);
        processQueue(null, data.accessToken);
        originalRequest.headers!.Authorization = `Bearer ${data.accessToken}`;
        return AXIOS_INSTANCE(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError as Error, null);
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }
    return Promise.reject(error);
  }
);

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return AXIOS_INSTANCE(config).then(({ data }) => data);
};
```

Reference: [Axios Interceptors](https://axios-http.com/docs/interceptors)

### 4.4 Use Custom Mutator for HTTP Client Configuration

**Impact: HIGH (centralizes auth, error handling, and cross-cutting concerns)**

Create a custom mutator to centralize HTTP client configuration. This is where authentication, error handling, base URLs, and request/response transformations belong.

**Incorrect (no mutator, scattered configuration):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // No mutator - auth must be added to every call
    },
  },
});
```

**Auth scattered across components:**
```typescript
const { data } = useGetUser(userId, {
  headers: { Authorization: `Bearer ${token}` },  // Repeated everywhere
});
```

**Correct (centralized mutator):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      override: {
        mutator: {
          path: './src/api/mutator.ts',
          name: 'customInstance',
        },
      },
    },
  },
});
```

```typescript
// src/api/mutator.ts
import Axios, { AxiosRequestConfig, AxiosError } from 'axios';

export const AXIOS_INSTANCE = Axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

AXIOS_INSTANCE.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return AXIOS_INSTANCE(config).then(({ data }) => data);
};

export type ErrorType<E> = AxiosError<E>;
```

**Clean component usage:**
```typescript
// Auth automatically included
const { data } = useGetUser(userId);
```

Reference: [Orval Custom Axios](https://orval.dev/guides/custom-axios)

### 4.5 Use Fetch Mutator for Smaller Bundle Size

**Impact: MEDIUM-HIGH (eliminates axios dependency, 10-20KB bundle savings)**

Use native fetch instead of Axios when you don't need Axios-specific features. This eliminates a dependency and reduces bundle size.

**Incorrect (Axios for simple use case):**

```typescript
// mutator.ts
import Axios, { AxiosRequestConfig } from 'axios';  // +15KB

export const AXIOS_INSTANCE = Axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return AXIOS_INSTANCE(config).then(({ data }) => data);
};
```

**Correct (native fetch):**

```typescript
// mutator.ts
const BASE_URL = import.meta.env.VITE_API_URL;

interface RequestConfig {
  url: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  params?: Record<string, string>;
  data?: unknown;
  headers?: Record<string, string>;
  signal?: AbortSignal;
}

export const customFetch = async <T>(config: RequestConfig): Promise<T> => {
  const { url, method, params, data, headers, signal } = config;

  const queryString = params
    ? `?${new URLSearchParams(params).toString()}`
    : '';

  const token = localStorage.getItem('accessToken');

  const response = await fetch(`${BASE_URL}${url}${queryString}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...headers,
    },
    ...(data && { body: JSON.stringify(data) }),
    signal,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new FetchError(response.status, error);
  }

  return response.json();
};

export class FetchError extends Error {
  constructor(public status: number, public data: unknown) {
    super(`HTTP ${status}`);
  }
}

export type ErrorType<E> = FetchError & { data: E };
```

**When to use Axios instead:**
- Need request/response interceptors with complex chaining
- Need upload progress tracking
- Need automatic request cancellation on unmount

Reference: [Orval Fetch Client](https://orval.dev/guides/fetch-client)

### 4.6 Use Interceptors for Cross-Cutting Concerns

**Impact: HIGH (centralizes logging, retry logic, and request timing)**

Configure Axios interceptors in your mutator for cross-cutting concerns like logging, retry logic, and request timing. This keeps generated code clean while adding observability.

**Incorrect (no interceptors):**

```typescript
// mutator.ts
export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  console.log('Request:', config.url);  // Logging in wrong place
  const start = Date.now();
  return axios(config)
    .then(({ data }) => {
      console.log('Response time:', Date.now() - start);
      return data;
    });
};
```

**Correct (interceptors for observability):**

```typescript
// mutator.ts
import Axios, { AxiosRequestConfig, AxiosResponse, AxiosError } from 'axios';

export const AXIOS_INSTANCE = Axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

// Request interceptor - logging and timing
AXIOS_INSTANCE.interceptors.request.use((config) => {
  config.metadata = { startTime: Date.now() };

  if (import.meta.env.DEV) {
    console.log(`[API] ${config.method?.toUpperCase()} ${config.url}`);
  }

  return config;
});

// Response interceptor - timing and error normalization
AXIOS_INSTANCE.interceptors.response.use(
  (response: AxiosResponse) => {
    const duration = Date.now() - response.config.metadata.startTime;

    if (import.meta.env.DEV) {
      console.log(`[API] ${response.status} in ${duration}ms`);
    }

    return response;
  },
  (error: AxiosError) => {
    const duration = Date.now() - error.config?.metadata?.startTime;
    console.error(`[API] Error after ${duration}ms:`, error.message);

    return Promise.reject(error);
  }
);

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return AXIOS_INSTANCE(config).then(({ data }) => data);
};

export type ErrorType<E> = AxiosError<E>;
```

**Benefits:**
- Clean separation of concerns
- Consistent logging across all requests
- Easy to add metrics/tracing

Reference: [Axios Interceptors](https://axios-http.com/docs/interceptors)

---

## 5. Query Library Integration

**Impact: MEDIUM-HIGH**

React Query, SWR, and Vue Query hook patterns affect caching behavior, refetching strategies, and UI state management.

### 5.1 Configure Default Query Options Globally

**Impact: MEDIUM-HIGH (reduces boilerplate, ensures consistent caching behavior)**

Configure default query options in Orval config instead of repeating them in every hook call. This ensures consistent caching behavior across your application.

**Incorrect (options repeated per hook):**

```typescript
// Every component sets the same options
const { data: user } = useGetUser(userId, {
  staleTime: 5 * 60 * 1000,
  gcTime: 10 * 60 * 1000,
  retry: 2,
});

const { data: orders } = useGetOrders({
  staleTime: 5 * 60 * 1000,  // Duplicated
  gcTime: 10 * 60 * 1000,    // Duplicated
  retry: 2,                   // Duplicated
});
```

**Correct (global defaults in config):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      client: 'react-query',
      override: {
        query: {
          useQuery: true,
          useMutation: true,
          options: {
            staleTime: 5 * 60 * 1000,
            gcTime: 10 * 60 * 1000,
            retry: 2,
          },
        },
      },
    },
  },
});
```

**Clean component usage:**
```typescript
// Defaults applied automatically
const { data: user } = useGetUser(userId);
const { data: orders } = useGetOrders();

// Override only when needed
const { data: liveData } = useGetMetrics({
  staleTime: 0,  // Override for real-time data
  refetchInterval: 5000,
});
```

**Per-operation overrides:**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      override: {
        operations: {
          getMetrics: {
            query: {
              options: {
                staleTime: 0,
                refetchInterval: 5000,
              },
            },
          },
        },
      },
    },
  },
});
```

Reference: [Orval Query Options](https://orval.dev/guides/react-query)

### 5.2 Enable Infinite Queries for Paginated Endpoints

**Impact: MEDIUM-HIGH (proper infinite scroll without manual pagination state)**

Enable infinite query generation for paginated endpoints. Manual pagination with regular queries leads to complex state management and poor UX.

**Incorrect (manual pagination):**

```typescript
// orval.config.ts - only useQuery enabled
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
    },
  },
});
```

**Manual pagination state:**
```typescript
const [page, setPage] = useState(1);
const { data } = useGetUsers({ page, limit: 20 });
const [allUsers, setAllUsers] = useState<User[]>([]);

useEffect(() => {
  if (data) {
    setAllUsers(prev => [...prev, ...data.users]);  // Manual accumulation
  }
}, [data]);

const loadMore = () => setPage(p => p + 1);
```

**Correct (infinite queries enabled):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
      override: {
        query: {
          useQuery: true,
          useInfinite: true,
          useInfiniteQueryParam: 'page',  // Which param controls pagination
        },
      },
    },
  },
});
```

**Clean infinite scroll:**
```typescript
const {
  data,
  fetchNextPage,
  hasNextPage,
  isFetchingNextPage,
} = useGetUsersInfinite({ limit: 20 });

// All pages automatically accumulated
const allUsers = data?.pages.flatMap(page => page.users) ?? [];

return (
  <div>
    {allUsers.map(user => <UserCard key={user.id} user={user} />)}
    {hasNextPage && (
      <button onClick={() => fetchNextPage()} disabled={isFetchingNextPage}>
        {isFetchingNextPage ? 'Loading...' : 'Load More'}
      </button>
    )}
  </div>
);
```

Reference: [TanStack Infinite Queries](https://tanstack.com/query/latest/docs/framework/react/guides/infinite-queries)

### 5.3 Enable Suspense Mode for Streaming UX

**Impact: MEDIUM-HIGH (enables React Suspense integration for better loading states)**

Enable suspense query generation when using React Suspense boundaries. This provides cleaner loading state management and enables streaming SSR.

**Incorrect (manual loading states):**

```typescript
function UserProfile({ userId }: { userId: string }) {
  const { data, isLoading, error } = useGetUser(userId);

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorDisplay error={error} />;

  return <Profile user={data} />;  // data could still be undefined
}
```

**Correct (suspense mode):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
      override: {
        query: {
          useSuspenseQuery: true,
        },
      },
    },
  },
});
```

**Clean component with Suspense:**
```typescript
import { Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';

// Parent component handles loading/error
function UserPage({ userId }: { userId: string }) {
  return (
    <ErrorBoundary fallback={<ErrorDisplay />}>
      <Suspense fallback={<Skeleton />}>
        <UserProfile userId={userId} />
      </Suspense>
    </ErrorBoundary>
  );
}

// Child component is simple - data is guaranteed
function UserProfile({ userId }: { userId: string }) {
  const { data } = useGetUserSuspense(userId);

  return <Profile user={data} />;  // data is never undefined
}
```

**Benefits:**
- `data` is always defined (no undefined checks)
- Loading states handled declaratively
- Works with React 18 streaming SSR
- Cleaner component code

**When NOT to use this pattern:**
- Need granular loading states within a component
- Can't use error boundaries
- Supporting React <18

Reference: [TanStack Suspense](https://tanstack.com/query/latest/docs/framework/react/guides/suspense)

### 5.4 Export Query Keys for Cache Invalidation

**Impact: MEDIUM-HIGH (enables proper cache invalidation patterns)**

Enable query key exports to use React Query's invalidation and prefetching APIs. Without exported keys, you must hardcode key strings, breaking when generated code changes.

**Incorrect (hardcoded query keys):**

```typescript
// orval.config.ts - query key export disabled by default
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
    },
  },
});
```

**Fragile invalidation with hardcoded keys:**
```typescript
const queryClient = useQueryClient();

const createUser = useCreateUser({
  onSuccess: () => {
    // Hardcoded key - breaks if Orval changes key format
    queryClient.invalidateQueries({ queryKey: ['/users'] });
  },
});
```

**Correct (exported query keys):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
      override: {
        query: {
          shouldExportQueryKey: true,
        },
      },
    },
  },
});
```

**Type-safe invalidation:**
```typescript
import { getGetUsersQueryKey } from '@/api/users';

const queryClient = useQueryClient();

const createUser = useCreateUser({
  onSuccess: () => {
    // Type-safe, follows generated key format
    queryClient.invalidateQueries({ queryKey: getGetUsersQueryKey() });
  },
});
```

**Prefetching with exported keys:**
```typescript
// Prefetch on hover
const prefetchUser = (userId: string) => {
  queryClient.prefetchQuery({
    queryKey: getGetUserQueryKey(userId),
    queryFn: () => getUser(userId),
  });
};
```

**When NOT to use this pattern:**
- Very small projects where cache invalidation is handled manually
- Not using React Query's programmatic APIs (invalidateQueries, prefetchQuery)

Reference: [TanStack Query Invalidation](https://tanstack.com/query/latest/docs/framework/react/guides/query-invalidation)

### 5.5 Pass AbortSignal for Request Cancellation

**Impact: MEDIUM-HIGH (prevents memory leaks and wasted bandwidth on unmount)**

Ensure your mutator passes the AbortSignal to enable automatic request cancellation. Without it, abandoned requests continue running after component unmount.

**Incorrect (signal ignored):**

```typescript
// mutator.ts
export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  // Signal not passed - requests can't be cancelled
  return axios({
    url: config.url,
    method: config.method,
    data: config.data,
  }).then(({ data }) => data);
};
```

**Problem:** User navigates away, but request continues, wastes bandwidth, may update unmounted component state.

**Correct (signal forwarded):**

```typescript
// mutator.ts
import Axios, { AxiosRequestConfig } from 'axios';

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return Axios({
    ...config,
    signal: config.signal,  // Forward the AbortSignal
  }).then(({ data }) => data);
};
```

**For fetch-based mutator:**

```typescript
// mutator.ts
interface RequestConfig {
  url: string;
  method: string;
  data?: unknown;
  signal?: AbortSignal;  // Include signal in config type
}

export const customFetch = async <T>(config: RequestConfig): Promise<T> => {
  const response = await fetch(config.url, {
    method: config.method,
    body: config.data ? JSON.stringify(config.data) : undefined,
    signal: config.signal,  // Forward to fetch
  });

  return response.json();
};
```

**React Query automatically cancels on:**
- Component unmount
- Query key change
- Manual `queryClient.cancelQueries()`

Reference: [TanStack Query Cancellation](https://tanstack.com/query/latest/docs/framework/react/guides/query-cancellation)

### 5.6 Use Generated Mutation Options Types

**Impact: MEDIUM (enables type-safe onSuccess/onError callbacks)**

Use the generated mutation options types for type-safe callbacks. This ensures your onSuccess data and onError error are properly typed.

**Incorrect (untyped callbacks):**

```typescript
const createUser = useCreateUser({
  onSuccess: (data) => {
    // data is typed as unknown or any
    console.log(data.id);  // No autocomplete, no type checking
  },
  onError: (error) => {
    // error is unknown
    toast.error(error.message);  // TypeScript error
  },
});
```

**Correct (using generated types):**

```typescript
import { useCreateUser, type CreateUserMutationResult } from '@/api/users';

const createUser = useCreateUser({
  onSuccess: (data) => {
    // data is properly typed as User
    console.log(data.id);  // Autocomplete works
    toast.success(`Created user ${data.email}`);
  },
  onError: (error) => {
    // error is typed as ErrorType<ApiError>
    const message = error.response?.data?.message ?? 'Creation failed';
    toast.error(message);
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: getGetUsersQueryKey() });
  },
});
```

**With optimistic updates:**

```typescript
const updateUser = useUpdateUser({
  onMutate: async (variables) => {
    // variables is typed as UpdateUserBody
    await queryClient.cancelQueries({ queryKey: getGetUserQueryKey(variables.id) });

    const previousUser = queryClient.getQueryData<User>(
      getGetUserQueryKey(variables.id)
    );

    queryClient.setQueryData(getGetUserQueryKey(variables.id), {
      ...previousUser,
      ...variables,
    });

    return { previousUser };
  },
  onError: (error, variables, context) => {
    // Rollback on error
    if (context?.previousUser) {
      queryClient.setQueryData(
        getGetUserQueryKey(variables.id),
        context.previousUser
      );
    }
  },
});
```

Reference: [TanStack Mutations](https://tanstack.com/query/latest/docs/framework/react/guides/mutations)

---

## 6. Type Safety & Validation

**Impact: MEDIUM**

Zod integration, strict typing, and runtime validation patterns ensure data integrity at API boundaries.

### 6.1 Enable useBigInt for Large Integer Support

**Impact: MEDIUM (prevents precision loss for int64 values)**

Enable `useBigInt` when your API uses int64 or uint64 formats. JavaScript's Number type loses precision beyond 2^53; BigInt preserves exact values.

**Incorrect (large integers as number):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // useBigInt not enabled - int64 becomes number
    },
  },
});
```

**Precision loss with large IDs:**
```typescript
interface Transaction {
  id: number;  // int64 in OpenAPI, but number in TS
  amount: number;
}

// API returns id: 9007199254740993
const tx = await getTransaction(id);
console.log(tx.id);  // 9007199254740992 - WRONG! Lost precision
```

**Correct (useBigInt enabled):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      useBigInt: true,
    },
  },
});
```

**BigInt preserves precision:**
```typescript
interface Transaction {
  id: bigint;  // Proper type for int64
  amount: number;
}

const tx = await getTransaction(id);
console.log(tx.id);  // 9007199254740993n - Correct!
```

**Handle BigInt in mutator:**

```typescript
// mutator.ts
export const customInstance = async <T>(config: AxiosRequestConfig): Promise<T> => {
  const response = await axios({
    ...config,
    transformResponse: [(data) => {
      // Parse with BigInt support
      // 16+ digits exceeds Number.MAX_SAFE_INTEGER (9007199254740991)
      return JSON.parse(data, (key, value) => {
        if (typeof value === 'string' && /^\d{16,}$/.test(value)) {
          return BigInt(value);
        }
        return value;
      });
    }],
  });

  return response.data;
};
```

**When NOT to use this pattern:**
- API doesn't use int64/uint64 formats
- All IDs fit within Number.MAX_SAFE_INTEGER

Reference: [Orval useBigInt](https://orval.dev/reference/configuration/output)

### 6.2 Enable useDates for Date Type Generation

**Impact: MEDIUM (generates Date types instead of string for date fields)**

Enable `useDates` to generate TypeScript Date types for date/datetime fields. Without it, all date fields are typed as `string`, losing type safety.

**Incorrect (dates as strings):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // useDates not enabled - dates typed as string
    },
  },
});
```

**Generated type has string dates:**
```typescript
interface User {
  id: string;
  email: string;
  createdAt: string;  // Should be Date
  updatedAt: string;  // Should be Date
}

// Can't use Date methods
user.createdAt.getFullYear();  // TypeScript error: string has no getFullYear
```

**Correct (useDates enabled):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      useDates: true,
    },
  },
});
```

**Generated type has proper Date types:**
```typescript
interface User {
  id: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;
}

// Date methods available
user.createdAt.getFullYear();  // Works!
```

**Important:** You still need runtime conversion in your mutator:

```typescript
// mutator.ts
import { parseISO } from 'date-fns';

// Recursively converts ISO date strings to Date objects
// API returns dates as strings at runtime despite TypeScript types
const convertDates = (obj: unknown): unknown => {
  if (typeof obj !== 'object' || obj === null) return obj;

  for (const [key, value] of Object.entries(obj)) {
    if (typeof value === 'string' && isISODateString(value)) {
      (obj as Record<string, unknown>)[key] = parseISO(value);
    } else if (typeof value === 'object') {
      convertDates(value);
    }
  }
  return obj;
};
```

Reference: [Orval useDates](https://orval.dev/reference/configuration/output)

### 6.3 Enable Zod Strict Mode for Safer Validation

**Impact: MEDIUM (catches unexpected fields, prevents data leakage)**

Enable strict mode for Zod schema generation to reject objects with unexpected properties. This catches API changes and prevents accidental data exposure.

**Incorrect (non-strict mode):**

```typescript
// orval.config.ts
export default defineConfig({
  apiZod: {
    output: {
      client: 'zod',
      // No strict mode - extra fields pass through
    },
  },
});
```

**Unexpected data passes validation:**
```typescript
// API returns extra sensitive field
const response = {
  id: '123',
  email: 'user@example.com',
  internalNotes: 'VIP customer - discount approved',  // Leaked!
};

userSchema.parse(response);  // Passes, includes internalNotes
```

**Correct (strict mode enabled):**

```typescript
// orval.config.ts
export default defineConfig({
  apiZod: {
    output: {
      client: 'zod',
      override: {
        zod: {
          strict: {
            response: true,
            body: true,
            query: true,
            param: true,
            header: true,
          },
        },
      },
    },
  },
});
```

**Strict validation catches unexpected fields:**
```typescript
const response = {
  id: '123',
  email: 'user@example.com',
  internalNotes: 'VIP customer',  // Extra field
};

userSchema.parse(response);
// ZodError: Unrecognized key(s) in object: 'internalNotes'
```

**When NOT to use this pattern:**
- API intentionally returns extra fields you ignore
- Working with APIs you don't control that may add fields

Reference: [Orval Zod Strict Mode](https://orval.dev/reference/configuration/output)

### 6.4 Generate Zod Schemas for Runtime Validation

**Impact: MEDIUM (catches API contract violations at runtime)**

Generate Zod schemas alongside TypeScript types to validate API responses at runtime. TypeScript types are erased at runtime; Zod catches contract violations in production.

**Incorrect (TypeScript only):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
      // No Zod - runtime type mismatches go undetected
    },
  },
});
```

**API returns unexpected data:**
```typescript
// API returns { user_name: 'John' } instead of { userName: 'John' }
const { data } = useGetUser(userId);
console.log(data.userName);  // undefined - no error thrown
```

**Correct (with Zod validation):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mode: 'tags-split',
      client: 'react-query',
      target: 'src/api/endpoints',
      schemas: 'src/api/models',
    },
  },
  apiZod: {
    input: './openapi.yaml',
    output: {
      mode: 'tags-split',
      client: 'zod',
      target: 'src/api/endpoints',
      fileExtension: '.zod.ts',
    },
  },
});
```

**Validate in mutator:**
```typescript
// mutator.ts
import { userSchema } from '@/api/endpoints/users.zod';

export const customInstance = async <T>(
  config: AxiosRequestConfig,
  schema?: ZodSchema<T>
): Promise<T> => {
  const response = await axios(config);

  if (schema) {
    return schema.parse(response.data);  // Throws if invalid
  }

  return response.data;
};
```

**Benefits:**
- Catches API breaking changes immediately
- Clear error messages with Zod's error formatting
- Can coerce types (string dates to Date objects)

**When NOT to use this pattern:**
- Internal APIs with strict contracts where validation overhead isn't justified
- Performance-critical paths where parsing overhead matters
- Very small projects where TypeScript alone provides sufficient safety

Reference: [Orval Zod Client](https://orval.dev/guides/client-with-zod)

### 6.5 Use Zod Coercion for Type Transformations

**Impact: MEDIUM (automatic string-to-Date, string-to-number conversions)**

Enable Zod coercion to automatically convert string values to proper types. APIs often return dates as strings; coercion converts them to Date objects.

**Incorrect (no coercion):**

```typescript
// orval.config.ts
export default defineConfig({
  apiZod: {
    output: {
      client: 'zod',
      // No coercion - dates remain strings
    },
  },
});
```

**Dates are strings, not Date objects:**
```typescript
const { data: user } = useGetUser(userId);

// TypeScript thinks createdAt is Date, but it's actually string
user.createdAt.toLocaleDateString();  // Runtime error: toLocaleDateString is not a function

// Must manually convert
const date = new Date(user.createdAt);
```

**Correct (coercion enabled):**

```typescript
// orval.config.ts
export default defineConfig({
  apiZod: {
    output: {
      client: 'zod',
      override: {
        zod: {
          coerce: {
            response: ['date'],  // Coerce date strings to Date
            query: ['string', 'number', 'boolean'],  // Coerce query params
          },
        },
      },
    },
  },
});
```

**Dates are properly converted:**
```typescript
const { data: user } = useGetUser(userId);

// createdAt is now a real Date object
user.createdAt.toLocaleDateString();  // Works!
```

**Available coercion types:**
- `date` - ISO date strings → Date objects
- `number` - Numeric strings → numbers
- `boolean` - "true"/"false" strings → booleans
- `bigint` - Large integer strings → BigInt
- `string` - Any value → string

Reference: [Orval Zod Coercion](https://orval.dev/reference/configuration/output)

---

## 7. Mock Generation & Testing

**Impact: MEDIUM**

MSW setup, Faker configuration, and testing patterns enable reliable frontend development without backend dependencies.

### 7.1 Configure Mock Response Delays

**Impact: MEDIUM (simulates network latency for realistic testing)**

Configure appropriate mock delays to simulate real network conditions. Instant responses hide loading state bugs and race conditions.

**Incorrect (no delay or excessive delay):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        delay: false,  // Instant - hides loading bugs
      },
    },
  },
});
```

**Loading states never visible:**
```typescript
// This bug is invisible with instant mocks
function UserList() {
  const { data, isLoading } = useGetUsers();

  // Bug: returns null instead of loading indicator
  if (!data) return null;  // Should check isLoading

  return <ul>{data.map(u => <li>{u.name}</li>)}</ul>;
}
```

**Correct (realistic delays):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        delay: 200,  // Fixed 200ms delay
      },
    },
  },
});
```

**Variable delays for realism:**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        delay: () => Math.random() * 500 + 100,  // 100-600ms
      },
    },
  },
});
```

**Per-endpoint delays:**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        delay: 200,
      },
      override: {
        operations: {
          uploadFile: {
            mock: {
              delay: 2000,  // Slow upload simulation
            },
          },
        },
      },
    },
  },
});
```

**In tests, use minimal delays:**
```typescript
// test-setup.ts
const server = setupServer(...handlers);

// Override delay for faster tests
server.use(
  http.get('*', async ({ request }) => {
    // No delay in tests
  })
);
```

Reference: [Orval Mock Delay](https://orval.dev/reference/configuration/output)

### 7.2 Generate Mock Index Files for Easy Setup

**Impact: MEDIUM (single import for all mock handlers)**

Enable mock index files when using tags-split mode. This provides a single import point for all mock handlers.

**Incorrect (manual handler aggregation):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mode: 'tags-split',
      mock: true,
      // No indexFiles for mocks
    },
  },
});
```

**Manual handler collection:**
```typescript
// test-setup.ts
import { getUsersMockHandlers } from '@/api/users/users.msw';
import { getOrdersMockHandlers } from '@/api/orders/orders.msw';
import { getProductsMockHandlers } from '@/api/products/products.msw';
// ... import every tag manually

const server = setupServer(
  ...getUsersMockHandlers(),
  ...getOrdersMockHandlers(),
  ...getProductsMockHandlers(),
  // ... spread every tag manually
);
```

**Correct (mock index files):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mode: 'tags-split',
      mock: {
        type: 'msw',
        indexFiles: true,  // Generate index.msw.ts
      },
    },
  },
});
```

**Generated index file:**
```typescript
// Generated: src/api/index.msw.ts
import { getUsersMockHandlers } from './users/users.msw';
import { getOrdersMockHandlers } from './orders/orders.msw';
import { getProductsMockHandlers } from './products/products.msw';

export const handlers = [
  ...getUsersMockHandlers(),
  ...getOrdersMockHandlers(),
  ...getProductsMockHandlers(),
];
```

**Clean test setup:**
```typescript
// test-setup.ts
import { setupServer } from 'msw/node';
import { handlers } from '@/api/index.msw';

const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

Reference: [Orval Mock indexFiles](https://orval.dev/reference/configuration/output)

### 7.3 Generate Mocks for All HTTP Status Codes

**Impact: MEDIUM (enables error state testing)**

Enable mock generation for all HTTP status codes to test error handling. By default, Orval only generates success (2xx) mocks.

**Incorrect (success mocks only):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: true,  // Only generates 200 handlers
    },
  },
});
```

**Can't test error handling:**
```typescript
test('shows error message on failure', async () => {
  // No easy way to trigger 400/500 responses
  // Must manually override handlers
});
```

**Correct (all status codes):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        generateEachHttpStatus: true,  // Generate for 400, 404, 500, etc.
      },
    },
  },
});
```

**Generated error handlers:**
```typescript
// Generated: users.msw.ts
export const getGetUserMockHandler400 = () => {
  return http.get('/users/:id', () => {
    return HttpResponse.json(getGetUserMock400(), { status: 400 });
  });
};

export const getGetUserMockHandler404 = () => {
  return http.get('/users/:id', () => {
    return HttpResponse.json(getGetUserMock404(), { status: 404 });
  });
};
```

**Test error states easily:**
```typescript
import { getGetUserMockHandler404 } from '@/api/users/users.msw';

test('shows not found message', async () => {
  server.use(getGetUserMockHandler404());

  render(<UserProfile userId="nonexistent" />);

  await screen.findByText(/user not found/i);
});

test('shows validation errors', async () => {
  server.use(getCreateUserMockHandler400());

  render(<CreateUserForm />);
  fireEvent.click(screen.getByText('Submit'));

  await screen.findByText(/email is required/i);
});
```

Reference: [Orval generateEachHttpStatus](https://orval.dev/reference/configuration/output)

### 7.4 Generate MSW Handlers for Testing

**Impact: MEDIUM (enables frontend development without backend dependencies)**

Enable MSW mock generation to create type-safe API mocks. This enables frontend development and testing without a running backend.

**Incorrect (no mocks):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      client: 'react-query',
      // No mock generation - tests require real API
    },
  },
});
```

**Tests depend on live API:**
```typescript
// test must call real API or manually mock every endpoint
test('displays user profile', async () => {
  // No easy way to mock API responses
});
```

**Correct (MSW mocks enabled):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      client: 'react-query',
      mock: true,  // Generate MSW handlers
    },
  },
});
```

**Generated mock handlers:**
```typescript
// Generated: src/api/users/users.msw.ts
import { http, HttpResponse } from 'msw';
import { getGetUserMock } from './users.mock';

export const getGetUserMockHandler = () => {
  return http.get('/users/:id', () => {
    return HttpResponse.json(getGetUserMock());
  });
};

export const getUsersMockHandlers = () => [
  getGetUserMockHandler(),
  // ... other handlers
];
```

**Use in tests:**
```typescript
import { setupServer } from 'msw/node';
import { getUsersMockHandlers } from '@/api/users/users.msw';

const server = setupServer(...getUsersMockHandlers());

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('displays user profile', async () => {
  render(<UserProfile userId="123" />);
  await screen.findByText(/john doe/i);  // Uses mock data
});
```

Reference: [MSW Documentation](https://mswjs.io/docs/)

### 7.5 Use OpenAPI Examples for Realistic Mocks

**Impact: MEDIUM (generates realistic mock data from spec examples)**

Configure mocks to use examples from your OpenAPI spec. This produces more realistic and consistent mock data than random Faker values.

**Incorrect (random Faker data):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: true,  // Uses Faker by default
    },
  },
});
```

**Generated mock data is unrealistic:**
```typescript
// Random Faker data
{
  id: 'a3b2c1d4-e5f6-...',
  email: 'Malvina_Cruickshank42@yahoo.com',  // Not realistic
  name: 'Laverne Schimmel',  // Random name
  role: 'Principal Functionality Architect',  // Nonsense
}
```

**Correct (use OpenAPI examples):**

```yaml
# openapi.yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          example: 'usr_123456'
        email:
          type: string
          example: 'john.doe@company.com'
        name:
          type: string
          example: 'John Doe'
        role:
          type: string
          enum: [admin, user, guest]
          example: 'user'
```

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        useExamples: true,  // Prefer examples from spec
      },
    },
  },
});
```

**Generated mock uses examples:**
```typescript
{
  id: 'usr_123456',
  email: 'john.doe@company.com',
  name: 'John Doe',
  role: 'user',
}
```

**Benefits:**
- Consistent, predictable test data
- Examples match expected production formats
- Easier to assert on known values

Reference: [Orval Mock Options](https://orval.dev/reference/configuration/output)

---

## 8. Advanced Patterns

**Impact: LOW**

Transformers, operation overrides, and edge case handling for complex integration scenarios.

### 8.1 Configure Form Data Serialization

**Impact: LOW (handles file uploads and multipart forms correctly)**

Configure form data handling for file upload and multipart form endpoints. The default serialization may not match your API's expectations for arrays and nested objects.

**Incorrect (default serialization):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // Default formData serialization
    },
  },
});
```

**Arrays serialized incorrectly:**
```typescript
// Sending: { files: [file1, file2], tags: ['a', 'b'] }

// Default sends:
// files=file1&files=file2&tags=a&tags=b

// But API expects:
// files[]=file1&files[]=file2&tags[0]=a&tags[1]=b
```

**Correct (explicit serialization):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      override: {
        formData: {
          // How to serialize arrays
          array: 'serialize-with-brackets',  // files[]=value
        },
        formUrlEncoded: {
          array: 'explode',  // files[0]=value&files[1]=value
        },
      },
    },
  },
});
```

**Array serialization options:**
- `serialize` - Default: `key=value1&key=value2`
- `serialize-with-brackets` - PHP style: `key[]=value1&key[]=value2`
- `explode` - Indexed: `key[0]=value1&key[1]=value2`

**Per-operation override for file uploads:**

```typescript
export default defineConfig({
  api: {
    output: {
      override: {
        operations: {
          uploadDocuments: {
            formData: {
              array: 'serialize-with-brackets',
            },
          },
        },
      },
    },
  },
});
```

Reference: [Orval formData Options](https://orval.dev/reference/configuration/output)

### 8.2 Override Settings per Operation

**Impact: LOW (customizes individual endpoints without affecting others)**

Use operation-specific overrides when certain endpoints need different configuration. This is cleaner than using a transformer for simple customizations.

**Use case:** Most endpoints use default options, but one needs custom mock data

**Incorrect (global change affects all):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        delay: 2000,  // Slow delay for all endpoints
      },
    },
  },
});
```

**Correct (per-operation override):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      client: 'react-query',
      mock: true,
      override: {
        operations: {
          uploadFile: {
            mock: {
              delay: 3000,  // Slow upload simulation
            },
          },
          getHealthCheck: {
            query: {
              options: {
                staleTime: Infinity,  // Never refetch
                gcTime: Infinity,
              },
            },
          },
          createPayment: {
            mutator: {
              path: './src/api/payment-mutator.ts',
              name: 'paymentInstance',  // Special auth for payments
            },
          },
        },
      },
    },
  },
});
```

**Override by tags:**

```typescript
export default defineConfig({
  api: {
    output: {
      override: {
        tags: {
          admin: {
            mutator: {
              path: './src/api/admin-mutator.ts',
              name: 'adminInstance',
            },
          },
        },
      },
    },
  },
});
```

**Available per-operation overrides:**
- `mutator` - Custom HTTP client
- `query` - React Query options
- `mock` - Mock data and delays
- `transformer` - Output transformation
- `formData` / `formUrlEncoded` - Serialization

Reference: [Orval Operations Override](https://orval.dev/reference/configuration/output)

### 8.3 Use Input Transformer for Spec Preprocessing

**Impact: LOW (fixes spec issues at source, prevents N downstream errors)**

Use an input transformer to modify the OpenAPI specification before code generation. This enables fixing spec issues, adding custom extensions, or filtering operations.

**Incorrect (inconsistent operationIds in spec):**

```yaml
# openapi.yaml - inconsistent naming causes inconsistent function names
paths:
  /users:
    get:
      operationId: GetAllUsers  # PascalCase - generates GetAllUsers()
  /orders:
    get:
      operationId: list_orders  # snake_case - generates list_orders()
```

**Correct (input transformer to normalize):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: {
      target: './openapi.yaml',
      transformer: './scripts/normalize-spec.ts',
    },
    output: {
      target: 'src/api',
    },
  },
});
```

```typescript
// scripts/normalize-spec.ts
import { OpenAPIObject, OperationObject } from 'openapi3-ts/oas31';

const toCamelCase = (str: string): string => {
  return str
    .replace(/[-_](.)/g, (_, char) => char.toUpperCase())
    .replace(/^(.)/, (char) => char.toLowerCase());
};

export default (spec: OpenAPIObject): OpenAPIObject => {
  const paths = spec.paths ?? {};

  for (const pathItem of Object.values(paths)) {
    for (const method of ['get', 'post', 'put', 'delete', 'patch'] as const) {
      const operation = pathItem?.[method] as OperationObject | undefined;
      if (operation?.operationId) {
        operation.operationId = toCamelCase(operation.operationId);
      }
    }
  }

  return spec;
};
```

**Other transformer use cases:**
- Remove deprecated endpoints
- Add x-custom extensions
- Merge multiple specs
- Fix nullable field definitions

Reference: [Orval Input Transformer](https://orval.dev/reference/configuration/input)

### 8.4 Use Output Transformer for Generated Code Modification

**Impact: LOW (adds custom logic to all N generated functions automatically)**

Use an output transformer to modify generated code before it's written. This enables adding custom logic, modifying function signatures, or injecting metadata.

**Incorrect (manual modification of each mutation):**

```typescript
// Manually adding analytics to every mutation - error-prone
const createUser = useCreateUser({
  onSuccess: () => {
    analytics.track('createUser');  // Must add to every mutation
  },
});

const updateUser = useUpdateUser({
  onSuccess: () => {
    analytics.track('updateUser');  // Repeated N times
  },
});
```

**Correct (output transformer):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      client: 'react-query',
      override: {
        transformer: './scripts/add-analytics.ts',
      },
    },
  },
});
```

```typescript
// scripts/add-analytics.ts
import { GeneratorVerbOptions } from '@orval/core';

export default (verbOptions: GeneratorVerbOptions): GeneratorVerbOptions => {
  // Only modify mutations
  if (verbOptions.verb !== 'post' && verbOptions.verb !== 'put' &&
      verbOptions.verb !== 'delete' && verbOptions.verb !== 'patch') {
    return verbOptions;
  }

  // Add analytics comment to generated code
  const originalImplementation = verbOptions.implementation;

  return {
    ...verbOptions,
    implementation: `
      // Analytics: ${verbOptions.operationId}
      ${originalImplementation}
    `,
  };
};
```

**Other transformer use cases:**
- Add deprecation warnings
- Inject logging
- Modify type names
- Add custom JSDoc comments

**When NOT to use this pattern:**
- Simple config changes (use override.operations instead)
- Need to change HTTP behavior (use mutator instead)
- Need to modify spec before generation (use input transformer)

Reference: [Orval Output Transformer](https://orval.dev/reference/configuration/output)

---

## References

1. [https://orval.dev](https://orval.dev)
2. [https://github.com/orval-labs/orval](https://github.com/orval-labs/orval)
3. [https://tanstack.com/query/latest](https://tanstack.com/query/latest)
4. [https://mswjs.io](https://mswjs.io)
5. [https://axios-http.com](https://axios-http.com)