---
title: Generate Accessible Labels and ARIA Attributes Automatically
impact: MEDIUM
impactDescription: prevents accessibility violations
tags: form, accessibility, aria, labels
---

## Generate Accessible Labels and ARIA Attributes Automatically

Accessibility should not be optional and it should not require extra work from developers. The FormBuilder should generate proper `<label for="...">` tags, `aria-describedby` for help text, and `aria-invalid` for error states. This ensures every form field is accessible without developers thinking about it.

**Incorrect (missing labels, no ARIA attributes, help text not linked to input):**

```erb
<div class="mb-4">
  <span class="text-sm text-gray-700">Email</span>
  <input type="email" name="user[email]" class="block w-full rounded-md border-gray-300" />
  <p class="text-gray-500 text-sm">We'll never share your email.</p>
</div>
```

**Correct (FormBuilder generates accessible markup automatically):**

```ruby
# app/form_builders/design_system_form_builder.rb
class DesignSystemFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    help_text = options.delete(:help)
    has_errors = object&.errors&.[](method)&.any?

    help_id = "#{object_name}_#{method}_help" if help_text
    error_id = "#{object_name}_#{method}_error" if has_errors

    described_by = [help_id, error_id].compact.join(" ").presence

    aria_options = {}
    aria_options["aria-describedby"] = described_by if described_by
    aria_options["aria-invalid"] = true if has_errors

    @template.content_tag(:div, class: "mb-4") do
      label(method, class: "block text-sm font-medium text-gray-700") +
        super(method, options.reverse_merge(class: field_classes(method)).merge(aria_options)) +
        error_tag(method, error_id) +
        help_tag(help_text, help_id)
    end
  end

  private

  def error_tag(method, error_id)
    return "".html_safe unless object&.errors&.[](method)&.any?

    @template.content_tag(:p, object.errors[method].first,
      id: error_id,
      class: "text-red-600 text-sm mt-1",
      role: "alert"
    )
  end

  def help_tag(text, help_id)
    return "".html_safe unless text

    @template.content_tag(:p, text, id: help_id, class: "text-gray-500 text-sm mt-1")
  end

  def field_classes(method)
    has_errors = object&.errors&.[](method)&.any?

    class_names(
      "mt-1 block w-full rounded-md shadow-sm",
      "border-gray-300": !has_errors,
      "border-red-500": has_errors
    )
  end
end
```

The rendered output for a field with help text and an error:

```html
<div class="mb-4">
  <label for="user_email" class="block text-sm font-medium text-gray-700">Email</label>
  <input type="text"
         name="user[email]"
         id="user_email"
         class="mt-1 block w-full rounded-md shadow-sm border-red-500"
         aria-describedby="user_email_help user_email_error"
         aria-invalid="true" />
  <p id="user_email_error" class="text-red-600 text-sm mt-1" role="alert">has already been taken</p>
  <p id="user_email_help" class="text-gray-500 text-sm mt-1">We'll never share your email.</p>
</div>
```

Key accessibility attributes generated automatically:
- `<label for="...">` linked to the input via matching `id`
- `aria-describedby` linking the input to both help text and error messages
- `aria-invalid="true"` on fields with validation errors
- `role="alert"` on error messages for screen reader announcement

Reference: [WAI-ARIA Forms Practices](https://www.w3.org/WAI/tutorials/forms/)
