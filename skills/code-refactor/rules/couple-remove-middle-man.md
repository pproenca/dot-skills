---
title: Remove Middle Man When Excessive
impact: CRITICAL
impactDescription: eliminates unnecessary indirection and reduces code bloat
tags: couple, middle-man, delegation, simplification
---

## Remove Middle Man When Excessive

When a class becomes a simple pass-through with too many delegating methods, let clients call the delegate directly. Balance encapsulation with simplicity.

**Incorrect (excessive delegation):**

```typescript
class Person {
  private department: Department

  getDepartmentName(): string { return this.department.getName() }
  getDepartmentCode(): string { return this.department.getCode() }
  getDepartmentBudget(): number { return this.department.getBudget() }
  getDepartmentManager(): Person { return this.department.getManager() }
  getDepartmentLocation(): string { return this.department.getLocation() }
  getDepartmentEmployeeCount(): number { return this.department.getEmployeeCount() }
  // Person becomes a bloated wrapper around Department
}

// Every new Department method requires a new Person method
```

**Correct (expose delegate when appropriate):**

```typescript
class Person {
  private _department: Department

  // Only hide what genuinely needs hiding
  getManager(): Person {
    return this._department.getManager()
  }

  // Expose the delegate for direct access
  get department(): Department {
    return this._department
  }
}

// Client accesses Department directly for detailed queries
function formatDepartmentInfo(person: Person): string {
  const dept = person.department
  return `${dept.getName()} (${dept.getCode()}) - ${dept.getLocation()}`
}

// Person only delegates what makes semantic sense
function getDirectManager(person: Person): Person {
  return person.getManager()
}
```

**Guidelines for balance:**
- Hide navigation that reveals internal structure
- Expose stable, cohesive objects that have their own API
- Count the delegating methods—if they outnumber real methods, reconsider

Reference: [Remove Middle Man](https://refactoring.com/catalog/removeMiddleMan.html)
