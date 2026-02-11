---
title: Apply Interface Segregation at Module Boundaries
impact: MEDIUM
impactDescription: prevents 30-50% of cascade rebuilds from unrelated type changes
tags: couple, interface-segregation, types, module-boundaries
---

## Apply Interface Segregation at Module Boundaries

Exporting a single monolithic interface forces every consumer to depend on the entire shape, even if they use two fields. When any field changes, TypeScript rechecks every file that imports the interface. Splitting interfaces per consumer concern limits rebuild cascading and makes contracts explicit.

**Incorrect (monolithic interface — all consumers depend on everything):**

```tsx
// types/employee.ts
export interface Employee {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  department: string;
  salary: number;
  bankAccount: string;
  performanceRating: number;
  startDate: Date;
  manager: Employee | null;
}

// EmployeeBadge only needs 3 fields but depends on all 10
import type { Employee } from "@/types/employee";

function EmployeeBadge({ employee }: { employee: Employee }) {
  return (
    <div className="badge">
      <span>{employee.firstName} {employee.lastName}</span>
      <span>{employee.department}</span>
    </div>
  );
}

// Adding bankRoutingNumber to Employee triggers recheck of EmployeeBadge
```

**Correct (segregated interfaces — consumers depend only on what they use):**

```tsx
// types/employee.ts
export interface EmployeeIdentity {
  id: string;
  firstName: string;
  lastName: string;
}

export interface EmployeeContact extends EmployeeIdentity {
  email: string;
  department: string;
}

export interface EmployeePayroll extends EmployeeIdentity {
  salary: number;
  bankAccount: string;
}

export interface EmployeeProfile extends EmployeeContact {
  performanceRating: number;
  startDate: Date;
  manager: EmployeeIdentity | null;
}

// EmployeeBadge depends only on EmployeeContact
import type { EmployeeContact } from "@/types/employee";

function EmployeeBadge({ employee }: { employee: EmployeeContact }) {
  return (
    <div className="badge">
      <span>{employee.firstName} {employee.lastName}</span>
      <span>{employee.department}</span>
    </div>
  );
}

// Changing EmployeePayroll does NOT trigger recheck of EmployeeBadge
```

Reference: [TypeScript Handbook - Interfaces](https://www.typescriptlang.org/docs/handbook/2/objects.html)
