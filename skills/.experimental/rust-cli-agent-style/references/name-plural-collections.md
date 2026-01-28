---
title: Use plural names for collections
impact: LOW
impactDescription: Natural English naming for collection types
tags: name, variables, collections
---

# Use plural names for collections

Variables holding collections should use plural names.

## Why This Matters

- Reads naturally in loops
- Clear multiplicity indication
- Distinguishes from single items
- Consistent convention

**Incorrect (avoid this pattern):**

```rust
let event: Vec<Event> = vec![];
let user: HashSet<User> = HashSet::new();
let message: VecDeque<Message> = VecDeque::new();

for e in event {  // Confusing - "event" sounds singular
    process(e);
}
```

**Correct (recommended):**

```rust
let events: Vec<Event> = vec![];
let users: HashSet<User> = HashSet::new();
let messages: VecDeque<Message> = VecDeque::new();

for event in events {  // Clear - iterating "events", each is "event"
    process(event);
}

for user in &users {
    notify(user);
}
```

## Iterator Naming

```rust
// Collection is plural
let items: Vec<Item> = get_items();

// Iterator variable is singular
for item in items {
    println!("{}", item);
}

// With enumerate
for (index, item) in items.iter().enumerate() {
    println!("{}: {}", index, item);
}

// Filtered collections
let active_users: Vec<&User> = users
    .iter()
    .filter(|u| u.is_active())
    .collect();
```

## Maps and Associative Collections

```rust
// Plural for the collection concept
let user_by_id: HashMap<UserId, User> = HashMap::new();
let permissions_by_role: HashMap<Role, Vec<Permission>> = HashMap::new();

// Or describe the mapping
let id_to_user: HashMap<UserId, User> = HashMap::new();
```
