# Ruby Refactoring

**Version 0.1.0**
Community
February 2026

> **Note:**
> This document is for agents and LLMs to follow when refactoring Ruby codebases.
> Humans may also find it useful, but guidance here is optimized for automation
> and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive refactoring guide for Ruby applications, designed for AI agents and LLMs. Contains 45 rules across 8 categories, prioritized by impact from critical (structure decomposition, conditional simplification) to incremental (naming and readability). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Structure & Decomposition](references/_sections.md#1-structure--decomposition) — **CRITICAL**
   - 1.1 [Compose Methods at Single Abstraction Level](references/struct-compose-method.md) — CRITICAL (reduces mixed abstraction levels from N to 1 per method)
   - 1.2 [Extract Class for Single Responsibility](references/struct-extract-class.md) — CRITICAL (reduces class coupling by 50-80%)
   - 1.3 [Extract Long Methods into Focused Units](references/struct-extract-method.md) — CRITICAL (reduces cognitive load by 3-5x)
   - 1.4 [Flatten Deep Nesting with Early Extraction](references/struct-flatten-deep-nesting.md) — HIGH (reduces cyclomatic complexity by 40-60%)
   - 1.5 [Introduce Parameter Object for Long Signatures](references/struct-parameter-object.md) — CRITICAL (eliminates parameter coupling across call chain)
   - 1.6 [One Reason to Change per Class](references/struct-single-responsibility.md) — HIGH (reduces change cascade across codebase)
   - 1.7 [Replace Complex Method with Method Object](references/struct-replace-method-with-object.md) — HIGH (enables decomposition of tangled logic)
2. [Conditional Simplification](references/_sections.md#2-conditional-simplification) — **CRITICAL**
   - 2.1 [Consolidate Duplicate Conditional Fragments](references/cond-consolidate-duplicates.md) — HIGH (reduces duplication by 30-50%)
   - 2.2 [Extract Complex Booleans into Named Predicates](references/cond-decompose-conditional.md) — CRITICAL (reduces boolean complexity from N clauses to 1 named predicate)
   - 2.3 [Replace case/when with Polymorphism](references/cond-replace-with-polymorphism.md) — CRITICAL (eliminates shotgun surgery across N branches)
   - 2.4 [Replace Nested Conditionals with Guard Clauses](references/cond-guard-clauses.md) — CRITICAL (reduces nesting depth by 2-4 levels)
   - 2.5 [Replace nil Checks with Null Object](references/cond-null-object.md) — HIGH (eliminates N nil-guard conditionals per call site)
   - 2.6 [Use Pattern Matching for Structural Conditions](references/cond-pattern-matching.md) — HIGH (reduces 3-5 nested nil checks to 1 expression)
3. [Coupling & Dependencies](references/_sections.md#3-coupling--dependencies) — **HIGH**
   - 3.1 [Avoid Class Methods in Domain Logic](references/couple-avoid-class-methods-domain.md) — MEDIUM-HIGH (reduces test setup from global stubs to 1 constructor injection)
   - 3.2 [Enforce Law of Demeter with Delegation](references/couple-law-of-demeter.md) — HIGH (reduces coupling to 1 dependency per call)
   - 3.3 [Inject Dependencies via Constructor Defaults](references/couple-dependency-injection.md) — HIGH (enables test isolation without monkey-patching)
   - 3.4 [Move Method to Resolve Feature Envy](references/couple-feature-envy.md) — HIGH (reduces cross-class coupling from N accessors to 1 method call)
   - 3.5 [Replace Mixin with Composed Object](references/couple-composition-over-inheritance.md) — HIGH (eliminates hidden method conflicts and unclear precedence)
   - 3.6 [Tell Objects What to Do, Don't Query Their State](references/couple-tell-dont-ask.md) — MEDIUM-HIGH (reduces caller coupling from N state queries to 1 command)
4. [Ruby Idioms](references/_sections.md#4-ruby-idioms) — **HIGH**
   - 4.1 [Always Pair method_missing with respond_to_missing?](references/idiom-respond-to-missing.md) — MEDIUM-HIGH (prevents broken respond_to? and method introspection)
   - 4.2 [Name Boolean Methods with ? Suffix](references/idiom-predicate-methods.md) — MEDIUM-HIGH (eliminates N return-type lookups per code review)
   - 4.3 [Omit Explicit return for Last Expression](references/idiom-implicit-return.md) — MEDIUM-HIGH (follows Ruby convention, reduces noise)
   - 4.4 [Use Keyword Arguments for Clarity](references/idiom-keyword-arguments.md) — HIGH (self-documents call sites, prevents argument order bugs)
   - 4.5 [Use map/select/reject Over each with Accumulator](references/idiom-prefer-enumerable.md) — HIGH (eliminates mutable accumulator pattern)
   - 4.6 [Use respond_to? Over is_a? for Type Checking](references/idiom-duck-typing.md) — HIGH (enables polymorphism without inheritance hierarchy)
   - 4.7 [Use yield Over block.call for Simple Blocks](references/idiom-block-yield.md) — MEDIUM-HIGH (avoids Proc allocation, 2-5x faster)
5. [Data & Value Objects](references/_sections.md#5-data--value-objects) — **MEDIUM-HIGH**
   - 5.1 [Encapsulate Collections Behind Domain Methods](references/data-encapsulate-collection.md) — MEDIUM-HIGH (prevents external mutation and scatters)
   - 5.2 [Replace Data Clumps with Grouped Objects](references/data-replace-data-clump.md) — MEDIUM (eliminates parameter coupling across 3+ methods)
   - 5.3 [Replace Primitive Obsession with Value Objects](references/data-value-object.md) — MEDIUM-HIGH (reduces scattered validation from N call sites to 1 constructor)
   - 5.4 [Separate Query Methods from Command Methods](references/data-separate-query-command.md) — MEDIUM (enables safe caching and idempotent reads)
   - 5.5 [Use Data.define for Immutable Value Objects](references/data-define-immutable.md) — MEDIUM-HIGH (immutable by default, 10-50x faster construction than OpenStruct)
6. [Design Patterns](references/_sections.md#6-design-patterns) — **MEDIUM**
   - 6.1 [Define Algorithm Skeleton with Template Method](references/pattern-template-method.md) — MEDIUM (eliminates 60-80% duplicated algorithm code across N subclasses)
   - 6.2 [Extract Algorithm Variations into Strategy Objects](references/pattern-strategy.md) — MEDIUM (reduces case/when branches from N to 0 in caller)
   - 6.3 [Implement Null Object with Full Protocol](references/pattern-null-object-protocol.md) — MEDIUM (eliminates conditional nil checking across entire call chain)
   - 6.4 [Use Factory Method to Abstract Object Creation](references/pattern-factory.md) — MEDIUM (decouples creation from usage, enables extension)
   - 6.5 [Wrap Objects with Decorator for Added Behavior](references/pattern-decorator.md) — MEDIUM (reduces subclass explosion from 2^N combinations to N decorators)
7. [Modern Ruby 3.x](references/_sections.md#7-modern-ruby-3x) — **MEDIUM**
   - 7.1 [Implement deconstruct_keys for Custom Pattern Matching](references/modern-deconstruct-keys.md) — MEDIUM (enables pattern matching on domain objects)
   - 7.2 [Use case/in for Structural Pattern Matching](references/modern-pattern-matching.md) — MEDIUM (reduces 3-5 nested hash checks to 1 destructuring expression)
   - 7.3 [Use Endless Method Definition for Simple Methods](references/modern-endless-methods.md) — MEDIUM (reduces noise for one-liner methods)
   - 7.4 [Use Pattern Matching with Guard Clauses](references/modern-hash-pattern-guard.md) — MEDIUM (reduces nested if/case from 3-4 levels to 1 flat match)
   - 7.5 [Use Rightward Assignment for Pipeline Expressions](references/modern-rightward-assignment.md) — LOW-MEDIUM (reduces left-side noise in multi-step pipelines by 30-50%)
8. [Naming & Readability](references/_sections.md#8-naming--readability) — **LOW-MEDIUM**
   - 8.1 [Rename to Eliminate Need for Comments](references/name-rename-to-remove-comments.md) — LOW-MEDIUM (eliminates 1 comment per renamed method or variable)
   - 8.2 [Spell Out Names Except Universal Abbreviations](references/name-avoid-abbreviations.md) — LOW-MEDIUM (prevents ambiguity and miscommunication)
   - 8.3 [Use Intention-Revealing Names](references/name-intention-revealing.md) — LOW-MEDIUM (eliminates need for explanatory comments)
   - 8.4 [Use One Word per Concept Across Codebase](references/name-consistent-vocabulary.md) — LOW-MEDIUM (prevents confusion between synonyms)

---

## References

- [RuboCop Ruby Style Guide](https://github.com/rubocop/ruby-style-guide)
- [Shopify Ruby Style Guide](https://ruby-style-guide.shopify.dev/)
- [POODR (Sandi Metz)](https://www.poodr.com/)
- [Sandi Metz's Four Rules](https://thoughtbot.com/blog/sandi-metz-rules-for-developers)
- [Ruby Science (thoughtbot)](https://thoughtbot.com/ruby-science/)
- [Refactoring: Ruby Edition](https://martinfowler.com/books/refactoringRubyEd.html)
- [Refactoring Guru](https://refactoring.guru/refactoring/catalog)
- [Ruby 3.x Pattern Matching](https://docs.ruby-lang.org/en/3.3/syntax/pattern_matching_rdoc.html)
- [GitHub Ruby Style Guide](https://github.com/github/rubocop-github)
- [Airbnb Ruby Style Guide](https://github.com/airbnb/ruby)
