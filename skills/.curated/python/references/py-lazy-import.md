---
title: Use Lazy Imports for Faster Startup
impact: LOW
impactDescription: 10-15% faster startup
tags: py, imports, lazy-loading, startup
---

## Use Lazy Imports for Faster Startup

Top-level imports execute at module load time, slowing startup. Import heavy modules inside functions when they're only needed occasionally.

**Incorrect (always imports heavy module):**

```python
import pandas as pd  # Imports at module load, even if never used
import numpy as np
from sklearn.ensemble import RandomForestClassifier

def simple_stats(values: list[float]) -> dict:
    return {"mean": sum(values) / len(values)}

def advanced_ml_analysis(data: list[dict]) -> dict:
    # Only called rarely, but pandas/sklearn always loaded
    df = pd.DataFrame(data)
    model = RandomForestClassifier()
    return {"prediction": model.fit_predict(df)}
```

**Correct (lazy import when needed):**

```python
def simple_stats(values: list[float]) -> dict:
    return {"mean": sum(values) / len(values)}

def advanced_ml_analysis(data: list[dict]) -> dict:
    import pandas as pd  # Only imports when function called
    from sklearn.ensemble import RandomForestClassifier

    df = pd.DataFrame(data)
    model = RandomForestClassifier()
    return {"prediction": model.fit_predict(df)}
```

**For frequently called functions:**

```python
_pandas = None

def get_dataframe(data: list[dict]):
    global _pandas
    if _pandas is None:
        import pandas
        _pandas = pandas
    return _pandas.DataFrame(data)
```

**Note:** Python caches imports, so subsequent calls don't re-import.

Reference: [Python 3.11 - Faster Startup](https://docs.python.org/3/whatsnew/3.11.html#faster-cpython)
