---
title: Avoid Conditional Logic in Tests
impact: HIGH
impactDescription: prevents tests from testing themselves — 0 branches per test
tags: design, conditional, branching, complexity, test-smell
---

## Avoid Conditional Logic in Tests

If/else statements, ternaries, loops, and rescue blocks in tests mean the test itself has multiple execution paths — which means you'd need tests for your tests. Each branch should be a separate example with a deterministic setup and a single expected outcome.

**Incorrect (conditional logic makes the test non-deterministic):**

```ruby
RSpec.describe CurrencyConverter do
  describe "#convert" do
    it "converts between currencies" do
      converter = described_class.new

      %w[USD EUR GBP JPY].each do |currency|
        result = converter.convert(100, from: "USD", to: currency)

        if currency == "USD"
          expect(result).to eq(100)
        elsif currency == "JPY"
          expect(result).to be > 100
        else
          expect(result).to be < 100
        end
      rescue StandardError => e
        fail "Conversion to #{currency} raised: #{e.message}"
      end
    end
  end
end
```

**Correct (one deterministic test per scenario):**

```ruby
RSpec.describe CurrencyConverter do
  describe "#convert" do
    it "returns the same amount when source and target currency are identical" do
      converter = described_class.new

      result = converter.convert(100, from: "USD", to: "USD")

      expect(result).to eq(100)
    end

    it "converts USD to EUR using the current exchange rate" do
      converter = described_class.new(rates: { "USD_EUR" => 0.92 })

      result = converter.convert(100, from: "USD", to: "EUR")

      expect(result).to eq(92)
    end

    it "converts USD to JPY using the current exchange rate" do
      converter = described_class.new(rates: { "USD_JPY" => 149.50 })

      result = converter.convert(100, from: "USD", to: "JPY")

      expect(result).to eq(14_950)
    end

    it "raises UnsupportedCurrencyError for unknown currency pairs" do
      converter = described_class.new

      expect {
        converter.convert(100, from: "USD", to: "XYZ")
      }.to raise_error(CurrencyConverter::UnsupportedCurrencyError)
    end
  end
end
```

Reference: [Better Specs](https://www.betterspecs.org/)
