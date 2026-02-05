---
title: Extract Subviews for Composition
impact: HIGH
impactDescription: reduces body complexity, enables SwiftUI diffing optimization
tags: view, extraction, composition, performance, readability
---

## Extract Subviews for Composition

Large view bodies hurt performance and readability. Extract logical sections into separate views. SwiftUI can then diff smaller units efficiently.

**Incorrect (monolithic 200-line body):**

```swift
struct ProfileView: View {
    let user: User

    var body: some View {
        ScrollView {
            VStack {
                // Header section - 30 lines
                ZStack {
                    Image(user.coverPhoto)
                    VStack {
                        AsyncImage(url: user.avatarURL)
                        Text(user.name)
                        Text(user.bio)
                        // ... more header code
                    }
                }

                // Stats section - 40 lines
                HStack {
                    VStack {
                        Text("\(user.followers)")
                        Text("Followers")
                    }
                    // ... more stats
                }

                // Posts section - 50 lines
                ForEach(user.posts) { post in
                    // ... complex post layout
                }

                // ... 80 more lines
            }
        }
    }
}
```

**Correct (composed from subviews):**

```swift
struct ProfileView: View {
    let user: User

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ProfileHeader(user: user)
                ProfileStats(user: user)
                ProfilePostsGrid(posts: user.posts)
            }
        }
    }
}

struct ProfileHeader: View {
    let user: User

    var body: some View {
        ZStack(alignment: .bottom) {
            CoverImage(url: user.coverPhotoURL)
            AvatarWithName(user: user)
        }
    }
}

struct ProfileStats: View {
    let user: User

    var body: some View {
        HStack(spacing: 32) {
            StatItem(value: user.followers, label: "Followers")
            StatItem(value: user.following, label: "Following")
            StatItem(value: user.posts.count, label: "Posts")
        }
    }
}
```

**Benefits:**
- Each view has a single responsibility
- SwiftUI diffs smaller view trees
- Easier to test individual components
- Promotes reuse across screens

**Extraction guidelines:**
- Extract when a section exceeds 30-40 lines
- Extract repeated patterns immediately
- Group by semantic meaning, not arbitrary line counts

Reference: [Airbnb SwiftUI Performance](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896)
