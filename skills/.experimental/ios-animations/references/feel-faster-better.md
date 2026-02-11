---
title: Faster Animations Almost Always Feel Better
impact: HIGH
impactDescription: reducing duration by 50ms consistently improves perceived quality in user testing
tags: feel, speed, perception, duration
---

## Faster Animations Almost Always Feel Better

When in doubt, make it faster. The single most common animation mistake is making things too slow. Developers overestimate how much time users need to "see" an animation. In practice, reducing duration by 50ms almost always improves perceived quality — the animation reads as crisper, snappier, more confident. Slow animations feel tentative, like the app is unsure of itself. The brain fills in the motion; you do not need to show every frame at human-readable speed.

**Incorrect (dropdown menu at 400ms — feels like it is wading through honey):**

```swift
struct FilterMenuView: View {
    @State private var isMenuOpen = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(duration: 0.4)) {
                    isMenuOpen.toggle()
                }
            } label: {
                HStack {
                    Text("Sort by")
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isMenuOpen ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: Capsule())
            }

            if isMenuOpen {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(["Newest", "Popular", "Price"], id: \.self) { option in
                        Button(option) { selectOption(option) }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                // 400ms — user is waiting for the menu to finish opening
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func selectOption(_ option: String) {
        withAnimation(.spring(duration: 0.4)) {
            isMenuOpen = false
        }
    }
}
```

**Correct (dropdown menu at 200ms — feels decisive and crisp):**

```swift
struct FilterMenuView: View {
    @State private var isMenuOpen = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.snappy(duration: 0.2)) {
                    isMenuOpen.toggle()
                }
            } label: {
                HStack {
                    Text("Sort by")
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isMenuOpen ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: Capsule())
            }

            if isMenuOpen {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(["Newest", "Popular", "Price"], id: \.self) { option in
                        Button(option) { selectOption(option) }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                // 200ms — menu snaps open, user can start reading immediately
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func selectOption(_ option: String) {
        withAnimation(.snappy(duration: 0.2)) {
            isMenuOpen = false
        }
    }
}
```

**Incorrect (tooltip lingers into view):**

```swift
struct TooltipView: View {
    @State private var showTooltip = false

    var body: some View {
        Button("Info") { showTooltip.toggle() }
            .overlay(alignment: .top) {
                if showTooltip {
                    Text("Tap to learn more")
                        .font(.caption)
                        .padding(8)
                        .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 6))
                        .foregroundStyle(.white)
                        .offset(y: -40)
                        // 350ms for a tooltip is painful
                        .transition(.opacity.animation(.smooth(duration: 0.35)))
                }
            }
    }
}
```

**Correct (tooltip appears crisply):**

```swift
struct TooltipView: View {
    @State private var showTooltip = false

    var body: some View {
        Button("Info") { showTooltip.toggle() }
            .overlay(alignment: .top) {
                if showTooltip {
                    Text("Tap to learn more")
                        .font(.caption)
                        .padding(8)
                        .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 6))
                        .foregroundStyle(.white)
                        .offset(y: -40)
                        // 150ms — tooltip pops without demanding attention
                        .transition(.opacity.animation(.smooth(duration: 0.15)))
                }
            }
    }
}
```

**Recommended duration reference table:**

| Element | Recommended Duration | Why |
|---|---|---|
| Tooltip | 150ms | Information aid, not a feature |
| Button state change | 100ms | Tactile feedback |
| Toggle / switch | 200ms | Direct manipulation |
| Dropdown menu | 200ms | Functional reveal |
| Navigation push | 250ms | Spatial context shift |
| Bottom sheet (half) | 300ms | Moderate spatial distance |
| Bottom sheet (full) | 350ms | Longer travel distance |
| Full-screen transition | 400-500ms | Cinematic, covers entire viewport |
| Onboarding sequence | 500-600ms | Deliberate storytelling |

**The 50ms test:** If you are unsure about a duration, try subtracting 50ms. If it still reads clearly, ship the shorter version. Repeat until the animation feels rushed, then add back one increment. You will almost always end up shorter than your first instinct.

**Reference:** Apple's spring presets (.snappy, .smooth, .bouncy) default to durations in the 200-350ms range. The preset names themselves tell you the design intent — "snappy" is meant to feel fast.
