---
title: Separate Query Methods from Command Methods
impact: MEDIUM
impactDescription: enables safe caching and idempotent reads
tags: data, cqrs, query, command, side-effects
---

## Separate Query Methods from Command Methods

A method that both returns a value and mutates state is impossible to call safely -- callers cannot check a balance without accidentally triggering a withdrawal, and the result cannot be cached or retried. Separating queries (return data, no side effects) from commands (mutate state, return nothing) makes each independently testable, cacheable, and composable.

**Incorrect (query and command tangled in one method):**

```ruby
class Account
  attr_reader :balance, :transactions

  def initialize(balance:)
    @balance = balance
    @transactions = []
  end

  def withdraw(amount)
    # Returns remaining balance AND mutates state — caller can't query without side effects
    raise InsufficientFundsError, "balance too low" if amount > @balance

    @balance -= amount
    @transactions << { type: :withdrawal, amount: amount, at: Time.current }
    @balance
  end
end

account = Account.new(balance: 500.00)
remaining = account.withdraw(100.00) # wanted to check balance, got a mutation instead
```

**Correct (query returns data, command mutates state):**

```ruby
class Account
  attr_reader :balance, :transactions

  def initialize(balance:)
    @balance = balance
    @transactions = []
  end

  # Query — safe to call any number of times, cacheable
  def sufficient_funds?(amount)
    amount <= @balance
  end

  # Command — mutates state, returns nothing
  def withdraw(amount)
    raise InsufficientFundsError, "balance too low" unless sufficient_funds?(amount)

    @balance -= amount
    @transactions << { type: :withdrawal, amount: amount, at: Time.current }
    nil # explicit nil signals no return value by design
  end
end

account = Account.new(balance: 500.00)
if account.sufficient_funds?(100.00)  # query — no side effects
  account.withdraw(100.00)            # command — explicit mutation
end
```
