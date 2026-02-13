---
title: Group Related Navigation Elements to Reduce Swipe Count
impact: MEDIUM
impactDescription: reduces VoiceOver swipes by 50-70% per row
tags: ally, voiceover, grouping, combine, label
---

## Group Related Navigation Elements to Reduce Swipe Count

List rows with multiple text, image, and icon elements require one VoiceOver swipe per element. A row with an avatar, title, subtitle, timestamp, and chevron costs 5 swipes just to traverse one row — in a 20-row list, that is 100 swipes to scan the screen. Combining related elements into a single accessibility element with a descriptive label reduces this to 1 swipe per row (20 total), conveying the same information 5x faster.

**Incorrect (each sub-element is a separate VoiceOver stop):**

```swift
struct ConversationListView: View {
    let conversations: [Conversation]

    var body: some View {
        NavigationStack {
            List(conversations) { conversation in
                NavigationLink(value: conversation) {
                    // BAD: VoiceOver treats each child as a separate element.
                    // Swipe sequence: "Avatar" -> "John Smith" -> "Hey, are you..."
                    // -> "2m ago" -> "Unread badge" = 5 swipes per row.
                    // 20 conversations * 5 swipes = 100 swipes to scan the list.
                    HStack(spacing: 12) {
                        AsyncImage(url: conversation.avatarURL)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(conversation.senderName)
                                .font(.headline)
                            Text(conversation.lastMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text(conversation.timeAgo)
                                .font(.caption)
                            if conversation.isUnread {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                }
            }
        }
    }
}
```

**Correct (elements combined into a single VoiceOver stop):**

```swift
struct ConversationListView: View {
    let conversations: [Conversation]

    var body: some View {
        NavigationStack {
            List(conversations) { conversation in
                NavigationLink(value: conversation) {
                    HStack(spacing: 12) {
                        AsyncImage(url: conversation.avatarURL)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(conversation.senderName)
                                .font(.headline)
                            Text(conversation.lastMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text(conversation.timeAgo)
                                .font(.caption)
                            if conversation.isUnread {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                    // Combine all children into ONE VoiceOver element.
                    // 1 swipe per row instead of 5. 20 swipes for 20 rows.
                    .accessibilityElement(children: .combine)
                    // Override the auto-combined label for clarity.
                    // VoiceOver reads: "John Smith, Hey are you free tomorrow, 2 minutes ago, unread"
                    .accessibilityLabel(conversationAccessibilityLabel(conversation))
                }
            }
            .navigationDestination(for: Conversation.self) { conversation in
                ConversationDetailView(conversation: conversation)
            }
        }
    }

    // Build a human-readable label that conveys all row information
    // in a natural sentence structure for VoiceOver.
    private func conversationAccessibilityLabel(_ conversation: Conversation) -> String {
        var label = "\(conversation.senderName), \(conversation.lastMessage), \(conversation.timeAgo)"
        if conversation.isUnread {
            label += ", unread"
        }
        return label
    }
}
```
