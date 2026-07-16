---
title: Use mapValues for value-only dictionary transforms
tags: coll, dictionaries, transformations, hashing
---

## Use mapValues for value-only dictionary transforms

The wrong default for changing only a dictionary's values is rebuilding the whole dictionary — `Dictionary(uniqueKeysWithValues: dict.map { ($0.key, transform($0.value)) })` or a loop/`reduce(into: [:])` that copies every key unchanged. The rebuild re-hashes every key and allocates a new table for what is a value-only transform, and `Dictionary(uniqueKeysWithValues:)` traps at runtime on duplicate keys — a latent crash the moment the key mapping ever produces a collision. `mapValues(_:)` preserves the keys and the table structure in one pass and cannot collide.

**Evidence of violation:** a `Dictionary(uniqueKeysWithValues:)` call, a `reduce(into: [:])`, or a loop building a new dictionary, where every inserted key is the source key passed through unchanged and only the value is transformed. PASS: value-only transforms use `mapValues(_:)` (or `compactMapValues(_:)` when dropping nils), or no dictionary transform exists in the changed code. N/A: any key is transformed, filtered, or merged — the rebuild is then doing key work `mapValues` cannot express.

**Incorrect (re-hashes every key and traps if the mapping ever collides):**

```swift
var products = [
    "Laptop": 1200.00,
    "Smartphone": 800.00,
    "Headphones": 150.00
]

let discountedProducts = Dictionary(
    uniqueKeysWithValues: products.map { ($0.key, $0.value * 0.90) }
)
```

**Correct (keys and table structure preserved, single pass):**

```swift
var products = [
    "Laptop": 1200.00,
    "Smartphone": 800.00,
    "Headphones": 150.00
]

let discountedProducts = products.mapValues { price in
    price * 0.90
}
```
