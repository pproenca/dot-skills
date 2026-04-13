---
title: Make Optional Questions Genuinely Skippable
impact: MEDIUM
impactDescription: reduces form-abandonment drop-off
tags: onboard, optional, dark-pattern
---

## Make Optional Questions Genuinely Skippable

Nielsen Norman Group's research on forms consistently shows that optional questions marked with required-field styling (asterisks, red borders, "required" labels on optional fields) trigger abandonment at the same rate as genuinely required fields, because users cannot tell the difference quickly. If a question does not branch the downstream experience — a demographic, an interest tag, an optional preference — it should be obviously skippable, with an explicit "Skip" button and no styling that implies required. The alternative is a dark pattern that trades completion-rate for abandonment-rate and usually loses.

**Incorrect (optional field styled identically to required, no skip button):**

```typescript
function OnboardingInterestStep() {
  const [interest, setInterest] = useState("")
  return (
    <Form onSubmit={() => goNext(interest)}>
      <Field
        label="What are your interests? *"
        required
        value={interest}
        onChange={setInterest}
      />
      <Button type="submit">Continue</Button>
    </Form>
  )
}
```

**Correct (optional field explicit, skip button prominent):**

```typescript
function OnboardingInterestStep() {
  const [interest, setInterest] = useState("")
  return (
    <Form onSubmit={() => goNext(interest)}>
      <Field
        label="What are your interests?"
        optionalLabel="Optional — helps us recommend stays"
        value={interest}
        onChange={setInterest}
      />
      <ButtonRow>
        <Button variant="secondary" onClick={() => goNext(null)}>Skip</Button>
        <Button type="submit">Continue</Button>
      </ButtonRow>
    </Form>
  )
}
```

Reference: [Nielsen Norman Group — Required Field Indicators](https://www.nngroup.com/articles/required-fields/)
