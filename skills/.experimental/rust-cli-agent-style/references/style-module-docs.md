---
title: Add module-level documentation
impact: MEDIUM
impactDescription: Module docs provide context and improve API discoverability
tags: style, documentation, modules
---

# Add module-level documentation

Start lib.rs and mod.rs files with `//!` documentation comments.

## Why This Matters

- Provides crate/module overview
- Appears in generated docs
- Explains purpose and usage
- Improves API discoverability

**Incorrect (avoid this pattern):**

```rust
// lib.rs with no module docs
use std::path::PathBuf;

pub mod config;
pub mod error;
```

**Correct (recommended):**

```rust
// lib.rs
//! Codex Core Library
//!
//! This crate provides the core functionality for the Codex agent,
//! including configuration management, tool execution, and
//! sandboxing capabilities.
//!
//! # Quick Start
//!
//! ```rust
//! use codex_core::Config;
//!
//! let config = Config::load()?;
//! let agent = Agent::new(config);
//! agent.run().await?;
//! ```
//!
//! # Features
//!
//! - `sandbox` - Enable sandboxing support (enabled by default)
//! - `telemetry` - Enable OpenTelemetry integration

use std::path::PathBuf;

pub mod config;
pub mod error;
```

## Submodule Documentation

```rust
// src/config/mod.rs
//! Configuration management for Codex.
//!
//! This module handles loading, validating, and providing access
//! to configuration from various sources (files, environment, CLI).

mod loader;
mod validation;

pub use loader::ConfigLoader;
pub use validation::validate;
```

## Key Sections

- **Overview** - What the crate/module does
- **Quick Start** - Basic usage example
- **Features** - Cargo feature flags
- **Modules** - Brief description of submodules
