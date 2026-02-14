---
name: signals-rails
description: 37signals Rails coding principles and conventions from DHH, Jorge Manrubia, and the Fizzy/Basecamp/HEY codebase. This skill should be used when writing, reviewing, or refactoring Ruby on Rails code following the 37signals philosophy — vanilla Rails, CRUD controllers, rich domain models, concerns, no service objects, Hotwire, Turbo, Stimulus, Solid Queue, Solid Cache, Solid Cable, multi-tenancy, Minitest, custom auth, or DHH conventions.
---

# 37signals Rails Best Practices

Comprehensive coding principles and conventions for Ruby on Rails applications, as practiced at 37signals (Basecamp, HEY, Fizzy). Contains 56 rules across 8 categories, prioritized by architectural impact. Derived from official 37signals sources: the Fizzy codebase, STYLE.md, AGENTS.md, the Rails Doctrine, DHH's "On Writing Software Well" series, and the unofficial 37signals style guide (265 Fizzy PRs).

## When to Apply

Reference these guidelines when:
- Writing new Rails controllers, models, or views
- Deciding between gems and vanilla Rails
- Modeling state and database schema
- Setting up background jobs, caching, or real-time features
- Reviewing code for 37signals-style conventions
- Refactoring toward rich domain models
- Choosing authentication or authorization approach
- Adding Stimulus controllers or Turbo patterns

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Architecture Fundamentals | CRITICAL | `arch-` |
| 2 | Controllers & REST | CRITICAL | `ctrl-` |
| 3 | Domain Modeling | HIGH | `model-` |
| 4 | State Management | HIGH | `state-` |
| 5 | Database & Infrastructure | HIGH | `db-` |
| 6 | Views & Frontend | MEDIUM | `view-` |
| 7 | Code Style | MEDIUM | `style-` |
| 8 | Testing | MEDIUM | `test-` |

## Quick Reference

### 1. Architecture Fundamentals (CRITICAL)

- [`arch-rich-models`](references/arch-rich-models.md) - Rich Domain Models Over Service Objects
- [`arch-vanilla-rails`](references/arch-vanilla-rails.md) - Vanilla Rails is Plenty
- [`arch-avoid-patterns`](references/arch-avoid-patterns.md) - Deliberately Avoided Patterns and Gems
- [`arch-earn-abstractions`](references/arch-earn-abstractions.md) - Earn Abstractions Through Rule of Three
- [`arch-build-before-gems`](references/arch-build-before-gems.md) - Build It Yourself Before Reaching for Gems
- [`arch-ship-to-learn`](references/arch-ship-to-learn.md) - Start Simple — Add Complexity Only After Validation
- [`arch-domain-facades`](references/arch-domain-facades.md) - Domain Models as Facades Over Internal Complexity
- [`arch-single-business-layer`](references/arch-single-business-layer.md) - Single Layer for Business Logic
- [`arch-custom-auth`](references/arch-custom-auth.md) - Custom Passwordless Auth Over Devise

### 2. Controllers & REST (CRITICAL)

- [`ctrl-crud-only`](references/ctrl-crud-only.md) - CRUD Controllers Over Custom Actions
- [`ctrl-model-as-resources`](references/ctrl-model-as-resources.md) - Model Non-CRUD Operations as Separate Resources
- [`ctrl-thin-controllers`](references/ctrl-thin-controllers.md) - Thin Controllers with Rich Domain Models
- [`ctrl-params-expect`](references/ctrl-params-expect.md) - Use params.expect() for Parameter Validation
- [`ctrl-controller-concerns`](references/ctrl-controller-concerns.md) - Controller Concerns for Cross-Cutting Behavior
- [`ctrl-nested-resources`](references/ctrl-nested-resources.md) - Nested Resources with scope module

### 3. Domain Modeling (HIGH)

- [`model-concerns`](references/model-concerns.md) - Concerns for Horizontal Code Sharing
- [`model-normalizes`](references/model-normalizes.md) - Use normalizes Macro for Data Cleaning
- [`model-store-accessor`](references/model-store-accessor.md) - Use store_accessor for JSON Column Access
- [`model-delegated-type`](references/model-delegated-type.md) - Use delegated_type for Polymorphism
- [`model-counter-caches`](references/model-counter-caches.md) - Counter Caches to Prevent N+1 Count Queries
- [`model-touch-chains`](references/model-touch-chains.md) - Touch Chains for Cache Invalidation
- [`model-callbacks-auxiliary`](references/model-callbacks-auxiliary.md) - Callbacks for Auxiliary Complexity
- [`model-event-tracking`](references/model-event-tracking.md) - Polymorphic Event Model for Activity Tracking
- [`model-poro-namespacing`](references/model-poro-namespacing.md) - Namespace POROs Under Parent Models

### 4. State Management (HIGH)

- [`state-records-over-booleans`](references/state-records-over-booleans.md) - Records as State Over Boolean Columns
- [`state-timestamps`](references/state-timestamps.md) - Timestamps for State Transitions
- [`state-enums`](references/state-enums.md) - Enums for Categorical States
- [`state-db-constraints`](references/state-db-constraints.md) - Database Constraints Over ActiveRecord Validations
- [`state-write-time`](references/state-write-time.md) - Compute at Write Time Not Read Time

### 5. Database & Infrastructure (HIGH)

- [`db-backed-everything`](references/db-backed-everything.md) - Database-Backed Everything
- [`db-solid-queue`](references/db-solid-queue.md) - Solid Queue for Background Jobs
- [`db-solid-cable`](references/db-solid-cable.md) - Solid Cable for Real-Time Pub/Sub
- [`db-solid-cache`](references/db-solid-cache.md) - Solid Cache for Application Caching
- [`db-multi-tenancy`](references/db-multi-tenancy.md) - Path-Based Multi-Tenancy with Current.account
- [`db-uuid-primary-keys`](references/db-uuid-primary-keys.md) - UUIDs as Primary Keys
- [`db-no-foreign-keys`](references/db-no-foreign-keys.md) - No Foreign Key Constraints

### 6. Views & Frontend (MEDIUM)

- [`view-turbo-frames`](references/view-turbo-frames.md) - Turbo Frames for Scoped Page Fragments
- [`view-turbo-streams`](references/view-turbo-streams.md) - Turbo Streams for Real-Time Updates
- [`view-stimulus-targets`](references/view-stimulus-targets.md) - Stimulus Targets Over CSS Selectors
- [`view-stimulus-design`](references/view-stimulus-design.md) - Stimulus Controller Design Principles
- [`view-helpers-not-partials`](references/view-helpers-not-partials.md) - Extract Logic to Helpers Not Partials
- [`view-progressive-enhancement`](references/view-progressive-enhancement.md) - Progressive Enhancement as Primary Pattern
- [`view-fragment-caching`](references/view-fragment-caching.md) - Fragment Caching for View Performance
- [`view-http-caching`](references/view-http-caching.md) - HTTP Caching with fresh_when and ETags

### 7. Code Style (MEDIUM)

- [`style-conditionals`](references/style-conditionals.md) - Expanded Conditionals Over Guard Clauses
- [`style-method-ordering`](references/style-method-ordering.md) - Methods Ordered by Call Sequence
- [`style-positive-names`](references/style-positive-names.md) - Use Positive Names for Methods and Scopes
- [`style-naming-return-values`](references/style-naming-return-values.md) - Method Names Reflect Return Values
- [`style-visibility-modifiers`](references/style-visibility-modifiers.md) - Visibility Modifier Formatting
- [`style-bang-methods`](references/style-bang-methods.md) - Bang Methods Only When Non-Bang Exists
- [`style-async-naming`](references/style-async-naming.md) - Use _later and _now Suffixes for Async Operations

### 8. Testing (MEDIUM)

- [`test-minitest`](references/test-minitest.md) - Minitest Over RSpec
- [`test-fixtures`](references/test-fixtures.md) - Database Fixtures Over FactoryBot
- [`test-no-damage`](references/test-no-damage.md) - No Test-Induced Design Damage
- [`test-no-system-tests`](references/test-no-system-tests.md) - Integration Tests Over System Tests
- [`test-behavior`](references/test-behavior.md) - Test Behavior Not Implementation

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
