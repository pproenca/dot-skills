---
title: Preserve Whole Object Instead of Fields
impact: CRITICAL
impactDescription: reduces parameter coupling and simplifies method signatures
tags: couple, preserve-object, parameters, encapsulation
---

## Preserve Whole Object Instead of Fields

When you extract several values from an object and pass them as parameters, pass the whole object instead. This reduces coupling to the object's internal structure.

**Incorrect (extracting multiple fields):**

```typescript
function isWithinDeliveryRange(
  customerLat: number,
  customerLng: number,
  customerCity: string,
  customerZipCode: string
): boolean {
  const warehouseLocation = getWarehouse(customerCity)
  const distance = calculateDistance(customerLat, customerLng, warehouseLocation)
  return distance < 50 && isServicedZipCode(customerZipCode)
}

// Calling code extracts fields manually
const customer = getCustomer(id)
const canDeliver = isWithinDeliveryRange(
  customer.address.latitude,
  customer.address.longitude,
  customer.address.city,
  customer.address.zipCode
)  // If Address structure changes, this breaks
```

**Correct (passing whole object):**

```typescript
interface Address {
  latitude: number
  longitude: number
  city: string
  zipCode: string
}

function isWithinDeliveryRange(address: Address): boolean {
  const warehouseLocation = getWarehouse(address.city)
  const distance = calculateDistance(address.latitude, address.longitude, warehouseLocation)
  return distance < 50 && isServicedZipCode(address.zipCode)
}

// Calling code is simpler and decoupled from Address structure
const customer = getCustomer(id)
const canDeliver = isWithinDeliveryRange(customer.address)

// If Address gains a 'region' field, only isWithinDeliveryRange changes
```

**When NOT to use this pattern:**
- You only need one or two fields and don't want to create a dependency on the whole type
- The receiving function would have to import the type from a distant module
- The object is mutable and you want to work with a snapshot of values

Reference: [Preserve Whole Object](https://refactoring.com/catalog/preserveWholeObject.html)
