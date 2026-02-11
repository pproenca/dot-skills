---
title: Inject Dependencies via Constructor Defaults
impact: HIGH
impactDescription: enables test isolation without monkey-patching
tags: couple, dependency-injection, testability, constructor
---

## Inject Dependencies via Constructor Defaults

Hard-coded class references inside methods make it impossible to substitute collaborators in tests without monkey-patching or stubbing globals. Injecting dependencies through the constructor with sensible defaults preserves the production path while giving tests a clean seam.

**Incorrect (hard-coded dependency buried inside the method):**

```ruby
class WeatherService
  def forecast(city)
    # Locked to HTTPClient — tests must hit the network or stub a global
    client = HTTPClient.new
    response = client.get("https://api.weather.example.com/v1/forecast?city=#{city}")
    JSON.parse(response.body)
  end
end
```

**Correct (inject via constructor with production default):**

```ruby
class WeatherService
  def initialize(client: HTTPClient.new)
    # Default preserves production behavior; tests inject a fake
    @client = client
  end

  def forecast(city)
    response = @client.get("https://api.weather.example.com/v1/forecast?city=#{city}")
    JSON.parse(response.body)
  end
end

# Test usage — no monkey-patching, no network
fake_client = instance_double(HTTPClient)
allow(fake_client).to receive(:get).and_return(
  OpenStruct.new(body: '{"temp": 22, "condition": "sunny"}')
)
service = WeatherService.new(client: fake_client)
result = service.forecast("London")
expect(result["temp"]).to eq(22)
```
