---
title: Analyze the current system and interview before inventing fields
tags: proc, requirements, analysis
---

## Analyze the current system and interview before inventing fields

The wrong default is to compile the field list from assumptions about what the data "should" be. The organization already has a current system — paper forms, spreadsheets, a legacy database, reports — and the fields it actually uses are the ground truth. Skipping the analysis produces a schema that models an imagined domain and misses fields the business depends on, or invents fields nobody maintains.

Two habits matter. First, examine how data is collected (input forms) *and* how information is presented (reports, screens), because the difference between the two reveals which values are stored versus derived. Second, interview users and management **separately**: users know the day-to-day data and its detail; management knows the information the organization needs to make decisions and its future direction. Reconciling the two yields the complete field list.

```text
From data-collection samples (forms) → stored fields:
  CustFirstName, CustLastName, CustStreetAddress, CustCity, CustState, CustZipcode
From information-presentation samples (reports) → often derived, not stored:
  "Full Name", "Total Due", "Days Overdue"   ← compute in a view, do not store
```
