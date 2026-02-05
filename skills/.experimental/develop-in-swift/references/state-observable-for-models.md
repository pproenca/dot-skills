---
title: Use @Observable for Shared Model Classes
impact: CRITICAL
impactDescription: granular property tracking, shared state across views, modern replacement for ObservableObject
tags: state, swiftui, observable, observation, ios17, shared-state
---

## Use @Observable for Shared Model Classes

The `@Observable` macro (iOS 17+) makes classes observable with automatic property tracking. SwiftUI only re-renders views that read changed properties. Use `@Observable` for model classes shared across multiple views.

**Incorrect (older ObservableObject pattern):**

```swift
// Pre-iOS 17 pattern - more boilerplate, less granular updates
class GameModel: ObservableObject {
    @Published var currentWord = ""
    @Published var score = 0
    @Published var guessedLetters: Set<Character> = []
}

struct GameView: View {
    @StateObject var game = GameModel()  // Old pattern
    // ...
}
```

**Correct (@Observable for modern apps):**

```swift
@Observable
class GameModel {
    var currentWord = ""
    var score = 0
    var guessedLetters: Set<Character> = []

    func guess(_ letter: Character) {
        guessedLetters.insert(letter)
        if currentWord.contains(letter) {
            score += 10
        }
    }
}

struct GameView: View {
    @State var game = GameModel()  // Use @State with @Observable

    var body: some View {
        VStack {
            Text("Score: \(game.score)")  // Only updates when score changes
            Text(game.currentWord)  // Only updates when word changes

            Button("Guess A") {
                game.guess("A")
            }
        }
    }
}

// Share model across views
struct ScoreboardView: View {
    var game: GameModel  // No wrapper needed for read-only

    var body: some View {
        Text("Score: \(game.score)")
    }
}
```

**@Observable migration:**
- `ObservableObject` → `@Observable`
- Remove `@Published` wrappers
- `@StateObject` → `@State`
- `@ObservedObject` → pass object directly

Reference: [Develop in Swift Tutorials - Complete a game with logic](https://developer.apple.com/tutorials/develop-in-swift/complete-a-game-with-logic)
