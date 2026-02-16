---
title: Respect accessibilityReduceMotion with Crossfade Fallback
impact: CRITICAL
impactDescription: 35% of adults experience motion sensitivity — ignoring reduce motion is an accessibility violation affecting 1 in 3 users
tags: craft, accessibility, reduceMotion, crossfade, fallback
---

## Respect accessibilityReduceMotion with Crossfade Fallback

Approximately 35% of adults experience some form of motion sensitivity. When a user enables "Reduce Motion" in iOS Settings, they are telling the system that sliding, zooming, and bouncing animations cause them physical discomfort — dizziness, nausea, or headaches. SwiftUI does not automatically respect this preference for custom animations. The `.animation(.default)` modifier and `withAnimation` still apply full spring or easing animations regardless of the setting. You must explicitly check `@Environment(\.accessibilityReduceMotion)` and substitute movement-based animations with opacity crossfades.

The key insight is that you should not remove all animation when reduce motion is enabled. Opacity crossfades are universally safe — they provide visual continuity without triggering vestibular responses. The problematic animations are those involving spatial movement: slides, zooms, rotations, and parallax effects.

**Incorrect (ignoring reduce motion — full animations always play):**

```swift
struct CardStack: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            [Color.blue, .purple, .orange][index].gradient
                        )
                        .padding()
                        .tag(index)
                }
            }
            .tabViewStyle(.page)

            // Custom animated indicator
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index == selectedTab ? .primary : .secondary)
                        .frame(width: 8, height: 8)
                        // This scale + offset animation plays for ALL users,
                        // including those who enabled Reduce Motion to avoid
                        // exactly this kind of movement.
                        .scaleEffect(index == selectedTab ? 1.3 : 1.0)
                        .offset(y: index == selectedTab ? -2 : 0)
                        .animation(.bouncy, value: selectedTab)
                }
            }
        }
    }
}
```

**Correct (crossfade fallback when reduce motion is enabled):**

```swift
@Equatable
struct CardStack: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(
                            [Color.blue, .purple, .orange][index].gradient
                        )
                        .padding()
                        .tag(index)
                }
            }
            .tabViewStyle(.page)

            HStack(spacing: Spacing.sm) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index == selectedTab ? .primary : .secondary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(
                            // When reduce motion is on, skip the scale bounce —
                            // just change the fill color (already handled above)
                            !reduceMotion && index == selectedTab ? 1.3 : 1.0
                        )
                        .animation(
                            reduceMotion ? .none : .bouncy,
                            value: selectedTab
                        )
                }
            }
        }
    }
}
```

**Reusable conditional animation helper:**

```swift
extension Animation {
    /// Returns `.opacity` crossfade when reduce motion is on,
    /// the provided animation otherwise.
    static func motionSafe(
        _ animation: Animation,
        reduceMotion: Bool
    ) -> Animation {
        reduceMotion ? .smooth(duration: 0.2) : animation
    }
}

extension AnyTransition {
    /// Returns an opacity-only transition when reduce motion is on,
    /// the provided transition otherwise.
    static func motionSafe(
        _ transition: AnyTransition,
        reduceMotion: Bool
    ) -> AnyTransition {
        reduceMotion ? .opacity : transition
    }
}
```

**Production example — screen entrance with reduce motion awareness:**

```swift
@Equatable
struct OnboardingCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    let title: String
    let description: String
    let iconName: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: iconName)
                .font(.system(size: 56))
                .foregroundStyle(.blue)
                // Movement: scale up from small
                .scaleEffect(isVisible ? 1 : (reduceMotion ? 1 : 0.5))
                // Safe: opacity always animates
                .opacity(isVisible ? 1 : 0)
                .animation(
                    reduceMotion
                        ? .smooth(duration: 0.3)          // crossfade only
                        : .spring(duration: 0.5, bounce: 0.2), // full spring
                    value: isVisible
                )

            Text(title)
                .font(.title2.bold())
                // Movement: slides up 20pt (skipped for reduce motion)
                .offset(y: isVisible ? 0 : (reduceMotion ? 0 : 20))
                .opacity(isVisible ? 1 : 0)
                .animation(
                    reduceMotion
                        ? .smooth(duration: 0.3).delay(0.05)
                        : .smooth(duration: 0.4).delay(0.1),
                    value: isVisible
                )

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .opacity(isVisible ? 1 : 0)
                .animation(
                    .smooth(duration: 0.3).delay(reduceMotion ? 0.1 : 0.2),
                    value: isVisible
                )
        }
        .padding(Spacing.xl)
        .task {
            try? await Task.sleep(for: .milliseconds(50))
            isVisible = true
        }
    }
}
```

**What is safe and what is not:**

| Animation type | Reduce motion ON | Reduce motion OFF |
|---------------|-----------------|-------------------|
| Opacity crossfade | Safe — always use | Safe |
| Color change | Safe — always use | Safe |
| Scale (subtle, < 1.1x) | Borderline — prefer skip | Safe |
| Slide / offset | Unsafe — replace with fade | Safe |
| Rotation | Unsafe — replace with fade | Safe |
| Parallax scroll | Unsafe — disable entirely | Safe |
| Zoom transition | Unsafe — replace with fade | Safe |
| Spring bounce | Unsafe — use linear fade | Safe |

**Important:** SwiftUI's built-in `.animation(.default)` and `withAnimation` do NOT automatically respect reduce motion. The `matchedTransitionSource` zoom transition (iOS 18) does respect it natively, but custom animations require manual checking. Always test your app with Settings > Accessibility > Motion > Reduce Motion enabled.

Reference: [WWDC 2019 — Visual Design and Accessibility](https://developer.apple.com/wwdc19/244) and Apple Human Interface Guidelines — Motion
