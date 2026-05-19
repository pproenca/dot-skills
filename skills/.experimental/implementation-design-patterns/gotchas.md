# Gotchas

Append entries as they're discovered. Format:

```markdown
### {Short title of the failure mode}
{What went wrong, how to recognize it, and how to avoid it.}
Added: {YYYY-MM-DD}
```

---

### Don't paste pedagogical names into production code
The "Correct" code blocks in every pattern reference preserve the canonical refactoring.guru identifiers verbatim — `ConcreteStrategyA`, `ConcreteStateB`, `Receiver`, `Adaptee`, `Component`, `Visitor`. These names exist to make the *structure* legible against the GoF catalog; they communicate nothing about *your* domain. Before merging code derived from a pattern reference, rename every class/method to a domain term that explains the role at the call site (e.g., `ConcreteStrategyA` → `AlphabeticalSort`, `Receiver` → `EmailService`, `Visitor` → `XmlExportVisitor`). If a reviewer can't tell what the code does without referring back to the pattern, the renaming isn't done.
Added: 2026-05-19

### Watch for native-TypeScript shortcuts before reaching for the class-based template
Several patterns collapse into language features in modern TypeScript:

- **Strategy** → `type Strategy = (data: T[]) => T[]` and pass the function directly
- **Iterator** → implement `[Symbol.iterator]()` so `for...of` works
- **Observer** → `EventTarget`, `EventEmitter`, RxJS `Subject`, framework signals/hooks
- **Command** → a closure: `const undo = () => { state = previous }`
- **Singleton** → `export const config = createConfig()` at module scope (ESM caches the module)
- **Template Method** → a higher-order function: `pipeline(parseStep, sharedRest)`
- **Visitor** → a discriminated union + exhaustive `switch (node.kind)`

Recommend the class-based GoF template when the user actually needs the extra structure (subclassing, identity, dispatch). Recommend the native shortcut when they don't — over-engineering is more common than under-engineering with this catalog.
Added: 2026-05-19
