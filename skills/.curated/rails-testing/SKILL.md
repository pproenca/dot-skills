---
name: rails-testing
description: Ruby on Rails testing best practices for writing effective, maintainable test suites with RSpec. This skill should be used when writing, reviewing, or refactoring Rails tests to ensure proper test design, data management, and coverage patterns. Triggers on tasks involving RSpec specs, model tests, request specs, system tests, factory definitions, Capybara interactions, Sidekiq job tests, or test suite optimization. Complementary to rails-dev, ruby-optimise, and ruby-refactor skills.
---

# Community Ruby on Rails Testing Best Practices

Comprehensive testing guide for Ruby on Rails applications, maintained by Community. Contains 46 rules across 8 categories, prioritized by impact to guide automated test generation, review, and refactoring.

## When to Apply

Reference these guidelines when:
- Writing new RSpec specs for models, requests, system tests, or jobs
- Setting up FactoryBot factories with traits and sequences
- Writing Capybara system tests for user journeys
- Testing background jobs with Sidekiq or Active Job
- Reviewing test code for anti-patterns (mystery guests, flaky tests, slow specs)
- Optimizing test suite performance and CI pipeline speed
- Organizing test files, shared examples, and custom matchers

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Test Design & Structure | CRITICAL | `design-` |
| 2 | Test Data Management | CRITICAL | `data-` |
| 3 | Model Testing | HIGH | `model-` |
| 4 | Request & Controller Testing | HIGH | `request-` |
| 5 | System & Acceptance Testing | MEDIUM-HIGH | `system-` |
| 6 | Async & Background Job Testing | MEDIUM | `async-` |
| 7 | Test Performance & Reliability | MEDIUM | `perf-` |
| 8 | Test Organization & Maintenance | LOW-MEDIUM | `org-` |

## Quick Reference

### 1. Test Design & Structure (CRITICAL)

- [`design-four-phase-test`](references/design-four-phase-test.md) - Use four-phase test structure (setup, exercise, verify, teardown)
- [`design-behavior-over-implementation`](references/design-behavior-over-implementation.md) - Test observable behavior, not internal implementation
- [`design-one-assertion-per-test`](references/design-one-assertion-per-test.md) - One logical expectation per test for precise failure diagnosis
- [`design-descriptive-test-names`](references/design-descriptive-test-names.md) - Write test names that read like specifications
- [`design-avoid-mystery-guest`](references/design-avoid-mystery-guest.md) - Make all test data visible within the test itself
- [`design-avoid-conditional-logic`](references/design-avoid-conditional-logic.md) - No if/else or loops in test code
- [`design-explicit-subject`](references/design-explicit-subject.md) - Name subjects explicitly instead of using implicit subject

### 2. Test Data Management (CRITICAL)

- [`data-factory-traits`](references/data-factory-traits.md) - Use composable factory traits instead of separate factories
- [`data-minimal-attributes`](references/data-minimal-attributes.md) - Specify only attributes relevant to the test
- [`data-build-over-create`](references/data-build-over-create.md) - Prefer build/build_stubbed over create when persistence isn't needed
- [`data-avoid-fixture-coupling`](references/data-avoid-fixture-coupling.md) - Use factories instead of shared fixtures
- [`data-transient-attributes`](references/data-transient-attributes.md) - Use transient attributes for complex factory setup
- [`data-sequence-unique-values`](references/data-sequence-unique-values.md) - Use sequences for uniqueness-constrained fields

### 3. Model Testing (HIGH)

- [`model-test-validations`](references/model-test-validations.md) - Test validations with boundary cases, not just happy path
- [`model-test-associations`](references/model-test-associations.md) - Test associations explicitly including dependent behavior
- [`model-test-scopes`](references/model-test-scopes.md) - Test scopes with matching and non-matching records
- [`model-test-callbacks-sparingly`](references/model-test-callbacks-sparingly.md) - Test callback side effects, not callback existence
- [`model-test-custom-methods`](references/model-test-custom-methods.md) - Test public methods with input/output pairs across scenarios
- [`model-avoid-testing-framework`](references/model-avoid-testing-framework.md) - Don't test ActiveRecord or framework behavior
- [`model-test-enums`](references/model-test-enums.md) - Test enum transitions and generated scopes

### 4. Request & Controller Testing (HIGH)

- [`request-over-controller-specs`](references/request-over-controller-specs.md) - Use request specs over deprecated controller specs
- [`request-test-response-status`](references/request-test-response-status.md) - Assert HTTP status codes explicitly
- [`request-test-authentication`](references/request-test-authentication.md) - Test authentication boundaries for every protected endpoint
- [`request-test-authorization`](references/request-test-authorization.md) - Test authorization for each role
- [`request-test-params-validation`](references/request-test-params-validation.md) - Test parameter validation and edge cases
- [`request-json-response-structure`](references/request-json-response-structure.md) - Assert JSON response structure for API endpoints

### 5. System & Acceptance Testing (MEDIUM-HIGH)

- [`system-page-objects`](references/system-page-objects.md) - Encapsulate page interactions in page objects
- [`system-use-accessible-selectors`](references/system-use-accessible-selectors.md) - Use accessible selectors over CSS/XPath
- [`system-avoid-sleep`](references/system-avoid-sleep.md) - Never use sleep — rely on Capybara's built-in waiting
- [`system-test-critical-paths`](references/system-test-critical-paths.md) - Reserve system tests for critical user journeys
- [`system-database-state`](references/system-database-state.md) - Use truncation strategy for system test database cleanup
- [`system-screenshot-on-failure`](references/system-screenshot-on-failure.md) - Capture screenshots on system test failure

### 6. Async & Background Job Testing (MEDIUM)

- [`async-separate-enqueue-from-perform`](references/async-separate-enqueue-from-perform.md) - Test enqueue and perform separately
- [`async-use-fake-mode-default`](references/async-use-fake-mode-default.md) - Default to Sidekiq fake mode globally
- [`async-test-job-perform`](references/async-test-job-perform.md) - Test job perform method directly
- [`async-test-mailer-delivery`](references/async-test-mailer-delivery.md) - Test mailer delivery with enqueued mail matcher
- [`async-test-after-commit`](references/async-test-after-commit.md) - Account for transaction-aware job enqueuing in Rails 7.2+

### 7. Test Performance & Reliability (MEDIUM)

- [`perf-parallel-tests`](references/perf-parallel-tests.md) - Run tests in parallel across CPU cores
- [`perf-database-strategy`](references/perf-database-strategy.md) - Use transaction strategy for non-system tests
- [`perf-profile-slow-specs`](references/perf-profile-slow-specs.md) - Profile and fix the slowest specs
- [`perf-quarantine-flaky-tests`](references/perf-quarantine-flaky-tests.md) - Quarantine flaky tests instead of retrying
- [`perf-avoid-before-all-mutation`](references/perf-avoid-before-all-mutation.md) - Never mutate state created in before(:all)

### 8. Test Organization & Maintenance (LOW-MEDIUM)

- [`org-avoid-deep-nesting`](references/org-avoid-deep-nesting.md) - Limit context nesting to 3 levels
- [`org-shared-examples-sparingly`](references/org-shared-examples-sparingly.md) - Use shared examples only for true behavioral contracts
- [`org-custom-matchers`](references/org-custom-matchers.md) - Extract custom matchers for repeated domain assertions
- [`org-file-structure-mirrors-app`](references/org-file-structure-mirrors-app.md) - Mirror app directory structure in spec directory

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
