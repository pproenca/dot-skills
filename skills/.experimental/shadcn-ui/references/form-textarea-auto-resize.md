---
title: Use Auto-Resizing Textarea for Long-Form Input
impact: MEDIUM
impactDescription: improves UX by expanding to fit content
tags: form, textarea, auto-resize, ux, input
---

## Use Auto-Resizing Textarea for Long-Form Input

Configure Textarea to auto-resize based on content. Fixed-height textareas force users to scroll within small boxes.

**Incorrect (fixed height textarea):**

```tsx
import { Textarea } from "@/components/ui/textarea"

function CommentInput() {
  return (
    <Textarea
      placeholder="Write your comment..."
      className="h-20"  // Fixed height, scrolls internally
    />
  )
}
```

**Correct (auto-resizing textarea):**

```tsx
import { Textarea } from "@/components/ui/textarea"
import { useRef, useEffect } from "react"

function CommentInput() {
  const textareaRef = useRef<HTMLTextAreaElement>(null)

  const handleInput = () => {
    const textarea = textareaRef.current
    if (textarea) {
      textarea.style.height = "auto"
      textarea.style.height = `${textarea.scrollHeight}px`
    }
  }

  return (
    <Textarea
      ref={textareaRef}
      placeholder="Write your comment..."
      onInput={handleInput}
      className="min-h-[80px] resize-none"  // Minimum height, no manual resize
    />
  )
}
```

**With max height constraint:**

```tsx
<Textarea
  ref={textareaRef}
  onInput={handleInput}
  className="min-h-[80px] max-h-[300px] resize-none overflow-y-auto"
/>
```

Reference: [shadcn/ui Textarea](https://ui.shadcn.com/docs/components/textarea)
