# Decision Tree: Rental income — Categoria F (Anexo F)

For PT-source rent received by an individual (residents and non-residents). Rates:
[rates-and-deductions.md §2](rates-and-deductions.md). Estimator:
[queries/rental-tax-estimate.py](queries/rental-tax-estimate.py).

```
START: rent received from a PT property during the income year.
│
├── Q1. Is the property let under a business activity in organized accounting, or
│       is it a Cat B activity (e.g. alojamento local as a business)?
│   │
│   ├── Alojamento local / Cat B ──► WRONG TREE. Go to self-employment-tree.md
│   │       (AL is Categoria B, not F).
│   ├── Organized accounting ──────► ESCALATE to a contabilista certificado.
│   └── Ordinary lease (Cat F) ────► continue to Q2.
│
├── Q2. Compute NET income: gross rents − deductible expenses (Art. 41).
│   │   Deductible: conservation/maintenance, condomínio, IMI, landlord insurance,
│   │   and (first year) the stamp duty on the lease.
│   │   NOT deductible: mortgage interest, capital repayment, furniture/appliances.
│   │   Expected: net ≥ 0; carry forward losses for 6 years if expenses > rents.
│   │
│   ├── Any expense undocumented (no invoice/receipt)? ──► drop it; only documented
│   │       expenses count. If most expenses are undocumented ──► ESCALATE.
│   └── Net computed ──► Q3.
│
├── Q3. Determine the AUTONOMOUS RATE (Art. 72). Use rental-tax-estimate.py.
│   │   Criteria are the SIGNED CONTRACT TERM and use:
│   │
│   ├── Non-residential (commercial/industrial/rural) ───────────► 28%.
│   ├── Residential, term < 5 years ─────────────────────────────► 25% (base).
│   ├── Residential, permanent housing, ≥5 and <10 years ────────► 15% (−10pp).
│   ├── Residential, permanent housing, ≥10 and <20 years ───────► 10% (−15pp).
│   ├── Residential, permanent housing, ≥20 years ───────────────► 5%  (−20pp).
│   └── New contract with rent ≥5% below the previous one ───────► additionally −5pp
│       (on top of a duration reduction; the combined rate does not go below the 5%
│        statutory floor — a ≥20yr contract plus a rent cut is an edge case to verify).
│       (Expected check: post-2024 contracts lose reductions if rent exceeds the
│        municipal limit by >50% — if so, fall back to 25%.)
│       NOTE [2026→]: from 2026 income, a 10% moderate-rent rate may apply instead
│       (rent ≤ ~€2,300/mo). Do NOT use it on the 2025 return.
│
├── Q4. Englobamento — should it be elected instead of the autonomous rate?
│   │   Compare the autonomous rate to the taxpayer's marginal Art. 68 rate on the
│   │   net rent (residents; or EU/EEA non-residents under Art. 17-A).
│   │
│   ├── Marginal progressive rate < autonomous rate ──► ELECT englobamento on Anexo F
│   │       (tick the option). Terminal: rent is taxed at the progressive scale.
│   └── Otherwise ──► keep the autonomous rate (no englobamento).
│
└── Q5. Compliance checks, then file.
    │
    ├── Recibos de renda eletrónicos issued for each payment (or exemption claimed)? 
    │       If not issued and not exempt ──► issue/regularise first.
    └── Terminal ACTION: submit **Anexo F** — list the property (matrix article,
        conservatória), gross rent, documented expenses, contract term/finalidade
        so the system applies the right rate, and the englobamento choice from Q4.
        Record figures with assets/templates/report.md. Non-resident: confirm the
        fiscal-representative status from filing-obligation-tree.md.
```

## Usual suspects (most frequent first)

1. **Expecting a reduced rate on a short lease.** Under 5 years = 25%; reductions
   begin only at 5-year permanent-housing contracts.
2. **Deducting mortgage interest or furniture.** Neither is allowed against Cat F.
3. **Forgetting englobamento can be cheaper** for low total income — always run the
   Q4 comparison.
4. **Treating alojamento local as Cat F.** AL run as a business is Cat B.
