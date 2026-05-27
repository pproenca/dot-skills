---
title: If the codebase can answer it, read the codebase — only ask what the source cannot tell you
tags: clarify, source-of-truth, pragmatic
---

## If the codebase can answer it, read the codebase — only ask what the source cannot tell you

The interview move (`clarify-interview-one-at-a-time`) only earns its keep on questions the user actually has to answer. Most "questions" the agent is tempted to ask are not those — they are observable facts about the codebase, the docs, or the runtime. Asking them treats the user's attention as free, signals that the agent has not done the work, and slows the loop. The default to correct: the agent reaches for `AskUserQuestion` before it reaches for `Grep`, `Read`, or running the program.

```text
Tempted to ask:
  Q: "What ORM does this project use?"
Should have done:
  Read package.json — answered in 2 seconds, no user round-trip.

Tempted to ask:
  Q: "What's the auth flow when the token expires?"
Should have done:
  Grep for "refresh" + "401" + the middleware path.

Tempted to ask:
  Q: "Does the production queue have at-least-once or exactly-once
      semantics?"
Should have done:
  Read the queue config / provider docs — observable fact.

Genuinely worth asking:
  Q: "If the second caller in Q3 sends a duplicate event,
      should we dedupe by event_id or accept the duplicate?"
  → A product/policy decision. The code does not contain
    the answer because the answer does not exist yet.
```

The discriminator is a one-line test: **does the answer already exist somewhere, or is it being decided now?** If it exists, find it. If it is being decided, ask — and pair the question with your recommendation per `clarify-interview-one-at-a-time`. The pathological mix is the worst of both: a wall of questions where three are observable from `package.json`, two are answered in the README, and the one real product decision is buried at the bottom where the user has already lost patience.

A useful trigger: before sending any question to the user, run the test "could I have answered this with a five-second grep, file read, or runtime check?" If yes, do that first. If no, the question is real and belongs in the interview.

Reference: [Hunt & Thomas — The Pragmatic Programmer, "DRY: every piece of knowledge must have a single, unambiguous, authoritative representation within a system" (Addison-Wesley, 1999)](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/)
