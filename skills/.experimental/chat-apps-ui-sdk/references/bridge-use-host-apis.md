---
title: Use Host Bridge APIs Instead of Reimplementing
impact: MEDIUM-HIGH
impactDescription: prevents broken pickers and unvetted links
tags: bridge, file-upload, open-external, host-api
---

## Use Host Bridge APIs Instead of Reimplementing

The host exposes first-class operations — `uploadFile`, `selectFiles`, `openExternal`, `requestModal` — that integrate with its file store, link vetting, and modal chrome. Rebuilding a raw `<input type="file">` or a `target="_blank"` anchor inside the sandbox bypasses that integration and often fails outright against the iframe's sandbox restrictions, so the control silently does nothing.

**Incorrect (a raw file input and a new-tab anchor fight the sandbox):**

```tsx
<input type="file" onChange={(e) => uploadDirect(e.target.files![0])} />
<a href={ticketUrl} target="_blank" rel="noreferrer">Open ticket</a>
```

**Correct (use host operations that integrate with its file store and link vetting):**

```tsx
<button onClick={async () => { const files = await window.openai.selectFiles(); attach(files); }}>Attach</button>
<button onClick={() => window.openai.openExternal({ href: ticketUrl })}>Open ticket</button>
```

These APIs are extensions, so feature-detect them on hosts that may not implement them (see [[dist-feature-detect-host-apis]]).

Reference: [Reference – Apps SDK](https://developers.openai.com/apps-sdk/reference)
