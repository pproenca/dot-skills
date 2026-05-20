---
title: Choose Follow-Up Messages or Silent Tool Calls
impact: HIGH
impactDescription: prevents chat spam and lost model context
tags: bridge, follow-up, call-tool, conversation
---

## Choose Follow-Up Messages or Silent Tool Calls

The bridge offers two ways to act, with opposite effects on the conversation. `sendFollowUpMessage` (the `ui/message` method) injects a user turn the model responds to; `callTool` runs a tool quietly and updates the widget without adding to the transcript. Use a follow-up when the user wants the model to react, and a silent call for in-widget data operations. Swapping them either floods the chat with noise or hides an action the model needed to see.

**Incorrect (every filter click injects a chat turn; the transcript fills with noise):**

```tsx
const onlyDirect = () => window.openai.sendFollowUpMessage({ prompt: "show only direct flights" });
```

**Correct (filter silently in-widget; reserve a follow-up for a decision the model should act on):**

```tsx
const onlyDirect = () => window.openai.callTool("filter_flights", { direct: true });          // silent refine
const book = (id: string) => window.openai.sendFollowUpMessage({ prompt: `Book flight ${id}` }); // model acts
```

A useful test: if the model would have nothing meaningful to say about the action, it should be a silent `callTool`.

Reference: [Build your ChatGPT UI – Apps SDK](https://developers.openai.com/apps-sdk/build/chatgpt-ui)
