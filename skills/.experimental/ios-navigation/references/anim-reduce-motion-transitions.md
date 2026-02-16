---
title: Respect Reduce Motion for All Navigation Animations
impact: MEDIUM-HIGH
impactDescription: required for accessibility compliance, affects 10-15% of users
tags: anim, accessibility, reduce-motion, spring
---

## Respect Reduce Motion for All Navigation Animations

When `accessibilityReduceMotion` is enabled, spring and movement-based animations should be replaced with instant transitions or simple crossfades. System navigation transitions (push, pop, tab switch) already handle this automatically, but any custom animation -- gesture-driven dismissals, hero transitions, parallax effects -- must check this preference explicitly. Ignoring it can cause discomfort for users with vestibular disorders, and violates WCAG 2.3.3 (Animation from Interactions).

**Incorrect (spring animation regardless of accessibility settings):**

```swift
// BAD: Users with vestibular disorders experience discomfort from
// bouncy spring animations. 10-15% of iOS users enable Reduce Motion.
// This code forces the same animation on everyone.
struct CustomModalView: View {
    @Binding var isPresented: Bool
    @State private var offset: CGFloat = 0

    var body: some View {
        if isPresented {
            ModalContent()
                .offset(y: offset)
                .transition(.move(edge: .bottom))
                .onAppear {
                    withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                        offset = 0
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            // Always animates with spring, even with
                            // Reduce Motion enabled
                            withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                                if value.translation.height > 150 {
                                    isPresented = false
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
        }
    }
}
```

**Correct (conditional animation respecting reduce motion):**

```swift
@Equatable
struct CustomModalView: View {
    @Binding var isPresented: Bool
    @State private var offset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if isPresented {
            ModalContent()
                .offset(y: reduceMotion ? 0 : offset)
                .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    withAnimation(presentationAnimation) {
                        offset = 0
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            withAnimation(dismissAnimation) {
                                if value.translation.height > 150 {
                                    isPresented = false
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
        }
    }

    private var presentationAnimation: Animation {
        reduceMotion
            ? .linear(duration: 0.15)
            : .spring(duration: 0.6, bounce: 0.3)
    }

    private var dismissAnimation: Animation {
        reduceMotion
            ? .linear(duration: 0.15)
            : .spring(duration: 0.5, bounce: 0)
    }
}
```
