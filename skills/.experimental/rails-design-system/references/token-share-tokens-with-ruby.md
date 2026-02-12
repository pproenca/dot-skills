---
title: Access Tokens in Ruby Only When Necessary
impact: MEDIUM-HIGH
impactDescription: prevents over-engineering token access
tags: token, ruby, mailer, pdf, yaml
---

## Access Tokens in Ruby Only When Necessary

For 95% of your Rails app, design tokens live in CSS via `@theme` and are consumed in ERB templates through Tailwind utility classes. You only need tokens in Ruby when generating content outside the browser rendering pipeline: HTML emails (which cannot use external stylesheets reliably), PDF generation, dynamic inline styles, or server-side image rendering. Keep the Ruby-side token access minimal and file-based.

**Incorrect (mirroring every CSS token in Ruby):**

```ruby
# app/models/design_tokens.rb
# Over-engineered: mirrors the entire CSS token set in Ruby
module DesignTokens
  COLORS = {
    primary: "#2563eb",
    primary_hover: "#1d4ed8",
    danger: "#dc2626",
    success: "#16a34a",
    warning: "#ca8a04",
    surface: "#ffffff",
    surface_raised: "#f9fafb",
    text: "#111827",
    text_muted: "#6b7280",
    border: "#e5e7eb",
  }.freeze

  SPACING = {
    xs: "0.25rem",
    sm: "0.5rem",
    md: "1rem",
    lg: "1.5rem",
    xl: "2rem",
  }.freeze

  RADII = {
    default: "0.5rem",
    lg: "0.75rem",
    full: "9999px",
  }.freeze

  # Now you have two sources of truth: CSS @theme AND this Ruby module
  # They WILL drift apart.
end
```

**Correct (YAML tokens loaded only where needed):**

```yaml
# config/design_tokens.yml
# Minimal subset for contexts that can't use Tailwind classes
colors:
  primary: "#2563eb"
  primary_hover: "#1d4ed8"
  danger: "#dc2626"
  success: "#16a34a"
  text: "#111827"
  text_muted: "#6b7280"
  surface: "#ffffff"
  border: "#e5e7eb"

fonts:
  family: "'Inter', ui-sans-serif, system-ui, sans-serif"
  size_base: "16px"
  size_sm: "14px"
```

```ruby
# app/helpers/design_token_helper.rb
module DesignTokenHelper
  def design_tokens
    @design_tokens ||= YAML.load_file(
      Rails.root.join("config/design_tokens.yml")
    ).deep_symbolize_keys
  end

  def token_color(name)
    design_tokens.dig(:colors, name)
  end
end
```

```erb
<%# app/views/user_mailer/welcome.html.erb %>
<%# Emails need inline styles — this is where Ruby tokens are useful %>
<table width="100%" style="font-family: <%= design_tokens.dig(:fonts, :family) %>;">
  <tr>
    <td style="background-color: <%= token_color(:primary) %>; padding: 24px;">
      <h1 style="color: #ffffff; font-size: 24px; margin: 0;">
        Welcome to <%= @app_name %>
      </h1>
    </td>
  </tr>
  <tr>
    <td style="padding: 24px; color: <%= token_color(:text) %>;">
      <p style="font-size: <%= design_tokens.dig(:fonts, :size_base) %>;">
        Hello <%= @user.name %>, your account is ready.
      </p>
    </td>
  </tr>
</table>
```

```erb
<%# app/views/layouts/application.html.erb %>
<%# Normal views use Tailwind classes — no Ruby tokens needed %>
<nav class="bg-primary text-white px-6 h-header flex items-center">
  <%= link_to "Home", root_path, class: "hover:bg-primary-hover px-3 py-2 rounded-default" %>
</nav>
```

**When to use Ruby tokens vs. Tailwind classes:**

| Context | Approach |
|---|---|
| ERB views, partials, components | Tailwind utility classes |
| ActionMailer HTML emails | Ruby tokens for inline styles |
| PDF generation (Prawn, wicked_pdf) | Ruby tokens |
| Dynamic inline styles (rare) | Ruby tokens |
| Server-side SVG or image generation | Ruby tokens |
| Everything else | Tailwind utility classes |

Reference: [Action Mailer Basics](https://guides.rubyonrails.org/action_mailer_basics.html)
