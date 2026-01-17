---
title: Use Snapshot Testing Judiciously
impact: MEDIUM
impactDescription: prevents snapshot blindness
tags: assert, snapshot, ui, regression
---

## Use Snapshot Testing Judiciously

Snapshots are useful for detecting unintended changes but can become meaningless if overused. Use them for stable outputs and review changes carefully.

**Incorrect (snapshot everything):**

```typescript
test('user service', () => {
  const user = userService.create({ name: 'Alice', email: 'alice@test.com' })
  // Snapshot includes timestamps, IDs - breaks on every run
  expect(user).toMatchSnapshot()
})

test('renders user list', () => {
  const component = render(<UserList users={mockUsers} />)
  // 500-line snapshot that nobody reviews
  expect(component).toMatchSnapshot()
})

// When snapshot fails, developer just runs `--updateSnapshot`
// without actually reviewing what changed
```

**Correct (targeted snapshots):**

```typescript
test('user has expected structure', () => {
  const user = userService.create({ name: 'Alice', email: 'alice@test.com' })

  // Snapshot only stable parts
  expect({
    name: user.name,
    email: user.email,
    role: user.role
  }).toMatchSnapshot()
})

test('error message format', () => {
  const error = validateUser({ email: 'invalid' })
  // Snapshots work well for error message text
  expect(error.message).toMatchSnapshot()
})

// Prefer explicit assertions for behavior
test('renders correct number of users', () => {
  const { getAllByRole } = render(<UserList users={mockUsers} />)
  expect(getAllByRole('listitem')).toHaveLength(mockUsers.length)
})

// Inline snapshots for small, reviewable outputs
test('formats date correctly', () => {
  const formatted = formatDate(new Date('2024-06-15'))
  expect(formatted).toMatchInlineSnapshot(`"June 15, 2024"`)
})
```

**Snapshot best practices:**
- Keep snapshots small and focused
- Use inline snapshots for short outputs
- Exclude non-deterministic values (IDs, timestamps)
- Review snapshot changes in code review
- Prefer explicit assertions for critical behavior

Reference: [Snapshot Testing - Jest](https://jestjs.io/docs/snapshot-testing)
