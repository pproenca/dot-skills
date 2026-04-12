---
title: Detect unbracketed paste bursts via a character timing state machine
impact: MEDIUM
impactDescription: prevents mid-paste shortcut key interpretation on terminals without bracketed paste
tags: tui, input, paste, state-machine
---

## Detect unbracketed paste bursts via a character timing state machine

Windows consoles, VS Code integrated terminals, and a surprising number of environments cannot deliver a single `Event::Paste` — they send one `KeyCode::Char` per pasted character, and if one of those is a shortcut key (like `?`) it gets interpreted mid-paste. Codex builds a pure state machine that consumes plain char events and returns a decision: `RetainFirstChar` (hold the first fast char so you can unwind), `BeginBufferFromPending`, `BeginBuffer { retro_chars }` (retroactively yank N already-inserted chars out of the textarea), or `BufferAppend`.

**Incorrect (insert each char immediately, mid-paste shortcuts fire):**

```rust
fn on_key(event: KeyEvent, textarea: &mut TextArea) {
    if let KeyCode::Char(ch) = event.code {
        textarea.insert(ch); // pasted "?" triggers help dialog
    }
}
```

**Correct (character-timing state machine returns decisions):**

```rust
// tui/src/bottom_pane/paste_burst.rs
#[cfg(not(windows))]
const PASTE_BURST_CHAR_INTERVAL: Duration = Duration::from_millis(8);
#[cfg(windows)]
const PASTE_BURST_CHAR_INTERVAL: Duration = Duration::from_millis(30);

pub fn on_plain_char(
    &mut self,
    character: char,
    now: Instant,
) -> CharDecision {
    self.note_plain_char(now);
    if self.active {
        return CharDecision::BufferAppend;
    }
    // Two fast chars -> upgrade held char into buffer
    if let Some((held, held_at)) = self.pending_first_char
        && now.duration_since(held_at) <= PASTE_BURST_CHAR_INTERVAL
    {
        self.active = true;
        let _ = self.pending_first_char.take();
        self.buffer.push(held);
        return CharDecision::BeginBufferFromPending;
    }
    if self.consecutive_plain_char_burst >= PASTE_BURST_MIN_CHARS {
        return CharDecision::BeginBuffer {
            retro_chars: self
                .consecutive_plain_char_burst
                .saturating_sub(1),
        };
    }
    self.pending_first_char = Some((character, now));
    CharDecision::RetainFirstChar
}
```

The `PasteBurst` never touches the textarea itself — it only returns decisions, and `ChatComposer` interprets them. That is why it is unit-testable. A specific pitfall is spelled out in `docs/tui-chat-composer.md`: `clear_window_after_non_char` clears the last timestamp, so if you call it while `buffer` is non-empty without flushing first, the buffered text will never flush. The rule: flush before clearing, always.

Reference: `codex-rs/tui/src/bottom_pane/paste_burst.rs:148`, `codex-rs/docs/tui-chat-composer.md`.
