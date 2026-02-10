# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Data Modeling (model)

**Impact:** CRITICAL
**Description:** Custom types and @Model design are the foundation. Wrong model definitions cascade into broken persistence, faulty queries, and corrupt relationships.

## 2. Persistence Setup (persist)

**Impact:** CRITICAL
**Description:** ModelContainer and ModelContext configuration determines whether data survives app launches. Incorrect setup silently loses user data.

## 3. Querying & Filtering (query)

**Impact:** HIGH
**Description:** @Query, predicates, and FetchDescriptor control how data reaches views. Inefficient queries cause lag and stale UI.

## 4. CRUD Operations (crud)

**Impact:** HIGH
**Description:** Insert, update, and delete patterns through ModelContext. Wrong mutation patterns cause data corruption and UI inconsistencies.

## 5. Relationships (rel)

**Impact:** MEDIUM-HIGH
**Description:** One-to-many, inverse relationships, and delete rules. Misconfigured relationships orphan data or cascade deletes unexpectedly.

## 6. SwiftUI State Flow (state)

**Impact:** MEDIUM
**Description:** @Bindable, @State, @Environment, and @Query coordinate data flow through the view hierarchy. Wrong wrappers cause stale UI or unnecessary redraws.

## 7. Sample Data & Previews (preview)

**Impact:** MEDIUM
**Description:** SampleData singleton and in-memory containers ensure reliable previews. Bad preview setup wastes development time with duplicate or missing data.

## 8. Schema & Migration (schema)

**Impact:** LOW-MEDIUM
**Description:** Schema definition, @Attribute customizations, and migration strategies. Unplanned schema changes crash existing users on app update.
