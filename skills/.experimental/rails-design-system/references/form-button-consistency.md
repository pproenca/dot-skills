---
title: Standardize Submit Button Styles in FormBuilder
impact: MEDIUM
impactDescription: eliminates inconsistent button styling across forms
tags: form, formbuilder, buttons, variants
---

## Standardize Submit Button Styles in FormBuilder

Submit buttons accumulate style drift faster than any other form element. One form uses `bg-blue-600`, another uses `bg-indigo-500`, a third uses inline styles. Overriding the `submit` method in your FormBuilder lets you define button variants once and use them consistently everywhere.

**Incorrect (copying button classes into every form):**

```erb
<%# app/views/users/new.html.erb %>
<%= f.submit "Create Account", class: "bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 font-medium" %>

<%# app/views/settings/edit.html.erb — slightly different classes %>
<%= f.submit "Save Settings", class: "bg-blue-500 text-white px-6 py-2 rounded-md hover:bg-blue-600" %>

<%# app/views/admin/users/edit.html.erb — someone added inline styles %>
<%= f.submit "Delete User", class: "bg-red-500 text-white px-4 py-2 rounded", style: "font-weight: bold" %>
```

**Correct (submit method override with variant support):**

```ruby
# app/form_builders/design_system_form_builder.rb
class DesignSystemFormBuilder < ActionView::Helpers::FormBuilder
  BUTTON_VARIANTS = {
    primary: "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500",
    secondary: "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 focus:ring-blue-500",
    destructive: "bg-red-600 text-white hover:bg-red-700 focus:ring-red-500"
  }.freeze

  BUTTON_BASE = "inline-flex items-center px-4 py-2 rounded-md font-medium text-sm " \
                "focus:outline-none focus:ring-2 focus:ring-offset-2 " \
                "disabled:opacity-50 disabled:cursor-not-allowed transition-colors"

  def submit(value = nil, options = {})
    variant = options.delete(:variant) || :primary
    variant_classes = BUTTON_VARIANTS.fetch(variant) do
      raise ArgumentError, "Unknown button variant: #{variant}. Use: #{BUTTON_VARIANTS.keys.join(', ')}"
    end

    options[:class] = class_names(BUTTON_BASE, variant_classes, options[:class])

    super(value, options)
  end
end
```

```erb
<%# Usage — clean, consistent, variant-based %>
<%= form_with model: @user do |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :email %>

  <div class="flex gap-3 mt-6">
    <%= f.submit "Save Changes", variant: :primary %>
    <%= f.submit "Cancel", variant: :secondary, formnovalidate: true %>
  </div>
<% end %>

<%# Destructive action %>
<%= form_with model: @user, method: :delete do |f| %>
  <%= f.submit "Delete Account", variant: :destructive,
        data: { turbo_confirm: "Are you sure? This cannot be undone." } %>
<% end %>
```

If you need button styles outside of forms (e.g., link-styled buttons), create a matching `button_link_to` helper in ApplicationHelper that uses the same `BUTTON_VARIANTS` constant:

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def button_link_to(text, url, variant: :primary, **options)
    variant_classes = DesignSystemFormBuilder::BUTTON_VARIANTS.fetch(variant)
    options[:class] = class_names(DesignSystemFormBuilder::BUTTON_BASE, variant_classes, options[:class])
    link_to(text, url, options)
  end
end
```

Reference: [Rails FormBuilder API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html)
