---
title: Choose Controlled vs Uncontrolled Appropriately
impact: LOW-MEDIUM
impactDescription: prevents form state sync bugs, enables real-time validation
tags: rcomp, controlled, uncontrolled, forms
---

## Choose Controlled vs Uncontrolled Appropriately

Controlled components get values from props; uncontrolled components manage their own state. This is a context-driven choice. Use controlled only when you need to react on every keystroke (validation, conditional UI). For submit-only forms, prefer uncontrolled with React 19 form actions.

**Incorrect (controlled state mirroring an input that's never read during render):**

```typescript
function SignupForm() {
  const [name, setName] = useState('')  // ❌ Never read except on submit

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    submit(name)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={name} onChange={e => setName(e.target.value)} />
      <button>Submit</button>
    </form>
  )
}
// Re-renders on every keystroke for no reason
```

**Correct (uncontrolled with form action for submit-only forms):**

```typescript
import { createUser } from './actions'

function SignupForm() {
  // React 19 form action: works without JS, no controlled state needed
  return (
    <form action={createUser}>
      <input name="name" defaultValue="John" />
      <button>Submit</button>
    </form>
  )
}
// Minimum boilerplate, progressive enhancement
```

**Correct (controlled for real-time validation):**

```typescript
function ValidatedSignupForm() {
  const [email, setEmail] = useState('')
  const isValid = email.includes('@')

  return (
    <form>
      <input
        value={email}
        onChange={e => setEmail(e.target.value)}
        className={isValid ? '' : 'error'}
      />
      {!isValid && <span>Enter valid email</span>}
      <button disabled={!isValid}>Submit</button>
    </form>
  )
}
// React on every keystroke to validate — controlled state is justified
```

**Decision guide:**
| Need | Use |
|------|-----|
| Submit-only validation | Uncontrolled |
| Real-time validation | Controlled |
| Conditional UI based on value | Controlled |
| Third-party form library | Check library docs |
| Maximum simplicity | Uncontrolled |
| Programmatic value changes | Controlled |
