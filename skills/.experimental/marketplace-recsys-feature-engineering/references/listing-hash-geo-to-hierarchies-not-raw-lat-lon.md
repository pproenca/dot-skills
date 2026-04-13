---
title: Hash Geo to Hierarchies, Not Raw Lat/Lon
impact: HIGH
impactDescription: prevents the model from treating geo as an arbitrary 2D plane
tags: listing, geo, h3, geohash, hierarchy
---

## Hash Geo to Hierarchies, Not Raw Lat/Lon

Raw (latitude, longitude) pairs are two continuous floats — the model has no native way to learn "this area is popular with cat sitters" or "this neighbourhood has a high acceptance rate". Hashing the location into a spatial index (H3, S2, or geohash) at multiple resolutions produces categorical features the model can embed per hash cell — coarse cells capture city-level effects, fine cells capture street-level effects, and an ablation study can tell you which resolution moves the metric. Privacy benefits are a bonus: publishing an H3-resolution-9 cell instead of an exact address protects the owner from scraping.

**Incorrect (raw lat/lon floats):**

```python
def geo_feature(listing: Listing) -> dict:
    return {
        "latitude": listing.lat,   # float
        "longitude": listing.lon,  # float
        # model treats these as arbitrary numbers; no neighbourhood learning
    }
```

**Correct (H3 cells at multiple resolutions):**

```python
import h3

H3_RESOLUTIONS = [5, 7, 9]
# r5 ≈ city  (252 km² area, ~8.5 km edge)
# r7 ≈ neighbourhood (5.16 km² area, ~1.22 km edge)
# r9 ≈ street (0.1 km² area, ~174 m edge)

def geo_feature(listing: Listing) -> dict:
    return {
        f"h3_r{res}": h3.latlng_to_cell(listing.lat, listing.lon, res)
        for res in H3_RESOLUTIONS
    }
    # {"h3_r5": "85283473fffffff", "h3_r7": "872830828ffffff", "h3_r9": "89283082837ffff"}
    # model learns embeddings per cell at each resolution; neighbourhood effects emerge naturally
```

Reference: [Uber — H3 Hexagonal Hierarchical Spatial Index](https://h3geo.org/)
