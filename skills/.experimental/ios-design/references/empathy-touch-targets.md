---
title: Ensure 44x44 Point Minimum Touch Targets
impact: CRITICAL
impactDescription: targets smaller than 44pt cause 15-25% more tap errors, frustrating users with motor impairments and everyone using the app one-handed while walking
tags: empathy, touch, target, kocienda-empathy, edson-people, a11y, motor
---

## Ensure 44x44 Point Minimum Touch Targets

Kocienda spent months refining the iPhone keyboard's touch model — enlarging the tap target of the letter the autocorrect engine predicted you'd type next. This is empathy expressed in code: understanding that human fingers are imprecise instruments, especially when the user is walking, riding transit, or has a motor disability. Edson's people-first principle demands that every interactive element be physically reachable by every person who might use it, not just the developer with steady hands and a desk.

**Incorrect (icon button with no minimum tap area):**

```swift
struct CompactToolbar: View {
    var body: some View {
        HStack(spacing: 8) {
            // 18pt icon with no expanded hit area
            Button { share() } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18))
            }

            // Text button with tiny padding
            Button("Edit") { edit() }
                .font(.caption2)
                .padding(4)
        }
    }
}
```

**Correct (minimum 44pt touch targets on every interactive element):**

```swift
struct CompactToolbar: View {
    var body: some View {
        HStack(spacing: 8) {
            Button { share() } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18))
                    // Visual size stays small, touch area expands
                    .frame(minWidth: 44, minHeight: 44)
            }

            Button("Edit") { edit() }
                .font(.caption2)
                .frame(minHeight: 44)
                .padding(.horizontal, 12)
        }
    }
}
```

**Common violations and fixes:**
| Element | Problem | Fix |
|---------|---------|-----|
| Icon-only button | 16-24pt visual size | `.frame(minWidth: 44, minHeight: 44)` |
| Text link in paragraph | Line height < 44pt | Wrap in `Button` with minimum frame |
| Close "X" button | Tiny circle in corner | `.frame(minWidth: 44, minHeight: 44)` |
| Rating stars | Stars touch each other | Add spacing and minimum frames |

**When NOT to enforce:** System controls like `Toggle`, `Stepper`, `Picker`, and `Slider` already meet Apple's touch target requirements. Don't add redundant frames to these.

Reference: [Accessibility - Touch targets](https://developer.apple.com/design/human-interface-guidelines/accessibility#Touch-targets)
