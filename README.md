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

Nothing has been bench-tested yet. The design writeup is in [`docs/DESIGN.md`](docs/DESIGN.md).
The whole machine is modelled: the feeder, the funnel and swing arm (up to .338 Lapua Mag), the coil
mount, and the cabinet with its faces and the parts inside it. See [`cad/README.md`](cad/README.md),
which also covers the OpenSCAD nightly requirement, and
[`assembly/assembly.scad`](assembly/assembly.scad) for everything put together. Parts and
fasteners are in [`assembly/BOM.md`](assembly/BOM.md).

[`docs/concept_diagram.svg`](docs/concept_diagram.svg) predates the current feeder design and is
kept only as a sketch of the overall machine.
