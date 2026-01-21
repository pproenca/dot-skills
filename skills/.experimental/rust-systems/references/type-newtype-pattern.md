---
title: Use Newtype Pattern for Type Safety
impact: MEDIUM
impactDescription: Newtypes prevent mixing semantically different values of the same underlying type
tags: type, newtype, safety, wrapper
---

## Use Newtype Pattern for Type Safety

Wrap primitive types in tuple structs (newtypes) when they represent distinct semantic concepts that shouldn't be mixed.

**Incorrect (problematic pattern):**

```rust
// All u32 - easy to mix up accidentally
fn create_user(user_id: u32, org_id: u32, role_id: u32) { ... }

// Oops - arguments in wrong order, compiles fine
create_user(org_id, user_id, role_id);

// Which one is which?
let chunk_size: u32 = 32;
let compression_level: u32 = 9;
let retry_count: u32 = 3;
```

**Correct (recommended pattern):**

```rust
// Newtypes - distinct types that can't be mixed
#[derive(Copy, Clone, Debug, PartialEq, Eq, Hash)]
pub struct UserId(pub u32);

#[derive(Copy, Clone, Debug, PartialEq, Eq, Hash)]
pub struct OrgId(pub u32);

#[derive(Copy, Clone, Debug, PartialEq, Eq, Hash)]
pub struct RoleId(pub u32);

fn create_user(user_id: UserId, org_id: OrgId, role_id: RoleId) { ... }

// Compile error - types don't match
create_user(OrgId(1), UserId(2), RoleId(3));

// Correct usage
create_user(UserId(1), OrgId(2), RoleId(3));
```

```rust
// Newtype with validation
#[derive(Copy, Clone, Debug)]
pub struct ChunkSizePo2(u32);

impl ChunkSizePo2 {
    pub fn new(n: u32) -> Result<Self, &'static str> {
        if n.count_ones() != 1 {
            return Err("must be power of two");
        }
        Ok(Self(n))
    }

    pub fn get(self) -> u32 {
        self.0
    }
}
```

**When NOT to use:**
- When you need transparent interop with the underlying type
- Simple internal values where type confusion is unlikely
