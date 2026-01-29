---
title: Enforce One-to-One Correlation Between Codebase and Application
impact: CRITICAL
impactDescription: prevents coupling, enables independent deployment
tags: code, architecture, microservices, modularity
---

## Enforce One-to-One Correlation Between Codebase and Application

Each application must have exactly one codebase. If you have multiple codebases, you have a distributed system where each component is its own app. If multiple apps share the same code, factor out the shared functionality into libraries.

**Incorrect (multiple apps sharing one codebase):**

```text
my-monorepo/
├── frontend-app/
│   └── package.json  # App 1
├── backend-api/
│   └── package.json  # App 2
├── worker-service/
│   └── package.json  # App 3
└── shared/
    └── utils.js      # Shared code tightly coupled
# All three apps deployed together, can't scale independently
```

**Correct (separate codebases with shared libraries):**

```text
# Each app has its own repository
github.com/company/frontend-app     # App 1
github.com/company/backend-api      # App 2
github.com/company/worker-service   # App 3
github.com/company/shared-utils     # Published as npm/pip package

# package.json in frontend-app
{
  "dependencies": {
    "@company/shared-utils": "^2.1.0"
  }
}

# Each app can be deployed, scaled, and versioned independently
```

**When NOT to use this pattern:**
- During initial prototyping when boundaries are unclear
- Monorepos are acceptable if each app has independent build/deploy pipelines

**Benefits:**
- Each app can be deployed independently
- Different apps can use different versions of shared code
- Teams can work in parallel without blocking each other

Reference: [The Twelve-Factor App - Codebase](https://12factor.net/codebase)
