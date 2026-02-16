---
title: Use Stacks Instead of Manual Positioning
impact: HIGH
impactDescription: stacks auto-adapt across 15+ screen sizes and 12 Dynamic Type steps — replacing .offset/.position with stacks eliminates 80-100% of device-specific layout bugs and saves 5-15 lines of manual coordinate math per component
tags: layout, stacks, vstack, hstack, edson-design-out-loud, kocienda-intersection
---

## Use Stacks Instead of Manual Positioning

Edson's "Design Out Loud" means prototyping with tools that adapt as you iterate. Stacks are SwiftUI's fundamental layout primitive — they flow content naturally, adapt to content size, and respond to Dynamic Type, localization, and screen dimensions. Manual positioning with `.offset()` or `.position()` creates brittle layouts that look right on one screen size and break on every other. Kocienda's intersection of technology and liberal arts demands layout that respects both the mathematical grid and the organic variability of human content.

**Incorrect (manual positioning that breaks on different devices):**

```swift
struct ProfileHeader: View {
    var body: some View {
        ZStack {
            Image("cover-photo")
                .resizable()
                .frame(height: 200)

            // Hard-coded position — breaks on iPad and Dynamic Type
            Text("John Appleseed")
                .font(.title.bold())
                .position(x: 195, y: 250)

            Image("avatar")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .offset(x: -120, y: 80)
        }
    }
}
```

**Correct (stacks that adapt to any content and screen):**

```swift
struct ProfileHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("cover-photo")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            Image("avatar")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(.background, lineWidth: 3))
                .offset(y: -52)
                .padding(.bottom, -52)

            Text("John Appleseed")
                .font(.title.bold())

            Text("iOS Engineer")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
```

**Stack selection guide:**
| Content Flow | Stack | Example |
|-------------|-------|---------|
| Top to bottom | `VStack` | Form fields, card content |
| Left to right | `HStack` | Label + value, icon + text |
| Front to back | `ZStack` | Overlays, badges, floating buttons |

**When .offset IS appropriate:** Decorative overlapping elements (avatar over cover photo) where the overlap is intentional and the base layout is still stack-based. Never use offset as the primary layout mechanism.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
