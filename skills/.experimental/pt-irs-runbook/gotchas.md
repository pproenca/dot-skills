# Gotchas — PT IRS filing

Diagnostic dead-ends and Portal das Finanças quirks. Append-only, with dates.

### Tenant with a Portuguese NIF → set country = Portugal, not their nationality
When declaring a tenant (or any counterparty) on Portal das Finanças, the country
field follows the **NIF's country**, not the person's passport. A Spanish or
Italian tenant who holds a PT NIF is entered as **Portugal**. Foreign country +
passport number is only for counterparties with **no** PT NIF. Picking the
nationality instead silently rejects or mis-files the record.
Added: 2026-05-24

### The rental rate ladder has no 2–5 year tier
A common wrong assumption is that any multi-year lease earns a reduced Cat F rate.
Under Art. 72 the reductions only begin at **permanent-housing contracts ≥5 years**
(−10pp → 15%). Contracts under 5 years are taxed at the **25% base**, whether the
finalidade is H_PERM or H_NPER — the H_PERM/H_NPER choice makes **no rate
difference at a 2-year term**. The "−2pp" some sources mention is a *renewal* bonus
inside the 5–10 year tier, not a sub-5-year rate.
Added: 2026-05-24

### OE2026's 10% rate is for income year 2026, not the 2025 return being filed now
The OE2026 moderate-rent 10% rate (rent ≤ ~€2,300/mo, permanent housing) applies
to income earned **after the law's entry into force** — i.e. the return filed in
2027. Do not apply it to the 2025-income Modelo 3 due 30 Jun 2026.
Added: 2026-05-24

### Cat F expenses exclude mortgage interest and furniture
Deductible Cat F expenses (Art. 41) are conservation/maintenance, condomínio, IMI,
and insurance. Since 2015 **mortgage interest, capital repayment, and furniture are
NOT deductible** against rental income — a frequent over-claim.
Added: 2026-05-24

### Non-residents: rental income has no withholding, so a return is mandatory
Individual tenants do not withhold (sem retenção, Art. 101). Because the
PT-source rental income is therefore *not* taxed by final withholding, a
non-resident landlord **must file** a Modelo 3 with Anexo F — they are not covered
by the "only income subject to final withholding → no return" exemption.
Added: 2026-05-24
