---
title: Avoid Direct Request Assertions
impact: HIGH
impactDescription: Tests implementation details; breaks on refactors that preserve behavior
tags: test, assertions, anti-pattern, implementation-details, behavior
---

## Avoid Direct Request Assertions

Do not assert that specific requests were made with specific parameters. This tests implementation details rather than behavior. Instead, assert on your application's reaction to responses.

**Incorrect (asserting request details):**

```typescript
it('sends correct data when creating user', async () => {
  const requestSpy = vi.fn()

  server.use(
    http.post('/api/user', async ({ request }) => {
      requestSpy(await request.json())
      return HttpResponse.json({ id: '1' })
    })
  )

  await createUser({ name: 'John', email: 'john@example.com' })

  // Testing implementation details - what if we add a field?
  expect(requestSpy).toHaveBeenCalledWith({
    name: 'John',
    email: 'john@example.com',
  })
})
```

**Correct (assert behavior through responses):**

```typescript
it('creates user and shows success message', async () => {
  server.use(
    http.post('/api/user', async ({ request }) => {
      const body = await request.json()
      // Validate in handler - returns error if invalid
      if (!body.email) {
        return HttpResponse.json(
          { error: 'Email required' },
          { status: 400 }
        )
      }
      return HttpResponse.json({ id: '1', ...body }, { status: 201 })
    })
  )

  render(<CreateUserForm />)
  await userEvent.type(screen.getByLabelText('Name'), 'John')
  await userEvent.type(screen.getByLabelText('Email'), 'john@example.com')
  await userEvent.click(screen.getByRole('button', { name: 'Create' }))

  // Assert application behavior, not request details
  expect(await screen.findByText('User created!')).toBeInTheDocument()
})
```

**For one-way requests (analytics, logging):**

```typescript
import { server } from './mocks/node'

it('tracks page view', async () => {
  const trackingPromise = new Promise<void>((resolve) => {
    server.events.on('request:end', ({ request }) => {
      if (request.url.includes('/analytics')) {
        resolve()
      }
    })
  })

  render(<HomePage />)

  // Verify the request was made without asserting payload
  await expect(trackingPromise).resolves.toBeUndefined()
})
```

**When NOT to use this pattern:**
- Analytics/telemetry testing may require request payload verification via lifecycle events

Reference: [Avoid Request Assertions](https://mswjs.io/docs/best-practices/avoid-request-assertions/)
