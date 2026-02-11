---
title: Use Lazy Initialization for Expensive Objects
impact: HIGH
impactDescription: defers allocation until needed, reduces startup overhead
tags: alloc, lazy, initialization, memoization
---

## Use Lazy Initialization for Expensive Objects

Eagerly building expensive objects in `initialize` forces allocation even when those objects are never accessed. Lazy initialization with `||=` defers the cost until first use, keeping object construction fast and memory footprint low for unused code paths.

**Incorrect (allocates everything upfront):**

```ruby
class OrderProcessor
  def initialize(config)
    @config = config
    @validator = OrderValidator.new(config.rules)       # Allocated even if unused
    @tax_calculator = TaxCalculator.new(config.region)  # Expensive API lookup on init
    @shipping_estimator = ShippingEstimator.new(
      carriers: config.carriers,
      warehouse: config.warehouse                       # Opens connection immediately
    )
    @audit_logger = AuditLogger.new(config.log_path)    # File handle opened on init
  end

  def validate(order)
    @validator.check(order)
  end
end
```

**Correct (allocates only when first accessed):**

```ruby
class OrderProcessor
  def initialize(config)
    @config = config
  end

  def validate(order)
    validator.check(order)
  end

  private

  def validator
    @validator ||= OrderValidator.new(@config.rules)
  end

  def tax_calculator
    @tax_calculator ||= TaxCalculator.new(@config.region)
  end

  def shipping_estimator
    @shipping_estimator ||= ShippingEstimator.new(
      carriers: @config.carriers,
      warehouse: @config.warehouse
    )
  end

  def audit_logger
    @audit_logger ||= AuditLogger.new(@config.log_path)
  end
end
```

**When to prefer eager initialization:**
- When the object is always used in every code path
- When initialization failure should surface immediately at construction time
- When thread safety requires controlled initialization order
