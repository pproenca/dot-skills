---
name: marketplace-recsys-feature-engineering
description: Use this skill whenever deciding what features to extract from raw marketplace assets — listing photos, owner-entered listing metadata, sitter wizard responses — to power item-to-item (similar listings), user-to-item (homefeed ranking), or user-to-user (mutual-fit matching) recommenders in a two-sided trust marketplace. Covers asset auditing, first-principles feature decomposition from the decision the user is making, vision-feature extraction (CLIP, room-type classification, amenity detection, aesthetic and quality scoring), listing text and metadata encoding (categoricals, multi-hot amenities, H3 geo-hashing, sentence-transformer description embeddings, structured pet triples), sitter wizard design (information-gain ordering, multiple-choice over free text, genuine skippability, hard constraint versus soft preference), derived-composition patterns for i2i / u2i / u2u (precomputed ANN shelves, multi-modal fusion, two-tower affinity, symmetric mutual-fit scoring, interpretable subscores), feature quality governance (single registry, training-serving parity, coverage and drift alarms, PII scrubbing, schema versioning), and incremental value proof (one feature at a time, ablation A/B, kill reviews, exploration slice, permanent feature-free baseline). Trigger even when the user does not explicitly say "feature engineering" but is asking how to get more signal out of listing photos, listing metadata, or the sitter onboarding wizard, or how to improve i2i / u2i / u2u quality without blindly ingesting a new model.
---

# Marketplace Engineering Recsys Feature Engineering Best Practices

Comprehensive first-principles guide for deriving usable recommender features from the raw assets of a two-sided trust marketplace — listing photos, owner-supplied listing metadata, and sitter wizard responses — for item-to-item, user-to-item, and user-to-user solutions. Contains 44 rules across 8 categories ordered by cascade impact on the feature-engineering lifecycle, plus one playbook that composes the rules into an end-to-end feature discovery workflow.

This skill is the **upstream precursor** to `marketplace-personalisation` (AWS Personalize) and `marketplace-search-recsys-planning` (OpenSearch retrieval). Those skills treat features as inputs they already have; this skill is about deciding what features to *build* from the raw assets, which decisions they serve, and how to prove each one is worth its maintenance cost.

## When to Apply

Reference this skill when:

- Planning what to extract from listing photos, descriptions, or amenity lists to power i2i similarity or u2i ranking
- Designing or revising the sitter onboarding wizard with recsys features as the primary output
- Deciding whether to build a vision embedding pipeline, a text encoder, or neither — and in what order
- Composing existing base features into item-to-item, user-to-item, or user-to-user scoring
- Auditing an existing feature store for coverage, drift, PII, duplication, or orphan features
- Choosing a ship/kill criterion for a new recsys feature and designing the ablation A/B test
- Answering the question: "we want to improve the similar-homes shelf — what feature should we build?"

## Setup

This skill has no user-specific configuration — it is self-contained. References are live URLs to engineering blogs from Airbnb, Pinterest, DoorDash, Uber, Netflix, and Google, to open-source libraries (Feast, Sentence-Transformers, Hugging Face CLIP, H3), to foundational academic papers (Airbnb KDD 2018, Pinterest ItemSage, YouTube Semantic IDs, PinSage), and to Google's Rules of Machine Learning.

## Rule Categories

Categories are ordered by cascade impact on the feature-engineering lifecycle: auditing mistakes build features on data that does not exist, first-principles mistakes produce features that do not map to real decisions, extraction mistakes poison everything downstream, and so on. Fix earlier-stage problems before later-stage problems.

| # | Category | Prefix | Impact |
|---|----------|--------|--------|
| 1 | Asset Audit and Inventory | `audit-` | CRITICAL |
| 2 | First-Principles Feature Decomposition | `firstp-` | CRITICAL |
| 3 | Image Feature Extraction | `vision-` | HIGH |
| 4 | Listing Text and Metadata Extraction | `listing-` | HIGH |
| 5 | Sitter Wizard and Profile Extraction | `wizard-` | HIGH |
| 6 | Derived Similarity and Affinity | `derive-` | MEDIUM-HIGH |
| 7 | Feature Quality and Governance | `quality-` | MEDIUM-HIGH |
| 8 | Incremental Rollout and Value Proof | `prove-` | MEDIUM |

## Quick Reference

### 1. Asset Audit and Inventory (CRITICAL)

- [`audit-measure-coverage-before-modelling`](references/audit-measure-coverage-before-modelling.md) — reject fields below 80% coverage from the feature plan
- [`audit-sample-every-asset-type-end-to-end`](references/audit-sample-every-asset-type-end-to-end.md) — pull 100 real instances through the real fetch path before planning
- [`audit-verify-rights-and-privacy-before-extraction`](references/audit-verify-rights-and-privacy-before-extraction.md) — ToS, GDPR, consent, face blur before encoding
- [`audit-quantify-freshness-per-asset`](references/audit-quantify-freshness-per-asset.md) — age distribution + expiry + refresh bucket
- [`audit-separate-raw-assets-from-derived-features`](references/audit-separate-raw-assets-from-derived-features.md) — raw immutable in object store, derived versioned in feature store

### 2. First-Principles Feature Decomposition (CRITICAL)

- [`firstp-start-from-the-decision-not-the-algorithm`](references/firstp-start-from-the-decision-not-the-algorithm.md) — decision first, sub-judgments second, tools last
- [`firstp-ask-what-signal-a-human-uses`](references/firstp-ask-what-signal-a-human-uses.md) — interview 8-12 owners and sitters; features trace back to quotes
- [`firstp-tie-every-feature-to-a-specific-solution`](references/firstp-tie-every-feature-to-a-specific-solution.md) — no feature without a named i2i/u2i/u2u consumer
- [`firstp-prefer-directly-observed-over-learned`](references/firstp-prefer-directly-observed-over-learned.md) — observed columns first, learned embeddings second
- [`firstp-reject-features-you-cannot-serve-at-inference`](references/firstp-reject-features-you-cannot-serve-at-inference.md) — training-serving parity starts at design time
- [`firstp-kill-features-a-popularity-baseline-already-captures`](references/firstp-kill-features-a-popularity-baseline-already-captures.md) — correlation screen before registration

### 3. Image Feature Extraction (HIGH)

- [`vision-use-clip-for-zero-shot-listing-embeddings`](references/vision-use-clip-for-zero-shot-listing-embeddings.md) — zero-shot CLIP ships in a week
- [`vision-detect-room-types-before-detecting-amenities`](references/vision-detect-room-types-before-detecting-amenities.md) — room prior conditions the amenity threshold
- [`vision-quantify-image-quality-separately-from-content`](references/vision-quantify-image-quality-separately-from-content.md) — blur, lighting, aesthetic as their own features
- [`vision-extract-per-object-counts-not-just-presence`](references/vision-extract-per-object-counts-not-just-presence.md) — `n_bed = 4` beats `has_bed = true`
- [`vision-pool-embeddings-across-a-listings-photo-set`](references/vision-pool-embeddings-across-a-listings-photo-set.md) — pooled listing vector; per-photo stored alongside
- [`vision-fine-tune-on-your-domain-when-clip-underperforms`](references/vision-fine-tune-on-your-domain-when-clip-underperforms.md) — contrastive fine-tune only after zero-shot plateaus

### 4. Listing Text and Metadata Extraction (HIGH)

- [`listing-declare-categorical-fields-for-bounded-vocabularies`](references/listing-declare-categorical-fields-for-bounded-vocabularies.md) — bounded vocab → categorical, validated on write
- [`listing-multi-hot-encode-amenity-lists`](references/listing-multi-hot-encode-amenity-lists.md) — fixed amenity vocabulary → multi-hot vector
- [`listing-hash-geo-to-hierarchies-not-raw-lat-lon`](references/listing-hash-geo-to-hierarchies-not-raw-lat-lon.md) — H3 at multiple resolutions
- [`listing-embed-description-with-pretrained-sentence-encoder`](references/listing-embed-description-with-pretrained-sentence-encoder.md) — all-MiniLM-L6-v2 for cheap semantic text features
- [`listing-extract-stay-duration-shape-not-just-length`](references/listing-extract-stay-duration-shape-not-just-length.md) — bin + holiday overlap + flexibility, not raw day count
- [`listing-encode-pet-requirements-as-structured-triples`](references/listing-encode-pet-requirements-as-structured-triples.md) — `(species, count, special_needs)` triples plus free text alongside

### 5. Sitter Wizard and Profile Extraction (HIGH)

- [`wizard-order-questions-by-information-gain`](references/wizard-order-questions-by-information-gain.md) — discriminative questions first, narrative last
- [`wizard-prefer-multiple-choice-over-free-text`](references/wizard-prefer-multiple-choice-over-free-text.md) — categorical features by construction
- [`wizard-make-skips-genuine-and-log-them`](references/wizard-make-skips-genuine-and-log-them.md) — skip is signal; defaults destroy it
- [`wizard-capture-experience-as-counts-and-dates`](references/wizard-capture-experience-as-counts-and-dates.md) — numbers, not adjectives; platform history overrides self-declaration
- [`wizard-separate-hard-constraints-from-soft-preferences`](references/wizard-separate-hard-constraints-from-soft-preferences.md) — filters vs ranking features

### 6. Derived Similarity and Affinity (MEDIUM-HIGH)

- [`derive-precompute-i2i-nearest-neighbours-offline`](references/derive-precompute-i2i-nearest-neighbours-offline.md) — ANN shelf built nightly, served from KV in <5ms
- [`derive-fuse-modalities-before-item-similarity`](references/derive-fuse-modalities-before-item-similarity.md) — vision + text + structured, weighted and normalised
- [`derive-use-two-tower-for-user-item-affinity`](references/derive-use-two-tower-for-user-item-affinity.md) — dual encoder trained on interactions; ANN-retrieval-ready
- [`derive-score-u2u-as-symmetric-mutual-fit`](references/derive-score-u2u-as-symmetric-mutual-fit.md) — `min(P(owner), P(sitter))`; one-sided scoring produces wasted requests
- [`derive-decompose-affinity-into-interpretable-subscores`](references/derive-decompose-affinity-into-interpretable-subscores.md) — fit/safety/logistics/price subscores + blend
- [`derive-cache-user-embedding-with-short-ttl`](references/derive-cache-user-embedding-with-short-ttl.md) — session-level cache, 60-300s TTL

### 7. Feature Quality and Governance (MEDIUM-HIGH)

- [`quality-version-feature-definitions-in-one-registry`](references/quality-version-feature-definitions-in-one-registry.md) — one name, one implementation, one owner
- [`quality-serve-training-and-inference-from-one-store`](references/quality-serve-training-and-inference-from-one-store.md) — feature store as the single source of truth
- [`quality-gate-features-on-coverage-and-drift`](references/quality-gate-features-on-coverage-and-drift.md) — coverage floor + PSI alarm
- [`quality-scrub-pii-before-features-leave-secure-zone`](references/quality-scrub-pii-before-features-leave-secure-zone.md) — face blur and regex scrubbing before encoding
- [`quality-freeze-feature-schemas-per-model-version`](references/quality-freeze-feature-schemas-per-model-version.md) — schema hash pinned to model artifact

### 8. Incremental Rollout and Value Proof (MEDIUM)

- [`prove-ship-one-feature-at-a-time`](references/prove-ship-one-feature-at-a-time.md) — one feature, one experiment, one decision
- [`prove-measure-lift-against-feature-ablated-variant`](references/prove-measure-lift-against-feature-ablated-variant.md) — ablation isolates the feature from incidental changes
- [`prove-kill-features-that-dont-earn-maintenance`](references/prove-kill-features-that-dont-earn-maintenance.md) — quarterly kill review on attributed lift
- [`prove-dedicate-random-exploration-slice-to-new-features`](references/prove-dedicate-random-exploration-slice-to-new-features.md) — 3-5% slice catches offline-close-to-tied winners
- [`prove-retain-feature-free-baseline-permanently`](references/prove-retain-feature-free-baseline-permanently.md) — popularity baseline as drift anchor

## Discovering New Features

One playbook composes the rules into an end-to-end workflow:

- [`references/playbooks/discovering.md`](references/playbooks/discovering.md) — Discover new features from raw marketplace assets: a seven-step workflow that starts with an asset audit and a decision decomposition and ends with a shipped ablation A/B against a feature-ablated baseline. Use when the task is "what should we build next?" rather than "fix this specific feature."

Read the playbook first when the task is an open-ended "how do we extract more signal from X?" Read individual rules when a specific implementation question arises.

## How to Use

- Read [`references/_sections.md`](references/_sections.md) for category structure and cascade rationale
- Read [`gotchas.md`](gotchas.md) for accumulated diagnostic lessons before suggesting interventions
- Read [`references/playbooks/discovering.md`](references/playbooks/discovering.md) to plan a new feature discovery cycle
- Read individual rule files under `references/` when a specific task matches the rule title
- Use [`assets/templates/_template.md`](assets/templates/_template.md) to author new rules as the skill grows

## Related Skills

- **`marketplace-personalisation`** — Post-extraction personalisation on AWS Personalize: event tracking, schema design, two-sided matching, cold start, feedback loops. Hand off once your features are in the store and you are ready to train a ranker.
- **`marketplace-search-recsys-planning`** — OpenSearch retrieval planning: query understanding, index design, ranking, search-plus-recs blending. Hand off when the bottleneck is retrieval rather than feature availability.
- **`marketplace-pre-member-personalisation`** — Pre-member journey from anonymous visit to paid membership: anonymous signal inference, onboarding intent capture, pre-member measurement. Hand off at the paid-member boundary.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions, impact ordering, cascade rationale |
| [references/playbooks/discovering.md](references/playbooks/discovering.md) | End-to-end feature discovery playbook |
| [gotchas.md](gotchas.md) | Accumulated feature-engineering diagnostic lessons (living) |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new rules |
| [metadata.json](metadata.json) | Version, discipline, authoritative references |
