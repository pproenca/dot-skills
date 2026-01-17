---
title: Examine System Boundaries
impact: HIGH
impactDescription: 70%+ of bugs occur at boundaries; interfaces are high-risk areas
tags: rca, boundaries, interfaces, integration, edge-cases
---

## Examine System Boundaries

Most bugs occur at boundaries: between modules, services, systems, or data formats. When debugging, pay special attention to these interfaces where assumptions from one side may not match the other.

**Incorrect (ignoring boundaries):**

```python
# Bug: User data sometimes corrupted after save

# Developer examines UserService internal logic exhaustively
class UserService:
    def save_user(self, user):
        validated = self.validate(user)  # Checks this...
        normalized = self.normalize(validated)  # And this...
        return self.repository.save(normalized)  # Glances at this

# 4 hours later: "Internal logic is perfect, don't understand"
# Never examined the boundary with repository
```

**Correct (examine boundaries first):**

```python
# Bug: User data sometimes corrupted after save

class UserService:
    def save_user(self, user):
        validated = self.validate(user)
        normalized = self.normalize(validated)

        # BOUNDARY EXAMINATION: Service → Repository
        print("Sending to repository:", {
            "type": type(normalized).__name__,
            "data": normalized.__dict__
        })

        result = self.repository.save(normalized)

        # BOUNDARY EXAMINATION: Repository → Service
        print("Received from repository:", {
            "type": type(result).__name__,
            "data": result.__dict__ if result else None
        })

        return result

# Output reveals:
# Sending: {"name": "José García", "email": "jose@..."}
# Received: {"name": "Jos\u00e9 Garc\u00eda", "email": "jose@..."}
# BUG: Repository driver encoding issue at boundary!
```

**Common boundary types to examine:**

```text
┌─────────────────────────────────────────────────────────────┐
│  Frontend ←──────────────────────────────────→ API         │
│            • JSON serialization                             │
│            • Date format conversion                         │
│            • Type coercion (string→number)                  │
├─────────────────────────────────────────────────────────────┤
│  Service ←───────────────────────────────────→ Database    │
│            • ORM mapping                                    │
│            • Encoding/character sets                        │
│            • Null handling                                  │
├─────────────────────────────────────────────────────────────┤
│  Your Code ←─────────────────────────────────→ Library     │
│            • Version differences                            │
│            • Optional vs required params                    │
│            • Error handling conventions                     │
├─────────────────────────────────────────────────────────────┤
│  System ←────────────────────────────────────→ File/Network│
│            • Line endings (CRLF vs LF)                      │
│            • Timeouts                                       │
│            • Path formats                                   │
└─────────────────────────────────────────────────────────────┘
```

**When NOT to use this pattern:**
- Bug is clearly in pure business logic
- Single-module applications with few boundaries

Reference: [Cornell CS312 - Debugging](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)
