---
title: Preserve Public Function Signatures and Types
impact: CRITICAL
impactDescription: API changes break all callers and require coordinated updates across codebases
tags: behave, api, signatures, types, compatibility
---

## Preserve Public Function Signatures and Types

Public APIs are contracts with consumers. Changing parameter order, making required params optional, narrowing accepted types, or modifying return types breaks every caller. Internal simplification must never leak into public interfaces.

**Incorrect (changes parameter order):**

```typescript
// Before: well-established API
function formatDate(date: Date, format: string, locale?: string): string {
  // ...
}

// After "simplification": reordered for "consistency"
function formatDate(format: string, date: Date, locale?: string): string {
  // ...
}
// Breaks: formatDate(new Date(), 'YYYY-MM-DD')
```

**Correct (preserve original signature, simplify internals):**

```typescript
function formatDate(date: Date, format: string, locale?: string): string {
  const loc = locale ?? 'en-US';
  return new Intl.DateTimeFormat(loc, parseFormat(format)).format(date);
}
```

**Incorrect (narrows accepted types):**

```python
# Before: accepts any iterable
def process_items(items: Iterable[str]) -> list[str]:
    return [transform(item) for item in items]

# After "simplification": requires list
def process_items(items: list[str]) -> list[str]:
    return [transform(item) for item in items]
# Breaks: process_items(generator_expression)
```

**Correct (preserves type flexibility):**

```python
def process_items(items: Iterable[str]) -> list[str]:
    return [transform(item) for item in items]
```

**Incorrect (makes required parameter optional):**

```go
// Before: explicit required config
func NewClient(config Config) *Client {
    return &Client{config: config}
}

// After "simplification": optional with default
func NewClient(config ...Config) *Client {
    cfg := Config{}
    if len(config) > 0 {
        cfg = config[0]
    }
    return &Client{config: cfg}
}
// Breaks: compile-time safety, caller may forget config
```

**Correct (preserve required parameter):**

```go
func NewClient(config Config) *Client {
    return &Client{config: config}
}
```

### Benefits

- All existing callers continue working
- No breaking changes in library versions
- Type safety maintained for consumers
- Documentation remains accurate
