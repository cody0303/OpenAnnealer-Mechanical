# OpenAnnealer — Mechanical

Mechanical design and assembly for [OpenAnnealer](https://github.com/cody0303/OpenAnnealer), an
automated induction annealer for cartridge cases. This repo covers the physical side only — case
feed, holder, coil mounting, and enclosure. Firmware/electronics live in the main
[OpenAnnealer](https://github.com/cody0303/OpenAnnealer) repo; this split mirrors the upstream
[OpenTrickler](https://github.com/eamars/OpenTrickler) project this fork is based on.

**Status: concept stage.** Design rationale, open assumptions, and next steps are in
[`docs/DESIGN.md`](docs/DESIGN.md) — read that before the CAD, since several parts here are
deliberately placeholders (no induction coil purchased yet, no motor locked in for the spare feed
motor) pending real hardware.

## Layout

- [`docs/`](docs) — design writeup, concept diagrams, photos as the build progresses
- [`cad/`](cad) — source CAD models
- [`stl/`](stl) — print-ready STL exports
- [`assembly/`](assembly) — bill of materials, assembly notes

## Status

Nothing has been printed or bench-tested yet — this repo currently holds the first-pass concept
design in [`docs/DESIGN.md`](docs/DESIGN.md) and a labeled concept diagram
([`docs/concept_diagram.svg`](docs/concept_diagram.svg)). CAD models and STLs will follow as the
design gets validated against real cases and a real coil.
