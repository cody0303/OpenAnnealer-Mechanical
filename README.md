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
- [`cad/`](cad) — source CAD models (OpenSCAD — see [`cad/README.md`](cad/README.md))
- [`stl/`](stl) — print-ready STL exports
- [`assembly/`](assembly) — bill of materials, assembly notes

## Status

Nothing has been printed or bench-tested yet. The design writeup is in
[`docs/DESIGN.md`](docs/DESIGN.md). CAD exists for the feed subsystem — hopper, singulator wheel
and shaft adapter, sized for .223 Rem / 5.56 NATO — in [`cad/feeder/`](cad/feeder); see
[`cad/README.md`](cad/README.md), which also covers the OpenSCAD nightly requirement. The holder
arm, coil mount and everything downstream of the feeder isn't modelled yet.

[`docs/concept_diagram.svg`](docs/concept_diagram.svg) predates the current feeder design and is
kept only as a sketch of the overall machine.
