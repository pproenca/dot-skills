---
title: Set Your Custom FormBuilder as the Application Default
impact: MEDIUM-HIGH
impactDescription: "eliminates builder: argument from 100% of form_with calls"
tags: form, formbuilder, configuration, defaults
---

## Set Your Custom FormBuilder as the Application Default

If developers have to remember to pass `builder: DesignSystemFormBuilder` to every `form_with` call, someone will forget. Setting `default_form_builder` in ApplicationController makes every form use your custom builder automatically. No opt-in required, no inconsistency possible.

**Incorrect (specifying the builder explicitly in every form):**

```erb
<%# app/views/users/new.html.erb %>
<%= form_with model: @user, builder: DesignSystemFormBuilder do |f| %>
  <%= f.text_field :name %>
<% end %>

<%# app/views/posts/new.html.erb — someone forgot the builder option %>
<%= form_with model: @post do |f| %>
  <div class="mb-4">
    <label for="post_title" class="block text-sm font-medium text-gray-700">Title</label>
    <%= f.text_field :title, class: "mt-1 block w-full rounded-md border-gray-300" %>
  </div>
<% end %>
```

**Correct (one-line configuration in ApplicationController):**

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  default_form_builder DesignSystemFormBuilder
end
```

```erb
<%# Every form_with now uses DesignSystemFormBuilder automatically %>
<%= form_with model: @user do |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :email, help: "We'll never share your email." %>
<% end %>
```

You can still override the builder for specific forms if needed (e.g., an admin-only form with different styling):

```erb
<%= form_with model: @setting, builder: AdminFormBuilder do |f| %>
  <%= f.text_field :value %>
<% end %>
```

Reference: [ActionController default_form_builder](https://api.rubyonrails.org/classes/ActionController/FormBuilder.html)
