# Best Practices

**Version 1.0.0**  
Apple  
2025-02-05

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide for Swift and SwiftUI app development based on Apple's official Develop in Swift Tutorials, covering Swift fundamentals, SwiftUI views, SwiftData persistence, and app distribution.

---

## Table of Contents

1. [Swift Language Fundamentals](#1-swift-language-fundamentals) — **CRITICAL**
   - 1.1 [Handle Optionals Safely with Unwrapping](#11-handle-optionals-safely-with-unwrapping)
   - 1.2 [Name Functions and Parameters for Clarity](#12-name-functions-and-parameters-for-clarity)
   - 1.3 [Prefer Structs Over Classes](#13-prefer-structs-over-classes)
   - 1.4 [Use camelCase Naming Convention](#14-use-camelcase-naming-convention)
   - 1.5 [Use Closures for Inline Functions](#15-use-closures-for-inline-functions)
   - 1.6 [Use for-in Loops for Collections](#16-use-for-in-loops-for-collections)
   - 1.7 [Use let for Constants, var for Variables](#17-use-let-for-constants-var-for-variables)
   - 1.8 [Use String Interpolation for Dynamic Text](#18-use-string-interpolation-for-dynamic-text)
2. [SwiftUI View Basics](#2-swiftui-view-basics) — **CRITICAL**
   - 2.1 [Apply Gradients for Visual Interest](#21-apply-gradients-for-visual-interest)
   - 2.2 [Apply Modifiers in Correct Order](#22-apply-modifiers-in-correct-order)
   - 2.3 [Return some View from Body Property](#23-return-some-view-from-body-property)
   - 2.4 [Use #Preview for Live Development](#24-use-preview-for-live-development)
   - 2.5 [Use Properties to Customize Views](#25-use-properties-to-customize-views)
   - 2.6 [Use SF Symbols for System Icons](#26-use-sf-symbols-for-system-icons)
   - 2.7 [Use System Colors for Dark Mode Support](#27-use-system-colors-for-dark-mode-support)
   - 2.8 [Use VStack, HStack, ZStack for Layout](#28-use-vstack-hstack-zstack-for-layout)
3. [State & Data Flow](#3-state-data-flow) — **CRITICAL**
   - 3.1 [Use @Binding for Two-Way Data Flow](#31-use-binding-for-two-way-data-flow)
   - 3.2 [Use @Environment for System and Shared Values](#32-use-environment-for-system-and-shared-values)
   - 3.3 [Use @Observable for Shared Model Classes](#33-use-observable-for-shared-model-classes)
   - 3.4 [Use @State for View-Local Value Types](#34-use-state-for-view-local-value-types)
4. [SwiftData & Persistence](#4-swiftdata-persistence) — **HIGH**
   - 4.1 [Configure modelContainer in App Entry Point](#41-configure-modelcontainer-in-app-entry-point)
   - 4.2 [Define Model Relationships with Properties](#42-define-model-relationships-with-properties)
   - 4.3 [Perform CRUD with modelContext](#43-perform-crud-with-modelcontext)
   - 4.4 [Use @Model for SwiftData Persistence](#44-use-model-for-swiftdata-persistence)
   - 4.5 [Use @Query to Fetch SwiftData Models](#45-use-query-to-fetch-swiftdata-models)
5. [Navigation & Presentation](#5-navigation-presentation) — **HIGH**
   - 5.1 [Use NavigationStack for Hierarchical Navigation](#51-use-navigationstack-for-hierarchical-navigation)
   - 5.2 [Use Sheets for Modal Presentation](#52-use-sheets-for-modal-presentation)
   - 5.3 [Use TabView for Top-Level Sections](#53-use-tabview-for-top-level-sections)
6. [Lists & Dynamic Content](#6-lists-dynamic-content) — **HIGH**
   - 6.1 [Add Swipe Actions to List Rows](#61-add-swipe-actions-to-list-rows)
   - 6.2 [Use List and ForEach with Identifiable Data](#62-use-list-and-foreach-with-identifiable-data)
7. [User Input & Forms](#7-user-input-forms) — **MEDIUM-HIGH**
   - 7.1 [Use Button with Action Closures](#71-use-button-with-action-closures)
   - 7.2 [Use Picker and Toggle for Selection Input](#72-use-picker-and-toggle-for-selection-input)
   - 7.3 [Use TextField with Binding for Text Input](#73-use-textfield-with-binding-for-text-input)
8. [Testing & Quality](#8-testing-quality) — **MEDIUM-HIGH**
   - 8.1 [Write Unit Tests with Swift Testing](#81-write-unit-tests-with-swift-testing)
9. [Accessibility & Localization](#9-accessibility-localization) — **MEDIUM-HIGH**
   - 9.1 [Add Accessibility Labels to Interactive Elements](#91-add-accessibility-labels-to-interactive-elements)
   - 9.2 [Support Dynamic Type for All Text](#92-support-dynamic-type-for-all-text)
10. [Debugging & Refinement](#10-debugging-refinement) — **MEDIUM**
   - 10.1 [Use Breakpoints to Debug Code](#101-use-breakpoints-to-debug-code)
   - 10.2 [Use Debug Console for Runtime Inspection](#102-use-debug-console-for-runtime-inspection)
11. [Machine Learning Integration](#11-machine-learning-integration) — **MEDIUM**
   - 11.1 [Use Natural Language Framework for Text Analysis](#111-use-natural-language-framework-for-text-analysis)
12. [visionOS & Spatial Computing](#12-visionos-spatial-computing) — **MEDIUM**
   - 12.1 [Build visionOS Apps with Windows](#121-build-visionos-apps-with-windows)
13. [App Distribution](#13-app-distribution) — **LOW**
   - 13.1 [Test with TestFlight Before Release](#131-test-with-testflight-before-release)

---

## 1. Swift Language Fundamentals

**Impact: CRITICAL**

Master Swift's type system, value vs reference semantics, optionals, and error handling. These foundations determine code safety, readability, and maintainability across all Apple platforms.

### 1.1 Handle Optionals Safely with Unwrapping

**Impact: CRITICAL (prevents crashes, represents missing values, type-safe null handling)**

Optionals represent values that might be missing (`nil`). Use `if let`, `guard let`, or nil-coalescing (`??`) to safely unwrap. Avoid force unwrapping (`!`) except in controlled situations.

**Incorrect (force unwrapping):**

```swift
var name: String? = fetchName()

// Force unwrapping crashes if nil
print(name!)  // Fatal error if name is nil

// Implicitly unwrapped optional used carelessly
var user: User!
print(user.name)  // Crash if user wasn't set
```

**Correct (safe unwrapping):**

```swift
var name: String? = fetchName()

// if let - use unwrapped value in block
if let name = name {
    print("Hello, \(name)")
} else {
    print("Hello, stranger")
}

// guard let - early exit if nil
func greet() {
    guard let name = name else {
        print("No name provided")
        return
    }
    // name is non-optional here
    print("Hello, \(name)")
}

// Nil-coalescing - provide default
let displayName = name ?? "Anonymous"

// Optional chaining - access properties/methods safely
let uppercased = name?.uppercased()  // Returns String? (nil if name is nil)

// In SwiftUI
Text(name ?? "Unknown")

if let birthday = friend.birthday {
    Text(birthday, style: .date)
}
```

**Unwrapping patterns:**
- `if let` - When you need else handling
- `guard let` - Early exit, keeps happy path unindented
- `??` - Default values
- `?.` - Optional chaining for property access
- `!` - Only when nil is a programmer error

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)

### 1.2 Name Functions and Parameters for Clarity

**Impact: HIGH (code reads like natural language, self-documenting, matches Apple API style)**

Swift functions should read like natural language at the call site. Use argument labels that create grammatically correct phrases, and omit labels with `_` when the function name is clear enough.

**Incorrect (unclear or verbose):**

```swift
// Unclear what the string parameter means
func add(s: String) {
    movies.append(Movie(title: s))
}
add(s: "Difficult Cat")  // What is 's'?

// Redundant label
func addMovie(movie title: String) {
    movies.append(Movie(title: title))
}
addMovie(movie: "Difficult Cat")  // "movie" is redundant with function name
```

**Correct (reads naturally at call site):**

```swift
// Omit label when function name is clear
func addMovie(_ title: String) {
    let newMovie = Movie(title: title)
    movies.append(newMovie)
}
addMovie("Difficult Cat")  // Reads naturally

// Use labels for clarity when needed
func move(from source: Int, to destination: Int) {
    // Implementation
}
move(from: 0, to: 5)  // "move from 0 to 5" reads naturally

// Multiple parameters with meaningful labels
func greet(_ name: String, withMessage message: String) {
    print("\(message), \(name)!")
}
greet("Sophie", withMessage: "Hello")  // Clear meaning
```

**Swift parameter naming rules:**
- Use `_` for first parameter when function name provides context
- Use argument labels that create grammatical phrases
- External name (label) can differ from internal name (parameter)
- Make call sites read like English sentences

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)

### 1.3 Prefer Structs Over Classes

**Impact: CRITICAL (value semantics prevent shared mutable state bugs, structs are faster)**

Structs are value types - they're copied when passed around. Classes are reference types - they share identity. Prefer structs for data models unless you need class-specific features like inheritance or reference identity.

**Incorrect (class for simple data model):**

```swift
class Friend {
    var name: String

    init(name: String) {
        self.name = name
    }
}

var friendClass = Friend(name: "Elena")
var otherFriendClass = friendClass
friendClass.name = "Graham"
// otherFriendClass.name is also "Graham" - shared reference!
```

**Correct (struct for value semantics):**

```swift
struct Friend {
    var name: String
}

var friendStruct = Friend(name: "Elena")
var otherFriendStruct = friendStruct
friendStruct.name = "Graham"
// friendStruct.name = "Graham"
// otherFriendStruct.name = "Elena" - independent copy!
```

**When to use classes:**
- SwiftData models (require `@Model` which needs classes)
- Shared mutable state that must be observed across views
- Inheritance hierarchies
- Identity comparison (`===`) is needed

**When to use structs:**
- Simple data containers
- SwiftUI views (all views are structs)
- Immutable or independently copyable data
- Thread-safe data transfer

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)

### 1.4 Use camelCase Naming Convention

**Impact: HIGH (follows Swift API guidelines, improves code readability, matches Apple frameworks)**

Swift uses camelCase: words are joined without spaces, and each word after the first is capitalized. Types use UpperCamelCase (PascalCase), while properties, methods, and variables use lowerCamelCase.

**Incorrect (inconsistent naming):**

```swift
struct user_profile {  // Wrong: snake_case for type
    var user_name: String  // Wrong: snake_case
    var ImageScale: CGFloat  // Wrong: starts with uppercase
}

func GetUserData() { }  // Wrong: starts with uppercase
let MAX_RETRIES = 3  // Wrong: SCREAMING_SNAKE_CASE
```

**Correct (Swift camelCase):**

```swift
struct UserProfile {  // UpperCamelCase for types
    var userName: String  // lowerCamelCase for properties
    var imageScale: CGFloat  // lowerCamelCase
}

func getUserData() { }  // lowerCamelCase for functions
let maxRetries = 3  // lowerCamelCase for constants

// SwiftUI examples
Text("Hello")
    .imageScale(.large)  // Modifier uses lowerCamelCase
    .foregroundStyle(.tint)
```

**Swift naming rules:**
- **Types** (struct, class, enum, protocol): `UpperCamelCase`
- **Properties, methods, variables**: `lowerCamelCase`
- **Constants**: `lowerCamelCase` (not SCREAMING_SNAKE_CASE)
- **Enum cases**: `lowerCamelCase`

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)

### 1.5 Use Closures for Inline Functions

**Impact: HIGH (enables callbacks, powers SwiftUI buttons, functional programming patterns)**

Closures are self-contained blocks of code that capture values from their context. SwiftUI uses closures extensively for button actions, list item views, and async callbacks. Use trailing closure syntax for cleaner code.

**Basic closure syntax:**

```swift
// Full closure syntax
let greet: (String) -> String = { (name: String) -> String in
    return "Hello, \(name)!"
}

// Simplified with type inference
let greet = { name in
    "Hello, \(name)!"
}

// Shorthand argument names
let numbers = [1, 2, 3]
let doubled = numbers.map { $0 * 2 }  // [2, 4, 6]
```

**Closures in SwiftUI:**

```swift
// Button action is a closure
Button("Tap Me") {
    // This closure runs when button is tapped
    count += 1
}

// Trailing closure syntax
Button {
    count += 1
} label: {
    Text("Increment")
}

// ForEach content is a closure
ForEach(friends) { friend in
    Text(friend.name)
}

// onAppear, onChange take closures
.onAppear {
    loadData()
}

.onChange(of: searchText) { oldValue, newValue in
    performSearch(newValue)
}

// Async closures
Task {
    await fetchData()
}
```

**Closure patterns:**
- Use trailing closure syntax when last parameter is a closure
- `$0`, `$1` for shorthand argument names
- Closures capture variables from their context
- `@escaping` for closures stored for later execution

Reference: [Develop in Swift Tutorials - Update the UI with state](https://developer.apple.com/tutorials/develop-in-swift/update-the-ui-with-state)

### 1.6 Use for-in Loops for Collections

**Impact: HIGH (idiomatic Swift, safer than index-based loops, works with any Sequence)**

Swift's `for-in` loop iterates over sequences directly. Prefer it over C-style index loops - it's safer, more readable, and works with any type that conforms to `Sequence`.

**Incorrect (index-based iteration):**

```swift
let pals = ["Elisha", "Andre", "Jasmine"]

// C-style loop is verbose and error-prone
for var i = 0; i < pals.count; i += 1 {
    print(pals[i])
}

// While loop for iteration
var index = 0
while index < pals.count {
    print(pals[index])
    index += 1
}
```

**Correct (for-in iteration):**

```swift
let pals = ["Elisha", "Andre", "Jasmine"]

// Iterate directly over elements
for pal in pals {
    print("Pal: \(pal)")
}

// With index when needed
for (index, pal) in pals.enumerated() {
    print("\(index): \(pal)")
}

// Iterate over ranges
for number in 1...5 {
    print(number)  // 1, 2, 3, 4, 5
}

// Iterate over dictionary
let scores = ["Alice": 95, "Bob": 87]
for (name, score) in scores {
    print("\(name): \(score)")
}
```

**for-in advantages:**
- No off-by-one errors
- Works with any Sequence (arrays, sets, ranges, strings)
- Clearer intent than index manipulation
- SwiftUI uses ForEach which follows the same pattern

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)

### 1.7 Use let for Constants, var for Variables

**Impact: CRITICAL (prevents accidental mutation, communicates intent, enables compiler optimizations)**

Swift distinguishes between constants (`let`) and variables (`var`). Constants cannot be reassigned after initialization, while variables can change. Prefer `let` by default - only use `var` when mutation is required.

**Incorrect (using var when value doesn't change):**

```swift
var userName = "Sophie"
var maxRetries = 3
var apiEndpoint = "https://api.example.com"

// These values never change but are declared as variables
// Compiler can't optimize, readers assume they might change
```

**Correct (let for immutable values):**

```swift
let userName = "Sophie"
let maxRetries = 3
let apiEndpoint = "https://api.example.com"

// Use var only when value needs to change
var currentRetryCount = 0
currentRetryCount += 1  // This actually changes

var lowTemp = 50
lowTemp = 40  // Reassignment is valid
lowTemp += 5  // Modification is valid
```

**Why this matters:**
- `let` prevents accidental mutation bugs
- Communicates intent to other developers
- Enables compiler optimizations
- Swift style prefers immutability

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)

### 1.8 Use String Interpolation for Dynamic Text

**Impact: HIGH (cleaner than concatenation, type-safe, supports complex expressions)**

Swift uses `\(expression)` inside string literals to embed values. This is cleaner and more readable than string concatenation with `+`.

**Incorrect (string concatenation):**

```swift
let name = "Jasmine"
let age = 25

// Verbose and error-prone
let greeting = "Hello, " + name + "! You are " + String(age) + " years old."

// Multiple lines of building
var message = "User: "
message = message + name
message = message + " (age: "
message = message + String(age)
message = message + ")"
```

**Correct (string interpolation):**

```swift
let name = "Jasmine"
let age = 25

// Clean and readable
let greeting = "Hello, \(name)! You are \(age) years old."

// Works with any expression
let pals = ["Elisha", "Andre", "Jasmine"]
for pal in pals {
    print("Pal: \(pal)")
}

// Complex expressions
let price = 19.99
let quantity = 3
let summary = "Total: $\(price * Double(quantity))"

// SwiftUI usage
Text("Welcome, \(userName)!")
```

**Interpolation capabilities:**
- Embed any value that conforms to `CustomStringConvertible`
- Include expressions: `\(items.count + 1)`
- Call methods: `\(name.uppercased())`
- Format with specifiers: `\(price, specifier: "%.2f")`

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)

---

## 2. SwiftUI View Basics

**Impact: CRITICAL**

Understand how to create, compose, and customize SwiftUI views. Views are the fundamental building blocks of your app's interface, and proper view architecture ensures performance and maintainability.

### 2.1 Apply Gradients for Visual Interest

**Impact: MEDIUM (modern app design, depth perception, smooth color transitions)**

Use gradients for backgrounds and fills to add visual depth. SwiftUI provides `LinearGradient`, `RadialGradient`, and `AngularGradient`. Define colors in asset catalog for dark mode support.

**Incorrect (flat colors everywhere):**

```swift
// Flat backgrounds lack visual interest
VStack {
    // Content
}
.background(Color.blue)
```

**Correct (gradient backgrounds):**

```swift
// Linear gradient
VStack {
    Text("Welcome")
        .font(.largeTitle)
}
.frame(maxWidth: .infinity, maxHeight: .infinity)
.background(
    LinearGradient(
        colors: [.blue, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
)

// Using asset catalog colors for dark mode support
.background(
    LinearGradient(
        colors: [Color("GradientStart"), Color("GradientEnd")],
        startPoint: .top,
        endPoint: .bottom
    )
)

// Gradient on shapes
RoundedRectangle(cornerRadius: 12)
    .fill(
        LinearGradient(
            colors: [.orange, .red],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
    .frame(height: 100)

// Radial gradient for spotlight effects
Circle()
    .fill(
        RadialGradient(
            colors: [.white, .clear],
            center: .center,
            startRadius: 0,
            endRadius: 100
        )
    )
```

**Gradient types:**
- `LinearGradient` - Colors transition along a line
- `RadialGradient` - Colors radiate from center
- `AngularGradient` - Colors sweep around center

Reference: [Develop in Swift Tutorials - Design an interface](https://developer.apple.com/tutorials/develop-in-swift/design-an-interface)

### 2.2 Apply Modifiers in Correct Order

**Impact: CRITICAL (modifier order affects appearance, each modifier wraps the previous view)**

SwiftUI modifiers wrap views - each modifier creates a new view containing the previous one. The order matters significantly: `.padding()` then `.background()` produces different results than `.background()` then `.padding()`.

**Incorrect (wrong modifier order):**

```swift
// Background doesn't include padding area
Text("Message")
    .background(Color.yellow, in: RoundedRectangle(cornerRadius: 8))
    .padding()  // Padding is outside the yellow background

// Font modifier after frame has no effect on text sizing
Text("Title")
    .frame(width: 200)
    .font(.largeTitle)  // Won't affect layout calculation
```

**Correct (intentional modifier order):**

```swift
// Padding first, then background covers padded area
Text("Knock, knock!")
    .padding()
    .background(Color.yellow, in: RoundedRectangle(cornerRadius: 8))

// Multiple messages with proper styling
VStack {
    Text("Knock, knock!")
        .padding()
        .background(Color.yellow, in: RoundedRectangle(cornerRadius: 8))

    Text("Who's there?")
        .padding()
        .background(Color.teal, in: RoundedRectangle(cornerRadius: 8))
}
```

**Common modifier patterns:**
1. Content modifiers first (`.font()`, `.foregroundStyle()`)
2. Layout modifiers (`.padding()`, `.frame()`)
3. Background/border (`.background()`, `.overlay()`)
4. Clip shape (`.clipShape()`)
5. Shadow and effects (`.shadow()`)

**Debugging tip:**
Use Xcode's Selectable Mode in preview to see the bounding box of each modifier layer.

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)

### 2.3 Return some View from Body Property

**Impact: CRITICAL (defines view hierarchy, enables SwiftUI's type system, required for all views)**

Every SwiftUI view must have a `body` computed property that returns `some View`. This is the view's content. Use `some` (opaque return type) to let Swift infer the exact type.

**Incorrect (wrong body signature):**

```swift
struct ContentView: View {
    // Missing body property - won't compile
}

struct ContentView: View {
    var body: View {  // Wrong: must be 'some View'
        Text("Hello")
    }
}

struct ContentView: View {
    func body() -> some View {  // Wrong: must be computed property, not function
        Text("Hello")
    }
}
```

**Correct (proper View conformance):**

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

// Preview for canvas
#Preview {
    ContentView()
}
```

**View protocol requirements:**
- Import SwiftUI framework
- Conform struct to `View` protocol
- Implement `body` as computed property
- Return type must be `some View`
- Body should return a single view (use containers to combine multiple)

**Why `some View`:**
- Hides the complex concrete type
- Enables SwiftUI's diffing algorithm
- Allows composition without type erasure

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)

### 2.4 Use #Preview for Live Development

**Impact: HIGH (instant feedback, test multiple configurations, debug visually without running app)**

The `#Preview` macro creates live previews in Xcode's canvas. Use previews to see changes instantly without building and running the full app. Create multiple previews to test different states and configurations.

**Incorrect (no previews):**

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello")
    }
}

// No preview - must run app to see changes
```

**Correct (preview for rapid iteration):**

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

// Multiple previews for different states
#Preview("Light Mode") {
    ContentView()
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}

// Preview with sample data
#Preview("With User") {
    ProfileView(user: User(name: "Sophie", email: "sophie@example.com"))
}
```

**Preview modes:**
- **Live Mode**: Interactive - tap buttons, scroll lists
- **Selectable Mode**: Click elements to highlight corresponding code
- **Variants**: Test different dynamic type sizes, color schemes

**Tips:**
- Press Option + Command + P to refresh preview
- Pin previews to keep them visible while editing other files
- Use `.previewLayout(.sizeThatFits)` for component-sized previews

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)

### 2.5 Use Properties to Customize Views

**Impact: HIGH (enables view reuse, passes data to child views, creates configurable components)**

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

### 2.6 Use SF Symbols for System Icons

**Impact: HIGH (consistent with iOS, automatic scaling, supports Dynamic Type)**

SF Symbols are Apple's icon library with over 5,000 symbols. Use `Image(systemName:)` for consistent, scalable icons that match system appearance and support Dynamic Type.

**Incorrect (custom icon images):**

```swift
// Custom images don't scale or adapt
Image("custom-plus-icon")
    .resizable()
    .frame(width: 24, height: 24)

// Asset-based icons don't match system style
Image("settings-gear")
```

**Correct (SF Symbols):**

```swift
// Basic SF Symbol
Image(systemName: "globe")

// Scaled with text
Image(systemName: "star.fill")
    .imageScale(.large)

// Colored
Image(systemName: "heart.fill")
    .foregroundStyle(.red)

// In buttons and labels
Button {
    addItem()
} label: {
    Label("Add", systemImage: "plus")
}

// Multiple colors
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.multicolor)

// Variable value (iOS 16+)
Image(systemName: "speaker.wave.3.fill", variableValue: 0.7)

// Toolbar items
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button("Add", systemImage: "plus") {
            showAddSheet = true
        }
    }
}
```

**Finding SF Symbols:**
- Download SF Symbols app from Apple
- Search by name or category
- Check availability by iOS version
- Use symbol variants: `.fill`, `.circle`, `.square`

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)

### 2.7 Use System Colors for Dark Mode Support

**Impact: HIGH (automatic dark mode, semantic meaning, accessibility compliant)**

Use semantic system colors like `.primary`, `.secondary`, and asset catalog colors. These automatically adapt to light and dark mode. Avoid hard-coded RGB values.

**Incorrect (hard-coded colors):**

```swift
// Hard-coded colors don't adapt to dark mode
Text("Title")
    .foregroundColor(Color(red: 0, green: 0, blue: 0))  // Black - invisible in dark mode

VStack {
    // ...
}
.background(Color.white)  // Harsh in dark mode
```

**Correct (semantic system colors):**

```swift
// Semantic colors adapt automatically
Text("Title")
    .foregroundStyle(.primary)  // Black in light, white in dark

Text("Subtitle")
    .foregroundStyle(.secondary)  // Gray that adapts

// System background colors
VStack {
    // ...
}
.background(Color(.systemBackground))

// Named colors from asset catalog
Text("Accent")
    .foregroundStyle(Color("BrandColor"))  // Define in Assets.xcassets

// Standard colors that adapt
Button("Delete", role: .destructive) { }  // Uses system red

Image(systemName: "star.fill")
    .foregroundStyle(.yellow)  // Standard yellow adapts

// Tint color (follows app accent)
Image(systemName: "globe")
    .foregroundStyle(.tint)
```

**System colors:**
- `.primary` / `.secondary` - Text colors
- `Color(.systemBackground)` - View backgrounds
- `Color(.secondarySystemBackground)` - Grouped content
- `.tint` - App accent color
- `.red`, `.blue`, `.green` - Standard colors (adapt slightly)

Reference: [Develop in Swift Tutorials - Design an interface](https://developer.apple.com/tutorials/develop-in-swift/design-an-interface)

### 2.8 Use VStack, HStack, ZStack for Layout

**Impact: CRITICAL (fundamental layout containers, determines view arrangement, performance-optimized)**

Stack views are the primary layout containers in SwiftUI. VStack arranges views vertically, HStack horizontally, and ZStack in layers (front to back). Combine them to create any layout.

**Incorrect (manual positioning):**

```swift
// Don't try to manually position views
Text("First")
    .position(x: 100, y: 50)
Text("Second")
    .position(x: 100, y: 100)

// Don't use offset for basic layout
Text("Hello").offset(y: -20)
Text("World").offset(y: 20)
```

**Correct (stack-based layout):**

```swift
// VStack - vertical arrangement
VStack {
    Text("Knock, knock!")
    Text("Who's there?")
}

// HStack - horizontal arrangement
HStack {
    Image(systemName: "star")
    Text("Favorites")
}

// ZStack - layered arrangement
ZStack {
    RoundedRectangle(cornerRadius: 10)
        .fill(Color.blue)
    Text("Overlay")
        .foregroundColor(.white)
}

// Nested stacks for complex layouts
VStack(alignment: .leading, spacing: 8) {
    HStack {
        Image(systemName: "person.fill")
        Text("Sophie Sun")
    }
    HStack {
        Image(systemName: "envelope")
        Text("sophie@example.com")
    }
}
```

**Stack parameters:**
- `alignment`: How children align (`.leading`, `.center`, `.trailing`)
- `spacing`: Space between children (use `nil` for default)
- Children are arranged in declaration order

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)

---

## 3. State & Data Flow

**Impact: CRITICAL**

Use @State, @Binding, @Observable, and @Environment correctly. Proper state management prevents UI bugs, unnecessary re-renders, and makes your app predictable.

### 3.1 Use @Binding for Two-Way Data Flow

**Impact: CRITICAL (child views can modify parent state, enables reusable input components)**

`@Binding` creates a two-way connection to state owned by another view. The child view can read and write the value, and changes propagate back to the parent. Use `$` prefix to pass a binding from `@State`.

**Incorrect (one-way data only):**

```swift
// Child can't modify parent's state
struct ToggleRow: View {
    var isOn: Bool  // Read-only copy

    var body: some View {
        Toggle("Setting", isOn: isOn)  // Error: needs Binding<Bool>
    }
}
```

**Correct (@Binding for two-way connection):**

```swift
struct ToggleRow: View {
    @Binding var isOn: Bool  // Two-way connection

    var body: some View {
        Toggle("Setting", isOn: $isOn)  // Pass binding to Toggle
    }
}

// Parent view
struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var soundEnabled = false

    var body: some View {
        VStack {
            // Pass binding with $ prefix
            ToggleRow(isOn: $notificationsEnabled)
            ToggleRow(isOn: $soundEnabled)
        }
    }
}

// TextField requires binding for text
struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        TextField("Search...", text: $searchText)  // $ creates binding
    }
}
```

**Binding patterns:**
- Create from @State with `$` prefix: `$myState`
- Accept in child view with `@Binding var`
- Built-in controls (Toggle, TextField, Slider) require bindings
- Don't use @Binding when child only reads data

Reference: [Develop in Swift Tutorials - Create dynamic content](https://developer.apple.com/tutorials/develop-in-swift/create-dynamic-content)

### 3.2 Use @Environment for System and Shared Values

**Impact: HIGH (access system settings, inject dependencies, share data without prop drilling)**

`@Environment` reads values from the SwiftUI environment - both system values (color scheme, dismiss action) and custom values you inject. Use it to access shared dependencies without passing through every view.

**Incorrect (passing through many layers):**

```swift
// Prop drilling - passing dismiss through every view
struct ParentView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ChildView(dismiss: dismiss)
    }
}

struct ChildView: View {
    var dismiss: DismissAction

    var body: some View {
        GrandchildView(dismiss: dismiss)  // Tedious passing
    }
}
```

**Correct (@Environment access where needed):**

```swift
// Access dismiss directly in the view that needs it
struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Text("Detail Content")
                .foregroundColor(colorScheme == .dark ? .white : .black)

            Button("Done") {
                dismiss()  // Dismiss the sheet/navigation
            }
        }
    }
}

// Access modelContext for SwiftData operations
struct FriendListView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Button("Add Friend") {
            let friend = Friend(name: "New Friend")
            modelContext.insert(friend)
        }
    }
}
```

**Common environment values:**
- `\.dismiss` - Dismiss sheets and navigation
- `\.colorScheme` - Light or dark mode
- `\.modelContext` - SwiftData context
- `\.openURL` - Open URLs
- `\.horizontalSizeClass` - Compact or regular width

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)

### 3.3 Use @Observable for Shared Model Classes

**Impact: CRITICAL (granular property tracking, shared state across views, modern replacement for ObservableObject)**

The `@Observable` macro (iOS 17+) makes classes observable with automatic property tracking. SwiftUI only re-renders views that read changed properties. Use `@Observable` for model classes shared across multiple views.

**Incorrect (older ObservableObject pattern):**

```swift
// Pre-iOS 17 pattern - more boilerplate, less granular updates
class GameModel: ObservableObject {
    @Published var currentWord = ""
    @Published var score = 0
    @Published var guessedLetters: Set<Character> = []
}

struct GameView: View {
    @StateObject var game = GameModel()  // Old pattern
    // ...
}
```

**Correct (@Observable for modern apps):**

```swift
@Observable
class GameModel {
    var currentWord = ""
    var score = 0
    var guessedLetters: Set<Character> = []

    func guess(_ letter: Character) {
        guessedLetters.insert(letter)
        if currentWord.contains(letter) {
            score += 10
        }
    }
}

struct GameView: View {
    @State var game = GameModel()  // Use @State with @Observable

    var body: some View {
        VStack {
            Text("Score: \(game.score)")  // Only updates when score changes
            Text(game.currentWord)  // Only updates when word changes

            Button("Guess A") {
                game.guess("A")
            }
        }
    }
}

// Share model across views
struct ScoreboardView: View {
    var game: GameModel  // No wrapper needed for read-only

    var body: some View {
        Text("Score: \(game.score)")
    }
}
```

**@Observable migration:**
- `ObservableObject` → `@Observable`
- Remove `@Published` wrappers
- `@StateObject` → `@State`
- `@ObservedObject` → pass object directly

Reference: [Develop in Swift Tutorials - Complete a game with logic](https://developer.apple.com/tutorials/develop-in-swift/complete-a-game-with-logic)

### 3.4 Use @State for View-Local Value Types

**Impact: CRITICAL (enables reactive UI, SwiftUI manages storage, triggers view updates automatically)**

`@State` creates mutable state that belongs to a single view. When state changes, SwiftUI automatically re-renders the view. Use `@State` for simple value types (Int, String, Bool) that only this view needs.

**Incorrect (trying to modify view properties):**

```swift
struct CounterView: View {
    var count = 0  // Not @State - can't be modified

    var body: some View {
        Button("Count: \(count)") {
            count += 1  // Error: Cannot assign to property
        }
    }
}
```

**Correct (@State for mutable view-local data):**

```swift
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        Button("Count: \(count)") {
            count += 1  // Works! UI updates automatically
        }
    }
}

// Multiple state properties
struct DiceRollerView: View {
    @State private var diceValue = 1
    @State private var isRolling = false

    var body: some View {
        VStack {
            Text("🎲 \(diceValue)")
                .font(.largeTitle)

            Button("Roll") {
                isRolling = true
                diceValue = Int.random(in: 1...6)
                isRolling = false
            }
            .disabled(isRolling)
        }
    }
}
```

**@State rules:**
- Always mark as `private` - state belongs to the view
- Use for value types (Int, String, Bool, structs)
- SwiftUI manages storage outside the view struct
- Changes trigger body re-evaluation

Reference: [Develop in Swift Tutorials - Update the UI with state](https://developer.apple.com/tutorials/develop-in-swift/update-the-ui-with-state)

---

## 4. SwiftData & Persistence

**Impact: HIGH**

Model your app's data with SwiftData using @Model, @Query, and model relationships. Proper data modeling ensures data integrity and enables efficient queries.

### 4.1 Configure modelContainer in App Entry Point

**Impact: HIGH (enables SwiftData persistence, provides context to all views, required setup)**

Add the `.modelContainer(for:)` modifier to your app's main scene to enable SwiftData. This creates the database and makes the model context available throughout your view hierarchy.

**Incorrect (no container setup):**

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // @Query will fail without modelContainer!
        }
    }
}
```

**Correct (modelContainer configured):**

```swift
import SwiftUI
import SwiftData

@main
struct FriendsFavoritesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Friend.self, Movie.self])
    }
}

// For previews, create a sample data container
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(SampleData.shared.modelContainer)
    }
}

// Sample data helper for previews
@MainActor
class SampleData {
    static let shared = SampleData()

    let modelContainer: ModelContainer

    init() {
        let schema = Schema([Friend.self, Movie.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: config)

        // Insert sample data
        let context = modelContainer.mainContext
        context.insert(Friend(name: "Sophie"))
        context.insert(Friend(name: "Alex"))
    }
}
```

**Container options:**
- `isStoredInMemoryOnly: true` - For previews and testing
- Multiple model types in single container
- CloudKit sync configuration
- Custom storage location

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)

### 4.2 Define Model Relationships with Properties

**Impact: HIGH (automatic relationship tracking, cascading updates, referential integrity)**

SwiftData creates relationships automatically when model properties reference other model types. Use array properties for one-to-many relationships and single properties for one-to-one.

**Incorrect (manual ID references):**

```swift
// Don't use IDs to reference other models
@Model
class Friend {
    var name: String
    var favoriteMovieIds: [UUID] = []  // Manual tracking is error-prone
}

@Model
class Movie {
    var id: UUID = UUID()
    var title: String
}
```

**Correct (direct model references):**

```swift
import SwiftData

@Model
class Friend {
    var name: String

    // One-to-many: Friend has many favorite movies
    var favoriteMovies: [Movie] = []

    init(name: String) {
        self.name = name
    }
}

@Model
class Movie {
    var title: String

    // Inverse relationship (optional but recommended)
    var fans: [Friend] = []

    init(title: String) {
        self.title = title
    }
}

// Usage
let friend = Friend(name: "Sophie")
let movie = Movie(title: "Dune")

// Add to relationship
friend.favoriteMovies.append(movie)
// SwiftData automatically updates movie.fans

// Query with relationships
@Query private var friends: [Friend]

ForEach(friend.favoriteMovies) { movie in
    Text(movie.title)
}
```

**Relationship patterns:**
- Array property → one-to-many relationship
- Single optional property → one-to-one relationship
- Define inverse for bidirectional relationships
- SwiftData handles cascading deletes

Reference: [Develop in Swift Tutorials - Work with relationships](https://developer.apple.com/tutorials/develop-in-swift/work-with-relationships)

### 4.3 Perform CRUD with modelContext

**Impact: HIGH (insert, update, delete models; automatic saves; transaction support)**

Use the model context from `@Environment(\.modelContext)` to insert and delete SwiftData models. Updates happen automatically when you modify model properties. SwiftData saves changes automatically.

**Incorrect (manual save calls or wrong patterns):**

```swift
// Don't create models without inserting
let friend = Friend(name: "Sophie")
// friend exists but isn't persisted!

// Don't try to manually save
modelContext.save()  // Usually unnecessary
```

**Correct (proper CRUD operations):**

```swift
import SwiftData
import SwiftUI

struct FriendListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        List {
            ForEach(friends) { friend in
                Text(friend.name)
            }
            .onDelete(perform: deleteFriends)
        }
        .toolbar {
            Button("Add", systemImage: "plus") {
                addFriend()
            }
        }
    }

    // CREATE
    private func addFriend() {
        let friend = Friend(name: "New Friend")
        modelContext.insert(friend)
        // SwiftData auto-saves
    }

    // DELETE
    private func deleteFriends(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(friends[index])
        }
    }
}

// UPDATE - just modify properties
struct FriendDetailView: View {
    @Bindable var friend: Friend  // @Bindable for binding to model properties

    var body: some View {
        Form {
            TextField("Name", text: $friend.name)
            // Changes auto-save when you type
        }
    }
}
```

**CRUD operations:**
- **Create**: `modelContext.insert(model)`
- **Read**: `@Query` fetches automatically
- **Update**: Modify model properties directly
- **Delete**: `modelContext.delete(model)`

Reference: [Develop in Swift Tutorials - Create, update, and delete data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)

### 4.4 Use @Model for SwiftData Persistence

**Impact: CRITICAL (automatic persistence, relationship tracking, integrates with SwiftUI)**

The `@Model` macro marks a class for SwiftData persistence. SwiftData automatically saves changes, tracks relationships, and integrates with SwiftUI. Use classes (not structs) for SwiftData models.

**Incorrect (struct or missing @Model):**

```swift
// Structs can't be SwiftData models
struct Friend {
    var name: String
    var birthday: Date
}

// Class without @Model won't persist
class Friend {
    var name: String
    var birthday: Date
}
```

**Correct (@Model class):**

```swift
import SwiftData

@Model
class Friend {
    var name: String
    var birthday: Date

    init(name: String, birthday: Date = .now) {
        self.name = name
        self.birthday = birthday
    }
}

@Model
class Movie {
    var title: String
    var releaseDate: Date
    var isFavorite: Bool

    init(title: String, releaseDate: Date = .now, isFavorite: Bool = false) {
        self.title = title
        self.releaseDate = releaseDate
        self.isFavorite = isFavorite
    }
}
```

**@Model requirements:**
- Must be a class (reference type)
- Properties are automatically persisted
- Provide initializer with required properties
- Import SwiftData framework

**SwiftData features:**
- Automatic saving on changes
- Undo/redo support
- CloudKit sync (with configuration)
- Type-safe queries

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)

### 4.5 Use @Query to Fetch SwiftData Models

**Impact: CRITICAL (reactive data fetching, automatic UI updates, type-safe predicates)**

`@Query` fetches SwiftData models and automatically updates your view when data changes. It's the primary way to display persisted data in SwiftUI. Add sorting and filtering with predicates.

**Incorrect (manual fetching):**

```swift
// Don't manually fetch in onAppear
struct FriendListView: View {
    @State private var friends: [Friend] = []

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        .onAppear {
            // Manual fetching won't update when data changes
            friends = fetchFriends()
        }
    }
}
```

**Correct (@Query for reactive fetching):**

```swift
import SwiftData
import SwiftUI

struct FriendListView: View {
    @Query private var friends: [Friend]  // Automatically fetches all Friends

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
    }
}

// With sorting
struct FriendListView: View {
    @Query(sort: \Friend.name) private var friends: [Friend]

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
    }
}

// With filtering and sorting
struct FavoritesView: View {
    @Query(
        filter: #Predicate<Movie> { $0.isFavorite },
        sort: \Movie.title
    ) private var favorites: [Movie]

    var body: some View {
        List(favorites) { movie in
            Text(movie.title)
        }
    }
}
```

**@Query features:**
- Automatically re-fetches when data changes
- Sort with key paths: `sort: \Model.property`
- Filter with `#Predicate` macro
- Combine multiple sort descriptors
- Results are always up-to-date

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)

---

## 5. Navigation & Presentation

**Impact: HIGH**

Implement NavigationStack, TabView, sheets, and detail views correctly. Navigation patterns define user flow and must maintain state across transitions.

### 5.1 Use NavigationStack for Hierarchical Navigation

**Impact: HIGH (modern push/pop navigation, type-safe destinations, programmatic control)**

`NavigationStack` (iOS 16+) provides hierarchical navigation with push/pop behavior. Use `NavigationLink` with `value:` for type-safe navigation and `navigationDestination` to define where each type navigates to.

**Incorrect (deprecated NavigationView):**

```swift
// Old pattern - deprecated
NavigationView {
    List(friends) { friend in
        NavigationLink(destination: FriendDetail(friend: friend)) {
            Text(friend.name)
        }
    }
}
```

**Correct (NavigationStack with typed destinations):**

```swift
struct FriendListView: View {
    @Query private var friends: [Friend]

    var body: some View {
        NavigationStack {
            List(friends) { friend in
                NavigationLink(value: friend) {
                    Text(friend.name)
                }
            }
            .navigationTitle("Friends")
            .navigationDestination(for: Friend.self) { friend in
                FriendDetailView(friend: friend)
            }
        }
    }
}

// Multiple destination types
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Friends", value: Route.friends)
                NavigationLink("Movies", value: Route.movies)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .friends: FriendListView()
                case .movies: MovieListView()
                }
            }
        }
    }
}

enum Route: Hashable {
    case friends
    case movies
}
```

**NavigationStack features:**
- Type-safe navigation with `value:` parameter
- `navigationDestination(for:)` defines destinations
- Programmatic navigation with `@State var path`
- Supports deep linking

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)

### 5.2 Use Sheets for Modal Presentation

**Impact: HIGH (temporary focused tasks, maintains context, proper dismiss handling)**

Sheets present content modally over the current view. Use `.sheet()` modifier with a binding to control presentation. Sheets are ideal for focused tasks like adding new items or editing details.

**Incorrect (manual overlay implementation):**

```swift
// Don't build custom modal overlays
struct ContentView: View {
    @State private var showingAdd = false

    var body: some View {
        ZStack {
            MainContent()
            if showingAdd {
                Color.black.opacity(0.3)
                AddItemView()
            }
        }
    }
}
```

**Correct (sheet with boolean binding):**

```swift
struct FriendListView: View {
    @State private var showingAddFriend = false

    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
        .toolbar {
            Button("Add", systemImage: "plus") {
                showingAddFriend = true
            }
        }
        .sheet(isPresented: $showingAddFriend) {
            AddFriendView()
        }
    }
}

// Sheet with item binding (auto-unwraps optional)
struct FriendListView: View {
    @State private var selectedFriend: Friend?

    var body: some View {
        List(friends) { friend in
            Button(friend.name) {
                selectedFriend = friend
            }
        }
        .sheet(item: $selectedFriend) { friend in
            FriendDetailView(friend: friend)
        }
    }
}

// Dismissing from within sheet
struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Form content
            }
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
```

**Sheet patterns:**
- `isPresented:` for boolean toggle
- `item:` for optional binding (nil = hidden)
- Access `\.dismiss` environment action
- Wrap sheet content in NavigationStack for toolbar

Reference: [Develop in Swift Tutorials - Create, update, and delete data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)

### 5.3 Use TabView for Top-Level Sections

**Impact: HIGH (standard iOS navigation pattern, persistent tabs, independent navigation stacks)**

`TabView` organizes your app into distinct sections with tabs at the bottom. Each tab maintains its own navigation state. Use tab items with SF Symbols for consistent iOS appearance.

**Incorrect (manual tab implementation):**

```swift
// Don't build custom tab bars
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            if selectedTab == 0 {
                FriendsView()
            } else {
                MoviesView()
            }
            HStack {
                Button("Friends") { selectedTab = 0 }
                Button("Movies") { selectedTab = 1 }
            }
        }
    }
}
```

**Correct (TabView with proper tab items):**

```swift
struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                FriendListView()
            }
            .tabItem {
                Label("Friends", systemImage: "person.2")
            }

            NavigationStack {
                MovieListView()
            }
            .tabItem {
                Label("Movies", systemImage: "film")
            }
        }
    }
}

// With programmatic selection
struct ContentView: View {
    @State private var selectedTab = Tab.friends

    var body: some View {
        TabView(selection: $selectedTab) {
            FriendListView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
                .tag(Tab.friends)

            MovieListView()
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
                .tag(Tab.movies)
        }
    }

    enum Tab {
        case friends, movies
    }
}
```

**TabView best practices:**
- Wrap each tab's content in NavigationStack
- Use SF Symbols for tab icons
- Keep to 5 or fewer tabs (iOS guideline)
- Use `tag` and `selection` for programmatic control

Reference: [Develop in Swift Tutorials - Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)

---

## 6. Lists & Dynamic Content

**Impact: HIGH**

Display collections with List, ForEach, and lazy containers. Handle dynamic data with proper identifiers and efficient rendering.

### 6.1 Add Swipe Actions to List Rows

**Impact: MEDIUM-HIGH (familiar iOS interaction pattern, quick actions, proper delete confirmation)**

Use `.swipeActions()` modifier to add swipe-to-reveal actions on list rows. Use `.onDelete()` for standard delete swipe with Edit mode support.

**Incorrect (custom swipe gesture implementation):**

```swift
// Don't implement custom swipe gestures for standard actions
List(friends) { friend in
    Text(friend.name)
        .gesture(DragGesture()...)  // Complex and non-standard
}
```

**Correct (built-in swipe actions):**

```swift
// Simple delete with onDelete
struct FriendListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var friends: [Friend]

    var body: some View {
        List {
            ForEach(friends) { friend in
                Text(friend.name)
            }
            .onDelete(perform: deleteFriends)
        }
    }

    private func deleteFriends(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(friends[index])
        }
    }
}

// Custom swipe actions
List(friends) { friend in
    Text(friend.name)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(friend)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                friend.isFavorite.toggle()
            } label: {
                Label("Favorite", systemImage: "star")
            }
            .tint(.yellow)
        }
}
```

**Swipe action patterns:**
- `.onDelete()` enables Edit mode and swipe-to-delete
- `.swipeActions(edge:)` for custom actions
- Use `role: .destructive` for delete actions
- Leading edge for positive actions, trailing for destructive

Reference: [Develop in Swift Tutorials - Create, update, and delete data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)

### 6.2 Use List and ForEach with Identifiable Data

**Impact: HIGH (efficient diffing, proper cell reuse, required for dynamic content)**

`List` and `ForEach` require each item to be uniquely identifiable. Conform your model to `Identifiable` protocol or provide an `id` key path. This enables SwiftUI to efficiently update only changed items.

**Incorrect (no identification):**

```swift
// ForEach can't track items without IDs
struct Friend {
    var name: String
}

ForEach(friends) { friend in  // Error: Friend doesn't conform to Identifiable
    Text(friend.name)
}
```

**Correct (Identifiable conformance):**

```swift
// Option 1: Conform to Identifiable
struct Friend: Identifiable {
    let id = UUID()  // Unique identifier
    var name: String
}

List(friends) { friend in
    Text(friend.name)
}

// Option 2: Provide id key path
struct Friend {
    var name: String  // Assuming names are unique
}

List(friends, id: \.name) { friend in
    Text(friend.name)
}

// SwiftData models are automatically Identifiable
@Model
class Friend {  // Already Identifiable via SwiftData
    var name: String
}

// ForEach in custom layouts
VStack {
    ForEach(friends) { friend in
        FriendRow(friend: friend)
    }
}

// With onDelete and onMove
List {
    ForEach(friends) { friend in
        Text(friend.name)
    }
    .onDelete(perform: deleteFriends)
    .onMove(perform: moveFriends)
}
```

**Identifiable rules:**
- Use stable IDs (don't use array index as ID)
- `UUID()` is good for new items
- SwiftData models are automatically Identifiable
- ID must be `Hashable`

Reference: [Develop in Swift Tutorials - Create dynamic content](https://developer.apple.com/tutorials/develop-in-swift/create-dynamic-content)

---

## 7. User Input & Forms

**Impact: MEDIUM-HIGH**

Capture user input with TextField, TextEditor, Picker, Toggle, and forms. Proper input handling includes validation, keyboard management, and accessibility.

### 7.1 Use Button with Action Closures

**Impact: HIGH (primary interaction element, closure-based actions, proper styling)**

`Button` triggers actions when tapped. The action is a closure that runs on tap. Use trailing closure syntax for clean code. Apply button styles for different visual treatments.

**Incorrect (wrong closure syntax):**

```swift
// Don't call function immediately
Button("Save", action: saveData())  // Wrong: calls saveData immediately

// Don't use NavigationLink for actions
NavigationLink("Delete") {
    // Wrong: NavigationLink is for navigation, not actions
}
```

**Correct (Button with closure):**

```swift
// Basic button with trailing closure
Button("Add Friend") {
    addNewFriend()
}

// Button with label
Button {
    count += 1
} label: {
    Text("Increment")
}

// Button with image and text
Button {
    saveChanges()
} label: {
    Label("Save", systemImage: "square.and.arrow.down")
}

// Button styles
Button("Primary Action") {
    performAction()
}
.buttonStyle(.borderedProminent)

Button("Secondary") {
    cancel()
}
.buttonStyle(.bordered)

// Destructive button
Button("Delete", role: .destructive) {
    deleteItem()
}

// Disabled button
Button("Submit") {
    submit()
}
.disabled(formIsInvalid)
```

**Button styles:**
- `.automatic` - Platform default
- `.bordered` - Light background
- `.borderedProminent` - Tinted background
- `.plain` - No visual treatment
- Use `role: .destructive` for delete actions

Reference: [Develop in Swift Tutorials - Update the UI with state](https://developer.apple.com/tutorials/develop-in-swift/update-the-ui-with-state)

### 7.2 Use Picker and Toggle for Selection Input

**Impact: MEDIUM-HIGH (standard iOS controls, automatic styling, proper accessibility)**

Use `Picker` for choosing from multiple options and `Toggle` for on/off states. Both require bindings and automatically adapt to the context (forms, navigation, etc.).

**Incorrect (custom selection UI):**

```swift
// Don't build custom radio buttons
HStack {
    ForEach(options, id: \.self) { option in
        Button {
            selected = option
        } label: {
            Circle()
                .stroke(selected == option ? Color.blue : Color.gray)
        }
    }
}
```

**Correct (Picker and Toggle):**

```swift
// Picker for multiple choice
struct SettingsView: View {
    @State private var selectedColor = "Blue"
    @State private var notificationsEnabled = true

    var body: some View {
        Form {
            // Picker in Form shows as navigation
            Picker("Theme Color", selection: $selectedColor) {
                Text("Blue").tag("Blue")
                Text("Green").tag("Green")
                Text("Purple").tag("Purple")
            }

            // Toggle for boolean
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
        }
    }
}

// Picker styles
Picker("Size", selection: $size) {
    ForEach(sizes, id: \.self) { size in
        Text(size).tag(size)
    }
}
.pickerStyle(.segmented)  // Inline segmented control

Picker("Priority", selection: $priority) {
    // ...
}
.pickerStyle(.menu)  // Dropdown menu

// Toggle with custom label
Toggle(isOn: $isDarkMode) {
    Label("Dark Mode", systemImage: "moon.fill")
}
```

**Picker styles:**
- `.automatic` - Context-dependent (navigation in Form)
- `.segmented` - Inline segmented control
- `.menu` - Dropdown menu
- `.wheel` - iOS wheel picker

Reference: [Develop in Swift Tutorials - Create dynamic content](https://developer.apple.com/tutorials/develop-in-swift/create-dynamic-content)

### 7.3 Use TextField with Binding for Text Input

**Impact: HIGH (captures user text, two-way binding updates state, keyboard management)**

`TextField` captures single-line text input. It requires a binding (`$`) to a String state property. The view updates as the user types.

**Incorrect (no binding):**

```swift
// TextField needs a binding, not a plain value
struct SearchView: View {
    var searchText = ""  // Not @State

    var body: some View {
        TextField("Search", text: searchText)  // Error: needs Binding<String>
    }
}
```

**Correct (TextField with binding):**

```swift
struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        TextField("Search...", text: $searchText)
    }
}

// With prompt (iOS 15+)
TextField("Name", text: $name, prompt: Text("Enter your name"))

// Styled TextField
TextField("Email", text: $email)
    .textFieldStyle(.roundedBorder)
    .keyboardType(.emailAddress)
    .textContentType(.emailAddress)
    .autocapitalization(.none)

// In a Form
Form {
    TextField("Name", text: $name)
    TextField("Email", text: $email)
        .keyboardType(.emailAddress)
}

// Secure text entry
SecureField("Password", text: $password)

// Multi-line text
TextEditor(text: $notes)
    .frame(height: 100)
```

**TextField options:**
- `.keyboardType()` - email, number, URL, etc.
- `.textContentType()` - enables autofill
- `.autocapitalization()` - control capitalization
- `SecureField` for passwords
- `TextEditor` for multi-line

Reference: [Develop in Swift Tutorials - Create dynamic content](https://developer.apple.com/tutorials/develop-in-swift/create-dynamic-content)

---

## 8. Testing & Quality

**Impact: MEDIUM-HIGH**

Write unit tests with Swift Testing framework. Test your models and logic to ensure correctness before shipping.

### 8.1 Write Unit Tests with Swift Testing

**Impact: MEDIUM-HIGH (verify model logic, catch regressions, document expected behavior)**

Swift Testing (new framework) uses `@Test` attribute and `#expect` macro for assertions. Write tests to verify your model logic works correctly before building UI.

**Incorrect (no tests or old XCTest):**

```swift
// Code without tests - bugs discovered in production
class Scoreboard {
    func calculateScore() -> Int { ... }
}

// Old XCTest style (still works but verbose)
class ScoreboardTests: XCTestCase {
    func testCalculateScore() {
        XCTAssertEqual(scoreboard.calculateScore(), 100)
    }
}
```

**Correct (Swift Testing):**

```swift
import Testing

// Test struct with @Test methods
struct ScoreboardTests {

    @Test func initialScoreIsZero() {
        let scoreboard = Scoreboard()
        #expect(scoreboard.score == 0)
    }

    @Test func scoreIncreasesOnCorrectAnswer() {
        var scoreboard = Scoreboard()
        scoreboard.recordCorrectAnswer()
        #expect(scoreboard.score == 10)
    }

    @Test func scoreDecreasesOnWrongAnswer() {
        var scoreboard = Scoreboard()
        scoreboard.score = 20
        scoreboard.recordWrongAnswer()
        #expect(scoreboard.score == 15)
    }

    @Test func scoreNeverGoesNegative() {
        var scoreboard = Scoreboard()
        scoreboard.recordWrongAnswer()
        #expect(scoreboard.score >= 0)
    }
}

// Parameterized tests
@Test(arguments: [1, 2, 3, 5, 8])
func fibonacciNumbers(input: Int) {
    #expect(fibonacci(input) > 0)
}
```

**Swift Testing features:**
- `@Test` attribute marks test functions
- `#expect(condition)` for assertions
- Parameterized tests with `arguments:`
- Better error messages than XCTest
- Works alongside XCTest

Reference: [Develop in Swift Tutorials - Add functionality with Swift Testing](https://developer.apple.com/tutorials/develop-in-swift/add-functionality-with-swift-testing)

---

## 9. Accessibility & Localization

**Impact: MEDIUM-HIGH**

Make apps accessible with VoiceOver labels, Dynamic Type, and proper localization. Accessibility is required for quality apps.

### 9.1 Add Accessibility Labels to Interactive Elements

**Impact: MEDIUM-HIGH (enables VoiceOver, required for inclusive apps, improves usability)**

Add `.accessibilityLabel()` to elements that don't have visible text. VoiceOver users need descriptive labels to understand interactive elements. All buttons, images, and custom controls need labels.

**Incorrect (missing accessibility):**

```swift
// Icon-only button without label
Button {
    addItem()
} label: {
    Image(systemName: "plus")
}
// VoiceOver says "button" - not helpful

// Decorative image announced as content
Image("logo")
// VoiceOver describes the image unnecessarily
```

**Correct (proper accessibility):**

```swift
// Button with accessibility label
Button {
    addFriend()
} label: {
    Image(systemName: "plus")
}
.accessibilityLabel("Add friend")

// Hide decorative images from VoiceOver
Image("decorative-divider")
    .accessibilityHidden(true)

// Informative image with description
Image("weather-sunny")
    .accessibilityLabel("Sunny weather")

// Combined element with custom description
HStack {
    Image(systemName: "star.fill")
    Text("\(rating)")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(rating) stars")

// Accessibility hint for complex interactions
Button("Delete") {
    showDeleteConfirmation()
}
.accessibilityHint("Shows confirmation dialog")
```

**Accessibility modifiers:**
- `.accessibilityLabel()` - What the element is
- `.accessibilityHint()` - What happens on activation
- `.accessibilityHidden(true)` - Hide decorative elements
- `.accessibilityElement(children:)` - Combine or ignore children

Reference: [Develop in Swift Tutorials - Add inclusive features](https://developer.apple.com/tutorials/develop-in-swift/add-inclusive-features)

### 9.2 Support Dynamic Type for All Text

**Impact: MEDIUM-HIGH (respects user font size settings, required for accessibility, improves readability)**

Use semantic font styles (`.title`, `.body`, `.caption`) instead of fixed sizes. SwiftUI automatically scales text based on user's accessibility settings. Test with larger text sizes.

**Incorrect (fixed font sizes):**

```swift
// Hard-coded sizes don't scale
Text("Title")
    .font(.system(size: 24))  // Won't respect Dynamic Type

Text("Body text")
    .font(.system(size: 14))  // Fixed size
```

**Correct (semantic text styles):**

```swift
// Semantic styles scale automatically
Text("Welcome")
    .font(.largeTitle)

Text("Section Header")
    .font(.headline)

Text("This is the main content of the app.")
    .font(.body)

Text("Additional details")
    .font(.caption)

// Allow text to scale with custom fonts
Text("Custom")
    .font(.custom("Avenir", size: 18, relativeTo: .body))

// Limit scaling for specific layouts
Text("Tab Label")
    .font(.caption2)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)  // Cap scaling
```

**Semantic font styles (smallest to largest):**
- `.caption2`, `.caption` - Smallest
- `.footnote`, `.subheadline`
- `.body` - Default reading size
- `.headline`, `.title3`, `.title2`, `.title`
- `.largeTitle` - Largest

**Testing Dynamic Type:**
- Use Xcode previews with different size classes
- Environment override in preview: `.environment(\.sizeCategory, .accessibilityExtraExtraLarge)`

Reference: [Develop in Swift Tutorials - Add inclusive features](https://developer.apple.com/tutorials/develop-in-swift/add-inclusive-features)

---

## 10. Debugging & Refinement

**Impact: MEDIUM**

Use Xcode's debugging tools, breakpoints, and console to find and fix bugs. Systematic debugging saves time and improves code quality.

### 10.1 Use Breakpoints to Debug Code

**Impact: MEDIUM (pause execution at specific lines, inspect variables, step through logic)**

Set breakpoints in Xcode to pause execution and inspect your app's state. Click the line number gutter to add a breakpoint. When paused, examine variables and step through code.

**Incorrect (print debugging only):**

```swift
// Print statements are verbose and slow
func processData() {
    print("Starting processData")
    print("items count: \(items.count)")
    for item in items {
        print("Processing: \(item)")
        // ...
        print("Done processing: \(item)")
    }
    print("Finished processData")
}
```

**Correct (breakpoint debugging):**

```swift
func processData() {
    // Set breakpoint on this line (click line number gutter)
    for item in items {
        let result = transform(item)  // <- Breakpoint here
        // Inspect 'item' and 'result' in Variables view
        // Step over (F6) to see next iteration
    }
}

// Use print sparingly for production logging
func fetchData() async {
    #if DEBUG
    print("Fetching data from \(url)")
    #endif
    // ...
}
```

**Debugging workflow:**
1. **Set breakpoint**: Click line number gutter
2. **Run app**: Execution pauses at breakpoint
3. **Inspect variables**: View values in Debug area
4. **Step controls**:
   - Step Over (F6): Execute current line
   - Step Into (F7): Enter function
   - Step Out (F8): Exit function
   - Continue (⌃⌘Y): Resume execution

**Conditional breakpoints:**
- Right-click breakpoint → Edit Breakpoint
- Add condition: `items.count > 10`
- Add action: Log message without stopping

Reference: [Develop in Swift Tutorials - Investigate and fix a bug](https://developer.apple.com/tutorials/develop-in-swift/investigate-and-fix-a-bug)

### 10.2 Use Debug Console for Runtime Inspection

**Impact: MEDIUM (evaluate expressions during pause, call methods, test fixes live)**

When paused at a breakpoint, use the debug console to evaluate expressions, inspect objects, and test fixes. Type `po variableName` to print object descriptions.

**Incorrect (print statements instead of debugger):**

```swift
// Don't litter code with print statements
func processData(_ data: [Item]) {
    print("data count: \(data.count)")  // Clutters console
    print("first item: \(data.first)")   // Hard to find
    for item in data {
        print("processing: \(item)")     // Too much noise
    }
}
```

**Debug console commands:**

```lldb
// Print object description
(lldb) po friend
▿ Friend
  - name: "Sophie"
  - birthday: 2024-01-15

// Print primitive value
(lldb) p count
(Int) $R0 = 42

// Evaluate expressions
(lldb) po friends.count
3

(lldb) po friends.filter { $0.name.contains("S") }
▿ 1 element
  - 0 : Friend(name: "Sophie")

// Call methods
(lldb) po friend.name.uppercased()
"SOPHIE"

// Modify values (use with caution)
(lldb) expression friend.name = "Alex"
```

**Console in SwiftUI debugging:**

```swift
struct ContentView: View {
    @State private var items: [Item] = []

    var body: some View {
        List(items) { item in
            Text(item.name)
        }
        .onAppear {
            // Set breakpoint here
            loadItems()
            // In console: po items
        }
    }
}
```

**Useful lldb commands:**
- `po expression` - Print object (calls debugDescription)
- `p expression` - Print value with type
- `expression` - Evaluate/modify values
- `bt` - Show call stack (backtrace)
- `frame variable` - Show all local variables

Reference: [Develop in Swift Tutorials - Investigate and fix a bug](https://developer.apple.com/tutorials/develop-in-swift/investigate-and-fix-a-bug)

---

## 11. Machine Learning Integration

**Impact: MEDIUM**

Add intelligent features with Natural Language, Vision, Create ML, and Core ML frameworks. On-device ML enables privacy-preserving features.

### 11.1 Use Natural Language Framework for Text Analysis

**Impact: MEDIUM (on-device ML, sentiment analysis, language detection, no network required)**

The Natural Language framework provides on-device text analysis including sentiment analysis, language detection, and tokenization. Results are private - text never leaves the device.

**Incorrect (manual string analysis):**

```swift
// Don't manually analyze text
func isPositive(_ text: String) -> Bool {
    let positiveWords = ["good", "great", "love", "happy"]
    for word in positiveWords {
        if text.lowercased().contains(word) {
            return true  // Misses context, sarcasm, negation
        }
    }
    return false
}
```

**Basic sentiment analysis:**

```swift
import NaturalLanguage

struct SentimentAnalyzer {
    func analyzeSentiment(of text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text

        let (sentiment, _) = tagger.tag(
            at: text.startIndex,
            unit: .paragraph,
            scheme: .sentimentScore
        )

        // Returns value from -1.0 (negative) to 1.0 (positive)
        return Double(sentiment?.rawValue ?? "0") ?? 0
    }
}

// Usage
let analyzer = SentimentAnalyzer()
let score = analyzer.analyzeSentiment(of: "I love this app!")
// score ≈ 0.8 (positive)

let negativeScore = analyzer.analyzeSentiment(of: "This is terrible")
// negativeScore ≈ -0.6 (negative)
```

**SwiftUI integration:**

```swift
struct SentimentView: View {
    @State private var text = ""
    @State private var sentiment: Double = 0

    var body: some View {
        VStack {
            TextField("Enter text", text: $text)
                .onChange(of: text) { _, newValue in
                    sentiment = SentimentAnalyzer().analyzeSentiment(of: newValue)
                }

            Text(sentimentEmoji)
                .font(.largeTitle)
        }
    }

    var sentimentEmoji: String {
        switch sentiment {
        case 0.3...: return "😊"
        case -0.3..<0.3: return "😐"
        default: return "😔"
        }
    }
}
```

**Natural Language capabilities:**
- Sentiment analysis
- Language identification
- Tokenization (words, sentences)
- Part-of-speech tagging
- Named entity recognition

Reference: [Develop in Swift Tutorials - Analyze sentiment in text](https://developer.apple.com/tutorials/develop-in-swift/analyze-sentiment-in-text)

---

## 12. visionOS & Spatial Computing

**Impact: MEDIUM**

Build for Apple Vision Pro with windows, ornaments, and volumes. Spatial computing requires understanding 3D space and immersive contexts.

### 12.1 Build visionOS Apps with Windows

**Impact: MEDIUM (spatial computing entry point, familiar SwiftUI patterns, depth and scale)**

visionOS windows use familiar SwiftUI patterns but exist in 3D space. Add depth with `.offset(z:)` and use glass material backgrounds. Windows are the foundation before volumes and immersive spaces.

**Incorrect (ignoring spatial design):**

```swift
// Don't use flat, opaque backgrounds in visionOS
struct BadVisionView: View {
    var body: some View {
        VStack {
            Text("Hello")
        }
        .background(Color.white)  // Opaque backgrounds look wrong
        .frame(width: 200, height: 100)  // Fixed sizes don't adapt
    }
}
```

**Basic visionOS window:**

```swift
import SwiftUI

@main
struct MyVisionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, visionOS!")
                .font(.extraLargeTitle)

            Image(systemName: "vision.pro")
                .font(.system(size: 100))
        }
        .padding(50)
    }
}
```

**Adding depth to elements:**

```swift
struct DepthView: View {
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 20) {
            // Elements at different depths
            Text("Background")
                .padding()
                .background(.regularMaterial)

            Text("Foreground")
                .padding()
                .background(.regularMaterial)
                .offset(z: 50)  // Comes toward viewer

            // Interactive depth
            Button("Press Me") {
                isPressed.toggle()
            }
            .offset(z: isPressed ? 100 : 0)
            .animation(.spring, value: isPressed)
        }
    }
}
```

**visionOS considerations:**
- Use glass materials (`.regularMaterial`, `.thickMaterial`)
- Add depth with `.offset(z:)` in points
- Larger touch targets (44pt minimum, 60pt+ recommended)
- Test in Simulator and on device

Reference: [Develop in Swift Tutorials - Add depth to your app](https://developer.apple.com/tutorials/develop-in-swift/add-depth-to-your-app)

---

## 13. App Distribution

**Impact: LOW**

Prepare apps for TestFlight and App Store distribution. Proper submission requires icons, metadata, and testing workflows.

### 13.1 Test with TestFlight Before Release

**Impact: LOW (real device testing, gather beta feedback, catch issues before App Store)**

TestFlight lets you distribute beta builds to testers before App Store release. Upload builds from Xcode, invite testers, and collect crash reports and feedback.

**Incorrect (skipping beta testing):**

```swift
// Don't ship directly to App Store without testing
// Problems you'll miss:
// - Device-specific crashes
// - Network edge cases
// - User flow confusion
// - Accessibility issues
// - Battery/performance problems on older devices
```

**TestFlight workflow:**

1. **Archive your app:**
   - Product → Archive in Xcode
   - Validate the archive

2. **Upload to App Store Connect:**
   - Distribute App → App Store Connect
   - Upload completes in Organizer

3. **Configure TestFlight:**
   - Set What to Test notes
   - Add internal testers (up to 100)
   - Add external testers (up to 10,000)

4. **Testers receive:**
   - Email invitation
   - Install via TestFlight app
   - Submit feedback and crash reports

**Code considerations:**

```swift
// Detect TestFlight vs App Store
#if DEBUG
let isTestFlight = false
#else
let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
#endif

// Show beta features only in TestFlight
if isTestFlight {
    Text("Beta Feature")
}

// Provide feedback mechanism
Button("Send Feedback") {
    // Open feedback form or email
}
```

**TestFlight benefits:**
- Test on real devices and networks
- Automatic crash reporting
- Built-in feedback screenshots
- 90-day build expiration
- No App Review for internal testers

Reference: [Develop in Swift Tutorials - Test your beta app](https://developer.apple.com/tutorials/develop-in-swift/test-your-beta-app)

---

## References

1. [https://developer.apple.com/tutorials/develop-in-swift/](https://developer.apple.com/tutorials/develop-in-swift/)
2. [https://developer.apple.com/documentation/swiftui/](https://developer.apple.com/documentation/swiftui/)
3. [https://developer.apple.com/documentation/swiftdata/](https://developer.apple.com/documentation/swiftdata/)
4. [https://www.swift.org/](https://www.swift.org/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |