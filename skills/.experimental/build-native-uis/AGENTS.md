# Best Practices

**Version 0.1.0**
Apple
February 2026

> **Note:** This document is mainly for agents and LLMs to follow when maintaining, generating, or refactoring SwiftUI codebases.
> Humans may also find it useful, but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive SwiftUI interface development guide extracted from Apple's official Develop in Swift Tutorials and SwiftUI Concepts. Contains 49 rules across 10 categories, prioritized by impact from critical (view composition, layout) to incremental (polish and refinement). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact descriptions to guide AI-assisted SwiftUI code generation and refactoring.

---

## Table of Contents

1. [View Composition](#1-view-composition) — **CRITICAL**
   - 1.1 [Apply Modifiers in Correct Order](#11-apply-modifiers-in-correct-order)
   - 1.2 [Extract Subviews to Reduce Body Complexity](#12-extract-subviews-to-reduce-body-complexity)
   - 1.3 [Prefer Composition Over Inheritance for Views](#13-prefer-composition-over-inheritance-for-views)
   - 1.4 [Return some View from body Property](#14-return-some-view-from-body-property)
   - 1.5 [Use #Preview for Live Development Feedback](#15-use-preview-for-live-development-feedback)
   - 1.6 [Use @ViewBuilder for Conditional View Content](#16-use-viewbuilder-for-conditional-view-content)
   - 1.7 [Use Properties to Make Views Configurable](#17-use-properties-to-make-views-configurable)
2. [Layout & Sizing](#2-layout--sizing) — **CRITICAL**
   - 2.1 [Configure Stack Alignment and Spacing](#21-configure-stack-alignment-and-spacing)
   - 2.2 [Use Frame() for Explicit Size Constraints](#22-use-frame-for-explicit-size-constraints)
   - 2.3 [Use Grid for Aligned Tabular Layouts](#23-use-grid-for-aligned-tabular-layouts)
   - 2.4 [Use LazyVGrid for Scrollable Grid Layouts](#24-use-lazyvgrid-for-scrollable-grid-layouts)
   - 2.5 [Use Spacer to Push Views Apart](#25-use-spacer-to-push-views-apart)
   - 2.6 [Use Stacks Instead of Manual Positioning](#26-use-stacks-instead-of-manual-positioning)
   - 2.7 [Use ZStack for Layered View Composition](#27-use-zstack-for-layered-view-composition)
3. [Styling & Theming](#3-styling--theming) — **HIGH**
   - 3.1 [Apply Gradients for Visual Depth](#31-apply-gradients-for-visual-depth)
   - 3.2 [Use foregroundStyle Over Deprecated foregroundColor](#32-use-foregroundstyle-over-deprecated-foregroundcolor)
   - 3.3 [Use Semantic Font Styles for Typography](#33-use-semantic-font-styles-for-typography)
   - 3.4 [Use SF Symbols for Platform-Consistent Icons](#34-use-sf-symbols-for-platform-consistent-icons)
   - 3.5 [Use System Colors for Automatic Dark Mode](#35-use-system-colors-for-automatic-dark-mode)
4. [State & Data Flow](#4-state--data-flow) — **HIGH**
   - 4.1 [Mark @State Properties as Private](#41-mark-state-properties-as-private)
   - 4.2 [Use @Bindable to Create Bindings from Observable Objects](#42-use-bindable-to-create-bindings-from-observable-objects)
   - 4.3 [Use @Binding for Two-Way Data Flow to Child Views](#43-use-binding-for-two-way-data-flow-to-child-views)
   - 4.4 [Use @Environment for System and Shared Values](#44-use-environment-for-system-and-shared-values)
   - 4.5 [Use @Observable for Shared Model Classes](#45-use-observable-for-shared-model-classes)
   - 4.6 [Use @State for View-Local Value Types](#46-use-state-for-view-local-value-types)
5. [Navigation & Presentation](#5-navigation--presentation) — **HIGH**
   - 5.1 [Manage Navigation State with Path Binding](#51-manage-navigation-state-with-path-binding)
   - 5.2 [Place Actions in Toolbar for Consistent Placement](#52-place-actions-in-toolbar-for-consistent-placement)
   - 5.3 [Use NavigationStack for Hierarchical Navigation](#53-use-navigationstack-for-hierarchical-navigation)
   - 5.4 [Use Sheets for Modal Presentation](#54-use-sheets-for-modal-presentation)
   - 5.5 [Use TabView for Top-Level App Sections](#55-use-tabview-for-top-level-app-sections)
6. [Lists & Dynamic Content](#6-lists--dynamic-content) — **MEDIUM-HIGH**
   - 6.1 [Add Swipe Actions for Contextual Operations](#61-add-swipe-actions-for-contextual-operations)
   - 6.2 [Use ForEach for Dynamic Content in Containers](#62-use-foreach-for-dynamic-content-in-containers)
   - 6.3 [Use List with Identifiable Data](#63-use-list-with-identifiable-data)
   - 6.4 [Use searchable for Built-In Search](#64-use-searchable-for-built-in-search)
7. [User Input & Interaction](#7-user-input--interaction) — **MEDIUM-HIGH**
   - 7.1 [Use Button with Action Closures](#71-use-button-with-action-closures)
   - 7.2 [Use Picker for Single-Value Selection](#72-use-picker-for-single-value-selection)
   - 7.3 [Use TextField with Binding for Text Input](#73-use-textfield-with-binding-for-text-input)
   - 7.4 [Use Toggle and Form for Settings Interfaces](#74-use-toggle-and-form-for-settings-interfaces)
8. [Accessibility & Adaptivity](#8-accessibility--adaptivity) — **MEDIUM**
   - 8.1 [Add Accessibility Labels to Interactive Elements](#81-add-accessibility-labels-to-interactive-elements)
   - 8.2 [Support Dynamic Type for All Text](#82-support-dynamic-type-for-all-text)
   - 8.3 [Use @ScaledMetric for Size-Adaptive Values](#83-use-scaledmetric-for-size-adaptive-values)
   - 8.4 [Use ViewThatFits for Adaptive Layouts](#84-use-viewthatfits-for-adaptive-layouts)
9. [Testing & Debugging](#9-testing--debugging) — **MEDIUM**
   - 9.1 [Use Breakpoints to Debug Runtime Issues](#91-use-breakpoints-to-debug-runtime-issues)
   - 9.2 [Use Preview with Sample Data for Visual Testing](#92-use-preview-with-sample-data-for-visual-testing)
   - 9.3 [Write Tests with Swift Testing Framework](#93-write-tests-with-swift-testing-framework)
10. [App Polish & Refinement](#10-app-polish--refinement) — **LOW**
    - 10.1 [Add Inclusive Features for Broader Reach](#101-add-inclusive-features-for-broader-reach)
    - 10.2 [Apply Transition Effects for View Insertion and Removal](#102-apply-transition-effects-for-view-insertion-and-removal)
    - 10.3 [Use withAnimation for State-Driven Transitions](#103-use-withanimation-for-state-driven-transitions)

---

## 1. View Composition

**Impact: CRITICAL**

Views are the fundamental building blocks of SwiftUI interfaces. Incorrect composition — bloated body properties, wrong modifier order, missing view extraction — cascades into layout bugs, performance issues, and unmaintainable code.

### 1.1 Apply Modifiers in Correct Order

**Impact: CRITICAL (modifier order changes visual output, each modifier wraps the previous view)**

Each SwiftUI modifier wraps the view that precedes it, producing a new view. This means `.background()` before `.padding()` paints behind the content only, while `.padding()` before `.background()` paints behind the content plus its padding. Getting this wrong produces layouts that look subtly broken and are hard to debug.

**Incorrect (background applied before padding, shadow before clip):**

```swift
struct NotificationBadge: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .background(Color.red) // background hugs text, padding added outside
            .padding(12)
            .shadow(radius: 8) // shadow renders on square corners
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
    }
}
```

**Correct (padding then background, clip then shadow):**

```swift
struct NotificationBadge: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(12) // content sizing first
            .background(Color.red) // fills padded area
            .clipShape(RoundedRectangle(cornerRadius: 12)) // clip before shadow
            .shadow(radius: 8) // shadow follows clipped shape
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 1.2 Extract Subviews to Reduce Body Complexity

**Impact: CRITICAL (reduces body from 50+ lines to 5-10, improves readability and reuse)**

A bloated `body` property makes it difficult to reason about layout, slows down Xcode previews, and prevents reuse of UI sections. Extracting logical sections into dedicated child views keeps each component focused and testable in isolation.

**Incorrect (entire profile screen in a single body):**

```swift
struct ProfileScreen: View {
    let username: String
    let bio: String
    let followerCount: Int
    let postCount: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.blue)
                Text(username)
                    .font(.title2).bold()
                Text(bio)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                HStack(spacing: 32) {
                    VStack {
                        Text("\(followerCount)")
                            .font(.headline)
                        Text("Followers")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    VStack {
                        Text("\(postCount)")
                            .font(.headline)
                        Text("Posts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}
```

**Correct (body delegates to extracted child views):**

```swift
struct ProfileScreen: View {
    let username: String
    let bio: String
    let followerCount: Int
    let postCount: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ProfileAvatar()
                ProfileInfo(username: username, bio: bio)
                ProfileStats(followerCount: followerCount, postCount: postCount)
            }
            .padding()
        }
    }
}

struct ProfileAvatar: View {
    var body: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 80, height: 80)
            .foregroundStyle(.blue)
    }
}

struct ProfileInfo: View {
    let username: String
    let bio: String

    var body: some View {
        VStack(spacing: 4) {
            Text(username)
                .font(.title2).bold()
            Text(bio)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct ProfileStats: View {
    let followerCount: Int
    let postCount: Int

    var body: some View {
        HStack(spacing: 32) {
            StatColumn(value: "\(followerCount)", label: "Followers")
            StatColumn(value: "\(postCount)", label: "Posts")
        }
    }
}

struct StatColumn: View { // reusable across screens
    let value: String
    let label: String

    var body: some View {
        VStack {
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 1.3 Prefer Composition Over Inheritance for Views

**Impact: CRITICAL (SwiftUI views are structs, composition is the only extensibility pattern)**

SwiftUI views are value-type structs, not classes, so subclassing is not available. Attempting class-based inheritance patterns leads to compiler errors or fragile workarounds that fight the framework. The idiomatic approach is to compose smaller views together and use `ViewModifier` to share cross-cutting styling.

**Incorrect (class-based thinking, trying to inherit from a base view):**

```swift
class BaseCard: View { // structs cannot be subclassed
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

class EventCard: BaseCard { // cannot inherit from a struct
    let date: Date

    override var body: some View {
        VStack(alignment: .leading) {
            super.body
            Text(date, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

**Correct (compose structs and use ViewModifier for shared styling):**

```swift
struct CardStyle: ViewModifier { // shared styling extracted once
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct BaseCard: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
        }
        .modifier(CardStyle())
    }
}

struct EventCard: View {
    let title: String
    let date: Date

    var body: some View { // compose BaseCard, don't inherit
        VStack(alignment: .leading) {
            BaseCard(title: title)
            Text(date, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 1.4 Return some View from body Property

**Impact: CRITICAL (foundation of every SwiftUI view)**

Every SwiftUI view must be a struct conforming to the `View` protocol, which requires a computed `body` property returning `some View`. Without this contract the compiler cannot participate in the declarative diffing system, and the struct is just inert data.

**Incorrect (struct without View conformance or body property):**

```swift
struct ProfileHeader {
    let username: String
    let avatarURL: URL

    func render() -> Text {
        Text(username)
            .font(.headline)
    }
}

struct SettingsRow {
    let title: String

    func display() -> some View { // no View conformance
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
        }
    }
}
```

**Correct (struct conforms to View with body property):**

```swift
struct ProfileHeader: View {
    let username: String
    let avatarURL: URL

    var body: some View { // required by View protocol
        Text(username)
            .font(.headline)
    }
}

struct SettingsRow: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 1.5 Use #Preview for Live Development Feedback

**Impact: CRITICAL (instant visual feedback reduces iteration time by 5-10x)**

Without previews, every visual change requires a full build-and-run cycle on a simulator. The `#Preview` macro renders the view directly in Xcode's canvas, giving sub-second feedback on layout and styling changes. Supplying realistic sample data in previews catches edge cases like long text and missing images before they reach QA.

**Incorrect (no preview, must build and run to see changes):**

```swift
struct OrderSummaryCard: View {
    let itemName: String
    let quantity: Int
    let priceInCents: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(itemName)
                    .font(.headline)
                Text("Qty: \(quantity)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("$\(priceInCents / 100).\(String(format: "%02d", priceInCents % 100))")
                .font(.title3).bold()
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
}

// No #Preview defined — requires simulator to verify layout
```

**Correct (previews with varied sample data for edge-case coverage):**

```swift
struct OrderSummaryCard: View {
    let itemName: String
    let quantity: Int
    let priceInCents: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(itemName)
                    .font(.headline)
                Text("Qty: \(quantity)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("$\(priceInCents / 100).\(String(format: "%02d", priceInCents % 100))")
                .font(.title3).bold()
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
}

#Preview("Standard Item") {
    OrderSummaryCard(itemName: "Wireless Charger", quantity: 1, priceInCents: 2999)
        .padding()
}

#Preview("Long Name & High Qty") { // catches truncation and layout overflow
    OrderSummaryCard(itemName: "Ultra-Premium Noise-Cancelling Headphones Pro Max", quantity: 150, priceInCents: 34999)
        .padding()
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 1.6 Use @ViewBuilder for Conditional View Content

**Impact: CRITICAL (enables conditional and dynamic view composition without type erasure)**

Wrapping views in `AnyView` to handle conditionals erases static type information, which disables SwiftUI's diffing optimizations and causes unnecessary view identity resets. `@ViewBuilder` lets the compiler preserve concrete types through conditional branches, keeping animations and state intact.

**Incorrect (AnyView erases type information, breaks diffing):**

```swift
struct MembershipBanner: View {
    let isPremium: Bool
    let memberName: String

    var body: some View {
        bannerContent()
    }

    func bannerContent() -> some View {
        if isPremium {
            return AnyView( // type erasure on every branch
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text("\(memberName) — Premium Member")
                        .font(.headline)
                }
                .padding()
                .background(Color.indigo.opacity(0.15))
                .clipShape(Capsule())
            )
        } else {
            return AnyView(
                Text("\(memberName) — Free Tier")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            )
        }
    }
}
```

**Correct (@ViewBuilder preserves type information and diffing):**

```swift
struct MembershipBanner: View {
    let isPremium: Bool
    let memberName: String

    var body: some View {
        bannerContent
    }

    @ViewBuilder // compiler tracks concrete types per branch
    var bannerContent: some View {
        if isPremium {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.yellow)
                Text("\(memberName) — Premium Member")
                    .font(.headline)
            }
            .padding()
            .background(Color.indigo.opacity(0.15))
            .clipShape(Capsule())
        } else {
            Text("\(memberName) — Free Tier")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 1.7 Use Properties to Make Views Configurable

**Impact: CRITICAL (enables reuse across the app, prevents duplication)**

Hardcoding text, colors, and images inside a view creates a one-off component that must be duplicated whenever the same layout is needed with different content. Exposing stored properties turns a view into a reusable template that call sites can configure, eliminating copy-paste drift.

**Incorrect (hardcoded content makes the view single-use):**

```swift
struct FeatureCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "star.fill")
                .font(.title)
                .foregroundStyle(.yellow)
            Text("Premium Feature")
                .font(.headline)
            Text("Unlock advanced analytics and reporting tools.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

**Correct (properties make the view reusable across screens):**

```swift
struct FeatureCard: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundStyle(iconColor)
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Call sites configure each instance
FeatureCard(
    iconName: "star.fill",
    iconColor: .yellow,
    title: "Premium Feature",
    description: "Unlock advanced analytics and reporting tools."
)

FeatureCard(
    iconName: "lock.shield",
    iconColor: .green,
    title: "Secure Storage",
    description: "End-to-end encrypted file storage for your team."
)
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

---

## 2. Layout & Sizing

**Impact: CRITICAL**

Stack containers, Grid, LazyVGrid, Spacer, and frame modifiers determine how views arrange on screen. Wrong layout choices cause broken UIs across device sizes and orientations.

### 2.1 Configure Stack Alignment and Spacing

**Impact: CRITICAL (default centering and spacing rarely match design specs)**

VStack defaults to center alignment and system-standard spacing, which almost never matches design specifications for form-like layouts. Labels and fields end up centered instead of left-aligned, and the vertical rhythm feels off. Explicitly setting alignment and spacing ensures the layout matches the design from the start and stays consistent across platforms.

**Incorrect (default centering misaligns form labels and fields):**

```swift
struct ContactFormView: View {
    @State private var fullName = ""
    @State private var emailAddress = ""
    @State private var phoneNumber = ""

    var body: some View {
        VStack { // defaults to .center alignment and system spacing
            Text("Contact Information")
                .font(.title2)
            Text("Full Name")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your name", text: $fullName)
                .textFieldStyle(.roundedBorder)
            Text("Email Address")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your email", text: $emailAddress)
                .textFieldStyle(.roundedBorder)
            Text("Phone Number")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your phone", text: $phoneNumber)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}
```

**Correct (explicit alignment and spacing match design specs):**

```swift
struct ContactFormView: View {
    @State private var fullName = ""
    @State private var emailAddress = ""
    @State private var phoneNumber = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // left-aligned with consistent rhythm
            Text("Contact Information")
                .font(.title2)
                .padding(.bottom, 4)
            Text("Full Name")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your name", text: $fullName)
                .textFieldStyle(.roundedBorder)
            Text("Email Address")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your email", text: $emailAddress)
                .textFieldStyle(.roundedBorder)
            Text("Phone Number")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Enter your phone", text: $phoneNumber)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 2.2 Use Frame() for Explicit Size Constraints

**Impact: CRITICAL (frame modifiers set ideal, minimum, and maximum sizes for precise layout control)**

Without explicit size constraints, views shrink to fit their content or expand unpredictably. Buttons may become too small to tap reliably, and text containers may overflow their intended bounds. The `frame()` modifier lets you set minimum, ideal, and maximum dimensions so views meet tap-target requirements and respect layout boundaries across all content sizes.

**Incorrect (no size constraints make button too small to tap reliably):**

```swift
struct ActionButtonBar: View {
    let primaryLabel: String
    let secondaryLabel: String

    var body: some View {
        HStack(spacing: 12) {
            Button(primaryLabel) {
                // handle primary action
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4) // tap target too small at 30pt height
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Button(secondaryLabel) {
                // handle secondary action
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
```

**Correct (frame constraints ensure minimum tap targets and flexible width):**

```swift
struct ActionButtonBar: View {
    let primaryLabel: String
    let secondaryLabel: String

    var body: some View {
        HStack(spacing: 12) {
            Button(primaryLabel) {
                // handle primary action
            }
            .frame(minWidth: 120, maxWidth: .infinity, minHeight: 44) // 44pt minimum for accessibility
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Button(secondaryLabel) {
                // handle secondary action
            }
            .frame(minWidth: 120, maxWidth: .infinity, minHeight: 44)
            .background(Color.secondary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal)
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 2.3 Use Grid for Aligned Tabular Layouts

**Impact: CRITICAL (Grid automatically aligns columns across rows, eliminating manual width calculations)**

Building table-like layouts with nested HStacks requires manually matching widths across rows, which breaks when content length changes or dynamic type is enabled. The `Grid` container automatically sizes each column to fit the widest cell, keeping all rows aligned without any hardcoded dimensions. This is the right tool for settings screens, data tables, and any row-column layout.

**Incorrect (hardcoded widths break when content or text size changes):**

```swift
struct SystemInfoView: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Device")
                    .frame(width: 100, alignment: .leading) // breaks with longer labels
                Text("iPhone 15 Pro")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text("Storage")
                    .frame(width: 100, alignment: .leading)
                Text("256 GB")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text("Battery Health")
                    .frame(width: 100, alignment: .leading) // truncated at larger text sizes
                Text("98%")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text("OS Version")
                    .frame(width: 100, alignment: .leading)
                Text("iOS 18.2")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}
```

**Correct (Grid auto-sizes columns to the widest cell in each column):**

```swift
struct SystemInfoView: View {
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
            GridRow {
                Text("Device")
                    .foregroundStyle(.secondary)
                Text("iPhone 15 Pro") // column width adapts to longest value
            }
            GridRow {
                Text("Storage")
                    .foregroundStyle(.secondary)
                Text("256 GB")
            }
            GridRow {
                Text("Battery Health")
                    .foregroundStyle(.secondary)
                Text("98%")
            }
            GridRow {
                Text("OS Version")
                    .foregroundStyle(.secondary)
                Text("iOS 18.2")
            }
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 2.4 Use LazyVGrid for Scrollable Grid Layouts

**Impact: CRITICAL (lazy grids create views on demand, handling thousands of items without memory spikes)**

Building grids from nested HStacks inside a VStack creates every single view upfront, regardless of whether it is on screen. For a gallery with hundreds or thousands of items, this consumes excessive memory and causes visible frame drops on scroll. LazyVGrid only instantiates views that are currently visible, keeping memory flat and scrolling smooth.

**Incorrect (nested stacks create all views upfront, causing memory spikes):**

```swift
struct PhotoGalleryView: View {
    let photoAssets: [PhotoAsset]

    var body: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(0..<(photoAssets.count / 3), id: \.self) { rowIndex in
                    HStack(spacing: 4) {
                        ForEach(0..<3) { columnIndex in
                            let index = rowIndex * 3 + columnIndex
                            if index < photoAssets.count {
                                AsyncImage(url: photoAssets[index].thumbnailURL)
                                    .frame(width: 120, height: 120) // hardcoded, won't adapt
                                    .clipped()
                            }
                        }
                    }
                }
            }
        }
    }
}
```

**Correct (LazyVGrid creates views on demand with adaptive columns):**

```swift
struct PhotoGalleryView: View {
    let photoAssets: [PhotoAsset]

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 4) // adapts column count to screen width
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(photoAssets) { photoAsset in
                    AsyncImage(url: photoAsset.thumbnailURL)
                        .frame(minHeight: 100)
                        .clipped()
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 2.5 Use Spacer to Push Views Apart

**Impact: CRITICAL (Spacer expands to fill available space, enabling flexible layouts without hardcoded sizes)**

Hardcoded padding or offset values to push views apart are fragile -- they break across screen sizes and orientations. Spacer is a flexible view that expands to fill all available space along the stack's axis, automatically distributing content to edges or between elements. This produces layouts that stay correct regardless of device dimensions.

**Incorrect (hardcoded padding breaks on different screen widths):**

```swift
struct ToolbarView: View {
    let documentTitle: String

    var body: some View {
        HStack {
            Button(action: { }) {
                Image(systemName: "chevron.left")
            }
            Text(documentTitle)
                .font(.headline)
                .padding(.leading, 90) // fragile: only looks centered on one screen width
            Button(action: { }) {
                Image(systemName: "square.and.arrow.up")
            }
            .padding(.leading, 80)
        }
        .padding()
    }
}
```

**Correct (Spacer fills available space to distribute views):**

```swift
struct ToolbarView: View {
    let documentTitle: String

    var body: some View {
        HStack {
            Button(action: { }) {
                Image(systemName: "chevron.left")
            }
            Spacer() // pushes title to center
            Text(documentTitle)
                .font(.headline)
            Spacer() // pushes action button to trailing edge
            Button(action: { }) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 2.6 Use Stacks Instead of Manual Positioning

**Impact: CRITICAL (stacks adapt to all screen sizes, manual positioning breaks on different devices)**

Manual positioning with `.position()` and `.offset()` uses hardcoded coordinates that only work on a single screen size. When the device changes, text overlaps, elements clip off-screen, and the layout collapses. Stacks compose views relative to each other, so the layout adapts automatically to any screen size or dynamic type setting.

**Incorrect (hardcoded positions break on different screen sizes):**

```swift
struct ProfileCardView: View {
    let userName: String
    let userRole: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 4)
            Image(systemName: "person.circle.fill")
                .font(.system(size: 48))
                .position(x: 60, y: 50) // breaks on smaller screens
            Text(userName)
                .font(.headline)
                .position(x: 200, y: 35)
            Text(userRole)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .position(x: 200, y: 60)
        }
        .frame(height: 100)
    }
}
```

**Correct (stacks adapt to any screen size automatically):**

```swift
struct ProfileCardView: View {
    let userName: String
    let userRole: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 48))
            VStack(alignment: .leading, spacing: 4) {
                Text(userName)
                    .font(.headline)
                Text(userRole)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 4)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 2.7 Use ZStack for Layered View Composition

**Impact: CRITICAL (ZStack layers views front-to-back, enabling overlays, badges, and background effects)**

Attempting to layer views using chained `.overlay()` modifiers quickly becomes unreadable and hard to control when you need alignment, padding, or multiple overlapping elements. ZStack provides a dedicated container for layered composition where each child is a peer view, making the stacking order explicit and alignment straightforward.

**Incorrect (chained overlays become unreadable with multiple layers):**

```swift
struct FeaturedCardView: View {
    let imageName: String
    let cardTitle: String
    let cardSubtitle: String

    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 200)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
            .overlay(
                VStack(alignment: .leading) {
                    Spacer()
                    Text(cardTitle).font(.title2).bold()
                    Text(cardSubtitle).font(.subheadline)
                }
                .foregroundStyle(.white)
                .padding(), alignment: .bottomLeading // easy to misplace
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

**Correct (ZStack makes layer order and alignment explicit):**

```swift
struct FeaturedCardView: View {
    let imageName: String
    let cardTitle: String
    let cardSubtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) { // single alignment for all layers
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)

            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(cardTitle).font(.title2).bold()
                Text(cardSubtitle).font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

---

## 3. Styling & Theming

**Impact: HIGH**

System colors, SF Symbols, gradients, fonts, and material backgrounds ensure visual consistency and platform integration. Hardcoded values break dark mode and accessibility.

### 3.1 Apply Gradients for Visual Depth

**Impact: HIGH (gradients create visual hierarchy and polish with minimal code)**

Flat solid color backgrounds can appear lifeless and make it harder for users to distinguish interactive elements from decorative surfaces. SwiftUI provides `LinearGradient`, `RadialGradient`, and `AngularGradient` that work directly with system colors and conform to `ShapeStyle`, enabling rich visual depth in a single modifier.

**Incorrect (flat solid color with no visual depth):**

```swift
struct PromotionBanner: View {
    let headline: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(headline)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.blue) // flat, no visual depth
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

**Correct (gradient background that adds visual hierarchy):**

```swift
struct PromotionBanner: View {
    let headline: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(headline)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background( // gradient creates visual depth and directionality
            LinearGradient(
                colors: [.blue, .indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 3.2 Use foregroundStyle Over Deprecated foregroundColor

**Impact: HIGH (foregroundStyle supports hierarchical styles and ShapeStyle, foregroundColor is deprecated)**

The `.foregroundColor(_:)` modifier is deprecated in favor of `.foregroundStyle(_:)`, which accepts any `ShapeStyle` including gradients, hierarchical styles, and semantic colors. Continuing to use the deprecated API means losing access to the richer styling system and accumulating compiler warnings across your codebase.

**Incorrect (deprecated foregroundColor modifier):**

```swift
struct TransactionRow: View {
    let merchant: String
    let amount: String
    let date: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(merchant)
                    .font(.headline)
                    .foregroundColor(.primary) // deprecated
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray) // deprecated, does not adapt semantically
            }
            Spacer()
            Text(amount)
                .font(.headline)
                .foregroundColor(.red) // deprecated
        }
        .padding(.vertical, 8)
    }
}
```

**Correct (foregroundStyle with ShapeStyle support):**

```swift
struct TransactionRow: View {
    let merchant: String
    let amount: String
    let date: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(merchant)
                    .font(.headline)
                    .foregroundStyle(.primary) // accepts any ShapeStyle
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary) // semantic hierarchical style
            }
            Spacer()
            Text(amount)
                .font(.headline)
                .foregroundStyle(.red)
        }
        .padding(.vertical, 8)
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 3.3 Use Semantic Font Styles for Typography

**Impact: HIGH (semantic fonts (.title, .headline, .body) scale with Dynamic Type automatically)**

Hardcoded font sizes with `.system(size:)` bypass Dynamic Type, preventing users who rely on larger text from reading your content. Semantic text styles like `.title`, `.headline`, and `.body` communicate typographic hierarchy to the system and scale proportionally with the user's preferred content size.

**Incorrect (hardcoded font sizes that ignore Dynamic Type):**

```swift
struct ArticleCard: View {
    let title: String
    let author: String
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 24, weight: .bold)) // fixed size, ignores Dynamic Type
            Text("By \(author)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            Text(summary)
                .font(.system(size: 16))
                .lineLimit(3)
        }
        .padding()
    }
}
```

**Correct (semantic font styles that scale with Dynamic Type):**

```swift
struct ArticleCard: View {
    let title: String
    let author: String
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2.bold()) // scales with Dynamic Type
            Text("By \(author)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text(summary)
                .font(.body) // matches user's preferred reading size
                .lineLimit(3)
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 3.4 Use SF Symbols for Platform-Consistent Icons

**Impact: HIGH (4,000+ icons that scale with Dynamic Type and match system UI)**

Custom PNG assets require multiple resolution variants, do not scale with Dynamic Type, and look out of place next to native UI elements. SF Symbols integrate seamlessly with San Francisco, the system font, automatically matching text weight, size, and accessibility settings without additional asset management.

**Incorrect (custom image assets that do not scale with text):**

```swift
struct SettingsRow: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image("custom-gear-icon") // requires 1x, 2x, 3x assets in asset catalog
                .resizable()
                .frame(width: 24, height: 24)
            Text(title)
                .font(.body)
            Spacer()
            Image("custom-chevron-right")
                .resizable()
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 8)
    }
}
```

**Correct (SF Symbols that scale with Dynamic Type):**

```swift
struct SettingsRow: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "gearshape.fill") // scales with Dynamic Type automatically
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.accentColor)
            Text(title)
                .font(.body)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary) // matches system disclosure indicator style
        }
        .padding(.vertical, 8)
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 3.5 Use System Colors for Automatic Dark Mode

**Impact: HIGH (automatic light/dark mode adaptation without conditional logic)**

Hardcoded RGB values require manual overrides for every appearance change, creating maintenance burden and accessibility issues. System colors like `Color.primary`, `Color.secondary`, and `Color.accentColor` adapt automatically to light mode, dark mode, and high-contrast settings across all Apple platforms.

**Incorrect (hardcoded RGB colors that break in dark mode):**

```swift
struct ProfileHeader: View {
    let username: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(username)
                .font(.title)
                .foregroundStyle(Color(red: 0.0, green: 0.0, blue: 0.0)) // invisible on dark backgrounds
            Text("Member since 2024")
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
            Divider()
            Button("Edit Profile") {
                // action
            }
            .tint(Color(red: 0.0, green: 0.48, blue: 1.0))
        }
        .padding()
        .background(Color(red: 1.0, green: 1.0, blue: 1.0)) // white background, no dark mode support
    }
}
```

**Correct (system colors that adapt to light and dark mode):**

```swift
struct ProfileHeader: View {
    let username: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(username)
                .font(.title)
                .foregroundStyle(.primary) // adapts to light/dark automatically
            Text("Member since 2024")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Divider()
            Button("Edit Profile") {
                // action
            }
            .tint(.accentColor)
        }
        .padding()
        .background(Color(.systemBackground)) // adapts to current appearance
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

---

## 4. State & Data Flow

**Impact: HIGH**

@State, @Binding, @Observable, @Environment, and @Bindable control how data flows through the view hierarchy. Incorrect state management causes stale UI, unnecessary rebuilds, and data loss.

### 4.1 Mark @State Properties as Private

**Impact: HIGH (prevents external mutation, state belongs to the owning view)**

`@State` properties represent a view's internal source of truth. When left non-private, parent views can set initial values through the memberwise initializer, which silently conflicts with SwiftUI's state management and causes the value to be overwritten on every parent re-render.

**Incorrect (non-private @State can be set from outside the view):**

```swift
struct ExpandableSection: View {
    @State var isExpanded = false // accessible in the memberwise initializer

    var body: some View {
        DisclosureGroup("Details", isExpanded: $isExpanded) {
            Text("Additional information about this item.")
        }
    }
}

struct ParentView: View {
    var body: some View {
        ExpandableSection(isExpanded: true) // overwrites state on every re-render
    }
}
```

**Correct (private @State prevents external mutation):**

```swift
struct ExpandableSection: View {
    @State private var isExpanded = false // only this view can mutate it

    var body: some View {
        DisclosureGroup("Details", isExpanded: $isExpanded) {
            Text("Additional information about this item.")
        }
    }
}

struct ParentView: View {
    var body: some View {
        ExpandableSection() // cannot override internal state
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 4.2 Use @Bindable to Create Bindings from Observable Objects

**Impact: HIGH (creates $ bindings for @Observable properties in forms and controls)**

SwiftUI controls like `TextField` and `Toggle` require `Binding` values, but `@Observable` objects do not automatically expose `$property` syntax in views. `@Bindable` enables the `$` prefix on an observable instance so its properties can be passed directly to controls without manual state mirroring.

**Incorrect (manual state mirroring duplicates source of truth):**

```swift
@Observable
class Book {
    var title = ""
    var isFavorite = false
}

struct BookEditView: View {
    var book: Book
    @State private var draftTitle = "" // duplicated state, easily drifts
    @State private var draftIsFavorite = false

    var body: some View {
        Form {
            TextField("Title", text: $draftTitle)
            Toggle("Favorite", isOn: $draftIsFavorite)
            Button("Save") {
                book.title = draftTitle
                book.isFavorite = draftIsFavorite
            }
        }
        .onAppear {
            draftTitle = book.title
            draftIsFavorite = book.isFavorite
        }
    }
}
```

**Correct (@Bindable creates bindings directly from the observable model):**

```swift
@Observable
class Book {
    var title = ""
    var isFavorite = false
}

struct BookEditView: View {
    @Bindable var book: Book // enables $book.property bindings

    var body: some View {
        Form {
            TextField("Title", text: $book.title)
            Toggle("Favorite", isOn: $book.isFavorite)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 4.3 Use @Binding for Two-Way Data Flow to Child Views

**Impact: HIGH (enables child views to read and write parent state without duplication)**

When a child view needs to read and modify a parent's state, passing a plain value creates a one-way copy that silently diverges. `@Binding` establishes a two-way connection so changes in the child propagate back to the source of truth in the parent.

**Incorrect (value copy does not update parent state):**

```swift
struct NotificationToggle: View {
    var isEnabled: Bool // one-way copy, parent never sees changes

    var body: some View {
        Toggle("Notifications", isOn: .constant(isEnabled))
    }
}

struct SettingsScreen: View {
    @State private var isEnabled = false

    var body: some View {
        Form {
            NotificationToggle(isEnabled: isEnabled) // passes a snapshot
        }
    }
}
```

**Correct (@Binding creates a two-way connection to parent state):**

```swift
struct NotificationToggle: View {
    @Binding var isEnabled: Bool // reads and writes the parent's state

    var body: some View {
        Toggle("Notifications", isOn: $isEnabled)
    }
}

struct SettingsScreen: View {
    @State private var isEnabled = false

    var body: some View {
        Form {
            NotificationToggle(isEnabled: $isEnabled) // passes a binding
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 4.4 Use @Environment for System and Shared Values

**Impact: HIGH (injects system settings and shared dependencies without prop drilling)**

Manually passing system values like color scheme or dismiss actions through multiple view layers creates brittle coupling and verbose initializers. `@Environment` lets any view in the hierarchy read these values directly from the SwiftUI environment, keeping view APIs clean.

**Incorrect (prop drilling system values through every layer):**

```swift
struct DetailScreen: View {
    let colorScheme: ColorScheme
    let dismiss: () -> Void

    var body: some View {
        VStack {
            Text("Detail")
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            Button("Close") {
                dismiss()
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DetailScreen(colorScheme: colorScheme, dismiss: dismiss.callAsFunction)
    }
}
```

**Correct (@Environment reads values directly from the SwiftUI environment):**

```swift
struct DetailScreen: View {
    @Environment(\.colorScheme) private var colorScheme // injected by SwiftUI
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Detail")
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            Button("Close") {
                dismiss()
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        DetailScreen() // no manual passing needed
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 4.5 Use @Observable for Shared Model Classes

**Impact: HIGH (fine-grained observation updates only views that read changed properties)**

The legacy `ObservableObject` protocol with `@Published` triggers view updates whenever any published property changes, even those the view does not read. The `@Observable` macro introduced in iOS 17 enables fine-grained tracking so only views that actually read a changed property re-render.

**Incorrect (ObservableObject re-renders all observing views on any change):**

```swift
class AppSettings: ObservableObject {
    @Published var username = ""
    @Published var notificationsEnabled = true
    @Published var fontSize = 14.0
}

struct FontSettingsView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        // re-renders when username or notificationsEnabled change too
        Stepper("Font Size: \(Int(settings.fontSize))", value: $settings.fontSize, in: 10...30)
    }
}
```

**Correct (@Observable tracks only the properties each view reads):**

```swift
@Observable
class AppSettings {
    var username = ""
    var notificationsEnabled = true
    var fontSize = 14.0
}

struct FontSettingsView: View {
    @Bindable var settings: AppSettings // enables $settings.property bindings

    var body: some View {
        // re-renders only when fontSize changes
        Stepper("Font Size: \(Int(settings.fontSize))", value: $settings.fontSize, in: 10...30)
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 4.6 Use @State for View-Local Value Types

**Impact: HIGH (enables reactive UI, SwiftUI manages storage outside the view struct)**

SwiftUI view structs are recreated frequently, so plain stored properties lose their values on every re-render. `@State` tells SwiftUI to persist and manage the storage outside the struct, triggering a view update whenever the value changes.

**Incorrect (plain var is reset on every re-render):**

```swift
struct CounterView: View {
    var tapCount = 0 // recreated as 0 on every view update

    var body: some View {
        VStack {
            Text("Taps: \(tapCount)")
            Button("Increment") {
                tapCount += 1 // compile error: cannot mutate immutable property
            }
        }
    }
}
```

**Correct (@State persists value across re-renders):**

```swift
struct CounterView: View {
    @State private var tapCount = 0 // SwiftUI manages storage outside the struct

    var body: some View {
        VStack {
            Text("Taps: \(tapCount)")
            Button("Increment") {
                tapCount += 1 // triggers a view update automatically
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

---

## 5. Navigation & Presentation

**Impact: HIGH**

NavigationStack, TabView, sheets, and programmatic navigation define user flow. Navigation must maintain state across transitions and support deep linking.

### 5.1 Manage Navigation State with Path Binding

**Impact: HIGH (enables deep linking, state restoration, and programmatic navigation)**

An uncontrolled NavigationStack provides no way to programmatically push, pop, or restore the navigation state. Binding a NavigationPath to the stack lets you drive navigation from code, support deep links, and save or restore the full stack across app launches.

**Incorrect (uncontrolled NavigationStack with no path binding):**

```swift
struct OrderListView: View {
    let orders: [Order]

    var body: some View {
        NavigationStack { // no path binding, cannot push or pop programmatically
            List(orders) { order in
                NavigationLink(value: order) {
                    OrderRow(order: order)
                }
            }
            .navigationTitle("Orders")
            .navigationDestination(for: Order.self) { order in
                OrderDetailView(order: order)
            }
        }
    }
}
```

**Correct (NavigationStack with path binding for programmatic navigation):**

```swift
struct OrderListView: View {
    let orders: [Order]
    @State private var path = NavigationPath() // controls the navigation stack

    var body: some View {
        NavigationStack(path: $path) {
            List(orders) { order in
                NavigationLink(value: order) {
                    OrderRow(order: order)
                }
            }
            .navigationTitle("Orders")
            .navigationDestination(for: Order.self) { order in
                OrderDetailView(order: order)
            }
            .toolbar {
                Button("Latest") {
                    if let latest = orders.first {
                        path.append(latest) // programmatic push
                    }
                }
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 5.2 Place Actions in Toolbar for Consistent Placement

**Impact: HIGH (toolbar adapts placement per platform (iOS navigation bar, macOS toolbar))**

Placing action buttons directly in the view body creates inconsistent positioning across devices and conflicts with scroll content. The `.toolbar` modifier places actions in the platform-appropriate location automatically -- the navigation bar on iOS, the window toolbar on macOS -- and respects system spacing and accessibility sizing.

**Incorrect (floating action buttons in the view body):**

```swift
struct DocumentListView: View {
    @State private var documents: [Document] = []

    var body: some View {
        NavigationStack {
            VStack {
                HStack { // manually placed buttons ignore platform conventions
                    Spacer()
                    Button { addDocument() } label: {
                        Image(systemName: "plus")
                    }
                    Button { toggleEditing() } label: {
                        Image(systemName: "pencil")
                    }
                }
                .padding(.horizontal)
                List(documents) { document in
                    Text(document.title)
                }
            }
            .navigationTitle("Documents")
        }
    }
}
```

**Correct (using toolbar with placement for platform-adaptive actions):**

```swift
struct DocumentListView: View {
    @State private var documents: [Document] = []

    var body: some View {
        NavigationStack {
            List(documents) { document in
                Text(document.title)
            }
            .navigationTitle("Documents")
            .toolbar {
                ToolbarItem(placement: .primaryAction) { // adapts to each platform
                    Button { addDocument() } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button { toggleEditing() } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 5.3 Use NavigationStack for Hierarchical Navigation

**Impact: HIGH (type-safe value-based navigation with automatic back button support)**

NavigationView is deprecated in iOS 16 and lacks type-safe destination routing. NavigationStack with `navigationDestination(for:)` provides value-based navigation that scales cleanly, supports programmatic control, and automatically manages the back button.

**Incorrect (using deprecated NavigationView with inline NavigationLink destinations):**

```swift
struct RecipeListView: View {
    let recipes: [Recipe]

    var body: some View {
        NavigationView { // deprecated in iOS 16
            List(recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRow(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
        }
        .navigationViewStyle(.stack)
    }
}
```

**Correct (using NavigationStack with value-based navigationDestination):**

```swift
struct RecipeListView: View {
    let recipes: [Recipe]

    var body: some View {
        NavigationStack { // replaces NavigationView
            List(recipes) { recipe in
                NavigationLink(value: recipe) { // pass value, not destination
                    RecipeRow(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 5.4 Use Sheets for Modal Presentation

**Impact: HIGH (sheets provide standard iOS modal pattern with automatic dismiss gesture)**

Pushing a creation form onto the navigation stack mixes hierarchical drill-down with modal intent, confusing the user about where they are in the app. Sheets signal a self-contained task that can be dismissed with a swipe, and they preserve the navigation stack underneath.

**Incorrect (pushing a creation form onto the navigation stack):**

```swift
struct GroceryListView: View {
    @State private var items: [GroceryItem] = []

    var body: some View {
        NavigationStack {
            List(items) { item in
                Text(item.name)
            }
            .navigationTitle("Groceries")
            .toolbar {
                NavigationLink("Add") { // pushes form onto stack as if drilling down
                    AddGroceryItemView(items: $items)
                }
            }
        }
    }
}
```

**Correct (presenting a creation form as a sheet):**

```swift
struct GroceryListView: View {
    @State private var items: [GroceryItem] = []
    @State private var isAddingItem = false

    var body: some View {
        NavigationStack {
            List(items) { item in
                Text(item.name)
            }
            .navigationTitle("Groceries")
            .toolbar {
                Button("Add") { isAddingItem = true }
            }
            .sheet(isPresented: $isAddingItem) { // modal presentation for a self-contained task
                AddGroceryItemView(items: $items)
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 5.5 Use TabView for Top-Level App Sections

**Impact: HIGH (standard iOS navigation pattern for parallel content areas)**

TabView is the standard iOS pattern for switching between independent top-level sections. Building a custom tab bar loses platform-native behavior like badge support, accessibility labels, and adaptive layout on iPad. SwiftUI's TabView handles all of this automatically.

**Incorrect (building a custom tab bar manually):**

```swift
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case 0: HomeView()
            case 1: SearchView()
            case 2: ProfileView()
            default: HomeView()
            }
            HStack { // custom tab bar loses native behavior
                Button { selectedTab = 0 } label: {
                    Label("Home", systemImage: "house")
                }
                Button { selectedTab = 1 } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
                Button { selectedTab = 2 } label: {
                    Label("Profile", systemImage: "person")
                }
            }
            .padding()
        }
    }
}
```

**Correct (using TabView with Tab items):**

```swift
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) { // native tab bar with full platform support
            Tab("Home", systemImage: "house", value: 0) {
                HomeView()
            }
            Tab("Search", systemImage: "magnifyingglass", value: 1) {
                SearchView()
            }
            Tab("Profile", systemImage: "person", value: 2) {
                ProfileView()
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

---

## 6. Lists & Dynamic Content

**Impact: MEDIUM-HIGH**

List, ForEach, and lazy containers display collections efficiently. Proper use of Identifiable, swipe actions, and searchable keeps scrolling smooth and data correct.

### 6.1 Add Swipe Actions for Contextual Operations

**Impact: MEDIUM-HIGH (standard iOS pattern for delete, archive, and other row-level actions)**

Swipe actions are the standard iOS pattern for row-level operations like delete, archive, and favorite. Embedding dedicated buttons directly inside each row clutters the visible layout and deviates from platform conventions users already know. The `.swipeActions` modifier keeps the row clean while making destructive and common actions discoverable through the familiar swipe gesture.

**Incorrect (dedicated delete button visible in each row):**

```swift
struct InboxView: View {
    @State private var messages = ["Meeting tomorrow", "Lunch plans", "Project update"]

    var body: some View {
        List {
            ForEach(messages, id: \.self) { message in
                HStack {
                    Text(message)
                    Spacer()
                    Button("Delete") { // clutters every row with a visible button
                        messages.removeAll { $0 == message }
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
}
```

**Correct (using .swipeActions for delete and favorite):**

```swift
struct InboxView: View {
    @State private var messages = ["Meeting tomorrow", "Lunch plans", "Project update"]
    @State private var favorites: Set<String> = []

    var body: some View {
        List {
            ForEach(messages, id: \.self) { message in
                Text(message)
                    .swipeActions(edge: .trailing) { // standard destructive action on trailing edge
                        Button(role: .destructive) {
                            messages.removeAll { $0 == message }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            favorites.insert(message)
                        } label: {
                            Label("Favorite", systemImage: "star")
                        }
                        .tint(.yellow)
                    }
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 6.2 Use ForEach for Dynamic Content in Containers

**Impact: MEDIUM-HIGH (ForEach generates views from collections inside any container, not just List)**

ForEach is not limited to List; it generates views from a collection inside any container like HStack, VStack, or LazyVGrid. Manually duplicating views for each item creates rigid layouts that cannot adapt when the data changes. ForEach keeps the UI in sync with the underlying collection and eliminates repetitive code.

**Incorrect (manually repeating views for each tag):**

```swift
struct TagCloudView: View {
    let tags = ["Swift", "iOS", "SwiftUI", "Xcode"]

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                Text("Swift").padding(8).background(.blue.opacity(0.2)).clipShape(Capsule())
                Text("iOS").padding(8).background(.blue.opacity(0.2)).clipShape(Capsule())
                Text("SwiftUI").padding(8).background(.blue.opacity(0.2)).clipShape(Capsule())
                Text("Xcode").padding(8).background(.blue.opacity(0.2)).clipShape(Capsule()) // breaks when tags change
            }
        }
    }
}
```

**Correct (using ForEach with collection in HStack):**

```swift
struct TagCloudView: View {
    let tags = ["Swift", "iOS", "SwiftUI", "Xcode"]

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tags, id: \.self) { tag in // generates a chip for each tag dynamically
                    Text(tag)
                        .padding(8)
                        .background(.blue.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 6.3 Use List with Identifiable Data

**Impact: MEDIUM-HIGH (Identifiable enables SwiftUI to track items for efficient diffing and animations)**

When displaying collections in a List, SwiftUI needs a stable way to identify each element so it can efficiently update only the rows that changed. Using `id: \.self` on plain strings breaks down when duplicates exist and prevents SwiftUI from animating insertions and removals correctly. Conforming your data to `Identifiable` gives each item a stable identity that survives reordering and mutation.

**Incorrect (using id: \.self on plain strings):**

```swift
struct FriendsView: View {
    @State private var friends = ["Alice", "Bob", "Charlie", "Alice"]

    var body: some View {
        List {
            ForEach(friends, id: \.self) { friend in // duplicate "Alice" causes identity conflicts
                Text(friend)
            }
        }
    }
}
```

**Correct (using Identifiable struct with List):**

```swift
struct Friend: Identifiable {
    let id = UUID() // stable identity for each item
    var name: String
}

struct FriendsView: View {
    @State private var friends = [
        Friend(name: "Alice"),
        Friend(name: "Bob"),
        Friend(name: "Charlie"),
        Friend(name: "Alice")
    ]

    var body: some View {
        List(friends) { friend in // List iterates Identifiable data directly
            Text(friend.name)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 6.4 Use searchable for Built-In Search

**Impact: MEDIUM-HIGH (system-standard search bar with automatic placement and keyboard handling)**

The `.searchable` modifier gives you a system-standard search bar that integrates with NavigationStack, handles keyboard dismissal, and follows platform conventions automatically. Building a custom TextField for search requires manually managing placement, styling, and focus behavior, and the result will look and feel inconsistent with the rest of iOS.

**Incorrect (custom TextField for search):**

```swift
struct ContactsView: View {
    @State private var searchText = ""
    let contacts = ["Alice", "Bob", "Charlie", "Diana", "Edward"]

    var filteredContacts: [String] {
        searchText.isEmpty ? contacts : contacts.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search contacts...", text: $searchText) // manual search field outside list
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                List(filteredContacts, id: \.self) { contact in
                    Text(contact)
                }
            }
            .navigationTitle("Contacts")
        }
    }
}
```

**Correct (using .searchable modifier):**

```swift
struct ContactsView: View {
    @State private var searchText = ""
    let contacts = ["Alice", "Bob", "Charlie", "Diana", "Edward"]

    var filteredContacts: [String] {
        searchText.isEmpty ? contacts : contacts.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredContacts, id: \.self) { contact in
                Text(contact)
            }
            .navigationTitle("Contacts")
            .searchable(text: $searchText) // system search bar with automatic placement
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

---

## 7. User Input & Interaction

**Impact: MEDIUM-HIGH**

TextField, Button, Picker, Toggle, and forms capture user intent. Proper input handling includes validation, keyboard management, and clear affordances.

### 7.1 Use Button with Action Closures

**Impact: MEDIUM-HIGH (Button handles tap events and provides built-in affordances like highlight and accessibility)**

Button is SwiftUI's primary interactive control. It provides built-in tap highlighting, accessibility traits, and keyboard support that `onTapGesture` does not. Using `onTapGesture` on a Text makes the element look tappable only through custom styling, offers no VoiceOver button role, and lacks the visual feedback users expect from interactive elements.

**Incorrect (Text with onTapGesture instead of Button):**

```swift
struct SaveFormView: View {
    @State private var isSaved = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Save Changes")
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture { // no highlight feedback, no accessibility button role
                    isSaved = true
                }

            if isSaved {
                Text("Changes saved!")
            }
        }
    }
}
```

**Correct (using Button with action closure):**

```swift
struct SaveFormView: View {
    @State private var isSaved = false

    var body: some View {
        VStack(spacing: 20) {
            Button { // provides tap highlight, accessibility, and keyboard support
                isSaved = true
            } label: {
                Text("Save Changes")
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if isSaved {
                Text("Changes saved!")
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 7.2 Use Picker for Single-Value Selection

**Impact: MEDIUM-HIGH (Picker adapts its style to context (wheel, menu, segmented) automatically)**

Picker provides a platform-native selection control that automatically adapts its presentation style based on context -- appearing as a menu in a Form, a wheel in a sheet, or a segmented control when explicitly styled. Building custom selection buttons requires managing highlight state, accessibility labels, and visual feedback manually, and the result will not match the native look and feel.

**Incorrect (custom buttons for selection):**

```swift
struct CategoryPickerView: View {
    @State private var selectedCategory = "Work"
    let categories = ["Work", "Personal", "Shopping", "Health"]

    var body: some View {
        Form {
            ForEach(categories, id: \.self) { category in
                Button { // manual selection with custom highlight logic
                    selectedCategory = category
                } label: {
                    HStack {
                        Text(category)
                        Spacer()
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}
```

**Correct (using Picker with ForEach and tag):**

```swift
struct CategoryPickerView: View {
    @State private var selectedCategory = "Work"
    let categories = ["Work", "Personal", "Shopping", "Health"]

    var body: some View {
        Form {
            Picker("Category", selection: $selectedCategory) { // adapts style to context automatically
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category) // tag matches the selection binding type
                }
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 7.3 Use TextField with Binding for Text Input

**Impact: MEDIUM-HIGH (TextField requires @State or @Binding for two-way text updates)**

TextField provides an editable text field that requires a two-way binding to a `@State` or `@Binding` property. Without a binding, there is no way for the user to type into the field and have the value reflected in your view's state. A plain Text view displays content but cannot accept input, which is a common mistake when transitioning from read-only to editable interfaces.

**Incorrect (Text view that cannot accept input):**

```swift
struct NameEntryForm: View {
    @State private var firstName = ""
    @State private var lastName = ""

    var body: some View {
        Form {
            Text(firstName) // displays text but user cannot type into it
            Text(lastName)
            Button("Save") {
                print("Saving \(firstName) \(lastName)")
            }
        }
    }
}
```

**Correct (TextField with $ binding for two-way updates):**

```swift
struct NameEntryForm: View {
    @State private var firstName = ""
    @State private var lastName = ""

    var body: some View {
        Form {
            TextField("First name", text: $firstName) // $ creates a two-way binding
            TextField("Last name", text: $lastName)
            Button("Save") {
                print("Saving \(firstName) \(lastName)")
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 7.4 Use Toggle and Form for Settings Interfaces

**Impact: MEDIUM-HIGH (Form provides grouped list styling, Toggle provides standard on/off control)**

Form wraps its content in a grouped list style that matches the native iOS Settings app, and Toggle provides a standard on/off switch that users instantly recognize. Building a custom switch with buttons and manual state coloring produces an inconsistent look, misses accessibility traits like the switch role, and requires extra work to replicate the grouped section styling that Form gives you for free.

**Incorrect (custom switch implementation with buttons):**

```swift
struct NotificationSettingsView: View {
    @State private var pushEnabled = true
    @State private var emailEnabled = false
    @State private var soundEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Push Notifications")
                Spacer()
                Button(pushEnabled ? "ON" : "OFF") { // custom toggle with no switch accessibility role
                    pushEnabled.toggle()
                }
                .foregroundStyle(pushEnabled ? .green : .gray)
            }
            HStack {
                Text("Email Notifications")
                Spacer()
                Button(emailEnabled ? "ON" : "OFF") {
                    emailEnabled.toggle()
                }
                .foregroundStyle(emailEnabled ? .green : .gray)
            }
            HStack {
                Text("Sound")
                Spacer()
                Button(soundEnabled ? "ON" : "OFF") {
                    soundEnabled.toggle()
                }
                .foregroundStyle(soundEnabled ? .green : .gray)
            }
        }
        .padding()
    }
}
```

**Correct (using Form with Toggle for native settings layout):**

```swift
struct NotificationSettingsView: View {
    @State private var pushEnabled = true
    @State private var emailEnabled = false
    @State private var soundEnabled = true

    var body: some View {
        Form { // provides grouped list styling matching iOS Settings
            Section("Alerts") {
                Toggle("Push Notifications", isOn: $pushEnabled)
                Toggle("Email Notifications", isOn: $emailEnabled)
            }
            Section("Preferences") {
                Toggle("Sound", isOn: $soundEnabled) // standard switch with accessibility support
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

---

## 8. Accessibility & Adaptivity

**Impact: MEDIUM**

Accessibility labels, Dynamic Type, @ScaledMetric, and VoiceOver support are required for quality apps. Adaptive layouts with ViewThatFits ensure usability across all users and devices.

### 8.1 Add Accessibility Labels to Interactive Elements

**Impact: MEDIUM (VoiceOver reads labels to screen reader users, unlabeled controls are invisible)**

VoiceOver relies on accessibility labels to describe controls to users who cannot see the screen. When an interactive element like an icon button has no label, VoiceOver either skips it entirely or reads a meaningless default like "button," leaving the user unable to interact with your app.

**Incorrect (icon button without accessibility label):**

```swift
struct ItemRow: View {
    let item: GroceryItem

    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Button(action: { deleteItem(item) }) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            Button(action: { toggleFavorite(item) }) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
            }
        }
    }
}
```

**Correct (descriptive label for each icon button):**

```swift
struct ItemRow: View {
    let item: GroceryItem

    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Button(action: { deleteItem(item) }) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .accessibilityLabel("Delete \(item.name)") // VoiceOver reads "Delete Milk"
            Button(action: { toggleFavorite(item) }) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
            }
            .accessibilityLabel("Favorite \(item.name)")
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 8.2 Support Dynamic Type for All Text

**Impact: MEDIUM (15-20% of users adjust text size, hardcoded fonts ignore their preference)**

Between 15 and 20 percent of users change their preferred text size in Settings. When you use hardcoded font sizes, your text stays fixed regardless of the user's preference, making your app difficult or impossible to read for those who need larger text.

**Incorrect (hardcoded font sizes ignore Dynamic Type):**

```swift
struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title)
                .font(.system(size: 20, weight: .bold))
            Text(recipe.author)
                .font(.system(size: 14))
            Text(recipe.description)
                .font(.system(size: 16))
        }
        .padding()
    }
}
```

**Correct (semantic fonts that scale with Dynamic Type):**

```swift
struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title)
                .font(.headline) // scales automatically with user's text size setting
            Text(recipe.author)
                .font(.subheadline)
            Text(recipe.description)
                .font(.body)
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 8.3 Use @ScaledMetric for Size-Adaptive Values

**Impact: MEDIUM (scales numeric values proportionally with Dynamic Type setting)**

Dynamic Type scales text automatically, but hardcoded spacing, padding, and icon sizes stay fixed. This creates visual imbalance when users increase their text size: large text with tiny icons or cramped padding. `@ScaledMetric` scales any numeric value proportionally with the user's Dynamic Type setting.

**Incorrect (hardcoded icon size stays fixed at all text sizes):**

```swift
struct CategoryLabel: View {
    let category: Category

    var body: some View {
        Label {
            Text(category.name)
                .font(.body)
        } icon: {
            Image(systemName: category.icon)
                .frame(width: 24, height: 24)
                .padding(6)
                .background(category.color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
```

**Correct (@ScaledMetric values grow with Dynamic Type):**

```swift
struct CategoryLabel: View {
    let category: Category
    @ScaledMetric private var iconSize: CGFloat = 24 // scales with Dynamic Type
    @ScaledMetric private var iconPadding: CGFloat = 6

    var body: some View {
        Label {
            Text(category.name)
                .font(.body)
        } icon: {
            Image(systemName: category.icon)
                .frame(width: iconSize, height: iconSize)
                .padding(iconPadding)
                .background(category.color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 8.4 Use ViewThatFits for Adaptive Layouts

**Impact: MEDIUM (automatically selects the first child view that fits available space)**

When users increase their text size or rotate to a narrow orientation, fixed horizontal layouts overflow and clip content. `ViewThatFits` evaluates each child view in order and renders the first one that fits within the available space, letting you provide graceful fallbacks without manual size calculations.

**Incorrect (fixed horizontal layout overflows with large text):**

```swift
struct EventActions: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            Button("Accept") { acceptEvent(event) }
                .buttonStyle(.borderedProminent)
            Button("Decline") { declineEvent(event) }
                .buttonStyle(.bordered)
            Button("Maybe") { tentativeEvent(event) }
                .buttonStyle(.bordered)
        }
    }
}
```

**Correct (ViewThatFits switches to vertical layout when needed):**

```swift
struct EventActions: View {
    let event: CalendarEvent

    var body: some View {
        ViewThatFits { // picks the first layout that fits
            HStack(spacing: 12) {
                Button("Accept") { acceptEvent(event) }
                    .buttonStyle(.borderedProminent)
                Button("Decline") { declineEvent(event) }
                    .buttonStyle(.bordered)
                Button("Maybe") { tentativeEvent(event) }
                    .buttonStyle(.bordered)
            }
            VStack(spacing: 8) {
                Button("Accept") { acceptEvent(event) }
                    .buttonStyle(.borderedProminent)
                Button("Decline") { declineEvent(event) }
                    .buttonStyle(.bordered)
                Button("Maybe") { tentativeEvent(event) }
                    .buttonStyle(.bordered)
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

---

## 9. Testing & Debugging

**Impact: MEDIUM**

Swift Testing framework, #Preview macro, breakpoints, and console debugging catch bugs before users do. Systematic testing of models and logic ensures correctness.

### 9.1 Use Breakpoints to Debug Runtime Issues

**Impact: MEDIUM (breakpoints pause execution to inspect variable values without adding print statements)**

Scattering `print()` statements through your code to trace values is slow, clutters output, and risks being shipped to production. Breakpoints pause execution at a specific line so you can inspect every variable in scope, step through logic, and evaluate expressions in the debugger console without modifying source code.

**Incorrect (scattered print statements to trace a bug):**

```swift
struct TipCalculator {
    func calculateTip(billAmount: Double, tipPercentage: Double, splitCount: Int) -> Double {
        print("billAmount: \(billAmount)")
        print("tipPercentage: \(tipPercentage)")
        let tipAmount = billAmount * tipPercentage
        print("tipAmount: \(tipAmount)")
        let totalWithTip = billAmount + tipAmount
        print("totalWithTip: \(totalWithTip)")
        let perPerson = totalWithTip / Double(splitCount)
        print("perPerson: \(perPerson)")
        return perPerson
    }
}
```

**Correct (clean code debugged with breakpoints in Xcode):**

```swift
struct TipCalculator {
    func calculateTip(billAmount: Double, tipPercentage: Double, splitCount: Int) -> Double {
        let tipAmount = billAmount * tipPercentage
        let totalWithTip = billAmount + tipAmount
        let perPerson = totalWithTip / Double(splitCount) // set breakpoint here to inspect all values
        return perPerson
    }
}
// In Xcode: click the line gutter to add a breakpoint, then use
// the debug console to evaluate expressions like `po tipAmount`
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 9.2 Use Preview with Sample Data for Visual Testing

**Impact: MEDIUM (previews with realistic data catch layout issues without running the full app)**

Previews with empty or minimal data hide real-world layout problems like text truncation, long names overflowing, and empty states never being tested. Using realistic sample data in your previews catches these visual issues during development without launching the full app on a simulator.

**Incorrect (preview with minimal data hides layout issues):**

```swift
#Preview {
    ContactList(contacts: [
        Contact(name: "Alice", phone: "555-0100", email: "a@b.com")
    ])
}
```

**Correct (preview with realistic sample data reveals edge cases):**

```swift
extension Contact {
    static let sampleContacts: [Contact] = [
        Contact(name: "Alice Johnson", phone: "555-0100", email: "alice.johnson@example.com"),
        Contact(name: "Dr. Roberto Garcia-Martinez", phone: "+44 20 7946 0958", email: "roberto.garcia-martinez@longcompany.co.uk"),
        Contact(name: "\u{AD40}\u{BBFC}\u{C900}", phone: "010-1234-5678", email: "minjun.kim@example.kr"),
        Contact(name: "Sam", phone: "", email: ""), // tests missing data
    ]
}

#Preview("Contact list with varied data") {
    NavigationStack {
        ContactList(contacts: Contact.sampleContacts) // reveals truncation and empty states
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 9.3 Write Tests with Swift Testing Framework

**Impact: MEDIUM (catches logic bugs before they reach users, #expect macro provides clear failure messages)**

Shipping model logic without tests means bugs reach users first. The Swift Testing framework uses `@Test` functions and the `#expect` macro to verify behavior with clear, readable failure messages that pinpoint exactly what went wrong.

**Incorrect (model logic shipped without any tests):**

```swift
struct ShoppingCart {
    private(set) var items: [CartItem] = []

    mutating func add(_ product: Product, quantity: Int) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
    }

    var totalPrice: Decimal {
        items.reduce(0) { $0 + $1.product.price * Decimal($1.quantity) }
    }
}
// No tests written for add() or totalPrice
```

**Correct (test verifies model behavior with #expect):**

```swift
import Testing

@Test func addingProductToCartIncreasesTotal() {
    var cart = ShoppingCart()
    let coffee = Product(id: "coffee-01", name: "Coffee Beans", price: 12.99)

    cart.add(coffee, quantity: 2)

    #expect(cart.items.count == 1)
    #expect(cart.totalPrice == 25.98) // 12.99 * 2
}

@Test func addingSameProductMergesQuantity() {
    var cart = ShoppingCart()
    let coffee = Product(id: "coffee-01", name: "Coffee Beans", price: 12.99)

    cart.add(coffee, quantity: 1)
    cart.add(coffee, quantity: 3)

    #expect(cart.items.count == 1) // merged, not duplicated
    #expect(cart.items[0].quantity == 4)
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

---

## 10. App Polish & Refinement

**Impact: LOW**

Animations, transitions, inclusive features, and app refinement turn functional apps into delightful experiences. Polish is the difference between a working app and a great one.

### 10.1 Add Inclusive Features for Broader Reach

**Impact: LOW (localization, color contrast, and reduced motion support expand your audience)**

Hardcoding English strings, ignoring reduced motion preferences, and relying solely on color to convey meaning excludes large segments of your potential audience. Supporting localization, respecting accessibility settings, and using multiple visual cues makes your app usable by more people worldwide.

**Incorrect (English-only text and motion-heavy UI with no fallback):**

```swift
struct GreetingHeader: View {
    let userName: String

    var body: some View {
        VStack(spacing: 12) {
            Text("Good morning, \(userName)!")
                .font(.title)
            Circle()
                .fill(.green)
                .frame(width: 12, height: 12)
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 1).repeatForever(), value: pulseScale)
        }
    }

    @State private var pulseScale: CGFloat = 1.2
}
```

**Correct (localized strings and reduced motion check):**

```swift
struct GreetingHeader: View {
    let userName: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 12) {
            Text("greeting.morning \(userName)") // uses Localizable.xcstrings key
                .font(.title)
            HStack(spacing: 6) {
                Circle()
                    .fill(.green)
                    .frame(width: 12, height: 12)
                    .scaleEffect(reduceMotion ? 1.0 : pulseScale) // respects user preference
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 1).repeatForever(),
                        value: pulseScale
                    )
                Text("status.online") // label supplements the color indicator
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @State private var pulseScale: CGFloat = 1.2
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 10.2 Apply Transition Effects for View Insertion and Removal

**Impact: LOW (transitions animate views appearing and disappearing, preventing jarring UI changes)**

When views are conditionally added or removed from the hierarchy, they pop in and out without any visual cue by default. Adding `.transition()` modifiers animates the insertion and removal, giving users a clear signal that content has appeared or disappeared.

**Incorrect (notification banner appears and disappears abruptly):**

```swift
struct ContentView: View {
    @State private var showBanner = false

    var body: some View {
        ZStack(alignment: .top) {
            MainFeedView()
            if showBanner {
                NotificationBanner(message: "Item saved successfully")
                    .padding(.top, 8)
            }
        }
    }
}
```

**Correct (transition animates the banner sliding in and fading out):**

```swift
struct ContentView: View {
    @State private var showBanner = false

    var body: some View {
        ZStack(alignment: .top) {
            MainFeedView()
            if showBanner {
                NotificationBanner(message: "Item saved successfully")
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity)) // slides in from top and fades
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showBanner)
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

### 10.3 Use withAnimation for State-Driven Transitions

**Impact: LOW (smooth animations provide spatial context and reduce cognitive load)**

Abrupt state changes disorient users because elements appear or disappear without spatial context. Wrapping state mutations in `withAnimation` interpolates between the old and new layout, helping users understand what changed and where to look next.

**Incorrect (abrupt state change with no animation):**

```swift
struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                isExpanded.toggle()
            } label: {
                HStack {
                    Text(question)
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
```

**Correct (withAnimation wraps the state change for smooth disclosure):**

```swift
struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { // animates the layout change
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(question)
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)

---

## References

1. [https://developer.apple.com/tutorials/develop-in-swift/](https://developer.apple.com/tutorials/develop-in-swift/)
2. [https://developer.apple.com/tutorials/swiftui-concepts/maintaining-the-adaptable-sizes-of-built-in-views](https://developer.apple.com/tutorials/swiftui-concepts/maintaining-the-adaptable-sizes-of-built-in-views)
3. [https://developer.apple.com/tutorials/swiftui-concepts/scaling-views-to-complement-text](https://developer.apple.com/tutorials/swiftui-concepts/scaling-views-to-complement-text)
4. [https://developer.apple.com/tutorials/sample-apps/layingoutviews](https://developer.apple.com/tutorials/sample-apps/layingoutviews)
5. [https://developer.apple.com/documentation/swiftui/](https://developer.apple.com/documentation/swiftui/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
