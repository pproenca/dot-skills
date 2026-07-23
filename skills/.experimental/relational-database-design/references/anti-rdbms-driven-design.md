---
title: Drive the design from requirements, not the RDBMS product
tags: anti, rdbms-driven, requirements
---

## Drive the design from requirements, not the RDBMS product

The wrong default — common precisely because it feels responsible — is to design the database around the RDBMS the team already owns or knows. The product provides tools to implement a design; it provides no principles or rationale for creating one. Letting it drive the design bends the schema to the tool's shape and the designer's familiarity with it, rather than to the organization's information requirements.

The failure modes are specific:

```text
- You make decisions based on what you think the product can or can't do
  (e.g. skip a participation degree because "it doesn't support that").
- You let the product dictate structure instead of the organization's requirements.
- The design is bounded by your knowledge of, and skill with, the product.
- The result: improper structure, weak integrity, inconsistent and inaccurate data —
  a database that "works" while being quietly poorly designed.
```

Design the logical structure with no product in mind (`proc-design-logically-before-choosing-rdbms`); choose and implement afterward, filling any gaps in the product's native support with SQL, constraints, or application code.
