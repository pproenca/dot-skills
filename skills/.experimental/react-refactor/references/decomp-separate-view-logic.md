---
title: Separate View Layer from Business Logic
impact: HIGH
impactDescription: business logic testable without rendering, 5× faster test suite
tags: decomp, custom-hooks, view-logic-separation, testability
---

## Separate View Layer from Business Logic

Business logic embedded in JSX forces every test to render the component, making tests slow and brittle. Extract validation, data transformation, and side effects into a custom hook, leaving the component as a thin view that maps hook return values to JSX.

**Incorrect (validation, API calls, and formatting interleaved with JSX):**

```tsx
function SubscriptionManager({ userId }: { userId: string }) {
  const [plan, setPlan] = useState<Plan | null>(null);
  const [isUpgrading, setIsUpgrading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchCurrentPlan(userId).then(setPlan).catch(() => setError("Failed to load plan"));
  }, [userId]);

  async function handleUpgrade(targetPlan: PlanTier) {
    if (!plan) return;
    if (plan.tier === targetPlan) {
      setError("Already on this plan");
      return;
    }
    if (plan.tier === "enterprise" && targetPlan !== "enterprise") {
      setError("Enterprise downgrades require support");
      return;
    }
    setIsUpgrading(true);
    setError(null);
    try {
      const upgraded = await upgradePlan(userId, targetPlan);
      setPlan(upgraded);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Upgrade failed");
    } finally {
      setIsUpgrading(false);
    }
  }

  const renewalDate = plan
    ? new Intl.DateTimeFormat("en-US", { dateStyle: "long" }).format(plan.renewsAt)
    : "";

  const monthlyPrice = plan ? formatCurrency(plan.pricePerMonth) : "";

  return (
    <div>
      {error && <Alert variant="error">{error}</Alert>}
      {plan && (
        <>
          <h2>{plan.tier} Plan</h2>
          <p>{monthlyPrice}/month — renews {renewalDate}</p>
          <button onClick={() => handleUpgrade("pro")} disabled={isUpgrading}>
            {isUpgrading ? "Upgrading..." : "Upgrade to Pro"}
          </button>
        </>
      )}
    </div>
  );
}
```

**Correct (custom hook owns all logic, component is a thin view):**

```tsx
// Testable without rendering — call the hook in a test harness
function useSubscription(userId: string) {
  const [plan, setPlan] = useState<Plan | null>(null);
  const [isUpgrading, setIsUpgrading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchCurrentPlan(userId).then(setPlan).catch(() => setError("Failed to load plan"));
  }, [userId]);

  async function handleUpgrade(targetPlan: PlanTier) {
    if (!plan) return;
    if (plan.tier === targetPlan) {
      setError("Already on this plan");
      return;
    }
    if (plan.tier === "enterprise" && targetPlan !== "enterprise") {
      setError("Enterprise downgrades require support");
      return;
    }
    setIsUpgrading(true);
    setError(null);
    try {
      const upgraded = await upgradePlan(userId, targetPlan);
      setPlan(upgraded);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Upgrade failed");
    } finally {
      setIsUpgrading(false);
    }
  }

  const renewalDate = plan
    ? new Intl.DateTimeFormat("en-US", { dateStyle: "long" }).format(plan.renewsAt)
    : "";

  return { plan, isUpgrading, error, renewalDate, handleUpgrade };
}

function SubscriptionManager({ userId }: { userId: string }) {
  const { plan, isUpgrading, error, renewalDate, handleUpgrade } =
    useSubscription(userId);

  return (
    <div>
      {error && <Alert variant="error">{error}</Alert>}
      {plan && (
        <>
          <h2>{plan.tier} Plan</h2>
          <p>{formatCurrency(plan.pricePerMonth)}/month — renews {renewalDate}</p>
          <button onClick={() => handleUpgrade("pro")} disabled={isUpgrading}>
            {isUpgrading ? "Upgrading..." : "Upgrade to Pro"}
          </button>
        </>
      )}
    </div>
  );
}
```

Reference: [Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
