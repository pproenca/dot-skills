---
title: Give recurring parameter clumps a dataclass
tags: model, data-clump, dataclass, signatures
---

## Give recurring parameter clumps a dataclass

When the same group of parameters travels through several signatures —
`(street, city, postal_code)`, `(host, port, use_tls)` — the group is a domain
concept the code never named. Every function restates the clump, every caller
threads it positionally, and adding a member means editing every signature in
the chain. The model's default is to keep threading, because each individual
signature looks locally fine. Naming the clump as a frozen dataclass collapses
the signatures, gives the concept a home for the validation and helpers that
inevitably follow, and turns "add a field" into a one-line change.

**Incorrect (the concept restated in every signature):**

```python
def geocode(street: str, city: str, postal_code: str) -> LatLng: ...
def format_label(street: str, city: str, postal_code: str) -> str: ...
def shipping_zone(street: str, city: str, postal_code: str) -> Zone: ...
```

**Correct (the concept named once, signatures collapse):**

```python
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class Address:
    street: str
    city: str
    postal_code: str

def geocode(address: Address) -> LatLng: ...
def format_label(address: Address) -> str: ...
def shipping_zone(address: Address) -> Zone: ...
```

**Evidence of violation:** the same group of **3 or more** parameters (matching
names and types) appearing together in **2 or more** function signatures in the
target — or a dict with a fixed key set passed through 2 or more call
boundaries and accessed key-by-key at each stop — with no declared type for the
group. PASS: the group travels as a dataclass/NamedTuple/TypedDict, or an
upstream type already holding the values is passed instead of being exploded
into fields — cite the type. N/A: no recurring group in the target; groups that
recur only between a public function and its private helper where one is a
thin, cited wrapper.

Reference: [dataclasses — Python documentation](https://docs.python.org/3/library/dataclasses.html)
