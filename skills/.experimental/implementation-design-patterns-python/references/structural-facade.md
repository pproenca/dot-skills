---
title: Use Facade to Hide a Complex Subsystem Behind One Interface
impact: HIGH
impactDescription: replaces sprawling client code that wires many subsystem objects with a single entry point, reduces coupling between application code and library internals, eliminates duplicated initialization sequences across callers
tags: structural, facade, subsystem, module-api, simplification
---

## Use Facade to Hide a Complex Subsystem Behind One Interface

**Pattern intent:** provide a simple, narrow interface to a large subsystem so clients don't orchestrate its internals. In Python a **module** is the most natural facade — a handful of public functions over many private helpers — and a small class works too. Either way the subsystem's wiring lives in one place.

### Shapes to recognize

- Client code that imports and sequences many objects from a library to get one result
- The same multi-step initialization (`open → configure → run → close`) copied across callers
- A third-party subsystem whose internals leak into application code
- "I just want `convert(file, format)` — I shouldn't have to know about codecs and bitrate readers"

### Problem

Converting a video means juggling a file reader, a codec factory, a bitrate reader, and an audio mixer in the right order. Each caller that needs a conversion repeats this dance, couples to every subsystem class, and breaks when the subsystem's internals change.

### Solution

Expose one function (or small class) that performs the whole sequence internally. Callers depend only on the facade; the subsystem stays free to change behind it.

**Incorrect (each caller wires the subsystem by hand):**

```python
file = VideoFile("clip.ogg")
codec = CodecFactory.extract(file)
stream = BitrateReader.read(file, codec)
stream = AudioMixer.fix(stream)
result = f"{stream} -> mp4"
# Every place that converts a video repeats all of this and couples to all four classes.
```

**Correct (one entry point hides the orchestration):**

```python
class VideoFile:
    def __init__(self, name: str) -> None:
        self.name, self.codec = name, name.split(".")[-1]

class CodecFactory:
    @staticmethod
    def extract(file: VideoFile) -> str:
        return file.codec

class BitrateReader:
    @staticmethod
    def read(file: VideoFile, codec: str) -> str:
        return f"{file.name} stream[{codec}]"

class AudioMixer:
    @staticmethod
    def fix(stream: str) -> str:
        return f"{stream}+audio"

def convert_video(filename: str, target_format: str) -> str:   # the facade
    file = VideoFile(filename)
    stream = BitrateReader.read(file, CodecFactory.extract(file))
    return f"{AudioMixer.fix(stream)} -> {target_format}"

print(convert_video("clip.ogg", "mp4"))
```

**Output:**

```text
clip.ogg stream[ogg]+audio -> mp4
```

### When to use

- A subsystem is complex and most clients need only a small, common slice of it
- You want to decouple application code from a library's internal structure
- You are layering a system and want a clear entry point per layer

### When NOT to use

- The subsystem is already simple — a facade adds a pointless layer
- Clients genuinely need fine-grained control — a facade that hides too much forces awkward workarounds
- You are matching one existing interface to another — that is **Adapter**, not Facade

### Implementation Steps

1. Identify the common task clients accomplish by orchestrating the subsystem
2. Create a module (or class) exposing one method per common task
3. Move the orchestration and wiring into that method
4. Have clients call the facade and stop importing subsystem internals
5. Keep advanced/raw access available for the rare client that needs it

### Pros

- Shields client code from subsystem complexity and churn
- Centralizes initialization and orchestration in one place
- A module facade requires no class at all — just public functions

### Cons

- A facade can become a god object coupled to every subsystem class
- Hiding capability can frustrate clients who need lower-level control

### Related Patterns

- **Adapter** — converts one existing interface to another; Facade defines a new simplified one
- **Mediator** — also centralizes interaction, but between peer components rather than over a subsystem
- **Singleton** — a facade is frequently exposed as a single module-level instance
- **Abstract Factory** — can hide how subsystem objects are created behind a facade

Reference: [refactoring.guru/design-patterns/facade/python](https://refactoring.guru/design-patterns/facade/python/example)
