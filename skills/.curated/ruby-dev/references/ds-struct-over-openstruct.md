---
title: Use Struct Over OpenStruct
impact: MEDIUM
impactDescription: Struct is 10-50x faster to instantiate than OpenStruct
tags: ds, struct, openstruct, allocation
---

## Use Struct Over OpenStruct

`OpenStruct` dynamically defines methods via `method_missing` and `define_method` on each new key, making instantiation 10-50x slower than `Struct`. Struct predefines its accessors at class creation time, resulting in fixed-layout objects the VM can optimize.

**Incorrect (dynamic method definition on each instantiation):**

```ruby
def parse_api_response(raw_data)
  raw_data.map do |entry|
    OpenStruct.new(                      # Dynamically defines methods per key
      name: entry["name"],
      email: entry["email"],
      role: entry["role"],
      created_at: Time.parse(entry["created_at"])
    )
  end
end
```

**Correct (fixed layout, precompiled accessors):**

```ruby
UserRecord = Struct.new(:name, :email, :role, :created_at, keyword_init: true)

def parse_api_response(raw_data)
  raw_data.map do |entry|
    UserRecord.new(
      name: entry["name"],
      email: entry["email"],
      role: entry["role"],
      created_at: Time.parse(entry["created_at"])
    )
  end
end
```

**Alternative (Data class in Ruby 3.2+):**

```ruby
UserRecord = Data.define(:name, :email, :role, :created_at)

# Data objects are immutable by design
record = UserRecord.new(name: "Jane", email: "jane@example.com", role: "admin", created_at: Time.now)
```
