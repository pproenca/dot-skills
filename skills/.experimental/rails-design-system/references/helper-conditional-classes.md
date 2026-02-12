---
title: Use class_names for Conditional CSS Classes
impact: MEDIUM
impactDescription: eliminates string interpolation in class attributes
tags: helper, css, class-names, conditional
---

## Use class_names for Conditional CSS Classes

Ternary operators and string interpolation in class attributes produce unreadable, error-prone code. Rails 7+ provides `class_names` (aliased as `token_list`) for building conditional class strings cleanly. It accepts a hash where keys are class names and values are booleans.

**Incorrect (ternary operators and string interpolation in class attributes):**

```erb
<%# Messy string interpolation %>
<div class="btn <%= active ? 'btn-active' : '' %> <%= disabled ? 'opacity-50 cursor-not-allowed' : '' %> <%= size == :large ? 'px-6 py-3 text-lg' : 'px-4 py-2 text-sm' %>">
  <%= label %>
</div>

<%# Even worse in a helper %>
```

```ruby
def nav_link(text, path)
  active = current_page?(path)
  classes = "nav-link"
  classes += " nav-link-active" if active
  classes += " text-gray-400" unless active
  link_to text, path, class: classes
end
```

**Correct (using class_names for clean conditional class logic):**

```erb
<%# Clean, readable conditional classes in ERB %>
<div class="<%= class_names(
  "btn",
  "btn-active": active,
  "opacity-50 cursor-not-allowed": disabled,
  "px-6 py-3 text-lg": size == :large,
  "px-4 py-2 text-sm": size != :large
) %>">
  <%= label %>
</div>

<%# Even cleaner with tag helper %>
<%= tag.div label, class: class_names(
  "btn",
  "btn-active": active,
  "opacity-50 cursor-not-allowed": disabled
) %>
```

```ruby
# Clean helper using class_names
module ApplicationHelper
  def nav_link(text, path)
    active = current_page?(path)

    link_to text, path, class: class_names(
      "nav-link px-3 py-2 rounded-md text-sm font-medium",
      "nav-link-active bg-gray-900 text-white": active,
      "text-gray-300 hover:bg-gray-700 hover:text-white": !active
    )
  end

  def flash_class(type)
    class_names(
      "px-4 py-3 rounded-md text-sm font-medium mb-4",
      "bg-green-50 text-green-800 border border-green-200": type.to_sym == :notice,
      "bg-red-50 text-red-800 border border-red-200": type.to_sym == :alert,
      "bg-blue-50 text-blue-800 border border-blue-200": type.to_sym == :info
    )
  end
end
```

`class_names` handles nil values and blank strings gracefully -- falsy conditions are simply omitted from the output. It works in helpers, ERB templates, and inside custom FormBuilder methods.

```ruby
# token_list is an alias for class_names
class_names("base", "active": true, "hidden": false)
# => "base active"

token_list("base", "active": true, "hidden": false)
# => "base active"
```

Reference: [Rails class_names helper](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-class_names)
