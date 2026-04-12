---
title: Scrub PII from Query Logs Before Warehouse Ingestion
impact: MEDIUM
impactDescription: prevents GDPR exposure in analytics
tags: monitor, pii, gdpr
---

## Scrub PII from Query Logs Before Warehouse Ingestion

Raw query logs contain personally identifiable information by construction — seeker identifiers, raw free-text queries that may contain names or addresses, IP-resolvable metadata, and sometimes contact details that users typed into the search box expecting them to be private. For a two-sided trust marketplace subject to GDPR and similar regimes, streaming those raw logs to the analytics warehouse without redaction creates a data-leak blast radius that grows every day. The fix is a redaction step in the ingestion pipeline: hash seeker identifiers, regex-strip common PII patterns from raw query text, and apply a separate retention policy to the redacted structured events versus the raw text.

**Incorrect (raw query log streamed unredacted to the analytics warehouse):**

```python
def emit_query_event(event: QueryEvent) -> None:
    warehouse_stream.put({
        "request_id": event.request_id,
        "seeker_id": event.seeker_id,
        "raw_query": event.raw,
        "normalised_query": event.normalised,
        "top_k": event.top_k,
        "timestamp": event.timestamp.isoformat(),
    })
```

**Correct (seeker ID hashed, raw text pattern-redacted, dual retention):**

```python
EMAIL_RE = re.compile(r"\b[\w.+-]+@[\w-]+\.[\w.-]+\b")
PHONE_RE = re.compile(r"\b(\+?\d{1,3}[\s-]?)?\(?\d{2,4}\)?[\s-]?\d{3,4}[\s-]?\d{3,4}\b")

def scrub_query_text(raw: str) -> str:
    scrubbed = EMAIL_RE.sub("[email]", raw)
    scrubbed = PHONE_RE.sub("[phone]", scrubbed)
    return scrubbed

def emit_query_event(event: QueryEvent) -> None:
    warehouse_stream.put({
        "request_id": event.request_id,
        "seeker_hash": hashlib.blake2b(event.seeker_id.encode(), digest_size=16).hexdigest(),
        "scrubbed_query": scrub_query_text(event.raw),
        "normalised_query": event.normalised,
        "top_k": event.top_k,
        "timestamp": event.timestamp.isoformat(),
    })
    raw_store.put(event, retention_days=7)
```

Reference: [Detecting PII in Log Data for GDPR Compliance](https://lantern.splunk.com/Security/UCE/Foundational_Visibility/Compliance/Detecting_Personally_Identifiable_Information_(PII)_in_log_data_for_GDPR_compliance)
