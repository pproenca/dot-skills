---
title: Define glossary terms by business meaning, not restatement or implementation
tags: gloss, ubiquitous-language, glossary, stakeholders
---

## Define glossary terms by business meaning, not restatement or implementation

The wrong default is filling the glossary with definitions that satisfy the reviewer but carry no information: the term's own words re-ordered, or a pointer at the class and table that implement it. The glossary's audience includes stakeholders and customers who cannot read the code — a definition they cannot use to settle a disagreement about meaning is not part of a ubiquitous language, it is decoration.

**Evidence of violation:** a glossary entry that (a) only restates the term — the definition adds no word that distinguishes the concept ("Order Manager — the component that manages orders"); (b) defines the term purely by implementation — names a table, class, endpoint, or framework instead of what the concept means in the business ("Shipment — row in the `shipments` table, see `ShipmentService`"); or (c) is circular with another entry — A is defined as B and B as A with nothing else ("Dispatch — see Shipment. Shipment — see Dispatch"). Quote the offending definition.

**Carve-outs (must be cited to claim):** an entry may *additionally* point at implementation ("stored in `shipments`") after a business definition — the violation is when implementation is all there is.

**Incorrect (a stakeholder learns nothing):**

```markdown
| Term | Meaning |
|------|---------|
| Shipment | Handled by ShipmentService; persisted in the shipments table. |
```

**Correct (the definition can settle an argument):**

```markdown
| Term | Meaning |
|------|---------|
| Shipment | The physical dispatch of some of an Order's items from one warehouse. An Order splits into several Shipments when its items live in different warehouses; a Shipment never spans Orders. (Stored in `shipments`.) |
```

The correct form does the two jobs a definition has in DDD: it states the meaning in business terms, and it draws the boundary against the nearest concepts it could be confused with.

Reference: [Eric Evans — Domain-Driven Design Reference: Ubiquitous Language](https://www.domainlanguage.com/ddd/reference/), [Martin Fowler — UbiquitousLanguage](https://martinfowler.com/bliki/UbiquitousLanguage.html)
