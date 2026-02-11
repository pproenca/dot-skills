---
title: Use Asymmetric Timing for Enter and Exit
impact: HIGH
impactDescription: slow entrance builds anticipation, fast exit keeps flow — symmetric transitions feel robotic
tags: feel, asymmetric, enter, exit, transition
---

## Use Asymmetric Timing for Enter and Exit

Entering views should take slightly longer than exiting ones. Entry builds spatial awareness — the user needs to register where new content is coming from and where it now lives. Exit should get out of the way quickly — the user has already decided to dismiss, and lingering departure animations block them from their next action. Symmetric enter/exit durations feel robotic because nothing in the physical world appears and disappears at the same rate. A door swings open with weight; it clicks shut quickly.

**Incorrect (same timing for appear and disappear — feels mechanical):**

```swift
struct ToastView: View {
    @Binding var isVisible: Bool
    let message: String

    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(message)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: Capsule())
            // Same .smooth for both appear and disappear
            // Disappearing toast hangs around too long
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.smooth(duration: 0.35), value: isVisible)
        }
    }
}
```

**Correct (slower entrance, faster exit using asymmetric transition):**

```swift
struct ToastView: View {
    @Binding var isVisible: Bool
    let message: String

    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(message)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: Capsule())
            .transition(.asymmetric(
                // Entry: 350ms — slides in with weight, user registers position
                insertion: .move(edge: .top).combined(with: .opacity)
                    .animation(.smooth(duration: 0.35)),
                // Exit: 200ms — snaps away, clears the screen quickly
                removal: .move(edge: .top).combined(with: .opacity)
                    .animation(.smooth(duration: 0.2))
            ))
        }
    }
}
```

**Incorrect (action sheet with symmetric timing):**

```swift
struct ActionSheetView: View {
    @State private var showActions = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(showActions ? 0.3 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(duration: 0.3)) {
                        showActions = false
                    }
                }

            if showActions {
                VStack(spacing: 8) {
                    Button("Share") { }
                    Button("Copy Link") { }
                    Button("Cancel", role: .cancel) {
                        withAnimation(.spring(duration: 0.3)) {
                            showActions = false
                        }
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding()
                // Same 300ms in both directions
                .transition(.move(edge: .bottom))
                .animation(.spring(duration: 0.3), value: showActions)
            }
        }
    }
}
```

**Correct (action sheet with asymmetric timing via conditional animation):**

```swift
struct ActionSheetView: View {
    @State private var showActions = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(showActions ? 0.3 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            if showActions {
                VStack(spacing: 8) {
                    Button("Share") { }
                    Button("Copy Link") { }
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding()
                .transition(.asymmetric(
                    // Entry: slides up with a satisfying spring, 350ms
                    insertion: .move(edge: .bottom)
                        .animation(.spring(duration: 0.35, bounce: 0.15)),
                    // Exit: fast slide down, 200ms, no bounce
                    removal: .move(edge: .bottom)
                        .animation(.smooth(duration: 0.2))
                ))
            }
        }
    }

    private func dismiss() {
        withAnimation {
            showActions = false
        }
    }

    private func present() {
        withAnimation {
            showActions = true
        }
    }
}
```

**Asymmetric timing guideline:**

| Element | Enter Duration | Exit Duration | Ratio |
|---|---|---|---|
| Toast / snackbar | 350ms | 200ms | 1.75x |
| Bottom sheet | 400ms | 250ms | 1.6x |
| Action menu | 350ms | 200ms | 1.75x |
| Modal overlay | 350ms | 200ms | 1.75x |
| Popover | 250ms | 150ms | 1.67x |

**Rule of thumb:** exit duration should be 55-65% of enter duration. The user needs time to parse incoming content but wants outgoing content gone immediately.

**Reference:** Material Design motion guidelines document this same principle as "deceleration" (entering) vs "acceleration" (exiting). Apple's native sheet presentation follows asymmetric timing — presenting takes longer than dismissing.
