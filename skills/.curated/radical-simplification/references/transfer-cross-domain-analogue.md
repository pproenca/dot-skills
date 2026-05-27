---
title: Find a structurally identical solved problem in another domain
tags: transfer, hofstadter, analogy
---

## Find a structurally identical solved problem in another domain

The default failure mode is staying inside the domain: a webhook problem is "solved" with webhook-y patterns, a database problem with database-y patterns. But most problems have *structural twins* in domains where someone has already done the hard work — and the twin's vocabulary often points to a much simpler design than the home domain offers.

```text
Problem: deduplicate webhook deliveries — the receiver may see the same
event twice if our delivery service retries after the receiver already
processed it.

Stay-in-domain answer: build a "delivered events" table at the sender,
mark each delivery as it goes out, check on retry.

Cross-domain analogue: this is exactly TCP's retransmit problem.
TCP solves it with:
  - sequence numbers (monotonic IDs per stream)
  - the receiver dedupes by sequence number
  - the sender retries until acked

Applied back to webhooks:
  - sender attaches a per-stream monotonic event_id
  - receiver stores last_processed_event_id per stream and ignores duplicates
  - sender retries on missing ack

The TCP version pushes dedup state to the receiver (where it belongs:
the receiver knows what it has processed). The stay-in-domain version
put it at the sender and would have failed when the receiver was
replaced or its DB was restored from a snapshot.
```

Useful prompts to invoke the search: "where else does someone process events that might arrive twice?" (TCP, idempotent HTTP, message queues, double-entry accounting). "Where else is this kind of constraint enforced?" (databases, type systems, physics conservation laws). Pattern-matching across domains is what Hofstadter calls "the fuel and fire of thinking" — it is also the source of most elegant designs.

Reference: [Hofstadter & Sander — Surfaces and Essences (Basic Books, 2013)](https://www.basicbooks.com/titles/douglas-hofstadter/surfaces-and-essences/9780465018475/)
