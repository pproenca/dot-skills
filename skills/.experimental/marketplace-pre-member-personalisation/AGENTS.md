# Two-Sided Pre-Member Personalisation

**Version 0.1.0**  
Marketplace Engineering  
April 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive design and diagnostic guide for the pre-member journey of a two-sided trust marketplace. Covers anonymous signal inference, side-specific validation (what pet owners and pet sitters each need to see and believe before paying), information-asymmetry closure, progressive profile building, social proof, conversion psychology, onboarding intent capture, identity stitching and pre-member measurement. 53 rules across 10 categories, every rule grounded in published consumer-trust and decision research — Cialdini, Kahneman, Roth, Fogg, Bandura, Slovic, Nielsen Norman Group, and two-sided marketplace engineering literature. Functions as the precursor to the companion marketplace-personalisation and marketplace-search-recsys-planning skills; hand off at the paid-member boundary.

---

## Table of Contents

1. [Anonymous Signal Inference](references/_sections.md#1-anonymous-signal-inference) — **CRITICAL**
   - 1.1 [Capture Entry-Point Metadata on Every Page Load](references/signal-capture-entry-point-metadata.md) — CRITICAL (enables acquisition-channel attribution and personalisation)
   - 1.2 [Classify Inbound Intent from the Acquisition Channel](references/signal-classify-inbound-intent.md) — CRITICAL (enables channel-specific priors without interaction data)
   - 1.3 [Extract Role from URL Path and Referrer Before First Render](references/signal-extract-role-from-url-and-referrer.md) — CRITICAL (enables side-specific content on the first page)
   - 1.4 [Infer Geography from IP with Confidence Caveats](references/signal-infer-geography-with-confidence.md) — CRITICAL (enables same-region content without false certainty)
   - 1.5 [Mint Anonymous Session Tokens from the First Request](references/signal-use-anonymous-session-tokens.md) — CRITICAL (enables session-level personalisation without login)
   - 1.6 [Store Raw Signal Separately from Derived Features](references/signal-separate-raw-from-derived.md) — CRITICAL (enables re-derivation when feature logic changes)
2. [Pet Owner Validation and Trust](references/_sections.md#2-pet-owner-validation-and-trust) — **CRITICAL**
   - 2.1 [Anchor Membership Cost Against the Visitor's Local Kennel Alternative](references/owner-anchor-cost-against-local-alternative.md) — CRITICAL (enables saving-frame perception via local anchor)
   - 2.2 [Demystify Owner Effort Explicitly Before Payment](references/owner-demystify-effort-explicitly.md) — CRITICAL (reduces cognitive-load conversion loss)
   - 2.3 [Display Honest Local Availability, Not Inflated Global Counts](references/owner-display-honest-local-availability.md) — CRITICAL (prevents post-payment expectancy violation)
   - 2.4 [Rank Sitters by Experience with the Visitor's Pet Type](references/owner-rank-sitters-by-pet-match-experience.md) — CRITICAL (prevents feasibility-mismatch objection)
   - 2.5 [Show Specific Local Owner Reviews, Not Global Averages](references/owner-show-specific-local-reviews.md) — CRITICAL (enables identifiable-victim social proof)
   - 2.6 [Surface Safety Guarantees and Insurance Before Listings](references/owner-surface-safety-guarantees-prominently.md) — CRITICAL (reduces risk-overweighting on rare bad outcomes)
3. [Pet Sitter Validation and Opportunity](references/_sections.md#3-pet-sitter-validation-and-opportunity) — **HIGH**
   - 3.1 [Be Honest About First-Stay Competition for New Sitters](references/sitter-be-honest-about-first-stay-competition.md) — HIGH (prevents first-year churn from expectation violation)
   - 3.2 [Disclose Hidden Costs Transparently Before Payment](references/sitter-disclose-hidden-costs-transparently.md) — HIGH (prevents first-stay cost-shock churn)
   - 3.3 [Provide a Concrete First-Stay Path, Not Abstract Encouragement](references/sitter-provide-concrete-first-stay-path.md) — HIGH (enables self-efficacy on the cold-start problem)
   - 3.4 [Rank Stays by the Sitter's Travel Goal, Not Just Supply Density](references/sitter-rank-stays-by-travel-goal.md) — HIGH (prevents mismatch between inventory and actual desire)
   - 3.5 [Show Stay Inventory in the Sitter's Target Destination](references/sitter-show-inventory-in-target-destinations.md) — HIGH (prevents generic-inventory disappointment)
   - 3.6 [Show Typical Daily Commitment per Stay, Not Vague Descriptions](references/sitter-show-typical-daily-commitment.md) — HIGH (enables accurate effort-to-benefit calculation)
4. [Information-Asymmetry Closure](references/_sections.md#4-information-asymmetry-closure) — **HIGH**
   - 4.1 [Display Acceptance Rate for the Visitor's Profile Shape](references/gap-display-acceptance-rate-for-profile-shape.md) — HIGH (prevents unrealistic expectations on rare-profile visitors)
   - 4.2 [Link to a Realistic First-Experience Story from a Peer](references/gap-link-to-realistic-first-experience-story.md) — HIGH (enables narrative-driven expectation setting)
   - 4.3 [Route Unworkable Segments to Alternatives, Not to Payment](references/gap-route-unworkable-segments-to-alternatives.md) — HIGH (prevents converting visitors who will churn)
   - 4.4 [Surface Lead-Time Reality for the Visitor's Dates](references/gap-surface-lead-time-reality.md) — HIGH (prevents unmatchable-dates disappointment)
   - 4.5 [Surface Seasonal Supply Constraints Before Payment](references/gap-surface-seasonal-supply-constraints.md) — HIGH (prevents seasonal-expectation mismatch)
   - 4.6 [Warn About the Cold-Start Penalty on Both Sides Pre-Payment](references/gap-warn-about-cold-start-penalty.md) — HIGH (prevents first-year churn from the cold-start surprise)
5. [Progressive Profile Building](references/_sections.md#5-progressive-profile-building) — **MEDIUM-HIGH**
   - 5.1 [Build Profile Features Incrementally on Each Interaction](references/profile-build-incrementally-on-each-interaction.md) — MEDIUM-HIGH (enables in-session preference learning without login)
   - 5.2 [Decay Profile Features with Session Inactivity](references/profile-decay-features-with-inactivity.md) — MEDIUM-HIGH (prevents stale clicks dominating the profile)
   - 5.3 [Persist Anonymous Profile Across Tabs and Reloads](references/profile-persist-across-tabs-and-reloads.md) — MEDIUM-HIGH (prevents profile reset on page refresh)
   - 5.4 [Reset Profile Features on Explicit Role Changes](references/profile-reset-on-explicit-role-change.md) — MEDIUM-HIGH (prevents cross-contamination between sitter and owner profiles)
   - 5.5 [Surface Profile Confidence Alongside Predictions](references/profile-surface-confidence-alongside-predictions.md) — MEDIUM-HIGH (enables downstream decisions to respect uncertainty)
6. [Social Proof and Lookalike Cohorts](references/_sections.md#6-social-proof-and-lookalike-cohorts) — **MEDIUM-HIGH**
   - 6.1 [Localise Social Proof to the Visitor's Geography](references/proof-localise-social-proof-to-visitor-area.md) — MEDIUM-HIGH (reduces psychological distance of proof)
   - 6.2 [Match Peer Stories to the Visitor's Inferred Cohort](references/proof-match-peer-stories-to-inferred-cohort.md) — MEDIUM-HIGH (enables similarity-driven persuasion)
   - 6.3 [Source Peer Stories from Real User History, Not Handpicked Marketing](references/proof-source-stories-from-real-history-not-handpicked.md) — MEDIUM-HIGH (prevents testimonial-skepticism collapse)
   - 6.4 [Surface Mixed-Positive Reviews, Not Only Five-Star](references/proof-surface-mixed-reviews-not-only-five-star.md) — MEDIUM-HIGH (enables blemishing-effect credibility)
   - 6.5 [Use Specific Peer Stories at Decision Points, Not Aggregate Stats](references/proof-use-specific-peer-stories-not-aggregates.md) — MEDIUM-HIGH (enables specific-beats-aggregate social proof)
7. [Personalised Conversion Triggers](references/_sections.md#7-personalised-conversion-triggers) — **MEDIUM-HIGH**
   - 7.1 [Anchor Membership Price Against the Visitor's Most Local Alternative](references/convert-anchor-price-against-local-alternative.md) — MEDIUM-HIGH (enables saving-frame perception via local anchor)
   - 7.2 [Never Interrupt an Active Search with a Conversion Modal](references/convert-never-interrupt-active-search.md) — MEDIUM-HIGH (prevents task-flow rejection)
   - 7.3 [Reengage Non-Converting Registrants with Personalised Triggers](references/convert-re-engage-non-converting-registrants-personalised.md) — MEDIUM-HIGH (enables targeted reactivation of registered-not-converted cohort)
   - 7.4 [Trigger the Paywall on Specific Listings, Not Generic Upgrade Prompts](references/convert-trigger-paywall-on-specific-listings.md) — MEDIUM-HIGH (enables cognitive-ease conversion)
   - 7.5 [Use Loss-Aversion Framing on Soft-Locked Content](references/convert-use-loss-aversion-framing-on-soft-locks.md) — MEDIUM-HIGH (2-3x stronger than equivalent gain framing)
8. [Onboarding Intent Capture](references/_sections.md#8-onboarding-intent-capture) — **MEDIUM**
   - 8.1 [Allow Answer Revision Without Restart](references/onboard-allow-answer-revision-without-restart.md) — MEDIUM (prevents mid-form abandonment on realisation)
   - 8.2 [Ask Role Before Any Other Onboarding Question](references/onboard-ask-role-before-anything-else.md) — MEDIUM (enables role-branched onboarding from the first question)
   - 8.3 [Ask the Highest-Information-Gain Question Earliest](references/onboard-ask-highest-information-gain-first.md) — MEDIUM (reduces drop-off per unit of signal captured)
   - 8.4 [Make Optional Questions Genuinely Skippable](references/onboard-make-optional-questions-genuinely-skippable.md) — MEDIUM (reduces form-abandonment drop-off)
   - 8.5 [Prefill Onboarding Answers from Inferred Signal](references/onboard-prefill-from-inferred-signal.md) — MEDIUM (reduces friction by removing redundant typing)
9. [Identity Stitching](references/_sections.md#9-identity-stitching) — **MEDIUM**
   - 9.1 [Avoid Cross-Contamination When Users Switch Accounts](references/stitch-avoid-cross-contamination-on-account-switch.md) — MEDIUM (prevents household-device profile merging)
   - 9.2 [Degrade Gracefully When Stitching Confidence Is Low](references/stitch-degrade-gracefully-on-low-confidence.md) — MEDIUM (prevents bad merges worse than no merges)
   - 9.3 [Handle Multi-Device Visitors via Privacy-Safe Deterministic Signals](references/stitch-handle-multi-device-via-privacy-safe-signal.md) — MEDIUM (enables cross-device profile continuity without fingerprinting)
   - 9.4 [Preserve Inferred Profile Across the Registration Transition](references/stitch-preserve-profile-across-registration.md) — MEDIUM (prevents personalisation reset at signup)
   - 9.5 [Use Deterministic Matching for Returning Visitors](references/stitch-use-deterministic-matching-for-returning-visitors.md) — MEDIUM (prevents incorrect profile merges)
10. [Pre-Member Measurement and Experimentation](references/_sections.md#10-pre-member-measurement-and-experimentation) — **MEDIUM**
   - 10.1 [Attribute Conversion to the Signal That Changed the Profile](references/measure-attribute-conversion-to-signal-change.md) — MEDIUM (enables intervention-level conversion attribution)
   - 10.2 [Define Anonymous-to-Member Conversion as the Primary Outcome](references/measure-define-anonymous-to-member-as-primary-outcome.md) — MEDIUM (prevents proxy-metric optimisation)
   - 10.3 [Run Interleaving for Fast Pre-Member Experiments](references/measure-run-interleaving-for-fast-experiments.md) — MEDIUM (reduces required sample size by 10-100x)
   - 10.4 [Segment Conversion Measurement by Channel and Visitor Profile](references/measure-segment-by-channel-and-visitor-profile.md) — MEDIUM (prevents aggregate-masked segment regressions)

---

## References

1. [https://www.influenceatwork.com/principles-of-persuasion/](https://www.influenceatwork.com/principles-of-persuasion/)
2. [https://www.jstor.org/stable/1914185](https://www.jstor.org/stable/1914185)
3. [https://www.hup.harvard.edu/books/9780544291133](https://www.hup.harvard.edu/books/9780544291133)
4. [https://bjfogg.com/fbm_files/page4_1.pdf](https://bjfogg.com/fbm_files/page4_1.pdf)
5. [https://psycnet.apa.org/doi/10.1037/0033-295X.84.2.191](https://psycnet.apa.org/doi/10.1037/0033-295X.84.2.191)
6. [https://www.decisionresearch.org/wp-content/uploads/2017/06/rd6501.pdf](https://www.decisionresearch.org/wp-content/uploads/2017/06/rd6501.pdf)
7. [https://www.nngroup.com/articles/trustworthiness/](https://www.nngroup.com/articles/trustworthiness/)
8. [https://www.nngroup.com/articles/required-fields/](https://www.nngroup.com/articles/required-fields/)
9. [https://www.nngroup.com/articles/progressive-disclosure/](https://www.nngroup.com/articles/progressive-disclosure/)
10. [https://psycnet.apa.org/doi/10.1037/a0018963](https://psycnet.apa.org/doi/10.1037/a0018963)
11. [https://link.springer.com/article/10.1023/A:1022299422219](https://link.springer.com/article/10.1023/A:1022299422219)
12. [https://psycnet.apa.org/doi/10.1037/0022-3514.79.5.701](https://psycnet.apa.org/doi/10.1037/0022-3514.79.5.701)
13. [https://academic.oup.com/jcr/article-abstract/38/5/846/1791985](https://academic.oup.com/jcr/article-abstract/38/5/846/1791985)
14. [https://experimentguide.com/](https://experimentguide.com/)
15. [https://dl.acm.org/doi/10.1145/2433396.2433429](https://dl.acm.org/doi/10.1145/2433396.2433429)
16. [https://www.lukew.com/resources/web_form_design.asp](https://www.lukew.com/resources/web_form_design.asp)
17. [https://auth0.com/docs/manage-users/user-accounts/user-profiles/progressive-profiling](https://auth0.com/docs/manage-users/user-accounts/user-profiles/progressive-profiling)
18. [https://docs.mixpanel.com/docs/tracking-methods/id-management/identifying-users-simplified](https://docs.mixpanel.com/docs/tracking-methods/id-management/identifying-users-simplified)
19. [https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/package-features/identity-stitching/](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/package-features/identity-stitching/)
20. [https://docs.treasuredata.com/products/customer-data-platform/real-time/real-time-id-stitching-overview](https://docs.treasuredata.com/products/customer-data-platform/real-time/real-time-id-stitching-overview)
21. [https://www.kameleoon.com/blog/contextual-bandits](https://www.kameleoon.com/blog/contextual-bandits)
22. [https://www.optimizely.com/insights/blog/contextual-bandits-in-personalization/](https://www.optimizely.com/insights/blog/contextual-bandits-in-personalization/)
23. [https://dl.acm.org/doi/10.1145/2645710.2645732](https://dl.acm.org/doi/10.1145/2645710.2645732)
24. [https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
25. [https://medium.com/airbnb-engineering/learning-market-dynamics-for-optimal-pricing-97cffbcc53e3](https://medium.com/airbnb-engineering/learning-market-dynamics-for-optimal-pricing-97cffbcc53e3)
26. [https://developers.google.com/machine-learning/guides/rules-of-ml](https://developers.google.com/machine-learning/guides/rules-of-ml)
27. [https://www.edelman.com/trust-barometer](https://www.edelman.com/trust-barometer)
28. [https://www.tandfonline.com/doi/abs/10.1080/08934219309367485](https://www.tandfonline.com/doi/abs/10.1080/08934219309367485)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |