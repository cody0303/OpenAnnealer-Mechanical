# CAD — OpenSCAD source

Parametric, text-based CAD for the printed parts.

## Requirements

**An OpenSCAD nightly build with `import-function` enabled** (Edit → Preferences → Features →
`import-function`). The [catchnhole](https://github.com/mmalecki/catchnhole) submodule uses
OpenSCAD's JSON `import()`, which the 2021.01 release doesn't have.

This matters because it fails *silently*: on a release build every `bolt()` call degrades to
undefined dimensions and renders as a pinhole with no countersink, while still exporting a
clean-looking, printable part. Check the console for `Ignoring unknown function 'import'`.

Clone with the submodule:

```bash
git submodule update --init --recursive
```

Headless render/export:

```bash
openscad --enable=import-function -o singulator1.stl cad/feeder/singulator1.scad
```

## Layout

- [`feeder/sharedDims.scad`](feeder/sharedDims.scad) — every dimension lives here; the part files
  include it rather than hard-coding numbers, so the hopper, wheel and adapter stay consistent with
  each other. **Change values here, not in a part file.**
- [`feeder/`](feeder) — the feed subsystem.

## Parts

| File | Part | Print material |
|---|---|---|
| [`feeder/hopper.scad`](feeder/hopper.scad) | Flat-backed pan; its boss doubles as the wheel's retaining wall, the base plate the case bases ride on, and the motor mount | PLA/PETG |
| [`feeder/singulator1.scad`](feeder/singulator1.scad) | Wheel with a rim pocket; one per case size, with the size embossed on the face | PETG/nylon |
| [`feeder/shaftAdapter.scad`](feeder/shaftAdapter.scad) | D-bore hub coupling the wheel to the motor shaft | PETG/nylon |

Not yet modelled: the coil mount, case holder and drop chute below the feeder.

## Hardware notes

- **Drive pins** are M3 socket-head bolts threading up through the adapter (head recessed in its
  underside) and protruding to engage the wheel. The bolt cavity is scaled 0.95 so the shank is
  2.85mm — a thread-forming fit in plastic. **M3×20** gives ~11mm of engagement into the wheel;
  M3×16 only gives ~7mm.
- **Set screw** is an M3 through a heat-set insert, aligned with the D-flat.
- **Motor bolts** counterbore into the top of the base plate. The wheel rides on that face, so the
  pocket depth (`3 × countersink`) has to exceed the 3mm head height — currently `countersink=1.33`
  for a 3.99mm pocket.
