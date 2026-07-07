# Fourier Series Decomposition and Musical Synthesis

University project (UE IRP) aiming to analyze and resynthesize musical notes (guitar, piano, saxophone) based on their Fourier series decomposition, by estimating the fundamental frequency, the harmonic coefficients, and the temporal envelope of the signal.

## Authors
ALEGRE Elisa, TIRECHE Sofiane, VALVERDE Simon

Supervisor: Haï Meïr Alezra — Université de Toulouse, May 2026

## Context

Starting from an audio recording of an instrument (guitar, piano, or saxophone), the project aims to:

1. **Estimate the fundamental frequency** of the played note, by searching a frequency grid that minimizes the reconstruction squared error
2. **Extract the Fourier coefficients** (amplitude and phase of each harmonic) from a stable ("sustain") region of the signal
3. **Extract the temporal envelope** of the sound via the Hilbert transform, smoothed with a Butterworth filter
4. **Resynthesize the note** by combining the timbre (harmonics) and the envelope
5. **Generate a full musical scale** by applying the process to several frequencies
6. **Evaluate the synthesis quality** using two metrics: RMSE (amplitude deviation) and Pearson correlation (envelope comparison)

## Repository structure

```
.
├── README.md
├── .gitignore
├── docs/
│   └── ALEGRE_TIRECHE_VALVERDE_IRP.pdf   # full presentation report
├── audio/
│   ├── guitar.mp3                        # source guitar recording
│   ├── piano.mp3                         # source piano recording
│   └── saxo.mp3                          # source saxophone recording
└── src/
    └── CODE_ALEGRE_TIRECHE_VALVERDE_FINAL.m   # full MATLAB script
```

## Requirements

- **MATLAB** (tested with the 2024/2025 version)
- **Signal Processing Toolbox** (`hilbert`, `butter`, `filtfilt` functions)
- An audio backend capable of reading `.mp3` files via `audioread`

## Usage

1. Open `src/CODE_ALEGRE_TIRECHE_VALVERDE_FINAL.m` in MATLAB
2. Place the audio files (`audio/guitar.mp3`, `audio/piano.mp3`, `audio/saxo.mp3`) in the same folder as the script, or adjust the paths in the code
3. Choose the instrument to analyze by uncommenting the corresponding `audioread` line (piano by default)
4. Adjust the "sustain" region (`t_debut`, `t_fin`) if needed, specific to each instrument
5. Run the script section by section (`%%`) to follow each step: f0 detection, coefficient extraction, envelope extraction, synthesis, scale generation, metrics

The script outputs several `.wav` files (raw synthesized sound, synthesized note, full scale) as well as figures illustrating each step.

## Results

Metrics obtained on the note synthesis for each instrument:

| Instrument | RMSE | Pearson |
|---|---|---|
| Guitar | 7.16×10⁻³ | 0.9820 |
| Piano | 6.31×10⁻³ | 0.9952 |
| Saxophone | 8.36×10⁻² | 0.9734 |

A Pearson score close to 1 and a low RMSE indicate a synthesis that closely matches the envelope and amplitude of the original signal.

For the full methodology and visualizations, see the report in `docs/`.

## References

See the last section of the PDF report (`docs/ALEGRE_TIRECHE_VALVERDE_IRP.pdf`) for the complete bibliography (Bello et al. 2005, H. Carfantan's courses, J-F. Trouilhet's labs).
