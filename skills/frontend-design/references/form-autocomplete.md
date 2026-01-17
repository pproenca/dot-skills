---
title: Enable Browser Autocomplete with Correct Attributes
impact: MEDIUM
impactDescription: reduces form filling time by 30%+
tags: form, autocomplete, autofill, ux, html
---

## Enable Browser Autocomplete with Correct Attributes

Browser autofill saves users significant typing time. Using correct `autocomplete` attributes helps browsers fill forms accurately. Disabling autocomplete frustrates users.

**Incorrect (autocomplete disabled or missing):**

```html
<!-- Explicitly disabled (frustrating) -->
<input type="email" autocomplete="off" name="email">

<!-- No autocomplete attribute (browser guesses wrong) -->
<input type="text" name="field1" placeholder="First name">
<input type="text" name="field2" placeholder="Last name">
<!-- Browser may fill "field1" with wrong data -->

<!-- Wrong autocomplete values -->
<input type="text" autocomplete="name" name="address">
```

**Correct (proper autocomplete attributes):**

```html
<!-- Personal information -->
<input type="text" name="firstName" autocomplete="given-name">
<input type="text" name="lastName" autocomplete="family-name">
<input type="email" name="email" autocomplete="email">
<input type="tel" name="phone" autocomplete="tel">

<!-- Address fields -->
<input type="text" name="address" autocomplete="street-address">
<input type="text" name="city" autocomplete="address-level2">
<input type="text" name="state" autocomplete="address-level1">
<input type="text" name="zip" autocomplete="postal-code">
<select name="country" autocomplete="country">

<!-- Payment (for payment forms) -->
<input type="text" name="cardNumber" autocomplete="cc-number">
<input type="text" name="cardName" autocomplete="cc-name">
<input type="text" name="expiry" autocomplete="cc-exp">

<!-- Login forms -->
<input type="text" name="username" autocomplete="username">
<input type="password" name="password" autocomplete="current-password">

<!-- New password (signup/change) -->
<input type="password" name="newPassword" autocomplete="new-password">
```

**Common autocomplete values:**
- Names: `given-name`, `family-name`, `name`
- Contact: `email`, `tel`, `url`
- Address: `street-address`, `postal-code`, `country`
- Payment: `cc-number`, `cc-name`, `cc-exp`

Reference: [HTML autocomplete attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/autocomplete)
