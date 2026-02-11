---
title: Use Ref Access Patterns That Enable Compilation
impact: CRITICAL
impactDescription: maintains compiler optimization for ref-using components
tags: compiler, refs, bailout, dom
---

## Use Ref Access Patterns That Enable Compilation

Reading `ref.current` during the render phase causes a compiler bailout because refs are mutable containers that break the purity assumption. The compiler cannot cache a render whose output depends on a value that changes outside React's control. Move all ref reads to effects, event handlers, or layout callbacks where the DOM is stable.

**Incorrect (ref reads in render cause compiler bailout):**

```tsx
function ChatMessages({ messages }: { messages: Message[] }) {
  const scrollRef = useRef<HTMLDivElement>(null)
  const prevCountRef = useRef(messages.length)

  // Bailout: reading ref.current during render
  const isAtBottom =
    scrollRef.current !== null &&
    scrollRef.current.scrollHeight - scrollRef.current.scrollTop <=
      scrollRef.current.clientHeight + 50

  // Bailout: reading and writing ref in render
  const hasNewMessages = messages.length > prevCountRef.current
  prevCountRef.current = messages.length

  return (
    <div ref={scrollRef}>
      {messages.map((message) => (
        <ChatBubble key={message.id} message={message} />
      ))}
      {hasNewMessages && isAtBottom && <ScrollAnchor />}
    </div>
  )
}
```

**Correct (ref reads moved to effects and callbacks):**

```tsx
function ChatMessages({ messages }: { messages: Message[] }) {
  const scrollRef = useRef<HTMLDivElement>(null)
  const [isAtBottom, setIsAtBottom] = useState(true)
  const [hasNewMessages, setHasNewMessages] = useState(false)
  const prevCountRef = useRef(messages.length)

  useEffect(() => {
    setHasNewMessages(messages.length > prevCountRef.current)
    prevCountRef.current = messages.length
  }, [messages.length])

  useEffect(() => {
    const element = scrollRef.current
    if (!element) return

    const checkScroll = () => {
      setIsAtBottom(
        element.scrollHeight - element.scrollTop <= element.clientHeight + 50
      )
    }

    checkScroll()
    element.addEventListener("scroll", checkScroll, { passive: true })
    return () => element.removeEventListener("scroll", checkScroll)
  }, [])

  return (
    <div ref={scrollRef}>
      {messages.map((message) => (
        <ChatBubble key={message.id} message={message} />
      ))}
      {hasNewMessages && isAtBottom && <ScrollAnchor />}
    </div>
  )
}
```

Reference: [React — Referencing Values with Refs](https://react.dev/learn/referencing-values-with-refs)
