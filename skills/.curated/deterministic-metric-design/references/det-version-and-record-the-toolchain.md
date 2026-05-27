---
title: Version the Definition and Record the Toolchain
impact: MEDIUM-HIGH
impactDescription: prevents broken trend lines across parser and library upgrades
tags: det, versioning, provenance, reproducibility
---

## Version the Definition and Record the Toolchain

The same metric run under a different parser, grammar, or library version silently changes — a new language release adds AST node types, a clone detector retunes its threshold — and bare stored numbers make the shift invisible, corrupting every trend line that spans the upgrade. Emit the metric version, the tool versions, and a hash of the exact input alongside every value, and bump the metric version (semver) whenever the definition changes, so old and new values are never compared blindly.

**Incorrect (bare number, no provenance):**

```python
db.save(module=m.name, size=size(m))   # a parser upgrade shifts every value; the trend lies
```

**Correct (value carries its provenance):**

```python
db.save(
    module=m.name,
    size=size(m),
    metric_version="size@2.1.0",        # bump on any definition change (breaking → major)
    tool_versions={"python": platform.python_version(), "parser": PARSER_VERSION},
    input_sha=sha256(m.source),         # ties the value to the exact input that produced it
)
```

Reference: [Semantic Versioning 2.0.0](https://semver.org/)
