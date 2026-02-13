---
title: Avoid Programmatic Tab Selection Changes
impact: MEDIUM
impactDescription: violates user expectations, causes disorientation
tags: anti, tab-view, selection, user-expectations
---

## Avoid Programmatic Tab Selection Changes

Apple's Human Interface Guidelines state that tabs should not change programmatically without direct user action. When the app switches tabs in response to server events, timers, or background state changes, users lose spatial context -- they cannot predict where they will end up, and their mental model of the app's layout breaks. Instead, use badges, indicators, or in-tab banners to draw attention to other tabs while leaving the user in control of navigation.

**Incorrect (tab switches automatically based on external events):**

```swift
// BAD: The selected tab changes without user interaction.
// A push notification or timer fires and yanks the user
// to a different tab, losing their scroll position and
// context in the current tab. This is disorienting.
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject private var notificationHandler: NotificationHandler

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

            MessagesView()
                .tabItem { Label("Messages", systemImage: "message") }
                .tag(Tab.messages)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(Tab.settings)
        }
        .onReceive(notificationHandler.deepLinkPublisher) { link in
            // Forcefully switches tab without user consent
            switch link {
            case .newMessage:
                selectedTab = .messages   // User is yanked away
            case .settingsUpdate:
                selectedTab = .settings   // User loses context
            default:
                break
            }
        }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
            // Even worse: periodic forced tab switch
            if notificationHandler.unreadCount > 0 {
                selectedTab = .messages // Switches every 30 seconds
            }
        }
    }
}
```

**Correct (user controls tab selection; badges draw attention):**

```swift
// GOOD: The user is always in control of which tab is active.
// Deep links and events update badge counts and in-tab banners
// to guide the user's attention without forcefully switching context.
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject private var notificationHandler: NotificationHandler

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

            MessagesView()
                .tabItem { Label("Messages", systemImage: "message") }
                .badge(notificationHandler.unreadCount) // Visual indicator
                .tag(Tab.messages)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .badge(notificationHandler.hasSettingsUpdate ? "!" : nil)
                .tag(Tab.settings)
        }
        .onReceive(notificationHandler.deepLinkPublisher) { link in
            // Update badge state, but never force-switch the tab.
            // If the user is already on the target tab, navigate
            // within that tab's stack instead.
            switch link {
            case .newMessage:
                notificationHandler.incrementUnread()
                if selectedTab == .messages {
                    // User is already here — push the conversation
                    notificationHandler.pendingConversationId = link.conversationId
                }
            case .settingsUpdate:
                notificationHandler.hasSettingsUpdate = true
            default:
                break
            }
        }
    }
}
```

**When NOT to use this pattern:**
- Programmatic tab switching IS appropriate when the user directly initiated the action, such as tapping a deep link, notification, or universal link. The anti-pattern is switching tabs from background events, timers, or server pushes without any user gesture.
- Apple's own apps (Messages, Mail) switch tabs when resolving user-tapped deep links.
