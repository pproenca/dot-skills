---
title: Follow Consistent Naming Across All Design System Files
impact: LOW-MEDIUM
impactDescription: reduces naming inconsistencies to 0 across components, partials, helpers
tags: org, naming, conventions, consistency
---

## Follow Consistent Naming Across All Design System Files

Without naming conventions, every developer invents their own: `ButtonUI`, `button-component`, `ButtonWidget`, `Btn`. This creates confusion, slows onboarding, and makes searching the codebase harder. Establish a naming convention once and enforce it in code review.

**Incorrect (inconsistent naming across the same codebase):**

```text
app/components/ButtonUI.rb          # no Component suffix
app/components/card_component.rb    # snake_case filename, good
app/components/UserAvatar.rb        # PascalCase filename, no suffix
app/views/shared/_btn.html.erb      # abbreviated name
app/views/shared/_Card.html.erb     # PascalCase partial (Rails expects lowercase)
app/javascript/controllers/settings_page_toggle_controller.js  # page-specific name
app/helpers/ui_helper.rb            # generic name — what UI?
```

**Correct (consistent naming convention across all design system files):**

| Type | Convention | Example |
|------|-----------|---------|
| ViewComponent class | `{Name}Component` | `ButtonComponent`, `AvatarComponent` |
| ViewComponent file | `{name}_component.rb` | `button_component.rb` |
| ViewComponent template | `{name}_component.html.erb` | `button_component.html.erb` |
| Shared partial | `_{noun}.html.erb` (lowercase) | `_flash.html.erb`, `_pagination.html.erb` |
| Stimulus controller | `{behavior}_controller.js` | `toggle_controller.js`, `clipboard_controller.js` |
| Helper module | `{Resource}Helper` | `UsersHelper`, `OrdersHelper` |
| FormBuilder | `{Purpose}FormBuilder` | `DesignSystemFormBuilder` |
| CSS / Token files | `_{category}.css` | `_colors.css`, `_typography.css` |

```text
# Correct directory structure with consistent naming
app/
  components/
    avatar_component.rb
    avatar_component.html.erb
    button_component.rb
    button_component.html.erb
    card_component.rb
    card_component.html.erb
  form_builders/
    design_system_form_builder.rb
  helpers/
    application_helper.rb         # icon, flash_class, page_title only
    users_helper.rb               # user_avatar, role_badge
    orders_helper.rb              # order_status_badge, format_price
  javascript/
    controllers/
      toggle_controller.js        # behavior-named
      clipboard_controller.js     # behavior-named
      dropdown_controller.js      # behavior-named
      autosave_controller.js      # behavior-named
  views/
    shared/
      _flash.html.erb
      _pagination.html.erb
      _empty_state.html.erb
```

Document the convention in a short section of your README or design system ADR so new developers can look it up:

```markdown
## Naming Conventions
- Components: `{Name}Component` class in `app/components/{name}_component.rb`
- Partials: `_` prefix, lowercase, singular noun: `_flash.html.erb`
- Stimulus: behavior name + `_controller.js`: `toggle_controller.js`
- Helpers: resource name + `Helper`: `OrdersHelper`
```

Reference: [Rails Naming Conventions](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html)
