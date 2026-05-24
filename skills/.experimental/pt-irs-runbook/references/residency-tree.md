# Decision Tree: Tax residency (Art. 16 CIRS)

**Why this is the gateway:** residency decides whether the taxpayer is taxed on
worldwide income at the progressive scale (resident) or only on PT-source income at
the special Art. 72 rates (non-resident), and whether deductions and the family
quotient apply. Decide this before opening any income-type tree.

Rates and regime differences: [rates-and-deductions.md §1](rates-and-deductions.md).
Day-count tool: [queries/residency-days.py](queries/residency-days.py).

```
START: For the income year, was the person present in Portugal?
│
├── Q1. Days physically present in PT during ANY rolling 12-month window
│       beginning or ending in the year — run queries/residency-days.py.
│   │   Expected output: max days in any 12-month window, and a pass/fail on 183.
│   │
│   ├── > 183 days ──────────────────────────────► RESIDENT (day test met). Go to Q4.
│   │
│   └── ≤ 183 days ──► Q2.
│
├── Q2. On 31 Dec of the year, did they hold a dwelling in PT in conditions
│       suggesting intention to keep and occupy it as habitual residence?
│   │   (Owned or rented home kept available year-round, family living there, etc.)
│   │
│   ├── Yes ─────────────────────────────────────► RESIDENT (habitual-residence test). Go to Q4.
│   │
│   └── No ──► Q3.
│
├── Q3. Special-status check: crew of PT-flagged ships/aircraft, or serving the
│       Portuguese State abroad, or member of a household whose other members are
│       PT-resident (Art. 16 §2)?
│   │
│   ├── Yes ─────────────────────────────────────► RESIDENT by attribution. Go to Q4.
│   │
│   └── No ──────────────────────────────────────► NON-RESIDENT. Go to Q5.
│
├── Q4. RESIDENT — did residency start or end PART-WAY through the year?
│   │   (Arrived in / left PT during the year — Art. 16 §3, §4: residency is counted
│   │    from the day of first presence / to the day of last presence.)
│   │
│   ├── Yes ──► PARTIAL-YEAR RESIDENT.
│   │           ACTION: file ONE Modelo 3 per status period, each marking the period
│   │           in quadro 8-C (Rosto). Resident period = worldwide income at the
│   │           progressive scale; non-resident period = PT-source only at Art. 72.
│   │           Then open the income-type trees for each period's income.
│   │
│   └── No ───► FULL-YEAR RESIDENT.
│               ACTION: declare WORLDWIDE income. Open filing-obligation-tree.md,
│               then each income-type tree. Foreign income → foreign-income-tree.md.
│
└── Q5. NON-RESIDENT — is the person tax-resident in the EU, Norway, Iceland or
        Liechtenstein, AND would the progressive scale beat the flat Art. 72 rate?
    │   (EU/EEA residents may elect resident-equivalent taxation — Art. 17-A —
    │    declaring worldwide income only to set the rate band.)
    │
    ├── Yes, and it lowers tax ──► NON-RESIDENT, opt for Art. 17-A treatment.
    │       ACTION: file Modelo 3 marking the EU/EEA option; expect to report
    │       worldwide income for rate purposes. Then open the income-type trees.
    │
    ├── No / not EU/EEA ─────────► NON-RESIDENT, standard.
    │       ACTION: declare only PT-source income at Art. 72 rates. Check the
    │       fiscal-representative question in filing-obligation-tree.md, then open
    │       the relevant income-type trees.
    │
    └── Both PT and another country claim residency (dual-residence) ──►
            ESCALATE to a contabilista certificado: apply the tie-breaker article
            of the relevant double-taxation treaty (permanent home → centre of vital
            interests → habitual abode → nationality). Treaty residence overrides
            the domestic test and changes the whole return.
```

## Usual suspects

1. **Counting only calendar-year days.** The 183-day test uses *any rolling
   12-month window* that begins or ends in the year — `residency-days.py` handles
   this; a naïve Jan–Dec count under-detects residency.
2. **Assuming non-resident = no PT return.** A non-resident with PT-source income
   not taxed by final withholding (typically rent) still files — see
   filing-obligation-tree.md.
3. **Ignoring partial-year split.** People who moved in/out mid-year owe two
   declarations, not one blended return.
