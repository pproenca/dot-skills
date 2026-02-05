---
title: Use Properties to Customize Views
impact: HIGH
impactDescription: enables view reuse, passes data to child views, creates configurable components
tags: view, swiftui, properties, customization, reuse, parameters
---

## Use Properties to Customize Views

Add properties to custom views to make them configurable. Properties allow the same view to display different data based on the values passed to its initializer.

**Incorrect (hardcoded values):**

```swift
// Every instance shows the same data
struct DayForecastView: View {
    var body: some View {
        VStack {
            Text("Mon")  // Hardcoded
            Image(systemName: "sun.max.fill")  // Hardcoded
            Text("70°")  // Hardcoded
        }
    }
}

// Can't customize without creating multiple view types
```

**Correct (configurable properties):**

```swift
struct DayForecastView: View {
    var day: String
    var icon: String
    var temperature: Int

    var body: some View {
        VStack {
            Text(day)
            Image(systemName: icon)
                .font(.largeTitle)
            Text("\(temperature)°")
        }
    }
}

// Usage - same view, different data
HStack {
    DayForecastView(day: "Mon", icon: "sun.max.fill", temperature: 70)
    DayForecastView(day: "Tue", icon: "cloud.fill", temperature: 65)
    DayForecastView(day: "Wed", icon: "cloud.rain.fill", temperature: 58)
}
```

**Property patterns:**
- Stored properties for data input
- Computed properties for derived values
- Default values for optional customization
- Use structs for models to group related properties

Reference: [Develop in Swift Tutorials - Customize views with properties](https://developer.apple.com/tutorials/develop-in-swift/customize-views-with-properties)
