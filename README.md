# SpectrumSplice

A spectral audio processor for Norns that manipulates sound in the frequency domain.

## Features

- Real-time FFT analysis/resynthesis
- Spectral freeze
- Pitch shifting in the frequency domain
- Time stretching
- Basic spectral visualization

## Requirements

- norns (210927 or later)
- audio input

## Documentation

### Controls

- E1: Change page
- E2: Select parameter
- E3: Adjust value
- K2: Toggle page
- K3: Toggle freeze (when selected)

### Parameters

#### Input/Output
- **Amplitude**: Overall output level
- **Mix**: Dry/wet balance between processed and input signal
- **Monitor Input**: Toggle monitoring of input signal

#### Spectral
- **Freeze**: Captures and holds the current spectral content
- **Pitch Shift**: Shifts frequency content up or down
- **Stretch**: Stretches or compresses the frequency spectrum

## Development

This is an early prototype. Planned features include:
- Multi-band processing
- Buffer recording and slicing
- Pattern sequencing
- Grid integration
- Modulation system

## License

MIT
