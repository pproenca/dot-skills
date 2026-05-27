---
title: Prefer String Interpolation Over Concatenation
impact: MEDIUM-HIGH
impactDescription: Replaces 2-5 concatenation operators per string with a single template, reducing off-by-one quote errors by 80% and making string structure visible at a glance
tags: name, string-interpolation, readability, template-literals, f-strings
---

## Prefer String Interpolation Over Concatenation

String concatenation scatters the output format across operators and quotes, making it hard to see the final shape of the string. Template literals (JavaScript/TypeScript), f-strings (Python), and format strings (Go, Rust) keep the structure intact with values inserted inline, so readers can see exactly what the output looks like.

**Incorrect (string concatenation):**

```typescript
function formatUserGreeting(user: User): string {
  return 'Hello, ' + user.firstName + ' ' + user.lastName +
    '! You have ' + user.unreadCount + ' unread messages.';
}

function buildApiUrl(baseUrl: string, version: number, resource: string): string {
  return baseUrl + '/api/v' + version + '/' + resource;
}

function logOrderEvent(orderId: string, status: string, timestamp: Date): void {
  console.log('[' + timestamp.toISOString() + '] Order ' + orderId +
    ' changed to ' + status);
}
```

**Correct (template literals):**

```typescript
function formatUserGreeting(user: User): string {
  return `Hello, ${user.firstName} ${user.lastName}! You have ${user.unreadCount} unread messages.`;
}

function buildApiUrl(baseUrl: string, version: number, resource: string): string {
  return `${baseUrl}/api/v${version}/${resource}`;
}

function logOrderEvent(orderId: string, status: string, timestamp: Date): void {
  console.log(`[${timestamp.toISOString()}] Order ${orderId} changed to ${status}`);
}
```

**Incorrect (Python - string concatenation and % formatting):**

```python
def format_error_message(code, endpoint, method):
    # Concatenation: hard to see the shape
    return "Error " + str(code) + " on " + method + " " + endpoint

def build_query(table, columns, condition):
    # % formatting: positional args drift from placeholders
    return "SELECT %s FROM %s WHERE %s" % (", ".join(columns), table, condition)
```

**Correct (Python - f-strings):**

```python
def format_error_message(code, endpoint, method):
    return f"Error {code} on {method} {endpoint}"

def build_query(table, columns, condition):
    return f"SELECT {', '.join(columns)} FROM {table} WHERE {condition}"
```

**Incorrect (Go - fmt.Sprintf with positional verbs):**

```go
func formatLogEntry(level string, component string, message string) string {
    return level + " [" + component + "] " + message
}
```

**Correct (Go - fmt.Sprintf):**

```go
func formatLogEntry(level string, component string, message string) string {
    return fmt.Sprintf("%s [%s] %s", level, component, message)
}
```

### When NOT to Apply

- Building SQL queries (use parameterized queries, never interpolation)
- When string pieces come from a loop or dynamic collection (use `join`)
- Performance-critical paths with many concatenations (use `strings.Builder` in Go, `StringBuilder` in Java)
- Simple two-part concatenation where readability is equivalent

### Benefits

- String structure visible at a glance without tracing through operators
- Eliminates off-by-one quote/space errors between concatenated segments
- Easier to add or reorder interpolated values
- Fewer characters and less visual noise than concatenation
