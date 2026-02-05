---
title: Use Audacity for Visual Analysis and Manual Editing
impact: LOW-MEDIUM
impactDescription: enables visual inspection and precise manual edits
tags: tool, audacity, gui, visual, manual-editing
---

## Use Audacity for Visual Analysis and Manual Editing

Audacity provides visual waveform/spectrogram editing essential for manual forensic work that automated tools can't handle.

**Incorrect (command-line only for all tasks):**

```bash
# Trying to repair specific click at 3.5s via CLI
ffmpeg -i audio.wav -af "adeclick" repaired.wav
# Declicks entire file, may miss specific problem
# No visual confirmation of repair
```

**Correct (visual editing for targeted repair):**

```bash
# In Audacity GUI:
# 1. Open in Audacity: File > Open > audio.wav
# 2. View spectrogram: Track dropdown > Spectrogram
# 3. Zoom to problem area at 3.5s
# 4. Select specific click region
# 5. Effect > Spectral edit > Filter
# 6. Visually verify repair
# 7. Export: File > Export > Export as WAV
```

**When to use Audacity:**

- Visual inspection of spectrograms
- Manual selection of noise samples
- Precise cut/splice editing
- Interactive comparison of enhancement settings
- Training ear on what different problems sound like

**Essential keyboard shortcuts:**

| Shortcut | Action |
|----------|--------|
| Space | Play/Stop |
| Shift+Space | Loop play selection |
| Ctrl+1 | Zoom in |
| Ctrl+3 | Zoom out |
| Ctrl+E | Zoom to selection |
| Ctrl+F | Fit project in window |
| R | Record |
| Z | Find zero crossings |
| Ctrl+D | Duplicate selection |
| Ctrl+Shift+E | Export selected audio |

**Spectral analysis workflow:**

1. **View spectrogram:**
   - Track dropdown → Spectrogram
   - Or Spectrogram Settings for detailed view

2. **Configure spectrogram:**
   - Edit → Preferences → Spectrogram
   - Window Size: 2048 (higher = better frequency resolution)
   - Window Type: Hann
   - Min Frequency: 0 Hz (or 50 Hz to hide DC)
   - Max Frequency: 8000 Hz (for speech)
   - Color scheme: Grayscale or Color (V2)

3. **Analyze specific regions:**
   - Select region
   - Analyze → Plot Spectrum
   - Look for tonal noise (sharp peaks)
   - Look for speech formants

**Noise reduction workflow:**

```text
1. Find a silent segment (noise only, no speech)
   - Select 0.5-2 seconds of pure noise
   - This is your "noise profile" sample

2. Get noise profile:
   - Effect → Noise Reduction
   - Click "Get Noise Profile"

3. Select audio to clean:
   - Select entire track (Ctrl+A) or specific region

4. Apply noise reduction:
   - Effect → Noise Reduction
   - Set reduction amount (6-12 dB for light, 12-24 dB for heavy)
   - Sensitivity: 6 (higher = more aggressive)
   - Frequency smoothing: 3
   - Click "Preview" to test
   - Click "OK" to apply
```

**Forensic enhancement preset:**

```text
Order of operations:
1. High-pass filter (Effect → High-Pass Filter, 80 Hz)
2. Noise reduction (as above)
3. Equalization for presence:
   - Effect → Filter Curve EQ
   - Boost 2-4 kHz by 3-6 dB
   - Cut 200-400 Hz by 2-3 dB (reduce mud)
4. Compression (Effect → Compressor):
   - Threshold: -20 dB
   - Ratio: 4:1
   - Attack: 0.1s
   - Release: 1.0s
5. Normalize (Effect → Normalize, -3 dB)
```

**Spectral editing (repair specific frequencies):**

1. Switch to Spectrogram view
2. Use Spectral Selection tool (F4)
3. Draw selection around specific noise
4. Effect → Spectral edit multi-tool
   - Filter: removes selected frequencies
   - Affects only selection

**Declicking:**

1. Zoom in very close to click
2. Use Draw tool (F3) to manually redraw waveform
3. Or: Effect → Click Removal (automatic)
   - Select threshold: 200
   - Max spike width: 20

**Manual splice detection:**

1. Zoom to waveform level
2. Look for:
   - Sudden DC offset changes
   - Unnatural zero crossings
   - Phase discontinuities
3. In spectrogram view, look for:
   - Vertical lines (abrupt spectral change)
   - ENF frequency jumps

**Audacity CLI (scripting):**

```bash
# Audacity has limited CLI, but can use macro/scripting
# Export from GUI: File → Export → Export as MP3

# For batch, use Audacity macros:
# 1. Create macro in Tools → Macros
# 2. Save macro
# 3. Run from command line (experimental):
audacity -b "MacroName" file1.wav file2.wav
```

**Comparison with command-line tools:**

| Task | Audacity | FFmpeg/SoX |
|------|----------|------------|
| Visual analysis | ✅ Best | ❌ No |
| Manual editing | ✅ Best | ❌ No |
| Batch processing | ❌ Poor | ✅ Best |
| Reproducibility | ❌ Manual | ✅ Scriptable |
| Noise profiling | ✅ Visual | ✅ Automated |
| Spectral repair | ✅ Manual | ❌ Limited |

**Recommended workflow:**

1. **Audacity first:** Visual analysis, identify problems
2. **Command-line:** Apply consistent processing
3. **Audacity verify:** Check results visually
4. **Command-line:** Batch process all files

**Project file tips:**

- Always save .aup3 project for undo history
- Export enhanced version as separate file
- Document settings used in a text file

Reference: [Audacity Manual](https://manual.audacityteam.org/)
