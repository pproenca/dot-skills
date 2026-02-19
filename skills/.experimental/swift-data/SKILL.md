---
name: swift-data
description: SwiftData persistence, data modeling, and modular MVVM-C data-layer integration for iOS 26 / Swift 6.2 apps. Use when writing, reviewing, or refactoring @Model entities, repository implementations, stale-while-revalidate reads, optimistic queued writes, sync/retry behavior, and SwiftUI state integration that keeps SwiftData types in Data only.
---

# SwiftData Best Practices — Modular MVVM-C Data Layer

Comprehensive data modeling, persistence, sync architecture, and error handling guide for SwiftData aligned with the clinic modular MVVM-C stack.

## Architecture Alignment

This skill enforces the same modular architecture mandated by `swift-ui-architect`:

```
┌───────────────────────────────────────────────────────────────┐
│ Feature modules: View + ViewModel, no SwiftData imports       │
├───────────────────────────────────────────────────────────────┤
│ Domain: models + repository/coordinator/error protocols        │
├───────────────────────────────────────────────────────────────┤
│ Data: @Model entities, SwiftData stores, repository impls,     │
│ remote clients, retry executor, sync queue, conflict handling  │
└───────────────────────────────────────────────────────────────┘
```

**Key principle:** SwiftData types (`@Model`, `ModelContext`, `@Query`, `FetchDescriptor`) live in Data-only implementation code. Feature Views/ViewModels work with Domain types and protocol dependencies.

## When to Apply

Reference these guidelines when:
- Defining @Model entity classes and mapping them to domain structs
- Setting up ModelContainer and ModelContext in the Data layer
- Implementing repository protocols backed by SwiftData
- Writing stale-while-revalidate repository reads (`AsyncStream`)
- Implementing optimistic writes plus queued sync operations
- Configuring entity relationships (one-to-many, inverse)
- Fetching from APIs and persisting to SwiftData via sync coordinators
- Handling save failures, corrupt stores, and migration errors
- Routing AppError traits to centralized error UI infrastructure
- Building preview infrastructure with sample data
- Planning schema migrations for app updates

## Workflow

Use this workflow when designing or refactoring a SwiftData-backed feature:

1. Domain design: define domain structs (`Trip`, `Friend`) with validation/computed rules (see `model-domain-mapping`, `state-business-logic-placement`)
2. Entity design: define `@Model` entity classes with mapping methods (see `model-*`, `model-domain-mapping`)
3. Repository protocol: define in Domain layer, implement with SwiftData in Data layer (see `persist-repository-wrapper`)
4. Container wiring: configure `ModelContainer` once at the app boundary with error recovery (see `persist-container-setup`, `persist-container-error-recovery`)
5. Dependency injection: inject repository protocols via @Environment (see `state-dependency-injection`)
6. ViewModel: create @Observable ViewModel that delegates directly to repository protocols (see `state-query-vs-viewmodel`)
7. CRUD flows: route all insert/delete/update through ViewModel -> Repository (see `crud-*`)
8. Sync architecture: queue writes, execute via sync coordinator with retry policy (see `sync-*`)
9. Relationships: model to-many relationships as arrays; define delete rules (see `rel-*`)
10. Previews: create in-memory containers and sample data for fast iteration (see `preview-*`)
11. Schema evolution: plan migrations with versioned schemas (see `schema-*`)

## Troubleshooting

- Data not persisting -> `persist-model-macro`, `persist-container-setup`, `persist-autosave`, `schema-configuration`
- List not updating after background import -> `query-background-refresh`, `persist-model-actor`
- List not updating (same-context) -> `query-property-wrapper`, `state-wrapper-views`
- Duplicates from API sync -> `schema-unique-attributes`, `sync-conflict-resolution`
- App crashes on launch after model change -> `schema-migration-recovery`, `persist-container-error-recovery`
- Save failures silently losing data -> `crud-save-error-handling`
- Stale data from network -> `sync-offline-first`, `sync-fetch-persist`
- Widget/extension can't see data -> `persist-app-group`, `schema-configuration`
- Choosing architecture pattern for data views -> `state-query-vs-viewmodel`, `persist-repository-wrapper`

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Data Modeling | CRITICAL | `model-` |
| 2 | Persistence Setup | CRITICAL | `persist-` |
| 3 | Querying & Filtering | HIGH | `query-` |
| 4 | CRUD Operations | HIGH | `crud-` |
| 5 | Sync & Networking | HIGH | `sync-` |
| 6 | Relationships | MEDIUM-HIGH | `rel-` |
| 7 | SwiftUI State Flow | MEDIUM-HIGH | `state-` |
| 8 | Schema & Migration | MEDIUM-HIGH | `schema-` |
| 9 | Sample Data & Previews | MEDIUM | `preview-` |

## Quick Reference

### 1. Data Modeling (CRITICAL)

- [`model-domain-mapping`](references/model-domain-mapping.md) - Map @Model entities to domain structs across Domain/Data boundaries
- [`model-custom-types`](references/model-custom-types.md) - Use custom types over parallel arrays
- [`model-class-for-persistence`](references/model-class-for-persistence.md) - Use classes for SwiftData entity types
- [`model-identifiable`](references/model-identifiable.md) - Conform entities to Identifiable with UUID
- [`model-initializer`](references/model-initializer.md) - Provide custom initializers for entity classes
- [`model-computed-properties`](references/model-computed-properties.md) - Use computed properties for derived data
- [`model-defaults`](references/model-defaults.md) - Provide sensible default values for entity properties
- [`model-transient`](references/model-transient.md) - Mark non-persistent properties with @Transient
- [`model-external-storage`](references/model-external-storage.md) - Use external storage for large binary data

### 2. Persistence Setup (CRITICAL)

- [`persist-repository-wrapper`](references/persist-repository-wrapper.md) - Wrap SwiftData behind Domain repository protocols
- [`persist-model-macro`](references/persist-model-macro.md) - Apply @Model macro to all persistent types
- [`persist-container-setup`](references/persist-container-setup.md) - Configure ModelContainer at the App level
- [`persist-container-error-recovery`](references/persist-container-error-recovery.md) - Handle ModelContainer creation failure with store recovery
- [`persist-context-environment`](references/persist-context-environment.md) - Access ModelContext via @Environment (Data layer)
- [`persist-autosave`](references/persist-autosave.md) - Enable autosave for manually created contexts
- [`persist-enumerate-batch`](references/persist-enumerate-batch.md) - Use ModelContext.enumerate for large traversals
- [`persist-in-memory-config`](references/persist-in-memory-config.md) - Use in-memory configuration for tests and previews
- [`persist-app-group`](references/persist-app-group.md) - Use App Groups for shared data storage
- [`persist-model-actor`](references/persist-model-actor.md) - Use @ModelActor for background SwiftData work
- [`persist-identifier-transfer`](references/persist-identifier-transfer.md) - Pass PersistentIdentifier across actors

### 3. Querying & Filtering (HIGH)

- [`query-property-wrapper`](references/query-property-wrapper.md) - Use @Query for declarative data fetching (Data layer)
- [`query-background-refresh`](references/query-background-refresh.md) - Force view refresh after background context inserts
- [`query-sort-descriptors`](references/query-sort-descriptors.md) - Apply sort descriptors to @Query
- [`query-predicates`](references/query-predicates.md) - Use #Predicate for type-safe filtering
- [`query-dynamic-init`](references/query-dynamic-init.md) - Use custom view initializers for dynamic queries
- [`query-fetch-descriptor`](references/query-fetch-descriptor.md) - Use FetchDescriptor outside SwiftUI views
- [`query-fetch-tuning`](references/query-fetch-tuning.md) - Tune FetchDescriptor paging and pending-change behavior
- [`query-localized-search`](references/query-localized-search.md) - Use localizedStandardContains for search
- [`query-expression`](references/query-expression.md) - Use #Expression for reusable predicate components (iOS 18+)

### 4. CRUD Operations (HIGH)

- [`crud-insert-context`](references/crud-insert-context.md) - Insert models via repository implementations
- [`crud-delete-indexset`](references/crud-delete-indexset.md) - Delete via repository with IndexSet from onDelete
- [`crud-sheet-creation`](references/crud-sheet-creation.md) - Use sheets for focused data creation via ViewModel
- [`crud-cancel-delete`](references/crud-cancel-delete.md) - Avoid orphaned records by persisting only on save
- [`crud-undo-cancel`](references/crud-undo-cancel.md) - Enable undo and use it to cancel edits
- [`crud-edit-button`](references/crud-edit-button.md) - Provide EditButton for list management
- [`crud-dismiss-save`](references/crud-dismiss-save.md) - Dismiss modal after ViewModel save completes
- [`crud-save-error-handling`](references/crud-save-error-handling.md) - Handle repository save failures with user feedback

### 5. Sync & Networking (HIGH)

- [`sync-fetch-persist`](references/sync-fetch-persist.md) - Use injected sync services to fetch and persist API data
- [`sync-offline-first`](references/sync-offline-first.md) - Design offline-first architecture with repository reads and background sync
- [`sync-conflict-resolution`](references/sync-conflict-resolution.md) - Implement conflict resolution for bidirectional sync

### 6. Relationships (MEDIUM-HIGH)

- [`rel-optional-single`](references/rel-optional-single.md) - Use optionals for optional relationships
- [`rel-array-many`](references/rel-array-many.md) - Use arrays for one-to-many relationships
- [`rel-inverse-auto`](references/rel-inverse-auto.md) - Rely on SwiftData automatic inverse maintenance
- [`rel-delete-rules`](references/rel-delete-rules.md) - Configure cascade delete rules for owned relationships
- [`rel-explicit-sort`](references/rel-explicit-sort.md) - Sort relationship arrays explicitly

### 7. SwiftUI State Flow (MEDIUM-HIGH)

- [`state-query-vs-viewmodel`](references/state-query-vs-viewmodel.md) - Route all data access through @Observable ViewModels
- [`state-business-logic-placement`](references/state-business-logic-placement.md) - Place business logic in domain value types and repository-backed ViewModels
- [`state-dependency-injection`](references/state-dependency-injection.md) - Inject repository protocols via @Environment
- [`state-bindable`](references/state-bindable.md) - Use @Bindable for two-way model binding
- [`state-local-state`](references/state-local-state.md) - Use @State for view-local transient data
- [`state-wrapper-views`](references/state-wrapper-views.md) - Extract wrapper views for dynamic query state

### 8. Schema & Migration (MEDIUM-HIGH)

- [`schema-define-all-types`](references/schema-define-all-types.md) - Define schema with all model types
- [`schema-unique-attributes`](references/schema-unique-attributes.md) - Use @Attribute(.unique) for natural keys
- [`schema-unique-macro`](references/schema-unique-macro.md) - Use #Unique for compound uniqueness (iOS 18+)
- [`schema-index`](references/schema-index.md) - Use #Index for hot predicates and sorts (iOS 18+)
- [`schema-migration-plan`](references/schema-migration-plan.md) - Plan migrations before changing models
- [`schema-migration-recovery`](references/schema-migration-recovery.md) - Plan migration recovery for schema changes
- [`schema-configuration`](references/schema-configuration.md) - Customize storage with ModelConfiguration

### 9. Sample Data & Previews (MEDIUM)

- [`preview-sample-singleton`](references/preview-sample-singleton.md) - Create a SampleData singleton for previews
- [`preview-in-memory`](references/preview-in-memory.md) - Use in-memory containers for preview isolation
- [`preview-static-data`](references/preview-static-data.md) - Define static sample data on model types
- [`preview-main-actor`](references/preview-main-actor.md) - Annotate SampleData with @MainActor

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
