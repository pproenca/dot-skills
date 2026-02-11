---
title: Replace Data Clumps with Grouped Objects
impact: MEDIUM
impactDescription: eliminates parameter coupling across 3+ methods
tags: data, data-clump, parameter-object, cohesion
---

## Replace Data Clumps with Grouped Objects

When the same group of parameters travels together through three or more methods, it signals a missing concept. Adding a sixth field means updating every method signature, every caller, and every test. Extracting the clump into a named object makes the concept explicit and gives formatting, validation, and comparison a natural home.

**Incorrect (address fields repeated across multiple methods):**

```ruby
class ShippingService
  def estimate_cost(street, city, state, zip, weight)
    zone = ZoneCalculator.zone_for(city, state, zip) # same 3 fields again
    rate = RateTable.lookup(zone, weight)
    rate
  end

  def validate_address(street, city, state, zip)
    # 4 parameters that always appear together
    ZipLookup.valid?(zip, city, state)
  end

  def format_label(street, city, state, zip, name)
    "#{name}\n#{street}\n#{city}, #{state} #{zip}"
  end
end

cost = service.estimate_cost("123 Main St", "Portland", "OR", "97201", 2.5)
valid = service.validate_address("123 Main St", "Portland", "OR", "97201")
label = service.format_label("123 Main St", "Portland", "OR", "97201", "Jane Doe")
```

**Correct (grouped into an Address object that owns its behavior):**

```ruby
class Address
  attr_reader :street, :city, :state, :zip

  def initialize(street:, city:, state:, zip:)
    @street = street
    @city = city
    @state = state
    @zip = zip
  end

  def valid?
    ZipLookup.valid?(zip, city, state)
  end

  # Formatting lives with the data it formats
  def to_label(name)
    "#{name}\n#{street}\n#{city}, #{state} #{zip}"
  end
end

class ShippingService
  def estimate_cost(address, weight)
    zone = ZoneCalculator.zone_for(address.city, address.state, address.zip)
    rate = RateTable.lookup(zone, weight)
    rate
  end

  def validate_address(address)
    address.valid?
  end

  def format_label(address, name)
    address.to_label(name)
  end
end

address = Address.new(street: "123 Main St", city: "Portland", state: "OR", zip: "97201")
cost = service.estimate_cost(address, 2.5)
valid = service.validate_address(address)
label = service.format_label(address, "Jane Doe")
```
