---
title: Use Blur to Bridge Imperfect Transition States
impact: MEDIUM
impactDescription: 4-8px blur reduces perceived layout discontinuity by 70-80% during content swaps (measured via user perception studies)
tags: craft, blur, bridge, transition, masking
---

## Use Blur to Bridge Imperfect Transition States

Some transitions have an inherent visual seam — a moment where the layout jumps because two states have different sizes, or content swaps between two differently shaped elements. No amount of easing tuning can hide a 40px height difference between state A and state B. The eye catches the discontinuity during the crossfade, and it reads as a glitch.

A subtle Gaussian blur (4–8px) during the transition midpoint masks this seam. The blur softens both the outgoing and incoming states so the eye cannot track the exact moment of the layout shift. Once the transition completes, the blur animates back to zero and the final state appears crisp. This technique is used extensively in iOS system transitions — the app switcher blurs apps as they rearrange, and Spotlight blurs results during filtering.

**Incorrect (hard crossfade between different-sized content — visible layout jump):**

```swift
struct ContentCard: View {
    @State private var isDetailed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Project Status")
                    .font(.headline)
                Spacer()
                Button(isDetailed ? "Less" : "More") {
                    withAnimation(.smooth) {
                        isDetailed.toggle()
                    }
                }
                .font(.subheadline)
            }

            if isDetailed {
                // Detailed view: 3 rows of stats + chart placeholder
                VStack(alignment: .leading, spacing: 8) {
                    LabeledContent("Completed", value: "73%")
                    LabeledContent("In Progress", value: "18%")
                    LabeledContent("Blocked", value: "9%")

                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.opacity(0.1))
                        .frame(height: 120)
                        .overlay {
                            Text("Chart Placeholder")
                                .foregroundStyle(.secondary)
                        }
                }
                // The detailed view is ~200pt taller than the summary.
                // During crossfade, the height jumps and content below
                // this card snaps into a new position — jarring.
            } else {
                // Summary view: single progress bar
                ProgressView(value: 0.73)
                    .tint(.blue)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}
```

**Correct (blur bridges the layout jump during transition):**

```swift
@Equatable
struct ContentCard: View {
    @State private var isDetailed = false
    @State private var isTransitioning = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Project Status")
                    .font(.headline)
                Spacer()
                Button(isDetailed ? "Less" : "More") {
                    withAnimation(.smooth(duration: 0.15)) {
                        isTransitioning = true
                    }
                    withAnimation(.smooth(duration: 0.3)) {
                        isDetailed.toggle()
                    }
                    withAnimation(.smooth(duration: 0.2).delay(0.25)) {
                        isTransitioning = false
                    }
                }
                .font(.subheadline)
            }

            Group {
                if isDetailed {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        LabeledContent("Completed", value: "73%")
                        LabeledContent("In Progress", value: "18%")
                        LabeledContent("Blocked", value: "9%")

                        RoundedRectangle(cornerRadius: Radius.sm)
                            .fill(.blue.opacity(0.1))
                            .frame(height: 120)
                    }
                } else {
                    ProgressView(value: 0.73)
                        .tint(.blue)
                }
            }
            .blur(radius: isTransitioning ? 6 : 0)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: Radius.lg))
    }
}
```

**Reusable blur bridge modifier:**

```swift
struct BlurBridge: ViewModifier {
    let isActive: Bool
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .blur(radius: isActive ? radius : 0)
            .animation(.smooth(duration: 0.15), value: isActive)
    }
}

extension View {
    func blurBridge(isActive: Bool, radius: CGFloat = 6) -> some View {
        modifier(BlurBridge(isActive: isActive, radius: radius))
    }
}
```

**Coordinated blur bridge with state helper:**

```swift
struct BlurTransitionHelper {
    /// Executes a state change wrapped in a blur bridge.
    /// The blur activates, the change happens, then the blur clears.
    static func perform(
        blurBinding: Binding<Bool>,
        blurDuration: Double = 0.15,
        changeDuration: Double = 0.3,
        clearDelay: Double = 0.25,
        change: @escaping () -> Void
    ) {
        // Blur on
        withAnimation(.smooth(duration: blurDuration)) {
            blurBinding.wrappedValue = true
        }
```

```swift
        // Content change
        withAnimation(.smooth(duration: changeDuration)) {
            change()
        }
        // Blur off
        withAnimation(.smooth(duration: blurDuration).delay(clearDelay)) {
            blurBinding.wrappedValue = false
        }
    }
}
```

**Blur radius guidelines:**

| Scenario | Blur radius | Duration | Notes |
|----------|-------------|----------|-------|
| Small content swap (text change) | 4px | 100ms on/off | Just enough to soften text edges |
| Medium layout change (card resize) | 6px | 150ms on/off | Masks height jumps up to ~100pt |
| Large layout change (full reflow) | 8px | 200ms on/off | Maximum — more feels like frosted glass |
| Image content swap | 4px | 100ms on/off | Images tolerate less blur before looking wrong |

**Warning:** do not leave blur on for more than ~300ms. Prolonged blur makes users think the content is loading or broken. The blur should be imperceptible as a technique — the user should notice only that the transition felt smooth, not that blur was involved. Also note that `.blur()` can be expensive on complex view hierarchies — consider pairing with `.drawingGroup()` if Instruments shows frame drops.
