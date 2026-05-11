---
name: marketplace-pre-member-personalisation
description: Use this skill whenever designing, building, reviewing, or diagnosing the pre-member journey of a two-sided trust marketplace — from anonymous landing through onboarding, registration, and the paid-membership paywall. Covers anonymous signal inference, what pet owners specifically need to validate before paying (safety, availability, competence, effort, local cost comparison), what pet sitters specifically need to validate (opportunity, first-stay path, daily commitment, hidden costs), information-asymmetry closure, progressive profile building, social proof, conversion psychology, onboarding intent capture, identity stitching, and pre-member measurement. Triggers on tasks involving visitor-to-member conversion, anonymous personalisation, onboarding flow design, paywall timing, pre-member ranking, or any question about what a pet owner or pet sitter needs to see before paying. Use this skill BEFORE marketplace-personalisation and marketplace-search-recsys-planning.
---

# Marketplace Engineering Two-Sided Pre-Member Personalisation Best Practices

Comprehensive design and diagnostic guide for the pre-member journey of a two-sided
trust marketplace. Covers anonymous signal inference, side-specific validation (what
pet owners and pet sitters each need to see before paying), information-asymmetry
closure, progressive profile building, social proof, conversion psychology, onboarding
intent capture, identity stitching, and pre-member measurement. Contains 53 rules across
10 categories, ordered by cascade impact, every rule grounded in published consumer-trust
and decision research.

## When to Apply

Reference this skill when:

- Designing or reviewing the anonymous landing page and first-render experience
- Choosing what to show a visitor before they have registered or paid
- Designing the onboarding flow and deciding which questions to ask in what order
- Planning the paywall moment — timing, copy, triggers, price anchoring
- Diagnosing a conversion funnel that is leaking between visit and paid membership
- Choosing how to persist visitor state across the anonymous → registered → member transition
- Measuring pre-member experiments and deciding whether to ship an intervention
- Answering "what does a pet owner or sitter actually need to believe before paying?"

This skill is the **precursor** to `marketplace-personalisation` and
`marketplace-search-recsys-planning`. Start here for anything pre-paid-membership;
hand off to those two skills at the paid-member boundary.

## Research foundations

Every rule in this skill is grounded in published research on consumer trust,
decision-making under risk, marketplace economics, and experimentation:

| Research source | What it informs |
|---|---|
| Cialdini — *Influence* | Social proof (specific beats aggregate), similarity principle, commitment |
| Kahneman & Tversky — Prospect Theory | Loss aversion, price anchoring, risk framing |
| Roth — *Who Gets What and Why* | Matching-market dynamics, two-sided acceptance rates, cold-start penalty |
| Fogg — Behavior Model | Motivation × ability × trigger, paywall timing |
| Bandura — Self-Efficacy Theory | First-stay path design, concrete-step persuasion |
| Slovic — Affect Heuristic | Risk overweighting, safety-signal prominence |
| Nielsen Norman Group | Form design, trust, review credibility |
| Trope & Liberman — Construal Level Theory | Psychological distance, local proof |
| Ein-Gar, Shiv, Tormala — Blemishing Effect | Mixed-review credibility |
| Small & Loewenstein — Identifiable Victim Effect | Named-person vs statistic evidence |
| Green & Brock — Narrative Transportation | First-experience stories |
| Kohavi — Trustworthy Online Experiments | Primary outcomes, proxy metrics, segmentation |
| Radlinski & Craswell — Optimized Interleaving | Fast ranking experiments |
| Airbnb / DoorDash engineering | Two-sided marketplace ranking and search |

## Rule Categories

Categories are ordered by cascade impact on the pre-member conversion journey:

| # | Category | Prefix | Impact |
|---|----------|--------|--------|
| 1 | Anonymous Signal Inference | `signal-` | CRITICAL |
| 2 | Pet Owner Validation and Trust | `owner-` | CRITICAL |
| 3 | Pet Sitter Validation and Opportunity | `sitter-` | HIGH |
| 4 | Information-Asymmetry Closure | `gap-` | HIGH |
| 5 | Progressive Profile Building | `profile-` | MEDIUM-HIGH |
| 6 | Social Proof and Lookalike Cohorts | `proof-` | MEDIUM-HIGH |
| 7 | Personalised Conversion Triggers | `convert-` | MEDIUM-HIGH |
| 8 | Onboarding Intent Capture | `onboard-` | MEDIUM |
| 9 | Identity Stitching | `stitch-` | MEDIUM |
| 10 | Pre-Member Measurement and Experimentation | `measure-` | MEDIUM |

## Quick Reference

### 1. Anonymous Signal Inference (CRITICAL)

- [`signal-extract-role-from-url-and-referrer`](references/signal-extract-role-from-url-and-referrer.md) — side inferred from URL path before first render
- [`signal-infer-geography-with-confidence`](references/signal-infer-geography-with-confidence.md) — geo-IP with confidence, not false certainty
- [`signal-capture-entry-point-metadata`](references/signal-capture-entry-point-metadata.md) — UTM, referrer, landing path persisted per session
- [`signal-use-anonymous-session-tokens`](references/signal-use-anonymous-session-tokens.md) — session-level identity from the first request
- [`signal-classify-inbound-intent`](references/signal-classify-inbound-intent.md) — transactional vs investigative vs curiosity
- [`signal-separate-raw-from-derived`](references/signal-separate-raw-from-derived.md) — raw signal plus versioned derived features

### 2. Pet Owner Validation and Trust (CRITICAL)

- [`owner-show-specific-local-reviews`](references/owner-show-specific-local-reviews.md) — identifiable-victim social proof, not aggregate stats
- [`owner-display-honest-local-availability`](references/owner-display-honest-local-availability.md) — honest liquidity beats inflated counts (expectancy-violation research)
- [`owner-surface-safety-guarantees-prominently`](references/owner-surface-safety-guarantees-prominently.md) — insurance and coverage above the fold (Slovic affect heuristic)
- [`owner-rank-sitters-by-pet-match-experience`](references/owner-rank-sitters-by-pet-match-experience.md) — feasibility by pet type, not global popularity
- [`owner-demystify-effort-explicitly`](references/owner-demystify-effort-explicitly.md) — explicit time budget beats aspirational copy (Fogg)
- [`owner-anchor-cost-against-local-alternative`](references/owner-anchor-cost-against-local-alternative.md) — local kennel price as anchor (Kahneman)

### 3. Pet Sitter Validation and Opportunity (HIGH)

- [`sitter-show-inventory-in-target-destinations`](references/sitter-show-inventory-in-target-destinations.md) — target-specific supply, not global counts
- [`sitter-be-honest-about-first-stay-competition`](references/sitter-be-honest-about-first-stay-competition.md) — cohort-specific acceptance rates
- [`sitter-provide-concrete-first-stay-path`](references/sitter-provide-concrete-first-stay-path.md) — five-step path (Bandura self-efficacy)
- [`sitter-show-typical-daily-commitment`](references/sitter-show-typical-daily-commitment.md) — explicit hours and walks, not "varies"
- [`sitter-rank-stays-by-travel-goal`](references/sitter-rank-stays-by-travel-goal.md) — goal-aware ranking
- [`sitter-disclose-hidden-costs-transparently`](references/sitter-disclose-hidden-costs-transparently.md) — food, utilities, transport (Edelman trust research)

### 4. Information-Asymmetry Closure (HIGH)

- [`gap-warn-about-cold-start-penalty`](references/gap-warn-about-cold-start-penalty.md) — first transaction is the hardest; say so
- [`gap-surface-lead-time-reality`](references/gap-surface-lead-time-reality.md) — median booking advance per destination
- [`gap-display-acceptance-rate-for-profile-shape`](references/gap-display-acceptance-rate-for-profile-shape.md) — cohort acceptance rate before paying
- [`gap-route-unworkable-segments-to-alternatives`](references/gap-route-unworkable-segments-to-alternatives.md) — decline payment rather than sell false hope
- [`gap-surface-seasonal-supply-constraints`](references/gap-surface-seasonal-supply-constraints.md) — seasonal curves with visitor month highlighted
- [`gap-link-to-realistic-first-experience-story`](references/gap-link-to-realistic-first-experience-story.md) — narrative transportation with honest friction

### 5. Progressive Profile Building (MEDIUM-HIGH)

- [`profile-build-incrementally-on-each-interaction`](references/profile-build-incrementally-on-each-interaction.md) — click updates profile, next page reranks
- [`profile-decay-features-with-inactivity`](references/profile-decay-features-with-inactivity.md) — exponential decay, 5-minute half-life
- [`profile-persist-across-tabs-and-reloads`](references/profile-persist-across-tabs-and-reloads.md) — server-side session-keyed store
- [`profile-surface-confidence-alongside-predictions`](references/profile-surface-confidence-alongside-predictions.md) — confidence scores next to values
- [`profile-reset-on-explicit-role-change`](references/profile-reset-on-explicit-role-change.md) — role switch clears role-specific features

### 6. Social Proof and Lookalike Cohorts (MEDIUM-HIGH)

- [`proof-use-specific-peer-stories-not-aggregates`](references/proof-use-specific-peer-stories-not-aggregates.md) — named people beat "4.9 stars"
- [`proof-match-peer-stories-to-inferred-cohort`](references/proof-match-peer-stories-to-inferred-cohort.md) — similarity principle
- [`proof-source-stories-from-real-history-not-handpicked`](references/proof-source-stories-from-real-history-not-handpicked.md) — data pipeline, not marketing
- [`proof-localise-social-proof-to-visitor-area`](references/proof-localise-social-proof-to-visitor-area.md) — psychological distance reduction
- [`proof-surface-mixed-reviews-not-only-five-star`](references/proof-surface-mixed-reviews-not-only-five-star.md) — blemishing effect

### 7. Personalised Conversion Triggers (MEDIUM-HIGH)

- [`convert-trigger-paywall-on-specific-listings`](references/convert-trigger-paywall-on-specific-listings.md) — specific object beats generic modal
- [`convert-use-loss-aversion-framing-on-soft-locks`](references/convert-use-loss-aversion-framing-on-soft-locks.md) — "don't lose what you built" (Kahneman)
- [`convert-anchor-price-against-local-alternative`](references/convert-anchor-price-against-local-alternative.md) — role-appropriate local anchor
- [`convert-never-interrupt-active-search`](references/convert-never-interrupt-active-search.md) — natural pause points only (Fogg)
- [`convert-re-engage-non-converting-registrants-personalised`](references/convert-re-engage-non-converting-registrants-personalised.md) — personalised triggers beat generic

### 8. Onboarding Intent Capture (MEDIUM)

- [`onboard-ask-role-before-anything-else`](references/onboard-ask-role-before-anything-else.md) — role drives branching
- [`onboard-ask-highest-information-gain-first`](references/onboard-ask-highest-information-gain-first.md) — information gain ordering
- [`onboard-prefill-from-inferred-signal`](references/onboard-prefill-from-inferred-signal.md) — confirmation beats data entry
- [`onboard-make-optional-questions-genuinely-skippable`](references/onboard-make-optional-questions-genuinely-skippable.md) — no dark-pattern required markers
- [`onboard-allow-answer-revision-without-restart`](references/onboard-allow-answer-revision-without-restart.md) — revision without losing progress

### 9. Identity Stitching (MEDIUM)

- [`stitch-preserve-profile-across-registration`](references/stitch-preserve-profile-across-registration.md) — no reset at signup
- [`stitch-use-deterministic-matching-for-returning-visitors`](references/stitch-use-deterministic-matching-for-returning-visitors.md) — email hash beats fingerprinting
- [`stitch-avoid-cross-contamination-on-account-switch`](references/stitch-avoid-cross-contamination-on-account-switch.md) — household hygiene
- [`stitch-handle-multi-device-via-privacy-safe-signal`](references/stitch-handle-multi-device-via-privacy-safe-signal.md) — deterministic-only cross-device
- [`stitch-degrade-gracefully-on-low-confidence`](references/stitch-degrade-gracefully-on-low-confidence.md) — fresh beats bad merge

### 10. Pre-Member Measurement and Experimentation (MEDIUM)

- [`measure-define-anonymous-to-member-as-primary-outcome`](references/measure-define-anonymous-to-member-as-primary-outcome.md) — one primary metric, rest are diagnostics
- [`measure-attribute-conversion-to-signal-change`](references/measure-attribute-conversion-to-signal-change.md) — profile-diff attribution
- [`measure-segment-by-channel-and-visitor-profile`](references/measure-segment-by-channel-and-visitor-profile.md) — Simpson's paradox prevention
- [`measure-run-interleaving-for-fast-experiments`](references/measure-run-interleaving-for-fast-experiments.md) — 10-100x less sample for ranking

## Living Context

This skill treats the product as evolving. Three living artefacts carry context across
sessions, releases and team changes:

- **`gotchas.md`** — append-only diagnostic lessons from pre-member conversion incidents
- **Visitor-concern matrix** — the side-by-side table of what each side needs to validate, extended as new concerns surface
- **Pre-member experiment log** — every conversion experiment with hypothesis, cohort, intervention, outcome

Update all three after every shipped change.

## How to Use

- Read [`references/_sections.md`](references/_sections.md) for category structure and cascade rationale
- Read [`gotchas.md`](gotchas.md) for accumulated lessons before suggesting interventions
- Read individual rule files when a specific task matches the rule title
- Use [`assets/templates/_template.md`](assets/templates/_template.md) to author new rules as the skill grows

## Related Skills

- **`marketplace-search-recsys-planning`** — post-member retrieval planning (search, OpenSearch, ranking). Hand off after paid-member activation.
- **`marketplace-personalisation`** — post-member personalisation (AWS Personalize, impression tracking, feedback loops, two-sided matching). Hand off after paid-member activation.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and cascade rationale |
| [gotchas.md](gotchas.md) | Accumulated pre-member diagnostic lessons |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new rules |
| [metadata.json](metadata.json) | Version, discipline, research references |
