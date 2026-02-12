---
title: Disable Turbo Drive on Incompatible Pages
impact: HIGH
impactDescription: prevents broken third-party widget interactions
tags: drive, disable, compatibility, third-party
---

## Disable Turbo Drive on Incompatible Pages

Turbo Drive intercepts all link clicks and form submissions by default, which breaks external OAuth redirects, payment gateway forms, file downloads, and third-party JavaScript widgets that expect full page loads. Disable Turbo on specific elements with `data-turbo="false"` rather than disabling it globally, which would eliminate all Turbo benefits.

**Incorrect (Turbo intercepting external redirects and payment forms):**

```erb
<%# OAuth link intercepted by Turbo — redirect fails silently %>
<%= link_to "Sign in with Google",
    user_google_oauth2_omniauth_authorize_path %>

<%# Stripe Checkout form broken by Turbo interception %>
<%= form_with url: create_checkout_session_path do |f| %>
  <%= f.hidden_field :price_id, value: @price.id %>
  <%= f.submit "Subscribe" %>
<% end %>

<%# File download intercepted instead of triggering browser download %>
<%= link_to "Download CSV", export_projects_path(format: :csv) %>
```

**Correct (Turbo disabled on specific incompatible elements):**

```erb
<%# Disable Turbo for OAuth redirects %>
<%= link_to "Sign in with Google",
    user_google_oauth2_omniauth_authorize_path,
    data: { turbo: false } %>

<%# Disable Turbo for payment forms that redirect externally %>
<%= form_with url: create_checkout_session_path,
    data: { turbo: false } do |f| %>
  <%= f.hidden_field :price_id, value: @price.id %>
  <%= f.submit "Subscribe" %>
<% end %>

<%# Disable Turbo for file downloads %>
<%= link_to "Download CSV", export_projects_path(format: :csv),
    data: { turbo: false } %>

<%# Scope disabling to a container for third-party widgets %>
<div data-turbo="false">
  <div id="hubspot-form"></div>
  <script>
    hbspt.forms.create({ portalId: "123", formId: "abc" });
  </script>
</div>
```
