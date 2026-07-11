---
title: Copy sub-binaries out of large parents before storing them long-lived
tags: mech, binary, memory-leak, refc
---

## Copy sub-binaries out of large parents before storing them long-lived

Matching or slicing a binary whose parent is over 64 bytes (a refc binary, stored off-heap) does not copy data — it creates a sub-binary: a small reference into the parent. That is the right default for throughput, but it means a 20-byte header extracted from a 5 MB payload *is* the 5 MB payload as far as the allocator is concerned: as long as the slice lives, the parent cannot be reclaimed. Park such slices in GenServer state, ETS, or any long-lived structure and memory grows with no corresponding data — the classic BEAM leak, invisible in the code and absent from heap dumps of your own terms. This includes decoder output: JSON string values commonly reference the input binary they were parsed from. The fix is one call at the boundary between transient and long-lived: `:binary.copy/1` detaches the slice from its parent.

**Evidence of violation:** a value produced by binary pattern matching, `binary_part`, `:binary.split`, `String.split`/`slice`, or decoding (`Jason.decode` and similar) of a large external payload — a request body, socket frame, file chunk, queue message — stored without `:binary.copy/1` into a structure that outlives the payload's processing: GenServer/Agent state, an ETS table, a persistent cache, an accumulator retained across messages. PASS: `:binary.copy/1` applied at the store boundary; or the stored value is not a binary slice (parsed integers, atoms from a whitelist, structs of copied fields). N/A: no extraction-from-payload flows into long-lived storage in the target. Carve-out (citable): the parent binary is itself bounded and small (a fixed-size protocol frame, a short header line — and slices of binaries at or under 64 bytes are heap binaries, copied by construction) — cite the size bound; "payloads are usually small" is not a bound.

```elixir
def handle_info({:frame, payload}, state) do
  <<_header::binary-size(16), session_token::binary-size(24), _rest::binary>> = payload
  # The token outlives the frame — detach it, or state pins every
  # frame this process has ever extracted a token from.
  {:noreply, %{state | token: :binary.copy(session_token)}}
end
```

Reference: [Erlang Efficiency Guide — Constructing and Matching Binaries](https://www.erlang.org/doc/system/binaryhandling.html)
