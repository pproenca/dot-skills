# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Order is by impact (CRITICAL → MEDIUM). The codebase-comprehension pipeline runs roughly `ingest → preprocess (lex) → construct graph → cluster → enrich-with-topics → rank → validate`, but the three CRITICAL sections are the ones a wrong decision cannot be recovered from later: a poisoned graph, a wrong-class clustering algorithm, or no validation at all. Read those first.

---

## 1. Graph Construction & Edge Weighting (graph)

**Impact:** CRITICAL  
**Description:** The first and most consequential decision: which graph you build determines what a "cluster" can possibly mean. Call graph, import graph, co-change graph, and file × vocabulary bipartite graphs all surface different structures, and the right choice of edge semantics, weighting, and noise filtering (omnipresent utilities, cycles, fan-in giants) propagates through every downstream algorithm. A poisoned graph is irrecoverable — no clustering or topic model can extract a signal that isn't in the input.

## 2. Community Detection & Clustering (clust)

**Impact:** CRITICAL  
**Description:** The core decomposition step, and the place where algorithm choice has order-of-magnitude consequences. Generic community detection on graphs (Louvain, Leiden, Infomap, Stochastic Block Models, MCL, Walktrap, spectral) and density-based clustering on embeddings (HDBSCAN) each have very different inductive biases — null-model–based, MDL-based, Bayesian, flow-based — and the wrong one against your graph silently produces "communities" that mean nothing.

## 3. Validation & Quality Metrics (valid)

**Impact:** CRITICAL  
**Description:** Without validation, the entire pipeline is theatre. MoJoFM (Wen-Tzerpos, TSE 2004) is the gold-standard distance metric between software clusterings; Adjusted Rand Index and Normalized Mutual Information measure agreement with ground truth; Newman's modularity Q with awareness of the Fortunato-Barthélemy resolution limit measures intrinsic quality; consensus clustering across runs measures stability; predicted co-change is a ground-truth proxy when no expert labels exist. CRITICAL impact because nothing else in this skill is trustworthy without it — placed third despite running at the end of the pipeline.

## 4. Identifier & Lexical Preprocessing (lex)

**Impact:** HIGH  
**Description:** Source-code identifiers and comments are the cheapest and densest semantic signal in a codebase, but they need real preprocessing — camelCase / snake_case splitting (and Samurai-style splitting for hard cases), abbreviation expansion, programming-language stop-words, stemming, and information-theoretic weighting (TF-IDF, BM25) — before any topic model or lexical edge can be trusted. Skip this and topic models surface "data", "info", "manager", "util" as the dominant terms.

## 5. Software-Specific Architecture Recovery (arch)

**Impact:** HIGH  
**Description:** Algorithms designed specifically for source code, not general graphs. Bunch's Modularization Quality fitness function, ACDC's subgraph-pattern matching, Limbo's information-bottleneck clustering, Murphy-Notkin-Sullivan reflexion modeling, and Steward-Eppinger DSM partitioning encode software-engineering priors (omnipresent utilities, hierarchy, subsystem patterns, hypothesis-vs-reality) that generic graph algorithms don't. They are the result of 25+ years of focused research and outperform off-the-shelf community detection on code-shaped inputs.

## 6. Topic Modelling on Source Code (topic)

**Impact:** HIGH  
**Description:** Once you have clusters, you have to *name* them — and the same machinery surfaces themes directly from identifier and comment text. Latent Semantic Indexing (Maletic-Marcus, 2001), Latent Dirichlet Allocation (Blei et al., 2003), Non-negative Matrix Factorization, and Hierarchical Dirichlet Processes for non-parametric topic counts each project the file × term matrix into a low-rank semantic space. Coherence (NPMI / UMass) — not perplexity — is the right model-selection criterion. Scope: latent topics over identifier/comment corpora; the broader information-theoretic toolbox lives in the `info` category.

## 7. Evolutionary Coupling & Co-Change Mining (evol)

**Impact:** HIGH  
**Description:** Files that change together belong together. Logical Coupling (Gall et al., 1998) and frequent-itemset mining on commit history (Zimmermann's ROSE, ICSE 2004) often beat static analysis at recovering true coupling because they capture *intent* — what developers treat as one feature — rather than syntax. The non-obvious parts are filtering large commits, applying temporal decay, and computing lift / support / confidence rather than raw co-change count.

## 8. Information-Theoretic Methods (info)

**Impact:** MEDIUM-HIGH  
**Description:** Compression-based distance (Normalized Compression Distance, Cilibrasi-Vitanyi 2005) lets you cluster files without ever extracting a feature; mutual information measures coupling without a distributional assumption; Minimum Description Length picks model complexity rigorously; identifier-naming entropy (Hindle's "naturalness", ICSE 2012) is a quality signal on the codebase itself. Niche but decisive when applicable, and almost never taught outside complex-systems and information-theory courses. Scope: information-theoretic distance and criteria *not* tied to topic models (those live in the `topic` category).

## 9. Centrality, Hierarchy & Labelling (rank)

**Impact:** MEDIUM  
**Description:** Once the codebase is clustered, the agent needs to know *which* clusters and *which files within them* matter. PageRank (Page-Brin 1999) on the dependency graph surfaces architecturally central modules; HITS (Kleinberg 1999) separates hub orchestrators from authority leaves; betweenness centrality finds bottlenecks. For labelling, graph-based keyword extraction (TextRank, YAKE) outperforms naive top-TF-IDF on cluster vocabularies.
