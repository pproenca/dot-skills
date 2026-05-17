---
title: Calculate A/B Sample Size from MDE Before Running
impact: HIGH
impactDescription: prevents 20-30% false positive rate from peeking
tags: eval, ab-testing, mde, power, sample-size
---

## Calculate A/B Sample Size from MDE Before Running

"Run until significance" inflates false positive rate to ~25-30% via repeated peeking. The disciplined approach: pre-compute the sample size your test needs from three inputs — your Minimum Detectable Effect (MDE), the desired statistical power (usually 0.8), and your baseline metric's variance. Run *until that sample size is reached*, then evaluate once. This is the difference between "this ranker looks better" and "this ranker is +1.2% better with 95% confidence, p<0.01."

**Incorrect (peek and stop — false positive rate inflates):**

```python
# Run the test, check p-value daily, stop as soon as p<0.05
def run_ab_until_significance(treatment, control, max_days=30):
    for day in range(1, max_days + 1):
        data = collect_data_for(day)
        p = ttest(data.treatment, data.control).pvalue
        if p < 0.05:
            return {"day": day, "p": p, "result": "ship"}  # 25-30% of these are false positives
    return {"result": "inconclusive"}
```

**Correct (pre-compute n from MDE × power × variance, run until n, evaluate once):**

```python
import math
from scipy.stats import norm

def sample_size_per_arm(baseline_rate, mde_relative, power=0.80, alpha=0.05):
    """
    Sample size per arm for two-proportion z-test.

    baseline_rate:  observed metric (e.g., conversion rate 0.024)
    mde_relative:   smallest effect you care about as fraction of baseline
                    (e.g., 0.05 = "detect a 5% relative lift")
    power:          1 - β (probability of detecting the effect when it exists)
    alpha:          significance threshold (Type I error rate)
    """
    p1 = baseline_rate
    p2 = baseline_rate * (1 + mde_relative)
    pbar = (p1 + p2) / 2

    z_alpha = norm.ppf(1 - alpha / 2)
    z_beta  = norm.ppf(power)

    n = (
        (z_alpha * math.sqrt(2 * pbar * (1 - pbar))
         + z_beta * math.sqrt(p1 * (1 - p1) + p2 * (1 - p2))) ** 2
        / (p2 - p1) ** 2
    )
    return math.ceil(n)

# Example: marketplace with 2.4% conversion, want to detect 5% relative lift
n = sample_size_per_arm(baseline_rate=0.024, mde_relative=0.05)
# → n = 282,000 per arm → 564,000 sessions total
# At 50k sessions/day per arm: need ~6 days of pure traffic
```

**The fundamental relationship:**

```text
n ∝ σ² / MDE²

  Halving the MDE quadruples the required sample size.
  Doubling the baseline variance doubles the required sample size.
  Going from 80% to 90% power roughly +30% sample size.
```

**MDE calibration by traffic level:**

| Traffic | Recommended MDE | Why |
|---------|----------------|-----|
| <10k sessions/day | 8-15% relative | Can't detect smaller without months of testing |
| 10k-100k sessions/day | 3-5% relative | Most marketplace defaults |
| 100k-1M sessions/day | 1-3% relative | Sensitive to small but real effects |
| >1M sessions/day | 0.5-1% relative | Catch tiny but business-meaningful effects |

**Lower the bar with two techniques (in order of cost):**

1. **CUPED** (see `eval-cuped-variance-reduction`) — 40-60% variance reduction → halve required sample size. Cheap, just statistical adjustment.
2. **Interleaving** (see `bias-interleaved-evaluation`) — 10-100× more sample-efficient per impression. More implementation cost, but transformative for low-traffic verticals.

**Sequential testing (if you really must peek):**

If iteration speed matters more than purity, use sequential tests with corrected p-value thresholds (e.g., O'Brien-Fleming, Pocock) instead of repeated naive t-tests. Modern A/B platforms (Eppo, GrowthBook, Statsig) provide these out of the box. Never peek without sequential corrections.

**Always combine with sample-ratio mismatch (SRM) check:**

```python
def srm_check(treatment_n, control_n, alpha=0.001):
    """Sanity-check that random assignment produced the expected ratio.
       If it didn't, the experiment is invalid regardless of the result."""
    from scipy.stats import chisquare
    chi, p = chisquare([treatment_n, control_n])
    if p < alpha:
        raise SRMError(
            f"Assignment imbalance detected (p={p}). "
            f"Possible causes: bot traffic, redirect loss, logging bug."
        )
```

A test that looks significant but failed SRM is broken — don't ship.

**Why pre-computation matters:** It anchors you to a *decision rule before seeing data*. Without it, you'll find a way to convince yourself any result is "interesting." Sample-size discipline is the difference between A/B testing as science and A/B testing as confirmation bias.

Reference: [Microsoft — Online Controlled Experiments at Large Scale (KDD 2013)](https://exp-platform.com/Documents/2013-02-OnlineControlledExperimentsAtLargeScale.pdf) · [Kohavi, Tang, Xu — Trustworthy Online Controlled Experiments (Cambridge book, 2020)](https://experimentguide.com/) · [Eppo MDE calculator](https://docs.geteppo.com/statistics/sample-size-calculator/mde/)
