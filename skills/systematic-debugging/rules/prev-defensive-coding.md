---
title: Add Defensive Code at System Boundaries
impact: LOW-MEDIUM
impactDescription: Catches bugs earlier with better context; prevents cascade failures
tags: prev, defensive, validation, boundaries, prevention
---

## Add Defensive Code at System Boundaries

Add validation and assertions at system boundaries (APIs, module interfaces, data ingestion points). Bugs caught at boundaries have better context and don't propagate through the system.

**Incorrect (no boundary defense):**

```python
# Bug manifests deep in the system
def render_dashboard(data):
    for widget in data['widgets']:
        for metric in widget['metrics']:
            # NullPointerException here
            # No idea where bad data came from
            # Could be API, database, cache, or calculation
            value = metric['current'] / metric['previous']
```

**Correct (defend at boundaries):**

```python
# API boundary - validate incoming requests
@app.route('/api/dashboard')
def get_dashboard():
    data = request.json
    # Validate at entry point
    if not data or 'user_id' not in data:
        raise ValueError("user_id required")  # Clear error source

    dashboard = generate_dashboard(data['user_id'])
    return validate_dashboard_response(dashboard)  # Validate output too

# Module boundary - validate inputs and outputs
def generate_dashboard(user_id: str) -> dict:
    assert user_id, "user_id must not be empty"

    widgets = load_widgets(user_id)
    assert isinstance(widgets, list), f"Expected list, got {type(widgets)}"

    return {
        'user_id': user_id,
        'widgets': [validate_widget(w) for w in widgets]
    }

def validate_widget(widget: dict) -> dict:
    """Validate widget structure at data boundary"""
    required = ['id', 'type', 'metrics']
    missing = [k for k in required if k not in widget]
    if missing:
        raise ValueError(f"Widget missing required fields: {missing}")

    for metric in widget.get('metrics', []):
        if metric.get('previous', 0) == 0:
            logger.warning(f"Zero previous value in widget {widget['id']}")
            metric['previous'] = 1  # Prevent division by zero with logged warning

    return widget
```

**Where to add defensive code:**
1. **API endpoints** - Validate request parameters
2. **Database results** - Check expected structure
3. **External service responses** - Verify format/status
4. **Module public interfaces** - Assert preconditions
5. **Configuration loading** - Validate required settings
6. **User input** - Sanitize and validate

**Defense patterns:**

```python
# Assert preconditions
def calculate(items):
    assert items, "items must not be empty"
    assert all(isinstance(i, Item) for i in items), "all items must be Item type"

# Guard clauses
def process(data):
    if not data:
        logger.warning("process called with empty data")
        return None

# Fail fast with context
def fetch_user(user_id):
    if not user_id:
        raise ValueError(f"user_id required, got: {user_id!r}")
```

**When NOT to use this pattern:**
- Internal functions with trusted callers
- Hot paths where validation overhead matters
- Redundant validation already done upstream

Reference: [Defensive Programming](https://en.wikipedia.org/wiki/Defensive_programming)
