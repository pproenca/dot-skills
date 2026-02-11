---
name: rails-dev-best-practices
description: Ruby on Rails performance and maintainability optimization guidelines for building backend APIs and frontend web applications. This skill should be used when writing, reviewing, or refactoring Ruby on Rails code to ensure optimal patterns for controllers, models, ActiveRecord queries, caching, views, API design, security, and background jobs. Triggers on tasks involving Rails controllers, ActiveRecord queries, migrations, Turbo/Hotwire, API endpoints, background jobs, or Rails performance improvements.
---

# Community Ruby on Rails Development Best Practices

Comprehensive performance and maintainability optimization guide for Ruby on Rails applications, maintained by Community. Contains 45 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new Rails controllers, models, or views
- Optimizing ActiveRecord queries and database access patterns
- Implementing caching strategies (fragment, Russian doll, low-level)
- Building or refactoring API endpoints
- Adding Turbo Frames and Streams for interactive UIs
- Reviewing code for N+1 queries and security vulnerabilities
- Designing background jobs with Sidekiq or Active Job
- Writing or reviewing database migrations

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Database & ActiveRecord | CRITICAL | `db-` |
| 2 | Controllers & Routing | CRITICAL | `ctrl-` |
| 3 | Security | HIGH | `sec-` |
| 4 | Models & Business Logic | HIGH | `model-` |
| 5 | Caching & Performance | HIGH | `cache-` |
| 6 | Views & Frontend | MEDIUM-HIGH | `view-` |
| 7 | API Design | MEDIUM | `api-` |
| 8 | Background Jobs & Async | LOW-MEDIUM | `job-` |

## Quick Reference

### 1. Database & ActiveRecord (CRITICAL)

- [`db-eager-load-associations`](references/db-eager-load-associations.md) - Eager load associations to eliminate N+1 queries
- [`db-add-database-indexes`](references/db-add-database-indexes.md) - Add database indexes on queried columns
- [`db-select-specific-columns`](references/db-select-specific-columns.md) - Select only needed columns
- [`db-batch-processing`](references/db-batch-processing.md) - Use find_each for large dataset iteration
- [`db-avoid-queries-in-loops`](references/db-avoid-queries-in-loops.md) - Avoid database queries inside loops
- [`db-use-scopes`](references/db-use-scopes.md) - Define reusable query scopes on models
- [`db-safe-migrations`](references/db-safe-migrations.md) - Write reversible zero-downtime migrations
- [`db-exists-over-count`](references/db-exists-over-count.md) - Use exists? instead of count for existence checks

### 2. Controllers & Routing (CRITICAL)

- [`ctrl-thin-controllers`](references/ctrl-thin-controllers.md) - Keep controllers thin by delegating to models and services
- [`ctrl-strong-params`](references/ctrl-strong-params.md) - Always use strong parameters for mass assignment
- [`ctrl-restful-routes`](references/ctrl-restful-routes.md) - Follow RESTful routing conventions
- [`ctrl-before-action-scoping`](references/ctrl-before-action-scoping.md) - Scope before_action callbacks with only/except
- [`ctrl-respond-to-format`](references/ctrl-respond-to-format.md) - Use respond_to for multi-format responses
- [`ctrl-rescue-from`](references/ctrl-rescue-from.md) - Handle errors with rescue_from in controllers

### 3. Security (HIGH)

- [`sec-parameterized-queries`](references/sec-parameterized-queries.md) - Never interpolate user input in SQL
- [`sec-strong-params-whitelist`](references/sec-strong-params-whitelist.md) - Whitelist permitted params, never blacklist
- [`sec-authenticate-before-authorize`](references/sec-authenticate-before-authorize.md) - Authenticate before authorize on every request
- [`sec-csrf-protection`](references/sec-csrf-protection.md) - Enable CSRF protection for all form submissions
- [`sec-scope-queries-to-user`](references/sec-scope-queries-to-user.md) - Scope queries to current user for authorization

### 4. Models & Business Logic (HIGH)

- [`model-validate-at-model-level`](references/model-validate-at-model-level.md) - Validate data at the model level
- [`model-avoid-callback-side-effects`](references/model-avoid-callback-side-effects.md) - Avoid side effects in model callbacks
- [`model-use-service-objects`](references/model-use-service-objects.md) - Extract complex logic into service objects
- [`model-scope-over-class-methods`](references/model-scope-over-class-methods.md) - Use scopes instead of class methods for query composition
- [`model-use-enums`](references/model-use-enums.md) - Use enums for finite state fields
- [`model-concerns-for-shared-behavior`](references/model-concerns-for-shared-behavior.md) - Use concerns for shared model behavior
- [`model-query-objects`](references/model-query-objects.md) - Extract complex queries into query objects

### 5. Caching & Performance (HIGH)

- [`cache-fragment-caching`](references/cache-fragment-caching.md) - Use fragment caching for expensive view partials
- [`cache-russian-doll`](references/cache-russian-doll.md) - Use Russian doll caching for nested collections
- [`cache-low-level`](references/cache-low-level.md) - Use Rails.cache.fetch for computed data
- [`cache-counter-cache`](references/cache-counter-cache.md) - Use counter caches for association counts
- [`cache-conditional-get`](references/cache-conditional-get.md) - Use conditional GET with stale? for HTTP caching

### 6. Views & Frontend (MEDIUM-HIGH)

- [`view-collection-rendering`](references/view-collection-rendering.md) - Use collection rendering instead of loop partials
- [`view-turbo-frames`](references/view-turbo-frames.md) - Use Turbo Frames for partial page updates
- [`view-turbo-streams`](references/view-turbo-streams.md) - Use Turbo Streams for real-time page mutations
- [`view-form-with`](references/view-form-with.md) - Use form_with instead of form_tag or form_for
- [`view-avoid-logic-in-views`](references/view-avoid-logic-in-views.md) - Move display logic to helpers or presenters

### 7. API Design (MEDIUM)

- [`api-serializers`](references/api-serializers.md) - Use serializers for consistent JSON responses
- [`api-pagination`](references/api-pagination.md) - Always paginate collection endpoints
- [`api-versioning`](references/api-versioning.md) - Version APIs from day one
- [`api-error-responses`](references/api-error-responses.md) - Return structured error responses
- [`api-avoid-jbuilder-hot-paths`](references/api-avoid-jbuilder-hot-paths.md) - Avoid Jbuilder on high-traffic endpoints

### 8. Background Jobs & Async (LOW-MEDIUM)

- [`job-idempotent-design`](references/job-idempotent-design.md) - Design jobs to be idempotent
- [`job-small-payloads`](references/job-small-payloads.md) - Pass IDs to jobs, not serialized objects
- [`job-error-handling`](references/job-error-handling.md) - Configure retry and error handling for jobs
- [`job-unique-jobs`](references/job-unique-jobs.md) - Prevent duplicate job enqueuing

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
