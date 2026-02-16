---
title: Avoid Hamburger Menu Navigation
impact: HIGH
impactDescription: 50% lower discoverability than tab bars (Nielsen Norman research)
tags: anti, hamburger, tab-bar, discoverability
---

## Avoid Hamburger Menu Navigation

Hamburger menus hide primary navigation behind a tap, reducing feature discoverability by approximately 50% compared to visible tab bars (Nielsen Norman Group research). Apple's Human Interface Guidelines recommend `TabView` for top-level destinations. The mobile industry largely abandoned hamburger menus after 2015 when A/B tests at Facebook, Spotify, and others consistently showed that visible navigation increased engagement. On iPad, use `NavigationSplitView` with a persistent sidebar instead.

**Incorrect (custom hamburger/drawer menu for primary navigation):**

```swift
// BAD: Primary sections hidden behind a hamburger icon.
// Users must tap the icon, scan the list, then tap again.
// Nielsen Norman research shows ~50% lower task completion
// for hidden navigation vs. visible tab bars.
struct MainView: View {
    @State private var isDrawerOpen = false
    @State private var selectedSection: AppSection = .home

    var body: some View {
        ZStack {
            // Content area
            NavigationStack {
                selectedSection.rootView
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                withAnimation { isDrawerOpen.toggle() }
                            } label: {
                                Image(systemName: "line.horizontal.3") // Hamburger icon
                            }
                        }
                    }
            }

            // Side drawer overlay
            if isDrawerOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { isDrawerOpen = false }

                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(AppSection.allCases) { section in
                            Button(section.title) {
                                selectedSection = section
                                isDrawerOpen = false
                            }
                            .padding()
                        }
                        Spacer()
                    }
                    .frame(width: 280)
                    .background(.ultraThickMaterial)
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
        }
    }
}
```

**Correct (TabView for primary navigation, sidebar for iPad):**

```swift
// GOOD: All primary sections visible at all times via TabView.
// Users can see every section and switch with a single tap.
// On iPad, NavigationSplitView provides a persistent sidebar
// that matches platform conventions.
@Equatable
struct MainView: View {
    @State private var selectedTab: AppSection = .home
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .compact {
            // iPhone: tab bar with 3-5 visible sections
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView()
                }
                .tabItem { Label("Home", systemImage: "house") }
                .tag(AppSection.home)

                NavigationStack {
                    SearchView()
                }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(AppSection.search)

                NavigationStack {
                    FavoritesView()
                }
                .tabItem { Label("Favorites", systemImage: "heart") }
                .tag(AppSection.favorites)

                NavigationStack {
                    ProfileView()
                }
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(AppSection.profile)
            }
        } else {
            // iPad: persistent sidebar with NavigationSplitView
            NavigationSplitView {
                List(AppSection.allCases, selection: $selectedTab) { section in
                    Label(section.title, systemImage: section.icon)
                }
            } detail: {
                selectedTab.rootView
            }
        }
    }
}
```
