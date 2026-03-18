---
title: Avoid Creating Single-Use Helper Methods
impact: HIGH
impactDescription: reduces indirection and keeps logic close to its usage
tags: mod, helpers, indirection, code-organization
---

## Avoid Creating Single-Use Helper Methods

Do not create small helper methods that are referenced only once. Single-use helpers add indirection without reuse benefit, forcing readers to jump between definitions. Inline the logic at the call site unless it is genuinely reused or the extraction significantly improves readability of a complex function.

**Incorrect (helper called from exactly one place):**

```rust
impl ThreadManager {
    fn build_tools_list(&self) -> Vec<ToolSpec> {
        self.config.tools.iter()
            .filter(|t| t.enabled)
            .map(|t| t.spec.clone())
            .collect()
    }

    pub fn start_thread(&self) -> Result<()> {
        let tools = self.build_tools_list();
        // ... only caller of build_tools_list
    }
}
```

**Correct (logic inlined at the single call site):**

```rust
impl ThreadManager {
    pub fn start_thread(&self) -> Result<()> {
        let tools: Vec<ToolSpec> = self.config.tools.iter()
            .filter(|t| t.enabled)
            .map(|t| t.spec.clone())
            .collect();
        // ... continues using tools
    }
}
```
