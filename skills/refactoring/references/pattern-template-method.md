---
title: Use Template Method for Shared Skeleton
impact: MEDIUM-HIGH
impactDescription: eliminates duplicate control flow across similar algorithms
tags: pattern, template-method, inheritance, skeleton
---

## Use Template Method for Shared Skeleton

When multiple classes have similar algorithms with different steps, define the skeleton in a base class and let subclasses override specific steps.

**Incorrect (duplicated algorithm structure):**

```typescript
class PDFReportGenerator {
  generate(data: ReportData): void {
    this.logStart('PDF')  // Duplicated
    const validated = this.validateData(data)  // Duplicated
    if (!validated) throw new Error('Invalid data')  // Duplicated

    // PDF-specific formatting
    const content = this.formatAsPDF(data)
    this.writeToPDF(content)

    this.logComplete('PDF')  // Duplicated
    this.sendNotification()  // Duplicated
  }
}

class ExcelReportGenerator {
  generate(data: ReportData): void {
    this.logStart('Excel')  // Duplicated
    const validated = this.validateData(data)  // Duplicated
    if (!validated) throw new Error('Invalid data')  // Duplicated

    // Excel-specific formatting
    const content = this.formatAsExcel(data)
    this.writeToExcel(content)

    this.logComplete('Excel')  // Duplicated
    this.sendNotification()  // Duplicated
  }
}
```

**Correct (template method pattern):**

```typescript
abstract class ReportGenerator {
  // Template method defines the skeleton
  generate(data: ReportData): void {
    this.logStart()
    this.validateData(data)
    const content = this.formatContent(data)  // Abstract - subclass implements
    this.writeOutput(content)  // Abstract - subclass implements
    this.logComplete()
    this.sendNotification()
  }

  private logStart(): void {
    console.log(`Starting ${this.getReportType()} generation`)
  }

  private validateData(data: ReportData): void {
    if (!data.title || !data.rows.length) {
      throw new Error('Invalid report data')
    }
  }

  private logComplete(): void {
    console.log(`Completed ${this.getReportType()} generation`)
  }

  private sendNotification(): void {
    notifyReportComplete(this.getReportType())
  }

  // Hook methods for subclasses to implement
  protected abstract getReportType(): string
  protected abstract formatContent(data: ReportData): string
  protected abstract writeOutput(content: string): void
}

class PDFReportGenerator extends ReportGenerator {
  protected getReportType(): string { return 'PDF' }

  protected formatContent(data: ReportData): string {
    return formatAsPDF(data)
  }

  protected writeOutput(content: string): void {
    writeToPDFFile(content)
  }
}

class ExcelReportGenerator extends ReportGenerator {
  protected getReportType(): string { return 'Excel' }

  protected formatContent(data: ReportData): string {
    return formatAsExcel(data)
  }

  protected writeOutput(content: string): void {
    writeToExcelFile(content)
  }
}
```

**Benefits:**
- Algorithm skeleton defined once
- Subclasses focus on what's different
- Adding new report types only requires implementing abstract methods

Reference: [Template Method Pattern](https://refactoring.guru/design-patterns/template-method)
