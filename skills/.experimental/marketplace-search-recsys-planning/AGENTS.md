# Two-Sided Search and Recsys Planning

**Version 0.1.0**  
Marketplace Engineering  
April 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Planning, design and diagnostic guide for search and recommendation systems in two-sided trust marketplaces built on OpenSearch. Contains 57 rules across 10 categories ordered by cascade impact on the retrieval lifecycle — from user-intent framing and product-surface architecture through OpenSearch index and query design, CDC ingestion, embedding-model selection, retrieval strategy, ranking, search-plus-recs blending, measurement, PII scrubbing and the instrumentation-and-dashboard layer that turns measurement into ongoing decision making. Includes two playbooks for planning a new retrieval system from scratch and diagnosing an existing one, plus explicit living-artefact conventions (decisions log, golden set, gotchas) so context accumulates across sessions, releases, and team changes. Functions as the precursor to the companion marketplace-personalisation skill with an explicit hand-off rule.

---

## Table of Contents

1. [Problem Framing and User Intent](references/_sections.md#1-problem-framing-and-user-intent) — **CRITICAL**
   - 1.1 [Audit Live Query Logs Before Designing](references/intent-audit-live-query-logs-first.md) — CRITICAL (prevents designing for imagined users)
   - 1.2 [Distinguish Transactional from Exploratory Intent](references/intent-distinguish-transactional-from-exploratory.md) — CRITICAL (prevents conversion loss on transactional sessions)
   - 1.3 [Map Queries to Intent Classes Before Touching Retrieval](references/intent-map-queries-to-intent-classes.md) — CRITICAL (prevents retrieval-strategy mismatch with user goal)
   - 1.4 [Reject the One-Search-For-Everything Temptation](references/intent-reject-one-search-for-everything.md) — CRITICAL (prevents system-wide compromise)
   - 1.5 [Separate Known-Item Search from Discovery](references/intent-separate-known-item-from-discovery.md) — CRITICAL (prevents recall loss on known-item queries)
   - 1.6 [Treat No-Search as a First-Class Choice](references/intent-treat-no-search-as-first-class-choice.md) — CRITICAL (prevents forcing retrieval where browse is correct)
2. [Surface Taxonomy and Architecture](references/_sections.md#2-surface-taxonomy-and-architecture) — **CRITICAL**
   - 2.1 [Avoid Mono-Stack Retrieval](references/arch-avoid-mono-stack-retrieval.md) — CRITICAL (prevents single-point-of-failure in retrieval)
   - 2.2 [Declare a Fallback Owner per Surface at Architecture Time](references/arch-design-zero-result-fallback.md) — CRITICAL (prevents fallback gaps on new surfaces)
   - 2.3 [Design for Cold Start from Day One](references/arch-design-for-cold-start-from-day-one.md) — CRITICAL (prevents new-listing discovery failure)
   - 2.4 [Map Each Surface to a Retrieval Primitive Deliberately](references/arch-map-surface-to-retrieval-primitive.md) — CRITICAL (prevents architectural drift across surfaces)
   - 2.5 [Route Surfaces to Search, Recs, or Hybrid Deliberately](references/arch-route-surfaces-deliberately.md) — CRITICAL (prevents ad-hoc routing drift)
   - 2.6 [Split Candidate Generation from Ranking](references/arch-split-candidate-generation-from-ranking.md) — CRITICAL (enables independent tuning of retrieval and ranking)
3. [Index Design and Mapping](references/_sections.md#3-index-design-and-mapping) — **HIGH**
   - 3.1 [Design Mappings Conservatively Because Reindex Is Expensive](references/index-design-mappings-conservatively.md) — HIGH (avoids full reindex downtime)
   - 3.2 [Match Index-Time and Query-Time Analyzers](references/index-match-index-and-query-time-analyzers.md) — HIGH (prevents tokenisation mismatch at query time)
   - 3.3 [Separate Searchable Fields from Display Fields](references/index-separate-searchable-from-display-fields.md) — HIGH (reduces index storage and query cost)
   - 3.4 [Stream Listing Updates via CDC, Not Periodic Full Re-Import](references/index-stream-listing-updates-via-cdc.md) — HIGH (reduces index staleness from hours to seconds)
   - 3.5 [Use Index Templates to Enforce Consistency](references/index-use-index-templates-for-consistency.md) — HIGH (prevents mapping drift across indices)
   - 3.6 [Use keyword and text as Multi-Fields](references/index-use-keyword-and-text-as-multi-fields.md) — HIGH (enables exact match and full-text on one field)
   - 3.7 [Use Language Analyzers for Language-Sensitive Fields](references/index-use-language-analyzers-for-language-fields.md) — HIGH (enables language-aware stemming and stopwords)
4. [Planning and Improvement Methodology](references/_sections.md#4-planning-and-improvement-methodology) — **HIGH**
   - 4.1 [Audit Before You Build — Gate Work on Instrumentation Readiness](references/plan-audit-before-you-build.md) — HIGH (prevents building on broken telemetry)
   - 4.2 [Build a Golden Query Set as the First Artefact](references/plan-build-golden-query-set-first.md) — HIGH (enables offline regression detection)
   - 4.3 [Find the Bottleneck Before Optimising](references/plan-find-bottleneck-before-optimising.md) — HIGH (prevents work on non-bottleneck layers)
   - 4.4 [Freeze and Version the Golden Set per Evaluation Cycle](references/plan-version-the-golden-set.md) — HIGH (enables comparable evaluations across releases)
   - 4.5 [Hand Off to the Personalisation Skill When the Bottleneck Is Personalisation](references/plan-handoff-to-personalisation-skill.md) — HIGH (prevents duplicated planning effort)
   - 4.6 [Maintain a Decisions Log as Living Context](references/plan-maintain-a-decisions-log.md) — HIGH (prevents lost context across team changes)
5. [Query Understanding](references/_sections.md#5-query-understanding) — **MEDIUM-HIGH**
   - 5.1 [Build Autocomplete on a Separate Index](references/query-build-autocomplete-on-separate-index.md) — MEDIUM-HIGH (prevents autocomplete latency from blocking main search)
   - 5.2 [Classify Queries Before Routing](references/query-classify-before-routing.md) — MEDIUM-HIGH (enables intent-aware routing)
   - 5.3 [Curate Synonyms by Domain Intent](references/query-curate-synonyms-by-domain.md) — MEDIUM-HIGH (enables domain-specific recall)
   - 5.4 [Normalise Queries Before Anything Else](references/query-normalise-before-anything-else.md) — MEDIUM-HIGH (prevents unicode and whitespace misses)
   - 5.5 [Use Fuzzy Matching for Typo Tolerance](references/query-use-fuzzy-matching-for-typos.md) — MEDIUM-HIGH (prevents recall loss on typos)
   - 5.6 [Use Language Analyzers for Stemming and Stopwords](references/query-use-language-analyzers-for-stemming.md) — MEDIUM-HIGH (enables stemming and stopword removal)
6. [Retrieval Strategy](references/_sections.md#6-retrieval-strategy) — **MEDIUM-HIGH**
   - 6.1 [Choose the Embedding Model Deliberately Before Hybrid Search](references/retrieve-choose-embedding-model-deliberately.md) — MEDIUM-HIGH (avoids full re-embedding on model change)
   - 6.2 [Combine BM25 and KNN via Hybrid Search](references/retrieve-combine-bm25-and-knn-via-hybrid-search.md) — MEDIUM-HIGH (enables semantic plus lexical recall)
   - 6.3 [Paginate with search_after for Deep Result Sets](references/retrieve-paginate-with-search-after.md) — MEDIUM-HIGH (prevents deep-pagination memory cost)
   - 6.4 [Run Expensive Signals in rescore](references/retrieve-run-expensive-signals-in-rescore.md) — MEDIUM-HIGH (reduces scoring cost on full candidate set)
   - 6.5 [Use bool Structure Deliberately](references/retrieve-use-bool-structure-deliberately.md) — MEDIUM-HIGH (prevents ambiguous clause semantics)
   - 6.6 [Use filter Clauses for Exact Matches](references/retrieve-use-filter-clauses-for-exact-matches.md) — MEDIUM-HIGH (enables query result caching)
7. [Relevance and Ranking](references/_sections.md#7-relevance-and-ranking) — **MEDIUM-HIGH**
   - 7.1 [Apply Diversity at Rank Time, Not Retrieval](references/rank-apply-diversity-at-rank-time.md) — MEDIUM-HIGH (preserves retrieval recall for diversity)
   - 7.2 [Deploy Learning to Rank Only After Golden Set and Judgments Exist](references/rank-deploy-ltr-only-after-golden-set-exists.md) — MEDIUM-HIGH (prevents premature LTR complexity)
   - 7.3 [Normalise Scores Across Retrieval Primitives](references/rank-normalise-scores-across-retrieval-primitives.md) — MEDIUM-HIGH (enables comparable hybrid ranking)
   - 7.4 [Tune BM25 Parameters Last, Not First](references/rank-tune-bm25-parameters-last.md) — MEDIUM-HIGH (prevents premature micro-optimisation)
   - 7.5 [Use function_score for Business Signals](references/rank-use-function-score-for-business-signals.md) — MEDIUM-HIGH (enables explainable business ranking)
8. [Search and Recommender Blending](references/_sections.md#8-search-and-recommender-blending) — **MEDIUM**
   - 8.1 [Combine Search and Personalisation Scores with Normalised Weights](references/blend-combine-search-and-personalisation-scores.md) — MEDIUM (enables comparable hybrid ranking)
   - 8.2 [Keep Hybrid Blending Explainable](references/blend-keep-hybrid-blending-explainable.md) — MEDIUM (enables blending debugging and tuning)
   - 8.3 [Never Return Zero Results](references/blend-never-return-zero-results.md) — MEDIUM (prevents dead-end sessions)
   - 8.4 [Use Search Alone When Intent Is Specific](references/blend-use-search-alone-for-specific-intent.md) — MEDIUM (prevents noise on precision-oriented queries)
9. [Measurement and Experimentation](references/_sections.md#9-measurement-and-experimentation) — **MEDIUM**
   - 9.1 [Define Session Success per Surface](references/measure-define-session-success-per-surface.md) — MEDIUM (enables surface-specific measurement)
   - 9.2 [Run Interleaving as a Cheap A/B Proxy](references/measure-run-interleaving-as-cheap-ab-proxy.md) — MEDIUM (reduces experiment sample-size cost)
   - 9.3 [Track NDCG, MRR and Zero-Result Rate](references/measure-track-ndcg-mrr-zero-result-rate.md) — MEDIUM (enables ranking-quality measurement)
   - 9.4 [Track Reformulation Rate as a Failure Signal](references/measure-track-reformulation-rate-as-failure-signal.md) — MEDIUM (enables implicit query-failure detection)
   - 9.5 [Use Click Models for Implicit Relevance Judgments](references/measure-use-click-models-for-implicit-judgments.md) — MEDIUM (enables scalable judgment collection)
10. [Instrumentation, Dashboards and Decision Triggers](references/_sections.md#10-instrumentation,-dashboards-and-decision-triggers) — **MEDIUM**
   - 10.1 [Alert on Decision-Triggering Metrics, Not Just Error Rates](references/monitor-alert-on-decision-triggers.md) — MEDIUM (enables early quality regression detection)
   - 10.2 [Build a Search Health Dashboard with Threshold Lines](references/monitor-build-search-health-dashboard.md) — MEDIUM (enables at-a-glance quality monitoring)
   - 10.3 [Log Every Query with Full Context for Counterfactual Replay](references/monitor-log-every-query-with-full-context.md) — MEDIUM (enables post-hoc query debugging)
   - 10.4 [Run a Weekly Search-Quality Review Ritual](references/monitor-run-weekly-search-quality-review.md) — MEDIUM (enables calendar-driven decision making)
   - 10.5 [Scrub PII from Query Logs Before Warehouse Ingestion](references/monitor-scrub-pii-from-query-logs.md) — MEDIUM (prevents GDPR exposure in analytics)
   - 10.6 [Track Ranking Stability as a Churn Metric](references/monitor-track-ranking-stability-churn.md) — MEDIUM (enables leading-indicator detection)

---

## References

1. [https://docs.opensearch.org/latest/query-dsl/compound/bool/](https://docs.opensearch.org/latest/query-dsl/compound/bool/)
2. [https://docs.opensearch.org/latest/query-dsl/query-filter-context/](https://docs.opensearch.org/latest/query-dsl/query-filter-context/)
3. [https://docs.opensearch.org/latest/query-dsl/rescore/](https://docs.opensearch.org/latest/query-dsl/rescore/)
4. [https://docs.opensearch.org/latest/analyzers/](https://docs.opensearch.org/latest/analyzers/)
5. [https://docs.opensearch.org/latest/analyzers/custom-analyzer/](https://docs.opensearch.org/latest/analyzers/custom-analyzer/)
6. [https://docs.opensearch.org/latest/analyzers/language-analyzers/index/](https://docs.opensearch.org/latest/analyzers/language-analyzers/index/)
7. [https://docs.opensearch.org/latest/analyzers/language-analyzers/english/](https://docs.opensearch.org/latest/analyzers/language-analyzers/english/)
8. [https://docs.opensearch.org/latest/vector-search/ai-search/hybrid-search/index/](https://docs.opensearch.org/latest/vector-search/ai-search/hybrid-search/index/)
9. [https://opensearch.org/blog/building-effective-hybrid-search-in-opensearch-techniques-and-best-practices/](https://opensearch.org/blog/building-effective-hybrid-search-in-opensearch-techniques-and-best-practices/)
10. [https://opensearch.org/blog/multilingual-search/](https://opensearch.org/blog/multilingual-search/)
11. [https://docs.aws.amazon.com/opensearch-service/latest/developerguide/learning-to-rank.html](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/learning-to-rank.html)
12. [https://aws.amazon.com/blogs/big-data/hybrid-search-with-amazon-opensearch-service/](https://aws.amazon.com/blogs/big-data/hybrid-search-with-amazon-opensearch-service/)
13. [https://www.manning.com/books/relevant-search](https://www.manning.com/books/relevant-search)
14. [https://opensourceconnections.com/blog/2019/12/11/what-is-a-relevant-search-result/](https://opensourceconnections.com/blog/2019/12/11/what-is-a-relevant-search-result/)
15. [https://eugeneyan.com/writing/recsys-llm/](https://eugeneyan.com/writing/recsys-llm/)
16. [https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
17. [https://pubsonline.informs.org/doi/10.1287/mksc.2022.0238](https://pubsonline.informs.org/doi/10.1287/mksc.2022.0238)
18. [https://www.pinecone.io/learn/offline-evaluation/](https://www.pinecone.io/learn/offline-evaluation/)
19. [https://developers.google.com/machine-learning/guides/rules-of-ml](https://developers.google.com/machine-learning/guides/rules-of-ml)
20. [https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/](https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/)
21. [https://docs.opensearch.org/latest/field-types/](https://docs.opensearch.org/latest/field-types/)
22. [https://docs.opensearch.org/latest/search-plugins/searching-data/paginate/](https://docs.opensearch.org/latest/search-plugins/searching-data/paginate/)
23. [https://sre.google/sre-book/embracing-risk/](https://sre.google/sre-book/embracing-risk/)
24. [https://sbert.net/examples/sentence_transformer/domain_adaptation/README.html](https://sbert.net/examples/sentence_transformer/domain_adaptation/README.html)
25. [https://eugeneyan.com/writing/system-design-for-discovery/](https://eugeneyan.com/writing/system-design-for-discovery/)
26. [https://lantern.splunk.com/Security/UCE/Foundational_Visibility/Compliance/Detecting_Personally_Identifiable_Information_(PII)_in_log_data_for_GDPR_compliance](https://lantern.splunk.com/Security/UCE/Foundational_Visibility/Compliance/Detecting_Personally_Identifiable_Information_(PII)_in_log_data_for_GDPR_compliance)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |