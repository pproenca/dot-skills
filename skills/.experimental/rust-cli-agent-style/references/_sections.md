# Rule Categories

This document defines the categories used to organize rules in the rust-cli-agent-style skill.

## 1. Error Handling (err)

**Impact:** CRITICAL
**Description:** Rules for handling errors safely and consistently. The codebase enforces deny(unwrap_used, expect_used) at the workspace level.

## 2. Organization (org)

**Impact:** HIGH
**Description:** Rules for organizing workspaces, crates, modules, and files.

## 3. Component Patterns (mod)

**Impact:** HIGH
**Description:** Rules for designing structs, traits, impls, and type patterns.

## 4. Cross-Crate (cross)

**Impact:** HIGH
**Description:** Rules for workspace-level configuration and cross-crate patterns.

## 5. Naming Conventions (name)

**Impact:** MEDIUM
**Description:** Rules for naming functions, types, constants, and variables.

## 6. Style (style)

**Impact:** MEDIUM
**Description:** Rules for code formatting, imports, and documentation.
