---
title: Release Components as Cohesive Units
impact: HIGH
impactDescription: enables version tracking, supports parallel team development
tags: comp, release, versioning, cohesion
---

## Release Components as Cohesive Units

Classes grouped into a component should be releasable together. A component should have a version number, release notes, and clear documentation. This is the Reuse/Release Equivalence Principle (REP).

**Incorrect (arbitrary grouping):**

```text
shared-lib/
├── src/
│   ├── auth/
│   │   ├── JwtValidator.ts
│   │   └── PermissionChecker.ts
│   ├── logging/
│   │   └── Logger.ts
│   ├── email/
│   │   └── EmailSender.ts
│   └── payment/
│       └── StripeClient.ts
└── package.json  // version 1.2.3

# Version 1.2.4 fixes JWT bug
# But users of EmailSender must also upgrade
# Changelog unclear which features affect which users
```

**Correct (cohesive releasable components):**

```text
packages/
├── auth/
│   ├── src/
│   │   ├── JwtValidator.ts
│   │   ├── PermissionChecker.ts
│   │   └── index.ts
│   ├── CHANGELOG.md        # Auth-specific changes
│   └── package.json        # @company/auth v2.1.0
├── logging/
│   ├── src/
│   │   └── Logger.ts
│   ├── CHANGELOG.md
│   └── package.json        # @company/logging v1.0.3
├── email/
│   ├── src/
│   │   └── EmailSender.ts
│   ├── CHANGELOG.md
│   └── package.json        # @company/email v1.5.0
└── payments/
    ├── src/
    │   └── StripeClient.ts
    ├── CHANGELOG.md
    └── package.json        # @company/payments v3.0.0

# Clear ownership: auth team owns @company/auth
# Independent versioning: JWT fix only bumps auth
# Semantic versioning: breaking change in payments doesn't affect others
```

**Benefits:**
- Teams release independently on their own schedule
- Version numbers communicate compatibility
- Changelogs specific to what users of each component care about

Reference: [Clean Architecture - Reuse/Release Equivalence Principle](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch13.xhtml)
