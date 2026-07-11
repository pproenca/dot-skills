---
title: Model graphs with an owning map and ID handles, not references
tags: own, ids, handles, graphs
---

## Model graphs with an owning map and ID handles, not references

A struct that tries to hold `&'a Node` references to its own contents — or `Rc<RefCell<Node>>` webs standing in for pointers — is the C/GC graph shape that Rust's ownership model rejects outright: self-referential structs won't borrow-check, and the `Rc` web pays the costs described in `own-no-rc-refcell-object-graph`. The idiomatic shape puts every node in one owning collection and stores edges as ID handles — a newtype key resolved through the owner on demand. Handles are cheap to pass around, never dangle into freed memory, serialize for free, and one `&mut` on the owner mutates any node without interior mutability.

```rust
use std::collections::HashMap;

#[derive(Clone, PartialEq, Eq, Hash)]
struct CrateId(String);

struct DepGraph {
    crates: HashMap<CrateId, CrateNode>, // one owner for every node
}

struct CrateNode {
    version: String,
    depends_on: Vec<CrateId>, // edges are handles, not pointers
}

impl DepGraph {
    fn node(&self, id: &CrateId) -> Option<&CrateNode> {
        self.crates.get(id)
    }

    fn add(&mut self, name: &str, version: String) -> CrateId {
        let id = CrateId(name.to_string());
        self.crates.insert(id.clone(), CrateNode { version, depends_on: Vec::new() });
        id
    }
}
```

The trade-off is honest: a stale ID is a `None` at lookup — a logic bug the compiler can't see, but one that surfaces as an explicit, local `Option` instead of a dangling pointer or a leaked cycle (mitigate by never removing nodes, or by treating a miss as a tombstone). For dense, hot graphs where hashing and `String` keys cost too much, the same shape compresses into a `Vec` arena with a `Copy` index newtype (`NodeId(u32)`) — the handles stay, only the owner's representation changes.

Reference: [Nick Cameron — Graphs and arena allocation](https://github.com/nrc/r4cppp/blob/master/graphs/README.md)
