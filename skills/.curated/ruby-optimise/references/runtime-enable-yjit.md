---
title: Enable YJIT for Production
impact: MEDIUM
impactDescription: 15-25% latency reduction with zero code changes
tags: runtime, yjit, jit, performance
---

## Enable YJIT for Production

YJIT is Ruby's built-in JIT compiler that compiles frequently-executed methods to native code at runtime. It ships with Ruby 3.1+ and is production-ready since Ruby 3.2, delivering significant latency improvements for web workloads with negligible memory cost.

**Incorrect (default interpreter without JIT compilation):**

```ruby
# Procfile or deployment config
# Ruby runs in interpreter-only mode by default
web: bundle exec puma -C config/puma.rb

# No JIT compilation, every method call goes through
# the interpreter on every invocation
# Hot paths like serialization and routing pay full
# interpreter overhead on each request
```

**Correct (YJIT enabled for native code compilation):**

```ruby
# Option 1: Environment variable (recommended for containers)
# Dockerfile or .env
# RUBY_YJIT_ENABLE=1

# Option 2: Command-line flag
# Procfile
web: bundle exec ruby --yjit -S puma -C config/puma.rb

# config/initializers/yjit.rb
if defined?(RubyVM::YJIT) && RubyVM::YJIT.enabled?
  Rails.logger.info(
    "YJIT enabled: #{RubyVM::YJIT.runtime_stats[:compiled_iseq_count]} methods compiled"
  )
end
```
