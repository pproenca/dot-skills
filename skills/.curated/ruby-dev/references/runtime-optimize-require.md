---
title: Optimize Require Load Order
impact: LOW
impactDescription: reduces boot time by deferring heavy gem loading
tags: runtime, require, boot, loading
---

## Optimize Require Load Order

Loading every gem at boot increases startup time and memory usage, even when most gems are only needed for specific code paths. Deferring heavy dependencies with `require: false` and `autoload` keeps boot fast and memory lean.

**Incorrect (all gems loaded eagerly at boot):**

```ruby
# Gemfile — every gem loads at startup
gem "rails"
gem "pg"
gem "sidekiq"
gem "prawn"           # PDF generation, 15MB+ memory, rarely used
gem "rmagick"         # Image processing, loads C extensions at boot
gem "elasticsearch"   # Only needed by search controller
gem "grover"          # HTML-to-PDF, loads Puppeteer at require time

# Boot time: ~8 seconds, RSS: ~350MB
# Every web worker pays the cost even if it never generates a PDF
```

**Correct (defer heavy gems until first use):**

```ruby
# Gemfile — defer gems not needed on every request
gem "rails"
gem "pg"
gem "sidekiq"
gem "prawn", require: false          # Loaded only when generating PDFs
gem "rmagick", require: false        # Loaded only for image processing
gem "elasticsearch", require: false  # Loaded only by search module
gem "grover", require: false

# app/services/invoice_pdf_service.rb
class InvoicePdfService
  def generate(order)
    require "prawn"  # First call pays ~200ms, subsequent calls are no-ops
    Prawn::Document.new do |pdf|
      pdf.text "Invoice ##{order.invoice_number}"
      pdf.text "Total: #{order.formatted_total}"
    end.render
  end
end
```
