---
title: Project Conventions Override Generic Best Practices
impact: CRITICAL
impactDescription: Prevents 95% of "but the best practice says..." debates in code review
tags: ctx, conventions, best-practices, pragmatism
---

## Project Conventions Override Generic Best Practices

Generic best practices are starting points, not absolute rules. Teams adopt specific conventions for good reasons: domain requirements, performance constraints, team preferences, or historical decisions. When project conventions conflict with generic guidance, always follow the project's established approach.

**Incorrect (applying generic "early return" pattern against project convention):**

```python
# Project convention: use guard clauses with explicit else blocks for clarity
# Developer applies generic "early return" simplification

def process_order(order):
    if not order.is_valid():
        return None
    if not order.has_items():
        return None
    if order.is_cancelled():
        return None

    return calculate_total(order)
```

**Correct (following project's explicit else block convention):**

```python
# Project convention documented: "Use explicit if-else for business logic clarity"
# This team values explicitness over brevity for audit trails

def process_order(order):
    if not order.is_valid():
        return None
    else:
        if not order.has_items():
            return None
        else:
            if order.is_cancelled():
                return None
            else:
                return calculate_total(order)
```

**Common conflicts:**

- Early returns vs explicit else blocks
- Inline conditionals vs extracted functions
- ORM usage vs raw SQL (some teams mandate one)
- Dependency injection style
- Test naming conventions

**When to propose changes to conventions:**

- Open a discussion with the team first
- Document the reasoning for the change
- Apply consistently across the codebase, not piecemeal

**Benefits:**

- Respects team decisions and domain knowledge
- Avoids religious debates about style
- Simplifications are accepted without friction

**References:**

- Check team wikis, ADRs (Architecture Decision Records)
- Ask maintainers when conventions seem unusual
