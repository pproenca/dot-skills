---
name: swift-data
description: SwiftData data modeling, persistence, and state management guidelines from Apple Developer tutorials. This skill should be used when writing, reviewing, or refactoring SwiftData models, persistence logic, @Query usage, CRUD operations, relationships, or SwiftUI state integration in iOS apps. Triggers on tasks involving @Model, ModelContainer, ModelContext, @Query, SwiftData relationships, or data persistence.
---

# Apple Developer SwiftData Best Practices

Comprehensive data modeling, persistence, and state management guide for Swift and SwiftUI applications using SwiftData, sourced from official Apple Developer tutorials and WWDC sessions. Contains 48 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Defining @Model classes and their properties
- Setting up ModelContainer and ModelContext for persistence
- Writing @Query declarations and predicates
- Implementing create, update, and delete operations
- Configuring model relationships (one-to-many, inverse)
- Coordinating SwiftUI state with SwiftData (@Bindable, @State, @Environment)
- Building preview infrastructure with sample data
- Planning schema migrations for app updates

## Workflow

Use this workflow when designing or refactoring a SwiftData-backed feature:

1. Model design: define `@Model` classes, defaults, and transient/computed state (see `model-*`)
2. Container wiring: configure `ModelContainer` once at the app boundary; choose default vs custom configuration; decide App Group sharing (see `persist-container-setup`, `schema-configuration`, `persist-app-group`)
3. Queries: prefer `@Query` in views; use `FetchDescriptor` in services/background work (see `query-property-wrapper`, `query-fetch-descriptor`, `query-fetch-tuning`)
4. CRUD flows: insert/delete via the environment context; choose creation UI patterns; handle cancel/undo appropriately (see `crud-*`)
5. Relationships: model to-many relationships as arrays; define delete rules for ownership (see `rel-*`)
6. Previews: create in-memory containers and sample data for fast iteration (see `preview-*`)
7. Schema evolution: plan migrations and validate uniqueness/indexing choices before shipping (see `schema-*`)

## Troubleshooting

- Data not persisting -> `persist-model-macro`, `persist-container-setup`, `persist-autosave`, `schema-configuration`
- List not updating -> `query-property-wrapper`, `state-query-view-updates`, `state-wrapper-views`
- Duplicates -> `schema-unique-attributes`, `schema-unique-macro`
- Widget/extension can’t see data -> `persist-app-group`, `schema-configuration`

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Data Modeling | CRITICAL | `model-` |
| 2 | Persistence Setup | CRITICAL | `persist-` |
| 3 | Querying & Filtering | HIGH | `query-` |
| 4 | CRUD Operations | HIGH | `crud-` |
| 5 | Relationships | MEDIUM-HIGH | `rel-` |
| 6 | SwiftUI State Flow | MEDIUM | `state-` |
| 7 | Sample Data & Previews | MEDIUM | `preview-` |
| 8 | Schema & Migration | LOW-MEDIUM | `schema-` |

## Quick Reference

### 1. Data Modeling (CRITICAL)

- [`model-custom-types`](references/model-custom-types.md) - Use custom types over parallel arrays
- [`model-class-for-persistence`](references/model-class-for-persistence.md) - Use classes for SwiftData persistent models
- [`model-identifiable`](references/model-identifiable.md) - Conform models to Identifiable with UUID
- [`model-initializer`](references/model-initializer.md) - Provide custom initializers for model classes
- [`model-computed-properties`](references/model-computed-properties.md) - Use computed properties for derived data
- [`model-defaults`](references/model-defaults.md) - Provide sensible default values for model properties
- [`model-transient`](references/model-transient.md) - Mark non-persistent properties with @Transient

### 2. Persistence Setup (CRITICAL)

- [`persist-model-macro`](references/persist-model-macro.md) - Apply @Model macro to all persistent types
- [`persist-container-setup`](references/persist-container-setup.md) - Configure ModelContainer at the App level
- [`persist-context-environment`](references/persist-context-environment.md) - Access ModelContext via @Environment
- [`persist-autosave`](references/persist-autosave.md) - Enable autosave for manually created contexts
- [`persist-enumerate-batch`](references/persist-enumerate-batch.md) - Use ModelContext.enumerate for large traversals
- [`persist-in-memory-config`](references/persist-in-memory-config.md) - Use in-memory configuration for tests and previews
- [`persist-app-group`](references/persist-app-group.md) - Use App Groups for shared data storage

### 3. Querying & Filtering (HIGH)

- [`query-property-wrapper`](references/query-property-wrapper.md) - Use @Query for declarative data fetching
- [`query-sort-descriptors`](references/query-sort-descriptors.md) - Apply sort descriptors to @Query
- [`query-predicates`](references/query-predicates.md) - Use #Predicate for type-safe filtering
- [`query-dynamic-init`](references/query-dynamic-init.md) - Use custom view initializers for dynamic queries
- [`query-fetch-descriptor`](references/query-fetch-descriptor.md) - Use FetchDescriptor outside SwiftUI views
- [`query-fetch-tuning`](references/query-fetch-tuning.md) - Tune FetchDescriptor paging and pending-change behavior
- [`query-localized-search`](references/query-localized-search.md) - Use localizedStandardContains for search

### 4. CRUD Operations (HIGH)

- [`crud-insert-context`](references/crud-insert-context.md) - Insert models via ModelContext
- [`crud-delete-indexset`](references/crud-delete-indexset.md) - Delete using IndexSet with onDelete modifier
- [`crud-sheet-creation`](references/crud-sheet-creation.md) - Use sheets for focused data creation
- [`crud-cancel-delete`](references/crud-cancel-delete.md) - Delete unsaved models on cancel
- [`crud-undo-cancel`](references/crud-undo-cancel.md) - Enable undo and use it to cancel edits
- [`crud-edit-button`](references/crud-edit-button.md) - Provide EditButton for list management
- [`crud-dismiss-save`](references/crud-dismiss-save.md) - Use Environment dismiss for modal save flow

### 5. Relationships (MEDIUM-HIGH)

- [`rel-optional-single`](references/rel-optional-single.md) - Use optionals for optional relationships
- [`rel-array-many`](references/rel-array-many.md) - Use arrays for one-to-many relationships
- [`rel-inverse-auto`](references/rel-inverse-auto.md) - Rely on SwiftData automatic inverse maintenance
- [`rel-delete-rules`](references/rel-delete-rules.md) - Configure cascade delete rules for owned relationships
- [`rel-explicit-sort`](references/rel-explicit-sort.md) - Sort relationship arrays explicitly

### 6. SwiftUI State Flow (MEDIUM)

- [`state-bindable`](references/state-bindable.md) - Use @Bindable for two-way model binding
- [`state-environment-context`](references/state-environment-context.md) - Access ModelContext via @Environment for mutations
- [`state-query-view-updates`](references/state-query-view-updates.md) - Leverage @Query for automatic view updates
- [`state-local-state`](references/state-local-state.md) - Use @State for view-local transient data
- [`state-wrapper-views`](references/state-wrapper-views.md) - Extract wrapper views for dynamic query state

### 7. Sample Data & Previews (MEDIUM)

- [`preview-sample-singleton`](references/preview-sample-singleton.md) - Create a SampleData singleton for previews
- [`preview-in-memory`](references/preview-in-memory.md) - Use in-memory containers for preview isolation
- [`preview-static-data`](references/preview-static-data.md) - Define static sample data on model types
- [`preview-main-actor`](references/preview-main-actor.md) - Annotate SampleData with @MainActor

### 8. Schema & Migration (LOW-MEDIUM)

- [`schema-define-all-types`](references/schema-define-all-types.md) - Define schema with all model types
- [`schema-unique-attributes`](references/schema-unique-attributes.md) - Use @Attribute(.unique) for natural keys
- [`schema-unique-macro`](references/schema-unique-macro.md) - Use #Unique for compound uniqueness (iOS 18+)
- [`schema-index`](references/schema-index.md) - Use #Index for hot predicates and sorts (iOS 18+)
- [`schema-migration-plan`](references/schema-migration-plan.md) - Plan migrations before changing models
- [`schema-configuration`](references/schema-configuration.md) - Customize storage with ModelConfiguration

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
