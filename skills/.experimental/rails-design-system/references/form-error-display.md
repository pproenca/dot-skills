---
title: Display Field Errors Inline Below Each Input
impact: MEDIUM-HIGH
impactDescription: reduces form-error markup from 5-8 lines to 0 lines per field
tags: form, errors, validation, ux
---

## Display Field Errors Inline Below Each Input

Users should see exactly which field has a problem without scanning a list at the top of the page. Inline errors below each field reduce cognitive load and speed up form correction. The FormBuilder should handle this automatically so developers never write error display logic manually.

**Incorrect (only showing grouped errors at the top of the form):**

```erb
<%= form_with model: @user do |f| %>
  <% if @user.errors.any? %>
    <div class="bg-red-50 border border-red-400 rounded p-4 mb-6">
      <h3 class="text-red-800 font-medium"><%= pluralize(@user.errors.count, "error") %> prevented saving:</h3>
      <ul class="list-disc ml-5 mt-2">
        <% @user.errors.full_messages.each do |msg| %>
          <li class="text-red-700"><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <%# User has to guess which field each error belongs to %>
  <%= f.text_field :name, class: "block w-full rounded-md border-gray-300" %>
  <%= f.text_field :email, class: "block w-full rounded-md border-gray-300" %>
<% end %>
```

**Correct (FormBuilder renders errors inline below each field automatically):**

```ruby
# app/form_builders/design_system_form_builder.rb
class DesignSystemFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    @template.content_tag(:div, class: "mb-4") do
      label(method, class: "block text-sm font-medium text-gray-700") +
        super(method, options.reverse_merge(class: field_classes(method))) +
        inline_errors(method)
    end
  end

  private

  def inline_errors(method)
    return "".html_safe unless object&.errors&.[](method)&.any?

    @template.content_tag(:p, class: "text-red-600 text-sm mt-1") do
      object.errors[method].first
    end
  end

  def field_classes(method)
    has_errors = object&.errors&.[](method)&.any?

    @template.class_names(
      "mt-1 block w-full rounded-md shadow-sm",
      "border-gray-300 focus:border-blue-500 focus:ring-blue-500": !has_errors,
      "border-red-500 focus:border-red-500 focus:ring-red-500": has_errors
    )
  end
end
```

The rendered HTML for a field with errors:

```html
<div class="mb-4">
  <label for="user_email" class="block text-sm font-medium text-gray-700">Email</label>
  <input type="text" name="user[email]" id="user_email"
         class="mt-1 block w-full rounded-md shadow-sm border-red-500 focus:border-red-500 focus:ring-red-500" />
  <p class="text-red-600 text-sm mt-1">has already been taken</p>
</div>
```

You can still show a summary at the top for screen readers, but the inline error is the primary visual feedback.

Reference: [Rails Active Record Validations](https://guides.rubyonrails.org/active_record_validations.html#displaying-validation-errors-in-views)
