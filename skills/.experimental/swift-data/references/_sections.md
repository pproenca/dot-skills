# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Data Modeling (model)

**Impact:** CRITICAL
**Description:** Custom types and @Model design are the foundation. Wrong model definitions cascade into broken persistence, faulty queries, and corrupt relationships.

## 2. Persistence Setup (persist)

**Impact:** CRITICAL
**Description:** ModelContainer, ModelContext, and @ModelActor configuration determines whether data survives app launches and whether concurrent access is safe. Incorrect setup silently loses user data or causes crashes.

## 3. Querying & Filtering (query)

**Impact:** HIGH
**Description:** @Query, predicates, and FetchDescriptor control how data reaches views. Inefficient queries cause lag and stale UI. Cross-context staleness is a known framework limitation requiring explicit workarounds.

## 4. CRUD Operations (crud)

**Impact:** HIGH
**Description:** Insert, update, and delete patterns through ModelContext. Wrong mutation patterns cause data corruption and UI inconsistencies. Error handling for save failures is critical to prevent silent data loss.

## 5. Sync & Networking (sync)

**Impact:** HIGH
**Description:** Fetching from APIs, persisting to SwiftData, offline-first architecture, and conflict resolution. Most production apps require network-to-persistence sync, and wrong patterns cause data races, duplicate records, and stale UI.

## 6. Relationships (rel)

**Impact:** MEDIUM-HIGH
**Description:** One-to-many, inverse relationships, and delete rules. Misconfigured relationships orphan data or cascade deletes unexpectedly.

## 7. SwiftUI State Flow (state)

**Impact:** MEDIUM-HIGH
**Description:** @Bindable, @State, @Environment, @Query, and @Observable coordinate data flow through the view hierarchy. Architecture decisions (ViewModel vs @Query, business logic placement) determine long-term maintainability and testability.

## 8. Schema & Migration (schema)

**Impact:** MEDIUM-HIGH
**Description:** Schema definition, @Attribute customizations, and migration strategies. Unplanned schema changes crash existing users on app update — a botched migration causes 100% crash rate.

## 9. Sample Data & Previews (preview)

**Impact:** MEDIUM
**Description:** SampleData singleton and in-memory containers ensure reliable previews. Bad preview setup wastes development time with duplicate or missing data.
