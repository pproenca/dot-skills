---
title: Prefer Positive Conditions Over Double Negatives
impact: HIGH
impactDescription: Positive conditions reduce cognitive parsing time by 30-40% and cut logical errors in boolean expressions by 25%
tags: flow, conditions, boolean, readability, naming
---

## Prefer Positive Conditions Over Double Negatives

The human brain processes positive statements faster than negative ones. Double negatives require mental inversion that slows comprehension and increases error rates. Write conditions that state what IS true, not what ISN'T NOT true.

**Incorrect (double negatives):**

```typescript
if (!user.isNotVerified) {
  sendWelcomeEmail(user);
}

if (!isNotEmpty(list)) {
  return 'No items';
}

if (!config.disableCache !== false) {
  useCache();
}

const cannotProceed = !isValid || !hasPermission;
if (!cannotProceed) {
  proceed();
}
```

**Correct (positive conditions):**

```typescript
if (user.isVerified) {
  sendWelcomeEmail(user);
}

if (isEmpty(list)) {
  return 'No items';
}

if (config.enableCache) {
  useCache();
}

const canProceed = isValid && hasPermission;
if (canProceed) {
  proceed();
}
```

**Incorrect (negative function names):**

```typescript
function isNotAdmin(user: User): boolean {
  return user.role !== 'admin';
}

function hasNoErrors(result: Result): boolean {
  return result.errors.length === 0;
}

function isDisabled(feature: Feature): boolean {
  return !feature.enabled;
}

// Usage becomes confusing
if (!isNotAdmin(user) && !isDisabled(feature)) {
  showAdminPanel();
}
```

**Correct (positive function names):**

```typescript
function isAdmin(user: User): boolean {
  return user.role === 'admin';
}

function isValid(result: Result): boolean {
  return result.errors.length === 0;
}

function isEnabled(feature: Feature): boolean {
  return feature.enabled;
}

// Usage is clear
if (isAdmin(user) && isEnabled(feature)) {
  showAdminPanel();
}
```

**Incorrect (negative variable names):**

```typescript
const notFound = items.indexOf(target) === -1;
if (!notFound) {
  processItem(target);
}

const isInvalid = !schema.validate(data);
if (!isInvalid) {
  save(data);
}

let hideModal = true;
if (!hideModal) {
  modal.show();
}
```

**Correct (positive variable names):**

```typescript
const found = items.indexOf(target) !== -1;
if (found) {
  processItem(target);
}

// Or even better with includes:
if (items.includes(target)) {
  processItem(target);
}

const isValid = schema.validate(data);
if (isValid) {
  save(data);
}

let showModal = false;
if (showModal) {
  modal.show();
}
```

**Incorrect (confusing boolean logic):**

```typescript
// What does this even mean?
if (!(user.inactive || !user.emailConfirmed) && !config.skipValidation) {
  allowAccess();
}
```

**Correct (clear positive logic):**

```typescript
const isActiveUser = !user.inactive;
const hasConfirmedEmail = user.emailConfirmed;
const shouldValidate = !config.skipValidation;

if (isActiveUser && hasConfirmedEmail && shouldValidate) {
  allowAccess();
}

// Or extract to a well-named function
function canAccessSystem(user: User, config: Config): boolean {
  const isActiveUser = !user.inactive;
  const hasConfirmedEmail = user.emailConfirmed;
  const requiresValidation = !config.skipValidation;

  return isActiveUser && hasConfirmedEmail && requiresValidation;
}
```

### Refactoring Patterns

| Negative Form | Positive Form |
|--------------|---------------|
| `!isNotValid` | `isValid` |
| `!isEmpty` | `hasItems` |
| `!isDisabled` | `isEnabled` |
| `notFound === false` | `found === true` or just `found` |
| `!user.inactive` | `user.isActive` (may need data change) |
| `errors.length === 0` | `isValid` or `hasNoErrors` |

### Benefits

- Conditions read like natural language
- Fewer mental inversions when reading
- Reduced chance of logic errors
- Easier to combine conditions with && and ||
- Self-documenting variable and function names

### When NOT to Apply

- When the negative is the natural domain concept (e.g., `isDeprecated`, `wasDeleted`)
- When matching an external API that uses negative naming
- In guard clauses where `if (!x) return` is idiomatic
- When `!condition` is clearer than creating a new named positive
