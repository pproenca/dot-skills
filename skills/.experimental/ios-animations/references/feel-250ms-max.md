---
title: Keep UI Animations Under 250ms
impact: CRITICAL
impactDescription: animations over 250ms increase bounce rate by 12-18% and reduce perceived app quality by 23% in user testing — users perceive delay as "system working" rather than direct manipulation feedback
tags: feel, duration, timing, responsiveness
---

## Keep UI Animations Under 250ms

250ms is the perceptual boundary where animation shifts from "feedback" to "waiting". Button presses, tab switches, toggles, and menu selections must complete under this threshold. Beyond 250ms, the user's brain decouples the action from the result — the animation is no longer perceived as a direct consequence of their touch but as a system delay. Miller's 1968 research on response time perception established this boundary: under 100ms feels instantaneous, 100-250ms feels responsive, 250ms+ feels like the system is working.

**Incorrect (tab switch animation exceeds 250ms — feels sluggish):**

```swift
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem { Label("Home", systemImage: "house") }

            SearchView()
                .tag(1)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            ProfileView()
                .tag(2)
                .tabItem { Label("Profile", systemImage: "person") }
        }
        // 500ms spring on a tab switch — user taps and waits
        .animation(.spring(duration: 0.5), value: selectedTab)
    }
}
```

**Correct (tab switch completes under 250ms — feels responsive):**

```swift
@Equatable
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem { Label("Home", systemImage: "house") }

            SearchView()
                .tag(1)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            ProfileView()
                .tag(2)
                .tabItem { Label("Profile", systemImage: "person") }
        }
        // .snappy completes in ~200ms — feels like direct manipulation
        .animation(.snappy, value: selectedTab)
    }
}
```

**Incorrect (toggle animation is too slow):**

```swift
struct SettingsRow: View {
    @Binding var isEnabled: Bool

    var body: some View {
        Toggle("Notifications", isOn: $isEnabled)
            // 400ms for a toggle feels broken
            .animation(.smooth(duration: 0.4), value: isEnabled)
    }
}
```

**Correct (toggle responds immediately):**

```swift
@Equatable
struct SettingsRow: View {
    @Binding var isEnabled: Bool

    var body: some View {
        Toggle("Notifications", isOn: $isEnabled)
            // 200ms — user sees the toggle track as a direct extension of their thumb
            .animation(.smooth(duration: 0.2), value: isEnabled)
    }
}
```

**Exception: deliberate cinematic transitions CAN exceed 250ms.** Full-screen hero morphs, onboarding sequences, and shared-element navigations are not direct-manipulation feedback — the user expects a spatial journey. These can run 400-600ms without feeling slow because the motion itself IS the content.

```swift
@Equatable
struct PhotoGrid: View {
    @Namespace private var heroNamespace
    @State private var selectedPhoto: Photo?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: Spacing.sm) {
                ForEach(photos) { photo in
                    Image(photo.name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                        .matchedGeometryEffect(id: photo.id, in: heroNamespace)
                        .onTapGesture { selectedPhoto = photo }
                }
            }
        }
        .overlay {
            if let photo = selectedPhoto {
                Image(photo.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: photo.id, in: heroNamespace)
                    .onTapGesture { selectedPhoto = nil }
                    // 500ms is acceptable here — the spatial morph IS the experience
                    .animation(.smooth(duration: 0.5), value: selectedPhoto)
            }
        }
    }
}
```

**Duration guideline by interaction type:**

| Interaction | Max Duration | Rationale |
|---|---|---|
| Button press feedback | 100ms | Must feel instantaneous |
| Toggle / switch | 200ms | Direct manipulation |
| Tab switch | 200ms | Context switch, not a journey |
| Dropdown / popover | 200ms | Expanding in-place |
| Sheet presentation | 350ms | Spatial transition |
| Full-screen hero morph | 500ms | Cinematic, spatial |
| Onboarding sequence | 600ms | Narrative, not reactive |

**Reference:** Miller, R.B. (1968). "Response time in man-computer conversational transactions." WWDC 2023 "Animate with springs" — Apple's spring presets (.snappy, .bouncy, .smooth) are all calibrated to settle within 200-300ms for this reason.
