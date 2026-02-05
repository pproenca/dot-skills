---
title: Extract Subviews to Reduce Body Complexity
impact: CRITICAL
impactDescription: reduces body from 50+ lines to 5-10, improves readability and reuse
tags: comp, swiftui, refactoring, readability, reuse
---

## Extract Subviews to Reduce Body Complexity

A bloated `body` property makes it difficult to reason about layout, slows down Xcode previews, and prevents reuse of UI sections. Extracting logical sections into dedicated child views keeps each component focused and testable in isolation.

**Incorrect (entire profile screen in a single body):**

```swift
struct ProfileScreen: View {
    let username: String
    let bio: String
    let followerCount: Int
    let postCount: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.blue)
                Text(username)
                    .font(.title2).bold()
                Text(bio)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                HStack(spacing: 32) {
                    VStack {
                        Text("\(followerCount)")
                            .font(.headline)
                        Text("Followers")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    VStack {
                        Text("\(postCount)")
                            .font(.headline)
                        Text("Posts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}
```

**Correct (body delegates to extracted child views):**

```swift
struct ProfileScreen: View {
    let username: String
    let bio: String
    let followerCount: Int
    let postCount: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ProfileAvatar()
                ProfileInfo(username: username, bio: bio)
                ProfileStats(followerCount: followerCount, postCount: postCount)
            }
            .padding()
        }
    }
}

struct ProfileAvatar: View {
    var body: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 80, height: 80)
            .foregroundStyle(.blue)
    }
}

struct ProfileInfo: View {
    let username: String
    let bio: String

    var body: some View {
        VStack(spacing: 4) {
            Text(username)
                .font(.title2).bold()
            Text(bio)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct ProfileStats: View {
    let followerCount: Int
    let postCount: Int

    var body: some View {
        HStack(spacing: 32) {
            StatColumn(value: "\(followerCount)", label: "Followers")
            StatColumn(value: "\(postCount)", label: "Posts")
        }
    }
}

struct StatColumn: View { // reusable across screens
    let value: String
    let label: String

    var body: some View {
        VStack {
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
