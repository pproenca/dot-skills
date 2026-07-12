---
title: Precompute assigns instead of template variables
tags: render, change-tracking, variables, heex
---

## Precompute assigns instead of template variables

A local variable in a template — `<% total = Enum.count(@bids) %>`, or a variable computed at the top of `render/1` and interpolated below — forces LiveView to give up on diffing: the guide states it "has to disable change tracking whenever variables are used in the template, with the exception of variables introduced by Elixir block constructs such as `case`, `for`, `if`, and others." Every expression touching the variable is re-evaluated and re-sent on every render, because the engine cannot know when a variable changed. The fix is mechanical: derive the value through a function call on assigns (`{bid_total(@bids)}`) so tracking follows the assigns the function reads, or precompute it into its own assign with `assign/3`/`update/3`.

**Evidence of violation:** a `<% name = ... %>` binding inside HEEx, or a `render/1` that defines locals and interpolates them in the returned `~H`. PASS: dynamic expressions reference `@assigns` directly or call functions whose arguments are assigns. Variables introduced by block constructs — `case`/`if`/`for` clause bindings, `:let` bindings on components and slots — are the guide's documented exception and PASS automatically, no citation needed. N/A: the target contains no HEEx templates.

```heex
<p class="text-sm">
  {length(@recent_bids)} bids — high bid {format_amount(highest_bid(@recent_bids))}
</p>
```

Reference: [Assigns and HEEx templates — Variables pitfall](https://hexdocs.pm/phoenix_live_view/assigns-eex.html)
