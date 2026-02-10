# Pulumi

**Version 0.1.0**  
Pulumi Community  
January 2026

> **Note:** This Pulumi guide is for agents and LLMs to follow when maintaining,
> generating, or refactoring Pulumi infrastructure code. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance and reliability guide for Pulumi infrastructure as code, designed for AI agents and LLMs. Contains 46 rules across 8 categories, prioritized by impact from critical (state management, resource graph optimization) to incremental (automation and CI/CD). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [State Management and Backend](references/_sections.md#1-state-management-and-backend) — **CRITICAL**
   - 1.1 [Enable Checkpoint Skipping for Large Production Stacks](references/pstate-checkpoint-skipping.md) — CRITICAL (up to 20× faster deployments)
   - 1.2 [Import Existing Resources Before Managing](references/pstate-import-existing.md) — CRITICAL (prevents duplicate resource creation)
   - 1.3 [Keep Stacks Under 500 Resources](references/pstate-stack-size.md) — CRITICAL (10-100× faster preview and deployment)
   - 1.4 [Use Managed Backend for Production Stacks](references/pstate-backend-selection.md) — CRITICAL (10-50× faster state operations vs self-managed)
   - 1.5 [Use State Export/Import for Migrations](references/pstate-export-import.md) — CRITICAL (prevents resource recreation during refactoring)
   - 1.6 [Use Targeted Refresh Instead of Full Stack Refresh](references/pstate-refresh-targeting.md) — CRITICAL (10-100× faster refresh operations)
2. [Resource Graph Optimization](references/_sections.md#2-resource-graph-optimization) — **CRITICAL**
   - 2.1 [Avoid Side Effects in Apply Functions](references/graph-avoid-apply-side-effects.md) — CRITICAL (prevents unpredictable behavior and resource leaks)
   - 2.2 [Minimize Stack Reference Depth](references/graph-stack-references-minimal.md) — CRITICAL (reduces deployment coupling and cascade failures)
   - 2.3 [Structure Resources for Maximum Parallelism](references/graph-parallel-resources.md) — CRITICAL (N× faster deployments where N is parallelism factor)
   - 2.4 [Use Conditional Logic at Resource Level](references/graph-conditional-resources.md) — CRITICAL (prevents graph instability and state drift)
   - 2.5 [Use dependsOn Only for External Dependencies](references/graph-explicit-depends.md) — CRITICAL (prevents hidden ordering issues)
   - 2.6 [Use Outputs to Express True Dependencies](references/graph-output-dependencies.md) — CRITICAL (eliminates false dependencies and enables parallelism)
3. [Component Design](references/_sections.md#3-component-design) — **HIGH**
   - 3.1 [Design Components for Multi-Language Consumption](references/pcomp-multi-language.md) — HIGH (reduces component implementations by 5×)
   - 3.2 [Pass Parent Option to Child Resources](references/pcomp-parent-child.md) — HIGH (prevents orphaned resources and enables cascading deletes)
   - 3.3 [Register Component Outputs Explicitly](references/pcomp-register-outputs.md) — HIGH (enables stack outputs and cross-stack references)
   - 3.4 [Use ComponentResource for Reusable Abstractions](references/pcomp-component-resources.md) — HIGH (enables sharing, consistency, and maintainability)
   - 3.5 [Use Name Prefix Pattern for Unique Resource Names](references/pcomp-unique-naming.md) — HIGH (prevents naming collisions across instances)
   - 3.6 [Use Transformations for Cross-Cutting Concerns](references/pcomp-transformations.md) — HIGH (100% compliance with zero code changes)
4. [Secrets and Configuration](references/_sections.md#4-secrets-and-configuration) — **HIGH**
   - 4.1 [Generate Secrets with Random Provider](references/secrets-generate-random.md) — HIGH (eliminates manual secret management)
   - 4.2 [Isolate Secrets by Environment](references/secrets-environment-isolation.md) — HIGH (prevents production credential access from development)
   - 4.3 [Prevent Secret Leakage in State](references/secrets-avoid-state-exposure.md) — HIGH (prevents credential exposure in checkpoints)
   - 4.4 [Rotate Secrets Provider When Team Members Leave](references/secrets-provider-rotation.md) — HIGH (prevents unauthorized access to encrypted config)
   - 4.5 [Use External Secret Managers for Production](references/secrets-external-providers.md) — HIGH (eliminates static secrets and enables rotation)
   - 4.6 [Use Secret Config for Sensitive Values](references/secrets-use-secret-config.md) — HIGH (prevents credential exposure in state and logs)
5. [Stack Organization](references/_sections.md#5-stack-organization) — **MEDIUM-HIGH**
   - 5.1 [Export Only Required Outputs](references/stack-output-minimal.md) — MEDIUM-HIGH (reduces coupling and speeds up stack references)
   - 5.2 [Parameterize Stack References](references/stack-references-parameterized.md) — MEDIUM-HIGH (enables environment promotion without code changes)
   - 5.3 [Separate Stacks by Deployment Lifecycle](references/stack-separation-by-lifecycle.md) — MEDIUM-HIGH (reduces blast radius and enables independent deployments)
   - 5.4 [Use Consistent Stack Naming Convention](references/stack-naming-conventions.md) — MEDIUM-HIGH (enables automation and reduces human error)
6. [Resource Options and Lifecycle](references/_sections.md#6-resource-options-and-lifecycle) — **MEDIUM**
   - 6.1 [Protect Stateful Resources](references/lifecycle-protect-stateful.md) — MEDIUM (prevents accidental data loss)
   - 6.2 [Set Custom Timeouts for Long-Running Resources](references/lifecycle-custom-timeouts.md) — MEDIUM (prevents premature deployment failures)
   - 6.3 [Use Aliases for Safe Resource Renaming](references/lifecycle-aliases.md) — MEDIUM (prevents delete-and-recreate on refactoring)
   - 6.4 [Use deleteBeforeReplace for Unique Constraints](references/lifecycle-delete-before-replace.md) — MEDIUM (prevents deployment failures from naming conflicts)
   - 6.5 [Use ignoreChanges for Externally Managed Properties](references/lifecycle-ignore-changes.md) — MEDIUM (prevents drift from external automation)
   - 6.6 [Use replaceOnChanges for Immutable Dependencies](references/lifecycle-replace-on-changes.md) — MEDIUM (prevents 100% of inconsistent state issues)
   - 6.7 [Use retainOnDelete for Shared Resources](references/lifecycle-retain-on-delete.md) — MEDIUM (prevents orphaned dependencies across stacks)
7. [Testing and Validation](references/_sections.md#7-testing-and-validation) — **MEDIUM**
   - 7.1 [Assert on Preview Results Before Deployment](references/test-preview-assertions.md) — MEDIUM (prevents unintended destructive changes)
   - 7.2 [Mock Stack References in Unit Tests](references/test-stack-reference-mocking.md) — MEDIUM (enables testing cross-stack dependencies)
   - 7.3 [Use Ephemeral Stacks for Integration Tests](references/test-integration-ephemeral.md) — MEDIUM (100% test isolation with automatic cleanup)
   - 7.4 [Use Mocks for Fast Unit Tests](references/test-unit-mocking.md) — MEDIUM (60× faster test execution)
   - 7.5 [Use Policy as Code for Property Testing](references/test-property-policies.md) — MEDIUM (100% policy compliance enforcement)
8. [Automation and CI/CD](references/_sections.md#8-automation-and-ci/cd) — **LOW-MEDIUM**
   - 8.1 [Enable Drift Detection for Production](references/auto-drift-detection.md) — LOW-MEDIUM (reduces drift-related incidents by 80%)
   - 8.2 [Run Preview in PR Checks](references/auto-ci-cd-preview.md) — LOW-MEDIUM (prevents 90% of deployment failures)
   - 8.3 [Use Automation API for Complex Workflows](references/auto-automation-api-workflows.md) — LOW-MEDIUM (enables programmatic multi-stack orchestration)
   - 8.4 [Use Inline Programs for Dynamic Infrastructure](references/auto-inline-programs.md) — LOW-MEDIUM (enables runtime-generated infrastructure definitions)
   - 8.5 [Use Pulumi Deployments for GitOps](references/auto-deployments-api.md) — LOW-MEDIUM (enables managed CI/CD without self-hosted runners)
   - 8.6 [Use Review Stacks for PR Environments](references/auto-review-stacks.md) — LOW-MEDIUM (enables testing in isolated environments per PR)

---

## References

1. [https://www.pulumi.com/docs/](https://www.pulumi.com/docs/)
2. [https://www.pulumi.com/docs/iac/concepts/](https://www.pulumi.com/docs/iac/concepts/)
3. [https://www.pulumi.com/docs/iac/concepts/state-and-backends/](https://www.pulumi.com/docs/iac/concepts/state-and-backends/)
4. [https://www.pulumi.com/docs/iac/concepts/components/](https://www.pulumi.com/docs/iac/concepts/components/)
5. [https://www.pulumi.com/docs/iac/concepts/secrets/](https://www.pulumi.com/docs/iac/concepts/secrets/)
6. [https://www.pulumi.com/docs/iac/automation-api/](https://www.pulumi.com/docs/iac/automation-api/)
7. [https://www.pulumi.com/docs/iac/guides/testing/](https://www.pulumi.com/docs/iac/guides/testing/)
8. [https://www.pulumi.com/blog/amazing-performance/](https://www.pulumi.com/blog/amazing-performance/)
9. [https://www.pulumi.com/blog/journaling/](https://www.pulumi.com/blog/journaling/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |