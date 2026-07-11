---
title: Model graphs with an arena and index handles, not references
tags: own, arena, indices, graphs
---

## Model graphs with an arena and index handles, not references

A struct that tries to hold `&'a Node` references to its own contents — or `Rc<RefCell<Node>>` webs standing in for pointers — is the C/GC graph shape that Rust's ownership model rejects outright: self-referential structs won't borrow-check, and the `Rc` web pays the costs described in `own-no-rc-refcell-object-graph`. The idiomatic shape is an arena — a `Vec` that owns every node — with edges stored as index newtypes. Indices are `Copy`, never dangle into freed memory, serialize for free, and one `&mut` on the arena mutates any node without interior mutability.

```rust
#[derive(Clone, Copy, PartialEq, Eq)]
struct NodeId(u32);

struct DepGraph {
    nodes: Vec<Node>, // the arena owns everything
}

struct Node {
    crate_name: String,
    depends_on: Vec<NodeId>, // edges are handles, not pointers
}

impl DepGraph {
    fn node(&self, id: NodeId) -> &Node {
        &self.nodes[id.0 as usize]
    }

    fn add(&mut self, crate_name: String) -> NodeId {
        let id = NodeId(self.nodes.len() as u32);
        self.nodes.push(Node { crate_name, depends_on: Vec::new() });
        id
    }
}
```

The trade-off is honest: a stale `NodeId` is a logic bug the compiler can't see (mitigate by never removing nodes, or by generational indices). That is a far smaller cost than the lifetime contortions or leak-prone `Rc` web it replaces.

Reference: [Nick Cameron — Graphs and arena allocation](https://github.com/nrc/r4cppp/blob/master/graphs/README.md)
