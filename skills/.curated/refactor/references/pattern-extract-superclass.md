---
title: Extract Superclass for Common Behavior
impact: MEDIUM-HIGH
impactDescription: eliminates duplication across related classes
tags: pattern, extract-superclass, inheritance, duplication
---

## Extract Superclass for Common Behavior

When two classes have similar features, extract common behavior into a superclass. This is appropriate when the classes represent variations of the same concept.

**Incorrect (duplicated behavior across classes):**

```typescript
class Employee {
  name: string
  annualSalary: number

  constructor(name: string, annualSalary: number) {
    this.name = name
    this.annualSalary = annualSalary
  }

  getMonthlyCost(): number {
    return this.annualSalary / 12
  }

  getName(): string {
    return this.name
  }

  getAnnualCost(): number {
    return this.annualSalary
  }
}

class Contractor {
  name: string
  hourlyRate: number
  hoursPerMonth: number

  constructor(name: string, hourlyRate: number, hoursPerMonth: number) {
    this.name = name
    this.hourlyRate = hourlyRate
    this.hoursPerMonth = hoursPerMonth
  }

  getMonthlyCost(): number {  // Same method name, different calculation
    return this.hourlyRate * this.hoursPerMonth
  }

  getName(): string {  // Duplicated
    return this.name
  }

  getAnnualCost(): number {  // Same method name, different calculation
    return this.getMonthlyCost() * 12
  }
}
```

**Correct (extracted superclass):**

```typescript
abstract class Worker {
  constructor(protected name: string) {}

  getName(): string {
    return this.name
  }

  abstract getMonthlyCost(): number

  getAnnualCost(): number {
    return this.getMonthlyCost() * 12
  }
}

class Employee extends Worker {
  constructor(name: string, private annualSalary: number) {
    super(name)
  }

  getMonthlyCost(): number {
    return this.annualSalary / 12
  }
}

class Contractor extends Worker {
  constructor(
    name: string,
    private hourlyRate: number,
    private hoursPerMonth: number
  ) {
    super(name)
  }

  getMonthlyCost(): number {
    return this.hourlyRate * this.hoursPerMonth
  }
}

// Can now work with both types uniformly
function calculateTotalMonthlyCost(workers: Worker[]): number {
  return workers.reduce((sum, worker) => sum + worker.getMonthlyCost(), 0)
}
```

**When NOT to use:**
- Classes don't represent the same conceptual category
- Would violate Liskov Substitution Principle
- Composition would be more flexible

Reference: [Extract Superclass](https://refactoring.com/catalog/extractSuperclass.html)
