---
title: Provide Actionable Empty States
impact: MEDIUM-HIGH
impactDescription: increases user action rate by 2-4×
tags: data, empty-state, ux, guidance, onboarding
---

## Provide Actionable Empty States

When displaying empty data (no results, no items), provide context and clear actions rather than just "No data".

**Incorrect (unhelpful empty state):**

```tsx
function TaskList({ tasks }: { tasks: Task[] }) {
  if (tasks.length === 0) {
    return <p className="text-muted-foreground p-4">No tasks found.</p>
    // User doesn't know why or what to do next
  }

  return <ul>{/* render tasks */}</ul>
}
```

**Correct (actionable empty state):**

```tsx
import { Plus, Search, Filter } from "lucide-react"

function TaskList({
  tasks,
  searchQuery,
  filter,
  onCreateTask,
  onClearFilters,
}: TaskListProps) {
  if (tasks.length === 0) {
    // Different empty states based on context
    if (searchQuery) {
      return (
        <div className="flex flex-col items-center justify-center p-12 text-center">
          <Search className="h-12 w-12 text-muted-foreground mb-4" />
          <h3 className="text-lg font-medium">No results for "{searchQuery}"</h3>
          <p className="text-muted-foreground mt-1 mb-4">
            Try adjusting your search or filters
          </p>
          <Button variant="outline" onClick={onClearFilters}>
            Clear filters
          </Button>
        </div>
      )
    }

    if (filter !== "all") {
      return (
        <div className="flex flex-col items-center justify-center p-12 text-center">
          <Filter className="h-12 w-12 text-muted-foreground mb-4" />
          <h3 className="text-lg font-medium">No {filter} tasks</h3>
          <p className="text-muted-foreground mt-1 mb-4">
            Tasks marked as {filter} will appear here
          </p>
          <Button variant="outline" onClick={() => onClearFilters()}>
            View all tasks
          </Button>
        </div>
      )
    }

    // Fresh start - no tasks yet
    return (
      <div className="flex flex-col items-center justify-center p-12 text-center border-2 border-dashed rounded-lg">
        <Plus className="h-12 w-12 text-muted-foreground mb-4" />
        <h3 className="text-lg font-medium">No tasks yet</h3>
        <p className="text-muted-foreground mt-1 mb-4 max-w-sm">
          Get started by creating your first task to track your work
        </p>
        <Button onClick={onCreateTask}>
          <Plus className="h-4 w-4 mr-2" />
          Create task
        </Button>
      </div>
    )
  }

  return <ul>{/* render tasks */}</ul>
}
```

**Empty state guidelines:**
- Use relevant icons to visually communicate the state
- Explain why the list is empty (search, filter, fresh start)
- Provide a clear primary action
- Keep copy concise and helpful

Reference: [Empty States Design Patterns](https://www.nngroup.com/articles/empty-state-interface-design/)
