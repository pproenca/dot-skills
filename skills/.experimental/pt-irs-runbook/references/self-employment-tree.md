# Decision Tree: Self-employment — Categoria B (Anexo B / C)

For recibos verdes / independent activity, including alojamento local run as a
business. Coefficients and reductions:
[rates-and-deductions.md §5](rates-and-deductions.md).

```
START: the taxpayer earned independent/business income in the year.
│
├── Q1. Accounting regime?
│   │
│   ├── Turnover > €200,000, or organized accounting elected ──► Anexo C.
│   │       ESCALATE to a contabilista certificado.
│   └── Simplified regime (turnover ≤ €200,000) ──► Q2.
│
├── Q2. Determine the COEFFICIENT for the activity (Art. 31):
│   │   0.15 goods/hospitality · 0.75 Art. 151 professional services ·
│   │   0.35 other services · 0.95 IP/capital · 0.30/0.10 subsidies.
│   │   Taxable income = coefficient × gross receipts.
│   │
│   ├── Newly opened activity? ──► apply −50% (year 1) / −25% (year 2) to the
│   │       coefficient.
│   └──► Q3.
│
├── Q3. Does the 0.75 / 0.35 service coefficient apply?
│   │   Those carry the 15% expense-justification rule: part of the deemed deduction
│   │   must be backed by documented business expenses, or taxable income is
│   │   increased by the unjustified shortfall.
│   │
│   ├── Yes, and expenses documented ──► fine; keep records.
│   ├── Yes, but expenses not documented ──► taxable income rises; warn the taxpayer.
│   └── No (e.g. 0.15 goods) ──► continue.
│
├── Q4. Social Security position?
│   │
│   ├── Liable (not exempt as employee/pensioner) ──► add **Anexo SS**.
│   └── Exempt this year ──► no Anexo SS.
│
└── Q5. Other flags.
    │
    ├── VAT-liable activity AND taxpayer is non-resident ──► fiscal representative
    │       must be a PT-resident VAT taxpayer (see filing-obligation-tree.md Q2);
    │       ESCALATE.
    ├── IRS Jovem eligible (≤35, within window) ──► apply the exemption to the Cat B
    │       income (see rates-and-deductions.md §7); flag the year on the return,
    │       then proceed to the Terminal ACTION below.
    └── Terminal ACTION: submit **Anexo B** (simplified) with gross receipts by
        coefficient class, plus Anexo SS if liable. The progressive scale applies to
        the computed taxable income (englobamento is the default for Cat B). Record
        with assets/templates/report.md.
```

## Usual suspects

1. **Declaring gross receipts as taxable income.** Under the simplified regime only
   the coefficient share is taxed.
2. **Ignoring the 15% expense-justification rule** on service income.
3. **Filing alojamento local as Cat F.** Run as a business it is Cat B.
4. **Forgetting the first/second-year coefficient reductions** for a new activity.
