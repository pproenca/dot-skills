# Decision Tree: Employment & pensions — Categoria A / H (Anexo A)

Salary (Cat A) and pensions (Cat H) both report on **Anexo A** and share the
**€4,104** specific deduction. Rates and IRS Jovem terms:
[rates-and-deductions.md §3, §6, §7](rates-and-deductions.md).

```
START: the taxpayer received salary, wages, or a pension in the year.
│
├── Q1. Resident with ONLY Cat A/H PT income and standard deductions?
│   │
│   ├── Yes ──► IRS automático almost certainly applies. Go to
│   │       filing-obligation-tree.md Q4 to review and accept the pre-filled return.
│   └── No (also has F/G/B/J, or wants a benefit not pre-filled) ──► Q2.
│
├── Q2. Is the taxpayer eligible for IRS Jovem (age ≤ 35, within the 10-year
│       window, Cat A/B income)?
│   │
│   ├── Yes ──► apply the year-based exemption (100% / 75% / 50% / 25%) up to the
│   │       55-IAS cap. Terminal: on Anexo A, flag the IRS-Jovem year so the
│   │       exemption is applied; keep proof of first-income year. If the year
│   │       sequence is unclear (gaps, prior partial use) ──► ESCALATE.
│   └── No ──► Q3.
│
├── Q3. Any severance / contract-termination compensation, or stock-based pay?
│   │
│   ├── Yes ──► ESCALATE: the exempt portion of severance (Art. 2 §4) and the
│   │       valuation of equity comp need case-specific treatment.
│   └── No ──► Q4.
│
└── Q4. Non-resident with PT employment income?
    │
    ├── Taxed by final withholding at source and nothing else due ──► NO RETURN
    │       (confirm via filing-obligation-tree.md). Terminal.
    └── Otherwise ──► Terminal ACTION: submit **Anexo A** with the income and PT
        withholding already deducted at source; the €4,104 specific deduction
        applies. Combine with any other annexes from the assembly step. Record with
        assets/templates/report.md.
```

## Usual suspects

1. **Accepting IRS automático when other income exists.** It only covers a clean
   Cat A/H situation — rental or gains make it wrong.
2. **Missing IRS Jovem** for a young worker, or mis-sequencing the exemption year.
3. **Pensions filed in the wrong place.** Cat H goes on Anexo A, not a separate
   pension annex.
