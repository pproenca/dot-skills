---
title: Use withAnimation Completion for Chained Sequences
impact: HIGH
impactDescription: eliminates 100% of DispatchQueue.main.asyncAfter timing hacks that break on variable-duration springs and reduces dead time by up to 200ms per animation step
tags: spring, completion, chaining, withAnimation, sequence
---

## Use withAnimation Completion for Chained Sequences

iOS 17 introduced a completion handler on `withAnimation` that fires when the animation reaches a specified criterion. This replaces the fragile pattern of guessing animation duration and chaining with `DispatchQueue.main.asyncAfter(deadline:)`. Springs have no fixed duration — they settle asymptotically — so hardcoded delays either fire too early (cutting off the animation) or too late (adding unnecessary dead time). The completion handler fires at exactly the right moment.

**Incorrect (DispatchQueue timing hack breaks on variable-duration springs):**

```swift
struct OnboardingStepView: View {
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showDescription = false
    @State private var showButton = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)
                .scaleEffect(showIcon ? 1 : 0.5)
                .opacity(showIcon ? 1 : 0)

            Text("Welcome to FitTrack")
                .font(.title.bold())
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 20)

            Text("Track your workouts, set goals, and see your progress over time.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .opacity(showDescription ? 1 : 0)
                .offset(y: showDescription ? 0 : 20)

            Button("Get Started") { }
                .buttonStyle(.borderedProminent)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
        }
        .padding(32)
        .onAppear {
            // These delays are fragile guesses:
            // - If the spring settles faster, there's dead time between steps
            // - If the spring settles slower, animations overlap incorrectly
            // - Changing the spring preset breaks all the timing
            withAnimation(.bouncy) { showIcon = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.smooth) { showTitle = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.smooth) { showDescription = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.smooth) { showButton = true }
            }
        }
    }
}
```

**Correct (withAnimation completion chains at exactly the right moment):**

```swift
@Equatable
struct OnboardingStepView: View {
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showDescription = false
    @State private var showButton = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
                .scaleEffect(showIcon ? 1 : 0.5)
                .opacity(showIcon ? 1 : 0)

            Text("Welcome to FitTrack")
                .font(.title.bold())
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 20)

            Text("Track your workouts, set goals, and see your progress over time.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .opacity(showDescription ? 1 : 0)
                .offset(y: showDescription ? 0 : 20)

            Button("Get Started") { }
                .buttonStyle(.borderedProminent)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
        }
        .padding(Spacing.xl)
        .onAppear {
            animateSequence()
        }
    }
```

The completion handler chains each animation step precisely:

```swift
    private func animateSequence() {
        // Each step fires exactly when the previous animation is done.
        // Changing the spring preset automatically adjusts the timing.
        withAnimation(.bouncy) {
            showIcon = true
        } completion: {
            withAnimation(.smooth) {
                showTitle = true
            } completion: {
                withAnimation(.smooth) {
                    showDescription = true
                } completion: {
                    withAnimation(.smooth) {
                        showButton = true
                    }
                }
            }
        }
    }
}
```

**Understanding completion criteria — `.logicallyComplete` vs `.removed`:**

```swift
@Equatable
struct StatusBanner: View {
    @State private var showBanner = false
    @State private var bannerMessage = ""

    var body: some View {
        VStack {
            if showBanner {
                Text(bannerMessage)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(.green, in: Capsule())
                    .foregroundStyle(.white)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()

            Button("Save Changes") {
                bannerMessage = "Changes saved successfully"

                withAnimation(.snappy) {
                    showBanner = true
                } completion: {
                    // Auto-dismiss after the show animation completes
                    withAnimation(.smooth.delay(1.5)) {
                        showBanner = false
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(Spacing.md)
    }
}
```

**Completion criteria options (iOS 17+):**

```swift
// .logicallyComplete (default): fires when the animation is
// perceptually done — the spring is close enough to the target
// that the difference is invisible. Best for chaining sequences.
withAnimation(.smooth) {
    offset = 100
} completion: {
    // Fires when the animation looks done to the user
    startNextStep()
}

// .removed: fires when the animation has fully settled to its
// target value (including the sub-pixel long tail). Use this
// when downstream logic requires the exact final value, or
// when cleaning up resources after the animation is truly done.
withAnimation(.smooth) {
    showPanel = false
} completion: {
    // Fires when the spring has fully settled, not just when it looks done
    cleanupPanelResources()
}
```

**For complex multi-step sequences, consider extracting the chain:**

```swift
@Equatable
struct CelebrationView: View {
    @State private var phase = 0

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)
                .scaleEffect(phase >= 1 ? 1 : 0)

            Text("Congratulations!")
                .font(.largeTitle.bold())
                .opacity(phase >= 2 ? 1 : 0)

            Text("You completed your 30-day streak!")
                .font(.title3)
                .foregroundStyle(.secondary)
                .opacity(phase >= 3 ? 1 : 0)

            Button("Share Achievement") { }
                .buttonStyle(.borderedProminent)
                .scaleEffect(phase >= 4 ? 1 : 0.8)
                .opacity(phase >= 4 ? 1 : 0)
        }
        .animation(.bouncy, value: phase)
        .onAppear {
            animateSequence()
        }
    }

    private func animateSequence() {
        withAnimation(.bouncy) {
            phase = 1
        } completion: {
            withAnimation(.smooth) {
                phase = 2
            } completion: {
                withAnimation(.smooth) {
                    phase = 3
                } completion: {
                    withAnimation(.snappy) {
                        phase = 4
                    }
                }
            }
        }
    }
}
```

**Benefits:**
- Zero hardcoded timing values to maintain
- Changing spring presets automatically adjusts the entire sequence
- No risk of `asyncAfter` firing while the app is backgrounded
- Compiler-checked — the completion closure is part of the `withAnimation` API

Reference: [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
