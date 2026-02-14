# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Architecture Fundamentals (arch)

**Impact:** CRITICAL
**Description:** Rich domain models over service objects, vanilla Rails over gems, earned abstractions over premature design — these foundational decisions cascade through every layer of the application.

## 2. Controllers & REST (ctrl)

**Impact:** CRITICAL
**Description:** CRUD-only controllers with resourceful routing eliminate custom actions and keep the HTTP layer thin, pushing all business logic into domain models.

## 3. Domain Modeling (model)

**Impact:** HIGH
**Description:** Concerns for horizontal sharing, normalizes for data cleaning, delegated_type for polymorphism — the rich model toolkit that replaces service layers.

## 4. State Management (state)

**Impact:** HIGH
**Description:** Records over booleans, timestamps over flags, database constraints over validations — state modeling that provides audit trails and enforces integrity at the database level.

## 5. Database & Infrastructure (db)

**Impact:** HIGH
**Description:** Database-backed everything: Solid Queue for jobs, Solid Cable for pub/sub, Solid Cache for caching — eliminating Redis and external dependencies.

## 6. Views & Frontend (view)

**Impact:** MEDIUM
**Description:** Hotwire-driven UI with Turbo Frames, Turbo Streams, and Stimulus — server-rendered HTML with progressive enhancement, minimal JavaScript.

## 7. Code Style (style)

**Impact:** MEDIUM
**Description:** Method ordering by call sequence, expanded conditionals, positive naming, _later/_now async conventions — the 37signals STYLE.md readability rules.

## 8. Testing (test)

**Impact:** MEDIUM
**Description:** Minitest over RSpec, fixtures over factories, behavior verification over implementation testing — fast, simple tests without design damage.
