# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. Glossary Lifecycle (gloss)

**Description:** The recorded ubiquitous language — the artifact that makes a vocabulary shared instead of tribal. A project with domain concepts but no recorded glossary fails the gate outright (absence is FAIL, not N/A); once a glossary exists, code must conform to it, every entry must stay live in the code, and definitions must carry business meaning a stakeholder can use. This category is the engine that produces a common, well-sized vocabulary on any project over repeated runs.

## 2. Language Consistency (lang)

**Description:** The vocabulary as it is actually used across code, tests, docs, and customer-facing surfaces. Catches synonym drift (two names, one concept), homonym collisions (one name, two concepts), semantics-free naming (Manager/Helper/Data types holding domain rules), domain transitions hidden behind generic setters, and code whose identifiers contradict its own documentation or UI copy. These are the failures that quietly fork the team's language from the stakeholders'.

## 3. Domain Model Integrity (model)

**Description:** Whether the model expresses the domain or merely stores it. Catches business rules enforced outside the type they govern while the type exposes raw mutation, objects constructible in invariant-violating states, domain concepts passed as bare interchangeable primitives, and lifecycles encoded as boolean flag piles instead of the domain's named states.

## 4. Boundaries & Context Integrity (ctx)

**Description:** The seams between bounded contexts and between the domain and the outside world. Catches one context reaching into another's internals instead of its published interface, external vendor models embedded untranslated in domain state, infrastructure imports inside the domain layer, and the same stored model mutated by more than one context.

## 5. Semantic Model & DSL Surface (dsl)

**Description:** DSLs and fluent surfaces judged as domain-vocabulary artifacts. Catches carrier syntax coupled directly to execution with no semantic model in between, DSL surfaces that let statements the domain forbids build without immediate error, and external DSLs shipped with no deterministic validator. Applies only when the target contains a DSL, builder surface, or declarative spec format; otherwise N/A.
