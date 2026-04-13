---
title: Scrub PII Before Features Leave the Secure Zone
impact: MEDIUM-HIGH
impactDescription: prevents GDPR exposure through embedding leaks
tags: quality, pii, gdpr, privacy, scrubbing
---

## Scrub PII Before Features Leave the Secure Zone

Image embeddings from photos containing faces, text embeddings from descriptions containing phone numbers, and user embeddings that memorise unique rare features are all privacy risks — an attacker with query access to the ANN index can recover that a specific person exists in the training data. PII scrubbing must happen at the extraction boundary, not at the serving boundary: blur faces before CLIP encoding, regex-scrub phone numbers and postcodes before the text encoder sees them, and use differential privacy or k-anonymity on per-user features that might be unique. Once the embedding contains PII, removing it later is effectively impossible.

**Incorrect (PII scrubbing deferred until after embedding):**

```python
def embed_description(text: str) -> np.ndarray:
    return text_encoder.encode(text)
    # "Call me on +44 7911 123456 if you need me" embeds the number into a 384-dim vector
    # later attempts to "redact" the phone number from the embedding are impossible
```

**Correct (PII scrubbed at the boundary, before extraction):**

```python
PII_PATTERNS = [
    (r"\+?\d[\d\s().-]{7,}\d", "[PHONE]"),
    (r"[\w.+-]+@[\w-]+\.[\w.-]+", "[EMAIL]"),
    (r"\b[A-Z]{1,2}\d[A-Z\d]?\s*\d[A-Z]{2}\b", "[POSTCODE]"),  # UK postcode
    (r"\b\d{1,5}\s+[A-Z][a-z]+\s+(Street|Road|Avenue|Lane)\b", "[ADDRESS]"),
]

def scrub_pii(text: str) -> str:
    for pattern, replacement in PII_PATTERNS:
        text = re.sub(pattern, replacement, text)
    return text

def embed_description(text: str) -> np.ndarray:
    scrubbed = scrub_pii(text)
    return text_encoder.encode(scrubbed)

def embed_photo(photo_bytes: bytes) -> np.ndarray:
    blurred = face_blur.apply(photo_bytes)  # face detection + gaussian blur on face regions
    return image_encoder.encode(blurred)
```

Reference: [Airbnb — When a Picture Is Worth More Than Words](https://medium.com/airbnb-engineering/when-a-picture-is-worth-more-than-words-17718860dcc2)
