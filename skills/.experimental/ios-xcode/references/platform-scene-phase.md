---
title: Respond to App Lifecycle with ScenePhase
impact: MEDIUM
impactDescription: save state, pause work, refresh on foreground
tags: platform, scenephase, lifecycle, background, foreground
---

## Respond to App Lifecycle with ScenePhase

ScenePhase tells you when your app moves between active, inactive, and background states. Use it to save state and manage resources.

**Incorrect (not responding to lifecycle):**

```swift
struct GameView: View {
    @State private var gameState: GameState

    var body: some View {
        GameBoard(state: gameState)
        // Game continues running when app is backgrounded
        // State lost if terminated
    }
}
```

**Correct (handling lifecycle):**

```swift
struct GameView: View {
    @State private var gameState: GameState
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GameBoard(state: gameState)
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    resumeGame()
                case .inactive:
                    pauseGame()
                case .background:
                    saveGameState()
                @unknown default:
                    break
                }
            }
    }

    private func saveGameState() {
        // Persist to disk before termination
        try? JSONEncoder().encode(gameState).write(to: saveURL)
    }
}
```

**Scene phases:**

```swift
.active      // App is in foreground and interactive
.inactive    // App is visible but not interactive (e.g., during app switcher)
.background  // App is not visible
```

**Common use cases:**

```swift
.onChange(of: scenePhase) { _, phase in
    switch phase {
    case .active:
        // Refresh data that might be stale
        refreshContent()
        // Resume timers
        timer.resume()

    case .inactive:
        // Pause video/audio
        player.pause()
        // Stop animations
        isAnimating = false

    case .background:
        // Save unsaved changes
        saveDocument()
        // Cancel non-essential network requests
        networkManager.cancelPendingRequests()
        // Clear sensitive data from memory
        clearCachedCredentials()

    @unknown default:
        break
    }
}
```

**App-level vs View-level:**

```swift
@main
struct MyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, phase in
            // App-wide lifecycle handling
        }
    }
}
```

Reference: [ScenePhase Documentation](https://developer.apple.com/documentation/swiftui/scenephase)
