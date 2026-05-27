---
title: Use Optional Chaining and Nullish Coalescing
impact: HIGH
impactDescription: Replaces 3-8 lines of null-checking boilerplate with a single expression, reducing nesting by 2-4 levels
tags: flow, optional-chaining, nullish-coalescing, null-checks
---

## Use Optional Chaining and Nullish Coalescing

Deep null-checking creates pyramids of `if` statements that obscure the actual logic. Optional chaining (`?.`) and nullish coalescing (`??`) collapse these checks into readable expressions that clearly show the intent: "get this value, or use a fallback."

**Incorrect (nested null checks):**

```typescript
function getUserCity(user: User | null): string {
  if (user) {
    if (user.address) {
      if (user.address.city) {
        return user.address.city;
      }
    }
  }
  return 'Unknown';
}

function getDisplayName(profile: Profile | null): string {
  let displayName = 'Anonymous';
  if (profile !== null && profile !== undefined) {
    if (profile.nickname !== null && profile.nickname !== undefined) {
      displayName = profile.nickname;
    } else if (profile.firstName !== null && profile.firstName !== undefined) {
      displayName = profile.firstName;
    }
  }
  return displayName;
}
```

**Correct (optional chaining and nullish coalescing):**

```typescript
function getUserCity(user: User | null): string {
  return user?.address?.city ?? 'Unknown';
}

function getDisplayName(profile: Profile | null): string {
  return profile?.nickname ?? profile?.firstName ?? 'Anonymous';
}
```

**Incorrect (Python - verbose None checks):**

```python
def get_config_value(config, section, key, default=None):
    if config is not None:
        section_data = config.get(section)
        if section_data is not None:
            value = section_data.get(key)
            if value is not None:
                return value
    return default
```

**Correct (Python - dictionary chaining):**

```python
def get_config_value(config, section, key, default=None):
    if config is None:
        return default
    return config.get(section, {}).get(key, default)
```

### When NOT to Apply

- When you need to distinguish between `null`, `undefined`, and `false`/`0`/`''` (use explicit checks)
- When each null check has different error handling or logging
- When the falsy-value semantics of `||` are intentionally different from `??`

### Benefits

- Eliminates 3-8 lines of null-checking per access chain
- Reduces nesting by 2-4 levels
- Intent is immediately clear: "access this path or use default"
- Fewer intermediate variables needed
