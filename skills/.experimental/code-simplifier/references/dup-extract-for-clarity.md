---
title: Extract Only When It Improves Clarity
impact: MEDIUM
impactDescription: Poor extractions increase code navigation time by 40-60% and obscure business logic behind generic names
tags: dup, clarity, readability, naming, abstraction
---

## Extract Only When It Improves Clarity

Extraction should make code easier to understand, not just shorter. If the extracted function name doesn't communicate intent better than the original code, keep the code inline. A helper called `processData()` or `handleStuff()` forces readers to look inside anyway. The goal is comprehension, not line count reduction.

**Incorrect (extraction hides intent behind vague name):**

```typescript
async function checkout(cart: Cart): Promise<Order> {
  const order = await processCartData(cart);
  await finalizeOrder(order);
  return order;
}

// What does this do? Must read implementation
async function processCartData(cart: Cart): Promise<Order> {
  const items = cart.items.filter(item => item.quantity > 0);
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const tax = subtotal * 0.08;
  return { items, subtotal, tax, total: subtotal + tax };
}
```

**Correct (inline code that speaks for itself):**

```typescript
async function checkout(cart: Cart): Promise<Order> {
  const items = cart.items.filter(item => item.quantity > 0);
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const tax = subtotal * 0.08;

  const order: Order = { items, subtotal, tax, total: subtotal + tax };
  await this.orderRepository.save(order);
  await this.emailService.sendConfirmation(order);

  return order;
}
// Business logic is immediately visible
```

**Incorrect (extracting trivial operations):**

```python
def create_report(data):
    filtered = filter_empty_records(data)
    sorted_data = sort_by_date(filtered)
    return format_as_table(sorted_data)

def filter_empty_records(data):
    return [r for r in data if r]  # One-liner hidden behind function

def sort_by_date(data):
    return sorted(data, key=lambda x: x['date'])  # One-liner hidden

def format_as_table(data):
    # Actually complex - this extraction is justified
    ...
```

**Correct (extract complex, inline simple):**

```python
def create_report(data):
    records = [r for r in data if r]  # Filter empty - obvious
    records.sort(key=lambda x: x['date'])  # Sort by date - obvious

    return format_as_table(records)  # Complex formatting - good extraction

def format_as_table(records):
    """Convert records to ASCII table with headers and alignment."""
    # 30 lines of table formatting logic
    ...
```

**Incorrect (generic names that require reading implementation):**

```go
func HandleRequest(r *Request) (*Response, error) {
    if err := doValidation(r); err != nil {
        return nil, err
    }
    result := doProcessing(r)
    return doFormatting(result), nil
}

func doValidation(r *Request) error { ... }
func doProcessing(r *Request) *Result { ... }
func doFormatting(r *Result) *Response { ... }
// "do" prefix is a code smell - names don't describe behavior
```

**Correct (names that describe actual behavior):**

```go
func HandleRequest(r *Request) (*Response, error) {
    if err := validateRequestSchema(r); err != nil {
        return nil, err
    }
    inventory := checkInventoryLevels(r.Items)
    return formatInventoryResponse(inventory), nil
}

func validateRequestSchema(r *Request) error { ... }
func checkInventoryLevels(items []Item) *InventoryStatus { ... }
func formatInventoryResponse(status *InventoryStatus) *Response { ... }
// Each name tells you what the function does without reading it
```

**Incorrect (DRY obsession - extracting unrelated similar code):**

```javascript
// "These both iterate arrays, let's extract!"
function processItems(items, processor) {
  const results = [];
  for (const item of items) {
    results.push(processor(item));
  }
  return results;
}

// Callers now obscure their intent
const prices = processItems(products, p => p.price);
const names = processItems(users, u => u.name);
```

**Correct (use language features, keep intent clear):**

```javascript
const prices = products.map(p => p.price);
const names = users.map(u => u.name);
// Array.map is universally understood - no custom abstraction needed
```

### Signs That Extraction Improves Clarity

- The function name explains a "why" that code alone doesn't convey
- The function encapsulates a business rule that has a domain name
- Readers can understand the calling code without reading the helper
- The extracted logic is cohesive and represents one concept

### Signs That Extraction Hurts Clarity

- You struggle to name the function (vague names like `process`, `handle`, `do`)
- The function name is longer than the code it contains
- Readers still need to check the implementation to understand the caller
- The extraction groups unrelated operations

### Benefits

- Code reads like documentation of business logic
- Reduced navigation between files and functions
- Function names serve as accurate documentation
- New team members understand code faster
