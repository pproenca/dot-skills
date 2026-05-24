# Symptom Catalog — PT IRS filing

Each symptom is a filing situation. Start at **residency** (it sets the regime),
then **filing obligation** (do you even file, and which annexes), then open the
tree for each income type the taxpayer has. A return often needs several annexes
at once. Every tree terminates in a concrete filing action or an escalation to a
contabilista certificado with a stated reason.

| # | Symptom / Question | Entry point | Priority | Terminal states |
|---|--------------------|-------------|----------|-----------------|
| 1 | "Am I resident or non-resident — and what changes?" | [residency-tree.md](residency-tree.md) | P1 (gateway) | Resident / Non-resident / Partial-year (two periods) / Escalate (tie-breaker treaty case) |
| 2 | "Do I have to file? IRS automático? Which annexes?" | [filing-obligation-tree.md](filing-obligation-tree.md) | P1 (router) | No return due / Accept IRS automático / File Modelo 3 with annexes {list} |
| 3 | "I receive rent from a PT property" (Categoria F) | [rental-income-tree.md](rental-income-tree.md) | P1 | Submit Anexo F at rate X% / Escalate (organized accounting, sublease, undocumented expenses) |
| 4 | "I sold a property or shares" (Categoria G) | [capital-gains-tree.md](capital-gains-tree.md) | P1 | Submit Anexo G (taxable base Y) / Anexo G1 (exempt) / Escalate (reinvestment, inheritance basis) |
| 5 | "I have salary or a pension" (Categoria A / H) | [employment-pension-tree.md](employment-pension-tree.md) | P2 | Accept IRS automático / Submit Anexo A / Escalate (IRS Jovem proof, severance) |
| 6 | "I'm self-employed / recibos verdes" (Categoria B) | [self-employment-tree.md](self-employment-tree.md) | P2 | Submit Anexo B simplified / Escalate (organized accounting, VAT, Anexo SS) |
| 7 | "I have foreign income / double-taxation risk" (Anexo J) | [foreign-income-tree.md](foreign-income-tree.md) | P2 | Submit Anexo J + credit (Art. 81) / IFICI path / Escalate (treaty residence conflict) |

## How priority maps to urgency

- **P1** changes the rest of the return: get residency and the annex set right
  first, and rental/gains have hard rate consequences if misclassified.
- **P2** is income-type detail that slots into the annex set decided in P1/P2 #2.

## Rates and thresholds live in one place

Do not restate rates inside a tree. All numeric values — Art. 68 brackets,
Art. 72 autonomous rates, Cat B coefficients, deduction caps, IRS Jovem and IFICI
terms, deadlines — are in [rates-and-deductions.md](rates-and-deductions.md), with
the income year they apply to. Update that one file when a budget changes.

## Calculators

Deterministic estimates (verify the result on Portal das Finanças afterwards):

| Tool | Computes | Used by |
|------|----------|---------|
| [queries/residency-days.py](queries/residency-days.py) | 183-day presence test over any rolling 12-month window (Art. 16) | residency-tree |
| [queries/rental-tax-estimate.py](queries/rental-tax-estimate.py) | Net Cat F income and autonomous tax by contract tier | rental-income-tree |
| [queries/property-capital-gain.py](queries/property-capital-gain.py) | Taxable real-estate gain with 50% inclusion and inflation coefficient | capital-gains-tree |
