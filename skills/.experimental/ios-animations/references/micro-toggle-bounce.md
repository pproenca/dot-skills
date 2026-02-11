---
title: Add Bounce to Toggle State Changes
impact: MEDIUM
impactDescription: slight overshoot on toggle communicates "locked in" — linear transition feels uncertain
tags: micro, toggle, bounce, spring, state-change
---

## Add Bounce to Toggle State Changes

When a toggle, checkbox, or radio button changes state, a slight spring overshoot reinforces the commitment. The thumb slides past its resting position by a few points and settles back — a physical metaphor for "locked in". Linear or ease-in-out transitions slide the thumb to its target and stop dead, which feels mechanical and uncertain. The user subconsciously wonders if the toggle actually landed. A `.bouncy(duration: 0.3)` spring solves this by providing a natural settle that communicates finality.

**Incorrect (linear transition feels mechanical and uncertain):**

```swift
struct CustomToggle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer()

            Capsule()
                .fill(configuration.isOn ? Color.green : Color(.systemGray4))
                .frame(width: 51, height: 31)
                .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                        .padding(2)
                        .frame(width: 27, height: 27)
                }
                // Linear: the thumb slides and stops dead. No overshoot,
                // no settle — feels like a slider, not a switch.
                .animation(.linear(duration: 0.2), value: configuration.isOn)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}
```

**Correct (bouncy spring overshoots and settles — communicates commitment):**

```swift
struct BouncyToggle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer()

            Capsule()
                .fill(configuration.isOn ? Color.green : Color(.systemGray4))
                .frame(width: 51, height: 31)
                .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                        .padding(2)
                        .frame(width: 27, height: 27)
                }
                // .bouncy(duration: 0.3): the thumb slides past its target by
                // ~2 points and settles back — a physical "click into place"
                .animation(.bouncy(duration: 0.3), value: configuration.isOn)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

struct SettingsView: View {
    @State private var wifiEnabled = true
    @State private var bluetoothEnabled = false

    var body: some View {
        Form {
            Toggle("Wi-Fi", isOn: $wifiEnabled)
                .toggleStyle(BouncyToggle())

            Toggle("Bluetooth", isOn: $bluetoothEnabled)
                .toggleStyle(BouncyToggle())
        }
    }
}
```

**Complete checkbox example with bounce:**

```swift
struct BouncyCheckbox: View {
    @Binding var isChecked: Bool

    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isChecked ? Color.blue : Color.clear)
                    .frame(width: 24, height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(isChecked ? Color.blue : Color(.systemGray3), lineWidth: 2)
                    )

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(isChecked ? 1 : 0)
            }
            // The checkmark pops in with bounce — it grows slightly past
            // full size and settles back, reinforcing "done"
            .animation(.bouncy(duration: 0.3), value: isChecked)
        }
        .buttonStyle(.plain)
    }
}

struct TaskListView: View {
    @State private var tasks = [
        (name: "Design review", done: false),
        (name: "Update API docs", done: true),
        (name: "Fix layout bug", done: false)
    ]

    var body: some View {
        List {
            ForEach(tasks.indices, id: \.self) { index in
                HStack(spacing: 12) {
                    BouncyCheckbox(isChecked: $tasks[index].done)

                    Text(tasks[index].name)
                        .strikethrough(tasks[index].done)
                        .foregroundStyle(tasks[index].done ? .secondary : .primary)
                }
            }
        }
    }
}
```

**Spring choice for state toggles:**

| Control | Spring | Why |
|---|---|---|
| System-style toggle | `.bouncy(duration: 0.3)` | Slight overshoot mimics physical switch |
| Checkbox / radio | `.bouncy(duration: 0.25)` | Quick pop-in for checkmark appearance |
| Segmented picker | `.snappy` | No bounce — segments are about speed, not delight |
| Stepper | `.snappy` | Rapid taps need immediate response |

**Key insight:** the bounce should be subtle. Default `.bouncy` has a `dampingFraction` of 0.7 which is visible but not exaggerated. If you go lower (more bounce), the toggle starts to feel like a toy. The goal is a physical toggle, not a spring-loaded trap.

Reference: [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
