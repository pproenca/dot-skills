---
title: Organize Design System Files in Predictable Locations
impact: LOW-MEDIUM
impactDescription: reduces onboarding file-location questions to 0 for standard Rails patterns
tags: org, file-structure, directories, conventions
---

## Organize Design System Files in Predictable Locations

When design system files are scattered across custom directories (`app/lib/ui/`, `app/design_system/`, `lib/components/`), new developers spend time asking "where does this go?" instead of building features. Use standard Rails directories. The convention already exists -- follow it.

**Incorrect (custom, non-standard directories):**

```text
app/
  lib/
    ui/
      button.rb                    # Non-standard location
      form_builder.rb
  design_system/
    components/                    # Custom top-level directory
      card.html.erb
  assets/
    stylesheets/
      components/
        button.css
lib/
  components/                      # Components in lib/ — not autoloaded by default
    avatar.rb
frontend/
  controllers/                     # Stimulus controllers outside app/javascript/
    toggle.js
```

**Correct (standard Rails directories for all design system files):**

```text
app/
  assets/
    stylesheets/
      application.css              # Main entry point
      tokens/
        _colors.css                # Design tokens
        _spacing.css
        _typography.css
  components/                      # ViewComponent classes + templates
    application_component.rb       # Base class
    avatar_component.rb
    avatar_component.html.erb
    button_component.rb
    button_component.html.erb
    card_component.rb
    card_component.html.erb
    modal_component.rb
    modal_component.html.erb
  form_builders/
    design_system_form_builder.rb  # Custom FormBuilder
  helpers/
    application_helper.rb          # Global helpers (icon, flash_class)
    users_helper.rb                # Domain-specific helpers
    orders_helper.rb
  javascript/
    controllers/
      application.js               # Stimulus application setup
      index.js                     # Controller registration
      toggle_controller.js         # Behavior-named controllers
      clipboard_controller.js
      dropdown_controller.js
      autosave_controller.js
  views/
    layouts/
      application.html.erb         # Main layout
      _head.html.erb               # Layout partials
      _navbar.html.erb
      _footer.html.erb
    shared/                        # Cross-cutting view partials
      _flash.html.erb
      _pagination.html.erb
      _empty_state.html.erb
      _search_form.html.erb
```

Key principles:
- **`app/components/`** for ViewComponent classes (auto-loaded by Rails if using the viewcomponent gem)
- **`app/views/shared/`** for cross-cutting partials used by multiple controllers
- **`app/javascript/controllers/`** for all Stimulus controllers (auto-loaded by stimulus-rails)
- **`app/form_builders/`** for custom FormBuilder classes (auto-loaded by Rails)
- **`app/helpers/`** for view helper modules (auto-loaded by Rails)
- **`app/assets/stylesheets/tokens/`** for design token files

Do not create directories like `app/ui/`, `app/design_system/`, or `frontend/`. Every file in the list above is auto-loaded by Rails without additional configuration. Custom directories require explicit autoload path configuration and confuse developers who expect standard Rails structure.

### Asset Pipeline: Propshaft (Rails 8+)

Rails 8 uses Propshaft as the default asset pipeline (replacing Sprockets). Propshaft serves assets from `app/assets/` with digest-stamped filenames but does not compile or transform files. CSS is processed by Tailwind CLI or the `tailwindcss-rails` gem, not by Propshaft. Keep your CSS entry point at `app/assets/stylesheets/application.css` and let Tailwind handle the build.

Reference: [Rails Directory Structure](https://guides.rubyonrails.org/getting_started.html#creating-the-blog-application)
