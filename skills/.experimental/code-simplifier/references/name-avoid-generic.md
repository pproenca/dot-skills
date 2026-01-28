---
title: Avoid Generic Names
impact: MEDIUM-HIGH
impactDescription: Generic names like data, info, temp force readers to trace through code to understand meaning, adding 10-30 seconds per occurrence
tags: name, specificity, clarity, readability, context
---

## Avoid Generic Names

Names like `data`, `info`, `temp`, `item`, `result`, `value`, and `thing` tell you nothing about what they contain. They force readers to trace through the code to understand what they represent. Replace generic names with specific ones that describe the actual content or purpose.

**Incorrect (generic names):**

```typescript
// Bad: What kind of data? What info? Result of what?
async function process(data: any): Promise<any> {
  const info = await fetchInfo(data.id);
  const result = transform(info);
  const temp = validate(result);
  return temp;
}

// Bad: What items? What values?
function handleItems(items: any[]) {
  for (const item of items) {
    const value = item.getValue();
    doSomething(value);
  }
}
```

**Correct (specific names):**

```typescript
// Good: Names describe actual content
async function processOrder(orderRequest: OrderRequest): Promise<OrderConfirmation> {
  const inventoryStatus = await fetchInventoryStatus(orderRequest.productId);
  const pricedOrder = applyPricing(inventoryStatus);
  const validatedOrder = validateOrder(pricedOrder);
  return validatedOrder;
}

// Good: Names reveal what's being processed
function applyDiscounts(lineItems: LineItem[]) {
  for (const lineItem of lineItems) {
    const originalPrice = lineItem.getPrice();
    applyDiscount(originalPrice);
  }
}
```

**Incorrect (Python - vague naming):**

```python
# Bad: What object? What info? Temp for what?
def process(obj):
    data = obj.get_data()
    info = parse(data)
    temp = []
    for thing in info:
        if thing.is_valid():
            temp.append(thing)
    result = format(temp)
    return result
```

**Correct (Python - descriptive naming):**

```python
# Good: Every name tells a story
def filter_active_subscriptions(customer):
    subscription_records = customer.get_subscriptions()
    parsed_subscriptions = parse_subscription_data(subscription_records)
    active_subscriptions = []
    for subscription in parsed_subscriptions:
        if subscription.is_active():
            active_subscriptions.append(subscription)
    formatted_report = format_subscription_report(active_subscriptions)
    return formatted_report
```

**Incorrect (Go - placeholder names):**

```go
// Bad: What response? What value? Temp for?
func handle(w http.ResponseWriter, r *http.Request) {
    data := getData(r)
    if data == nil {
        return
    }
    result := process(data)
    temp := format(result)
    value := validate(temp)
    respond(w, value)
}
```

**Correct (Go - meaningful names):**

```go
// Good: Clear data flow
func handleUserProfileRequest(w http.ResponseWriter, r *http.Request) {
    userCredentials := extractCredentials(r)
    if userCredentials == nil {
        return
    }
    profileData := loadUserProfile(userCredentials)
    formattedProfile := formatProfileResponse(profileData)
    validatedResponse := validateResponse(formattedProfile)
    sendJSONResponse(w, validatedResponse)
}
```

### Worst Offenders

| Generic Name | What to Ask | Better Alternative |
|--------------|-------------|-------------------|
| `data` | Data about what? | `userData`, `sensorReadings`, `configPayload` |
| `info` | Information about what? | `userInfo`, `connectionInfo`, `errorDetails` |
| `temp` | Temporary what? | `pendingChanges`, `intermediateSum`, `bufferContent` |
| `item` | Item from what collection? | `cartItem`, `menuOption`, `searchResult` |
| `result` | Result of what operation? | `queryResult`, `validationResult`, `calculatedTotal` |
| `value` | Value of what? | `inputValue`, `configValue`, `computedScore` |
| `list` | List of what? | `userList`, `errorMessages`, `availableOptions` |
| `obj` / `object` | Object representing what? | `userProfile`, `paymentRecord`, `configSettings` |
| `str` / `string` | String containing what? | `userName`, `errorMessage`, `formattedDate` |
| `num` / `number` | Number representing what? | `retryCount`, `totalPrice`, `userAge` |

### When NOT to Apply

- Truly generic utilities (e.g., `stringify(value)` in a serialization library)
- Short-lived variables in tiny scopes (3-5 lines max)
- Generic type parameters (`T`, `K`, `V` are conventional)
- Language-specific idioms (e.g., `_` for unused variables)

### Benefits

- Code reads like documentation
- No need to trace variable origins
- Bugs become obvious when wrong data flows through
- Refactoring is safer with distinct names
- Code reviews catch misuse immediately
