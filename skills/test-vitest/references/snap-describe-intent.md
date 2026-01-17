---
title: Name Snapshot Tests Descriptively
impact: LOW
impactDescription: Improves snapshot file organization and failure debugging
tags: snap, naming, organization, debugging
---

## Name Snapshot Tests Descriptively

Snapshot names are derived from test names. Generic names like "should work" or "renders correctly" make it hard to find and understand snapshots. Descriptive names document what the snapshot represents.

**Incorrect (generic names):**

```typescript
import { describe, it, expect } from 'vitest'

describe('Button', () => {
  it('should render', () => {
    expect(render(<Button>Click</Button>)).toMatchSnapshot()
  })

  it('should render 2', () => {
    expect(render(<Button disabled>Click</Button>)).toMatchSnapshot()
  })

  it('works', () => {
    expect(render(<Button variant="primary">Click</Button>)).toMatchSnapshot()
  })
})

// __snapshots__/Button.test.ts.snap contains:
// - "Button should render 1"
// - "Button should render 2 1"
// - "Button works 1"
// Which is which?
```

**Correct (descriptive names):**

```typescript
import { describe, it, expect } from 'vitest'

describe('Button', () => {
  it('renders with default props', () => {
    expect(render(<Button>Click</Button>)).toMatchSnapshot()
  })

  it('renders in disabled state', () => {
    expect(render(<Button disabled>Click</Button>)).toMatchSnapshot()
  })

  it('renders with primary variant', () => {
    expect(render(<Button variant="primary">Click</Button>)).toMatchSnapshot()
  })
})

// __snapshots__/Button.test.ts.snap contains:
// - "Button renders with default props 1"
// - "Button renders in disabled state 1"
// - "Button renders with primary variant 1"
// Clear what each represents
```

**Custom snapshot names:**

```typescript
it('renders button states', () => {
  expect(render(<Button>Click</Button>)).toMatchSnapshot('default state')
  expect(render(<Button disabled>Click</Button>)).toMatchSnapshot('disabled state')
})
```

**Benefits:**
- Easy to find specific snapshots
- Clear failure messages
- Self-documenting test files

Reference: [Vitest Snapshot Guide](https://vitest.dev/guide/snapshot)
