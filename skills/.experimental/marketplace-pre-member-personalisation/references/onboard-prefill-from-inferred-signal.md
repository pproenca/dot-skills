---
title: Prefill Onboarding Answers from Inferred Signal
impact: MEDIUM
impactDescription: reduces friction by removing redundant typing
tags: onboard, prefill, inference
---

## Prefill Onboarding Answers from Inferred Signal

Signals captured earlier in the session — URL path, geo-IP, entry-point metadata, clicks — already answer some of the questions onboarding is about to ask. A visitor from the `/find-a-sitter-london` URL path is almost certainly an owner in London, and asking them to type London into a blank field is a small insult that adds drop-off. Pre-fill every field the system can credibly infer, show the inference source transparently, and let the visitor confirm or correct. This turns onboarding from a data-entry exercise into a confirmation exercise, which has dramatically lower friction.

**Incorrect (blank fields, no use of prior inference):**

```typescript
function OnboardingCityStep() {
  const [city, setCity] = useState("")
  return (
    <Field
      label="Which city?"
      value={city}
      onChange={setCity}
      placeholder="e.g. London"
    />
  )
}
```

**Correct (inferred value pre-filled with transparent source and easy correction):**

```typescript
function OnboardingCityStep({ profile }: { profile: InferredProfile }) {
  const inferred = profile.inferredCity
  const [city, setCity] = useState(inferred?.value ?? "")

  return (
    <div>
      <Field label="Which city?" value={city} onChange={setCity} />
      {inferred && city === inferred.value && (
        <Caption>
          Inferred from your {inferred.source === "geoip" ? "location" : "search"}.
          <Button variant="inline" onClick={() => setCity("")}>
            Change
          </Button>
        </Caption>
      )}
    </div>
  )
}
```

Reference: [Auth0 — Progressive Profiling](https://auth0.com/docs/manage-users/user-accounts/user-profiles/progressive-profiling)
