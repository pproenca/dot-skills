---
title: Write Descriptive Test Names
impact: HIGH
impactDescription: failing test output becomes a self-documenting specification
tags: design, naming, describe, context, readability
---

## Write Descriptive Test Names

The `describe`/`context`/`it` hierarchy should read like a specification when concatenated. Use `describe "#method_name"` for instance methods, `describe ".method_name"` for class methods, `context "when/with/without..."` for conditions, and `it "returns/creates/raises..."` for expected outcomes. When a test fails in CI, the full description is the first thing anyone reads.

**Incorrect (vague names that convey no specification):**

```ruby
RSpec.describe Invoice do
  describe "generate" do
    it "works" do
      invoice = create(:invoice, :with_line_items)
      expect(invoice.generate_pdf).to be_present
    end

    it "test error" do
      invoice = build(:invoice, line_items: [])
      expect { invoice.generate_pdf }.to raise_error(StandardError)
    end

    it "handles tax" do
      invoice = create(:invoice, :with_line_items, tax_rate: 0.2)
      expect(invoice.total_with_tax).to be > invoice.subtotal
    end
  end
end
# Failure output: "Invoice generate works FAILED" — tells you nothing
```

**Correct (reads as a specification):**

```ruby
RSpec.describe Invoice do
  describe "#generate_pdf" do
    context "when the invoice has line items" do
      it "returns a PDF binary string" do
        invoice = create(:invoice, :with_line_items)

        pdf = invoice.generate_pdf

        expect(pdf).to start_with("%PDF")
      end
    end

    context "when the invoice has no line items" do
      it "raises an EmptyInvoiceError" do
        invoice = build(:invoice, line_items: [])

        expect { invoice.generate_pdf }.to raise_error(Invoice::EmptyInvoiceError)
      end
    end
  end

  describe "#total_with_tax" do
    context "when a 20% tax rate applies" do
      it "returns the subtotal multiplied by 1.2" do
        invoice = create(:invoice, :with_line_items, subtotal_cents: 10_000, tax_rate: 0.2)

        expect(invoice.total_with_tax_cents).to eq(12_000)
      end
    end
  end
end
# Failure output: "Invoice #generate_pdf when the invoice has no line items raises an EmptyInvoiceError FAILED"
```

Reference: [Better Specs — How to Describe Your Methods](https://www.betterspecs.org/#describe)
