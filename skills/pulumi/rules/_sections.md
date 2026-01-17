# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. State Management and Backend (pstate)

**Impact:** CRITICAL
**Description:** State operations run on every preview/update. Poor backend choice or state bloat causes 10-50× slowdowns on large stacks.

## 2. Resource Graph Optimization (graph)

**Impact:** CRITICAL
**Description:** Dependency chains determine deployment parallelism. Sequential dependencies cascade into multiplicative deployment times.

## 3. Component Design (pcomp)

**Impact:** HIGH
**Description:** Well-designed components enable reuse and enforce standards. Poor abstractions leak complexity and cause maintenance overhead.

## 4. Secrets and Configuration (secrets)

**Impact:** HIGH
**Description:** Improper secret handling creates security vulnerabilities. Unencrypted secrets in state or logs expose credentials.

## 5. Stack Organization (stack)

**Impact:** MEDIUM-HIGH
**Description:** Stack boundaries affect blast radius, deployment speed, and team autonomy. Over-consolidated stacks become deployment bottlenecks.

## 6. Resource Options and Lifecycle (lifecycle)

**Impact:** MEDIUM
**Description:** Resource options control replacement, protection, and deletion behavior. Incorrect options cause data loss or stuck deployments.

## 7. Testing and Validation (test)

**Impact:** MEDIUM
**Description:** Testing catches misconfigurations before deployment. Unit tests run in milliseconds while integration tests validate real behavior.

## 8. Automation and CI/CD (auto)

**Impact:** LOW-MEDIUM
**Description:** Automation API enables programmatic infrastructure management. CI/CD integration ensures consistent, auditable deployments.
