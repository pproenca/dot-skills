---
title: Extract Subviews to Create Diffing Checkpoints
impact: HIGH
impactDescription: skips re-evaluation of unchanged branches, 2-5x body reduction
tags: view, subview, extraction, diffing, performance, composition, readability
---

## Extract Subviews to Create Diffing Checkpoints

SwiftUI compares a subview's inputs before calling its body. When you extract a section into its own struct, SwiftUI can skip re-evaluating that entire branch if its inputs haven't changed. Massive monolithic bodies force the framework to re-evaluate every line on every state change, even when only a small part of the data has been modified.

**Incorrect (monolithic body re-evaluates everything on any state change):**

```swift
struct EventDetailView: View {
    @State private var event: Event
    @State private var isRSVPed: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: event.coverImageURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: { Color.gray }
                    .frame(height: 240).clipped()
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title).font(.title).bold().foregroundStyle(.white)
                        Text(event.venue).font(.subheadline).foregroundStyle(.white.opacity(0.8))
                    }
                    .padding()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(event.date, style: .date).font(.headline)
                        Text(event.date, style: .time).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(isRSVPed ? "Going" : "RSVP") { isRSVPed.toggle() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
                VStack(alignment: .leading, spacing: 8) {
                    Text("About").font(.title3).bold()
                    Text(event.description).font(.body).foregroundStyle(.secondary)
                }
                .padding()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Attendees (\(event.attendees.count))").font(.title3).bold()
                    ForEach(event.attendees) { attendee in
                        HStack {
                            AsyncImage(url: attendee.avatarURL) { image in
                                image.resizable()
                            } placeholder: { Circle().fill(.gray) }
                            .frame(width: 36, height: 36).clipShape(Circle())
                            Text(attendee.name)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
```

**Correct (subviews create diffing checkpoints that skip unchanged branches):**

```swift
struct EventDetailView: View {
    @State private var event: Event
    @State private var isRSVPed: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                EventCoverHeader(title: event.title, venue: event.venue,
                                 coverImageURL: event.coverImageURL)
                EventDateRow(date: event.date, isRSVPed: $isRSVPed)
                EventDescription(text: event.description)
                AttendeesList(attendees: event.attendees)
            }
        }
    }
}

struct EventCoverHeader: View {
    let title: String
    let venue: String
    let coverImageURL: URL?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: coverImageURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(height: 240)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title).bold().foregroundStyle(.white)
                Text(venue).font(.subheadline).foregroundStyle(.white.opacity(0.8))
            }
            .padding()
        }
    }
}
```

**Multi-level extraction for complex screens:**

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

**Extraction guidelines:**
- Each view should have a single responsibility
- Extract when a section exceeds 30-40 lines
- Extract repeated patterns immediately
- Group by semantic meaning, not arbitrary line counts
- SwiftUI diffs smaller view trees more efficiently
- Subviews are easier to test individually and promote reuse across screens

Reference: [Demystify SwiftUI performance - WWDC23](https://developer.apple.com/videos/play/wwdc2023/10160/)
