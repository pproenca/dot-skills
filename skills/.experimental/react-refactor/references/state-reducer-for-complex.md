---
title: Use useReducer for Multi-Field State Transitions
impact: CRITICAL
impactDescription: eliminates impossible states, centralizes transition logic
tags: state, useReducer, state-transitions, type-safety
---

## Use useReducer for Multi-Field State Transitions

Multiple related useState calls allow independent updates that produce impossible combinations — like `isSubmitting: true` and `isSuccess: true` simultaneously. A single useReducer with typed actions ensures every transition produces a valid state, and the transition logic lives in one place.

**Incorrect (independent useState calls — impossible states possible):**

```tsx
function CheckoutWizard() {
  const [currentStep, setCurrentStep] = useState(0);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [completedSteps, setCompletedSteps] = useState<Set<number>>(new Set());

  async function handleNext() {
    setIsSubmitting(true);
    setError(null);
    try {
      await validateStep(currentStep);
      setCompletedSteps((prev) => new Set(prev).add(currentStep));
      setCurrentStep((s) => s + 1);
      // Bug: forgot setIsSubmitting(false) — isSubmitting stuck at true
    } catch (err) {
      setError(err.message);
      setIsSubmitting(false);
      // Bug: isSuccess remains true from a previous submission
    }
  }
}
```

**Correct (useReducer — every transition is valid by construction):**

```tsx
type WizardState = {
  currentStep: number;
  completedSteps: Set<number>;
} & (
  | { status: "idle"; error: null }
  | { status: "submitting"; error: null }
  | { status: "error"; error: string }
  | { status: "success"; error: null }
);

type WizardAction =
  | { type: "SUBMIT_STEP" }
  | { type: "STEP_VALIDATED" }
  | { type: "STEP_FAILED"; error: string }
  | { type: "GO_BACK" };

function wizardReducer(state: WizardState, action: WizardAction): WizardState {
  switch (action.type) {
    case "SUBMIT_STEP":
      return { ...state, status: "submitting", error: null };
    case "STEP_VALIDATED":
      return {
        ...state,
        status: "idle",
        error: null,
        currentStep: state.currentStep + 1,
        completedSteps: new Set(state.completedSteps).add(state.currentStep),
      };
    case "STEP_FAILED":
      return { ...state, status: "error", error: action.error };
    case "GO_BACK":
      return { ...state, status: "idle", error: null, currentStep: Math.max(0, state.currentStep - 1) };
  }
}

function CheckoutWizard() {
  const [state, dispatch] = useReducer(wizardReducer, {
    currentStep: 0,
    completedSteps: new Set(),
    status: "idle",
    error: null,
  });

  async function handleNext() {
    dispatch({ type: "SUBMIT_STEP" });
    try {
      await validateStep(state.currentStep);
      dispatch({ type: "STEP_VALIDATED" }); // Transition always resets submitting
    } catch (err) {
      dispatch({ type: "STEP_FAILED", error: err.message });
    }
  }
}
```

Reference: [React Docs - Extracting State Logic into a Reducer](https://react.dev/learn/extracting-state-logic-into-a-reducer)
