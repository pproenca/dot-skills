---
name: pt-irs-runbook
description: >-
  Use this skill when navigating Portuguese personal income tax (IRS / Código do
  IRS) or filing a Modelo 3 return — determining tax residency (Art. 16),
  classifying income by category (rental/Anexo F, capital gains/Anexo G,
  employment/Anexo A, self-employment/Anexo B, pensions, foreign income/Anexo J),
  choosing the right annexes, applying current Art. 72 autonomous rates, and
  meeting Portal das Finanças deadlines. Covers residents and non-residents,
  including landlords with Portuguese-source rental income and double-taxation
  relief. Portugal-specific; not a substitute for a contabilista certificado.
---

# Portugal IRS Filing Runbook

A diagnostic runbook for Portuguese personal income tax (IRS). Each *symptom* is a
filing situation; each decision tree routes from the situation to the correct
**annex, autonomous rate, and deadline**, then terminates in a concrete filing
action or a clear "escalate to a contabilista certificado for {reason}".

> **Not tax advice.** This skill encodes the CIRS and Portal das Finanças rules as
> verified on the cited dates. Tax rates and thresholds change with each Orçamento
> do Estado. Always confirm figures against the live Art. 68/72 text and the
> official Modelo 3 / IRS automático screens before submitting, and involve a
> contabilista certificado for anything non-routine. Default income year is
> **2025 (return filed 1 Apr – 30 Jun 2026)** unless stated otherwise.

## When to Apply

- The user asks how to **file a Modelo 3** (PT annual income tax return) or which
  annexes apply to their income.
- The user needs to know whether they are a **PT tax resident or non-resident**,
  and what that changes.
- The user receives **Portuguese-source income** — rent, a property/share sale,
  salary, pension, or self-employment fees — and must declare it.
- The user is a **non-resident landlord** (or has foreign income as a resident)
  and needs the right rate plus **double-taxation relief**.
- The user asks about a specific PT regime: **IRS automático, IRS Jovem, IFICI
  (the post-NHR regime), englobamento, mais-valias reinvestment**.

This skill is Portugal-specific. For UK/other-country filing it is out of scope
(though it covers the *PT side* of a cross-border situation, e.g. PT rental income
that also appears on a UK SA106).

## How to Use

1. **Always start at residency.** Read [residency-tree](references/residency-tree.md).
   Residency status (Art. 16) determines the entire regime — worldwide vs
   PT-source-only income, progressive vs flat rates, deductions vs none.
2. **Then check whether a return is even required** and which annexes:
   [filing-obligation-tree](references/filing-obligation-tree.md).
3. **Open the tree for each income type the user has.** A taxpayer often needs
   several annexes at once.
4. **Look up every rate/threshold in one place:**
   [rates-and-deductions.md](references/rates-and-deductions.md) is the single
   source of truth; the trees link to it rather than restating numbers.
5. **Estimate figures deterministically** with the calculators in
   [references/queries/](references/queries/) (day-count, rental tax, capital
   gain), then **verify on Portal das Finanças**.
6. **Summarise the outcome** with [assets/templates/report.md](assets/templates/report.md).

## Common Symptoms

| # | Symptom / Question | Entry tree | Priority |
|---|--------------------|-----------|----------|
| 1 | "Am I resident or non-resident — and what changes?" | [residency-tree](references/residency-tree.md) | P1 (gateway) |
| 2 | "Do I have to file? Can I accept IRS automático? Which annexes?" | [filing-obligation-tree](references/filing-obligation-tree.md) | P1 (router) |
| 3 | "I receive rent from a PT property" (Categoria F) | [rental-income-tree](references/rental-income-tree.md) | P1 |
| 4 | "I sold a property or shares" (Categoria G / mais-valias) | [capital-gains-tree](references/capital-gains-tree.md) | P1 |
| 5 | "I have salary or a pension" (Categoria A / H) | [employment-pension-tree](references/employment-pension-tree.md) | P2 |
| 6 | "I'm self-employed / recibos verdes" (Categoria B) | [self-employment-tree](references/self-employment-tree.md) | P2 |
| 7 | "I have foreign income / risk of double taxation" (Anexo J) | [foreign-income-tree](references/foreign-income-tree.md) | P2 |

### Usual suspects — the mistakes a default answer makes

| Wrong default | Reality | Where |
|---------------|---------|-------|
| "Rental income is taxed at the progressive scale" | Cat F has its own **autonomous rate** (25% base, lower for long leases); englobamento is *optional* | [rental-income-tree](references/rental-income-tree.md) |
| "A 2-year lease gets a reduced rental rate" | The Art. 72 reductions start at **5-year** permanent-housing contracts; under 5 years = **25%** | [rates-and-deductions.md](references/rates-and-deductions.md) |
| "Non-residents pay 28% on the whole property gain" | Since 2023 non-residents get the **50% inclusion + progressive rates**, like residents | [capital-gains-tree](references/capital-gains-tree.md) |
| "Just sign up for NHR" | NHR is **closed to new arrivals**; the current regime is **IFICI** with much narrower eligibility | [foreign-income-tree](references/foreign-income-tree.md) |
| "A non-resident must appoint a fiscal representative" | Optional if you adhere to **electronic notifications**; always optional for EU/EEA residents | [filing-obligation-tree](references/filing-obligation-tree.md) |

## Setup

On first use, populate [config.json](config.json) with the taxpayer's situation
(residence country, fiscal representative status, applicable tax treaty, NIF). If a
required field is empty, ask the user, then save it. Never store passwords — login
to Portal das Finanças is interactive.

## Gotchas

Diagnostic dead-ends and portal quirks accumulate in [gotchas.md](gotchas.md).
Read it before a non-trivial filing.

## Related Skills

- A UK Self Assessment / SA106 runbook would complement this for the cross-border
  (PT rental → UK FTCR) case — not part of this skill.
