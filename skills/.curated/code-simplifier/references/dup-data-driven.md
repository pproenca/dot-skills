---
title: Use Data-Driven Patterns Over Repetitive Conditionals
impact: MEDIUM
impactDescription: Data-driven approaches reduce conditional branches by 60-80% and make adding new cases a one-line change instead of copy-paste
tags: dup, data-driven, conditionals, maps, configuration
---

## Use Data-Driven Patterns Over Repetitive Conditionals

When you have repetitive if/else or switch statements that map inputs to outputs, replace them with data structures like maps, lookup tables, or configuration objects. Data-driven code is easier to extend (add a line, not a branch), easier to test (validate the data structure), and less prone to copy-paste errors.

**Incorrect (repetitive conditionals):**

```typescript
function getStatusColor(status: string): string {
  if (status === 'pending') {
    return '#FFA500';
  } else if (status === 'approved') {
    return '#00FF00';
  } else if (status === 'rejected') {
    return '#FF0000';
  } else if (status === 'cancelled') {
    return '#808080';
  } else if (status === 'processing') {
    return '#0000FF';
  } else if (status === 'completed') {
    return '#00AA00';
  } else {
    return '#000000';
  }
}
// Adding a new status = new branch + risk of typo
```

**Correct (data-driven lookup):**

```typescript
const STATUS_COLORS: Record<string, string> = {
  pending: '#FFA500',
  approved: '#00FF00',
  rejected: '#FF0000',
  cancelled: '#808080',
  processing: '#0000FF',
  completed: '#00AA00',
};

function getStatusColor(status: string): string {
  return STATUS_COLORS[status] ?? '#000000';
}
// Adding a new status = one line in the map
```

**Incorrect (switch statement for validation rules):**

```python
def validate_field(field_type, value):
    if field_type == 'email':
        if not re.match(r'^[\w.-]+@[\w.-]+\.\w+$', value):
            return 'Invalid email format'
    elif field_type == 'phone':
        if not re.match(r'^\d{10}$', value):
            return 'Phone must be 10 digits'
    elif field_type == 'zip':
        if not re.match(r'^\d{5}(-\d{4})?$', value):
            return 'Invalid ZIP code'
    elif field_type == 'ssn':
        if not re.match(r'^\d{3}-\d{2}-\d{4}$', value):
            return 'Invalid SSN format'
    # ... 20 more field types
    return None
```

**Correct (configuration-driven validation):**

```python
FIELD_VALIDATORS = {
    'email': (r'^[\w.-]+@[\w.-]+\.\w+$', 'Invalid email format'),
    'phone': (r'^\d{10}$', 'Phone must be 10 digits'),
    'zip': (r'^\d{5}(-\d{4})?$', 'Invalid ZIP code'),
    'ssn': (r'^\d{3}-\d{2}-\d{4}$', 'Invalid SSN format'),
}

def validate_field(field_type: str, value: str) -> str | None:
    if field_type not in FIELD_VALIDATORS:
        return None

    pattern, error_message = FIELD_VALIDATORS[field_type]
    if not re.match(pattern, value):
        return error_message
    return None
# New field type = one line in FIELD_VALIDATORS
```

**Incorrect (factory with repetitive instantiation):**

```go
func CreateHandler(handlerType string) Handler {
    switch handlerType {
    case "json":
        return &JSONHandler{
            ContentType: "application/json",
            Encoder:     json.Marshal,
        }
    case "xml":
        return &XMLHandler{
            ContentType: "application/xml",
            Encoder:     xml.Marshal,
        }
    case "yaml":
        return &YAMLHandler{
            ContentType: "application/yaml",
            Encoder:     yaml.Marshal,
        }
    // ... more handlers
    }
    return nil
}
```

**Correct (registry pattern):**

```go
type HandlerConfig struct {
    ContentType string
    Encoder     func(any) ([]byte, error)
}

var handlerRegistry = map[string]HandlerConfig{
    "json": {"application/json", json.Marshal},
    "xml":  {"application/xml", xml.Marshal},
    "yaml": {"application/yaml", yaml.Marshal},
}

func CreateHandler(handlerType string) Handler {
    config, ok := handlerRegistry[handlerType]
    if !ok {
        return nil
    }
    return NewHandler(config)
}
// Adding a handler = one line in registry
```

**Incorrect (under-abstraction - missing data-driven opportunity):**

```javascript
function calculateShipping(country) {
  if (country === 'US') return 5.99;
  if (country === 'CA') return 9.99;
  if (country === 'MX') return 12.99;
  if (country === 'UK') return 15.99;
  if (country === 'DE') return 15.99;
  if (country === 'FR') return 15.99;
  if (country === 'JP') return 25.99;
  if (country === 'AU') return 29.99;
  return 35.99; // International
}
// Europe has same price but requires 3 lines
```

**Correct (data structure reveals patterns):**

```javascript
const SHIPPING_RATES = {
  domestic: { US: 5.99 },
  northAmerica: { CA: 9.99, MX: 12.99 },
  europe: { UK: 15.99, DE: 15.99, FR: 15.99, ES: 15.99, IT: 15.99 },
  pacific: { JP: 25.99, AU: 29.99, NZ: 29.99 },
  default: 35.99,
};

function calculateShipping(country) {
  for (const region of Object.values(SHIPPING_RATES)) {
    if (typeof region === 'object' && country in region) {
      return region[country];
    }
  }
  return SHIPPING_RATES.default;
}
// Structure reveals business logic: regions have shared pricing
```

### When NOT to Use Data-Driven

- When branches have complex logic, not just value mapping
- When there are only 2-3 cases and they're unlikely to grow
- When the "data" would be as complex as the code it replaces

### Benefits

- Adding new cases is a configuration change, not code change
- Data can be loaded from external sources (database, config files)
- Easier to test - validate the data structure separately
- Business rules are visible at a glance in the data structure
- Reduces cyclomatic complexity significantly
