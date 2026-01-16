---
name: orval-openapi-best-practices
description: Orval OpenAPI TypeScript client generation best practices. This skill should be used when configuring Orval, generating TypeScript clients from OpenAPI specs, setting up React Query/SWR hooks, creating custom mutators, or writing MSW mocks. Triggers on tasks involving orval.config.ts, OpenAPI codegen, API client setup, or mock generation.
---

# Orval OpenAPI Best Practices

Comprehensive guide for generating type-safe TypeScript clients from OpenAPI specifications using Orval. Contains 42 rules across 8 categories, prioritized by impact to guide automated configuration, client generation, and testing setup.

## When to Apply

Reference these guidelines when:
- Configuring Orval for a new project
- Setting up OpenAPI-based TypeScript client generation
- Integrating React Query, SWR, or Vue Query with generated hooks
- Creating custom mutators for authentication and error handling
- Generating MSW mocks for testing

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | OpenAPI Specification Quality | CRITICAL | `spec-` |
| 2 | Configuration Architecture | CRITICAL | `config-` |
| 3 | Output Structure & Organization | HIGH | `output-` |
| 4 | Custom Client & Mutators | HIGH | `mutator-` |
| 5 | Query Library Integration | MEDIUM-HIGH | `query-` |
| 6 | Type Safety & Validation | MEDIUM | `types-` |
| 7 | Mock Generation & Testing | MEDIUM | `mock-` |
| 8 | Advanced Patterns | LOW | `adv-` |

## Quick Reference

### 1. OpenAPI Specification Quality (CRITICAL)

- `spec-operationid-unique` - Use unique and descriptive operationIds
- `spec-schemas-reusable` - Define reusable schemas in components
- `spec-tags-organization` - Organize operations with tags
- `spec-response-types` - Define all response types explicitly
- `spec-required-fields` - Mark required fields explicitly

### 2. Configuration Architecture (CRITICAL)

- `config-mode-selection` - Choose output mode based on API size
- `config-client-selection` - Select client based on framework requirements
- `config-separate-schemas` - Separate schemas into dedicated directory
- `config-input-validation` - Validate OpenAPI spec before generation
- `config-baseurl-setup` - Configure base URL properly
- `config-prettier-format` - Enable automatic code formatting

### 3. Output Structure & Organization (HIGH)

- `output-file-extension` - Use distinct file extensions for generated code
- `output-index-files` - Generate index files for clean imports
- `output-naming-convention` - Configure consistent naming conventions
- `output-clean-target` - Enable clean mode for consistent regeneration
- `output-headers-enabled` - Enable headers in generated functions

### 4. Custom Client & Mutators (HIGH)

- `mutator-custom-instance` - Use custom mutator for HTTP client configuration
- `mutator-error-types` - Export custom error types from mutator
- `mutator-body-wrapper` - Export body type wrapper for request transformation
- `mutator-interceptors` - Use interceptors for cross-cutting concerns
- `mutator-token-refresh` - Handle token refresh in mutator
- `mutator-fetch-client` - Use fetch mutator for smaller bundle size

### 5. Query Library Integration (MEDIUM-HIGH)

- `query-hook-options` - Configure default query options globally
- `query-key-export` - Export query keys for cache invalidation
- `query-infinite-queries` - Enable infinite queries for paginated endpoints
- `query-suspense-support` - Enable suspense mode for streaming UX
- `query-signal-cancellation` - Pass AbortSignal for request cancellation
- `query-mutation-callbacks` - Use generated mutation options types

### 6. Type Safety & Validation (MEDIUM)

- `types-zod-validation` - Generate Zod schemas for runtime validation
- `types-zod-strict` - Enable Zod strict mode for safer validation
- `types-zod-coerce` - Use Zod coercion for type transformations
- `types-use-dates` - Enable useDates for Date type generation
- `types-bigint-support` - Enable useBigInt for large integer support

### 7. Mock Generation & Testing (MEDIUM)

- `mock-msw-generation` - Generate MSW handlers for testing
- `mock-use-examples` - Use OpenAPI examples for realistic mocks
- `mock-delay-config` - Configure mock response delays
- `mock-http-status` - Generate mocks for all HTTP status codes
- `mock-index-files` - Generate mock index files for easy setup

### 8. Advanced Patterns (LOW)

- `adv-input-transformer` - Use input transformer for spec preprocessing
- `adv-operation-override` - Override settings per operation
- `adv-output-transformer` - Use output transformer for generated code modification
- `adv-form-data-handling` - Configure form data serialization

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/spec-operationid-unique.md
rules/config-mode-selection.md
rules/_sections.md
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
