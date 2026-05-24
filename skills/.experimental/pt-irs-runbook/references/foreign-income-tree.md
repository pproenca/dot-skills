# Decision Tree: Foreign income & double taxation (Anexo J, Art. 81)

For a **resident** with income earned abroad (residents are taxed on worldwide
income), and for the post-NHR **IFICI** regime. Treaty credit and IFICI terms:
[rates-and-deductions.md §1, §7](rates-and-deductions.md). The applicable treaty is
in [config.json](../config.json) (`applicable_tax_treaty`).

```
START: resident received income from outside Portugal in the year.
│
├── Q1. Is the taxpayer under the IFICI regime (the post-NHR incentive)?
│   │
│   ├── Yes ──► foreign-source income is largely EXEMPT (with progression) and
│   │       eligible PT Cat A/B is taxed at 20%. Terminal: declare foreign income on
│   │       Anexo J and the IFICI annex; apply the exemption-with-progression method.
│   │       Registration deadline: 15 Jan of the year after becoming resident
│   │       (rates-and-deductions.md §7). If eligibility/registration is unconfirmed
│   │       ──► ESCALATE.
│   ├── Asking to "sign up for NHR" ──► NHR is CLOSED to new arrivals. Terminal:
│   │       test IFICI eligibility instead (narrow: research/innovation/listed
│   │       activities); if not eligible, normal worldwide taxation applies → Q2.
│   └── No / not applicable ──► Q2.
│
├── Q2. Classify each foreign income stream and place it on **Anexo J** by type
│       (employment, pensions, capital, rental, capital gains). Then resolve double
│       taxation per the treaty in config.json.
│   │
│   ├── Immovable property income/gains abroad ──► the source state taxes first
│   │       (OECD model Art. 6/13). PT gives a credit (Q3). For the mirror case —
│   │       PT-source rent declared by a non-resident — PT taxes first and the
│   │       residence state grants relief (e.g. UK FTCR on a UK SA106); the PT side
│   │       is rental-income-tree.md, not this tree.
│   └── Other income types ──► Q3.
│
├── Q3. Apply the foreign-tax credit (Art. 81 — crédito de imposto por dupla
│       tributação internacional).
│   │   Credit = the LESSER of (a) foreign tax actually paid, capped at the treaty
│   │   rate, and (b) the PT tax attributable to that foreign income.
│   │
│   ├── A treaty exists (config.applicable_tax_treaty set) ──► cap the creditable
│   │       foreign tax at the treaty rate; enter foreign income and foreign tax on
│   │       Anexo J. Terminal ACTION: file Anexo J with the Art. 81 credit.
│   ├── No treaty with the source country ──► unilateral relief still applies under
│   │       Art. 81; credit = lesser of foreign tax and PT tax on that income.
│   │       Terminal: file Anexo J with unilateral credit.
│   └── Foreign tax exceeds the treaty rate (over-withheld abroad) ──► claim the
│           excess back from the SOURCE country, not from PT. PT credits only up to
│           the treaty rate. If the source refund process is unclear ──► ESCALATE.
│
└── Q4. Consistency check before filing.
    │   Foreign income on Anexo J also raises the average rate applied to PT income
    │   (worldwide income sets the band). Confirm currency conversion uses the
    │   official annual exchange rate.
    │
    └── Terminal ACTION: submit **Anexo J** alongside the PT-income annexes, with the
        Art. 81 credit. Record with assets/templates/report.md.
```

## Usual suspects

1. **Recommending NHR.** It is closed to new arrivals; the live regime is IFICI,
   with much narrower eligibility.
2. **Crediting more foreign tax than the treaty allows.** PT caps the credit at the
   treaty rate; the excess is recovered from the source country.
3. **Omitting foreign income because it was taxed abroad.** Residents declare
   worldwide income on Anexo J even when a credit fully offsets the PT tax.
4. **Forgetting that foreign income raises the rate band** on PT income.
