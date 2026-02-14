---
title: Thin Controllers with Rich Domain Models
impact: HIGH
impactDescription: reduces controller size to under 100 lines
tags: ctrl, thin-controllers, domain-models, separation
---

## Thin Controllers with Rich Domain Models

Controllers handle HTTP concerns only: authentication, parameter parsing, and response formatting. All business logic belongs in domain models. Simple ActiveRecord operations like `create!` or `update!` can live in the controller directly — there is no need to wrap trivial persistence in model methods. The test is whether the logic requires domain knowledge: if it does, it belongs in the model.

**Incorrect (fat controller with business logic):**

```ruby
class InvoicesController < ApplicationController
  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.number = "INV-#{Date.current.strftime('%Y%m')}-#{Invoice.count + 1}"
    @invoice.due_date = Date.current + @invoice.account.payment_terms.days
    @invoice.tax_amount = @invoice.line_items.sum { |li| li.amount * li.tax_rate }
    @invoice.total = @invoice.line_items.sum(&:amount) + @invoice.tax_amount

    if @invoice.total > 10_000
      @invoice.requires_approval = true
      @invoice.approval_status = "pending"
    end

    if @invoice.save
      @invoice.account.update!(outstanding_balance: @invoice.account.outstanding_balance + @invoice.total)
      InvoiceMailer.created(@invoice).deliver_later if @invoice.account.email_notifications?
      redirect_to @invoice
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Correct (thin controller delegating to rich model):**

```ruby
class InvoicesController < ApplicationController
  def create
    @invoice = Current.account.invoices.create!(invoice_params)
    redirect_to @invoice
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def invoice_params
    params.expect(invoice: [:recipient_id, line_items_attributes: [:description, :amount, :tax_rate]])
  end
end

# app/models/invoice.rb — business logic lives here
class Invoice < ApplicationRecord
  belongs_to :account
  has_many :line_items, dependent: :destroy
  accepts_nested_attributes_for :line_items

  before_validation :assign_number, on: :create
  before_validation :calculate_totals
  after_create_commit :notify_account
  after_create_commit :update_outstanding_balance

  def requires_approval?
    total > 10_000
  end

  private

  def assign_number
    self.number = "INV-#{Date.current.strftime('%Y%m')}-#{account.invoices.count + 1}"
    self.due_date = Date.current + account.payment_terms.days
  end

  def calculate_totals
    self.tax_amount = line_items.sum { |li| li.amount * li.tax_rate }
    self.total = line_items.sum(&:amount) + tax_amount
    self.approval_status = "pending" if requires_approval?
  end

  def notify_account
    InvoiceMailer.created(self).deliver_later if account.email_notifications?
  end

  def update_outstanding_balance
    account.increment!(:outstanding_balance, total)
  end
end
```

**When NOT to use:** Simple CRUD actions that only call `create!`, `update!`, or `destroy!` do not need model method wrappers. Extracting `Invoice#save_invoice` that just calls `save!` adds indirection without value.

Reference: [Vanilla Rails is Plenty](https://dev.37signals.com/vanilla-rails-is-plenty/)
