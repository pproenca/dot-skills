---
title: Use .snappy Spring for Responsive Interactions
impact: CRITICAL
impactDescription: 30-50ms faster perceived response than .smooth for high-frequency actions
tags: spring, snappy, buttons, toggles, responsive
---

## Use .snappy Spring for Responsive Interactions

`.snappy` has higher stiffness than `.smooth`, which means it reaches its target faster and with minimal overshoot. This makes it ideal for controls the user taps repeatedly — toggles, tab switches, segmented pickers, checkbox taps — where even 30ms of perceived lag erodes the feeling of direct manipulation. The difference between `.smooth` and `.snappy` is subtle in isolation but compounds across an entire session of frequent taps.

**Incorrect (.smooth feels sluggish on a high-frequency toggle):**

```swift
struct NotificationSettingsRow: View {
    let title: String
    let subtitle: String
    @Binding var isEnabled: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Custom toggle indicator
            Circle()
                .fill(isEnabled ? Color.green : Color(.systemGray4))
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: isEnabled ? "checkmark" : "")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
                // .smooth is fine generally, but for toggles tapped many times
                // in a settings screen, the slight delay feels laggy
                .animation(.smooth, value: isEnabled)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isEnabled.toggle()
        }
    }
}
```

**Correct (.snappy feels crisp and immediate):**

```swift
@Equatable
struct NotificationSettingsRow: View {
    let title: String
    let subtitle: String
    @Binding var isEnabled: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Circle()
                .fill(isEnabled ? Color.green : Color(.systemGray4))
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: isEnabled ? "checkmark" : "")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
                // .snappy: higher stiffness, faster settle, crisp for toggles
                // (equivalent to Motion.responsive)
                .animation(.snappy, value: isEnabled)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isEnabled.toggle()
        }
    }
}
```

**Parameter comparison between presets:**

| Preset | response | dampingFraction | Perceived feel |
|--------|----------|-----------------|----------------|
| `.smooth` | 0.5 | 1.0 | Calm, deliberate |
| `.snappy` | 0.3 | 1.0 | Quick, decisive |
| `.bouncy` | 0.5 | 0.7 | Playful, overshoot |

**Where `.snappy` excels — tab bar and segmented control:**

```swift
@Equatable
struct CategoryTabBar: View {
    let categories = ["All", "Food", "Drinks", "Desserts"]
    @State private var selectedIndex = 0

    var body: some View {
        HStack(spacing: 0) {
            ForEach(categories.indices, id: \.self) { index in
                Button {
                    selectedIndex = index
                } label: {
                    Text(categories[index])
                        .font(.subheadline.weight(.medium))
                        .padding(.vertical, Spacing.sm)
                        .padding(.horizontal, Spacing.md)
                        .foregroundStyle(selectedIndex == index ? .white : .primary)
                        .background {
                            if selectedIndex == index {
                                Capsule()
                                    .fill(.tint)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.xs)
        .background(.quaternary, in: Capsule())
        // .snappy makes tab switching feel instant — users notice
        // the 30ms difference when switching tabs rapidly
        .animation(.snappy, value: selectedIndex)
    }
}
```

**Rule of thumb:** if the user might tap the same control more than twice in quick succession, use `.snappy`.

Reference: [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
