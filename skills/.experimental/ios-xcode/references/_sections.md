# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Project & Platform (project)

**Impact:** HIGH
**Description:** Xcode project configuration, app storage, scene lifecycle, and widget integration define the foundation of your app's capabilities and platform integration.

## 2. SwiftData & Persistence (data)

**Impact:** CRITICAL
**Description:** SwiftData model definitions, queries, containers, and CRUD operations are essential for apps with persistent data. Wrong patterns cause data corruption and performance issues.

## 3. Testing (test)

**Impact:** HIGH
**Description:** Swift Testing framework, preview macros, and sample data enable rapid iteration and catch bugs before they ship. Previews are your fastest feedback loop.

## 4. Debugging & Profiling (debug)

**Impact:** MEDIUM-HIGH
**Description:** Breakpoints, console output, and Instruments profiling are essential for diagnosing issues and optimizing performance in Xcode.

## 5. Distribution (dist)

**Impact:** MEDIUM
**Description:** TestFlight distribution and app icon design are the final steps before users experience your app. Getting these right ensures a professional launch.

## 6. Specialty Platforms (platform)

**Impact:** MEDIUM
**Description:** Natural Language ML and visionOS spatial computing extend your app to Apple's broader ecosystem. These patterns enable platform-specific features.
