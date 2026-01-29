# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Configuration Foundations (config)

**Impact:** CRITICAL
**Description:** Proper entry and project file configuration prevents false positives and ensures all dead code is detected. Misconfiguration is the #1 cause of missed issues.

## 2. Entry Point Strategy (entry)

**Impact:** CRITICAL
**Description:** Entry files determine the analysis scope. Missing entries cause missed dead code; incorrect entries cause false positives across the entire codebase.

## 3. Workspace & Monorepo (workspace)

**Impact:** HIGH
**Description:** Monorepo misconfiguration causes cross-workspace false positives and missed dependencies. Each workspace requires explicit configuration.

## 4. Dependency Analysis (deps)

**Impact:** HIGH
**Description:** Detecting unused dependencies reduces bundle size, install time, and security surface. Proper plugin configuration catches tool-specific dependencies.

## 5. Export Detection (exports)

**Impact:** MEDIUM-HIGH
**Description:** Unused exports inflate bundles and obscure codebases. Correct configuration catches dead exports while respecting intentional public APIs.

## 6. CI Integration (ci)

**Impact:** MEDIUM
**Description:** CI integration prevents dead code regressions. Proper setup ensures fast feedback without blocking legitimate changes.

## 7. Auto-Fix Workflow (fix)

**Impact:** MEDIUM
**Description:** Safe auto-fix workflows prevent accidental code loss while maximizing cleanup efficiency. Always review changes before committing.

## 8. Performance Optimization (perf)

**Impact:** LOW-MEDIUM
**Description:** Caching, filtering, and mode selection optimize analysis speed for large codebases. Essential for monorepos with 100k+ files.
