---
title: No component inheritance hierarchies — compose with props and children
tags: react, inheritance, composition, class-components
---

## No component inheritance hierarchies — compose with props and children

The wrong default, ported from OO UI toolkits, is specializing components by extending them — a `BaseButton` class that `PrimaryButton extends`, or new `React.Component` subclasses as the vehicle for shared behavior. The React team's position is categorical — after years of React at Facebook, they found no use case where component inheritance beats composition — and the modern API is function components; the class API is legacy. Inheritance couples children to parent internals (protected methods, render overrides) that props and `children` express without the coupling, and it locks the code out of hooks, which only work in function components.

**Evidence of violation:** a component class that `extends` another project component, a `Base*`/`Abstract*` component intended for extension, or a newly written `React.Component`/`PureComponent` subclass. The carve-out is the error boundary — `componentDidCatch`/`getDerivedStateFromError` have no hook equivalent, so one thin class-based error boundary (usually wrapping a library like `react-error-boundary`) is legitimate.

**Incorrect (specialization via extends):**

```tsx
class BaseButton extends React.Component<BaseButtonProps> {
  protected classes() { return `btn btn-${this.props.size ?? "md"}` }
  render() { return <button className={this.classes()}>{this.props.label}</button> }
}
class PrimaryButton extends BaseButton {
  protected classes() { return `${super.classes()} btn-primary` }
}
```

**Correct (specialization via props and composition):**

```tsx
function Button({ variant = "default", size = "md", children }: ButtonProps) {
  return <button className={`btn btn-${size} btn-${variant}`}>{children}</button>
}
const PrimaryButton = (props: Omit<ButtonProps, "variant">) => (
  <Button variant="primary" {...props} />
)
```

Reference: [React docs — Composition vs Inheritance](https://legacy.reactjs.org/docs/composition-vs-inheritance.html) and [react.dev — Component (legacy class API)](https://react.dev/reference/react/Component)
