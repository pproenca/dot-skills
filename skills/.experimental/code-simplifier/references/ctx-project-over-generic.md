---
title: Project Conventions Override Generic Best Practices
impact: CRITICAL
impactDescription: Prevents 95% of "but the best practice says..." debates in code review
tags: ctx, conventions, best-practices, pragmatism
---

## Project Conventions Override Generic Best Practices

Generic best practices are starting points, not absolute rules. Teams adopt specific conventions for good reasons: domain requirements, performance constraints, team preferences, or historical decisions. When project conventions conflict with generic guidance, always follow the project's established approach.

**Incorrect (applying generic "arrow function" pattern against project convention):**

```javascript
// Project convention: use function declarations for top-level functions
// Developer applies generic "arrow functions are cleaner" simplification

// Existing file uses function declarations throughout
function validateEmail(email) {
  return email.includes("@");
}

// Developer "simplifies" new additions to arrow functions
const validatePhone = (phone) => /^\d{10}$/.test(phone);
const validateAge = (age) => age >= 0 && age <= 150;
```

**Correct (following project's function declaration convention):**

```javascript
// Project convention documented: "Use function declarations for all named functions"
// This team prefers hoisting behavior and consistent style

function validateEmail(email) {
  return email.includes("@");
}

function validatePhone(phone) {
  return /^\d{10}$/.test(phone);
}

function validateAge(age) {
  return age >= 0 && age <= 150;
}
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
