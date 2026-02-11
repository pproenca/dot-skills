---
title: Use Symbols for Identifiers and Hash Keys
impact: MEDIUM
impactDescription: 1.3-2x faster hash lookups, single allocation per symbol
tags: str, symbols, identifiers, hash-keys
---

## Use Symbols for Identifiers and Hash Keys

String keys are full objects: each lookup computes a hash from every byte of the key, and every literal occurrence may allocate a new String. Symbols are interned and immutable, so the VM allocates each one exactly once and compares them by object ID rather than content. For hashes that are accessed on every request, the difference compounds into measurable throughput gains.

**Incorrect (string keys compared by content each time):**

```ruby
def process_order(params)
  user_id   = params["user_id"]              # hashes every byte of "user_id" on each lookup
  product   = params["product_id"]
  quantity  = params["quantity"]
  coupon    = params["coupon_code"]           # 4 string hashes per call

  order = {
    "status"     => "pending",               # new String allocated for each key
    "total"      => calculate_total(product, quantity, coupon),
    "created_at" => Time.now,
    "user_id"    => user_id
  }

  order["status"] = "confirmed"              # another byte-by-byte hash to find the key
  order
end
```

**Correct (symbol keys compared by identity):**

```ruby
def process_order(params)
  user_id   = params[:user_id]               # integer comparison, no byte hashing
  product   = params[:product_id]
  quantity  = params[:quantity]
  coupon    = params[:coupon_code]

  order = {
    status:     :pending,
    total:      calculate_total(product, quantity, coupon),
    created_at: Time.now,
    user_id:    user_id
  }

  order[:status] = :confirmed
  order
end
```
