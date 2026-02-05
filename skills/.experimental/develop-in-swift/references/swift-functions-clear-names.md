---
title: Name Functions and Parameters for Clarity
impact: HIGH
impactDescription: code reads like natural language, self-documenting, matches Apple API style
tags: swift, functions, parameters, naming, readability
---

## Name Functions and Parameters for Clarity

Swift functions should read like natural language at the call site. Use argument labels that create grammatically correct phrases, and omit labels with `_` when the function name is clear enough.

**Incorrect (unclear or verbose):**

```swift
// Unclear what the string parameter means
func add(s: String) {
    movies.append(Movie(title: s))
}
add(s: "Difficult Cat")  // What is 's'?

// Redundant label
func addMovie(movie title: String) {
    movies.append(Movie(title: title))
}
addMovie(movie: "Difficult Cat")  // "movie" is redundant with function name
```

**Correct (reads naturally at call site):**

```swift
// Omit label when function name is clear
func addMovie(_ title: String) {
    let newMovie = Movie(title: title)
    movies.append(newMovie)
}
addMovie("Difficult Cat")  // Reads naturally

// Use labels for clarity when needed
func move(from source: Int, to destination: Int) {
    // Implementation
}
move(from: 0, to: 5)  // "move from 0 to 5" reads naturally

// Multiple parameters with meaningful labels
func greet(_ name: String, withMessage message: String) {
    print("\(message), \(name)!")
}
greet("Sophie", withMessage: "Hello")  // Clear meaning
```

**Swift parameter naming rules:**
- Use `_` for first parameter when function name provides context
- Use argument labels that create grammatical phrases
- External name (label) can differ from internal name (parameter)
- Make call sites read like English sentences

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)
