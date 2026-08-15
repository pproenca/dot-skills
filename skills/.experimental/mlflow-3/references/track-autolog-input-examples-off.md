---
title: Turn on input examples when autologging
tags: track, autolog, input-example, signature
---

## Turn on input examples when autologging

`mlflow.autolog()` looks like a complete solution, but its defaults undercut the serving story built in this skill's logging rules: `log_input_examples` defaults to **false**, so autologged models ship without the input example that drives signature-from-example inference and log-time serving validation. Enable it when the autologged model is a deployment candidate, not just a training-diagnostics record. Also note precedence: flavor-specific calls (`mlflow.sklearn.autolog(...)`) override the global `mlflow.autolog()` for that flavor, so a global setting can be silently superseded by a stray flavor call elsewhere in the codebase.

```python
import mlflow

mlflow.autolog(
    log_input_examples=True,  # the one default worth flipping — False ships no example
)
```

Reference: [mlflow.autolog API](https://mlflow.org/docs/latest/api_reference/python_api/mlflow.html#mlflow.autolog) · [mlflow/tracking/fluent.py (v3.15.1)](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/tracking/fluent.py)
