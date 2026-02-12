---
title: Use a form_group Method for Custom Field Layouts
impact: MEDIUM
impactDescription: reduces per-field wrapper markup from 4-6 lines to 1 method call
tags: form, formbuilder, layout, groups
---

## Use a form_group Method for Custom Field Layouts

Not every form field stands alone. Address fields (city, state, zip), name fields (first, last), and date ranges need to be grouped visually. Without a `form_group` helper, developers invent their own wrapper markup each time, producing inconsistent spacing and labeling. A `form_group` method gives you a consistent wrapper for multi-field layouts.

**Incorrect (ad-hoc div wrappers with inconsistent spacing in every form):**

```erb
<div style="margin-bottom: 16px;">
  <span class="font-medium">Address</span>
  <div class="flex gap-2">
    <%= f.text_field :city, class: "w-1/2 rounded-md border-gray-300", placeholder: "City" %>
    <%= f.text_field :state, class: "w-1/4 rounded-md border-gray-300", placeholder: "State" %>
    <%= f.text_field :zip, class: "w-1/4 rounded-md border-gray-300", placeholder: "ZIP" %>
  </div>
</div>

<%# Another form uses different markup for the same pattern %>
<div class="mb-6">
  <label class="block mb-1 text-gray-600">Address</label>
  <div class="grid grid-cols-4 gap-3">
    <%= f.text_field :city, class: "col-span-2 ..." %>
    ...
  </div>
</div>
```

**Correct (form_group method for consistent multi-field layouts):**

```ruby
# app/form_builders/design_system_form_builder.rb
class DesignSystemFormBuilder < ActionView::Helpers::FormBuilder
  def form_group(legend = nil, options = {}, &block)
    layout = options.delete(:layout) || :horizontal
    help_text = options.delete(:help)

    layout_class = case layout
                   when :horizontal then "flex gap-4"
                   when :grid then "grid grid-cols-12 gap-4"
                   else ""
                   end

    @template.content_tag(:fieldset, class: "mb-6") do
      legend_tag(legend) +
        @template.content_tag(:div, class: layout_class, &block) +
        (help_text ? @template.content_tag(:p, help_text, class: "text-gray-500 text-sm mt-1") : "".html_safe)
    end
  end

  # Lightweight field method for use inside form_group (no wrapper div)
  def inline_field(method, type: :text_field, **options)
    wrapper_class = options.delete(:wrapper_class) || ""
    @template.content_tag(:div, class: wrapper_class) do
      label(method, class: "block text-sm font-medium text-gray-700") +
        send(type, method, options.reverse_merge(class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm"))
    end
  end

  private

  def legend_tag(text)
    return "".html_safe unless text

    @template.content_tag(:legend, text, class: "block text-sm font-medium text-gray-900 mb-2")
  end
end
```

```erb
<%# Usage — consistent, readable, flexible %>
<%= form_with model: @user do |f| %>
  <%= f.form_group "Full Name", layout: :horizontal do %>
    <%= f.inline_field :first_name, wrapper_class: "flex-1" %>
    <%= f.inline_field :last_name, wrapper_class: "flex-1" %>
  <% end %>

  <%= f.form_group "Address", layout: :horizontal do %>
    <%= f.inline_field :city, wrapper_class: "flex-1" %>
    <%= f.inline_field :state, wrapper_class: "w-24" %>
    <%= f.inline_field :zip, wrapper_class: "w-32" %>
  <% end %>
<% end %>
```

The rendered output:

```html
<fieldset class="mb-6">
  <legend class="block text-sm font-medium text-gray-900 mb-2">Address</legend>
  <div class="flex gap-4">
    <div class="flex-1">
      <label for="user_city" class="block text-sm font-medium text-gray-700">City</label>
      <input type="text" name="user[city]" id="user_city" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
    </div>
    <div class="w-24">
      <label for="user_state" class="block text-sm font-medium text-gray-700">State</label>
      <input type="text" name="user[state]" id="user_state" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
    </div>
    <div class="w-32">
      <label for="user_zip" class="block text-sm font-medium text-gray-700">Zip</label>
      <input type="text" name="user[zip]" id="user_zip" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
    </div>
  </div>
</fieldset>
```

Reference: [Rails Form Helpers Guide](https://guides.rubyonrails.org/form_helpers.html)
