---
title: Follow the Feature Flag Lifecycle
impact: MEDIUM
impactDescription: prevents 100% of premature feature exposure incidents
tags: cfg, feature-flags, lifecycle, stages
---

## Follow the Feature Flag Lifecycle

Feature flags in `codex-rs/core/src/features.rs` follow a defined lifecycle: `UnderDevelopment` -> `Experimental` -> `Stable` -> `Deprecated` -> `Removed`. Each stage has specific semantics. New features start as `UnderDevelopment` with `default_enabled: false`. The `Stage` enum variant determines visibility in the `/experimental` menu and rollout behavior.

**Incorrect (skipping lifecycle stages or incorrect defaults):**

```rust
FeatureSpec {
    id: Feature::MyNewFeature,
    key: "my_new_feature",
    stage: Stage::Stable,        // Jumping straight to Stable
    default_enabled: true,       // Enabled by default from day one
},
```

**Correct (starting at UnderDevelopment, graduating through stages):**

```rust
// Phase 1: Internal development
FeatureSpec {
    id: Feature::MyNewFeature,
    key: "my_new_feature",
    stage: Stage::UnderDevelopment,
    default_enabled: false,
},

// Phase 2: User-facing experiment (after validation)
FeatureSpec {
    id: Feature::MyNewFeature,
    key: "my_new_feature",
    stage: Stage::Experimental {
        name: "My New Feature",
        menu_description: "Description shown in /experimental menu.",
        announcement: "NEW: My New Feature is available in /experimental.",
    },
    default_enabled: false,
},
```
