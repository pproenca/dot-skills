---
title: Choose Controlled vs Uncontrolled Appropriately
impact: LOW-MEDIUM
impactDescription: correct data flow, proper form handling
tags: comp, controlled, uncontrolled, forms
---

## Choose Controlled vs Uncontrolled Appropriately

Controlled components get values from props. Uncontrolled components manage their own state. Choose based on whether you need to react to every change.

**Incorrect (controlled for simple submission-only form):**

```typescript
function SimpleForm() {
  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    const name = formData.get('name')
    // Use name on submit
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" defaultValue="John" />
      <button>Submit</button>
    </form>
  )
}
// Less code, works for simple forms
```

**Correct (uncontrolled for simple form, controlled for validation):**

```typescript
function ValidatedForm() {
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
// React to every keystroke
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
