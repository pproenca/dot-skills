---
title: "Use Stubs for Deterministic Return Values"
impact: HIGH
impactDescription: "eliminates network/disk flakiness from unit tests"
tags: mock, stub, deterministic, isolation
---

## Use Stubs for Deterministic Return Values

Tests that depend on live APIs or disk state produce different results across runs, environments, and CI machines. Stubs return predetermined `Result` values so every assertion runs against an identical, reproducible response regardless of network availability or server state.

**Incorrect (test fails when API is down or response changes):**

```swift
func testLoadWeatherForecast() async throws {
    let service = WeatherService(apiKey: "test-key")

    let forecast = try await service.fetchForecast(city: "London") // real HTTP request — flaky on CI, slow, rate-limited

    #expect(!forecast.daily.isEmpty)
}
```

**Correct (stub guarantees identical response every run):**

```swift
struct StubWeatherClient: WeatherFetching {
    var result: Result<Forecast, Error> // predetermined outcome — no network involved

    func fetchForecast(city: String) async throws -> Forecast {
        return try result.get()
    }
}

func testLoadWeatherForecast() async throws {
    let forecast = Forecast(daily: [
        .init(date: Date(), high: 18, low: 11, condition: .cloudy)
    ])
    let stub = StubWeatherClient(result: .success(forecast))
    let viewModel = WeatherViewModel(client: stub)

    await viewModel.loadForecast(city: "London")

    #expect(viewModel.forecast?.daily.count == 1)
    #expect(viewModel.forecast?.daily.first?.condition == .cloudy) // deterministic — same result on every machine
}
```
