---
title: Use Whisper for Noise-Robust Transcription
impact: MEDIUM
impactDescription: transcribes speech at SNR below 10 dB
tags: transcribe, whisper, asr, speech-recognition, openai
---

## Use Whisper for Noise-Robust Transcription

OpenAI's Whisper is trained on diverse, noisy data making it more robust than traditional ASR for degraded audio.

**Incorrect (preprocessing that hurts Whisper):**

```bash
# Aggressive denoising can remove speech cues Whisper uses
ffmpeg -i noisy.wav -af "afftdn=nr=40" over_denoised.wav
whisper over_denoised.wav
# May perform worse than raw audio
```

**Correct (minimal preprocessing for Whisper):**

```bash
# Whisper works best with 16kHz audio
ffmpeg -i input.wav -ar 16000 -ac 1 whisper_ready.wav

# Run Whisper
whisper whisper_ready.wav --model large-v3 --language en

# For very noisy audio, try medium denoising first
ffmpeg -i noisy.wav -ar 16000 -ac 1 -af "afftdn=nr=12" lightly_denoised.wav
whisper lightly_denoised.wav --model large-v3
```

**Python Whisper workflow:**

```python
import whisper
import numpy as np
import librosa
import soundfile as sf

def transcribe_with_whisper(audio_path, model_size='large-v3', language='en'):
    """
    Transcribe audio using OpenAI Whisper.
    """
    # Load model
    model = whisper.load_model(model_size)

    # Transcribe
    result = model.transcribe(
        audio_path,
        language=language,
        task='transcribe',
        verbose=True
    )

    return result

def prepare_for_whisper(audio, sr):
    """
    Prepare audio for optimal Whisper performance.
    """
    # Whisper expects 16kHz mono
    if sr != 16000:
        audio = librosa.resample(audio, orig_sr=sr, target_sr=16000)
        sr = 16000

    # Ensure mono
    if audio.ndim > 1:
        audio = audio.mean(axis=1)

    # Normalize
    peak = np.max(np.abs(audio))
    if peak > 0:
        audio = audio / peak * 0.9

    return audio, sr

def transcribe_segments(audio, sr, segment_duration=30):
    """
    Transcribe long audio in segments for better accuracy.
    """
    model = whisper.load_model('large-v3')

    segment_samples = segment_duration * sr
    segments = []

    for i in range(0, len(audio), segment_samples):
        segment = audio[i:i + segment_samples]

        # Pad if too short
        if len(segment) < sr:  # Less than 1 second
            continue

        # Transcribe segment
        result = model.transcribe(
            segment,
            language='en',
            fp16=False  # Use fp32 for better accuracy
        )

        start_time = i / sr
        for seg in result['segments']:
            segments.append({
                'start': start_time + seg['start'],
                'end': start_time + seg['end'],
                'text': seg['text']
            })

    return segments

def transcribe_with_confidence(audio_path, model_size='large-v3'):
    """
    Transcribe and return confidence scores.
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

def multi_model_transcription(audio_path):
    """
    Transcribe with multiple models and compare.
    """
    models = ['small', 'medium', 'large-v3']
    results = {}

    for model_name in models:
        print(f"Transcribing with {model_name}...")
        model = whisper.load_model(model_name)
        result = model.transcribe(audio_path, language='en')
        results[model_name] = result['text']

    return results

def whisper_with_preprocessing_comparison(audio_path):
    """
    Compare Whisper results with different preprocessing.
    """
    import noisereduce as nr

    audio, sr = librosa.load(audio_path, sr=16000)
    model = whisper.load_model('large-v3')

    results = {}

    # 1. Raw audio
    raw_result = model.transcribe(audio, language='en')
    results['raw'] = raw_result['text']

    # 2. Light noise reduction
    light_nr = nr.reduce_noise(y=audio, sr=sr, prop_decrease=0.3)
    sf.write('temp_light.wav', light_nr, sr)
    light_result = model.transcribe('temp_light.wav', language='en')
    results['light_nr'] = light_result['text']

    # 3. Medium noise reduction
    medium_nr = nr.reduce_noise(y=audio, sr=sr, prop_decrease=0.6)
    sf.write('temp_medium.wav', medium_nr, sr)
    medium_result = model.transcribe('temp_medium.wav', language='en')
    results['medium_nr'] = medium_result['text']

    return results

# Usage
if __name__ == '__main__':
    # Simple transcription
    result = transcribe_with_whisper('audio.wav')
    print(result['text'])

    # With word timestamps
    text, words = transcribe_with_confidence('audio.wav')
    for word in words[:10]:
        print(f"{word['start']:.2f}s: {word['word']}")
```

**Install Whisper:**

```bash
pip install openai-whisper

# Or use faster-whisper for better performance
pip install faster-whisper
```

**Whisper model comparison:**

| Model | Size | Speed | Accuracy | VRAM |
|-------|------|-------|----------|------|
| tiny | 39M | Very fast | Low | 1 GB |
| small | 244M | Fast | Good | 2 GB |
| medium | 769M | Medium | Better | 5 GB |
| large-v3 | 1550M | Slow | Best | 10 GB |

**Preprocessing recommendations:**

| Audio Quality | Preprocessing | Notes |
|--------------|---------------|-------|
| Clean | None | Whisper handles well |
| Light noise | None or light NR | Test both |
| Heavy noise | Light NR (prop=0.3-0.5) | Heavy NR can hurt |
| Very degraded | VAD + segmentation | Process speech only |

Reference: [OpenAI Whisper](https://github.com/openai/whisper)
