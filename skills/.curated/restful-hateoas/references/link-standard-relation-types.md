---
title: Use Standard IANA Link Relation Types
impact: CRITICAL
impactDescription: enables generic hypermedia clients, improves API discoverability
tags: link, iana, relation-types, standards, discoverability
---

## Use Standard IANA Link Relation Types

Use IANA-registered link relation types (`self`, `next`, `prev`, `collection`, `item`, `edit`, `related`) instead of inventing custom names. Standard rels have defined semantics that generic clients already understand. When you need a custom relation, use a URI (not a bare string) to avoid collisions and provide documentation.

**Incorrect (invented relation names with no standard meaning):**

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  private

  def extra_links
    {
      get_customer: { href: "/api/v1/customers/#{@resource.customer_id}" },
      do_cancel: { href: "/api/v1/orders/#{@resource.id}/cancel" },
      fetch_items: { href: "/api/v1/orders/#{@resource.id}/items" },
      parent_list: { href: "/api/v1/orders" }
    }
    # Every client must learn what "get_customer" and "do_cancel" mean
  end
end
```

**Correct (IANA standard rels, custom rels use URIs):**

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  CUSTOM_REL_BASE = "https://api.example.com/rels".freeze

  private

  def extra_links
    links = {
      related: { href: "/api/v1/customers/#{@resource.customer_id}" },  # IANA: related resource
      collection: { href: "/api/v1/orders" },                           # IANA: parent collection
      item: @resource.line_items.map { |li|                             # IANA: child items
        { href: "/api/v1/orders/#{@resource.id}/line_items/#{li.id}" }
      }
    }
    if @resource.cancellable?
      links["#{CUSTOM_REL_BASE}/cancel"] = {  # custom rel uses URI namespace
        href: "/api/v1/orders/#{@resource.id}/cancellation",
        method: "POST"
      }
    end
    links
  end
end
```

**Common IANA relation types for REST APIs:**
| Rel | Use for |
|-----|---------|
| `self` | Canonical URI of this resource |
| `collection` | Parent collection this item belongs to |
| `item` | Individual items within a collection |
| `next` / `prev` | Pagination navigation |
| `first` / `last` | Pagination boundaries |
| `edit` | URI to edit this resource (PUT/PATCH) |
| `related` | A related resource |

**Reference:** [IANA Link Relations Registry](https://www.iana.org/assignments/link-relations/link-relations.xhtml). See also `restful-hateoas:link-self-link-every-resource`.
