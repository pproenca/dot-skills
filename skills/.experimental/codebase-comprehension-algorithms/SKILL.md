---
name: codebase-comprehension-algorithms
description: Use this skill whenever mapping an unfamiliar codebase into feature/business domains — answering "what is this about", "which files implement feature X", "where is the architectural spine", or reviewing a refactor that crosses module boundaries. 47 algorithms across 9 categories — graph construction (omnipresent filter, multilayer, SCC), lexical preprocessing (Samurai, TF-IDF), community detection (Leiden, Infomap, SBM, MCL, Walktrap, spectral, HDBSCAN), architecture recovery (Bunch+MQ, ACDC, Limbo, Reflexion, DSM), topic modelling (LDA, LSI, NMF, HDP), evolutionary coupling (Gall, ROSE), information-theoretic (NCD, MI, MDL, naturalness), centrality (PageRank, HITS, betweenness, TextRank), validation (MoJoFM, ARI/NMI, resolution limit, consensus, co-change prediction, ablation). Trigger without explicit "clustering" mention — codebase grokking, dependency mapping, domain extraction, architecture-recovery validation all apply.
---

# Community Codebase Comprehension And Domain Mapping Algorithms Best Practices

A practitioner-oriented reference of the **algorithms that work for mapping a codebase into understandable feature/business domains**. Most of these techniques live in the Software Architecture Recovery and Mining Software Repositories literatures and are invisible to working engineers — yet they're the right tools for the job a coding agent is asked to do every day: *"what does this codebase do, and where?"*

The 47 rules are organized by **execution-lifecycle impact**: a wrong decision early in the pipeline (which graph to build, which identifiers to keep) propagates through everything downstream. The three CRITICAL categories (`graph-`, `clust-`, `valid-`) are the ones a wrong call cannot be recovered from later. Read them first.

**Scope**: proven algorithms with peer-reviewed citations or canonical books — Newman *Networks*, Leskovec-Rajaraman-Ullman *Mining of Massive Datasets*, Ganter-Wille *Formal Concept Analysis*, plus 40+ ICSE / FSE / TSE / PNAS / JMLR papers. No tutorial sites, no Stack Overflow, no marketing posts. Deliberately deferred to a future version: GNN/CodeBERT/code2vec (not "proven over decades" yet) and refactoring-recipe stuff (covered by sibling skills like `react-refactor` and `typescript-refactor`).

## When to Apply

Use these rules when:

- Onboarding an agent into an unfamiliar codebase: "explain what this codebase does, by domain"
- Producing an architecture map: "what are the main subsystems and how do they connect?"
- Locating a feature: "which files implement payments / authentication / search?"
- Reviewing a refactor: "did this change respect the architectural boundaries?"
- Detecting architectural debt: "what files have surprising coupling?"
- Validating an existing decomposition: "does the README's architecture match the code?"
- Picking algorithms for any of the above — the user wants something that's *proven*, not vibes

## Rule Categories By Priority

| # | Category | Prefix | Impact | What it does |
|---|----------|--------|--------|--------------|
| 1 | Graph Construction & Edge Weighting | `graph-` | CRITICAL | Which graph to build; omnipresent filter; cycle handling; multilayer |
| 2 | Community Detection & Clustering | `clust-` | CRITICAL | Leiden, Infomap, SBM, MCL, Walktrap, spectral, HDBSCAN |
| 3 | Validation & Quality Metrics | `valid-` | CRITICAL | MoJoFM, ARI/NMI, resolution limit, consensus, co-change prediction, ablation |
| 4 | Identifier & Lexical Preprocessing | `lex-` | HIGH | Samurai splitting, abbreviation expansion, TF-IDF/BM25, stemming, V-O parsing |
| 5 | Software-Specific Architecture Recovery | `arch-` | HIGH | Bunch + MQ, ACDC, Limbo, Reflexion, DSM |
| 6 | Topic Modelling on Source Code | `topic-` | HIGH | LDA, LSI/SVD, NMF, HDP, coherence-based K selection |
| 7 | Evolutionary Coupling & Co-Change Mining | `evol-` | HIGH | Lift / confidence / support, large-commit filter, temporal decay, logical coupling |
| 8 | Information-Theoretic Methods | `info-` | MEDIUM-HIGH | Normalized Compression Distance, Mutual Information, MDL, code naturalness |
| 9 | Centrality, Hierarchy & Labelling | `rank-` | MEDIUM | PageRank, HITS, betweenness, TextRank/YAKE labels |

## Quick Reference

### 1. Graph Construction & Edge Weighting (CRITICAL)

- [`graph-filter-omnipresent-utilities-before-clustering`](references/graph-filter-omnipresent-utilities-before-clustering.md) — Drop the loggers and base classes BEFORE clustering (20-40 MoJoFM points)
- [`graph-pick-edge-type-by-question-asked`](references/graph-pick-edge-type-by-question-asked.md) — Call, import, co-change, bipartite — the question determines the graph
- [`graph-collapse-sccs-before-clustering`](references/graph-collapse-sccs-before-clustering.md) — Tarjan SCC condensation makes cycles explicit and stabilises every algorithm
- [`graph-weight-edges-by-information-content`](references/graph-weight-edges-by-information-content.md) — IDF / PMI / Jaccard on edges suppresses noise (2-5× MoJoFM)
- [`graph-bipartite-file-term-for-joint-structure`](references/graph-bipartite-file-term-for-joint-structure.md) — When DI / dynamic dispatch hides the call graph
- [`graph-combine-signals-in-multilayer-graphs`](references/graph-combine-signals-in-multilayer-graphs.md) — Mucha 2010 multilayer modularity over normalised α-weighted layers

### 2. Community Detection & Clustering (CRITICAL)

- [`clust-leiden-not-louvain`](references/clust-leiden-not-louvain.md) — Louvain produces disconnected communities on 5-25% of nodes (Traag 2019)
- [`clust-infomap-mdl-on-random-walks`](references/clust-infomap-mdl-on-random-walks.md) — MDL on random walks; the right tool for flow-meaningful graphs
- [`clust-stochastic-block-model`](references/clust-stochastic-block-model.md) — Bayesian, hierarchical, learns K from data; handles non-assortative structure
- [`clust-mcl-markov-clustering`](references/clust-mcl-markov-clustering.md) — Flow simulation; dominant in bioinformatics; robust to noise
- [`clust-walktrap-short-random-walks`](references/clust-walktrap-short-random-walks.md) — Random-walk distance + hierarchical agglomerative
- [`clust-spectral-laplacian-fiedler`](references/clust-spectral-laplacian-fiedler.md) — Optimal k-way normalised cut via Laplacian eigenvectors
- [`clust-hdbscan-density-based`](references/clust-hdbscan-density-based.md) — When clustering on file embeddings, not graphs

### 3. Validation & Quality Metrics (CRITICAL)

- [`valid-mojofm-as-software-clustering-distance`](references/valid-mojofm-as-software-clustering-distance.md) — The SAR gold-standard distance metric (Wen-Tzerpos 2004)
- [`valid-adjusted-rand-index-and-nmi`](references/valid-adjusted-rand-index-and-nmi.md) — Chance-corrected cross-algorithm comparison
- [`valid-be-aware-of-resolution-limit`](references/valid-be-aware-of-resolution-limit.md) — Modularity can't see clusters smaller than √(2m) (Fortunato-Barthélemy PNAS 2007)
- [`valid-consensus-clustering-for-stability`](references/valid-consensus-clustering-for-stability.md) — A single-run answer is unreliable; consensus across runs is the right answer
- [`valid-cochange-prediction-as-ground-truth-proxy`](references/valid-cochange-prediction-as-ground-truth-proxy.md) — Temporal held-out co-change replaces missing ground truth
- [`valid-ablate-each-input-signal`](references/valid-ablate-each-input-signal.md) — Leave-one-out; reveals which input actually drives the result

### 4. Identifier & Lexical Preprocessing (HIGH)

- [`lex-split-identifiers-with-samurai`](references/lex-split-identifiers-with-samurai.md) — 87% precision vs 60% for naive camelCase (Enslen MSR 2009)
- [`lex-build-programming-language-stop-words`](references/lex-build-programming-language-stop-words.md) — Three-layer: keywords + generic + IDF-driven
- [`lex-expand-abbreviations-with-context`](references/lex-expand-abbreviations-with-context.md) — usr → user, ctx → context (Lawrie GenTest 2011)
- [`lex-tf-idf-and-bm25-on-identifiers`](references/lex-tf-idf-and-bm25-on-identifiers.md) — Raw counts are dominated by common terms; TF-IDF / BM25 fix it
- [`lex-stem-versus-subword-tokenization`](references/lex-stem-versus-subword-tokenization.md) — Porter stemmer for clustering, BPE for embeddings
- [`lex-extract-verb-object-pattern-from-method-names`](references/lex-extract-verb-object-pattern-from-method-names.md) — getUserById → (verb=get, object=user); compound concept signal

### 5. Software-Specific Architecture Recovery (HIGH)

- [`arch-bunch-with-mq-fitness`](references/arch-bunch-with-mq-fitness.md) — MQ fitness function + search; better than Q-maximization on code
- [`arch-acdc-subgraph-patterns`](references/arch-acdc-subgraph-patterns.md) — Subsystem and skeleton patterns; matches architect intuition
- [`arch-limbo-information-bottleneck`](references/arch-limbo-information-bottleneck.md) — Tishby's IB applied to software (Andritsos-Tzerpos 2005)
- [`arch-reflexion-model`](references/arch-reflexion-model.md) — Compare hypothesized vs actual; the underused gem from Murphy-Notkin 1995
- [`arch-dsm-partitioning`](references/arch-dsm-partitioning.md) — Design Structure Matrix; 60-year-old engineering technique

### 6. Topic Modelling on Source Code (HIGH)

- [`topic-lda-on-source-code`](references/topic-lda-on-source-code.md) — Probabilistic per-file topic distributions over identifier+comment text
- [`topic-lsi-svd-on-term-document`](references/topic-lsi-svd-on-term-document.md) — Deterministic SVD-based semantic embeddings (Maletic-Marcus 2001)
- [`topic-nmf-non-negative-factorization`](references/topic-nmf-non-negative-factorization.md) — Parts-based additive topics, fully reproducible
- [`topic-hdp-for-nonparametric-topic-count`](references/topic-hdp-for-nonparametric-topic-count.md) — Hierarchical Dirichlet Process — learns K from data
- [`topic-pick-topic-count-by-coherence-not-perplexity`](references/topic-pick-topic-count-by-coherence-not-perplexity.md) — Perplexity is anti-correlated with human topic quality

### 7. Evolutionary Coupling & Co-Change Mining (HIGH)

- [`evol-mine-cochange-with-lift-and-confidence`](references/evol-mine-cochange-with-lift-and-confidence.md) — Lift > 2 is the cutoff; raw co-change count is noise
- [`evol-filter-large-commits`](references/evol-filter-large-commits.md) — A 200-file commit produces 20K spurious pair-counts; filter aggressively
- [`evol-temporal-decay-on-edge-weights`](references/evol-temporal-decay-on-edge-weights.md) — Exponential decay with 6-month half-life
- [`evol-logical-coupling-as-architectural-signal`](references/evol-logical-coupling-as-architectural-signal.md) — 30-50% of strongest coupling is invisible to static analysis (Gall 1998)

### 8. Information-Theoretic Methods (MEDIUM-HIGH)

- [`info-normalized-compression-distance`](references/info-normalized-compression-distance.md) — Cluster without feature engineering; gzip-based universal similarity
- [`info-mutual-information-as-coupling`](references/info-mutual-information-as-coupling.md) — Catches non-linear / conditional coupling that lift misses
- [`info-mdl-for-model-selection`](references/info-mdl-for-model-selection.md) — Principled K selection; Occam's razor as a code length
- [`info-naturalness-of-code-as-quality-signal`](references/info-naturalness-of-code-as-quality-signal.md) — Hindle 2012 — code is 30-50% more predictable than English; bugs spike entropy

### 9. Centrality, Hierarchy & Labelling (MEDIUM)

- [`rank-pagerank-for-module-importance`](references/rank-pagerank-for-module-importance.md) — Architectural spine via PageRank on the reversed dependency graph
- [`rank-hits-hubs-and-authorities`](references/rank-hits-hubs-and-authorities.md) — Orchestrators vs implementations (Kleinberg 1999)
- [`rank-betweenness-centrality-for-bottlenecks`](references/rank-betweenness-centrality-for-bottlenecks.md) — Bridges between domains; god-class detection
- [`rank-textrank-for-cluster-labels`](references/rank-textrank-for-cluster-labels.md) — Multi-word keyphrases as cluster labels (Mihalcea-Tarau 2004, YAKE 2020)

## How to Use

Start with the question the agent is trying to answer:

- **"What are the main domains in this codebase?"** → `graph-` (pick a graph) → `clust-` (Leiden / Infomap / SBM) → `topic-` (label them) → `valid-` (sanity-check stability and ablate)
- **"Which files implement feature X?"** → `topic-lda-on-source-code` for theme location; `rank-pagerank-for-module-importance` with X's files as seed for personalized PageRank
- **"Where is the architectural spine?"** → `rank-pagerank-for-module-importance` + `rank-hits-hubs-and-authorities` on the dependency graph
- **"Does the README's architecture match the code?"** → `arch-reflexion-model` is purpose-built for this
- **"What's the *real* coupling here (beyond static dependencies)?"** → `evol-logical-coupling-as-architectural-signal` and `evol-mine-cochange-with-lift-and-confidence`
- **"How do I cluster without designing features?"** → `info-normalized-compression-distance`
- **"How big are the clusters supposed to be?"** → `valid-be-aware-of-resolution-limit` and `topic-hdp-for-nonparametric-topic-count`
- **"How do I know my decomposition is right?"** → the entire `valid-` category; multi-proxy evaluation is mandatory

The skill's worldview: **build the right graph first** (and filter omnipresent files), **pick an algorithm matching the graph and the question**, **use a code-specific preprocessing pipeline** (Samurai + stop-words + stemming + TF-IDF) where lexical signals matter, and **always validate** — MoJoFM if you have expert ground truth, consensus + co-change prediction + ablation if you don't.

Code examples are in Python because the reference implementations (networkx, igraph, leidenalg, scikit-learn, gensim, graph-tool, hdbscan) all live there. The reasoning generalises to any language.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
| [AGENTS.md](AGENTS.md) | Auto-built TOC navigation |

## Related Skills

- `computer-science-algorithms` — Algorithm-and-data-structure reference (this skill cross-references it for MinHash/LSH, Aho-Corasick, etc.)
- `complexity-optimizer` — Static analysis for hot paths the rules here identify
- `design-to-react-algorithms` — Companion skill for design-to-code structural recovery
