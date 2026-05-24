# Decision Tree: Capital gains — Categoria G (Anexo G / G1)

For disposals of real estate and securities by an individual. Base computation and
rates: [rates-and-deductions.md §2, §4](rates-and-deductions.md). Property-gain
estimator: [queries/property-capital-gain.py](queries/property-capital-gain.py).

```
START: an asset was disposed of (sold, exchanged, or contributed) in the year.
│
├── Q1. What was disposed?
│   │
│   ├── Real estate (or rights over it) ──► Q2.
│   ├── Shares / securities / units ──────► Q6.
│   └── Other (crypto held <365 days, IP, etc.) ──► ESCALATE: rules vary by asset
│           and holding period; confirm the specific Art. 10 category.
│
├── Q2. Acquisition date of the property?
│   │
│   ├── Before 1 Jan 1989 ──► EXEMPT (pre-CIRS). Terminal: report on **Anexo G1**
│   │       (exempt gains) for the record; no tax on the gain.
│   └── 1989 or later ──► Q3.
│
├── Q3. Compute the GAIN. Run property-capital-gain.py with:
│       realisation value, acquisition value × inflation coefficient (current
│       Portaria), acquisition + disposal costs, and improvement costs (last 12 yrs).
│   │   Expected output: the gross gain and the taxable 50%.
│   │
│   └──► Q4.
│
├── Q4. Was the property the taxpayer's OWN PERMANENT HOME and are proceeds being
│       reinvested in another own permanent home (PT/EU/EEA)?
│   │   Window: 24 months before to 36 months after the sale; declare the intent.
│   │
│   ├── Fully reinvested ──► EXEMPT on the reinvested portion. Terminal: report the
│   │       sale and the reinvestment intent/amount on Anexo G so the exemption is
│   │       applied; any non-reinvested portion stays taxable (continue Q5 on it).
│   ├── Partially reinvested ──► taxable on the non-reinvested proportion. Q5.
│   ├── Not a permanent home, or no reinvestment ──► fully taxable. Q5.
│   └── Reinvestment spans multiple years / mortgage-discharge variant ──► ESCALATE.
│
├── Q5. Tax the taxable gain (real estate): **50% inclusion + progressive scale**.
│   │   Applies to BOTH residents and non-residents (post-2023). The 50% is
│   │   englobado at Art. 68; a non-resident declares worldwide income to set the
│   │   rate band only.
│   │
│   └── Terminal ACTION: submit **Anexo G** with the acquisition/realisation values,
│       costs, improvements, and (if any) reinvestment. Expect tax on 50% of the gain
│       at the average Art. 68 rate. Record with assets/templates/report.md.
│
└── Q6. Securities / shares.
    │
    ├── Net result is a LOSS ──► report on Anexo G; losses may offset/ carry forward
    │       (5 years) only if englobamento is elected. Terminal: file Anexo G.
    ├── Net GAIN, default ──► 28% flat (Art. 72). Terminal: file Anexo G; tax = 28%
    │       of the net gain.
    └── Held < 365 days AND taxpayer's taxable income reaches the top Art. 68 bracket
            ──► MANDATORY englobamento of the short-term gain (anti-speculation rule).
            Terminal: file Anexo G with englobamento; gain taxed at the progressive
            scale. If unsure whether the threshold is met ──► ESCALATE.
```

## Usual suspects (most frequent first)

1. **Applying 28% to a non-resident's property gain.** Since 2023 it is 50%
   inclusion + progressive — usually lower than the old 28%-on-100%.
2. **Forgetting the inflation coefficient** on the acquisition value — it
   materially reduces the gain for older properties.
3. **Missing the permanent-home reinvestment exemption** or its declaration of
   intent.
4. **Omitting improvement costs / acquisition & disposal costs** (IMT, notary,
   agent commission) that reduce the gain.
