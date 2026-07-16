---
title: Restyle system controls with style protocols instead of rebuilding them
tags: access, style-protocols, togglestyle, custom-controls
---

## Restyle system controls with style protocols instead of rebuilding them

The wrong default when a design calls for a bespoke-looking control is rebuilding it from primitives, even though the control's semantic role matches a system component. A hand-rolled toggle built from a `Button` and an icon announces itself as a button — assistive technologies never learn it has an on/off state — and it forfeits the state handling and platform behavior the system component carries. When the built-in exposes a style protocol (`ToggleStyle`, `ButtonStyle`, `LabelStyle`, `ProgressViewStyle`), define the custom visuals there and apply the style to the real control: the UI looks fully custom while inheriting accessibility traits, value announcements, and system behavior automatically.

**Evidence of violation:** a custom component that replicates a system control's semantics from primitives where the corresponding style protocol exists and is unused — the checkable shapes: a `Binding<Bool>` flipped by a button or tap that renders an on/off appearance (that is a `Toggle`; restyle with `ToggleStyle`), a tap-activated single action with a custom pressed/visual treatment rebuilt outside `Button` (restyle with `ButtonStyle`), a title-plus-icon pairing laid out by hand (that is a `Label`; restyle with `LabelStyle`). PASS: the built-in control with a custom style conformance applied. N/A: the replicated role has no style protocol to conform to (e.g. `Picker` — SwiftUI exposes no `PickerStyle` conformance for custom styles); such controls are judged by `access-representation-for-custom-controls` instead. N/A: no custom controls in the target.

**Incorrect (announces as a button; on/off state invisible to VoiceOver):**

```swift
import SwiftUI

struct NotificationsToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        // ⚠️ Announces as a button; the on/off state is invisible to VoiceOver
        Button {
            isOn.toggle()
        } label: {
            Image(systemName: "bell")
                .symbolVariant(isOn ? .none : .slash)
                .contentTransition(.symbolEffect)
        }
        .accessibilityLabel("Notifications")
    }
}
```

**Correct (custom visuals on a real Toggle; traits and state come free):**

```swift
import SwiftUI

struct SymbolToggleStyle: ToggleStyle {
    let symbolName: String

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: "bell")
                    .symbolVariant(
                        configuration.isOn ? .none : .slash
                    )
                    .contentTransition(.symbolEffect)
            }
            .labelStyle(.iconOnly)
        }
    }
}

extension ToggleStyle where Self == SymbolToggleStyle {
    static func symbol(_ symbolName: String) -> SymbolToggleStyle {
        SymbolToggleStyle(symbolName: symbolName)
    }
}

struct NotificationsToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("Notifications", isOn: $isOn)
            .toggleStyle(.symbol("bell"))
    }
}
```
