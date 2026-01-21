---
title: Use Dict for O(1) Key-Value Lookup
impact: CRITICAL
impactDescription: O(n) to O(1) lookup
tags: ds, dict, lookup, mapping, performance
---

## Use Dict for O(1) Key-Value Lookup

Searching a list of tuples or objects for a key is O(n). Converting to a dict provides O(1) lookup by key, critical for repeated access patterns.

**Incorrect (O(n) search per lookup):**

```python
def get_user_emails(user_ids: list[int], users: list[tuple[int, str]]) -> list[str]:
    emails = []
    for user_id in user_ids:
        for uid, email in users:  # O(n) scan for each user_id
            if uid == user_id:
                emails.append(email)
                break
    return emails
```

**Correct (O(1) lookup):**

```python
def get_user_emails(user_ids: list[int], users: list[tuple[int, str]]) -> list[str]:
    user_map = {uid: email for uid, email in users}  # One-time O(n) conversion
    return [user_map[user_id] for user_id in user_ids if user_id in user_map]
```

**Alternative (with default value):**

```python
def get_user_emails(user_ids: list[int], users: list[tuple[int, str]]) -> list[str]:
    user_map = dict(users)
    return [user_map.get(user_id, "unknown@example.com") for user_id in user_ids]
```

Reference: [Python Data Structures](https://docs.python.org/3/tutorial/datastructures.html#dictionaries)
