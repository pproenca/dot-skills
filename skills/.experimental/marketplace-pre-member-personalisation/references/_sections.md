## Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by cascade impact on the pre-member conversion journey. The
central insight driving the ordering is that **both sides of a trust marketplace are
trying to validate specific beliefs before paying**, and the research on consumer trust
and two-sided markets is clear that those beliefs are side-specific. Signal inference
must come first because nothing downstream can be side-aware without it. Owner and sitter
validation come next because they encode what each side actually needs to see. Everything
else is the supporting infrastructure — progressive profiling, gap closure, social proof,
conversion psychology, onboarding capture, identity stitching and measurement.

---

## 1. Anonymous Signal Inference (signal)

**Impact:** CRITICAL  
**Description:** Without extracting role, intent, geography and urgency from URL path, referrer, query params, geo-IP and device within the first request, no downstream personalisation layer can be side-aware and every visitor is treated as a blank slate.

## 2. Pet Owner Validation and Trust (owner)

**Impact:** CRITICAL  
**Description:** Pet owners have six specific validations they perform before paying — safety, competence, availability, matching feasibility, value-versus-kennels and effort — and the personalisation layer must surface evidence for each one concretely because aggregate reassurances fail against loss-aversion and risk-overweighting.

## 3. Pet Sitter Validation and Opportunity (sitter)

**Impact:** HIGH  
**Description:** Pet sitters need to see concrete opportunity in their target destinations, honest first-stay competition, a credible path to acceptance, realistic daily commitment and transparent hidden costs before paying — because the single biggest cause of first-year sitter churn is discovering these facts after payment.

## 4. Information-Asymmetry Closure (gap)

**Impact:** HIGH  
**Description:** Both sides are missing information they do not know they are missing — cold-start penalty on the first transaction, seasonal supply collapse, acceptance rates for their profile shape, lead time distributions — and surfacing these facts honestly before conversion trades a small conversion cost for a large retention gain.

## 5. Progressive Profile Building (profile)

**Impact:** MEDIUM-HIGH  
**Description:** A visitor who clicks, scrolls and dwells reveals preferences with every interaction that never return to the system unless the session accumulates them into an evolving profile persisted across tabs, reloads and the anonymous-to-registered transition.

## 6. Social Proof and Lookalike Cohorts (proof)

**Impact:** MEDIUM-HIGH  
**Description:** Cialdini's research shows specific social proof converts dramatically better than aggregate, and the identifiable-victim effect confirms named-person evidence beats statistics — so pre-member proof must be localised, cohort-matched and sourced from real-user history rather than handpicked marketing testimonials.

## 7. Personalised Conversion Triggers (convert)

**Impact:** MEDIUM-HIGH  
**Description:** The paywall moment is governed by loss aversion, price anchoring and cognitive ease — three well-documented psychological mechanisms that together determine whether the visitor pays or bounces, and each demands a different personalised treatment than a generic upgrade modal.

## 8. Onboarding Intent Capture (onboard)

**Impact:** MEDIUM  
**Description:** Every onboarding question costs friction measured in drop-off, and must earn its place by producing downstream personalisation lift — so question ordering follows information gain, optional questions are genuinely skippable, and inferred answers are pre-filled wherever the system can credibly guess.

## 9. Identity Stitching (stitch)

**Impact:** MEDIUM  
**Description:** The transition from anonymous session to registered account to paid member must preserve every inferred feature the system has built, using deterministic matching where identifiers exist and degrading gracefully where they do not, because bad stitching is worse than no stitching.

## 10. Pre-Member Measurement and Experimentation (measure)

**Impact:** MEDIUM  
**Description:** Anonymous-to-member conversion is the only primary outcome that matters pre-member, and attribution, segmentation and experiment velocity determine whether the team can actually learn from the traffic they have.
