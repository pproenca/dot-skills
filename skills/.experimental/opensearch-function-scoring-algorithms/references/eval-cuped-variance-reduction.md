---
title: Apply CUPED to Halve A/B Sample Size with Pre-Experiment Covariates
impact: HIGH
impactDescription: 40-60% variance reduction, 2x test throughput
tags: eval, cuped, variance-reduction, covariate, ab-testing
---

## Apply CUPED to Halve A/B Sample Size with Pre-Experiment Covariates

A user's metric in an A/B test (conversion, bookings, sessions) is dominated by *who that user is*, not by the treatment. A power user converts 5× more than a casual user — that variance overwhelms the small treatment effect. CUPED (Controlled-experiment Using Pre-Existing Data, Microsoft 2013) adjusts each user's post-experiment metric by their pre-experiment metric, removing the persistent individual-level variation and exposing the treatment effect. Result: typical 40-60% variance reduction — equivalent to running with 2× the traffic, at zero infrastructure cost. Deployed at Netflix, Microsoft, Booking, Airbnb, Uber, DoorDash, LinkedIn, TripAdvisor.

**Incorrect (raw difference-in-means — most variance is from individual differences):**

```python
import numpy as np
from scipy.stats import ttest_ind

# Treatment vs control on bookings_per_user — high variance, slow to power
treatment = np.array([user.bookings_post for user in treatment_users])
control   = np.array([user.bookings_post for user in control_users])

ate = treatment.mean() - control.mean()  # average treatment effect
stat, pvalue = ttest_ind(treatment, control)
```

The variance of `treatment.mean() - control.mean()` is dominated by user-level variation that has nothing to do with the experiment.

**Correct (CUPED — adjust post-metric by pre-metric covariate):**

```python
import numpy as np
from scipy.stats import ttest_ind

# Y = post-experiment metric (e.g., bookings during the test window)
# X = pre-experiment metric for the SAME user (e.g., bookings in the 28d before)
all_users = treatment_users + control_users
Y = np.array([u.bookings_post for u in all_users])
X = np.array([u.bookings_pre  for u in all_users])

# 1. Compute theta from pooled data — Cov(X, Y) / Var(X)
theta = np.cov(X, Y, ddof=1)[0, 1] / np.var(X, ddof=1)

# 2. Adjust each Y by removing the X-predicted portion
#    Subtract X.mean() so the adjusted metric still has the same mean as Y
Y_cuped = Y - theta * (X - X.mean())

# 3. Run the t-test on the adjusted metric
treat_idx   = [i for i, u in enumerate(all_users) if u.in_treatment]
control_idx = [i for i, u in enumerate(all_users) if not u.in_treatment]
ate_cuped = Y_cuped[treat_idx].mean() - Y_cuped[control_idx].mean()
stat, pvalue = ttest_ind(Y_cuped[treat_idx], Y_cuped[control_idx])
```

**The variance reduction:**

```text
Var(Y_cuped) = Var(Y) × (1 - ρ²)

  ρ = correlation(X, Y) across users

  Typical ρ for behavioral metrics:
    bookings_pre vs bookings_post:    ρ ≈ 0.6-0.8  → 36-64% variance reduction
    sessions_pre vs sessions_post:    ρ ≈ 0.7-0.9  → 49-81% variance reduction
    conversion_pre vs conversion_post: ρ ≈ 0.3-0.5  → 9-25% variance reduction
```

**Picking the covariate:** The best `X` is the SAME metric measured in a comparable pre-experiment window. Longer pre-window = higher ρ = more reduction; common choice is 28-56 days.

**Picking the pre-window length:**

| Pre-window | When to use |
|------------|-------------|
| 7 days | Short test (1-2 weeks) on high-frequency metrics |
| 28 days | Standard default for most marketplace tests |
| 56 days | Long tests or low-frequency conversion metrics |
| 90 days | Long-tail / quarterly retention metrics |

**Trap — pre-period must end BEFORE experiment starts:**

```python
# WRONG — pre-window overlaps with the experiment
X = user.bookings_in_last_28_days  # includes treatment days for in-experiment users

# RIGHT — pre-window strictly before experiment start
X = user.bookings_in_28_days_before_experiment_start
```

If pre and post overlap, you can introduce treatment leakage into the covariate and invalidate the analysis.

**For new users with no pre-period data:** Either drop them from the CUPED analysis (acceptable if they're a small minority) or use a population-level default (X = population mean) — this gives zero variance reduction for those users but doesn't break anything.

**Combining CUPED with stratified analysis:**

```python
# Apply CUPED within strata for better attribution
for stratum in ["high_value_user", "medium_value_user", "low_value_user"]:
    users = [u for u in all_users if u.value_tier == stratum]
    apply_cuped_and_test(users)
```

**Validation:** After applying CUPED, compute the empirical variance of `Y_cuped` and compare to `Y`. The ratio `Var(Y_cuped) / Var(Y)` should match `(1 - ρ²)` within ~5%. If it doesn't, the covariate isn't well-correlated with the outcome (use a different covariate) or the computation has a bug.

**Modern A/B platforms have CUPED built in:** Eppo, GrowthBook, Statsig all support CUPED with a checkbox. If you're using these, just enable it on your primary metric; if not, the implementation above is ~10 lines.

Reference: [Deng, Xu, Kohavi, Walker — Improving the Sensitivity of Online Controlled Experiments by Utilizing Pre-Experiment Data (WSDM 2013)](https://exp-platform.com/Documents/2013-02-CUPED-ImprovingSensitivityOfControlledExperiments.pdf) · [GrowthBook CUPED documentation](https://docs.growthbook.io/statistics/cuped) · [Matteo Courthoud — Understanding CUPED](https://matteocourthoud.github.io/post/cuped/)
