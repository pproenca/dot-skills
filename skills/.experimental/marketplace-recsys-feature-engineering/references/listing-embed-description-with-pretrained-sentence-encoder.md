---
title: Embed Description Text with a Pretrained Sentence Encoder
impact: HIGH
impactDescription: prevents TF-IDF sparsity and synonym drift with 0 training cost
tags: listing, text, sentence-transformers, minilm, embeddings
---

## Embed Description Text with a Pretrained Sentence Encoder

Owner-written descriptions are the richest unstructured signal in the catalogue — they carry personality, calmness, formality, and specific requests that no structured field captures. A pretrained sentence encoder like `all-MiniLM-L6-v2` produces 384-dim embeddings at 5x the speed of BERT-base with almost-equivalent quality on semantic similarity, turning every description into a usable feature in days without training. The embedding is what you feed downstream i2i composition and u2i ranking towers. Train a domain-specific encoder only after this v1 has shipped and the gap is measured.

**Incorrect (TF-IDF over description, stale and sparse):**

```python
from sklearn.feature_extraction.text import TfidfVectorizer

vectorizer = TfidfVectorizer(max_features=5000)
vectorizer.fit(all_descriptions)
def text_feature(desc: str) -> np.ndarray:
    return vectorizer.transform([desc]).toarray()[0]
    # sparse bag-of-words, no semantic understanding of synonyms or paraphrases
```

**Correct (sentence-transformer embedding, 384-dim dense):**

```python
from sentence_transformers import SentenceTransformer

TEXT_ENCODER = "sentence-transformers/all-MiniLM-L6-v2"
encoder = SentenceTransformer(TEXT_ENCODER)

def text_feature(desc: str) -> np.ndarray:
    if not desc or len(desc) < 20:
        return np.zeros(384)
    vec = encoder.encode(desc, normalize_embeddings=True)
    return vec  # 384-dim, L2-normalised, ready for cosine similarity

# for non-English listings, route to the language-specific model (paraphrase-multilingual-MiniLM-L12-v2)
```

Reference: [sentence-transformers/all-MiniLM-L6-v2 on Hugging Face](https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2)
