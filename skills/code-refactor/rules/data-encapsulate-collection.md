---
title: Encapsulate Collection
impact: MEDIUM
impactDescription: prevents uncontrolled modifications and enforces invariants
tags: data, encapsulation, collection, immutability
---

## Encapsulate Collection

Never expose raw collections directly. Provide controlled access methods that maintain invariants and prevent external modification.

**Incorrect (exposed mutable collection):**

```typescript
class Course {
  students: Student[] = []  // Exposed directly

  addStudent(student: Student): void {
    this.students.push(student)
  }
}

// Callers can bypass the API and break invariants
const course = new Course()
course.students.push(student)  // Bypasses addStudent validation
course.students.length = 0  // Clears all students unexpectedly
course.students = []  // Replaces entire collection

// No way to enforce max class size or prerequisites
```

**Correct (encapsulated with controlled access):**

```typescript
class Course {
  private _students: Student[] = []
  private readonly maxSize = 30

  addStudent(student: Student): void {
    if (this._students.length >= this.maxSize) {
      throw new Error('Course is full')
    }
    if (this._students.some(s => s.id === student.id)) {
      throw new Error('Student already enrolled')
    }
    this._students.push(student)
  }

  removeStudent(studentId: string): void {
    const index = this._students.findIndex(s => s.id === studentId)
    if (index === -1) {
      throw new Error('Student not found')
    }
    this._students.splice(index, 1)
  }

  // Return a copy to prevent external modification
  get students(): readonly Student[] {
    return [...this._students]
  }

  get studentCount(): number {
    return this._students.length
  }

  hasStudent(studentId: string): boolean {
    return this._students.some(s => s.id === studentId)
  }
}

// Now all access goes through controlled methods
const course = new Course()
course.addStudent(student)  // Validates max size
course.students.push(another)  // No effect - it's a copy
```

**Benefits:**
- Invariants enforced (max size, no duplicates)
- Clear API for collection operations
- Internal representation can change without affecting clients

Reference: [Encapsulate Collection](https://refactoring.com/catalog/encapsulateCollection.html)
