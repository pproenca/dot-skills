---
title: Replace Conditional with Lookup Table
impact: HIGH
impactDescription: reduces cyclomatic complexity and improves maintainability
tags: cond, lookup-table, map, switch-elimination
---

## Replace Conditional with Lookup Table

When a conditional simply maps values to other values, replace it with a lookup table (object or Map). This is cleaner and often faster.

**Incorrect (long switch for value mapping):**

```typescript
function getStatusLabel(status: string): string {
  switch (status) {
    case 'pending':
      return 'Awaiting Review'
    case 'approved':
      return 'Approved'
    case 'rejected':
      return 'Rejected'
    case 'in_progress':
      return 'In Progress'
    case 'completed':
      return 'Completed'
    case 'cancelled':
      return 'Cancelled'
    default:
      return 'Unknown'
  }
}

function getStatusColor(status: string): string {
  switch (status) {
    case 'pending':
      return '#FFA500'
    case 'approved':
      return '#00FF00'
    case 'rejected':
      return '#FF0000'
    // ... same pattern repeated
  }
}
```

**Correct (lookup table):**

```typescript
interface StatusConfig {
  label: string
  color: string
  icon: string
}

const STATUS_CONFIG: Record<string, StatusConfig> = {
  pending: { label: 'Awaiting Review', color: '#FFA500', icon: 'clock' },
  approved: { label: 'Approved', color: '#00FF00', icon: 'check' },
  rejected: { label: 'Rejected', color: '#FF0000', icon: 'x' },
  in_progress: { label: 'In Progress', color: '#0000FF', icon: 'spinner' },
  completed: { label: 'Completed', color: '#008000', icon: 'check-circle' },
  cancelled: { label: 'Cancelled', color: '#808080', icon: 'ban' }
}

const DEFAULT_STATUS: StatusConfig = { label: 'Unknown', color: '#000000', icon: 'question' }

function getStatusConfig(status: string): StatusConfig {
  return STATUS_CONFIG[status] ?? DEFAULT_STATUS
}

function getStatusLabel(status: string): string {
  return getStatusConfig(status).label
}

function getStatusColor(status: string): string {
  return getStatusConfig(status).color
}
```

**Benefits:**
- Single source of truth for all status-related data
- Adding a new status is one line, not changes to multiple switches
- Configuration can be externalized (loaded from JSON/database)

**When NOT to use:**
- Logic between cases is complex and varies significantly
- Only 2-3 cases exist and unlikely to grow

Reference: [Replace Conditional with Polymorphism](https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html)
