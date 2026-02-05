---
title: Track Confidence Scores for Uncertain Words
impact: MEDIUM
impactDescription: identifies unreliable transcription sections
tags: transcribe, confidence, uncertainty, verification, review
---

## Track Confidence Scores for Uncertain Words

ASR confidence scores identify words that need human review. Flag low-confidence sections for manual verification.

**Incorrect (accept all text equally):**

```python
# Treating all words as equally reliable
result = model.transcribe(audio)
print(result['text'])  # No indication of confidence
```

**Correct (track and flag uncertainty):**

```python
import whisper
import numpy as np
import librosa

def transcribe_with_confidence(audio_path, model_size='large-v3'):
    """
    Transcribe and extract word-level confidence scores.
    """
    model = whisper.load_model(model_size)

    result = model.transcribe(
        audio_path,
        language='en',
        word_timestamps=True
    )

    words_with_confidence = []
    for segment in result['segments']:
        if 'words' in segment:
            for word in segment['words']:
                words_with_confidence.append({
                    'word': word['word'],
                    'start': word['start'],
                    'end': word['end'],
                    'probability': word.get('probability', None)
                })

    return result['text'], words_with_confidence

def flag_uncertain_sections(words_with_confidence, threshold=0.7):
    """
    Identify sections with low confidence for human review.
    """
    uncertain_sections = []
    current_uncertain = None

    for word in words_with_confidence:
        prob = word.get('probability', 1.0)
        if prob is None:
            prob = 1.0

        if prob < threshold:
            if current_uncertain is None:
                current_uncertain = {
                    'start': word['start'],
                    'end': word['end'],
                    'words': [word['word']],
                    'avg_confidence': prob
                }
            else:
                current_uncertain['end'] = word['end']
                current_uncertain['words'].append(word['word'])
                current_uncertain['avg_confidence'] = (
                    (current_uncertain['avg_confidence'] * (len(current_uncertain['words']) - 1) + prob)
                    / len(current_uncertain['words'])
                )
        else:
            if current_uncertain is not None:
                uncertain_sections.append(current_uncertain)
                current_uncertain = None

    if current_uncertain is not None:
        uncertain_sections.append(current_uncertain)

    return uncertain_sections

def generate_review_transcript(audio_path, confidence_threshold=0.7):
    """
    Generate transcript with uncertainty markers for review.
    """
    text, words = transcribe_with_confidence(audio_path)

    # Build marked-up transcript
    marked_text = []
    current_uncertain = False

    for word in words:
        prob = word.get('probability', 1.0) or 1.0

        if prob < confidence_threshold:
            if not current_uncertain:
                marked_text.append('[?')
                current_uncertain = True
            marked_text.append(word['word'])
        else:
            if current_uncertain:
                marked_text.append('?]')
                current_uncertain = False
            marked_text.append(word['word'])

    if current_uncertain:
        marked_text.append('?]')

    return ' '.join(marked_text)

def export_uncertainty_report(audio_path, output_path):
    """
    Export detailed uncertainty report.
    """
    text, words = transcribe_with_confidence(audio_path)
    uncertain = flag_uncertain_sections(words)

    report = []
    report.append("TRANSCRIPTION UNCERTAINTY REPORT")
    report.append("=" * 50)
    report.append(f"\nFull transcript:\n{text}\n")
    report.append(f"\nUncertain sections ({len(uncertain)} found):")
    report.append("-" * 50)

    for i, section in enumerate(uncertain, 1):
        report.append(f"\n{i}. [{section['start']:.1f}s - {section['end']:.1f}s]")
        report.append(f"   Text: {' '.join(section['words'])}")
        report.append(f"   Avg confidence: {section['avg_confidence']:.1%}")

    # Overall statistics
    if words:
        probs = [w.get('probability', 1.0) or 1.0 for w in words]
        report.append(f"\n\nStatistics:")
        report.append(f"  Total words: {len(words)}")
        report.append(f"  Average confidence: {np.mean(probs):.1%}")
        report.append(f"  Low confidence words (<70%): {sum(1 for p in probs if p < 0.7)}")
        report.append(f"  Very low confidence words (<50%): {sum(1 for p in probs if p < 0.5)}")

    report_text = '\n'.join(report)

    with open(output_path, 'w') as f:
        f.write(report_text)

    return report_text

def confidence_colored_html(audio_path, output_path):
    """
    Generate HTML transcript with color-coded confidence.
    """
    text, words = transcribe_with_confidence(audio_path)

    html = ['<!DOCTYPE html><html><head>',
            '<style>',
            '.high { background-color: #90EE90; }',
            '.medium { background-color: #FFFFE0; }',
            '.low { background-color: #FFB6C1; }',
            'span { padding: 2px; margin: 1px; display: inline-block; }',
            '</style></head><body>']

    for word in words:
        prob = word.get('probability', 1.0) or 1.0

        if prob >= 0.8:
            css_class = 'high'
        elif prob >= 0.6:
            css_class = 'medium'
        else:
            css_class = 'low'

        html.append(f'<span class="{css_class}" title="{prob:.0%}">{word["word"]}</span>')

    html.append('<br><br>')
    html.append('<div>Legend: <span class="high">High (&gt;80%)</span>')
    html.append('<span class="medium">Medium (60-80%)</span>')
    html.append('<span class="low">Low (&lt;60%)</span></div>')
    html.append('</body></html>')

    html_content = '\n'.join(html)

    with open(output_path, 'w') as f:
        f.write(html_content)

    return html_content

# Usage
if __name__ == '__main__':
    # Get transcript with uncertainty markers
    marked_transcript = generate_review_transcript('difficult_audio.wav')
    print(marked_transcript)

    # Export detailed report
    report = export_uncertainty_report('difficult_audio.wav', 'uncertainty_report.txt')

    # Generate color-coded HTML
    confidence_colored_html('difficult_audio.wav', 'transcript.html')
```

**Confidence interpretation:**

| Confidence | Interpretation | Action |
|------------|----------------|--------|
| > 90% | Very reliable | Accept |
| 70-90% | Probably correct | Accept with note |
| 50-70% | Uncertain | Mark for review |
| < 50% | Likely wrong | Require human verification |

Reference: [Whisper Word Timestamps](https://github.com/openai/whisper)
