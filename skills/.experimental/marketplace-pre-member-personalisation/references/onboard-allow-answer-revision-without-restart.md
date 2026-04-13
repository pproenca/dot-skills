---
title: Allow Answer Revision Without Restart
impact: MEDIUM
impactDescription: prevents mid-form abandonment on realisation
tags: onboard, revision, trust
---

## Allow Answer Revision Without Restart

Visitors change their minds mid-onboarding — they realise the dates they entered are wrong, they want to try a different destination, they meant to pick owner instead of both. A form that does not let the visitor revise previous answers without losing progress forces them to choose between completing a flow they no longer believe in, starting over, or abandoning. Most pick abandon. Persist the in-progress state, show a visible breadcrumb of previous answers, and let the visitor click any previous step to revise without losing the rest.

**Incorrect (linear form with no way back without losing progress):**

```typescript
function OnboardingFlow() {
  const [step, setStep] = useState(0)
  const [answers, setAnswers] = useState<Partial<Answers>>({})

  return (
    <div>
      <Step currentStep={step} answers={answers} setAnswers={setAnswers} />
      <Button onClick={() => setStep(step + 1)}>Continue</Button>
    </div>
  )
}
```

**Correct (persistent state, breadcrumb, revision-without-restart):**

```typescript
function OnboardingFlow() {
  const [step, setStep] = useState(0)
  const [answers, setAnswers] = usePersistedState<Partial<Answers>>("onboarding", {})

  return (
    <div>
      <Breadcrumb
        steps={ONBOARDING_STEPS}
        currentStep={step}
        completedSteps={Object.keys(answers)}
        onStepClick={(targetStep) => setStep(targetStep)}
      />
      <Step currentStep={step} answers={answers} setAnswers={setAnswers} />
      <ButtonRow>
        {step > 0 && <Button variant="secondary" onClick={() => setStep(step - 1)}>Back</Button>}
        <Button onClick={() => setStep(step + 1)}>Continue</Button>
      </ButtonRow>
    </div>
  )
}
```

Reference: [Nielsen Norman Group — Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/)
