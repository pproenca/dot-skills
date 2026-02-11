---
title: Spell Out Names Except Universal Abbreviations
impact: LOW-MEDIUM
impactDescription: prevents ambiguity and miscommunication
tags: name, abbreviations, readability, clarity
---

## Spell Out Names Except Universal Abbreviations

Abbreviated names save keystrokes but cost minutes in comprehension. `desc` could mean description, descending, or descriptor. `mgr` saves three characters but forces every reader to mentally expand it. Spell out names fully unless the abbreviation is universally understood in software (`id`, `url`, `html`, `json`, `http`, `db`, `io`, `api`).

**Incorrect (abbreviations create ambiguity):**

```ruby
class TxnProcessor
  def calc_avg_txn_amt(acct)
    txns = acct.txns.where(stat: :completed)
    return 0 if txns.empty?

    tot_amt = txns.sum(&:amt)
    avg = tot_amt / txns.cnt
    avg
  end

  def gen_rpt(dept_mgr, dt_range)
    txns = dept_mgr.dept.txns.where(created_at: dt_range)
    qty = txns.count
    desc = txns.group(:cat).sum(:amt)  # desc — description or descending?
    { qty: qty, desc: desc }
  end
end
```

**Correct (spelled-out names eliminate guesswork):**

```ruby
class TransactionProcessor
  def calculate_average_transaction_amount(account)
    transactions = account.transactions.where(status: :completed)
    return 0 if transactions.empty?

    total_amount = transactions.sum(&:amount)
    average = total_amount / transactions.count
    average
  end

  def generate_report(department_manager, date_range)
    transactions = department_manager.department.transactions.where(created_at: date_range)
    quantity = transactions.count
    breakdown = transactions.group(:category).sum(:amount)  # no ambiguity
    { quantity: quantity, breakdown: breakdown }
  end
end
```

Commonly misused abbreviations to always spell out:

| Abbreviation | Spell out as |
|---|---|
| `mgr` | `manager` |
| `amt` | `amount` |
| `qty` | `quantity` |
| `desc` | `description` (or `descending` — the ambiguity proves the point) |
| `txn` | `transaction` |
| `util` | `utility` |
| `calc` | `calculate` |
| `rpt` | `report` |
| `dept` | `department` |
| `cnt` | `count` |
| `stat` | `status` |
| `cat` | `category` |
