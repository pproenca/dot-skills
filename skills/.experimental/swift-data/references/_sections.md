# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Data Modeling (model)

**Impact:** CRITICAL
**Description:** @Model entity design and entity-to-domain struct mapping are the foundation. Wrong model definitions cascade into broken persistence, faulty queries, and corrupt relationships. Entity classes live in the Data layer; domain structs (Equatable, Sendable) live in the Domain layer.

## 2. Persistence Setup (persist)

**Impact:** CRITICAL
**Description:** ModelContainer, ModelContext, @ModelActor, and repository protocol implementations determine whether data survives app launches and whether concurrent access is safe. Repository protocols are defined in the Domain layer; SwiftData implementations live in the Data layer. Incorrect setup silently loses user data or causes crashes.

## 3. Querying & Filtering (query)

**Impact:** HIGH
**Description:** @Query, predicates, and FetchDescriptor control how data reaches views. Inefficient queries cause lag and stale UI. Cross-context staleness is a known framework limitation requiring explicit workarounds.

## 4. CRUD Operations (crud)

**Impact:** HIGH
**Description:** Insert, update, and delete patterns routed through ViewModels and repository implementations. All mutations flow View -> ViewModel -> Repository -> SwiftData. Wrong patterns cause data corruption and UI inconsistencies. Error handling for save failures is critical to prevent silent data loss.

## 5. Sync & Networking (sync)

**Impact:** HIGH
**Description:** Injected sync services fetch from APIs and persist to SwiftData via @ModelActor. Sync protocols are defined in the Domain layer; implementations live in the Data layer. ViewModels coordinate repository reads and background sync. Wrong patterns cause data races, duplicate records, and stale UI.

## 6. Relationships (rel)

**Impact:** MEDIUM-HIGH
**Description:** One-to-many, inverse relationships, and delete rules. Misconfigured relationships orphan data or cascade deletes unexpectedly.

## 7. SwiftUI State Flow (state)

**Impact:** MEDIUM-HIGH
**Description:** @Observable ViewModels, @Bindable, @State, and @Environment coordinate data flow through the view hierarchy following Clean MVVM + Repository architecture. All data access routes through ViewModels backed by repository protocols. Business logic lives in domain value types and use cases, not in views or ViewModels.

## 8. Schema & Migration (schema)

**Impact:** MEDIUM-HIGH
**Description:** Schema definition, @Attribute customizations, and migration strategies. Unplanned schema changes crash existing users on app update — a botched migration causes 100% crash rate.

## 9. Sample Data & Previews (preview)

**Impact:** MEDIUM
**Description:** SampleData singleton and in-memory containers ensure reliable previews. Bad preview setup wastes development time with duplicate or missing data.
