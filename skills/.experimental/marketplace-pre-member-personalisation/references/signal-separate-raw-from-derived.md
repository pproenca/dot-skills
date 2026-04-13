---
title: Store Raw Signal Separately from Derived Features
impact: CRITICAL
impactDescription: enables re-derivation when feature logic changes
tags: signal, features, versioning
---

## Store Raw Signal Separately from Derived Features

A profile feature computed today with one logic — "likely_owner if landing_path contains /find-a-sitter" — is not the same feature two months later when the logic has changed. If only the derived value is stored, every logic change invalidates all historical profiles and makes backfills impossible. Storing the raw signal (URL path, referrer, UTM, geo-IP result, timestamp) alongside the derived feature (inferred role, confidence, channel classification) lets the team re-derive features retrospectively when logic improves, debug why a specific visitor was classified a particular way, and run counterfactual experiments on classification changes.

**Incorrect (derived role stored, raw signal discarded):**

```python
def on_first_page_load(request: Request) -> None:
    role = infer_role_from_request(request)
    profile_store.put(
        anon_session=request.anon_session,
        inferred_role=role,
    )
```

**Correct (raw signal captured separately, derived features link back to it):**

```python
def on_first_page_load(request: Request) -> None:
    raw_signal = RawSignal(
        anon_session=request.anon_session,
        landing_path=request.url.pathname,
        referrer=request.headers.get("referer"),
        utm={k: v for k, v in request.query.items() if k.startswith("utm_")},
        geoip_result=geoip_lookup(request.client_ip),
        user_agent=request.headers.get("user-agent"),
        captured_at=datetime.utcnow(),
    )
    raw_signal_store.put(raw_signal)

    derived = derive_features(raw_signal, feature_logic_version="v3.2")
    profile_store.put(
        anon_session=request.anon_session,
        features=derived,
        feature_logic_version="v3.2",
        raw_signal_ref=raw_signal.id,
    )
```

Reference: [Snowplow — Users and Identity Stitching](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/package-features/identity-stitching/)
