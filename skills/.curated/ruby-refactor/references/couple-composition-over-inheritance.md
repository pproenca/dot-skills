---
title: Replace Mixin with Composed Object
impact: HIGH
impactDescription: eliminates hidden method conflicts and unclear precedence
tags: couple, composition, mixin, module, inheritance
---

## Replace Mixin with Composed Object

Including multiple modules flattens their methods into a single namespace where conflicts are silent and resolution depends on `ancestors` order. As the mixin count grows, the precedence chain becomes unpredictable and debugging requires tracing through `ancestors`. Composition makes each collaborator explicit with its own interface and no name collisions.

**Incorrect (multiple includes with hidden conflict):**

```ruby
module Searchable
  def search(query)
    # Full-text search across all fields
    records.select { |r| r.values.any? { |v| v.to_s.include?(query) } }
  end
end

module Filterable
  def search(query)
    # Filters by exact match — silently overrides Searchable#search
    records.select { |r| r[:name] == query }
  end
end

class ProductCatalog
  include Searchable
  include Filterable  # ancestors: Filterable wins — Searchable#search is dead code

  attr_reader :records

  def initialize(records)
    @records = records
  end
end
```

**Correct (composed objects with explicit interfaces):**

```ruby
class SearchEngine
  def initialize(records)
    @records = records
  end

  def search(query)
    @records.select { |r| r.values.any? { |v| v.to_s.include?(query) } }
  end
end

class Filter
  def initialize(records)
    @records = records
  end

  def search(query)
    @records.select { |r| r[:name] == query }
  end
end

class ProductCatalog
  attr_reader :records

  def initialize(records, search_engine: SearchEngine.new(records), filter: Filter.new(records))
    @records = records
    @search_engine = search_engine
    @filter = filter
  end

  # No conflict — each collaborator has its own object and name
  def full_text_search(query) = @search_engine.search(query)
  def exact_filter(query) = @filter.search(query)
end
```
