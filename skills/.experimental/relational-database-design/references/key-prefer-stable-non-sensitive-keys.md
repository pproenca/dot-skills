---
title: Prefer a key value that rarely changes and exposes nothing sensitive
tags: key, stability, privacy
---

## Prefer a key value that rarely changes and exposes nothing sensitive

The wrong default is to promote a convenient real-world value — a Social Security number, an email address, a phone number — to primary key. Two candidate-key elements rule these out: a key's value should change only in rare or extreme cases, and it must not breach the organization's security or privacy rules. An email or phone changes; a national ID is sensitive and, once it is the key, it propagates into every related table as a foreign key, spreading the exposure and making any change cascade everywhere.

When the natural identifier is unstable or sensitive, use a system-assigned surrogate key as the primary key and keep the natural value as an ordinary field (enforcing uniqueness on it as an alternate key if the business requires it).

**Incorrect (sensitive, mutable value as the key — copied into every child table):**

```sql
CREATE TABLE Employees (
  SocialSecurityNumber TEXT PRIMARY KEY,   -- sensitive; propagates as an FK everywhere
  EmpFirstName TEXT
);
```

**Correct (stable surrogate key; natural value kept as a constrained field):**

```sql
CREATE TABLE Employees (
  EmployeeID  INTEGER PRIMARY KEY,          -- stable surrogate
  EmpFirstName TEXT,
  TaxIDNumber TEXT UNIQUE                    -- alternate key, not the identifier
);
```
