---
title: Declare All Dependencies Explicitly in a Manifest File
impact: CRITICAL
impactDescription: enables reproducible builds, prevents "works on my machine" issues
tags: dep, dependencies, manifest, reproducibility
---

## Declare All Dependencies Explicitly in a Manifest File

A twelve-factor app declares all dependencies completely and exactly via a dependency declaration manifest. This includes direct dependencies and their transitive dependencies, ensuring any developer can build and run the application with just the language runtime and dependency manager installed.

**Incorrect (implicit dependencies):**

```python
# No requirements.txt or pyproject.toml
# Developer assumes packages are globally installed

# app.py
import requests  # Assumed to be installed globally
import numpy     # Version? Who knows
import pandas    # Might work with pandas 1.x or 2.x

# README says "install the usual stuff"
# New developer: "What's the usual stuff?"
```

**Correct (explicit dependency manifest):**

```toml
# pyproject.toml
[project]
name = "myapp"
version = "1.0.0"
dependencies = [
    "requests>=2.28.0,<3.0.0",
    "numpy>=1.24.0,<2.0.0",
    "pandas>=2.0.0,<3.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
]
```

```bash
# New developer setup is deterministic
git clone https://github.com/company/myapp.git
cd myapp
pip install -e .
# All dependencies installed at compatible versions
```

**Alternative (lockfile for exact reproducibility):**

```bash
# requirements.txt with pinned versions from pip-compile
requests==2.31.0
numpy==1.26.2
pandas==2.1.3
# Every build uses identical dependency versions
```

**Benefits:**
- New developers can build immediately after clone
- CI/CD produces identical builds to development
- Security audits can enumerate all dependencies
- Version conflicts are detected early

Reference: [The Twelve-Factor App - Dependencies](https://12factor.net/dependencies)
