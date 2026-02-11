---
title: Profile and Fix Slow Specs
impact: MEDIUM
impactDescription: 10% of specs often account for 80% of total suite time
tags: perf, profiling, slow-tests, create-vs-build, optimization
---

## Profile and Fix Slow Specs

Most teams accept a slow suite without investigating where the time actually goes. Running `rspec --profile` surfaces the slowest examples, and the fixes are almost always the same: replacing `create` with `build` or `build_stubbed` when persistence isn't needed, converting system tests to request specs when JavaScript isn't required, and adding missing database indexes to test databases. A targeted 30-minute profiling session often cuts suite time by 30-50%.

**Incorrect (accepting slow suite without investigation):**

```ruby
# spec/models/invoice_spec.rb — every test hits the database unnecessarily
RSpec.describe Invoice do
  describe "#total" do
    it "sums line items" do
      invoice = create(:invoice)  # INSERT into invoices
      create(:line_item, invoice: invoice, amount_cents: 1000)  # INSERT into line_items
      create(:line_item, invoice: invoice, amount_cents: 2500)  # INSERT into line_items

      expect(invoice.total_cents).to eq(3500)
    end
  end

  describe "#overdue?" do
    it "returns true when past due date" do
      invoice = create(:invoice, due_date: 1.day.ago, status: :unpaid)

      expect(invoice).to be_overdue
    end
  end
end

# spec/system/admin_reports_spec.rb — full browser test for a data table
RSpec.describe "Admin reports", type: :system do
  it "displays filtered invoices" do
    create_list(:invoice, 50, status: :paid)

    visit admin_reports_path
    select "Paid", from: "Status"
    click_on "Filter"

    expect(page).to have_css("table tbody tr", count: 50)
  end
end
```

**Correct (profiled and optimized — build where possible, request spec where sufficient):**

```ruby
# Run: bundle exec rspec --profile 20
# Identify slowest specs, then apply targeted fixes:

# spec/models/invoice_spec.rb — no database needed for pure calculation
RSpec.describe Invoice do
  describe "#total" do
    it "sums line items" do
      invoice = build(:invoice)
      invoice.line_items = build_list(:line_item, 2, amount_cents: [1000, 2500].cycle)

      expect(invoice.total_cents).to eq(3500)
    end
  end

  describe "#overdue?" do
    it "returns true when past due date" do
      invoice = build(:invoice, due_date: 1.day.ago, status: :unpaid)

      expect(invoice).to be_overdue
    end
  end
end

# spec/requests/admin_reports_spec.rb — request spec is 10x faster than system test
RSpec.describe "Admin reports", type: :request do
  it "returns filtered invoices as JSON" do
    create_list(:invoice, 3, status: :paid)
    create(:invoice, status: :unpaid)

    get admin_reports_path, params: { status: "paid" }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["invoices"].size).to eq(3)
  end
end

# Tip: Add test-specific indexes if queries are slow
# db/migrate/xxx_add_index_on_invoices_status.rb (if missing)
```

Reference: [RSpec --profile flag](https://rspec.info/features/3-12/rspec-core/command-line/profile/) | [thoughtbot — Speed Up Tests](https://thoughtbot.com/blog/speed-up-tests-by-selectively-avoiding-factory-girl)
