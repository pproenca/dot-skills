# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by cascade impact on the personalisation lifecycle: problems
at earlier stages poison every downstream stage. Tracking mistakes cannot be recovered
from; schema mistakes force a full dataset rebuild; matching-design mistakes produce a
system that is technically working but operationally wrong.

---

## 1. Event Tracking and Capture (track)

**Impact:** CRITICAL  
**Description:** Instrumentation is the foundation of every downstream stage — without logged impressions, stable IDs, outcome events, and join keys, no model, filter, or metric is recoverable.

## 2. Dataset and Schema Design (schema)

**Impact:** CRITICAL  
**Description:** Personalize schemas are effectively immutable, so early shape decisions constrain every future solution — bad schemas force a full dataset rebuild rather than an incremental fix.

## 3. Two-Sided Matching Patterns (match)

**Impact:** CRITICAL  
**Description:** Marketplace matching must respect both sides' preferences, feasibility constraints, and provider capacity — monolithic one-sided ranking produces winner-take-all dynamics that erode supply quality and long-term liquidity.

## 4. Simple Baselines and Theory of Constraints (simple)

**Impact:** HIGH  
**Description:** The bottleneck in a recommender is rarely the algorithm — it is usually instrumentation, coverage, or freshness, so simple baselines measure the gap before complexity is added and protect against over-engineering.

## 5. Feedback Loops and Bias Control (loop)

**Impact:** HIGH  
**Description:** Selection bias, positional bias, and popularity death spirals compound silently if feedback signals are not instrumented, exploration is not reserved, and the system is not optimising for the real downstream outcome.

## 6. Cold Start and Coverage (cold)

**Impact:** HIGH  
**Description:** New providers and new seekers arrive continuously in a marketplace, so cold-start handling via metadata-based recipes, explicit onboarding intent, and exploration slots determines whether inventory gets discovered at all.

## 7. Recipe and Pipeline Selection (recipe)

**Impact:** MEDIUM-HIGH  
**Description:** Choosing the correct recipe and pipeline shape — USER_PERSONALIZATION_v2 for discovery, SIMS for item-page similarity, PERSONALIZED_RANKING_v2 as a re-ranker — matches the algorithm to the problem and avoids training cost without justified lift.

## 8. Inference, Filters and Re-ranking (infer)

**Impact:** MEDIUM-HIGH  
**Description:** Serving-time correctness depends on applying hard exclusions via the Filters API, deduplicating by canonical entity, enforcing fairness caps, and caching responses — business rules must run after model scoring, not before.

## 9. Observability and Online Metrics (obs)

**Impact:** MEDIUM-HIGH  
**Description:** Online and offline metrics diverge silently, coverage collapses invisibly, and distribution drift goes unnoticed unless A/B tests, segment-sliced metrics, and exposure-health signals are first-class infrastructure.
