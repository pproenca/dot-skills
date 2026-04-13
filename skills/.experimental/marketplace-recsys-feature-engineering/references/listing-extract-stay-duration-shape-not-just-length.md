---
title: Extract Stay Duration Shape, Not Just Length
impact: HIGH
impactDescription: unlocks 3-5 sitter preference segments over a single integer
tags: listing, duration, shape, binning, flexibility
---

## Extract Stay Duration Shape, Not Just Length

"14 days" is a number; "two-week stay over Christmas with flexible dates" is a cluster a sitter preference model can learn on. Extract the duration shape as multiple structured features: duration bin (weekend / short / standard / long / extended), whether it spans a holiday period, whether the dates are flexible, and the absolute day count. Sitters have preferences over the shape (weekend-only travellers, month-long retirees, flexible-schedule remote workers) that a raw day count collapses.

**Incorrect (raw day count only):**

```python
def duration_feature(stay: Stay) -> int:
    return (stay.end_date - stay.start_date).days
    # a model sees "14" and cannot tell it's Christmas break vs a random two weeks in March
```

**Correct (duration bin + shape + flexibility + holiday overlap):**

```python
DURATION_BINS = [
    ("weekend", lambda d: d <= 3),
    ("short", lambda d: 4 <= d <= 7),
    ("standard", lambda d: 8 <= d <= 14),
    ("long", lambda d: 15 <= d <= 30),
    ("extended", lambda d: d > 30),
]

def duration_feature(stay: Stay) -> dict:
    days = (stay.end_date - stay.start_date).days
    bin_label = next(label for label, pred in DURATION_BINS if pred(days))
    return {
        "duration_days": days,
        "duration_bin": bin_label,                       # categorical
        "spans_public_holiday": spans_holiday(stay),
        "spans_school_holiday": spans_school_holiday(stay, stay.region_code),
        "dates_are_flexible": stay.flexible,
        "start_weekday": stay.start_date.strftime("%A").lower(),
    }
```

Reference: [Airbnb — Real-time Personalization using Embeddings for Search Ranking](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
