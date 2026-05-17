# codebase comprehension and domain mapping algorithms

**Version 0.1.0**  
Community  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when applying codebase comprehension and domain mapping algorithms — choosing the right graph, clustering algorithm, lexical preprocessing, topic model, and validation strategy when grokking an unfamiliar codebase. Humans may also find it useful, but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

A practitioner-oriented reference of 47 algorithms across 9 categories for mapping a codebase into understandable feature/business domains — graph construction (omnipresent filter, multilayer, SCC condensation, edge weighting), lexical preprocessing (Samurai identifier splitting, abbreviation expansion, TF-IDF/BM25, stemming, V-O parsing), community detection (Leiden over Louvain, Infomap, Stochastic Block Models, MCL, Walktrap, spectral, HDBSCAN), software-specific architecture recovery (Bunch + MQ, ACDC, Limbo, Reflexion, DSM), topic modelling on source (LDA, LSI/SVD, NMF, HDP, coherence-based K selection), evolutionary coupling from version history (lift/support/confidence, large-commit filtering, temporal decay, logical coupling), information-theoretic methods (Normalized Compression Distance, Mutual Information, MDL, code naturalness), centrality and labelling (PageRank, HITS, betweenness, TextRank/YAKE), and validation (MoJoFM, Adjusted Rand Index, Normalized Mutual Information, resolution-limit awareness, consensus clustering, co-change prediction as ground-truth proxy, ablation). Every rule cites peer-reviewed sources (ICSE / FSE / TSE / JMLR / PNAS) or canonical books. Designed for AI agents asked to grok an unfamiliar codebase and report what each part of it actually does.

---

## Table of Contents

1. [Graph Construction & Edge Weighting](references/_sections.md#1-graph-construction-&-edge-weighting) — **CRITICAL**
   - 1.1 [Build A Bipartite File × Term Graph When Identifiers Carry The Signal](references/graph-bipartite-file-term-for-joint-structure.md) — HIGH (10-20 MoJoFM points on heavily-DI codebases where static call-graph misses 30-60% of edges)
   - 1.2 [Collapse Strongly Connected Components Before Clustering](references/graph-collapse-sccs-before-clustering.md) — CRITICAL (turns a tangled multigraph into a DAG and prevents clusters from being split mid-cycle)
   - 1.3 [Combine Structural, Lexical and Co-Change Signals As A Multilayer Graph](references/graph-combine-signals-in-multilayer-graphs.md) — HIGH (15-30% MoJoFM improvement over single-signal clustering on real codebases (Beck-Diehl EMSE 2013))
   - 1.4 [Filter Omnipresent Utilities Before Clustering](references/graph-filter-omnipresent-utilities-before-clustering.md) — CRITICAL (removes ~5–15% of files that absorb 50%+ of edges and dominate every cluster)
   - 1.5 [Pick The Edge Type By The Question You're Asking](references/graph-pick-edge-type-by-question-asked.md) — CRITICAL (30-50% disagreement between structural and co-change clusterings on the same codebase (Beck-Diehl 2013))
   - 1.6 [Weight Edges By Information Content, Not Raw Frequency](references/graph-weight-edges-by-information-content.md) — CRITICAL (2–5x MoJoFM improvement over unweighted graphs by suppressing high-fan-in noise)
2. [Community Detection & Clustering](references/_sections.md#2-community-detection-&-clustering) — **CRITICAL**
   - 2.1 [Use HDBSCAN For Density-Based Clustering On File Embeddings](references/clust-hdbscan-density-based.md) — MEDIUM-HIGH (handles varying cluster densities; eliminates the need to pick K; 10-15 NMI points over k-means on file embeddings)
   - 2.2 [Use Infomap When You Want To Compress Flow, Not Maximize Modularity](references/clust-infomap-mdl-on-random-walks.md) — CRITICAL (10-25% NMI improvement over Leiden on directed flow-meaningful graphs)
   - 2.3 [Use Leiden, Not Louvain — Louvain Produces Disconnected Communities](references/clust-leiden-not-louvain.md) — CRITICAL (Louvain returns mathematically guaranteed-broken clusters on 5-25% of nodes; Leiden fixes this with no extra cost)
   - 2.4 [Use MCL (Markov Clustering) For Flow Simulation On Sparse Graphs](references/clust-mcl-markov-clustering.md) — MEDIUM-HIGH (15-30% improvement on noise-injected networks (Brohée-van Helden 2006); eliminates K hyperparameter)
   - 2.5 [Use Spectral Clustering When Cuts And Algebraic Connectivity Matter](references/clust-spectral-laplacian-fiedler.md) — MEDIUM (computes optimal k-way normalized cut in O(N²) eigendecomp; reveals algebraic connectivity λ₂)
   - 2.6 [Use Stochastic Block Models For Principled Bayesian Decomposition](references/clust-stochastic-block-model.md) — HIGH (NMI 0.7-0.9 vs 0.1 for modularity on non-assortative structure (Peixoto 2014); eliminates resolution limit)
   - 2.7 [Use Walktrap When You Want Communities Defined By Short Random Walks](references/clust-walktrap-short-random-walks.md) — MEDIUM (O(n² log n) hierarchical, distance metric grounded in random-walk probabilities)
3. [Validation & Quality Metrics](references/_sections.md#3-validation-&-quality-metrics) — **CRITICAL**
   - 3.1 [Ablate Each Input Signal And Measure The Drop In Quality](references/valid-ablate-each-input-signal.md) — MEDIUM-HIGH (reveals which input signals carry signal vs noise; eliminates unhelpful components from the pipeline)
   - 3.2 [Be Aware Of The Resolution Limit Of Modularity Maximization](references/valid-be-aware-of-resolution-limit.md) — CRITICAL (prevents modularity Q from detecting clusters smaller than sqrt(2m); affects every codebase with > 10000 edges)
   - 3.3 [Use Adjusted Rand Index And Normalized Mutual Information For Cross-Algorithm Comparison](references/valid-adjusted-rand-index-and-nmi.md) — HIGH (chance-adjusted clustering similarity; reduces inflated baseline of plain Rand index by 0.6-0.9)
   - 3.4 [Use Co-Change Prediction As A Ground-Truth Proxy When No Expert Labels Exist](references/valid-cochange-prediction-as-ground-truth-proxy.md) — HIGH (eliminates need for expert ground-truth labelling; lift > 2 against random is the minimum bar)
   - 3.5 [Use Consensus Clustering To Measure And Improve Stability](references/valid-consensus-clustering-for-stability.md) — HIGH (reduces single-run variance; 0.70 → 0.85 NMI on LFR benchmark across 50 runs (Lancichinetti-Fortunato 2012))
   - 3.6 [Use MoJoFM As The Canonical Distance Between Software Clusterings](references/valid-mojofm-as-software-clustering-distance.md) — CRITICAL (reduces cross-algorithm comparison to a single 0-100 score; the SAR gold-standard since 2004)
4. [Identifier & Lexical Preprocessing](references/_sections.md#4-identifier-&-lexical-preprocessing) — **HIGH**
   - 4.1 [Build A Stop-Word List Specific To Programming Languages](references/lex-build-programming-language-stop-words.md) — HIGH (removes 30-50% of token volume that carries no domain signal ("get", "data", "manager"))
   - 4.2 [Expand Abbreviations With Context Before Computing Similarity](references/lex-expand-abbreviations-with-context.md) — HIGH (recovers 10-20% of identifier tokens that were lost to abbreviation; usr → user, ctx → context)
   - 4.3 [Extract Verb-Object Pattern From Method Names For Concept Mining](references/lex-extract-verb-object-pattern-from-method-names.md) — MEDIUM-HIGH (surfaces 70%+ of "what this code does to what" semantics that pure bag-of-tokens loses)
   - 4.4 [Split Identifiers With Samurai, Not Just Regex](references/lex-split-identifiers-with-samurai.md) — HIGH (87% accuracy on hard splits vs ~60% for camelCase regex alone (Enslen et al., MSR 2009))
   - 4.5 [Stem Or Subword-Tokenize To Collapse Morphological Variants](references/lex-stem-versus-subword-tokenization.md) — MEDIUM-HIGH (collapses 20-40% vocabulary inflation from singular/plural/tense variation)
   - 4.6 [Use TF-IDF Or BM25 To Weight Identifier Tokens, Not Raw Counts](references/lex-tf-idf-and-bm25-on-identifiers.md) — HIGH (2-3x improvement in topic coherence and clustering quality over raw token frequency)
5. [Software-Specific Architecture Recovery](references/_sections.md#5-software-specific-architecture-recovery) — **HIGH**
   - 5.1 [Use ACDC's Subgraph Patterns To Recover Subsystem And Skeleton Structure](references/arch-acdc-subgraph-patterns.md) — HIGH (recovers MoJoFM 75+ vs 40-55% for statistical methods on standard SAR benchmarks)
   - 5.2 [Use Bunch's Modularization Quality As A Software-Specific Fitness Function](references/arch-bunch-with-mq-fitness.md) — HIGH (improves MoJoFM by 5-15% over Q-maximization on standard SAR benchmarks (Mitchell-Mancoridis TSE 2006))
   - 5.3 [Use Design Structure Matrix Partitioning To Find Block-Diagonal Architecture](references/arch-dsm-partitioning.md) — MEDIUM-HIGH (reduces architecture analysis to block-diagonal matrix inspection in O(V+E); reveals cycles and layers)
   - 5.4 [Use Limbo To Cluster Files By Preserving Information About Their Features](references/arch-limbo-information-bottleneck.md) — HIGH (2-5× faster than Bunch with comparable MoJoFM; applies Information Bottleneck principle to clustering)
   - 5.5 [Use The Reflexion Model To Compare Hypothesized vs Actual Architecture](references/arch-reflexion-model.md) — HIGH (reduces architecture recovery from months to days; reveals 80% of debt in 4-6 hours (Murphy-Notkin FSE 1995))
6. [Topic Modelling on Source Code](references/_sections.md#6-topic-modelling-on-source-code) — **HIGH**
   - 6.1 [Pick The Number Of Topics By Coherence, Not Perplexity](references/topic-pick-topic-count-by-coherence-not-perplexity.md) — HIGH (perplexity is 43% anti-correlated with human topic quality; C_V coherence correlates 79% (Röder 2015))
   - 6.2 [Use Hierarchical Dirichlet Processes To Learn The Right Number Of Topics](references/topic-hdp-for-nonparametric-topic-count.md) — MEDIUM-HIGH (eliminates K hyperparameter; infers number of topics from data at 2-3× LDA's cost)
   - 6.3 [Use LDA On Source Code To Surface Latent Domain Topics](references/topic-lda-on-source-code.md) — HIGH (60-85% topic-domain alignment with expert labels on Java systems (Linstead ICSM 2007))
   - 6.4 [Use LSI / Truncated SVD When You Need Deterministic Semantic Embeddings](references/topic-lsi-svd-on-term-document.md) — HIGH (5-10× faster than LDA; produces deterministic embeddings for similarity queries)
   - 6.5 [Use Non-Negative Matrix Factorization When You Need Strictly-Positive Topic Weights](references/topic-nmf-non-negative-factorization.md) — MEDIUM-HIGH (deterministic alternative to LDA; 5× faster convergence with parts-based additive interpretation)
7. [Evolutionary Coupling & Co-Change Mining](references/_sections.md#7-evolutionary-coupling-&-co-change-mining) — **HIGH**
   - 7.1 [Apply Temporal Decay So Old Co-Change Counts Less Than Recent](references/evol-temporal-decay-on-edge-weights.md) — MEDIUM-HIGH (5-8% MoJoFM improvement on 6-month half-life vs un-weighted (Beck-Diehl EMSE 2013))
   - 7.2 [Filter Out Large Commits Before Mining Co-Change](references/evol-filter-large-commits.md) — HIGH (a single 200-file commit inflates pair counts by 200·199/2 ≈ 20K; filter aggressively)
   - 7.3 [Mine Co-Change With Lift And Confidence, Not Raw Co-Occurrence Count](references/evol-mine-cochange-with-lift-and-confidence.md) — HIGH (15-25% precision lift over raw co-change counts; lift > 2 captures meaningful coupling)
   - 7.4 [Treat Logical Coupling As The Architectural Signal Static Analysis Misses](references/evol-logical-coupling-as-architectural-signal.md) — HIGH (30-50% of strongest software coupling is invisible to static analysis (Gall ICSM 1998))
8. [Information-Theoretic Methods](references/_sections.md#8-information-theoretic-methods) — **MEDIUM-HIGH**
   - 8.1 [Use Code Naturalness (N-gram Entropy) As A Codebase-Health Signal](references/info-naturalness-of-code-as-quality-signal.md) — MEDIUM (code is 30-50% more predictable than English; buggy regions show 10-30% entropy spike (Hindle ICSE 2012))
   - 8.2 [Use Minimum Description Length To Pick Number Of Clusters Or Topics](references/info-mdl-for-model-selection.md) — MEDIUM-HIGH (eliminates K hyperparameter via information-theoretic trade-off; consistent as N → ∞ (Rissanen 1986))
   - 8.3 [Use Mutual Information To Measure Coupling Without Edge Counts](references/info-mutual-information-as-coupling.md) — MEDIUM (captures non-linear, conditional, and time-shifted coupling that lift misses in 10-25% of pairs)
   - 8.4 [Use Normalized Compression Distance For Feature-Free Similarity](references/info-normalized-compression-distance.md) — MEDIUM-HIGH (eliminates feature engineering; approximates Kolmogorov-complexity similarity in O(n) via gzip)
9. [Centrality, Hierarchy & Labelling](references/_sections.md#9-centrality,-hierarchy-&-labelling) — **MEDIUM**
   - 9.1 [Use Betweenness Centrality To Find Cross-Domain Bottlenecks](references/rank-betweenness-centrality-for-bottlenecks.md) — MEDIUM (O(V·E) — finds files that connect clusters; surprise edges often signal architectural debt)
   - 9.2 [Use HITS To Distinguish Orchestrators (Hubs) From Implementations (Authorities)](references/rank-hits-hubs-and-authorities.md) — MEDIUM (separates orchestrators from implementations in O((V+E)·iter); orthogonal to PageRank)
   - 9.3 [Use PageRank On The Dependency Graph To Find Architecturally Central Modules](references/rank-pagerank-for-module-importance.md) — MEDIUM (O((V+E)·iters) — identifies the "spine" modules whose removal ripples through everything)
   - 9.4 [Use TextRank Or YAKE To Generate Human-Readable Cluster Labels](references/rank-textrank-for-cluster-labels.md) — MEDIUM (65-80% match with expert-named modules vs 40-55% for top-TF-IDF (Linstead ICSM 2007))

---

## References

1. [https://mitpress.mit.edu/9780262048828/networks/](https://mitpress.mit.edu/9780262048828/networks/)
2. [http://www.mmds.org/](http://www.mmds.org/)
3. [https://link.springer.com/book/10.1007/978-3-540-25910-3](https://link.springer.com/book/10.1007/978-3-540-25910-3)
4. [https://www.nature.com/articles/s41598-019-41695-z](https://www.nature.com/articles/s41598-019-41695-z)
5. [https://www.pnas.org/doi/10.1073/pnas.0706851105](https://www.pnas.org/doi/10.1073/pnas.0706851105)
6. [https://www.pnas.org/doi/10.1073/pnas.0605965104](https://www.pnas.org/doi/10.1073/pnas.0605965104)
7. [https://arxiv.org/abs/1705.10225](https://arxiv.org/abs/1705.10225)
8. [https://www.jmlr.org/papers/v3/blei03a.html](https://www.jmlr.org/papers/v3/blei03a.html)
9. [https://www.jmlr.org/papers/v11/vinh10a.html](https://www.jmlr.org/papers/v11/vinh10a.html)
10. [https://dl.acm.org/doi/10.1145/222124.222147](https://dl.acm.org/doi/10.1145/222124.222147)
11. [https://ieeexplore.ieee.org/document/1463238](https://ieeexplore.ieee.org/document/1463238)
12. [https://ieeexplore.ieee.org/document/1357809](https://ieeexplore.ieee.org/document/1357809)
13. [https://ieeexplore.ieee.org/document/6227135](https://ieeexplore.ieee.org/document/6227135)
14. [https://www.cs.yorku.ca/~bil/papers/wcre00.pdf](https://www.cs.yorku.ca/~bil/papers/wcre00.pdf)
15. [https://www.cs.toronto.edu/~periklis/pubs/wcre03.pdf](https://www.cs.toronto.edu/~periklis/pubs/wcre03.pdf)
16. [https://ieeexplore.ieee.org/document/1412045](https://ieeexplore.ieee.org/document/1412045)
17. [https://link.springer.com/article/10.1007/s10664-012-9220-1](https://link.springer.com/article/10.1007/s10664-012-9220-1)
18. [https://www.sciencedirect.com/science/article/pii/S0020025519308588](https://www.sciencedirect.com/science/article/pii/S0020025519308588)
19. [https://www.hindawi.com/journals/ase/2012/792024/](https://www.hindawi.com/journals/ase/2012/792024/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |