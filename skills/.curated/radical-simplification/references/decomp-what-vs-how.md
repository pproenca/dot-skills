---
title: Specify WHAT before implementing HOW
tags: decomp, lamport, dijkstra, specification
---

## Specify WHAT before implementing HOW

When specification and implementation are fused, the agent argues about Raft vs. Paxos before it has agreed what "the leader" means. The result is a debate where both sides are right about different problems. Write the WHAT — the externally observable properties — in a paragraph the customer of the code could read, before any line of HOW. The HOW debate then has a referee.

```text
Task: "implement leader election."

WHAT (the spec, ~5 lines, language-independent):
  - At most one node is leader at any moment when the network is stable.
  - A leader is elected within T seconds of the previous leader's last heartbeat.
  - Clients can ask any node who the leader is; the answer is either
    correct or "I don't know" (never wrong).
  - Network partition: minority side returns "I don't know"; majority elects.

HOW (after the spec is agreed):
  - Lease-based: simple, requires loosely synced clocks. ✓ fits.
  - Raft: stronger guarantees we don't need. ✗ over-engineered for this.
  - Paxos: same. ✗.

  Picked: leases. The WHAT made the choice obvious; without it, all three
  felt defensible because each is correct for a *different* spec.
```

A useful tell: if the agent cannot write the WHAT in 5 lines without referring to the HOW, the problem is not yet understood. Stop and write it.

Reference: [Lamport — State the Problem Before Describing the Solution (ACM SIGSOFT Software Engineering Notes, 1978)](https://www.microsoft.com/en-us/research/publication/state-the-problem-before-presenting-the-solution/)
