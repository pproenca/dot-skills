---
title: Test ARIA States and Properties
impact: LOW
impactDescription: verifies dynamic accessibility states work correctly
tags: a11y, aria, states, toBeChecked, expanded
---

## Test ARIA States and Properties

Use jest-dom matchers to verify ARIA states like checked, expanded, selected, and pressed update correctly.

**Test checkbox state:**

```tsx
test('toggles checkbox state', async () => {
  const user = userEvent.setup()
  render(<Checkbox label="Remember me" />)

  const checkbox = screen.getByRole('checkbox', { name: /remember me/i })
  expect(checkbox).not.toBeChecked()

  await user.click(checkbox)

  expect(checkbox).toBeChecked()
})
```

**Test expanded state:**

```tsx
test('toggles accordion panel', async () => {
  const user = userEvent.setup()
  render(<Accordion title="Details" />)

  const button = screen.getByRole('button', { name: /details/i })
  expect(button).toHaveAttribute('aria-expanded', 'false')

  await user.click(button)

  expect(button).toHaveAttribute('aria-expanded', 'true')
  expect(screen.getByRole('region')).toBeVisible()
})
```

**Test selected state (tabs):**

```tsx
test('switches selected tab', async () => {
  const user = userEvent.setup()
  render(<Tabs tabs={['Profile', 'Settings']} />)

  expect(screen.getByRole('tab', { name: /profile/i })).toHaveAttribute(
    'aria-selected', 'true'
  )

  await user.click(screen.getByRole('tab', { name: /settings/i }))

  expect(screen.getByRole('tab', { name: /settings/i })).toHaveAttribute(
    'aria-selected', 'true'
  )
  expect(screen.getByRole('tab', { name: /profile/i })).toHaveAttribute(
    'aria-selected', 'false'
  )
})
```

Reference: [WAI-ARIA States and Properties](https://www.w3.org/TR/wai-aria-1.1/#state_prop_def)
