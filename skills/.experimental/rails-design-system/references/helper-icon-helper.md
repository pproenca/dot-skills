---
title: Create an Icon Helper for Consistent Icon Usage
impact: MEDIUM
impactDescription: reduces icon SVG markup from 3-10 lines to 1 helper call
tags: helper, icons, svg, components
---

## Create an Icon Helper for Consistent Icon Usage

Icons get copy-pasted as raw SVG markup across dozens of views, making it impossible to change icon sets or standardize sizing later. A single `icon` helper centralizes icon rendering. You can switch from inline SVG to a sprite sheet, or from Heroicons to Lucide, by changing one file.

**Incorrect (copy-pasting SVG markup inline in every view):**

```erb
<%# app/views/users/show.html.erb %>
<svg class="w-5 h-5 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
</svg>

<%# app/views/orders/index.html.erb — same icon, different size %>
<svg class="w-4 h-4 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
</svg>

<%# 48 more files with similar copy-pasted SVGs... %>
```

**Correct (centralized icon helper with consistent API):**

```ruby
# app/helpers/icon_helper.rb
module IconHelper
  ICON_PATH = Rails.root.join("app/assets/images/icons")

  def icon(name, size: :md, **options)
    size_classes = icon_size_class(size)
    options[:class] = class_names(size_classes, options[:class])

    inline_svg(name, options)
  end

  private

  def inline_svg(name, options)
    file_path = ICON_PATH.join("#{name}.svg")

    unless File.exist?(file_path)
      Rails.logger.warn("Icon not found: #{name}")
      return tag.span("?", class: options[:class], title: "Missing icon: #{name}")
    end

    svg = File.read(file_path)

    # Inject class and aria attributes into the SVG tag
    svg = svg.sub("<svg", %(<svg class="#{options[:class]}" aria-hidden="true"))
    svg.html_safe
  end

  def icon_size_class(size)
    case size
    when :xs then "w-3 h-3"
    when :sm then "w-4 h-4"
    when :md then "w-5 h-5"
    when :lg then "w-6 h-6"
    when :xl then "w-8 h-8"
    else size # Allow passing custom classes like "w-10 h-10"
    end
  end
end
```

```erb
<%# Usage — clean, consistent, easy to change %>
<%= icon("check", size: :md, class: "text-green-600") %>
<%= icon("x-mark", size: :sm, class: "text-red-500") %>
<%= icon("arrow-right", size: :lg, class: "text-gray-400") %>

<%# In a button %>
<button class="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-md">
  <%= icon("plus", size: :sm) %>
  Add Item
</button>
```

For production apps, consider using the `inline_svg` gem instead of the hand-rolled version above -- it handles caching, asset pipeline integration, and SVG optimization:

```ruby
# Gemfile
gem "inline_svg"

# app/helpers/icon_helper.rb
module IconHelper
  def icon(name, size: :md, **options)
    options[:class] = class_names(icon_size_class(size), options[:class])
    options[:aria_hidden] = true

    inline_svg_tag("icons/#{name}.svg", **options)
  end
end
```

Reference: [Heroicons](https://heroicons.com/)
