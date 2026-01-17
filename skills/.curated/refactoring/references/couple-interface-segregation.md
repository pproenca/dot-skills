---
title: Apply Interface Segregation Principle
impact: CRITICAL
impactDescription: prevents unnecessary dependencies and enables focused testing
tags: couple, isp, solid, interface-design
---

## Apply Interface Segregation Principle

Clients should not be forced to depend on methods they don't use. Split large interfaces into smaller, focused ones.

**Incorrect (fat interface forces unused dependencies):**

```typescript
interface Worker {
  work(): void
  eat(): void
  sleep(): void
  attendMeeting(): void
  writeReport(): void
}

class Robot implements Worker {
  work(): void { /* ... */ }
  eat(): void { throw new Error('Robots do not eat') }  // Forced to implement
  sleep(): void { throw new Error('Robots do not sleep') }  // Meaningless method
  attendMeeting(): void { throw new Error('Robots do not attend meetings') }
  writeReport(): void { /* ... */ }
}

class Intern implements Worker {
  work(): void { /* ... */ }
  eat(): void { /* ... */ }
  sleep(): void { /* ... */ }
  attendMeeting(): void { throw new Error('Interns cannot attend meetings') }  // Policy violation
  writeReport(): void { throw new Error('Interns cannot write reports') }
}
```

**Correct (segregated interfaces):**

```typescript
interface Workable {
  work(): void
}

interface Feedable {
  eat(): void
  sleep(): void
}

interface MeetingAttendee {
  attendMeeting(): void
}

interface ReportWriter {
  writeReport(): void
}

class Robot implements Workable, ReportWriter {
  work(): void { /* ... */ }
  writeReport(): void { /* ... */ }
}

class Intern implements Workable, Feedable {
  work(): void { /* ... */ }
  eat(): void { /* ... */ }
  sleep(): void { /* ... */ }
}

class SeniorEmployee implements Workable, Feedable, MeetingAttendee, ReportWriter {
  work(): void { /* ... */ }
  eat(): void { /* ... */ }
  sleep(): void { /* ... */ }
  attendMeeting(): void { /* ... */ }
  writeReport(): void { /* ... */ }
}
```

**Benefits:**
- Classes only implement what they actually do
- Changes to one interface don't affect unrelated clients
- Testing is focused on relevant capabilities

Reference: [Interface Segregation Principle](https://en.wikipedia.org/wiki/Interface_segregation_principle)
