---
title: Match Existing Code Style in File and Project
impact: CRITICAL
impactDescription: Reduces code review friction by 80% through consistent patterns
tags: ctx, consistency, patterns, style
---

## Match Existing Code Style in File and Project

Every codebase develops its own idioms and patterns over time. Simplifications that introduce foreign patterns, even if technically better, create jarring inconsistencies. Before simplifying, study the surrounding code to understand naming conventions, error handling approaches, and structural patterns already in use.

**Incorrect (introducing arrow functions in a file using function declarations):**

```javascript
// Existing file uses function declarations throughout
function validateEmail(email) {
  return email.includes("@");
}

function validatePhone(phone) {
  return phone.length === 10;
}

// New simplified code introduces arrow functions
const validateName = (name) => name.length > 0;

const validateAge = (age) => age >= 0 && age <= 150;
```

**Correct (matching existing function declaration pattern):**

```javascript
// Existing file uses function declarations throughout
function validateEmail(email) {
  return email.includes("@");
}

function validatePhone(phone) {
  return phone.length === 10;
}

// Simplified code follows existing pattern
function validateName(name) {
  return name.length > 0;
}

function validateAge(age) {
  return age >= 0 && age <= 150;
}
```

**Patterns to observe:**

- Function declaration style (arrow vs function keyword)
- Naming conventions (camelCase, snake_case, prefixes)
- Import organization and grouping
- Error handling approach (try/catch, Result types, error callbacks)
- Comment style and documentation format

**When NOT to use:**

- When explicitly refactoring to modernize the entire file
- When existing patterns are acknowledged anti-patterns by the team

**Benefits:**

- Code reads as if written by one author
- Easier to maintain and understand
- Reduces cognitive load during code review
