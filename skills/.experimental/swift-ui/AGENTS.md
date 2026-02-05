# SwiftUI

**Version 0.1.0**  
Apple Design Patterns  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide for building Apple-quality iOS app UIs with SwiftUI, designed for AI agents and LLMs. Contains 50+ rules across 9 categories, from critical state management and HIG-compliant visual design to navigation patterns, animations, accessibility, and platform integration. Each rule includes detailed explanations with incorrect vs. correct implementations to enable principal-level one-shot native app development matching Apple's Weather, Calendar, Photos, and Notes apps.

---

## Table of Contents

1. [Data Flow & State Management](#1-data-flow-state-management) — **CRITICAL**
   - 1.1 [Avoid Creating State Inside View Body](#11-avoid-creating-state-inside-view-body)
   - 1.2 [Minimize State Scope to Reduce Re-renders](#12-minimize-state-scope-to-reduce-re-renders)
   - 1.3 [Use @Binding for Child View Mutations](#13-use-binding-for-child-view-mutations)
   - 1.4 [Use @Environment for Shared App Data](#14-use-environment-for-shared-app-data)
   - 1.5 [Use @Observable for Model Classes](#15-use-observable-for-model-classes)
   - 1.6 [Use @State for View-Local Value Types](#16-use-state-for-view-local-value-types)
2. [Visual Design System](#2-visual-design-system) — **CRITICAL**
   - 2.1 [Apply Consistent Padding Patterns](#21-apply-consistent-padding-patterns)
   - 2.2 [Establish Clear Visual Hierarchy](#22-establish-clear-visual-hierarchy)
   - 2.3 [Respect Safe Areas for Content Layout](#23-respect-safe-areas-for-content-layout)
   - 2.4 [Support Dark Mode from Day One](#24-support-dark-mode-from-day-one)
   - 2.5 [Use HIG-Compliant Spacing Values](#25-use-hig-compliant-spacing-values)
   - 2.6 [Use Material Backgrounds for Depth](#26-use-material-backgrounds-for-depth)
   - 2.7 [Use Semantic System Colors](#27-use-semantic-system-colors)
   - 2.8 [Use System Typography Styles](#28-use-system-typography-styles)
3. [Component Selection](#3-component-selection) — **HIGH**
   - 3.1 [Choose Button vs Toggle by Interaction Type](#31-choose-button-vs-toggle-by-interaction-type)
   - 3.2 [Choose Grid vs LazyVGrid by Data Size](#32-choose-grid-vs-lazyvgrid-by-data-size)
   - 3.3 [Choose List vs LazyVStack by Feature Needs](#33-choose-list-vs-lazyvstack-by-feature-needs)
   - 3.4 [Choose Sheet vs FullScreenCover by Content Type](#34-choose-sheet-vs-fullscreencover-by-content-type)
   - 3.5 [Choose TextField vs TextEditor by Content Length](#35-choose-textfield-vs-texteditor-by-content-length)
   - 3.6 [Choose the Right Picker Style](#36-choose-the-right-picker-style)
4. [Navigation Patterns](#4-navigation-patterns) — **HIGH**
   - 4.1 [Organize App Sections with TabView](#41-organize-app-sections-with-tabview)
   - 4.2 [Place Toolbar Items Correctly](#42-place-toolbar-items-correctly)
   - 4.3 [Use Environment Dismiss for Modal Closure](#43-use-environment-dismiss-for-modal-closure)
   - 4.4 [Use Item Binding for Sheet Presentation](#44-use-item-binding-for-sheet-presentation)
   - 4.5 [Use NavigationStack for Modern Navigation](#45-use-navigationstack-for-modern-navigation)
5. [View Composition](#5-view-composition) — **HIGH**
   - 5.1 [Apply Modifiers in Correct Order](#51-apply-modifiers-in-correct-order)
   - 5.2 [Avoid AnyView for Type Erasure](#52-avoid-anyview-for-type-erasure)
   - 5.3 [Conform Views to Equatable for Diffing](#53-conform-views-to-equatable-for-diffing)
   - 5.4 [Extract Subviews for Composition](#54-extract-subviews-for-composition)
   - 5.5 [Prefer Value Types for View Data](#55-prefer-value-types-for-view-data)
   - 5.6 [Use @ViewBuilder for Flexible Composition](#56-use-viewbuilder-for-flexible-composition)
6. [Animation & Haptics](#6-animation-haptics) — **MEDIUM-HIGH**
   - 6.1 [Add Haptic Feedback for Interactions](#61-add-haptic-feedback-for-interactions)
   - 6.2 [Animate Loading and Empty States](#62-animate-loading-and-empty-states)
   - 6.3 [Make Animations Gesture-Driven](#63-make-animations-gesture-driven)
   - 6.4 [Use matchedGeometryEffect for Shared Transitions](#64-use-matchedgeometryeffect-for-shared-transitions)
   - 6.5 [Use Semantic Transitions for Appearing Views](#65-use-semantic-transitions-for-appearing-views)
   - 6.6 [Use Spring Animations as Default](#66-use-spring-animations-as-default)
7. [Accessibility](#7-accessibility) — **MEDIUM-HIGH**
   - 7.1 [Add Accessibility Labels to Interactive Elements](#71-add-accessibility-labels-to-interactive-elements)
   - 7.2 [Ensure Minimum Touch Target Size](#72-ensure-minimum-touch-target-size)
   - 7.3 [Maintain Sufficient Color Contrast](#73-maintain-sufficient-color-contrast)
   - 7.4 [Respect Reduce Motion Preference](#74-respect-reduce-motion-preference)
   - 7.5 [Support Dynamic Type for All Text](#75-support-dynamic-type-for-all-text)
8. [Lists & Scroll Performance](#8-lists-scroll-performance) — **MEDIUM**
   - 8.1 [Profile SwiftUI with Instruments](#81-profile-swiftui-with-instruments)
   - 8.2 [Use AsyncImage for Remote Images](#82-use-asyncimage-for-remote-images)
   - 8.3 [Use drawingGroup for Complex Graphics](#83-use-drawinggroup-for-complex-graphics)
   - 8.4 [Use Lazy Containers for Large Collections](#84-use-lazy-containers-for-large-collections)
   - 8.5 [Use task Modifier for Async Work](#85-use-task-modifier-for-async-work)
9. [Platform Integration](#9-platform-integration) — **MEDIUM**
   - 9.1 [Design for Widget and Live Activity Integration](#91-design-for-widget-and-live-activity-integration)
   - 9.2 [Integrate System Features Natively](#92-integrate-system-features-natively)
   - 9.3 [Respond to App Lifecycle with ScenePhase](#93-respond-to-app-lifecycle-with-scenephase)
   - 9.4 [Use AppStorage for User Preferences](#94-use-appstorage-for-user-preferences)
   - 9.5 [Use SF Symbols for Consistent Iconography](#95-use-sf-symbols-for-consistent-iconography)

---

## 1. Data Flow & State Management

**Impact: CRITICAL**

Wrong state patterns cause cascading re-renders, memory leaks, and broken UIs. Mastering @Observable, @State, and @Binding is the foundation of performant SwiftUI.

### 1.1 Avoid Creating State Inside View Body

**Impact: CRITICAL (prevents re-initialization on every render)**

Creating objects or heavy computations inside the view body causes them to run on every re-render. State and expensive work must be outside the body.

**Incorrect (DateFormatter created every render):**

```swift
struct EventDateView: View {
    let event: Event

    var body: some View {
        let formatter = DateFormatter()  // Created EVERY render
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return Text(formatter.string(from: event.date))
    }
}
```

**Correct (formatter cached outside body):**

```swift
struct EventDateView: View {
    let event: Event

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        Text(Self.formatter.string(from: event.date))
    }
}
```

**Alternative (computed property):**

```swift
struct EventDateView: View {
    let event: Event

    private var formattedDate: String {
        event.date.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        Text(formattedDate)  // Uses modern formatting API
    }
}
```

**Note:** For truly expensive computations that depend on props, consider moving them to the model layer or using a task modifier.

Reference: [The Secret to Buttery Smooth SwiftUI](https://www.swiftdifferently.com/blog/swiftui/swiftui-performance-article)

### 1.2 Minimize State Scope to Reduce Re-renders

**Impact: CRITICAL (isolates re-renders to smallest possible view subtree)**

Place state in the lowest view that needs it. When state changes, only that view and its children re-render. State too high up causes unnecessary work.

**Incorrect (state at top causes full re-render):**

```swift
struct ProductListView: View {
    @State private var products: [Product] = []
    @State private var searchText = ""  // Every keystroke re-renders entire list
    @State private var selectedProduct: Product?

    var body: some View {
        VStack {
            TextField("Search", text: $searchText)

            List(filteredProducts) { product in
                ProductRow(product: product)  // All rows re-render on search
            }
        }
    }
}
```

**Correct (search state isolated):**

```swift
struct ProductListView: View {
    @State private var products: [Product] = []
    @State private var selectedProduct: Product?

    var body: some View {
        VStack {
            SearchField(products: products, onSelect: { selectedProduct = $0 })

            List(products) { product in
                ProductRow(product: product)  // Only re-renders when products change
            }
        }
    }
}

struct SearchField: View {
    let products: [Product]
    let onSelect: (Product) -> Void
    @State private var searchText = ""  // Isolated state

    var filteredProducts: [Product] {
        products.filter { $0.name.contains(searchText) }
    }

    var body: some View {
        // Only this view re-renders on keystroke
        TextField("Search", text: $searchText)
    }
}
```

**Rule of thumb:** If a piece of state only affects one view subtree, move it into that subtree.

Reference: [Understanding and Improving SwiftUI Performance](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896)

### 1.3 Use @Binding for Child View Mutations

**Impact: CRITICAL (enables two-way data flow without duplicating state)**

@Binding creates a two-way connection to state owned by a parent view. The child can read and write the value, but the parent remains the source of truth.

**Incorrect (duplicating state in child):**

```swift
struct SettingsView: View {
    @State private var notificationsEnabled = true

    var body: some View {
        // Child has its own copy, parent never sees changes
        NotificationToggle(isEnabled: notificationsEnabled)
    }
}

struct NotificationToggle: View {
    @State var isEnabled: Bool  // Separate state, not connected

    var body: some View {
        Toggle("Notifications", isOn: $isEnabled)
    }
}
```

**Correct (binding to parent's state):**

```swift
struct SettingsView: View {
    @State private var notificationsEnabled = true

    var body: some View {
        NotificationToggle(isEnabled: $notificationsEnabled)
    }
}

struct NotificationToggle: View {
    @Binding var isEnabled: Bool  // Two-way connection to parent

    var body: some View {
        Toggle("Notifications", isOn: $isEnabled)
    }
}
```

**For @Observable objects, use @Bindable:**

```swift
struct ProfileEditor: View {
    @Bindable var profile: UserProfile  // Creates bindings to @Observable

    var body: some View {
        TextField("Name", text: $profile.name)
    }
}
```

Reference: [SwiftUI Data Flow](https://matteomanferdini.com/swiftui-data-flow/)

### 1.4 Use @Environment for Shared App Data

**Impact: CRITICAL (avoids prop drilling through view hierarchy)**

@Environment provides dependency injection for data needed across many views. Avoids passing data through every intermediate view (prop drilling).

**Incorrect (prop drilling through hierarchy):**

```swift
struct AppView: View {
    @State var settings = AppSettings()

    var body: some View {
        TabView {
            HomeView(settings: settings)
            ProfileView(settings: settings)
        }
    }
}

struct HomeView: View {
    let settings: AppSettings

    var body: some View {
        FeedView(settings: settings)  // Must pass through
    }
}

struct FeedView: View {
    let settings: AppSettings

    var body: some View {
        PostView(settings: settings)  // And again...
    }
}
```

**Correct (environment injection):**

```swift
struct AppView: View {
    @State var settings = AppSettings()

    var body: some View {
        TabView {
            HomeView()
            ProfileView()
        }
        .environment(settings)  // Inject once at top
    }
}

struct PostView: View {
    @Environment(AppSettings.self) var settings  // Access anywhere

    var body: some View {
        Text(settings.userName)
    }
}
```

**System environment values:**

```swift
struct AdaptiveView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var typeSize
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        // Adapt to system settings
    }
}
```

Reference: [SwiftUI Data Flow 2023](https://troz.net/post/2023/swiftui-data-flow-2023/)

### 1.5 Use @Observable for Model Classes

**Impact: CRITICAL (eliminates ObservableObject boilerplate, enables granular updates)**

The @Observable macro (iOS 17+) replaces ObservableObject with automatic property tracking. SwiftUI only re-renders views that read changed properties, not the entire observation graph.

**Incorrect (ObservableObject triggers full re-renders):**

```swift
class UserProfile: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var avatarURL: URL?
    // Every @Published change re-renders ALL observing views
}

struct ProfileView: View {
    @StateObject var profile = UserProfile()

    var body: some View {
        VStack {
            Text(profile.name)  // Re-renders when email changes too
            Text(profile.email)
        }
    }
}
```

**Correct (granular property tracking):**

```swift
@Observable
class UserProfile {
    var name: String = ""
    var email: String = ""
    var avatarURL: URL?
    // SwiftUI tracks which properties each view reads
}

struct ProfileView: View {
    @State var profile = UserProfile()

    var body: some View {
        VStack {
            Text(profile.name)  // Only re-renders when name changes
            Text(profile.email) // Only re-renders when email changes
        }
    }
}
```

**Migration guide:**
- `ObservableObject` → `@Observable`
- Remove all `@Published` wrappers
- `@StateObject` → `@State`
- `@ObservedObject` → remove wrapper (just pass the object)
- `@EnvironmentObject` → `@Environment(MyType.self)`

Reference: [SwiftUI Data Flow with Observation](https://www.swiftyplace.com/blog/swiftui-observation)

### 1.6 Use @State for View-Local Value Types

**Impact: CRITICAL (prevents memory leaks and unexpected re-initialization)**

@State is for value types (structs, enums, primitives) that belong exclusively to a view. SwiftUI manages the storage and persists it across view updates.

**Incorrect (local variable resets on every body call):**

```swift
struct CounterView: View {
    var count = 0  // Resets to 0 on every re-render

    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1  // Compiler error: cannot mutate
            }
        }
    }
}
```

**Correct (state persists across re-renders):**

```swift
struct CounterView: View {
    @State private var count = 0  // Persisted by SwiftUI

    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1  // Triggers re-render with new value
            }
        }
    }
}
```

**When NOT to use @State:**
- For reference types (classes) - use @State with @Observable instead
- For data that needs to be shared with parent views - use @Binding
- For app-wide data - use @Environment

**Note:** Always mark @State properties as `private` since they should only be modified by the owning view.

Reference: [State Management in SwiftUI](https://developers-heaven.net/blog/state-management-in-swiftui-state-binding-observable-and-environment/)

---

## 2. Visual Design System

**Impact: CRITICAL**

HIG compliance with proper spacing, typography, and colors is what separates amateur apps from Apple-quality experiences. These patterns create visual harmony.

### 2.1 Apply Consistent Padding Patterns

**Impact: CRITICAL (creates visual rhythm and professional polish)**

Inconsistent padding creates visual noise. Use the same padding values for the same contexts throughout your app.

**Incorrect (inconsistent padding):**

```swift
struct SettingsView: View {
    var body: some View {
        List {
            Section("Account") {
                Text("Email")
                    .padding(.horizontal, 16)  // 16pt
                Text("Password")
                    .padding(.horizontal, 20)  // Different: 20pt
            }

            Section("Preferences") {
                Text("Notifications")
                    .padding(.leading, 12)  // Different: 12pt
            }
        }
    }
}
```

**Correct (systematic padding):**

```swift
struct SettingsView: View {
    var body: some View {
        List {
            Section("Account") {
                SettingsRow(title: "Email", value: user.email)
                SettingsRow(title: "Password", value: "••••••••")
            }

            Section("Preferences") {
                SettingsRow(title: "Notifications", value: "On")
            }
        }
    }
}

struct SettingsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        // List provides consistent padding automatically
    }
}
```

**Padding guidelines:**

```swift
// Screen-level content padding
.padding(.horizontal, 16)  // Standard iOS margin

// Card/grouped content
.padding(16)  // Equal padding all sides

// Compact elements (buttons, chips)
.padding(.horizontal, 12)
.padding(.vertical, 8)

// Touch targets (minimum 44pt)
.frame(minHeight: 44)
```

**Use SwiftUI's built-in spacing:**

```swift
List { }           // Automatic row padding
Form { }           // Automatic form padding
NavigationStack { } // Automatic navigation padding
```

Reference: [Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)

### 2.2 Establish Clear Visual Hierarchy

**Impact: CRITICAL (guides user attention and improves comprehension)**

Visual hierarchy uses size, weight, color, and spacing to communicate importance. Every screen should have a clear primary, secondary, and tertiary information level.

**Incorrect (flat hierarchy, everything same weight):**

```swift
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.body)  // Same weight
            Text(product.category)
                .font(.body)  // Same weight
            Text(product.price)
                .font(.body)  // Same weight
            Text(product.description)
                .font(.body)  // Everything looks the same
        }
    }
}
```

**Correct (clear information hierarchy):**

```swift
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.category)
                .font(.caption)
                .foregroundStyle(.secondary)  // Tertiary: context

            Text(product.name)
                .font(.headline)  // Primary: most important

            Text(product.price)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.accentColor)  // Secondary: key info

            Text(product.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)  // Tertiary: supporting
        }
    }
}
```

**Hierarchy techniques:**

| Level | Size | Weight | Color |
|-------|------|--------|-------|
| Primary | .headline+ | .semibold+ | .primary |
| Secondary | .body | .regular | .primary |
| Tertiary | .subheadline- | .regular | .secondary |
| Metadata | .caption | .regular | .tertiary |

**Apple's Weather app example:**
- Temperature: `.system(size: 96)` - Hero
- Condition: `.title2` - Primary
- High/Low: `.title3` - Secondary
- Details: `.body` - Tertiary

Reference: [Human Interface Guidelines - Typography](https://developer.apple.com/design/human-interface-guidelines/typography)

### 2.3 Respect Safe Areas for Content Layout

**Impact: CRITICAL (prevents content clipping by notch, home indicator, and system UI)**

Safe areas ensure content isn't obscured by the notch, Dynamic Island, home indicator, or status bar. Ignore them only intentionally for backgrounds.

**Incorrect (content under system UI):**

```swift
struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var inputText = ""

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages) { message in
                    MessageRow(message: message)
                }
            }
            TextField("Message", text: $inputText)
                .padding()
        }
        .ignoresSafeArea()  // Input field hidden under home indicator
    }
}
```

**Correct (respecting safe areas):**

```swift
struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var inputText = ""

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages) { message in
                    MessageRow(message: message)
                }
            }
            TextField("Message", text: $inputText)
                .padding()
        }
        // Safe area respected by default
    }
}
```

**Extending backgrounds only:**

```swift
struct ProfileHeader: View {
    let user: User

    var body: some View {
        ZStack {
            // Background extends under status bar
            Color.blue
                .ignoresSafeArea(edges: .top)

            // Content respects safe area
            VStack {
                Avatar(url: user.avatarURL)
                Text(user.name)
            }
            .padding(.top, 60)
        }
    }
}
```

**Safe area regions:**
- `.top` - Status bar, Dynamic Island
- `.bottom` - Home indicator
- `.leading`, `.trailing` - Rounded corners on iPad
- `.keyboard` - Software keyboard

Reference: [Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)

### 2.4 Support Dark Mode from Day One

**Impact: CRITICAL (required for App Store quality, 80%+ users enable Dark Mode)**

Dark Mode isn't optional. Over 80% of iOS users enable it. Design with both appearances from the start using semantic colors and adaptive assets.

**Incorrect (light-only design):**

```swift
struct ProfileCard: View {
    let user: User

    var body: some View {
        VStack {
            Image(user.avatar)
            Text(user.name)
                .foregroundColor(.black)  // Invisible in Dark Mode
        }
        .background(Color.white)  // Harsh in Dark Mode
        .cornerRadius(12)
        .shadow(color: .gray, radius: 4)  // Wrong shadow color
    }
}
```

**Correct (adaptive design):**

```swift
struct ProfileCard: View {
    let user: User

    var body: some View {
        VStack {
            Image(user.avatar)
            Text(user.name)
                .foregroundStyle(.primary)  // Adapts automatically
        }
        .background(.background.secondary)  // System background
        .cornerRadius(12)
        .shadow(color: .primary.opacity(0.1), radius: 4)  // Adaptive shadow
    }
}
```

**Testing both appearances:**

```swift
struct ProfileCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileCard(user: .preview)
                .preferredColorScheme(.light)
            ProfileCard(user: .preview)
                .preferredColorScheme(.dark)
        }
    }
}
```

**Adaptive images in asset catalog:**
1. Add image to Assets.xcassets
2. Select "Appearances" → "Any, Dark"
3. Provide both light and dark variants

**Responding to appearance changes:**

```swift
struct AdaptiveIcon: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Image(colorScheme == .dark ? "icon-dark" : "icon-light")
    }
}
```

Reference: [Human Interface Guidelines - Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode)

### 2.5 Use HIG-Compliant Spacing Values

**Impact: CRITICAL (creates visual rhythm matching Apple's native apps)**

Apple uses an 8-point grid system. Spacing values should be multiples of 4 or 8 points. Random values create visual discord.

**Incorrect (arbitrary spacing values):**

```swift
struct SettingsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
        .padding(.horizontal, 15)  // Arbitrary value
        .padding(.vertical, 11)    // Not on grid
    }
}
```

**Correct (8-point grid):**

```swift
struct SettingsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)  // 2 × 8
        .padding(.vertical, 12)    // 1.5 × 8
    }
}
```

**Standard spacing constants:**

```swift
enum Spacing {
    static let xxs: CGFloat = 4   // Tight grouping
    static let xs: CGFloat = 8    // Related elements
    static let sm: CGFloat = 12   // Standard gap
    static let md: CGFloat = 16   // Section padding
    static let lg: CGFloat = 24   // Major sections
    static let xl: CGFloat = 32   // Screen margins
    static let xxl: CGFloat = 48  // Hero spacing
}

// Usage
VStack(spacing: Spacing.sm) {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}
.padding(Spacing.md)
```

**Note:** iOS uses 16pt horizontal margins for content and 20pt for grouped table views.

Reference: [Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)

### 2.6 Use Material Backgrounds for Depth

**Impact: CRITICAL (creates the layered, translucent look of native iOS apps)**

Materials provide the translucent, blurred backgrounds that define iOS's visual language. They create depth and help content stand out while maintaining context.

**Incorrect (solid backgrounds lose context):**

```swift
struct BottomSheet: View {
    let items: [MenuItem]

    var body: some View {
        VStack {
            ForEach(items) { item in
                MenuItemRow(item: item)
            }
        }
        .background(Color.white)  // Solid, no depth
    }
}
```

**Correct (material backgrounds):**

```swift
struct BottomSheet: View {
    let items: [MenuItem]

    var body: some View {
        VStack {
            ForEach(items) { item in
                MenuItemRow(item: item)
            }
        }
        .background(.regularMaterial)  // Translucent, adapts to content behind
    }
}
```

**Material types (thinnest to thickest blur):**

```swift
.ultraThinMaterial  // Subtle blur, most transparent
.thinMaterial       // Light blur
.regularMaterial    // Standard blur (most common)
.thickMaterial      // Heavy blur
.ultraThickMaterial // Maximum blur, most opaque
```

**Common use cases:**

```swift
// Navigation bar style
.toolbarBackground(.regularMaterial, for: .navigationBar)

// Tab bar
.toolbarBackground(.thinMaterial, for: .tabBar)

// Overlay cards
.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

// Full-screen overlay
ZStack {
    ContentView()
    Color.clear
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    ModalContent()
}
```

**Vibrancy for text on materials:**

```swift
Text("Vibrant Label")
    .foregroundStyle(.secondary)  // Automatically vibrant on materials
```

Reference: [Human Interface Guidelines - Materials](https://developer.apple.com/design/human-interface-guidelines/materials)

### 2.7 Use Semantic System Colors

**Impact: CRITICAL (automatic Dark Mode support and accessibility compliance)**

Semantic colors like `.primary`, `.secondary`, and system backgrounds automatically adapt to Dark Mode, accessibility settings, and platform conventions.

**Incorrect (hardcoded colors):**

```swift
struct MessageBubble: View {
    let message: Message

    var body: some View {
        Text(message.text)
            .foregroundColor(Color(red: 0, green: 0, blue: 0))  // Black, invisible in Dark Mode
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))  // Light gray, wrong in Dark Mode
    }
}
```

**Correct (semantic colors):**

```swift
struct MessageBubble: View {
    let message: Message

    var body: some View {
        Text(message.text)
            .foregroundStyle(.primary)  // Adapts to color scheme
            .background(.background.secondary)  // System background
    }
}
```

**Semantic color hierarchy:**

```swift
// Text colors
.primary      // Main text, high contrast
.secondary    // Supporting text, medium contrast
.tertiary     // Placeholder text, low contrast
.quaternary   // Disabled text, minimal contrast

// Background colors
.background           // Primary background
.background.secondary // Grouped content background

// System colors (adapt to Dark Mode)
Color.systemBackground
Color.secondarySystemBackground
Color.tertiarySystemBackground
Color.systemGroupedBackground

// Accent colors
Color.accentColor  // App tint color
Color.blue, .green, .red  // System colors with Dark Mode variants
```

**Defining custom adaptive colors:**

```swift
extension Color {
    static let cardBackground = Color("CardBackground")  // From asset catalog
}

// Asset catalog provides light and dark variants
```

Reference: [Human Interface Guidelines - Color](https://developer.apple.com/design/human-interface-guidelines/color)

### 2.8 Use System Typography Styles

**Impact: CRITICAL (ensures Dynamic Type support and visual consistency)**

Apple's semantic font styles (`.title`, `.headline`, `.body`) automatically scale with Dynamic Type and maintain visual hierarchy. Hardcoded sizes break accessibility.

**Incorrect (hardcoded font sizes):**

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.system(size: 24, weight: .bold))  // Ignores Dynamic Type
            Text(article.subtitle)
                .font(.system(size: 16))  // Fixed size
            Text(article.body)
                .font(.system(size: 14))  // Won't scale
        }
    }
}
```

**Correct (semantic text styles):**

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.title)  // Scales with Dynamic Type
            Text(article.subtitle)
                .font(.headline)  // Semantic meaning
            Text(article.body)
                .font(.body)  // Default reading size
        }
    }
}
```

**Text style hierarchy:**

```swift
.largeTitle  // 34pt - Screen titles
.title       // 28pt - Section headers
.title2      // 22pt - Subsections
.title3      // 20pt - Group headers
.headline    // 17pt semibold - Important labels
.body        // 17pt - Default text
.callout     // 16pt - Secondary content
.subheadline // 15pt - Supporting text
.footnote    // 13pt - Disclaimers
.caption     // 12pt - Labels
.caption2    // 11pt - Smallest text
```

**Customizing while preserving scaling:**

```swift
Text("Custom Title")
    .font(.title.weight(.heavy))
    .font(.body.italic())
    .font(.headline.monospaced())
```

Reference: [Human Interface Guidelines - Typography](https://developer.apple.com/design/human-interface-guidelines/typography)

---

## 3. Component Selection

**Impact: HIGH**

Choosing the right SwiftUI component for each use case determines implementation success. Wrong component choice leads to performance issues and UX problems.

### 3.1 Choose Button vs Toggle by Interaction Type

**Impact: HIGH (prevents user confusion from wrong control type)**

Buttons trigger actions. Toggles change state. Users have strong expectations about how each behaves.

**Incorrect (Button for on/off state):**

```swift
struct AudioControls: View {
    @State private var isMuted = false

    var body: some View {
        Button(isMuted ? "Unmute" : "Mute") {
            isMuted.toggle()
        }
        // Label changes, confusing which state is active
        // Doesn't communicate current state clearly
    }
}
```

**Correct (Toggle for binary state):**

```swift
struct AudioControls: View {
    @State private var isMuted = false

    var body: some View {
        Toggle("Mute", isOn: $isMuted)
        // Clear on/off state visible at all times
        // Matches user expectation for settings
    }
}
```

**Use Button for actions:**

```swift
struct SubscriptionView: View {
    var body: some View {
        VStack(spacing: 16) {
            Button("Subscribe Now") { subscribe() }
                .buttonStyle(.borderedProminent)

            Button("Cancel Subscription", role: .destructive) {
                showCancelConfirmation = true
            }
        }
    }
}
```

**Use Toggle for persistent settings:**

```swift
struct NotificationSettings: View {
    @AppStorage("pushEnabled") private var pushEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true

    var body: some View {
        Form {
            Toggle("Push Notifications", isOn: $pushEnabled)
            Toggle("Sound Effects", isOn: $soundEnabled)
        }
    }
}
```

**Decision matrix:**

| Interaction | Control |
|-------------|---------|
| Submit form | Button |
| Delete item | Button |
| Enable/disable feature | Toggle |
| On/off setting | Toggle |

Reference: [Human Interface Guidelines - Toggles](https://developer.apple.com/design/human-interface-guidelines/toggles)

### 3.2 Choose Grid vs LazyVGrid by Data Size

**Impact: HIGH (prevents memory waste or layout issues from wrong grid type)**

Grid loads all items immediately. LazyVGrid loads on demand. Use Grid for small fixed layouts, LazyVGrid for dynamic data.

**Incorrect (Grid for large dynamic data):**

```swift
struct PhotoGallery: View {
    let photos: [Photo]  // Could be hundreds

    var body: some View {
        ScrollView {
            Grid {  // Loads ALL photos immediately
                ForEach(photos) { photo in
                    GridRow {
                        PhotoThumbnail(photo: photo)
                    }
                }
            }
            // Massive memory usage, slow initial load
        }
    }
}
```

**Correct (LazyVGrid for dynamic data):**

```swift
struct PhotoGallery: View {
    let photos: [Photo]

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(photos) { photo in
                    PhotoThumbnail(photo: photo)
                        .aspectRatio(1, contentMode: .fill)
                }
            }
            // Only visible photos in memory
        }
    }
}
```

**Use Grid for small fixed layouts:**

```swift
struct QuickActionsGrid: View {
    let actions = QuickAction.defaults  // 6-9 items

    var body: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                ActionButton(action: actions[0])
                ActionButton(action: actions[1])
                ActionButton(action: actions[2])
            }
            GridRow {
                ActionButton(action: actions[3])
                ActionButton(action: actions[4])
                ActionButton(action: actions[5])
            }
        }
    }
}
```

**Decision matrix:**

| Scenario | Use |
|----------|-----|
| Calculator buttons | Grid |
| Settings quick actions | Grid |
| Photo gallery | LazyVGrid |
| Product catalog | LazyVGrid |

Reference: [Apple Developer - LazyVGrid](https://developer.apple.com/documentation/swiftui/lazyvgrid)

### 3.3 Choose List vs LazyVStack by Feature Needs

**Impact: HIGH (prevents rebuilding UI when wrong component lacks needed features)**

List provides built-in features (swipe actions, selection, editing). LazyVStack offers more customization. Choose based on what you need.

**Incorrect (LazyVStack when List features needed):**

```swift
struct InboxView: View {
    @State private var emails: [Email] = []

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(emails) { email in
                    EmailRow(email: email)
                    // No swipe actions, no selection, no edit mode
                    // Would need to rebuild from scratch to add these
                }
            }
        }
    }
}
```

**Correct (List when swipe/selection needed):**

```swift
struct InboxView: View {
    @State private var emails: [Email] = []
    @State private var selection: Set<Email.ID> = []

    var body: some View {
        List(emails, selection: $selection) { email in
            EmailRow(email: email)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) { delete(email) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .listStyle(.plain)
    }
}
```

**Use LazyVStack for custom layouts:**

```swift
struct FeedView: View {
    let posts: [Post]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(posts) { post in
                    PostCard(post: post)
                        .padding(.horizontal)
                }
            }
        }
    }
}
```

**Decision matrix:**

| Need | Use |
|------|-----|
| Swipe actions | List |
| Selection (single/multi) | List |
| Section headers with sticky | List |
| Edit mode (reorder/delete) | List |
| Custom layouts | LazyVStack |
| Full visual control | LazyVStack |

Reference: [List or LazyVStack - Fatbobman](https://fatbobman.com/en/posts/list-or-lazyvstack/)

### 3.4 Choose Sheet vs FullScreenCover by Content Type

**Impact: HIGH (prevents confusing navigation mental model for users)**

Sheets are for quick tasks that maintain context. Full-screen covers are for immersive flows that replace the current context entirely.

**Incorrect (sheet for immersive camera flow):**

```swift
struct HomeView: View {
    @State private var showingCamera = false

    var body: some View {
        Button("Take Photo") { showingCamera = true }
            .sheet(isPresented: $showingCamera) {
                CameraView()  // Sheet for immersive camera feels wrong
                // User can accidentally dismiss by swiping
            }
    }
}
```

**Correct (fullScreenCover for immersive flow):**

```swift
struct HomeView: View {
    @State private var showingCamera = false

    var body: some View {
        Button("Take Photo") { showingCamera = true }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView()  // Full screen for immersive experience
                // Requires explicit dismiss action
            }
    }
}
```

**Use sheet for quick contextual tasks:**

```swift
struct PhotosView: View {
    @State private var showingShareSheet = false

    var body: some View {
        Button("Share") { showingShareSheet = true }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(photo: selectedPhoto)
                    .presentationDetents([.medium, .large])
            }
    }
}
```

**Decision matrix:**

| Content Type | Presentation |
|--------------|--------------|
| Quick edit | Sheet (medium) |
| Share/export | Sheet |
| Filters/options | Sheet |
| Camera/scanner | FullScreenCover |
| Onboarding | FullScreenCover |
| Media player | FullScreenCover |
| Authentication | FullScreenCover |

Reference: [SwiftUI Presentations](https://www.swiftyplace.com/blog/presenting-views-in-swiftui-sheets-modals-popovers-alerts-and-navigation)

### 3.5 Choose TextField vs TextEditor by Content Length

**Impact: HIGH (prevents poor text entry experience from wrong input type)**

TextField is for single-line input. TextEditor is for multi-line content. Use the right component for the expected content length.

**Incorrect (TextField for long content):**

```swift
struct NoteEditor: View {
    @Binding var note: Note

    var body: some View {
        TextField("Note", text: $note.content)
            // Single line only, truncates long content
            // No scrolling, no line wrapping
            // Users can't see what they're typing
    }
}
```

**Correct (TextEditor for multi-line):**

```swift
struct NoteEditor: View {
    @Binding var note: Note
    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $note.content)
            .focused($isFocused)
            .frame(minHeight: 200)
            .scrollContentBackground(.hidden)
            .background(.background.secondary)
            .cornerRadius(8)
    }
}
```

**Use TextField for short input:**

```swift
struct LoginForm: View {
    @State private var email = ""

    var body: some View {
        TextField("Email", text: $email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
    }
}
```

**TextField with axis for expandable (iOS 16+):**

```swift
TextField("Message", text: $message, axis: .vertical)
    .lineLimit(1...5)  // Expands from 1 to 5 lines
```

**Decision matrix:**

| Content | Component |
|---------|-----------|
| Username, email | TextField |
| Search query | TextField |
| Password | SecureField |
| Notes, comments | TextEditor |
| Bio, description | TextEditor |

Reference: [Human Interface Guidelines - Text Fields](https://developer.apple.com/design/human-interface-guidelines/text-fields)

### 3.6 Choose the Right Picker Style

**Impact: HIGH (prevents poor UX from mismatched picker for data type)**

SwiftUI offers multiple picker styles. Choose based on the number of options and frequency of change.

**Incorrect (menu for frequently-changed options):**

```swift
struct FilterView: View {
    @State private var timeRange = TimeRange.week

    var body: some View {
        Picker("Time Range", selection: $timeRange) {
            Text("Day").tag(TimeRange.day)
            Text("Week").tag(TimeRange.week)
            Text("Month").tag(TimeRange.month)
        }
        .pickerStyle(.menu)  // Hidden in menu, requires tap to see options
        // User can't quickly switch between common options
    }
}
```

**Correct (segmented for 2-5 frequent options):**

```swift
struct FilterView: View {
    @State private var timeRange = TimeRange.week

    var body: some View {
        Picker("Time Range", selection: $timeRange) {
            Text("Day").tag(TimeRange.day)
            Text("Week").tag(TimeRange.week)
            Text("Month").tag(TimeRange.month)
        }
        .pickerStyle(.segmented)  // Always visible, one-tap switching
    }
}
```

**Use menu for infrequent selections:**

```swift
struct SortOptions: View {
    @State private var sortOrder = SortOrder.dateDescending

    var body: some View {
        Picker("Sort By", selection: $sortOrder) {
            ForEach(SortOrder.allCases) { order in
                Text(order.displayName).tag(order)
            }
        }
        .pickerStyle(.menu)  // Compact, 10+ options
    }
}
```

**Decision matrix:**

| Options | Frequency | Style |
|---------|-----------|-------|
| 2-5 | High | .segmented |
| 3-15 | Low-Medium | .menu |
| Dates/times | Any | .wheel or .graphical |
| 15+ | Any | Navigation to list |

Reference: [Human Interface Guidelines - Pickers](https://developer.apple.com/design/human-interface-guidelines/pickers)

---

## 4. Navigation Patterns

**Impact: HIGH**

NavigationStack, sheets, and modals define how users move through your app. Wrong patterns cause navigation bugs, state loss, and poor user experience.

### 4.1 Organize App Sections with TabView

**Impact: HIGH (provides familiar iOS navigation pattern for top-level sections)**

TabView provides the familiar iOS tab bar for switching between top-level app sections. Each tab maintains its own navigation state.

**Incorrect (tabs without proper structure):**

```swift
struct AppView: View {
    var body: some View {
        TabView {
            HomeView()  // No tab item
            SearchView()
            ProfileView()
        }
    }
}
```

**Correct (properly configured tabs):**

```swift
struct AppView: View {
    @State private var selectedTab = Tab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(Tab.profile)
        }
    }
}

enum Tab: Hashable {
    case home, search, profile
}
```

**Tab badge for notifications:**

```swift
.tabItem {
    Label("Inbox", systemImage: "envelope")
}
.badge(unreadCount)  // Shows red badge
```

**Guidelines for tabs:**
- Use 3-5 tabs (more requires "More" tab)
- Each tab is a self-contained section
- Tabs should represent parallel content, not sequential flow
- Use SF Symbols for consistency
- Tab labels should be short (1-2 words)

**Programmatic tab switching:**

```swift
// Switch to search tab
selectedTab = .search

// Handle deep links
.onOpenURL { url in
    if url.path.contains("profile") {
        selectedTab = .profile
    }
}
```

Reference: [Human Interface Guidelines - Tab Bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)

### 4.2 Place Toolbar Items Correctly

**Impact: HIGH (follows iOS conventions for action placement)**

iOS has conventions for toolbar button placement. Following them makes your app feel native and predictable.

**Incorrect (wrong placements):**

```swift
struct NoteEditor: View {
    var body: some View {
        TextEditor(text: $note.content)
            .toolbar {
                Button("Cancel") { dismiss() }  // No placement
                Button("Save") { save() }       // Default placement
            }
    }
}
```

**Correct (proper placements):**

```swift
struct NoteEditor: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TextEditor(text: $note.content)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
    }
}
```

**Standard toolbar placements:**

```swift
// Leading (left side)
.cancellationAction    // Cancel, Close
.navigation            // Back, custom nav

// Trailing (right side)
.confirmationAction    // Done, Save, Add
.primaryAction         // Main action
.destructiveAction     // Delete (red)

// Bottom bar
.bottomBar             // Tab-like actions

// Keyboard
.keyboard              // Above keyboard

// Principal (center)
.principal             // Title area custom content
```

**Complete toolbar example:**

```swift
struct DocumentEditor: View {
    var body: some View {
        EditorContent()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(document.title).font(.headline)
                        Text("Edited 2m ago").font(.caption)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { save() }
                        .fontWeight(.semibold)
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Button { } label: { Image(systemName: "bold") }
                    Button { } label: { Image(systemName: "italic") }
                    Spacer()
                    Button { } label: { Image(systemName: "photo") }
                }
            }
    }
}
```

Reference: [Human Interface Guidelines - Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars)

### 4.3 Use Environment Dismiss for Modal Closure

**Impact: HIGH (clean dismissal without passing closures through hierarchy)**

The `@Environment(\.dismiss)` action provides a clean way to close modals without passing callbacks through the view hierarchy.

**Incorrect (passing dismiss callback):**

```swift
struct ParentView: View {
    @State private var showingEditor = false

    var body: some View {
        Button("Edit") { showingEditor = true }
            .sheet(isPresented: $showingEditor) {
                EditorView(onDismiss: { showingEditor = false })
            }
    }
}

struct EditorView: View {
    let onDismiss: () -> Void  // Callback passed through

    var body: some View {
        NavigationStack {
            Form { /* ... */ }
                .toolbar {
                    Button("Done") { onDismiss() }
                }
        }
    }
}
```

**Correct (environment dismiss):**

```swift
struct ParentView: View {
    @State private var showingEditor = false

    var body: some View {
        Button("Edit") { showingEditor = true }
            .sheet(isPresented: $showingEditor) {
                EditorView()
            }
    }
}

struct EditorView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form { /* ... */ }
                .toolbar {
                    Button("Done") { dismiss() }
                }
        }
    }
}
```

**Works in nested views too:**

```swift
struct DeepNestedView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button("Close Modal") {
            dismiss()  // Dismisses the entire modal, not just this view
        }
    }
}
```

**Dismiss with confirmation:**

```swift
struct UnsavedChangesEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hasChanges = false
    @State private var showingConfirmation = false

    var body: some View {
        Form { /* ... */ }
            .toolbar {
                Button("Cancel") {
                    if hasChanges {
                        showingConfirmation = true
                    } else {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Discard changes?", isPresented: $showingConfirmation) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep Editing", role: .cancel) { }
            }
    }
}
```

Reference: [DismissAction Documentation](https://developer.apple.com/documentation/swiftui/dismissaction)

### 4.4 Use Item Binding for Sheet Presentation

**Impact: HIGH (prevents modal state bugs and simplifies data passing)**

Use `.sheet(item:)` instead of `.sheet(isPresented:)` when the sheet needs data. This ensures the data exists when the sheet appears.

**Incorrect (boolean + separate state):**

```swift
struct RecipeList: View {
    @State private var recipes: [Recipe] = []
    @State private var showingDetail = false
    @State private var selectedRecipe: Recipe?  // Can be nil when sheet opens

    var body: some View {
        List(recipes) { recipe in
            Button(recipe.name) {
                selectedRecipe = recipe
                showingDetail = true
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let recipe = selectedRecipe {  // Force unwrap risk
                RecipeDetail(recipe: recipe)
            }
        }
    }
}
```

**Correct (item binding):**

```swift
struct RecipeList: View {
    @State private var recipes: [Recipe] = []
    @State private var selectedRecipe: Recipe?  // Single source of truth

    var body: some View {
        List(recipes) { recipe in
            Button(recipe.name) {
                selectedRecipe = recipe  // Setting triggers sheet
            }
        }
        .sheet(item: $selectedRecipe) { recipe in
            // recipe is guaranteed non-nil
            RecipeDetail(recipe: recipe)
        }
    }
}
```

**Make your model Identifiable:**

```swift
struct Recipe: Identifiable {
    let id: UUID
    var name: String
    var ingredients: [Ingredient]
}
```

**Multiple sheet types:**

```swift
struct ContentView: View {
    @State private var activeSheet: SheetType?

    var body: some View {
        Button("Edit") { activeSheet = .edit(item) }
        Button("Share") { activeSheet = .share(item) }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .edit(let item):
                    EditView(item: item)
                case .share(let item):
                    ShareView(item: item)
                }
            }
    }
}

enum SheetType: Identifiable {
    case edit(Item)
    case share(Item)

    var id: String {
        switch self {
        case .edit(let item): return "edit-\(item.id)"
        case .share(let item): return "share-\(item.id)"
        }
    }
}
```

Reference: [SwiftUI Sheet Documentation](https://developer.apple.com/documentation/swiftui/view/sheet(item:ondismiss:content:))

### 4.5 Use NavigationStack for Modern Navigation

**Impact: HIGH (enables programmatic navigation and deep linking)**

NavigationStack (iOS 16+) replaces NavigationView with programmatic path control. This enables deep linking, state restoration, and complex navigation flows.

**Incorrect (deprecated NavigationView):**

```swift
struct ContentView: View {
    var body: some View {
        NavigationView {  // Deprecated, limited control
            List(items) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    ItemRow(item: item)
                }
            }
        }
    }
}
```

**Correct (NavigationStack with path):**

```swift
struct ContentView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(items) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }
            }
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
            }
            .navigationDestination(for: Category.self) { category in
                CategoryView(category: category)
            }
        }
    }

    // Programmatic navigation
    func navigateToItem(_ item: Item) {
        navigationPath.append(item)
    }

    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
```

**Deep linking support:**

```swift
struct AppView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: DeepLink.self) { link in
                    link.destination
                }
        }
        .onOpenURL { url in
            if let deepLink = DeepLink(url: url) {
                path.append(deepLink)
            }
        }
    }
}
```

**Navigation title styles:**

```swift
.navigationTitle("Inbox")
.navigationBarTitleDisplayMode(.large)   // Large title
.navigationBarTitleDisplayMode(.inline)  // Small title
.navigationBarTitleDisplayMode(.automatic) // Context-dependent
```

Reference: [Modern SwiftUI Navigation](https://medium.com/@dinaga119/mastering-navigation-in-swiftui-the-2025-guide-to-clean-scalable-routing-bbcb6dbce929)

---

## 5. View Composition

**Impact: HIGH**

How views are structured affects performance, maintainability, and reusability. Proper extraction and composition enable SwiftUI's diffing optimization.

### 5.1 Apply Modifiers in Correct Order

**Impact: HIGH (wrong order produces unexpected visual results)**

Modifier order matters. Each modifier wraps the view in a new view. Padding before background is different from background before padding.

**Incorrect (padding outside background):**

```swift
struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .background(Color.blue)  // Background only behind text
            .padding()               // Padding outside background
            .foregroundStyle(.white)
    }
}
// Result: Small blue box with empty padding around it
```

**Correct (padding inside background):**

```swift
struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(.white)
            .background(Color.blue)  // Background includes padding
            .cornerRadius(8)
    }
}
// Result: Blue rounded rectangle containing padded text
```

**Common modifier ordering:**

```swift
Text("Button")
    // 1. Content modifiers (text styling)
    .font(.headline)
    .foregroundStyle(.white)

    // 2. Layout modifiers (spacing, size)
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity)

    // 3. Background/overlay
    .background(Color.accentColor)
    .cornerRadius(12)

    // 4. Effects (shadow, blur)
    .shadow(radius: 4)

    // 5. Positioning modifiers
    .padding()
```

**Visual debugging tip:**

```swift
Text("Debug")
    .border(.red)      // See text bounds
    .padding()
    .border(.blue)     // See padded bounds
    .background(.gray)
    .border(.green)    // See background bounds
```

**Frame before vs after padding:**

```swift
// Frame then padding - padding is outside the frame
Text("A").frame(width: 100).padding()

// Padding then frame - frame includes padding
Text("B").padding().frame(width: 100)
```

Reference: [8 Common SwiftUI Mistakes](https://www.hackingwithswift.com/articles/224/common-swiftui-mistakes-and-how-to-fix-them)

### 5.2 Avoid AnyView for Type Erasure

**Impact: HIGH (AnyView disables SwiftUI's diffing optimization)**

AnyView erases type information, preventing SwiftUI from efficiently diffing views. Use `@ViewBuilder`, generics, or `Group` instead.

**Incorrect (AnyView breaks diffing):**

```swift
struct DynamicContent: View {
    let contentType: ContentType

    var body: some View {
        content  // Returns AnyView
    }

    var content: AnyView {
        switch contentType {
        case .text(let string):
            return AnyView(Text(string))  // Type erased
        case .image(let url):
            return AnyView(AsyncImage(url: url))  // Type erased
        case .video(let url):
            return AnyView(VideoPlayer(url: url))  // Type erased
        }
    }
}
```

**Correct (using @ViewBuilder):**

```swift
struct DynamicContent: View {
    let contentType: ContentType

    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        switch contentType {
        case .text(let string):
            Text(string)  // Type preserved
        case .image(let url):
            AsyncImage(url: url)  // Type preserved
        case .video(let url):
            VideoPlayer(url: url)  // Type preserved
        }
    }
}
```

**Alternative with Group:**

```swift
var body: some View {
    Group {
        if showImage {
            AsyncImage(url: imageURL)
        } else {
            Text(placeholder)
        }
    }
}
```

**When AnyView is acceptable:**
- Heterogeneous collections where type erasure is unavoidable
- Plugin systems with unknown view types
- Rarely-updated views where diffing cost is negligible

**Using generics instead:**

```swift
struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(.background.secondary)
            .cornerRadius(12)
    }
}
```

Reference: [SwiftUI Performance Best Practices](https://dev.to/arshtechpro/swiftui-performance-and-stability-avoiding-the-most-costly-mistakes-234c)

### 5.3 Conform Views to Equatable for Diffing

**Impact: HIGH (replaces reflection-based diffing with fast equality check)**

When a view conforms to Equatable, SwiftUI uses your equality implementation instead of reflection-based diffing. This is faster for complex views.

**Incorrect (reflection-based diffing):**

```swift
struct MessageRow: View {
    let message: Message
    let isSelected: Bool
    let onTap: () -> Void  // Closure prevents automatic Equatable

    var body: some View {
        HStack {
            Avatar(url: message.sender.avatarURL)
            VStack(alignment: .leading) {
                Text(message.sender.name)
                Text(message.preview)
            }
        }
        .background(isSelected ? Color.accentColor.opacity(0.1) : .clear)
        .onTapGesture(perform: onTap)
    }
}
// SwiftUI must reflect over all properties each time
```

**Correct (Equatable conformance):**

```swift
struct MessageRow: View, Equatable {
    let message: Message
    let isSelected: Bool
    let onTap: () -> Void

    static func == (lhs: MessageRow, rhs: MessageRow) -> Bool {
        lhs.message.id == rhs.message.id &&
        lhs.message.updatedAt == rhs.message.updatedAt &&
        lhs.isSelected == rhs.isSelected
        // Intentionally ignore onTap closure
    }

    var body: some View {
        HStack {
            Avatar(url: message.sender.avatarURL)
            VStack(alignment: .leading) {
                Text(message.sender.name)
                Text(message.preview)
            }
        }
        .background(isSelected ? Color.accentColor.opacity(0.1) : .clear)
        .onTapGesture(perform: onTap)
    }
}

// Usage with .equatable() modifier
List(messages) { message in
    MessageRow(
        message: message,
        isSelected: selectedID == message.id,
        onTap: { selectedID = message.id }
    )
    .equatable()  // Tells SwiftUI to use Equatable
}
```

**When to use Equatable:**
- Views with closures (callbacks, actions)
- Views with complex nested data
- List/grid rows that update frequently
- Views where you want to control what triggers updates

**Note:** For simple value-type-only views, SwiftUI's automatic diffing is usually sufficient.

Reference: [EquatableView Documentation](https://developer.apple.com/documentation/swiftui/equatableview)

### 5.4 Extract Subviews for Composition

**Impact: HIGH (reduces body complexity, enables SwiftUI diffing optimization)**

Large view bodies hurt performance and readability. Extract logical sections into separate views. SwiftUI can then diff smaller units efficiently.

**Incorrect (monolithic 200-line body):**

```swift
struct ProfileView: View {
    let user: User

    var body: some View {
        ScrollView {
            VStack {
                // Header section - 30 lines
                ZStack {
                    Image(user.coverPhoto)
                    VStack {
                        AsyncImage(url: user.avatarURL)
                        Text(user.name)
                        Text(user.bio)
                        // ... more header code
                    }
                }

                // Stats section - 40 lines
                HStack {
                    VStack {
                        Text("\(user.followers)")
                        Text("Followers")
                    }
                    // ... more stats
                }

                // Posts section - 50 lines
                ForEach(user.posts) { post in
                    // ... complex post layout
                }

                // ... 80 more lines
            }
        }
    }
}
```

**Correct (composed from subviews):**

```swift
struct ProfileView: View {
    let user: User

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ProfileHeader(user: user)
                ProfileStats(user: user)
                ProfilePostsGrid(posts: user.posts)
            }
        }
    }
}

struct ProfileHeader: View {
    let user: User

    var body: some View {
        ZStack(alignment: .bottom) {
            CoverImage(url: user.coverPhotoURL)
            AvatarWithName(user: user)
        }
    }
}

struct ProfileStats: View {
    let user: User

    var body: some View {
        HStack(spacing: 32) {
            StatItem(value: user.followers, label: "Followers")
            StatItem(value: user.following, label: "Following")
            StatItem(value: user.posts.count, label: "Posts")
        }
    }
}
```

**Benefits:**
- Each view has a single responsibility
- SwiftUI diffs smaller view trees
- Easier to test individual components
- Promotes reuse across screens

**Extraction guidelines:**
- Extract when a section exceeds 30-40 lines
- Extract repeated patterns immediately
- Group by semantic meaning, not arbitrary line counts

Reference: [Airbnb SwiftUI Performance](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896)

### 5.5 Prefer Value Types for View Data

**Impact: HIGH (enables automatic diffing and prevents reference-related bugs)**

Pass structs and enums to views, not classes. SwiftUI's diffing works best with value types, and you avoid reference-related state bugs.

**Incorrect (passing class instances):**

```swift
class TodoItem {  // Reference type
    var title: String
    var isCompleted: Bool

    init(title: String, isCompleted: Bool) {
        self.title = title
        self.isCompleted = isCompleted
    }
}

struct TodoRow: View {
    let item: TodoItem  // Reference - mutations don't trigger updates

    var body: some View {
        HStack {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
            Text(item.title)
        }
    }
}
```

**Correct (value types):**

```swift
struct TodoItem: Identifiable {  // Value type
    let id: UUID
    var title: String
    var isCompleted: Bool
}

struct TodoRow: View {
    let item: TodoItem  // Value - SwiftUI detects changes

    var body: some View {
        HStack {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
            Text(item.title)
        }
    }
}
```

**When you need reference semantics, use @Observable:**

```swift
@Observable
class AppState {  // Shared mutable state
    var currentUser: User?
    var settings: Settings = .default
}

struct SettingsView: View {
    @Bindable var appState: AppState  // @Bindable for @Observable classes

    var body: some View {
        Toggle("Dark Mode", isOn: $appState.settings.darkModeEnabled)
    }
}
```

**Model design pattern:**

```swift
// Domain models as value types
struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
}

// App state as @Observable class
@Observable
class UserStore {
    var users: [User] = []
    var selectedUserID: UUID?

    var selectedUser: User? {
        users.first { $0.id == selectedUserID }
    }
}
```

Reference: [SwiftUI Data Flow](https://matteomanferdini.com/swiftui-data-flow/)

### 5.6 Use @ViewBuilder for Flexible Composition

**Impact: HIGH (enables container views and conditional content)**

@ViewBuilder lets you create container views that accept arbitrary content, just like SwiftUI's built-in VStack and HStack.

**Incorrect (limited single-view parameter):**

```swift
struct Card: View {
    let content: AnyView  // Type erased, inflexible

    var body: some View {
        content
            .padding()
            .background(.background.secondary)
            .cornerRadius(12)
    }
}

// Usage is awkward
Card(content: AnyView(Text("Hello")))
```

**Correct (@ViewBuilder for flexible content):**

```swift
struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(.background.secondary)
            .cornerRadius(12)
    }
}

// Usage is natural
Card {
    VStack(alignment: .leading) {
        Text("Title")
            .font(.headline)
        Text("Description")
            .font(.body)
    }
}
```

**@ViewBuilder in computed properties:**

```swift
struct ConditionalContent: View {
    let showDetails: Bool

    var body: some View {
        VStack {
            header
            mainContent
        }
    }

    @ViewBuilder
    private var header: some View {
        if showDetails {
            DetailedHeader()
        } else {
            CompactHeader()
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        Text("Main content")
        if showDetails {
            Text("Additional details")
        }
    }
}
```

**Container with multiple slots:**

```swift
struct PageLayout<Header: View, Content: View, Footer: View>: View {
    let header: Header
    let content: Content
    let footer: Footer

    init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            content.frame(maxHeight: .infinity)
            footer
        }
    }
}
```

Reference: [ViewBuilder Documentation](https://developer.apple.com/documentation/swiftui/viewbuilder)

---

## 6. Animation & Haptics

**Impact: MEDIUM-HIGH**

Spring physics, haptic feedback, and smooth transitions create the polished native feel that users expect from Apple-quality apps.

### 6.1 Add Haptic Feedback for Interactions

**Impact: MEDIUM-HIGH (reinforces UI actions with tactile confirmation)**

Haptics provide tactile confirmation of actions. Use them for selection changes, success/error states, and significant interactions.

**Incorrect (no tactile feedback):**

```swift
struct RatingView: View {
    @State private var rating = 0

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .onTapGesture {
                        rating = star  // Silent, no feedback
                    }
            }
        }
    }
}
```

**Correct (haptic on selection):**

```swift
struct RatingView: View {
    @State private var rating = 0

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(star <= rating ? .yellow : .gray)
                    .onTapGesture {
                        rating = star
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
            }
        }
    }
}
```

**Haptic types:**

```swift
// Impact - physical collision feel
UIImpactFeedbackGenerator(style: .light).impactOccurred()   // Subtle tap
UIImpactFeedbackGenerator(style: .medium).impactOccurred()  // Button press
UIImpactFeedbackGenerator(style: .heavy).impactOccurred()   // Strong impact

// Selection - scrolling through options
UISelectionFeedbackGenerator().selectionChanged()

// Notification - success/warning/error
UINotificationFeedbackGenerator().notificationOccurred(.success)
UINotificationFeedbackGenerator().notificationOccurred(.warning)
UINotificationFeedbackGenerator().notificationOccurred(.error)
```

**Best practices:**

```swift
struct HapticButton: View {
    let action: () -> Void

    var body: some View {
        Button("Submit") {
            // Prepare generator for lower latency
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()

            action()
            generator.impactOccurred()
        }
    }
}
```

**When to use haptics:**
- Toggle/switch changes: .light impact
- Button confirmations: .medium impact
- Destructive actions: .warning notification
- Success states: .success notification
- Picker selection: .selectionChanged
- Pull to refresh trigger: .medium impact

Reference: [Human Interface Guidelines - Haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)

### 6.2 Animate Loading and Empty States

**Impact: MEDIUM-HIGH (provides visual feedback during async operations)**

Use skeleton screens and subtle animations instead of spinners. They reduce perceived wait time and maintain layout stability.

**Incorrect (spinner blocks content):**

```swift
struct ArticleView: View {
    @State private var article: Article?
    @State private var isLoading = true

    var body: some View {
        if isLoading {
            ProgressView()  // Generic, loses context
        } else if let article {
            ArticleContent(article: article)
        }
    }
}
```

**Correct (skeleton maintains layout):**

```swift
struct ArticleView: View {
    @State private var article: Article?
    @State private var isLoading = true

    var body: some View {
        if isLoading {
            ArticleSkeleton()  // Same layout as content
        } else if let article {
            ArticleContent(article: article)
        }
    }
}

struct ArticleSkeleton: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(.gray.opacity(0.3))
                .frame(height: 24)
                .frame(maxWidth: .infinity)

            // Subtitle placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(.gray.opacity(0.3))
                .frame(height: 16)
                .frame(width: 200)

            // Body placeholders
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.3))
                    .frame(height: 14)
            }
        }
        .opacity(isAnimating ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.8).repeatForever(), value: isAnimating)
        .onAppear { isAnimating = true }
    }
}
```

**Redacted modifier (iOS 14+):**

```swift
struct ArticleView: View {
    let article: Article?

    var body: some View {
        ArticleContent(article: article ?? .placeholder)
            .redacted(reason: article == nil ? .placeholder : [])
    }
}
```

**Shimmer effect:**

```swift
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.5), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}
```

Reference: [Human Interface Guidelines - Loading](https://developer.apple.com/design/human-interface-guidelines/loading)

### 6.3 Make Animations Gesture-Driven

**Impact: MEDIUM-HIGH (creates interactive, responsive feel)**

Gesture-driven animations respond to user input in real-time. The view follows the finger, then settles into place when released.

**Incorrect (toggle-based, not interactive):**

```swift
struct DismissibleCard: View {
    @State private var isDismissed = false

    var body: some View {
        CardContent()
            .offset(x: isDismissed ? 300 : 0)
            .onTapGesture {
                withAnimation { isDismissed = true }  // Not draggable
            }
    }
}
```

**Correct (gesture-driven with spring settle):**

```swift
struct DismissibleCard: View {
    @State private var offset: CGFloat = 0
    @State private var isDismissed = false

    var body: some View {
        CardContent()
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation.width  // Follow finger
                    }
                    .onEnded { gesture in
                        let threshold: CGFloat = 100
                        if gesture.translation.width > threshold {
                            // Dismiss with velocity
                            withAnimation(.spring()) {
                                offset = 500
                                isDismissed = true
                            }
                        } else {
                            // Snap back
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
    }
}
```

**Sheet-like drag to dismiss:**

```swift
struct InteractiveSheet: View {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack { /* content */ }
            .offset(y: max(0, dragOffset))
            .gesture(
                DragGesture()
                    .onChanged { dragOffset = $0.translation.height }
                    .onEnded { gesture in
                        if gesture.translation.height > 150 ||
                           gesture.predictedEndTranslation.height > 300 {
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    }
            )
    }
}
```

**Using predictedEndTranslation for natural feel:**

```swift
// Consider velocity, not just position
if gesture.predictedEndTranslation.height > 300 {
    dismiss()  // User flicked quickly
}
```

Reference: [Human Interface Guidelines - Gestures](https://developer.apple.com/design/human-interface-guidelines/gestures)

### 6.4 Use matchedGeometryEffect for Shared Transitions

**Impact: MEDIUM-HIGH (creates fluid hero transitions between views)**

matchedGeometryEffect creates smooth transitions where elements appear to move between different views, like Apple's Photos app.

**Incorrect (abrupt appearance):**

```swift
struct PhotoGallery: View {
    @State private var selectedPhoto: Photo?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(photos) { photo in
                    PhotoThumbnail(photo: photo)
                        .onTapGesture { selectedPhoto = photo }
                }
            }
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            PhotoDetail(photo: photo)  // Appears from nowhere
        }
    }
}
```

**Correct (matched geometry transition):**

```swift
struct PhotoGallery: View {
    @State private var selectedPhoto: Photo?
    @Namespace private var animation

    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(photos) { photo in
                        if selectedPhoto != photo {
                            PhotoThumbnail(photo: photo)
                                .matchedGeometryEffect(id: photo.id, in: animation)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedPhoto = photo
                                    }
                                }
                        }
                    }
                }
            }

            if let photo = selectedPhoto {
                PhotoDetail(photo: photo)
                    .matchedGeometryEffect(id: photo.id, in: animation)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedPhoto = nil
                        }
                    }
            }
        }
    }
}
```

**Key requirements:**
1. Same `id` on both source and destination views
2. Same `@Namespace` shared between views
3. Wrap state change in `withAnimation`
4. Only one view with the ID visible at a time

**Card expansion example:**

```swift
struct ExpandableCardList: View {
    @State private var expandedID: UUID?
    @Namespace private var cardAnimation

    var body: some View {
        ForEach(cards) { card in
            CardView(card: card, isExpanded: expandedID == card.id)
                .matchedGeometryEffect(id: card.id, in: cardAnimation)
                .onTapGesture {
                    withAnimation(.spring(response: 0.4)) {
                        expandedID = expandedID == card.id ? nil : card.id
                    }
                }
        }
    }
}
```

Reference: [matchedGeometryEffect Documentation](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:))

### 6.5 Use Semantic Transitions for Appearing Views

**Impact: MEDIUM-HIGH (creates contextual enter/exit animations)**

When views are inserted or removed, use `.transition()` to define how they animate. Choose transitions that match the spatial context.

**Incorrect (abrupt insertion):**

```swift
struct AlertBanner: View {
    @Binding var isVisible: Bool
    let message: String

    var body: some View {
        if isVisible {
            Text(message)
                .padding()
                .background(.red)
                // No transition - just pops in
        }
    }
}
```

**Correct (slide from edge):**

```swift
struct AlertBanner: View {
    @Binding var isVisible: Bool
    let message: String

    var body: some View {
        if isVisible {
            Text(message)
                .padding()
                .background(.red)
                .cornerRadius(8)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// Trigger with animation
withAnimation(.spring()) {
    showBanner = true
}
```

**Built-in transitions:**

```swift
.transition(.opacity)           // Fade in/out
.transition(.scale)             // Grow/shrink from center
.transition(.slide)             // Slide from leading edge
.transition(.move(edge: .top))  // Slide from specific edge
.transition(.push(from: .trailing))  // Push like navigation

// Combine transitions
.transition(.opacity.combined(with: .scale))
.transition(.asymmetric(insertion: .scale, removal: .opacity))
```

**Common patterns:**

```swift
// Toast notification (from bottom)
.transition(.move(edge: .bottom).combined(with: .opacity))

// Modal overlay
.transition(.opacity)

// Side panel
.transition(.move(edge: .trailing))

// Action sheet items
.transition(.scale.combined(with: .opacity))

// List item
.transition(.slide)
```

**Custom transition:**

```swift
extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
```

Reference: [Animations Documentation](https://developer.apple.com/documentation/swiftui/animations)

### 6.6 Use Spring Animations as Default

**Impact: MEDIUM-HIGH (creates natural, iOS-native motion feel)**

Spring animations are the iOS default. They feel natural because they simulate physical motion. Use them instead of linear or easeIn/Out.

**Incorrect (mechanical easing):**

```swift
struct ExpandableCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            Text("Header")
            if isExpanded {
                Text("Details...")
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {  // Mechanical feel
                isExpanded.toggle()
            }
        }
    }
}
```

**Correct (spring physics):**

```swift
struct ExpandableCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            Text("Header")
            if isExpanded {
                Text("Details...")
            }
        }
        .onTapGesture {
            withAnimation(.spring()) {  // Natural, bouncy feel
                isExpanded.toggle()
            }
        }
    }
}
```

**Spring presets:**

```swift
.spring()        // Default, balanced (response: 0.5, dampingFraction: 0.825)
.smooth          // No bounce, smooth settle
.snappy          // Quick, minimal bounce
.bouncy          // Playful, noticeable bounce

// Custom spring
.spring(response: 0.3, dampingFraction: 0.6)
// response: duration-like (lower = faster)
// dampingFraction: 0 = infinite bounce, 1 = no bounce
```

**When to use each:**

| Animation | Use Case |
|-----------|----------|
| .spring() | General UI transitions |
| .smooth | Scroll position, subtle changes |
| .snappy | Button feedback, quick actions |
| .bouncy | Fun interactions, achievements |
| .easeOut | One-way exits (dismiss, fade out) |

**Implicit animation:**

```swift
Circle()
    .frame(width: isLarge ? 100 : 50)
    .animation(.spring(), value: isLarge)  // Animates when isLarge changes
```

Reference: [WWDC23: Animate with Springs](https://developer.apple.com/videos/play/wwdc2023/10158/)

---

## 7. Accessibility

**Impact: MEDIUM-HIGH**

VoiceOver, Dynamic Type, and system colors are not optional. Accessibility support is required for App Store quality and reaches 15%+ of users.

### 7.1 Add Accessibility Labels to Interactive Elements

**Impact: MEDIUM-HIGH (enables VoiceOver users to understand controls)**

VoiceOver reads accessibility labels to describe UI elements. Without them, users hear unhelpful descriptions like "button" or "image".

**Incorrect (no labels):**

```swift
struct SocialActions: View {
    var body: some View {
        HStack {
            Button { like() } label: {
                Image(systemName: "heart")  // VoiceOver: "heart, button"
            }
            Button { share() } label: {
                Image(systemName: "square.and.arrow.up")  // Unhelpful
            }
            Button { bookmark() } label: {
                Image(systemName: "bookmark")  // "bookmark, button"
            }
        }
    }
}
```

**Correct (descriptive labels):**

```swift
struct SocialActions: View {
    let isLiked: Bool
    let isBookmarked: Bool

    var body: some View {
        HStack {
            Button { like() } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
            }
            .accessibilityLabel(isLiked ? "Unlike" : "Like")

            Button { share() } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .accessibilityLabel("Share")

            Button { bookmark() } label: {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
            }
            .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Add bookmark")
        }
    }
}
```

**Common accessibility modifiers:**

```swift
Image("profile-photo")
    .accessibilityLabel("Profile photo of \(user.name)")

Button("X") { dismiss() }
    .accessibilityLabel("Close")
    .accessibilityHint("Dismisses this screen")

Slider(value: $volume)
    .accessibilityValue("\(Int(volume * 100)) percent")

TextField("Search", text: $query)
    .accessibilityLabel("Search recipes")
```

**Hiding decorative elements:**

```swift
// Decorative images don't need VoiceOver
Image("decorative-divider")
    .accessibilityHidden(true)

// Group related elements
VStack {
    Image(systemName: "star.fill")
    Text("4.5")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Rating: 4.5 stars")
```

Reference: [Human Interface Guidelines - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)

### 7.2 Ensure Minimum Touch Target Size

**Impact: MEDIUM-HIGH (Apple requires 44×44pt minimum for accessibility)**

Apple's HIG requires interactive elements to be at least 44×44 points. Smaller targets are hard to tap, especially for users with motor impairments.

**Incorrect (tiny touch target):**

```swift
struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.caption)  // Only ~16pt, too small
        }
    }
}
```

**Correct (expanded touch target):**

```swift
struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.body)
                .frame(width: 44, height: 44)  // Minimum touch target
        }
    }
}
```

**Using contentShape for custom hit areas:**

```swift
struct CompactRow: View {
    let item: Item
    let action: () -> Void

    var body: some View {
        HStack {
            Text(item.title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)  // Visual padding
        .contentShape(Rectangle())  // Entire row is tappable
        .frame(minHeight: 44)  // Minimum height
        .onTapGesture(perform: action)
    }
}
```

**Spacing between targets:**

```swift
struct ActionBar: View {
    var body: some View {
        HStack(spacing: 8) {  // Minimum 8pt between targets
            ForEach(actions) { action in
                Button { } label: {
                    Image(systemName: action.icon)
                        .frame(width: 44, height: 44)
                }
            }
        }
    }
}
```

**Common violations to avoid:**
- Icon buttons without frame expansion
- Dense toolbars with < 8pt spacing
- Small checkboxes or radio buttons
- Text links without padding

**Testing with accessibility inspector:**

```swift
// Accessibility inspector shows touch target sizes
// Xcode > Open Developer Tool > Accessibility Inspector
```

Reference: [Human Interface Guidelines - Touch Targets](https://developer.apple.com/design/human-interface-guidelines/accessibility#Touch-targets)

### 7.3 Maintain Sufficient Color Contrast

**Impact: MEDIUM-HIGH (4.5:1 contrast ratio required for WCAG compliance)**

Text must have sufficient contrast against its background. WCAG requires 4.5:1 for normal text and 3:1 for large text (18pt+).

**Incorrect (insufficient contrast):**

```swift
struct LowContrastLabel: View {
    var body: some View {
        Text("Important info")
            .foregroundColor(.gray)  // ~3:1 ratio on white
            .background(.white)
    }
}

struct SubtleButton: View {
    var body: some View {
        Text("Tap here")
            .foregroundColor(Color(white: 0.7))  // Light gray on white
    }
}
```

**Correct (accessible contrast):**

```swift
struct AccessibleLabel: View {
    var body: some View {
        Text("Important info")
            .foregroundStyle(.secondary)  // System color ensures contrast
    }
}

struct AccessibleButton: View {
    var body: some View {
        Button("Tap here") { }
            .foregroundStyle(.accentColor)  // Designed for contrast
    }
}
```

**System colors automatically handle contrast:**

```swift
// These adapt to light/dark mode with proper contrast
.primary      // Black/White - highest contrast
.secondary    // ~60% opacity - 4.5:1 minimum
.tertiary     // ~30% opacity - use sparingly
.accentColor  // Tinted, always meets contrast

// Be careful with custom colors
Color("CustomGray")  // Must verify contrast in both modes
```

**Testing contrast:**

```swift
// Use Accessibility Inspector to check contrast ratios
// Or online tools like webaim.org/resources/contrastchecker

// Preview in increased contrast mode
#Preview {
    ContentView()
        .environment(\.accessibilityContrast, .increased)
}
```

**Don't rely on color alone:**

```swift
// Wrong: only color indicates error
TextField("Email", text: $email)
    .foregroundColor(hasError ? .red : .primary)

// Right: icon + color + text
VStack(alignment: .leading) {
    TextField("Email", text: $email)
    if hasError {
        Label("Invalid email format", systemImage: "exclamationmark.circle")
            .foregroundStyle(.red)
            .font(.caption)
    }
}
```

Reference: [Human Interface Guidelines - Color and Contrast](https://developer.apple.com/design/human-interface-guidelines/color#Contrast)

### 7.4 Respect Reduce Motion Preference

**Impact: MEDIUM-HIGH (prevents motion sickness for vestibular disorder users)**

Users with vestibular disorders can enable "Reduce Motion" in Settings. Respect this by simplifying or removing animations.

**Incorrect (ignoring reduce motion):**

```swift
struct BouncyButton: View {
    @State private var isPressed = false

    var body: some View {
        Button("Tap Me") { }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
            // Always bounces, even with Reduce Motion enabled
    }
}
```

**Correct (respecting preference):**

```swift
struct BouncyButton: View {
    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button("Tap Me") { }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(reduceMotion ? .none : .spring(), value: isPressed)
    }
}
```

**Alternative animations for reduce motion:**

```swift
struct AnimatedView: View {
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        if isVisible {
            ContentView()
                .transition(reduceMotion ? .opacity : .slide)
        }
    }
}
```

**Using withAnimation conditionally:**

```swift
func toggle() {
    if reduceMotion {
        isExpanded.toggle()  // Instant change
    } else {
        withAnimation(.spring()) {
            isExpanded.toggle()
        }
    }
}
```

**Animation wrapper:**

```swift
extension View {
    func conditionalAnimation<V: Equatable>(
        _ animation: Animation?,
        value: V,
        reduceMotion: Bool
    ) -> some View {
        self.animation(reduceMotion ? nil : animation, value: value)
    }
}
```

**What to simplify with Reduce Motion:**
- Replace sliding/bouncing with fades
- Remove parallax effects
- Disable auto-playing animations
- Reduce transition durations
- Use crossfades instead of spatial transitions

Reference: [Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/motion#Reducing-motion)

### 7.5 Support Dynamic Type for All Text

**Impact: MEDIUM-HIGH (25%+ of users adjust text size settings)**

Dynamic Type lets users scale text system-wide. Your app must adapt layouts to accommodate larger text without breaking.

**Incorrect (fixed sizes break at larger settings):**

```swift
struct ProfileHeader: View {
    let user: User

    var body: some View {
        HStack {
            Avatar(url: user.avatarURL)
                .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.system(size: 18))  // Fixed, won't scale
                Text(user.bio)
                    .font(.system(size: 14))  // Fixed
            }
        }
    }
}
```

**Correct (semantic fonts that scale):**

```swift
struct ProfileHeader: View {
    let user: User
    @Environment(\.dynamicTypeSize) var typeSize

    var body: some View {
        layout {
            Avatar(url: user.avatarURL)
                .frame(width: avatarSize, height: avatarSize)
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)  // Scales automatically
                Text(user.bio)
                    .font(.subheadline)  // Scales automatically
            }
        }
    }

    // Switch to vertical layout at large text sizes
    @ViewBuilder
    var layout: some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 12) { content }
        } else {
            HStack(spacing: 16) { content }
        }
    }

    var avatarSize: CGFloat {
        typeSize.isAccessibilitySize ? 80 : 60
    }
}
```

**Using ScaledMetric for custom values:**

```swift
struct CustomCard: View {
    @ScaledMetric(relativeTo: .body) var iconSize = 24
    @ScaledMetric(relativeTo: .body) var spacing = 12

    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: "star")
                .frame(width: iconSize, height: iconSize)
            Text("Favorite")
        }
    }
}
```

**Limiting scaling for specific elements:**

```swift
Text("Price")
    .font(.caption)
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)  // Cap at accessibility1
```

**Testing tip:**

```swift
// Preview at different sizes
#Preview {
    ProfileHeader(user: .preview)
        .environment(\.dynamicTypeSize, .accessibility3)
}
```

Reference: [Supporting Dynamic Type](https://developer.apple.com/documentation/swiftui/dynamictypesize)

---

## 8. Lists & Scroll Performance

**Impact: MEDIUM**

LazyVStack vs List selection, 120fps scrolling, and view body optimization ensure smooth performance even with large datasets.

### 8.1 Profile SwiftUI with Instruments

**Impact: MEDIUM (reduces optimization time by 5-10× by targeting actual bottlenecks)**

Don't guess at performance issues. Use Instruments to identify actual bottlenecks in view body execution, re-renders, and layout.

**Incorrect (guessing at performance issues):**

```swift
struct ProductList: View {
    let products: [Product]

    var body: some View {
        // "This feels slow, let me add memoization everywhere"
        List(products) { product in
            ProductRow(product: product)
        }
        // Random optimizations without measuring
        // May not address the actual problem
    }
}
```

**Correct (profile then optimize):**

```swift
struct ProductList: View {
    let products: [Product]

    var body: some View {
        let _ = Self._printChanges()  // Debug: see why body runs

        List(products) { product in
            ProductRow(product: product)
        }
        // 1. Profile with Instruments (Cmd+I)
        // 2. Find actual bottleneck
        // 3. Fix specific issue
        // 4. Verify improvement
    }
}
```

**Instruments setup:**

1. Profile in Release mode (Cmd+I or Product > Profile)
2. Select "SwiftUI" template (Instruments 26+)
3. Or use "Time Profiler" + "SwiftUI View Body" instruments

**Common issues and solutions:**

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| Body runs on every frame | Animation on parent | Extract animated view |
| 100+ body calls per second | State at wrong level | Move state down |
| Slow single body | Expensive computation | Cache or move to model |
| Memory growth | Unbounded list | Use LazyVStack |

**Best practice:** Profile before and after optimization to verify improvements.

Reference: [WWDC25: Optimize SwiftUI Performance](https://developer.apple.com/videos/play/wwdc2025/306/)

### 8.2 Use AsyncImage for Remote Images

**Impact: MEDIUM (automatic caching, placeholder, and error handling)**

AsyncImage (iOS 15+) handles image loading with built-in placeholder, error states, and caching. No need for third-party libraries for basic use cases.

**Incorrect (manual image loading):**

```swift
struct AvatarView: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
            } else {
                ProgressView()
            }
        }
        .task {
            // Manual loading, no caching, no error handling
            let (data, _) = try? await URLSession.shared.data(from: url)
            if let data { image = UIImage(data: data) }
        }
    }
}
```

**Correct (AsyncImage with states):**

```swift
struct AvatarView: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.secondary)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 50, height: 50)
        .clipShape(Circle())
    }
}
```

**Simplified syntax with placeholder:**

```swift
AsyncImage(url: user.avatarURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    Color.gray.opacity(0.3)
}
.frame(width: 50, height: 50)
.clipShape(Circle())
```

**With transition:**

```swift
AsyncImage(url: url, transaction: Transaction(animation: .easeIn)) { phase in
    switch phase {
    case .success(let image):
        image.resizable()
    default:
        Color.gray.opacity(0.3)
    }
}
```

**For complex caching needs, consider:**
- Kingfisher
- Nuke
- SDWebImage

But for most apps, AsyncImage is sufficient.

Reference: [AsyncImage Documentation](https://developer.apple.com/documentation/swiftui/asyncimage)

### 8.3 Use drawingGroup for Complex Graphics

**Impact: MEDIUM (renders complex views to Metal texture, 5-10× faster)**

When rendering complex shapes, gradients, or many overlapping views, `drawingGroup()` flattens them into a single Metal texture. This dramatically improves performance.

**Incorrect (each element rendered separately):**

```swift
struct ParticleEffect: View {
    let particles: [Particle]

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color.gradient)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .blur(radius: 2)
            }
        }
        // 500 particles = 500 separate render passes
    }
}
```

**Correct (flattened to single texture):**

```swift
struct ParticleEffect: View {
    let particles: [Particle]

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color.gradient)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .blur(radius: 2)
            }
        }
        .drawingGroup()  // Renders to single Metal texture
    }
}
```

**Good candidates for drawingGroup:**
- Particle systems
- Complex gradients
- Many overlapping shapes
- Path-heavy visualizations
- Charts with many data points

**Not recommended for:**
- Simple views (overhead not worth it)
- Views with text (can reduce text quality)
- Views needing high-quality scaling
- Interactive elements (breaks hit testing inside)

**Combining with compositingGroup:**

```swift
ZStack {
    // Background layers
    ForEach(layers) { layer in
        layer.view
    }
}
.compositingGroup()  // Groups for blending
.drawingGroup()      // Renders to texture
```

**Measuring impact:**

```swift
// Use Instruments > Core Animation
// Look for "Offscreen-Rendered" layers
// drawingGroup should reduce render passes
```

Reference: [drawingGroup Documentation](https://developer.apple.com/documentation/swiftui/view/drawinggroup(opaque:colormode:))

### 8.4 Use Lazy Containers for Large Collections

**Impact: MEDIUM (loads only visible items, reduces memory by 90%+)**

Lazy containers (LazyVStack, LazyHStack, LazyVGrid) only create views for items currently on screen. Non-lazy containers create all views immediately.

**Incorrect (VStack loads all 1000 items):**

```swift
struct MessageHistory: View {
    let messages: [Message]  // 1000+ messages

    var body: some View {
        ScrollView {
            VStack {
                ForEach(messages) { message in
                    MessageRow(message: message)  // All 1000 created immediately
                }
            }
        }
    }
}
```

**Correct (LazyVStack loads on demand):**

```swift
struct MessageHistory: View {
    let messages: [Message]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(messages) { message in
                    MessageRow(message: message)  // Only visible rows created
                }
            }
        }
    }
}
```

**Memory comparison:**
- VStack with 1000 rows: ~1000 views in memory
- LazyVStack with 1000 rows: ~20 views in memory (visible + buffer)

**Lazy grid for galleries:**

```swift
struct PhotoGallery: View {
    let photos: [Photo]

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(photos) { photo in
                    AsyncImage(url: photo.thumbnailURL)
                        .aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }
}
```

**When NOT to use Lazy:**
- Small, fixed collections (< 20 items)
- When you need simultaneous animations
- When using `.id()` modifier (can break lazy loading)

**Combining with pagination:**

```swift
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
    }

    if hasMoreItems {
        ProgressView()
            .onAppear { loadMoreItems() }
    }
}
```

Reference: [Creating Performant Scrollable Stacks](https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks)

### 8.5 Use task Modifier for Async Work

**Impact: MEDIUM (automatic cancellation when view disappears)**

The `.task` modifier runs async work when a view appears and automatically cancels it when the view disappears. This prevents memory leaks and wasted work.

**Incorrect (onAppear doesn't cancel):**

```swift
struct ArticleView: View {
    let articleID: String
    @State private var article: Article?

    var body: some View {
        content
            .onAppear {
                Task {
                    // This task continues even if view disappears
                    article = try? await fetchArticle(articleID)
                }
            }
    }
}
```

**Correct (task auto-cancels):**

```swift
struct ArticleView: View {
    let articleID: String
    @State private var article: Article?

    var body: some View {
        content
            .task {
                // Automatically cancelled if view disappears
                article = try? await fetchArticle(articleID)
            }
    }
}
```

**task with id for re-fetching:**

```swift
struct ArticleView: View {
    let articleID: String
    @State private var article: Article?

    var body: some View {
        content
            .task(id: articleID) {
                // Re-runs when articleID changes
                // Previous task is cancelled
                article = try? await fetchArticle(articleID)
            }
    }
}
```

**Handling cancellation:**

```swift
.task {
    do {
        article = try await fetchArticle(articleID)
    } catch is CancellationError {
        // View disappeared, task was cancelled
        // No action needed
    } catch {
        // Actual error
        self.error = error
    }
}
```

**Multiple async operations:**

```swift
.task {
    async let articles = fetchArticles()
    async let user = fetchUser()

    // Both cancelled if view disappears
    self.articles = try? await articles
    self.user = try? await user
}
```

**When to use onAppear instead:**
- Synchronous work
- Fire-and-forget analytics
- UI state setup (focus, scroll position)

Reference: [task(priority:_:) Documentation](https://developer.apple.com/documentation/swiftui/view/task(priority:_:))

---

## 9. Platform Integration

**Impact: MEDIUM**

SF Symbols, Dark Mode, system features, and platform conventions create apps that feel native and integrate seamlessly with iOS.

### 9.1 Design for Widget and Live Activity Integration

**Impact: MEDIUM (enables 40% more daily user touchpoints via home screen)**

Widgets and Live Activities extend your app beyond the main interface. Design shared components and data models that work across both.

**Incorrect (duplicate code for widget):**

```swift
// Main app
struct WorkoutProgressView: View {
    let workout: Workout

    var body: some View {
        VStack {
            Text("\(workout.elapsedTime.formatted())")
            Text("\(workout.caloriesBurned) cal")
        }
    }
}

// Widget - completely separate implementation
struct WorkoutWidgetView: View {
    let entry: WorkoutEntry

    var body: some View {
        // Duplicated layout logic
        // Different data model
        // Inconsistent appearance
        VStack {
            Text("\(entry.time)")
            Text("\(entry.calories)")
        }
    }
}
```

**Correct (shared components via App Group):**

```swift
// Shared framework
struct WorkoutProgress: Codable {
    let elapsedTime: TimeInterval
    let caloriesBurned: Int
}

struct WorkoutProgressView: View {
    let progress: WorkoutProgress
    @Environment(\.widgetFamily) var family  // nil in main app

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                CompactView(progress: progress)
            default:
                FullView(progress: progress)
            }
        }
    }
}

// Works in both app and widget
// Single source of truth for layout
```

**Share data via App Group:**

```swift
extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.app.fitness")!
}

// Main app writes
UserDefaults.shared.set(encoded, forKey: "workout")

// Widget reads
let workout = UserDefaults.shared.data(forKey: "workout")
```

**Updating widgets:**

```swift
// Refresh widget timeline
WidgetCenter.shared.reloadAllTimelines()
```

**Design considerations:**
- Widgets are read-only snapshots
- Use `.containerBackground()` for backgrounds
- Keep text concise - widgets are glanceable
- Deep link to relevant app sections

Reference: [Human Interface Guidelines - Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)

### 9.2 Integrate System Features Natively

**Impact: MEDIUM (reduces code by 50-80% vs custom implementations)**

Use system-provided UI for sharing, photo picking, and contacts. Users trust familiar interfaces, and you get automatic updates.

**Incorrect (custom share implementation):**

```swift
struct ArticleView: View {
    let article: Article
    @State private var showingCustomShare = false

    var body: some View {
        Button("Share") { showingCustomShare = true }
            .sheet(isPresented: $showingCustomShare) {
                // Custom share UI
                VStack {
                    Button("Copy Link") { /* ... */ }
                    Button("Twitter") { /* ... */ }
                    Button("Facebook") { /* ... */ }
                    // Missing: AirDrop, Messages, Mail, Notes...
                    // Must maintain every share destination
                }
            }
    }
}
```

**Correct (system ShareLink):**

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        ShareLink(item: article.url, subject: Text(article.title)) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        // All share destinations included
        // Updated automatically by iOS
    }
}
```

**Photo picker (iOS 16+):**

```swift
struct ProfileEditor: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: Image?

    var body: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            if let avatarImage {
                avatarImage.resizable().frame(width: 100, height: 100)
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
            }
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    avatarImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}
```

**Benefits of system UI:**
- Familiar to users, builds trust
- Automatically updated with iOS
- Handles permissions and privacy
- Consistent accessibility support

Reference: [Human Interface Guidelines - System Features](https://developer.apple.com/design/human-interface-guidelines/)

### 9.3 Respond to App Lifecycle with ScenePhase

**Impact: MEDIUM (save state, pause work, refresh on foreground)**

ScenePhase tells you when your app moves between active, inactive, and background states. Use it to save state and manage resources.

**Incorrect (not responding to lifecycle):**

```swift
struct GameView: View {
    @State private var gameState: GameState

    var body: some View {
        GameBoard(state: gameState)
        // Game continues running when app is backgrounded
        // State lost if terminated
    }
}
```

**Correct (handling lifecycle):**

```swift
struct GameView: View {
    @State private var gameState: GameState
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GameBoard(state: gameState)
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    resumeGame()
                case .inactive:
                    pauseGame()
                case .background:
                    saveGameState()
                @unknown default:
                    break
                }
            }
    }

    private func saveGameState() {
        // Persist to disk before termination
        try? JSONEncoder().encode(gameState).write(to: saveURL)
    }
}
```

**Scene phases:**

```swift
.active      // App is in foreground and interactive
.inactive    // App is visible but not interactive (e.g., during app switcher)
.background  // App is not visible
```

**Common use cases:**

```swift
.onChange(of: scenePhase) { _, phase in
    switch phase {
    case .active:
        // Refresh data that might be stale
        refreshContent()
        // Resume timers
        timer.resume()

    case .inactive:
        // Pause video/audio
        player.pause()
        // Stop animations
        isAnimating = false

    case .background:
        // Save unsaved changes
        saveDocument()
        // Cancel non-essential network requests
        networkManager.cancelPendingRequests()
        // Clear sensitive data from memory
        clearCachedCredentials()

    @unknown default:
        break
    }
}
```

**App-level vs View-level:**

```swift
@main
struct MyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, phase in
            // App-wide lifecycle handling
        }
    }
}
```

Reference: [ScenePhase Documentation](https://developer.apple.com/documentation/swiftui/scenephase)

### 9.4 Use AppStorage for User Preferences

**Impact: MEDIUM (automatic persistence and SwiftUI integration)**

@AppStorage wraps UserDefaults with SwiftUI reactivity. Changes persist automatically and trigger view updates.

**Incorrect (manual UserDefaults):**

```swift
struct SettingsView: View {
    @State private var darkModeEnabled: Bool

    init() {
        _darkModeEnabled = State(initialValue: UserDefaults.standard.bool(forKey: "darkMode"))
    }

    var body: some View {
        Toggle("Dark Mode", isOn: $darkModeEnabled)
            .onChange(of: darkModeEnabled) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "darkMode")  // Manual sync
            }
    }
}
```

**Correct (AppStorage):**

```swift
struct SettingsView: View {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false

    var body: some View {
        Toggle("Dark Mode", isOn: $darkModeEnabled)
        // Automatically persisted to UserDefaults
    }
}
```

**Supported types:**

```swift
@AppStorage("username") var username = ""           // String
@AppStorage("itemCount") var itemCount = 0          // Int
@AppStorage("price") var price = 0.0                // Double
@AppStorage("isEnabled") var isEnabled = false      // Bool
@AppStorage("selectedTab") var selectedTab: Tab = .home  // RawRepresentable
@AppStorage("lastOpened") var lastOpened: Date?     // Optional with nil default
```

**Custom app group for sharing:**

```swift
// Share between app and widget
@AppStorage("streak", store: UserDefaults(suiteName: "group.com.app.shared"))
var streak = 0
```

**Enum storage with RawRepresentable:**

```swift
enum Theme: String, CaseIterable {
    case system, light, dark
}

struct AppearanceSettings: View {
    @AppStorage("theme") private var theme: Theme = .system

    var body: some View {
        Picker("Theme", selection: $theme) {
            ForEach(Theme.allCases, id: \.self) { theme in
                Text(theme.rawValue.capitalized)
            }
        }
    }
}
```

**When NOT to use AppStorage:**
- Large data (use FileManager or Core Data)
- Sensitive data (use Keychain)
- Complex objects (use Codable + file storage)

Reference: [AppStorage Documentation](https://developer.apple.com/documentation/swiftui/appstorage)

### 9.5 Use SF Symbols for Consistent Iconography

**Impact: MEDIUM (6900+ icons that scale with text and adapt to context)**

SF Symbols are Apple's icon system. They automatically scale with Dynamic Type, adapt to weight, and support multiple rendering modes.

**Incorrect (custom image assets):**

```swift
struct ActionButton: View {
    var body: some View {
        Button {
            share()
        } label: {
            Image("share-icon")  // Custom asset, doesn't scale
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
}
```

**Correct (SF Symbols):**

```swift
struct ActionButton: View {
    var body: some View {
        Button {
            share()
        } label: {
            Image(systemName: "square.and.arrow.up")  // Scales automatically
        }
    }
}
```

**Symbol configuration:**

```swift
// Weight matches text weight
Image(systemName: "star.fill")
    .fontWeight(.semibold)

// Size matches text style
Image(systemName: "heart")
    .font(.title)

// Explicit size with scaling
Image(systemName: "gear")
    .imageScale(.large)  // .small, .medium, .large
```

**Rendering modes:**

```swift
// Monochrome (default) - single color
Image(systemName: "cloud.sun.fill")
    .foregroundStyle(.blue)

// Hierarchical - automatic depth
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.blue)

// Palette - custom colors per layer
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.palette)
    .foregroundStyle(.gray, .yellow)

// Multicolor - Apple's designed colors
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.multicolor)
```

**Symbol variants:**

```swift
// Fill variant
Image(systemName: "heart.fill")

// Slash variant (disabled state)
Image(systemName: "bell.slash")

// Badge variant
Image(systemName: "app.badge")

// Using symbolVariant modifier
Image(systemName: "heart")
    .symbolVariant(.fill)
```

**Finding symbols:** Use SF Symbols app (free from Apple) to browse all 6900+ symbols.

Reference: [SF Symbols Documentation](https://developer.apple.com/sf-symbols/)

---

## References

1. [https://developer.apple.com/design/human-interface-guidelines/](https://developer.apple.com/design/human-interface-guidelines/)
2. [https://developer.apple.com/documentation/swiftui](https://developer.apple.com/documentation/swiftui)
3. [https://developer.apple.com/videos/play/wwdc2025/256/](https://developer.apple.com/videos/play/wwdc2025/256/)
4. [https://developer.apple.com/videos/play/wwdc2025/306/](https://developer.apple.com/videos/play/wwdc2025/306/)
5. [https://developer.apple.com/videos/play/wwdc2023/10158/](https://developer.apple.com/videos/play/wwdc2023/10158/)
6. [https://developer.apple.com/sf-symbols/](https://developer.apple.com/sf-symbols/)
7. [https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896)
8. [https://fatbobman.com/en/](https://fatbobman.com/en/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |