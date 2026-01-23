---
title: Use Partial Boundaries When Full Separation is Premature
impact: MEDIUM-HIGH
impactDescription: prepares for future without over-engineering now
tags: bound, partial-boundaries, pragmatism, yagni
---

## Use Partial Boundaries When Full Separation is Premature

When you anticipate needing a boundary but the cost of full separation is too high, implement a partial boundary. This prepares for future separation without premature over-engineering.

**Incorrect (no boundary when one might be needed):**

```python
# Tightly coupled - if we ever need to split, massive refactor
class ReportService:
    def generate_sales_report(self, start_date, end_date):
        # Direct database access
        conn = psycopg2.connect(DATABASE_URL)
        cursor = conn.cursor()
        cursor.execute("""
            SELECT * FROM sales
            WHERE date BETWEEN %s AND %s
        """, (start_date, end_date))

        # Direct PDF generation
        pdf = FPDF()
        for row in cursor.fetchall():
            pdf.cell(200, 10, txt=str(row))
        return pdf.output()

# Cannot split report generation from data access without rewriting
```

**Correct (partial boundary - same component, prepared for split):**

```python
# Strategy 1: Facade pattern (simplest partial boundary)
class ReportingFacade:
    """Single entry point, internal implementation can be refactored later."""

    def generate_sales_report(self, request: ReportRequest) -> Report:
        data = self._fetch_data(request)
        return self._format_report(data, request.format)

    def _fetch_data(self, request):
        # Could become a separate DataAccess component later
        return self.repository.get_sales(request.start, request.end)

    def _format_report(self, data, format):
        # Could become a separate ReportRenderer component later
        if format == 'pdf':
            return PdfRenderer().render(data)
        return CsvRenderer().render(data)


# Strategy 2: Interface with single implementation
class SalesDataProvider(Protocol):
    def get_sales(self, start: date, end: date) -> list[Sale]: ...

class PostgresSalesProvider:
    def get_sales(self, start: date, end: date) -> list[Sale]:
        # Implementation here

# Both live in same component, but interface enables future split
# When split needed: move interface to one component, impl to another


# Strategy 3: One-dimensional boundary
# Skip reciprocal interface - simpler but weaker protection
class ReportGenerator:
    def __init__(self, data_provider: SalesDataProvider):
        self.data_provider = data_provider  # Depends on abstraction

# SalesDataProvider implementation knows about ReportGenerator
# Not fully decoupled, but good enough for now
```

**When to use partial boundaries:**
- You suspect a boundary will be needed, but not yet
- Team is small and deployment is unified
- Cost of full boundary outweighs current benefits

Reference: [Clean Architecture - Partial Boundaries](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch24.xhtml)
