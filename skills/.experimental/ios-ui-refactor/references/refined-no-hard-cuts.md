---
title: Always Animate Between States, Even Minimally
impact: HIGH
impactDescription: hard cuts between loading, loaded, empty, and error states feel like rendering bugs — even a 200ms opacity fade eliminates perceived jank
tags: refined, animation, state-change, edson-prototype, rams-3, transition
---

## Always Animate Between States, Even Minimally

Edson's iterative refinement demands that no state transition go unpolished. A hard cut from loading to loaded is the unfinished version — the version before someone prototyped the transition. Rams' aesthetic principle: even a 200ms opacity fade transforms a perceived bug into an intentional design decision.

**Incorrect (hard cut between loading and loaded states):**

```swift
struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if posts.isEmpty {
                ContentUnavailableView("No Posts",
                    systemImage: "text.bubble",
                    description: Text("Follow people to see their posts."))
            } else {
                // Content appears instantly — jarring snap from spinner
                List(posts) { post in
                    PostRow(post: post)
                }
            }
        }
        .task {
            posts = await fetchPosts()
            // Hard cut: isLoading flips with no animation
            isLoading = false
        }
    }
}
```

**Correct (animated transitions between all states):**

```swift
struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .transition(.opacity)
            } else if posts.isEmpty {
                ContentUnavailableView("No Posts",
                    systemImage: "text.bubble",
                    description: Text("Follow people to see their posts."))
                    .transition(.opacity)
            } else {
                List(posts) { post in
                    PostRow(post: post)
                }
                .transition(.opacity)
            }
        }
        // Wrap the entire conditional in an animation scope
        .animation(.smooth(duration: 0.3), value: isLoading)
        .animation(.smooth(duration: 0.3), value: posts.isEmpty)
        .task {
            posts = await fetchPosts()
            isLoading = false
        }
    }
}
```

**Transition patterns by context:**
| State change | Recommended transition |
|---|---|
| Loading to loaded | `.opacity` — content fades in as spinner fades out |
| Empty to populated | `.opacity` or `.blurReplace` (iOS 18) for a softer reveal |
| Error to retry/success | `.opacity` combined with `.offset` for a gentle slide-in |
| Item insertion/removal in a list | `.move(edge:)` combined with `.opacity` for list animations |
| Tab or segment switch | `.opacity` to crossfade content areas |

**Alternative (iOS 18 content transition for text and images):**

```swift
Text(statusMessage)
    .contentTransition(.numericText())
    .animation(.smooth, value: statusMessage)
```

**When NOT to use:**
- Users with Reduce Motion enabled — always respect `AccessibilityReduceMotion` by falling back to `.opacity` with shorter duration, or no animation at all
- Real-time data displays (stock tickers, live scores) where constant animation becomes distracting — use `contentTransition(.numericText())` instead of full view transitions

**Reference:** Apple HIG — Motion, WWDC 2023 "Animate with springs" — recommends that every state change include at least a spring-driven opacity transition.
