---
title: Use Data.define for Immutable Value Objects
impact: MEDIUM-HIGH
impactDescription: immutable by default, 85x faster than OpenStruct
tags: data, data-define, immutable, ruby3
---

## Use Data.define for Immutable Value Objects

Hand-rolled value objects require boilerplate for initialization, freezing, equality, and pattern matching -- and every line is a chance to forget `freeze` or misimplement `==`. `Data.define` provides all of this out of the box with zero ceremony, and benchmarks at 85x faster than OpenStruct for construction. Ruby 3.2+ only.

**Incorrect (manual boilerplate for immutability and equality):**

```ruby
class Coordinate
  attr_reader :latitude, :longitude

  def initialize(latitude:, longitude:)
    raise ArgumentError, "invalid latitude" unless (-90..90).cover?(latitude)
    raise ArgumentError, "invalid longitude" unless (-180..180).cover?(longitude)

    @latitude = latitude
    @longitude = longitude
    freeze # easy to forget, breaks immutability guarantee
  end

  def ==(other)
    other.is_a?(self.class) &&
      latitude == other.latitude &&
      longitude == other.longitude
  end
  alias_method :eql?, :==

  def hash = [latitude, longitude].hash

  def deconstruct_keys(keys)
    { latitude: latitude, longitude: longitude }
  end
end
```

**Correct (Data.define — immutable, equatable, pattern-matchable):**

```ruby
Coordinate = Data.define(:latitude, :longitude) do
  def initialize(latitude:, longitude:)
    raise ArgumentError, "invalid latitude" unless (-90..90).cover?(latitude)
    raise ArgumentError, "invalid longitude" unless (-180..180).cover?(longitude)

    super # frozen, ==, eql?, hash, and deconstruct_keys provided automatically
  end

  def to_s = "#{latitude}, #{longitude}"
end

# Pattern matching works out of the box
coordinate = Coordinate.new(latitude: 51.5074, longitude: -0.1278)

case coordinate
in Coordinate[latitude: (50..55) => lat, longitude:]
  puts "UK region: #{lat}, #{longitude}"
end
```

Note: `Data.define` requires Ruby 3.2+. For earlier versions, use `Struct` with `keyword_init: true` and manual `freeze`.
