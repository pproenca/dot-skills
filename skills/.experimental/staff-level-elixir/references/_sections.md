# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

This is a correctness/idiom skill, not a performance skill, so no impact tiers.

---

## 1. Process & OTP Design (otp)

**Description:** The judgment that separates staff-level Elixir from the rest: whether a problem needs a process at all, and if so, which one. Corrects the reflex to model everything as a GenServer — a single serialization point — instead of plain modules, ETS, Tasks, and well-shaped supervision trees.

## 2. Error Handling & Let-It-Crash (err)

**Description:** How to signal and handle failure on the BEAM. Corrects raising for expected failures, and the defensive `try/rescue` habit that masks bugs and defeats the supervisor's ability to restart from clean state.

## 3. Idioms & Design Choices (data)

**Description:** The everyday language-level decisions where a competent-but-not-fluent default reads as non-idiomatic or quietly slow: conditionals over pattern matching, eager `Enum` over `Stream` (and vice versa), binary concatenation over iolists, awkward pipelines, and reaching for macros where a function suffices.

## 4. Concurrency & the Scheduler (conc)

**Description:** Running work in parallel without kneecapping the VM. Corrects unbounded/linked `Task` fan-out, ignored timeouts, and creating atoms from external input — a denial-of-service vector because atoms are never garbage collected.

## 5. Ecto & Data Access (ecto)

**Description:** The data-access mistakes that pass tests and fail in production: N+1 association loads, non-atomic multi-step writes, uniqueness enforced only in Elixir (a race), and loading whole tables into memory.

## 6. Phoenix & LiveView (phx)

**Description:** Keeping the web layer thin and LiveView cheap. Corrects calling `Repo`/schemas directly from controllers and LiveViews, holding large collections in socket assigns, and running side effects during the disconnected mount.
