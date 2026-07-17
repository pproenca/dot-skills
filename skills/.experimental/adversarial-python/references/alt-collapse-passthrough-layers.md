---
title: Delete layers that only forward calls
tags: alt, indirection, wrappers, layering
---

## Delete layers that only forward calls

A wrapper layer whose methods forward to the wrapped object with the same
arguments and return values — no transformation, no error translation, no type
change — adds a file to read, a name to disambiguate, and a place for the two
interfaces to drift, while every behavior still lives one level down. These
layers accrete in legacy codebases ("every repository gets a service") and the
model extends them because the shape looks architectural. A layer earns its
existence by *changing* something across the boundary; pure forwarding is
negative-value code.

```python
# The layer below adds nothing the session did not already have:
class InvoiceService:
    def __init__(self, repo: InvoiceRepo) -> None:
        self._repo = repo

    def get(self, invoice_id: str) -> Invoice:
        return self._repo.get(invoice_id)

    def list_for(self, customer_id: str) -> list[Invoice]:
        return self._repo.list_for(customer_id)

    def save(self, invoice: Invoice) -> None:
        self._repo.save(invoice)

# Delete it. Callers use InvoiceRepo directly. The moment a method needs to
# CHANGE something crossing the boundary (compose two calls, translate errors,
# enforce a policy), THAT method earns a home — write it then, where it's needed.
```

**Evidence of violation:** a class or module in the target with **3 or more**
methods/functions that forward 1:1 to the same underlying object or module —
identical parameters passed through, return value returned unchanged, no
exception translation — where repo search finds **no second implementation and
no test double** standing in for the layer. PASS: the layer transforms
(composes calls, maps types, translates errors, enforces policy) in its
methods, or a cited second implementation/fake exists making it a real seam.
N/A: no forwarding layer in the target. Public API facades re-exporting a
package's internals (`__init__.py` surface) are N/A — re-export is not
call forwarding.

Reference: [PEP 20 — The Zen of Python ("Flat is better than nested")](https://peps.python.org/pep-0020/)
