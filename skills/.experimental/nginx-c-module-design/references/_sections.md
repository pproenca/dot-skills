# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Exposure Decisions (expose)

**Impact:** CRITICAL
**Description:** Deciding what to make configurable vs hardcode is the most consequential design choice — wrong exposure creates security holes, admin confusion, or forces workarounds when needed settings are compiled in.

## 2. Naming Conventions (naming)

**Impact:** CRITICAL
**Description:** Directive naming is the module's public API — inconsistent prefixes, wrong verb/noun patterns, or unclear grouping makes a working module look broken and untrustworthy to nginx admins.

## 3. Directive Types (type)

**Impact:** HIGH
**Description:** Choosing the wrong directive type (flag vs enum, raw number vs time unit, string vs enum slot) creates confusing syntax that fights nginx admin muscle memory.

## 4. Scope Design (scope)

**Impact:** HIGH
**Description:** Wrong scope placement breaks config inheritance, prevents per-location tuning, or makes directives silently ignored — the admin sees no error but the directive has no effect.

## 5. Default Values (default)

**Impact:** MEDIUM-HIGH
**Description:** Bad defaults cause zero-config deployments to be insecure, unreliable, or silently degraded — every directive must work safely when the admin provides no explicit value.

## 6. Validation & Error Messages (valid)

**Impact:** MEDIUM
**Description:** Poor validation defers errors from config-test time to request time, and unhelpful messages waste hours of admin debugging — parse-time validation with actionable messages is essential.

## 7. Variable Design (var)

**Impact:** MEDIUM
**Description:** Exposing the wrong data as nginx variables creates misleading diagnostics, performance traps from expensive evaluation, or admin confusion about what belongs in directives vs variables.

## 8. Evolution & Compatibility (compat)

**Impact:** LOW-MEDIUM
**Description:** Breaking directive changes without deprecation paths destroy admin trust, break automation tooling, and force emergency config rewrites during upgrades.
