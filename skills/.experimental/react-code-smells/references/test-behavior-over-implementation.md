---
title: Test Behavior, Not Implementation Details
impact: MEDIUM
impactDescription: reduces test maintenance by 70%, enables safe refactoring
tags: test, behavior, implementation-details, testing-library, refactoring
---

## Test Behavior, Not Implementation Details

Testing internal state, method calls, and component structure creates brittle tests. Test what users see and do.

**Code Smell Indicators:**
- Tests break when refactoring without behavior change
- Testing internal state values directly
- Testing component instance methods
- Assertions on implementation (state, handlers) not output

**Incorrect (testing implementation details):**

```tsx
function Counter() {
  const [count, setCount] = useState(0)
  const [history, setHistory] = useState([])

  function increment() {
    setCount(c => c + 1)
    setHistory(h => [...h, count + 1])
  }

  return (
    <div>
      <span data-testid="count">{count}</span>
      <button onClick={increment}>+</button>
    </div>
  )
}

// BAD: Testing implementation details
test('counter implementation', () => {
  const { result } = renderHook(() => {
    const [count, setCount] = useState(0)
    return { count, setCount }
  })

  // Testing internal state directly
  expect(result.current.count).toBe(0)

  act(() => result.current.setCount(1))
  expect(result.current.count).toBe(1)
})

// BAD: Testing class instance
test('counter instance', () => {
  const wrapper = mount(<Counter />)
  const instance = wrapper.instance()

  // Accessing internal methods
  instance.increment()
  expect(instance.state.count).toBe(1)
  expect(instance.state.history).toHaveLength(1)
})
```

**Correct (testing behavior):**

```tsx
// GOOD: Testing what users see and do
test('displays initial count of zero', () => {
  render(<Counter />)
  expect(screen.getByText('0')).toBeInTheDocument()
})

test('increments count when button clicked', async () => {
  render(<Counter />)

  // User sees 0
  expect(screen.getByText('0')).toBeInTheDocument()

  // User clicks button
  await userEvent.click(screen.getByRole('button', { name: '+' }))

  // User sees 1
  expect(screen.getByText('1')).toBeInTheDocument()
})

test('increments multiple times', async () => {
  render(<Counter />)

  await userEvent.click(screen.getByRole('button', { name: '+' }))
  await userEvent.click(screen.getByRole('button', { name: '+' }))
  await userEvent.click(screen.getByRole('button', { name: '+' }))

  expect(screen.getByText('3')).toBeInTheDocument()
})
```

**Correct (testing form behavior):**

```tsx
// BAD: Testing form state
test('form state', () => {
  const { result } = renderHook(() => useState(''))
  act(() => result.current[1]('test@example.com'))
  expect(result.current[0]).toBe('test@example.com')
})

// GOOD: Testing form behavior
test('submits form with entered email', async () => {
  const onSubmit = jest.fn()
  render(<EmailForm onSubmit={onSubmit} />)

  // User types email
  await userEvent.type(
    screen.getByLabelText('Email'),
    'test@example.com'
  )

  // User submits form
  await userEvent.click(screen.getByRole('button', { name: 'Submit' }))

  // Form was submitted with email
  expect(onSubmit).toHaveBeenCalledWith({ email: 'test@example.com' })
})

test('shows error for invalid email', async () => {
  render(<EmailForm onSubmit={jest.fn()} />)

  await userEvent.type(screen.getByLabelText('Email'), 'invalid')
  await userEvent.click(screen.getByRole('button', { name: 'Submit' }))

  // User sees error message
  expect(screen.getByText('Invalid email address')).toBeInTheDocument()
})
```

**Query priority (user-centric):**
```
1. getByRole - how users interact (button, textbox, heading)
2. getByLabelText - how users find form fields
3. getByPlaceholderText - if no label
4. getByText - what users see
5. getByTestId - LAST RESORT
```

**Test checklist:**
```
Does this test:
├── Test what users see? → Good
├── Test user interactions? → Good
├── Test internal state? → Refactor
├── Test method names? → Refactor
├── Break if I refactor internals? → Refactor
└── Use data-testid for everything? → Use better queries
```

Reference: [Testing Library Guiding Principles](https://testing-library.com/docs/guiding-principles)
