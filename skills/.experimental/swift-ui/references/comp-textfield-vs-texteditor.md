---
title: Choose TextField vs TextEditor by Content Length
impact: HIGH
impactDescription: prevents poor text entry experience from wrong input type
tags: comp, textfield, texteditor, input, multiline
---

## Choose TextField vs TextEditor by Content Length

TextField is for single-line input. TextEditor is for multi-line content. Use the right component for the expected content length.

**Incorrect (TextField for long content):**

```swift
struct NoteEditor: View {
    @Binding var note: Note

    var body: some View {
        TextField("Note", text: $note.content)
            // Single line only, truncates long content
            // No scrolling, no line wrapping
            // Users can't see what they're typing
    }
}
```

**Correct (TextEditor for multi-line):**

```swift
struct NoteEditor: View {
    @Binding var note: Note
    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $note.content)
            .focused($isFocused)
            .frame(minHeight: 200)
            .scrollContentBackground(.hidden)
            .background(.background.secondary)
            .cornerRadius(8)
    }
}
```

**Use TextField for short input:**

```swift
struct LoginForm: View {
    @State private var email = ""

    var body: some View {
        TextField("Email", text: $email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
    }
}
```

**TextField with axis for expandable (iOS 16+):**

```swift
TextField("Message", text: $message, axis: .vertical)
    .lineLimit(1...5)  // Expands from 1 to 5 lines
```

**Decision matrix:**

| Content | Component |
|---------|-----------|
| Username, email | TextField |
| Search query | TextField |
| Password | SecureField |
| Notes, comments | TextEditor |
| Bio, description | TextEditor |

Reference: [Human Interface Guidelines - Text Fields](https://developer.apple.com/design/human-interface-guidelines/text-fields)
