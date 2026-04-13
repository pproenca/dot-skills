# Discovery Playbook: From Raw Asset to Shipped Recsys Feature

This playbook walks through the end-to-end workflow for discovering, extracting,
composing, and shipping a new recommender feature in a two-sided trust marketplace.
It composes the rules from every category into a seven-step process that starts
with an asset audit and a decision decomposition and ends with an ablation A/B
test against a feature-ablated baseline.

Use this playbook when:

- The task is "how do we extract more signal from our photos / metadata / wizard?"
- A sibling skill (`marketplace-personalisation`, `marketplace-search-recsys-planning`)
  has identified a feature gap and the question is what to build
- Planning the next quarter of feature-engineering work
- Diagnosing a feature portfolio that has grown quickly without a discipline

Skip to the individual rules when a specific implementation question arises
mid-stream (e.g., "which text encoder should I use?" — go straight to
[`listing-embed-description-with-pretrained-sentence-encoder`](../listing-embed-description-with-pretrained-sentence-encoder.md)).

## Summary

| Step | Goal | Time Budget | Primary Rules |
|------|------|-------------|---------------|
| 1. Audit the raw assets | Know what actually exists, at what quality | 2-5 days | `audit-*` (all 5 rules) |
| 2. Decompose the decision | Write the decision and the sub-judgments | 1-3 days | `firstp-start-from-the-decision-not-the-algorithm`, `firstp-ask-what-signal-a-human-uses` |
| 3. Pick one candidate feature | Tied to a solution and a metric | 1 day | `firstp-tie-every-feature-to-a-specific-solution`, `firstp-kill-features-a-popularity-baseline-already-captures` |
| 4. Prototype the extractor | Working code on a sample, within serving budget | 1-2 weeks | `vision-*`, `listing-*`, or `wizard-*` depending on source |
| 5. Compose into the target | i2i shelf, u2i ranker, or u2u matcher | 1-2 weeks | `derive-*` (all 6 rules) |
| 6. Register, gate, productionise | Single registry, coverage + drift alarms | 3-5 days | `quality-*` (all 5 rules) |
| 7. Ablation A/B and decide | Ship, kill, or iterate | 2-4 weeks | `prove-*` (all 5 rules) |

Total: **6-10 weeks** from "we have raw assets" to "a shipped feature with
proven online lift." Every step has an exit criterion — do not proceed to
the next step until the current step passes.

## Step 1 — Audit the Raw Assets

**Goal:** an honest, numeric picture of every asset type you might extract features from.

Run the audit against every source table and object store that could feed features:
the listings table, the listing_photos bucket, the sitter_profiles table, the wizard
responses store. For each one, produce three numbers: coverage per field
([`audit-measure-coverage-before-modelling`](../audit-measure-coverage-before-modelling.md)),
end-to-end fetchability of a random sample
([`audit-sample-every-asset-type-end-to-end`](../audit-sample-every-asset-type-end-to-end.md)),
and freshness distribution
([`audit-quantify-freshness-per-asset`](../audit-quantify-freshness-per-asset.md)).

In parallel, confirm rights and privacy
([`audit-verify-rights-and-privacy-before-extraction`](../audit-verify-rights-and-privacy-before-extraction.md))
and separate raw storage from derived storage
([`audit-separate-raw-assets-from-derived-features`](../audit-separate-raw-assets-from-derived-features.md))
before the first extractor runs.

**Exit criterion:** a one-page audit document for every asset type, listing coverage
(≥80% gate), fetch success rate (≥95% gate), freshness median and tail, ToS status,
consent flag status, and which fields are excluded from the feature plan with
reason.

## Step 2 — Decompose the Decision

**Goal:** write the specific decision this feature is meant to help the recommender make.

Do not start from CLIP or two-tower or anything else
([`firstp-start-from-the-decision-not-the-algorithm`](../firstp-start-from-the-decision-not-the-algorithm.md)).
Start from a sentence like "would an owner of a senior dog request this sitter?"
or "which two listings are similar enough that a sitter who booked one would
book the other?" Decompose the decision into 3-7 sub-judgments a human would
make to answer it.

Interview 8-12 real owners and 8-12 real sitters and ask them to talk through
three listings they accepted and three they rejected
([`firstp-ask-what-signal-a-human-uses`](../firstp-ask-what-signal-a-human-uses.md)).
Every named signal is a candidate feature with a quote attached.

**Exit criterion:** a written decision statement, a list of 3-7 sub-judgments
with human quotes backing each, and a shortlist of 5-15 candidate features.

## Step 3 — Pick One Candidate Feature

**Goal:** one feature, one solution, one metric, one owner, one hypothesis.

From the shortlist, pick the single highest-leverage feature. Tie it to a
specific downstream solution — i2i similarity shelf, u2i homefeed ranker, or
u2u matchmaking — and a specific primary metric
([`firstp-tie-every-feature-to-a-specific-solution`](../firstp-tie-every-feature-to-a-specific-solution.md)).
Run a correlation screen against the current popularity baseline to kill
features that are subsumed by booking count
([`firstp-kill-features-a-popularity-baseline-already-captures`](../firstp-kill-features-a-popularity-baseline-already-captures.md)).
Prefer directly observed features over learned ones unless a learned feature
is specifically justified
([`firstp-prefer-directly-observed-over-learned`](../firstp-prefer-directly-observed-over-learned.md)).
Reject any feature whose serving story is not already wired up
([`firstp-reject-features-you-cannot-serve-at-inference`](../firstp-reject-features-you-cannot-serve-at-inference.md)).

**Exit criterion:** one feature picked, one-page RFC listing owner, solution,
metric, hypothesis, serving source, correlation against baseline, and the
specific sub-judgment it is meant to improve.

## Step 4 — Prototype the Extractor

**Goal:** working extractor code on a 5k-item sample, within the serving budget.

Route to the appropriate extraction category based on the source:

- **Images**: start with zero-shot CLIP
  ([`vision-use-clip-for-zero-shot-listing-embeddings`](../vision-use-clip-for-zero-shot-listing-embeddings.md)),
  detect room type before amenities
  ([`vision-detect-room-types-before-detecting-amenities`](../vision-detect-room-types-before-detecting-amenities.md)),
  extract quality separately from content
  ([`vision-quantify-image-quality-separately-from-content`](../vision-quantify-image-quality-separately-from-content.md)),
  count objects per class
  ([`vision-extract-per-object-counts-not-just-presence`](../vision-extract-per-object-counts-not-just-presence.md)),
  and pool across the listing's full photo set
  ([`vision-pool-embeddings-across-a-listings-photo-set`](../vision-pool-embeddings-across-a-listings-photo-set.md)).

- **Listing text and metadata**: declare categorical fields
  ([`listing-declare-categorical-fields-for-bounded-vocabularies`](../listing-declare-categorical-fields-for-bounded-vocabularies.md)),
  multi-hot amenities
  ([`listing-multi-hot-encode-amenity-lists`](../listing-multi-hot-encode-amenity-lists.md)),
  hash geo
  ([`listing-hash-geo-to-hierarchies-not-raw-lat-lon`](../listing-hash-geo-to-hierarchies-not-raw-lat-lon.md)),
  embed descriptions with Sentence-Transformers
  ([`listing-embed-description-with-pretrained-sentence-encoder`](../listing-embed-description-with-pretrained-sentence-encoder.md)),
  and extract duration shape and pet triples
  ([`listing-extract-stay-duration-shape-not-just-length`](../listing-extract-stay-duration-shape-not-just-length.md),
  [`listing-encode-pet-requirements-as-structured-triples`](../listing-encode-pet-requirements-as-structured-triples.md)).

- **Sitter wizard**: restructure questions by information gain
  ([`wizard-order-questions-by-information-gain`](../wizard-order-questions-by-information-gain.md)),
  convert free text to multiple choice
  ([`wizard-prefer-multiple-choice-over-free-text`](../wizard-prefer-multiple-choice-over-free-text.md)),
  log skips
  ([`wizard-make-skips-genuine-and-log-them`](../wizard-make-skips-genuine-and-log-them.md)),
  capture experience numerically
  ([`wizard-capture-experience-as-counts-and-dates`](../wizard-capture-experience-as-counts-and-dates.md)),
  and separate hard constraints from soft preferences
  ([`wizard-separate-hard-constraints-from-soft-preferences`](../wizard-separate-hard-constraints-from-soft-preferences.md)).

Benchmark latency and memory on the prototype before declaring it viable.

**Exit criterion:** the extractor produces feature values for a 5k-item sample,
the p99 latency is within the serving budget, and the output passes a spot-check
on 20 hand-picked items.

## Step 5 — Compose Into the Target Solution

**Goal:** the feature is used by its named consumer (i2i, u2i, or u2u).

Route by consumer:

- **i2i**: fuse modalities
  ([`derive-fuse-modalities-before-item-similarity`](../derive-fuse-modalities-before-item-similarity.md))
  and precompute the shelf offline
  ([`derive-precompute-i2i-nearest-neighbours-offline`](../derive-precompute-i2i-nearest-neighbours-offline.md)).

- **u2i**: add the feature to the item tower or user tower of a two-tower model
  ([`derive-use-two-tower-for-user-item-affinity`](../derive-use-two-tower-for-user-item-affinity.md)),
  decompose into interpretable subscores
  ([`derive-decompose-affinity-into-interpretable-subscores`](../derive-decompose-affinity-into-interpretable-subscores.md)),
  and cache the user vector
  ([`derive-cache-user-embedding-with-short-ttl`](../derive-cache-user-embedding-with-short-ttl.md)).

- **u2u**: wire both sides of the mutual-fit score
  ([`derive-score-u2u-as-symmetric-mutual-fit`](../derive-score-u2u-as-symmetric-mutual-fit.md))
  so that no request is generated where the owner would reject.

**Exit criterion:** an end-to-end offline pipeline produces ranked outputs for
a representative set of queries or users, and the outputs are hand-reviewable.

## Step 6 — Register, Gate, and Productionise

**Goal:** the feature exists in a single registry, is gated on coverage and drift,
and is served by a single store for both training and inference.

Register the feature in the feature registry with owner, metric, solution,
and serving path
([`quality-version-feature-definitions-in-one-registry`](../quality-version-feature-definitions-in-one-registry.md)).
Point training and inference at the same feature store
([`quality-serve-training-and-inference-from-one-store`](../quality-serve-training-and-inference-from-one-store.md)).
Wire coverage and drift alarms
([`quality-gate-features-on-coverage-and-drift`](../quality-gate-features-on-coverage-and-drift.md)).
Scrub PII at the extraction boundary
([`quality-scrub-pii-before-features-leave-secure-zone`](../quality-scrub-pii-before-features-leave-secure-zone.md)).
Freeze the feature schema per model version
([`quality-freeze-feature-schemas-per-model-version`](../quality-freeze-feature-schemas-per-model-version.md)).

**Exit criterion:** the feature is queryable by training and serving code
through the same interface, coverage and PSI alarms are firing normally, and
schema hash is committed to the next model artifact.

## Step 7 — Ablation A/B and Decide

**Goal:** a statistically significant online decision about whether the feature earns its place.

Train two models with identical hyperparameters, one with the feature and one
without it
([`prove-measure-lift-against-feature-ablated-variant`](../prove-measure-lift-against-feature-ablated-variant.md)).
Ship the feature-included variant as treatment, the feature-excluded variant as
control — not the previous production model as control. Run exactly one feature
per experiment
([`prove-ship-one-feature-at-a-time`](../prove-ship-one-feature-at-a-time.md)).
Reserve a 3-5% exploration slice if the offline metric was close to tie
([`prove-dedicate-random-exploration-slice-to-new-features`](../prove-dedicate-random-exploration-slice-to-new-features.md)),
retain the permanent feature-free baseline slice
([`prove-retain-feature-free-baseline-permanently`](../prove-retain-feature-free-baseline-permanently.md)),
and put the feature on the next quarterly kill review
([`prove-kill-features-that-dont-earn-maintenance`](../prove-kill-features-that-dont-earn-maintenance.md)).

**Exit criterion:** a shipped decision (ship, kill, iterate) written into the
decisions log with reason, lift, confidence interval, segment breakdown, and the
next step for the feature.

## After the Cycle

Successful features graduate into permanent production and feed the downstream
skills:

- The `marketplace-personalisation` skill's recipe selection and ranking uses
  the new features via the feature store.
- The `marketplace-search-recsys-planning` skill's retrieval layer uses them for
  candidate generation and rescoring.
- The `marketplace-pre-member-personalisation` skill's pre-member ranking can
  reference them once the anonymous session has enough signal to match.

Killed features are archived and the registry entry is removed; the lessons
learned are added to [`../../gotchas.md`](../../gotchas.md) so the next
discovery cycle starts smarter.
