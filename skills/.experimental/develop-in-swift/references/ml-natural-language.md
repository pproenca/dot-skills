---
title: Use Natural Language Framework for Text Analysis
impact: MEDIUM
impactDescription: on-device ML, sentiment analysis, language detection, no network required
tags: ml, machine-learning, natural-language, sentiment, nlp
---

## Use Natural Language Framework for Text Analysis

The Natural Language framework provides on-device text analysis including sentiment analysis, language detection, and tokenization. Results are private - text never leaves the device.

**Incorrect (manual string analysis):**

```swift
// Don't manually analyze text
func isPositive(_ text: String) -> Bool {
    let positiveWords = ["good", "great", "love", "happy"]
    for word in positiveWords {
        if text.lowercased().contains(word) {
            return true  // Misses context, sarcasm, negation
        }
    }
    return false
}
```

**Basic sentiment analysis:**

```swift
import NaturalLanguage

struct SentimentAnalyzer {
    func analyzeSentiment(of text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text

        let (sentiment, _) = tagger.tag(
            at: text.startIndex,
            unit: .paragraph,
            scheme: .sentimentScore
        )

        // Returns value from -1.0 (negative) to 1.0 (positive)
        return Double(sentiment?.rawValue ?? "0") ?? 0
    }
}

// Usage
let analyzer = SentimentAnalyzer()
let score = analyzer.analyzeSentiment(of: "I love this app!")
// score ≈ 0.8 (positive)

let negativeScore = analyzer.analyzeSentiment(of: "This is terrible")
// negativeScore ≈ -0.6 (negative)
```

**SwiftUI integration:**

```swift
struct SentimentView: View {
    @State private var text = ""
    @State private var sentiment: Double = 0

    var body: some View {
        VStack {
            TextField("Enter text", text: $text)
                .onChange(of: text) { _, newValue in
                    sentiment = SentimentAnalyzer().analyzeSentiment(of: newValue)
                }

            Text(sentimentEmoji)
                .font(.largeTitle)
        }
    }

    var sentimentEmoji: String {
        switch sentiment {
        case 0.3...: return "😊"
        case -0.3..<0.3: return "😐"
        default: return "😔"
        }
    }
}
```

**Natural Language capabilities:**
- Sentiment analysis
- Language identification
- Tokenization (words, sentences)
- Part-of-speech tagging
- Named entity recognition

Reference: [Develop in Swift Tutorials - Analyze sentiment in text](https://developer.apple.com/tutorials/develop-in-swift/analyze-sentiment-in-text)
