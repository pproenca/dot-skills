# Rates & Deductions — single source of truth

All numeric values used by the decision trees. **Default income year: 2025**
(return filed 1 Apr – 30 Jun 2026). Where OE2026 changes a value for income year
2026 (filed 2027), it is marked **[2026→]**. When a new Orçamento do Estado lands,
update only this file.

> Verify before filing. Brackets and indexed caps are re-set by each annual budget.
> The autonomous rates below are quoted verbatim from Art. 72 CIRS as of May 2026;
> progressive brackets must be read off the live Art. 68 table for the income year.

## 1. Residency regime (sets everything)

| | Resident | Non-resident |
|---|----------|--------------|
| Taxed on | Worldwide income | PT-source income only |
| Rate basis | Progressive (Art. 68) by englobamento | Special/flat rates (Art. 72) per category |
| Family quotient | Yes | No |
| Deduções à coleta | Yes | No (limited exceptions) |
| EU/EEA option | — | May elect to be taxed under resident rules (Art. 17-A), declaring worldwide income to set the rate |

Source: CIRS Art. 15, 16, 17-A.

## 2. Art. 72 autonomous / special rates

### Rental income — Categoria F (verbatim from Art. 72, May 2026)

| Situation | Rate | Note |
|-----------|------|------|
| Residential letting, base | **25%** | §2. Applies to any residential lease **under 5 years** |
| Permanent-housing contract ≥5 and <10 years | **15%** | §3: −10pp; **+2pp per renewal** of equal length, renewal reductions capped at 10pp |
| Permanent-housing contract ≥10 and <20 years | **10%** | §4: −15pp |
| Permanent-housing contract ≥20 years (and direito real de habitação duradoura) | **5%** | §5: −20pp |
| New contract with rent ≥5% below previous contract | **extra −5pp** | §24, on top of the duration reduction |
| Non-residential (commercial, industrial, rural) | **28%** | No duration reductions |

- **There is no 2–5 year reduction tier.** A 2-year lease is taxed at the 25% base
  regardless of H_PERM vs H_NPER finalidade.
- Reductions do **not** apply to contracts signed after 1 Jan 2024 whose monthly
  rent exceeds the municipal price limits by more than 50%.
- **[2026→]** OE2026 adds a **10%** rate for moderate-rent permanent-housing leases
  (rent ≤ ~€2,300/month, registered, property classified residential), plus a
  "zero-IRS" track for rents ≤80% of the INE median with a ≥3-year term. These
  apply to **2026 income (filed 2027)**, not the 2025 return.
- Englobamento (option to be taxed at the progressive scale instead) is available;
  worthwhile only if the marginal rate is below the autonomous rate.

Source: CIRS Art. 72 §2–§5, §24; Lei 56/2023 (Mais Habitação); OE2026.

### Capital gains & investment income — Art. 72

| Item | Rate |
|------|------|
| Net gains on securities/shares (Cat G) | **28%** flat, or option to aggregate |
| Investment income not subject to withholding (Cat E) | **28%** |
| Income/gains from blacklisted (favourable-regime) jurisdictions | **35%** |
| Non-resident with PT permanent establishment | **25%** |

Real-estate gains are **not** a flat Art. 72 rate — see §4 below (50% inclusion +
progressive). Source: CIRS Art. 72 §1, §18.

## 3. Art. 68 progressive brackets (residents, and englobamento)

For income year 2025 there are **9 escalões** with marginal rates ranging from
roughly **13% to 48%** (redação da Lei n.º 55-A/2025). Exact threshold euros are
re-indexed annually — **read them off the official Art. 68 table for the income
year** rather than hardcoding.

- Add the **taxa adicional de solidariedade**: **+2.5%** on taxable income above
  €80,000 and **+5%** above €250,000 (Art. 68-A).
- The progressive scale applies to the resident's total englobado income and to
  englobado capital gains; it sets the average rate used for the non-resident's
  real-estate gain too.

Source: CIRS Art. 68, 68-A; Portal das Finanças escalões table (income year 2025).

## 4. Real-estate capital gains base (Cat G)

Gain = realisation value − (acquisition value × inflation coefficient) −
acquisition/disposal costs − improvement costs (last 12 years), per Art. 10, 50.

- **Taxable portion = 50% of the gain** for both **residents and non-residents**
  (the pre-2023 "100% at 28%" rule for non-residents is gone).
- The taxable 50% is **englobado** at the progressive scale (Art. 43 §2). A
  non-resident declares worldwide income on the return only to fix the rate band.
- **Reinvestment exemption** (Art. 10 §5): gain on an own permanent home is exempt
  to the extent proceeds are reinvested in another own permanent home in PT/EU/EEA,
  within 24 months before or 36 months after the sale (with declaration of intent).
- Inflation coefficients are published yearly by Portaria — pass the current one to
  `queries/property-capital-gain.py`.

## 5. Categoria B — simplified regime coefficients (Art. 31)

Taxable income = coefficient × gross receipts (regime applies up to €200,000
turnover):

| Coefficient | Applies to |
|-------------|------------|
| 0.15 | Sale of goods, hotel/restaurant/beverage |
| 0.75 | Professional services in the Art. 151 table |
| 0.35 | Other services |
| 0.95 | Intellectual property assigned by third parties, capital, positive balance of gains |
| 0.30 | Subsidies not for operations |
| 0.10 | Operating subsidies |

- The 0.75/0.35 service coefficients carry a **15% expense-justification rule**:
  part of the deemed deduction must be backed by documented business expenses.
- First-year **−50%** and second-year **−25%** reductions on the coefficient apply
  to a newly opened activity.
- Social Security is reported separately via **Anexo SS**.
- Above €200,000 turnover, or by option, **organized accounting** (Anexo C) →
  escalate to a contabilista certificado.

Source: CIRS Art. 28, 31.

## 6. Deductions (residents only)

**Dedução específica** (subtracted before the scale):

- Categoria A (employment) and H (pensions): **€4,104** per holder (or higher
  mandatory social-contribution amount).

**Deduções à coleta** (subtracted from the tax) — income year 2025, confirm caps
on the Anexo H / despesas screen:

| Deduction | Rate / cap |
|-----------|-----------|
| General family expenses (despesas gerais familiares) | 35% of expenses, cap €250/holder (45% / €335.66 for single-parent) |
| Health | 15%, cap €1,000 |
| Education | 30%, cap €800 |
| Property — rent paid for own home | 15%, cap €600 (raised for some moderate-rent cases) |
| Homes/elder care (lares) | 25%, cap €403.75 |
| Invoice-requirement deduction (IVA em faturas) | 15% of VAT in eligible sectors, cap €250 |
| Descendants/ascendants, PPR, donations | per Art. 78-A..78-F |

Source: CIRS Art. 25, 78–78-G. Caps are indexed — verify for the income year.

## 7. Special regimes

- **IRS Jovem (2025 model):** ages up to **35**, max **10 years** of Cat A/B income.
  Exemption schedule on eligible income: **100%** year 1; **75%** years 2–4; **50%**
  years 5–7; **25%** years 8–10. Cap **55 × IAS = €28,737.50** (IAS 2025 = €522.50).
  Source: Folheto IRS Jovem 2025 (Portal das Finanças).
- **IFICI (the post-NHR regime, a.k.a. NHR 2.0):** **20%** flat IRS on Cat A/B from
  eligible highly-qualified activities, plus exemption of most foreign-source income.
  Narrow eligibility (research/innovation/listed activities). The old **NHR is
  closed to new arrivals** — registrations ended in the 2024/early-2025 transition.
  Anyone "just signing up for NHR" must instead test IFICI eligibility.
  - **IFICI registration deadline:** apply by **15 January of the year following**
    the year you become a PT tax resident (Portaria 352/2024/1) — e.g. resident in
    2025 → register by 15 Jan 2026. Registration is via the AT / the relevant
    certifying body for the activity (IAPMEI, FCT, AICEP, Startup Portugal, etc.).
    Transitional: those who became resident in 2024 had until 15 Mar 2025. Verify
    the channel for the specific activity.

## 8. Calendar (income year 2025)

| Date | Event |
|------|-------|
| Until ~Feb 2026 | Validate e-fatura invoices (deduction classification) |
| 15–31 Mar 2026 | Confirm household/dependents; complaint window on pre-filled deductions |
| **1 Apr – 30 Jun 2026** | **Modelo 3 submission window (all taxpayers, electronic)** |
| 31 Jul 2026 | Assessment / refund target for on-time returns |
| 31 Aug 2026 | Payment deadline if tax is due |

Non-residents file in the same window **if** they have PT-source income not taxed
by final withholding. Source: Portal das Finanças "IRS – Principais prazos 2026".
