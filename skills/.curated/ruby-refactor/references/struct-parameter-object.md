---
title: Introduce Parameter Object for Long Signatures
impact: CRITICAL
impactDescription: eliminates parameter coupling across call chain
tags: struct, parameter-object, data-clump, sandi-metz
---

## Introduce Parameter Object for Long Signatures

Long parameter lists couple every caller to the exact position and count of arguments. When the same group of parameters appears in multiple methods, it signals a missing concept. Bundling them into objects names the concept and gives validation a natural home. Sandi Metz's rule: 4 parameters max.

**Incorrect (5+ parameters repeated across methods):**

```ruby
class PropertySearch
  def search(start_date, end_date, min_price, max_price, category, sort_by: :relevance)
    properties = Property.where(category: category)
    properties = properties.where("available_from <= ? AND available_to >= ?", start_date, end_date)
    properties = properties.where("price >= ? AND price <= ?", min_price, max_price)
    properties.order(sort_by)
  end

  def count(start_date, end_date, min_price, max_price, category)
    # Same 5 parameters duplicated across the call chain
    properties = Property.where(category: category)
    properties = properties.where("available_from <= ? AND available_to >= ?", start_date, end_date)
    properties.where("price >= ? AND price <= ?", min_price, max_price).count
  end

  def average_price(start_date, end_date, min_price, max_price, category)
    properties = Property.where(category: category)
    properties = properties.where("available_from <= ? AND available_to >= ?", start_date, end_date)
    properties.where("price >= ? AND price <= ?", min_price, max_price).average(:price)
  end
end
```

**Correct (parameter objects encapsulate related data):**

```ruby
class DateRange
  attr_reader :start_date, :end_date

  def initialize(start_date:, end_date:)
    raise ArgumentError, "start_date must precede end_date" if start_date > end_date

    @start_date = start_date
    @end_date = end_date
  end

  def to_scope(relation)
    relation.where("available_from <= ? AND available_to >= ?", start_date, end_date)
  end
end

class PriceRange
  attr_reader :min_price, :max_price

  def initialize(min_price:, max_price:)
    raise ArgumentError, "min_price must not exceed max_price" if min_price > max_price

    @min_price = min_price
    @max_price = max_price
  end

  def to_scope(relation)
    relation.where("price >= ? AND price <= ?", min_price, max_price)
  end
end

class PropertySearch
  def search(date_range, price_range, category, sort_by: :relevance)
    filter(date_range, price_range, category).order(sort_by)
  end

  def count(date_range, price_range, category)
    filter(date_range, price_range, category).count
  end

  def average_price(date_range, price_range, category)
    filter(date_range, price_range, category).average(:price)
  end

  private

  def filter(date_range, price_range, category)
    scope = Property.where(category: category)
    scope = date_range.to_scope(scope)
    price_range.to_scope(scope)
  end
end
```

Reference: Sandi Metz, *Practical Object-Oriented Design* -- pass no more than 4 parameters.
