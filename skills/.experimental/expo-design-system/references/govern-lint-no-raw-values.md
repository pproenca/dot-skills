---
title: Lint Against Raw Colors and Inline Styles
impact: MEDIUM
impactDescription: prevents ungoverned values from merging into the codebase
tags: govern, eslint, lint, tokens
---

## Lint Against Raw Colors and Inline Styles

Relying on code review to catch hex literals and inline style objects is inconsistent — reviewers miss them, and once merged they multiply. An ESLint rule that fails CI on color literals and inline `style` objects turns the convention into an automated gate that cannot be forgotten.

**Incorrect (no lint gate — raw values slip through review):**

```typescript
const styles = StyleSheet.create(() => ({
  banner: { backgroundColor: '#FEF3C7', borderColor: 'rgba(0,0,0,0.08)', color: 'teal', padding: 11 },
  // hex, rgba, a named color, and an off-scale number — all ungoverned, all slip through review
}))
```

**Correct (an ESLint rule rejects literals and inline styles):**

```javascript
// .eslintrc.js — fail CI when a hex color or an inline style object appears in feature code
module.exports = {
  rules: {
    'no-restricted-syntax': ['error',
      { selector: "Literal[value=/^#([0-9a-fA-F]{3,8})$/]",
        message: 'Use a theme color token, not a hex literal.' },
      { selector: "Literal[value=/^(rgba?|hsla?)\\(/]",
        message: 'Use a theme color token, not an rgb()/hsl() literal.' },
      { selector: "Literal[value=/^(red|green|blue|teal|gray|grey|black|white|orange|purple)$/]",
        message: 'Use a theme color token, not a named CSS color.' },
      { selector: "JSXAttribute[name.name='style'] ObjectExpression",
        message: 'Use StyleSheet.create with tokens, not an inline style object.' },
    ],
  },
}
```

AST selectors cannot tell a spacing literal from any other number, so pair this with a numeric-scale check (a custom lint or a CI grep for off-scale `padding`/`margin`/`fontSize` values) and treat `style={[...]}` arrays the same as inline objects.

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/)
