---
title: Reach for controlled state only when something reads the value on every change — otherwise prefer uncontrolled with `<form action>`
impact: LOW-MEDIUM
impactDescription: avoids per-keystroke re-renders for forms that only read on submit; enables real-time UI only where it actually justifies the state cell
tags: rcomp, controlled-vs-uncontrolled, on-every-change, submit-only
---

## Reach for controlled state only when something reads the value on every change — otherwise prefer uncontrolled with `<form action>`

**Pattern intent:** controlled inputs trade per-keystroke re-renders for per-keystroke read access. The trade only pays off when *something* downstream actually needs that per-keystroke read (validation feedback, dependent UI, programmatic transformation). For submit-only forms, uncontrolled inputs plus a form action are simpler and faster.

### Shapes to recognize

- A `useState('')` + `value={x} onChange={...}` pair where `x` is never read except inside `handleSubmit`.
- A "controlled form" with three `useState` cells, all read only inside submit — every keystroke causes a render, none of the renders use the new value.
- An uncontrolled input that's later switched to controlled mid-lifecycle (or vice versa) — produces "A component is changing an uncontrolled input to be controlled" warnings.
- A form using React Hook Form / Formik purely to track field values for submit — for a single-action form, `<form action>` + `defaultValue` is simpler.
- A controlled input where `onChange` simply does `setX(e.target.value)` — the React 19 + form-action path can read the value from `FormData` at submit without state.

The canonical resolution: ask "does anything *between* this keystroke and the next read the new value?" If no, uncontrolled + form action. If yes (validation, dependent UI, transformation), controlled is justified. Don't flip mid-lifecycle.

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
