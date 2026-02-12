---
title: Use Tag Helpers for Small HTML Fragments
impact: MEDIUM
impactDescription: eliminates 100% of html_safe calls in helpers, prevents XSS
tags: helper, tag-helpers, security, html-safe
---

## Use Tag Helpers for Small HTML Fragments

Building HTML strings with interpolation and calling `html_safe` is the most common source of XSS vulnerabilities in Rails helpers. The `tag` helper (`tag.span`, `tag.div`) and `content_tag` build HTML safely, handle attribute escaping, and produce cleaner code. Never concatenate HTML strings manually.

**Incorrect (building HTML strings with interpolation and html_safe):**

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def role_label(role)
    "<span class='badge badge-#{role}'>#{role.titleize}</span>".html_safe
  end

  def status_dot(status)
    color = status == "active" ? "green" : "gray"
    "<span class='inline-block w-2 h-2 rounded-full bg-#{color}-500'></span> <span>#{status}</span>".html_safe
  end

  def external_link(url, text)
    "<a href='#{url}' target='_blank' rel='noopener' class='text-blue-600 underline'>#{text}</a>".html_safe
  end
end
```

**Correct (using tag helpers for safe, readable HTML generation):**

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def role_label(role)
    tag.span(role.titleize, class: "badge badge-#{role}")
  end

  def status_dot(status)
    color = status == "active" ? "green" : "gray"
    tag.span(class: "inline-flex items-center gap-1.5") do
      tag.span(class: "inline-block w-2 h-2 rounded-full bg-#{color}-500") +
        tag.span(status.titleize)
    end
  end

  def external_link(url, text)
    tag.a(text, href: url, target: "_blank", rel: "noopener", class: "text-blue-600 underline")
  end
end
```

Key advantages of tag helpers:
- **Automatic escaping** -- user-provided values are escaped by default
- **Block syntax** -- nest elements with `do...end` instead of string concatenation
- **Hash-style attributes** -- `data: { controller: "tooltip" }` generates `data-controller="tooltip"`

```ruby
# Nesting with blocks
tag.div(class: "card", data: { controller: "expandable" }) do
  tag.h3("Title", class: "card-title") +
    tag.p("Body content", class: "card-body")
end

# Self-closing tags
tag.hr(class: "my-4")
tag.input(type: "hidden", name: "token", value: form_token)
```

Reference: [Rails Action View Tag Helpers](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html)
