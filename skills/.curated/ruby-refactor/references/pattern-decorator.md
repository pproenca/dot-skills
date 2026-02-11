---
title: Wrap Objects with Decorator for Added Behavior
impact: MEDIUM
impactDescription: adds behavior without modifying original class
tags: pattern, decorator, wrapper, composition
---

## Wrap Objects with Decorator for Added Behavior

When cross-cutting concerns like logging, caching, and retries are added through subclassing, the number of subclasses explodes combinatorially (LoggingClient, CachingClient, LoggingCachingClient, etc.). Decorators using `SimpleDelegator` let you stack behaviors independently and in any order, keeping each concern in its own class.

**Incorrect (subclass explosion for every combination of concerns):**

```ruby
class HttpClient
  def fetch(url)
    Net::HTTP.get(URI(url))
  end
end

class LoggingHttpClient < HttpClient
  def fetch(url)
    Rails.logger.info("HTTP GET #{url}")
    result = super
    Rails.logger.info("HTTP 200 #{url} (#{result.bytesize} bytes)")
    result
  end
end

# CachingLoggingHttpClient, RetryLoggingHttpClient, RetryLoggingCachingHttpClient…
# each combination requires a new subclass
class CachingLoggingHttpClient < LoggingHttpClient
  def fetch(url)
    @cache ||= {}
    @cache[url] ||= super
  end
end
```

**Correct (stacked decorators using SimpleDelegator):**

```ruby
class HttpClient
  def fetch(url)
    Net::HTTP.get(URI(url))
  end
end

class LoggingDecorator < SimpleDelegator
  def fetch(url)
    Rails.logger.info("HTTP GET #{url}")
    result = super  # delegates to wrapped object
    Rails.logger.info("HTTP 200 #{url} (#{result.bytesize} bytes)")
    result
  end
end

class CachingDecorator < SimpleDelegator
  def initialize(client)
    super
    @cache = {}
  end

  def fetch(url)
    @cache[url] ||= super
  end
end

class RetryDecorator < SimpleDelegator
  def fetch(url, retries: 3)
    attempts = 0
    begin
      attempts += 1
      super(url)
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise e if attempts >= retries
      retry  # each decorator handles one concern independently
    end
  end
end

# Stack any combination without new classes
client = HttpClient.new
client = LoggingDecorator.new(client)
client = CachingDecorator.new(client)
client = RetryDecorator.new(client)
client.fetch("https://api.example.com/data")
```
