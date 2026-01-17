---
title: Document Assumptions and Constraints Early
impact: CRITICAL
impactDescription: prevents mid-project surprises and rework
tags: scope, assumptions, constraints, risk-management
---

## Document Assumptions and Constraints Early

Assumptions are conditions believed to be true that haven't been validated. Constraints are fixed limitations. Documenting both early allows validation before coding starts, preventing costly mid-project discoveries.

**Incorrect (undocumented assumptions):**

```markdown
## Feature: Payment Processing

### Requirements
- Accept credit card payments
- Process refunds
- Generate invoices

// Team assumes: existing payment provider, USD only, no taxes
// Reality discovered in sprint 3: new provider needed, multi-currency required
// Result: 3-week delay for integration rework
```

**Correct (explicit assumptions and constraints):**

```markdown
## Feature: Payment Processing

### Assumptions (To Be Validated)
- [ ] Stripe account is already configured and approved
- [ ] All transactions will be in USD initially
- [ ] Sales tax calculation is handled by a separate service
- [ ] PCI compliance is managed at infrastructure level

### Constraints (Fixed Limitations)
- Must use Stripe (contractual obligation)
- Maximum transaction: $10,000 (fraud policy)
- Refund window: 30 days (business policy)
- No cryptocurrency payments (regulatory)

### Dependencies
- Tax calculation service must be deployed first
- Legal team must approve terms of service copy

### Validation Plan
1. Week 1: Confirm Stripe account status with finance
2. Week 1: Verify tax service API availability
3. Week 2: Legal review of payment terms
```

**When to validate assumptions:**
- Before sprint planning
- When assumptions affect architecture
- When cost of being wrong is high

Reference: [JHK InfoTech - Software Product Specification](https://www.jhkinfotech.com/blog/software-product-specification)
