---
title: Train a zstd Dictionary When Compressing Many Small Payloads
impact: MEDIUM
impactDescription: 2-10x better ratio on small messages (< 1 KB)
tags: codec, zstd, dictionary, small-payloads, training
---

## Train a zstd Dictionary When Compressing Many Small Payloads

zstd's compression is great when there's enough data to build per-payload statistics — but for messages under ~1 KB, the codec hasn't seen enough to find any redundancy, and the compressed size is often *bigger* than the input (header overhead exceeds savings). A *trained* dictionary, built once from a representative sample, gives the encoder a head start: the dictionary is the same across all encoders/decoders, so each small message is encoded against the same shared context. Typical wins: 2–10× better compression on small JSON, log lines, or RPC payloads.

**Incorrect (compressing tiny payloads without a dictionary — often grows them):**

```python
import zstandard as zstd

cctx = zstd.ZstdCompressor(level=3)
for msg in many_200_byte_messages:
    compressed = cctx.compress(msg)
    # compressed.size often >= msg.size for messages < 1 KB
    send(compressed)
```

**Correct (train once, reuse the dictionary forever):**

```bash
# Step 1: collect 1000-10000 sample messages (representative of the real workload).
# Step 2: train a dictionary file (typically 100 KB-1 MB).
zstd --train samples/*.json -o dict.zstd -B 4096
```

```python
import zstandard as zstd

# Load the trained dictionary once.
dict_data = zstd.ZstdCompressionDict(open("dict.zstd", "rb").read())

# Both encoder and decoder use the same dictionary.
cctx = zstd.ZstdCompressor(level=3, dict_data=dict_data)
dctx = zstd.ZstdDecompressor(dict_data=dict_data)

# Now small messages compress 2-10x better.
for msg in many_200_byte_messages:
    compressed = cctx.compress(msg)
    send(compressed)
```

**Generating a dictionary programmatically:**

```python
import zstandard as zstd

samples = [msg.encode() for msg in load_sample_messages(n=10_000)]
dict_data = zstd.train_dictionary(dict_size=100 * 1024, samples=samples)
open("dict.zstd", "wb").write(dict_data.as_bytes())
```

**When trained dictionaries help most:**
- Messages are small (< few KB) and numerous
- Messages share structure (same JSON keys, same protocol fields)
- Both sides of the wire can ship/load the same dictionary file
- Compression happens at very high QPS (CPU + bytes both matter)

**When NOT to train:**
- Payloads are large (> 64 KB) — they have enough internal redundancy to compress without a dictionary
- Producer and consumer can't sync on dictionary versions easily
- Workload is too diverse — a dictionary tuned for type A makes type B worse

**Versioning the dictionary:**

```python
# Embed a dictionary ID in each message so receivers can pick the right one.
HEADER = struct.pack(">H", DICT_VERSION_ID)
send(HEADER + cctx.compress(msg))

# On the receiver side, look up the matching dictionary by ID.
```

**Measuring the win:**

```python
# Compare raw, dictless-zstd, and dict-zstd sizes on a real sample.
raw   = sum(len(m) for m in messages)
dictless = sum(len(zstd.ZstdCompressor().compress(m)) for m in messages)
dicted   = sum(len(cctx.compress(m)) for m in messages)
print(f"raw {raw}  dictless {dictless}  dicted {dicted}")
```

Reference: [zstd — Dictionary training](https://github.com/facebook/zstd#dictionary-compression-how-to), [python-zstandard — train_dictionary](https://python-zstandard.readthedocs.io/en/latest/dictionaries.html)
