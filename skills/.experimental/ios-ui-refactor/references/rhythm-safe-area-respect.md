---
title: Always Respect Safe Areas
impact: MEDIUM-HIGH
impactDescription: ignoring safe areas clips text and buttons behind the Dynamic Island, notch, or home indicator — users cannot read or tap obscured content, producing support tickets and 1-star reviews on notched devices
tags: rhythm, safe-area, layout, dynamic-island, accessibility
---

## Always Respect Safe Areas

Calling `.ignoresSafeArea()` without understanding what it disables is one of the most common layout failures on modern iPhones. The safe area insets protect content from the Dynamic Island, the home indicator, and rounded display corners. Ignoring safe areas for backgrounds and images is correct — ignoring them for text, buttons, or interactive elements is never correct. When you need a custom bar or overlay at the screen edge, use `.safeAreaInset(edge:)` to push content inward rather than ignoring the safe area entirely.

**Incorrect (ignoresSafeArea hides text and buttons behind hardware):**

```swift
struct LiveActivityView: View {
    var body: some View {
        ZStack {
            Color.black

            VStack(spacing: 16) {
                // This text renders behind the Dynamic Island on iPhone 15+
                Text("LIVE")
                    .font(.caption.bold())
                    .foregroundStyle(.red)

                Text("Golden State Warriors vs. Boston Celtics")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text("Q3 · 4:28")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                // This button sits behind the home indicator
                Button("Open Full Scoreboard") { }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 8)
            }
            .padding()
        }
        // Blanket ignore — content now collides with hardware on every edge
        .ignoresSafeArea()
    }
}
```

**Correct (background extends to edges, content stays within safe areas):**

```swift
struct LiveActivityView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("LIVE")
                .font(.caption.bold())
                .foregroundStyle(.red)

            Text("Golden State Warriors vs. Boston Celtics")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Q3 · 4:28")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))

            Spacer()

            Button("Open Full Scoreboard") { }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        // Background extends to edges — content does not
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
```

**Custom bottom bar using safeAreaInset:**

```swift
struct ChatView: View {
    @State private var message = ""

    var body: some View {
        ScrollView {
            LazyVStack {
                // Chat messages...
                ForEach(0..<20) { i in
                    Text("Message \(i)")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        // safeAreaInset pushes scroll content UP so it is never hidden
        .safeAreaInset(edge: .bottom) {
            HStack {
                TextField("Message", text: $message)
                    .textFieldStyle(.roundedBorder)
                Button(action: { /* send */ }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.bar)
        }
    }
}
```

**Safe area rules by content type:**

```swift
// Content type         | Ignore safe area? | Method
// ----------------------|-------------------|----------------------------------
// Background color      | Yes               | .background(Color.x.ignoresSafeArea())
// Background image      | Yes               | .ignoresSafeArea() on the image only
// Text content          | Never             | Default behavior (respects safe area)
// Buttons / controls    | Never             | Default behavior
// Custom top/bottom bar | No — use inset    | .safeAreaInset(edge:)
// Scroll content        | No                | .contentMargins() on iOS 17+
// Full-screen media     | Yes (video only)  | .ignoresSafeArea() with controls overlay
```

**When NOT to enforce:** Full-screen video playback, camera viewfinders, and immersive AR experiences legitimately ignore all safe areas. In those cases, overlay interactive controls (play/pause, close) within the safe area using a separate layer.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
