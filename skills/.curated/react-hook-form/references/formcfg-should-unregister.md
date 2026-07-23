---
title: Keep shouldUnregister Off Unless Hidden Fields Must Leave the Payload
impact: HIGH
impactDescription: prevents silently dropping values the user already entered
tags: formcfg, should-unregister, dynamic-forms, conditional-fields
---

## Keep shouldUnregister Off Unless Hidden Fields Must Leave the Payload

The default (`shouldUnregister: false`) keeps a field's value in form state after its input unmounts. That is the right default and it is not a memory problem — the retained data is a few strings per field. `shouldUnregister: true` is a **submission-shape** option: it removes unmounted fields from the values object entirely. Reaching for it to "clean up" a multi-step wizard silently deletes everything the user entered on step 1 the moment they advance to step 2.

**Incorrect (wizard loses step 1 the moment step 2 renders):**

```typescript
function OnboardingWizard() {
  const [step, setStep] = useState(1)
  const { register, handleSubmit } = useForm<OnboardingData>({
    shouldUnregister: true,  // personalName is dropped as soon as step 1 unmounts
    defaultValues: { personalName: '', companyName: '' },
  })

  return (
    <form onSubmit={handleSubmit(completeOnboarding)}>
      {step === 1 && <input {...register('personalName')} />}
      {step === 2 && <input {...register('companyName')} />}
      <button type="button" onClick={() => setStep(2)}>Next</button>
    </form>
  )
}
```

**Correct (default retention — every step survives to submit):**

```typescript
function OnboardingWizard() {
  const [step, setStep] = useState(1)
  const { register, handleSubmit } = useForm<OnboardingData>({
    defaultValues: { personalName: '', companyName: '' },
  })

  return (
    <form onSubmit={handleSubmit(completeOnboarding)}>
      {step === 1 && <input {...register('personalName')} />}
      {step === 2 && <input {...register('companyName')} />}
      <button type="button" onClick={() => setStep(2)}>Next</button>
    </form>
  )
}
```

**When `shouldUnregister: true` is the right call:**
- A discriminated payload where the hidden branch's keys must be absent, not empty — e.g. a "Business" account sends `taxId` and a "Personal" one must not send the key at all
- A backend that treats a present-but-empty key differently from an absent one
- Set it per field via `register('taxId', { shouldUnregister: true })` rather than form-wide, so the rest of the form keeps the safe default

Reference: [useForm - shouldUnregister](https://react-hook-form.com/docs/useform)
