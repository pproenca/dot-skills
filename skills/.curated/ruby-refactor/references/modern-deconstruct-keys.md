---
title: Implement deconstruct_keys for Custom Pattern Matching
impact: MEDIUM
impactDescription: enables pattern matching on domain objects
tags: modern, deconstruct-keys, pattern-matching, protocol
---

## Implement deconstruct_keys for Custom Pattern Matching

Without `deconstruct_keys`, custom objects cannot participate in Ruby 3.0+ `case/in` pattern matching, forcing callers back to manual accessor checks and conditionals. Implementing this protocol method lets domain objects expose their structure declaratively, enabling the same concise matching syntax that works with hashes and arrays.

**Incorrect (manual attribute checks on domain objects):**

```ruby
class Coordinate
  attr_reader :latitude, :longitude, :altitude

  def initialize(latitude:, longitude:, altitude: nil)
    @latitude = latitude
    @longitude = longitude
    @altitude = altitude
  end
end

class FlightTracker
  def classify_position(coordinate)
    if coordinate.latitude.between?(-90, 90) && coordinate.longitude.between?(-180, 180)
      if coordinate.altitude && coordinate.altitude > 10_000  # manual accessor checks, no structural matching
        :high_altitude
      elsif coordinate.altitude
        :low_altitude
      else
        :ground_level
      end
    else
      :invalid
    end
  end
end
```

**Correct (deconstruct_keys enables case/in on domain objects):**

```ruby
class Coordinate
  attr_reader :latitude, :longitude, :altitude

  def initialize(latitude:, longitude:, altitude: nil)
    @latitude = latitude
    @longitude = longitude
    @altitude = altitude
  end

  def deconstruct_keys(keys)  # enables pattern matching protocol for this class
    h = {}
    h[:latitude] = latitude if keys.nil? || keys.include?(:latitude)
    h[:longitude] = longitude if keys.nil? || keys.include?(:longitude)
    h[:altitude] = altitude if keys.nil? || keys.include?(:altitude)
    h
  end
end

class FlightTracker
  def classify_position(coordinate)
    case coordinate
    in { latitude: (-90..90), longitude: (-180..180), altitude: (10_001..) }
      :high_altitude
    in { latitude: (-90..90), longitude: (-180..180), altitude: Integer }
      :low_altitude
    in { latitude: (-90..90), longitude: (-180..180) }  # matches ground level naturally
      :ground_level
    else
      :invalid
    end
  end
end
```
