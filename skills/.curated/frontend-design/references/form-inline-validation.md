---
title: Use Inline Validation After Field Blur
impact: MEDIUM
impactDescription: reduces form abandonment by 22%
tags: form, validation, inline, ux, errors
---

## Use Inline Validation After Field Blur

Validating only on submit forces users to scroll back and fix errors. Inline validation (after field blur, not during typing) gives immediate feedback while respecting the user's flow.

**Incorrect (validation only on submit or during typing):**

```javascript
// Only validates on form submit
form.addEventListener('submit', (event) => {
  const errors = validateAllFields();
  if (errors.length) {
    event.preventDefault();
    showErrorSummary(errors); // User must scroll to find errors
  }
});

// Validates on every keystroke (annoying)
emailInput.addEventListener('input', () => {
  if (!isValidEmail(emailInput.value)) {
    showError('Invalid email'); // Error shows while still typing
  }
});
```

**Correct (inline validation on blur, removal on input):**

```javascript
// Validate when user leaves field
emailInput.addEventListener('blur', () => {
  if (!emailInput.value) return; // Don't validate empty on blur

  if (!isValidEmail(emailInput.value)) {
    showFieldError(emailInput, 'Enter a valid email address');
  }
});

// Clear error when user starts correcting
emailInput.addEventListener('input', () => {
  if (hasError(emailInput) && isValidEmail(emailInput.value)) {
    clearFieldError(emailInput);
  }
});

// Still validate all on submit as backup
form.addEventListener('submit', (event) => {
  const errors = validateAllFields();
  if (errors.length) {
    event.preventDefault();
    focusFirstError();
  }
});
```

**Validation timing rules:**
- Required fields: Validate on blur AND on submit
- Format validation: Validate on blur, clear on valid input
- Never validate empty required fields on blur (wait for submit)
- Never show errors while user is actively typing

Reference: [Baymard Inline Validation](https://baymard.com/blog/inline-form-validation)
