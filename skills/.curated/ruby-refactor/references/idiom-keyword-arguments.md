---
title: Use Keyword Arguments for Clarity
impact: HIGH
impactDescription: self-documents call sites, prevents argument order bugs
tags: idiom, keyword-arguments, readability, api-design
---

## Use Keyword Arguments for Clarity

Positional arguments with more than two parameters become unreadable at the call site. Callers must remember exact ordering, and boolean flags are especially cryptic. Keyword arguments make every call self-documenting and immune to transposition bugs.

**Incorrect (positional arguments obscure meaning):**

```ruby
class UserService
  def create_user(first_name, last_name, admin, verified, age)
    User.new(
      first_name: first_name,
      last_name: last_name,
      admin: admin,
      verified: verified,
      age: age
    )
  end
end

# caller has no idea what true, false, 25 mean
service.create_user("John", "Doe", true, false, 25)
```

**Correct (keyword arguments self-document every call):**

```ruby
class UserService
  def create_user(first_name:, last_name:, admin:, verified:, age:)  # required keywords, no defaults
    User.new(
      first_name: first_name,
      last_name: last_name,
      admin: admin,
      verified: verified,
      age: age
    )
  end
end

# call site reads like documentation
service.create_user(first_name: "John", last_name: "Doe", admin: true, verified: false, age: 25)
```
