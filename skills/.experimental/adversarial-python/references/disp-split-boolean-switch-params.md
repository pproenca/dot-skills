---
title: Split functions forked end-to-end by a boolean parameter
tags: disp, boolean-flag, function-design, api-design
---

## Split functions forked end-to-end by a boolean parameter

A boolean parameter that selects between two disjoint code paths means one
function name is hiding two functions — every call site already knows which one
it wants (it passes a literal `True` or `False`), so the flag adds a level of
indirection that only the function's own body has to resolve. The two paths
share a signature but not behavior; they accrete divergent parameters and
`if flag` sprinkles over time. Two named functions (sharing a private helper
for any genuinely common core) make each call site say what it does.

**Incorrect (one name, two behaviors, resolved at runtime):**

```python
def export_report(report: Report, as_pdf: bool) -> bytes:
    if as_pdf:
        doc = render_pdf_layout(report)
        return doc.to_bytes()
    else:
        rows = flatten_rows(report)
        return write_csv(rows)

# every caller decides statically anyway:
export_report(monthly, as_pdf=True)
```

**Correct (each call site names its behavior):**

```python
def export_report_pdf(report: Report) -> bytes:
    return render_pdf_layout(report).to_bytes()

def export_report_csv(report: Report) -> bytes:
    return write_csv(flatten_rows(report))
```

**Evidence of violation:** a function with a boolean parameter that is consulted
in a conditional partitioning the function body into **disjoint paths** —
neither branch's statements are a superset of the other's, so no shared
pipeline exists — where the call sites in the target pass literal
`True`/`False` (or a constant). PASS: the flag toggles a
step *within* a shared pipeline (one branch is a superset of the other), the
flag is genuinely dynamic at call sites (forwarded from runtime input — cite
the call site), or the split functions exist and the flagged wrapper is a
documented compatibility shim. N/A: no boolean-forked function in the target.

Reference: [PEP 8 — Function and Method Arguments / API design guidance](https://peps.python.org/pep-0008/)
