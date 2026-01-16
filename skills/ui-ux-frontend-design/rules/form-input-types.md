---
title: Use Correct HTML Input Types for Mobile Keyboards
impact: MEDIUM
impactDescription: reduces typing effort by showing appropriate keyboard
tags: form, input-types, mobile, keyboard, html
---

## Use Correct HTML Input Types for Mobile Keyboards

Using `type="text"` for all inputs forces mobile users to switch keyboards manually. Proper input types trigger optimized keyboards with relevant keys.

**Incorrect (generic text input for everything):**

```html
<input type="text" name="email" placeholder="Email">
<!-- Shows full QWERTY, user must find @ symbol -->

<input type="text" name="phone" placeholder="Phone">
<!-- Shows full QWERTY, user must switch to number keyboard -->

<input type="text" name="search" placeholder="Search...">
<!-- No "Search" or "Go" button on mobile keyboard -->

<input type="text" name="url" placeholder="Website URL">
<!-- No ".com" shortcut or "/" key prominent -->
```

**Correct (semantic input types):**

```html
<!-- Email: shows @ and .com on keyboard -->
<input type="email" name="email" placeholder="Email" autocomplete="email">

<!-- Phone: shows numeric keypad -->
<input type="tel" name="phone" placeholder="Phone" autocomplete="tel">

<!-- Search: shows Search/Go button instead of Enter -->
<input type="search" name="query" placeholder="Search...">

<!-- URL: shows "/" and ".com" shortcuts -->
<input type="url" name="website" placeholder="Website URL" autocomplete="url">

<!-- Number: shows numeric keypad -->
<input
  type="text"
  inputmode="numeric"
  pattern="[0-9]*"
  name="zipcode"
  placeholder="ZIP Code"
>
```

**Input types and their keyboards:**
| Type | Keyboard shows |
|------|----------------|
| `email` | @ symbol prominent |
| `tel` | Number pad |
| `url` | .com, / shortcuts |
| `search` | Search button |
| `number` | Number pad with +/- |
| `inputmode="numeric"` | Number pad only |

Reference: [web.dev Input Types](https://web.dev/articles/payment-and-address-form-best-practices#input_types)
