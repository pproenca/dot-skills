---
title: Ask Role Before Any Other Onboarding Question
impact: MEDIUM
impactDescription: enables role-branched onboarding from the first question
tags: onboard, role, branching
---

## Ask Role Before Any Other Onboarding Question

Role is the single largest branching factor in a two-sided marketplace — every subsequent question depends on whether the visitor is on the supply or demand side. Luke Wroblewski's research on progressive form design shows that high-branching questions belong first because the answer changes which questions follow. Asking a generic question (name, email) before role forces the system to show the same follow-up fields to everyone and hides the branching from the visitor, which is a missed opportunity to tailor the remainder of the flow dramatically.

**Incorrect (generic fields first, role later):**

```typescript
function OnboardingStep1() {
  return (
    <Form>
      <Field name="firstName" label="First name" />
      <Field name="email" label="Email" />
      <Field name="password" label="Password" />
      <Button>Continue</Button>
    </Form>
  )
}
```

**Correct (role chosen first, pre-filled from inference, drives branching):**

```typescript
function OnboardingStep1({ inferredRole, inferredRoleConfidence }: Props) {
  const [role, setRole] = useState<Role | null>(
    inferredRoleConfidence >= 0.7 ? inferredRole : null
  )

  return (
    <div>
      <h2>What brings you here?</h2>
      <RoleChooser value={role} onChange={setRole}>
        <Choice value="owner">I have a pet and need care while I travel</Choice>
        <Choice value="sitter">I want to travel and look after pets</Choice>
        <Choice value="both">Both — I have pets and I want to travel</Choice>
      </RoleChooser>
      {role && <Button onClick={() => goToRoleSpecificStep2(role)}>Continue</Button>}
    </div>
  )
}
```

Reference: [Luke Wroblewski — Web Form Design: Filling in the Blanks](https://www.lukew.com/resources/web_form_design.asp)
