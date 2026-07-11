---
title: Measure durations with monotonic time, never wall-clock diffs
tags: mech, time, monotonic, clock
---

## Measure durations with monotonic time, never wall-clock diffs

`DateTime.utc_now/0` and `System.system_time/1` answer "what time is it?" — a question NTP is allowed to change its mind about. Diffing two wall-clock reads to produce a duration, a deadline, or a rate window inherits every clock adjustment in between: a step backward yields negative elapsed time (crashing guards, freeing every rate limit at once), a step forward expires every timeout simultaneously. The VM maintains a second clock for exactly this reason: `System.monotonic_time/0` never goes backward and measures *elapsed runtime*, which is what a duration is. The rule of thumb is grammatical — wall clock for timestamps that name a moment (audit fields, `inserted_at`), monotonic for anything computed by subtraction.

**Evidence of violation:** two wall-clock reads (`DateTime.utc_now`, `NaiveDateTime.utc_now`, `System.system_time`, `:os.system_time`) subtracted — directly or via `DateTime.diff` — to produce a duration, timeout, deadline, cache TTL decision, or rate-limit window. PASS: durations from `System.monotonic_time/0-1` diffs (converted with `System.convert_time_unit` as needed) or `:timer.tc`; deadlines stored as monotonic instants; wall-clock values used only as data (persisted timestamps, display). N/A: no elapsed-time computation in the target. Carve-out (citable): the diff spans persistence or nodes — a stored `inserted_at` compared to now for a business rule ("expire after 30 days") — where wall-clock is the only shared clock; cite the cross-boundary requirement. Within one VM's runtime, there is no carve-out.

```elixir
def measure(fun) do
  started = System.monotonic_time()
  result = fun.()
  # Immune to NTP steps: monotonic time cannot go backward or jump.
  elapsed_ms = System.convert_time_unit(System.monotonic_time() - started, :native, :millisecond)
  {result, elapsed_ms}
end
```

Reference: [Erlang — Time and Time Correction in Erlang/OTP](https://www.erlang.org/doc/apps/erts/time_correction.html)
