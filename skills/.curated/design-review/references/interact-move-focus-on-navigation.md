---
title: Move focus to new content after client-side navigation
tags: interact, navigation, focus
---

## Move focus to new content after client-side navigation

After a client-side route change the DOM updates but focus stays on the link the user clicked and nothing is announced, so keyboard and screen-reader users have no idea the view changed and must tab from the top to discover it. On each route change, move focus to the new page's main heading (made focusable with `tabIndex={-1}`): it's a tested pattern that drops keyboard users straight onto the new content and gives screen readers a concise announcement of where they've landed. (A polite `aria-live` route announcer is a common complement.)

```tsx
// On every route change, move focus to the page heading so AT users land on new content
const headingRef = useRef<HTMLHeadingElement>(null);
useEffect(() => { headingRef.current?.focus(); }, [pathname]);

<h1 ref={headingRef} tabIndex={-1} className="text-3xl font-bold">
  {pageTitle}
</h1>
```

Reference: [Gatsby — User testing of accessible client-side routing](https://www.gatsbyjs.com/blog/2019-07-11-user-testing-accessible-client-routing/)
