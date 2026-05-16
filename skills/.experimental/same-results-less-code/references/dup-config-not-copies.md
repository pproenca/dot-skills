---
title: Replace Many Hardcoded Copies With One Table
impact: HIGH
impactDescription: reduces N copy-pasted definitions to 1 table; eliminates the "I forgot to update one" bug
tags: dup, config, data-driven, table
---

## Replace Many Hardcoded Copies With One Table

When the same shape — a feature flag with its default, a route with its handler, a column with its formatter — appears N times across the code with only the names and values changing, the right form is a single declarative table. Hardcoded copies invite drift (one entry forgotten when a global rule changes), and they hide the *set* of valid entries behind grep results. A table makes the set first-class.

**Incorrect (N copies of the same shape, one per entity):**

```typescript
// In featureFlags.ts:
export function isCheckoutV2Enabled(user: User): boolean {
  if (!isFeatureFlagsLoaded()) return false;
  const flag = remoteConfig.get('checkout_v2');
  if (!flag) return false;
  if (flag.disabled) return false;
  if (flag.allowlist && !flag.allowlist.includes(user.id)) return false;
  return true;
}

export function isNewDashboardEnabled(user: User): boolean {
  if (!isFeatureFlagsLoaded()) return false;
  const flag = remoteConfig.get('new_dashboard');
  if (!flag) return false;
  if (flag.disabled) return false;
  if (flag.allowlist && !flag.allowlist.includes(user.id)) return false;
  return true;
}

export function isBetaPricingEnabled(user: User): boolean { /* same shape again */ }
export function isFastSearchEnabled(user: User): boolean { /* same shape again */ }
// 6+ identical functions. Add a "geo restriction" to flags → edit every function.
```

**Correct (the flag set is data; the logic runs once):**

```typescript
type FlagKey = 'checkout_v2' | 'new_dashboard' | 'beta_pricing' | 'fast_search';

export function isEnabled(key: FlagKey, user: User): boolean {
  if (!isFeatureFlagsLoaded()) return false;
  const flag = remoteConfig.get(key);
  if (!flag) return false;
  if (flag.disabled) return false;
  if (flag.allowlist && !flag.allowlist.includes(user.id)) return false;
  return true;
}
// Adding a flag = adding a string to `FlagKey`.
// Adding a rule (geo restriction) = editing one function. Once.
```

**Common shapes that often live as copies but want to be tables:**

- HTTP routes + handlers (`app.get('/a', handlerA); app.get('/b', handlerB)`) → array of `{path, handler}` rows.
- Permissions per role (`canRead = role === 'admin' || role === 'editor'; canWrite = role === 'admin'`) → matrix table.
- Column definitions for a grid (one component per column with formatter, sort, filter inline) → array of column-descriptor rows.
- Validation rules per field, defaults per environment, error messages per error code.

**Symptoms:**

- Three or more functions/objects with the same shape and one varying token (usually a string key).
- Comments like `// TODO: when adding a flag here, also update X, Y, Z`.
- A grep that returns N matches for a pattern, all near-identical.
- Tests parameterised over the same N entities, asserting the same property of each.

**When NOT to use this pattern:**

- The entries differ in *behaviour*, not just data — keeping them as functions lets each one diverge naturally. Force into a table only when the shape is genuinely stable.

Reference: [Tidy First? — Replace Conditional With Map](https://tidyfirst.substack.com/) (Kent Beck)
