# Decision Tree: Do I file, IRS automático, and which annexes?

Run this after [residency-tree.md](residency-tree.md). It decides whether a return
is required at all, whether the pre-filled **IRS automático** can be accepted, and
which annexes the Modelo 3 needs. Deadlines and the calendar:
[rates-and-deductions.md §8](rates-and-deductions.md).

```
START: residency known (resident / non-resident / partial-year)?
│
├── NON-RESIDENT branch
│   │
│   ├── Q1. Is ALL PT-source income taxed by final withholding
│   │       (retenção a título definitivo)? e.g. some dividends/interest taxed at
│   │       source with no further obligation.
│   │   │
│   │   ├── Yes, and nothing else ─────► NO RETURN DUE. Terminal: confirm nothing
│   │   │       else is PT-source; advise no Modelo 3 is required.
│   │   │
│   │   └── No — there is PT-source income NOT finally withheld
│   │           (rent is the classic case: individual tenants don't withhold,
│   │            Art. 101) ──► MUST FILE Modelo 3. Go to Q3 (annex assembly).
│   │
│   └── Q2. Fiscal representative (Art. 19 LGT) — needed?
│       │
│       ├── Resident in EU/Norway/Iceland/Liechtenstein ──► OPTIONAL. Terminal:
│       │       no representative required; electronic notifications optional.
│       ├── Adheres to electronic notifications (ViaCTT / public e-notification) ──►
│       │       OPTIONAL. Terminal: adhesion satisfies the duty; no representative.
│       ├── Non-EU/EEA, no e-notification adhesion ──► REQUIRED. Terminal: appoint a
│       │       representante fiscal before filing.
│       └── Non-resident with a VAT-liable self-employment activity in PT ──►
│               REQUIRED and the representative must be a PT-resident VAT taxpayer;
│               e-notification does NOT waive it. Escalate to a contabilista.
│
├── RESIDENT branch
│   │
│   ├── Q3. Below the dispensa thresholds (Art. 58)? — only income subject to final
│   │       withholding, or total income under the legal minimum, no other duties.
│   │   │
│   │   ├── Yes ──► NO RETURN DUE. Terminal: confirm no Cat F/G/B income and no
│   │   │           obligation triggers; advise no Modelo 3 required.
│   │   │
│   │   └── No ──► a return is due. Go to Q4.
│   │
│   ├── Q4. IRS automático offered AND the situation is fully covered by it?
│   │       Covered: residents with only Cat A/H (and certain simple Cat B
│   │       simplified) income, PT-source, standard deductions, no excluded items.
│   │       NOT covered: rental (F), capital gains (G), foreign income (J),
│   │       organized accounting, some benefits/regimes.
│   │   │
│   │   ├── Fully covered ──► REVIEW & ACCEPT IRS automático. Terminal: verify the
│   │   │       pre-filled income, household and withholding, then confirm. It
│   │   │       becomes final automatically if not rejected in the window.
│   │   │
│   │   └── Not covered, or taxpayer prefers manual ──► File full Modelo 3. Go to Q5.
│
└── Q5. ANNEX ASSEMBLY (resident: worldwide; non-resident: PT-source only).
        Add every annex whose income/condition is present. Each links to its tree.

        Rosto (always) — identification, household, quadro 8-C for partial-year.
        ├── Salary / pension present?            → Anexo A   (employment-pension-tree.md)
        ├── Self-employment / recibos verdes?    → Anexo B   (self-employment-tree.md)
        │     (organized accounting → Anexo C → escalate)
        ├── Investment income (dividends/interest) to declare/aggregate? → Anexo E
        ├── Rental income?                       → Anexo F   (rental-income-tree.md)
        ├── Capital gain (property/shares)?      → Anexo G / G1 (capital-gains-tree.md)
        ├── Foreign income (resident)?           → Anexo J   (foreign-income-tree.md)
        ├── Deductions/benefits to claim?        → Anexo H   (rates-and-deductions.md §6)
        └── Self-employment Social Security?     → Anexo SS

        Terminal: submit the Modelo 3 with exactly this annex set within the
        1 Apr – 30 Jun window. Use assets/templates/report.md to record the outcome.
```

## Usual suspects

1. **Non-resident landlord assuming no return.** Rent is not finally withheld →
   filing is mandatory (Q1 "No" branch).
2. **Accepting IRS automático with rental or gains.** Those situations are outside
   automático; accepting it would omit Anexo F/G. Always run Q4's coverage check.
3. **Over-appointing a representative.** EU/EEA residence or e-notification adhesion
   already satisfies Art. 19 — don't pay for a representative you don't need.
