---
title: Data is what you store; information is what you present
tags: term, data, information
---

## Data is what you store; information is what you present

The wrong default is to use "data" and "information" interchangeably and then store information — a formatted "Full Name," a "Total Due," a "Days Overdue" — as if it were data. In this method the two are deliberately distinct: **data** is the static raw values kept in the tables; **information** is data that has been processed, combined, or formatted to be meaningful at the moment it is presented. Information is dynamic — it is what you get *out*, computed from data on demand.

The design consequence is direct: store data, derive information. A value that is a calculation, a concatenation, or a formatting of other fields is information and belongs in a view or report, not in a stored field (`fld-derive-dont-store-calculated-values`). Confusing the two is the root of calculated fields and of the spreadsheet mindset that stores data in its presentation shape.

```text
Data (store it):           CustFirstName='Estela', CustLastName='Rosales', BalanceDue=240.00
Information (derive it):    "Estela Rosales owes $240.00"  ← assembled at read time, not stored
```
