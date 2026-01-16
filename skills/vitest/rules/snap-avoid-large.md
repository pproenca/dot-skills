---
title: Avoid Large Snapshots
impact: MEDIUM
impactDescription: Large snapshots are rarely reviewed and blindly updated, masking real bugs
tags: snap, snapshot-size, maintainability, code-review
---

## Avoid Large Snapshots

Snapshots over 50-100 lines become noise that reviewers skip. When updates happen, developers press "u" without reviewing changes, allowing bugs to slip through. Snapshot smaller, more focused pieces instead.

**Incorrect (entire component output):**

```typescript
import { describe, it, expect } from 'vitest'
import { render } from '@testing-library/react'

describe('Dashboard', () => {
  it('should render correctly', () => {
    const { container } = render(<Dashboard user={testUser} data={testData} />)
    // 500-line snapshot - no one will review changes
    expect(container.innerHTML).toMatchSnapshot()
  })
})
```

**Correct (focused snapshots):**

```typescript
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'

describe('Dashboard', () => {
  it('should display user name', () => {
    render(<Dashboard user={testUser} data={testData} />)
    expect(screen.getByRole('heading', { name: /alice/i })).toBeInTheDocument()
  })

  it('should render stats correctly', () => {
    render(<Dashboard user={testUser} data={testData} />)
    // Small, focused snapshot
    expect(screen.getByTestId('stats')).toMatchInlineSnapshot(`
      <div data-testid="stats">
        <span>Views: 1,234</span>
        <span>Clicks: 567</span>
      </div>
    `)
  })

  it('should show correct navigation links', () => {
    render(<Dashboard user={testUser} data={testData} />)
    const links = screen.getAllByRole('link')
    expect(links.map(l => l.textContent)).toEqual([
      'Home', 'Profile', 'Settings'
    ])
  })
})
```

**Signs of snapshot abuse:**
- Snapshot files larger than the test files
- Most PRs include "Update snapshots" commits
- Reviewers skip snapshot changes in code review
- Snapshots contain unstable data (dates, IDs)

**Better alternatives:**
- Assert specific properties
- Use focused inline snapshots
- Test behavior, not markup

**Benefits:**
- Snapshots get actually reviewed
- Changes are easier to understand
- Tests remain maintainable

Reference: [Vitest Snapshot Best Practices](https://vitest.dev/guide/snapshot)
