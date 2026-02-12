---
title: Create a Custom FormBuilder for Design System Consistency
impact: MEDIUM-HIGH
impactDescription: eliminates form markup duplication across entire app
tags: form, formbuilder, consistency, dry
---

## Create a Custom FormBuilder for Design System Consistency

Every form in your app needs labels, error messages, help text, and consistent wrapper markup. Without a custom FormBuilder, developers copy-paste this structure into every form, leading to drift and inconsistency. Extending `ActionView::Helpers::FormBuilder` lets you define the structure once and enforce it everywhere.

**Incorrect (manually duplicating form field structure in every view):**

```erb
<%= form_with model: @user do |f| %>
  <div class="mb-4">
    <label for="user_name" class="block text-sm font-medium text-gray-700">Name</label>
    <%= f.text_field :name, class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm" %>
    <% if @user.errors[:name].any? %>
      <p class="text-red-600 text-sm mt-1"><%= @user.errors[:name].first %></p>
    <% end %>
  </div>

  <div class="mb-4">
    <label for="user_email" class="block text-sm font-medium text-gray-700">Email</label>
    <%= f.text_field :email, class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm" %>
    <% if @user.errors[:email].any? %>
      <p class="text-red-600 text-sm mt-1"><%= @user.errors[:email].first %></p>
    <% end %>
  </div>
<% end %>
```

**Correct (custom FormBuilder that wraps fields with labels, errors, and help text automatically):**

```ruby
# app/form_builders/design_system_form_builder.rb
class DesignSystemFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    help_text = options.delete(:help)
    field_wrapper(method, help_text) do
      super(method, options.reverse_merge(
        class: field_classes(method)
      ))
    end
  end

  # Override other field types the same way:
  # email_field, password_field, text_area, telephone_field, etc.

  private

  def field_wrapper(method, help_text = nil, &block)
    help_id = "#{object_name}_#{method}_help" if help_text

    @template.content_tag(:div, class: "mb-4") do
      label(method, class: "block text-sm font-medium text-gray-700") +
        block.call +
        error_message(method) +
        (help_text ? @template.content_tag(:p, help_text, id: help_id, class: "text-gray-500 text-sm mt-1") : "".html_safe)
    end
  end

  def error_message(method)
    return "".html_safe unless object&.errors&.[](method)&.any?

    @template.content_tag(:p, object.errors[method].first, class: "text-red-600 text-sm mt-1")
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

```erb
<%# Usage — clean, consistent, zero boilerplate %>
<%= form_with model: @user do |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :email, help: "We'll never share your email." %>
<% end %>
```

Reference: [Rails Form Helpers Guide](https://guides.rubyonrails.org/form_helpers.html)
