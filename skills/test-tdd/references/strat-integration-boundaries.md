---
title: Test Integration at Service Boundaries
impact: LOW
impactDescription: prevents integration failures in production
tags: strat, integration, boundaries, contracts
---

## Test Integration at Service Boundaries

Integration tests should verify contracts between components - API shapes, database schemas, and service interfaces. Test the boundaries, not the internals.

**Incorrect (testing implementation through integration):**

```typescript
test('user creation flow', async () => {
  // Testing implementation details through integration test
  const result = await request(app)
    .post('/api/users')
    .send({ email: 'test@example.com', name: 'Alice' })

  // Checking database internals
  const dbRecord = await db.query('SELECT * FROM users WHERE email = $1', ['test@example.com'])
  expect(dbRecord.rows[0].password_hash).toMatch(/^\$2b\$/)  // bcrypt format
  expect(dbRecord.rows[0].created_at).toBeDefined()

  // Checking email service internals
  const sentEmails = mockEmailService.getSentEmails()
  expect(sentEmails[0].template).toBe('welcome-v2')
  expect(sentEmails[0].templateVars.activationLink).toMatch(/\/activate\//)
})
```

**Correct (testing boundary contracts):**

```typescript
describe('POST /api/users', () => {
  it('returns created user with id', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'Alice' })

    // Test API contract, not implementation
    expect(response.status).toBe(201)
    expect(response.body).toMatchObject({
      id: expect.any(String),
      email: 'test@example.com',
      name: 'Alice'
    })
  })

  it('returns 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'invalid', name: 'Alice' })

    expect(response.status).toBe(400)
    expect(response.body.error).toBeDefined()
  })

  it('returns 409 for duplicate email', async () => {
    await createUser({ email: 'existing@example.com' })

    const response = await request(app)
      .post('/api/users')
      .send({ email: 'existing@example.com', name: 'Bob' })

    expect(response.status).toBe(409)
  })
})
```

**Integration test focus:**
- HTTP status codes and response shapes
- Database constraints and relationships
- Queue message formats
- External API contracts
- Error handling at boundaries

Reference: [Contract Testing - Pact](https://docs.pact.io/)
