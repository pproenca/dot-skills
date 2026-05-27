---
title: Use Intention-Revealing Names
impact: MEDIUM-HIGH
impactDescription: Descriptive names reduce code review time by 30-40% and eliminate the need for explanatory comments
tags: name, readability, self-documenting, clarity
---

## Use Intention-Revealing Names

Names should answer why something exists, what it does, and how it is used. If a name requires a comment to explain its purpose, the name itself should be improved. Good names make code self-documenting, reducing cognitive load and preventing misuse.

**Incorrect (names require comments to understand):**

```typescript
// Bad: What does 'd' represent?
const d = 86400000; // milliseconds in a day

function calc(a: number[], f: number): number {
  // Bad: What is being calculated? What are a and f?
  return a.filter(x => x > f).length;
}

// Bad: What does this list contain?
const list = getUsers();
```

**Correct (names reveal intent):**

```typescript
const MILLISECONDS_PER_DAY = 86400000;

function countItemsAboveThreshold(items: number[], threshold: number): number {
  return items.filter(item => item > threshold).length;
}

const activeUsers = getActiveUsers();
```

**Incorrect (Python - cryptic names):**

```python
# Bad: What is being processed?
def proc(d, t):
    r = []
    for i in d:
        if i['ts'] > t:
            r.append(i)
    return r
```

**Correct (Python - intention-revealing):**

```python
def filter_events_after_timestamp(events, cutoff_timestamp):
    recent_events = []
    for event in events:
        if event['timestamp'] > cutoff_timestamp:
            recent_events.append(event)
    return recent_events
```

**Incorrect (Go - opaque abbreviations):**

```go
// Bad: What does this function do?
func proc(c *Ctx, req *Req) (*Resp, error) {
    u := c.GetU()
    if u == nil {
        return nil, ErrNA
    }
    return &Resp{D: u.D}, nil
}
```

**Correct (Go - clear purpose):**

```go
func fetchUserProfile(ctx *RequestContext, request *ProfileRequest) (*ProfileResponse, error) {
    currentUser := ctx.GetAuthenticatedUser()
    if currentUser == nil {
        return nil, ErrNotAuthenticated
    }
    return &ProfileResponse{DisplayName: currentUser.DisplayName}, nil
}
```

### When NOT to Apply

- Loop indices (`i`, `j`, `k`) in simple iterations where scope is tiny
- Mathematical formulas where single-letter variables are conventional (e.g., `x`, `y` for coordinates)
- Lambda parameters in very short, obvious transformations

### Benefits

- Code becomes self-documenting
- Eliminates need for explanatory comments
- Reduces onboarding time for new developers
- Makes code review faster and more effective
- Prevents bugs caused by misunderstanding variable purpose
