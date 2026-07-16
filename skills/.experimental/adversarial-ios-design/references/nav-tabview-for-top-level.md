---
title: Use a tab bar for top-level sections, not a drawer or button grid
tags: nav, tab-bar, information-architecture, drawer
---

## Use a tab bar for top-level sections, not a drawer or button grid

The wrong default for an app with several peer sections is a hamburger-toggled side drawer or a home screen of navigation buttons — patterns imported from the web and Android. Both hide the app's structure behind an extra tap, so users never form a map of what the app contains, and neither preserves per-section state the way the system tab bar does. An app whose top level is 2–5 peer areas gets a `TabView`; the tab bar names every section, stays reachable from anywhere, and switches instantly.

**Evidence of violation:** the root scene implements a custom side drawer — a `ZStack` (or offset/transition pair) whose leading panel of section links is toggled by a menu button such as `Image(systemName: "line.3.horizontal")` — or the only top-level switcher is a grid or list of `NavigationLink`s to peer sections, with no `TabView` anywhere in the scene. PASS: the root scene is a `TabView` containing a `Tab` per section — cite the root body; a genuinely single-section app whose screens form one hierarchy under a single `NavigationStack` also passes — cite the root. N/A: a single-screen utility with no peer sections to switch between.

**Incorrect (sections hidden behind a hamburger, no persistent orientation):**

```swift
import SwiftUI

struct TrailheadRootView: View {
    @State private var isDrawerOpen = false

    var body: some View {
        ZStack(alignment: .leading) {
            NavigationStack { HikeFeedView() }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        // ⚠️ Hamburger drawer as the app's only top-level navigation
                        Button {
                            isDrawerOpen.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                    }
                }

            if isDrawerOpen {
                List {
                    NavigationLink("Hikes") { HikeFeedView() }
                    NavigationLink("Maps") { TrailMapView() }
                    NavigationLink("Badges") { BadgeGalleryView() }
                    NavigationLink("Profile") { HikerProfileView() }
                }
                .frame(width: 280)
                .transition(.move(edge: .leading))
            }
        }
    }
}
```

**Correct (every section named, visible, and one tap away):**

```swift
import SwiftUI

struct TrailheadRootView: View {
    var body: some View {
        TabView {
            Tab("Hikes", systemImage: "figure.hiking") {
                NavigationStack { HikeFeedView() }
            }
            Tab("Maps", systemImage: "map") {
                NavigationStack { TrailMapView() }
            }
            Tab("Badges", systemImage: "medal") {
                NavigationStack { BadgeGalleryView() }
            }
            Tab("Profile", systemImage: "person.crop.circle") {
                NavigationStack { HikerProfileView() }
            }
        }
    }
}
```

Reference: [HIG — Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars), [HIG — Sidebars](https://developer.apple.com/design/human-interface-guidelines/sidebars)
