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
openscad --enable=import-function -o singulator.stl cad/feeder/singulator.scad
```

## Layout

- [`sharedDims.scad`](sharedDims.scad) — the dimensions parts share (hardware, stack spacings,
  the cabinet wall); the part files include it rather than hard-coding numbers.
  **Change shared values here, not in a part file.**
- [`feeder/layout.scad`](feeder/layout.scad) — where the feeder stack sits, derived from
  sharedDims; the left panel drills its holes from it.
- [`cabinet/boxLayout.scad`](cabinet/boxLayout.scad) — the cabinet box, what's inside it, and
  every face's cut-outs. Front is the screen end, back is where the USB ports come out, left is the
  panel the feeder mounts on, right is the wall with the IEC inlet.
- [`feeder/`](feeder) — the feed subsystem, outside the cabinet.
- [`cabinet/`](cabinet) — printed parts inside the cabinet, plus `flatPanel.scad` (the flat-face
  helpers) and `boxLayout.scad`, which aren't parts.
- [`cabinetFlat/`](cabinetFlat) — the cabinet's six faces. The release also exports each one as a
  DXF for cutting (`tools/export_panel_dxf.py`), so nothing but faces belongs here. Faces taller
  than the bed (the ones with a `panelTile` setting) come out of the release as one STL per
  printing tile, `name-upper.stl` and `name-lower.stl`.
- [`../assembly/assembly.scad`](../assembly/assembly.scad) — the whole machine, view only, with
  clash checks. [`../assembly/BOM.md`](../assembly/BOM.md) lists parts and fasteners.

## Parts

| File | Part | Print material |
|---|---|---|
| [`feeder/hopper.scad`](feeder/hopper.scad) | Flat-backed pan; its boss doubles as the wheel's retaining wall, the base plate the case bases ride on, and the motor mount | PLA/PETG |
| [`feeder/singulator.scad`](feeder/singulator.scad) | Wheel with a rim pocket; one per case family, with the size embossed on the face | PETG/nylon |
| [`feeder/shaftAdapter.scad`](feeder/shaftAdapter.scad) | D-bore hub coupling the wheel to the motor shaft | PETG/nylon |
| [`feeder/funnel.scad`](feeder/funnel.scad) | Takes the case from the wheel down into the coil | PETG |
| [`feeder/hornMount.scad`](feeder/hornMount.scad) | Swing arm keyed to the servo's stock horn; carries the M5 thumbscrew the case stands on | PETG/nylon |
| [`cabinet/servoMount.scad`](cabinet/servoMount.scad) | Holds the MG90S inside the left panel | PETG |
| [`cabinet/heatsinkHolder.scad`](cabinet/heatsinkHolder.scad) | Holds the coil's two heatsinks; shares the funnel's upper bolt | PETG |
| [`cabinet/screenTilt.scad`](cabinet/screenTilt.scad) | Tilted screen and knob housing, front wall | PETG |
| [`cabinet/transformerCradle.scad`](cabinet/transformerCradle.scad) | Bridge holding the transformer over the driver board | PETG |
| [`cabinet/fanAdapter.scad`](cabinet/fanAdapter.scad) | 40 mm fan duct, low on the front wall, angled down the driver's heatsink | PETG |
| [`cabinet/cornerBlock.scad`](cabinet/cornerBlock.scad) | Corner block the faces screw into (12 off) | PETG |
| [`cabinetFlat/`](cabinetFlat) | Left panel (`sidePanel`), front, back and right walls, lid and base: 6 mm, printed as tiles or cut from ply | PETG / ply |

## Hardware notes

- **Drive pins** are M3 socket-head bolts threading up through the adapter (head recessed in its
  underside) and protruding to engage the wheel. The bolt cavity is scaled 0.95 so the shank is
  2.85mm — a thread-forming fit in plastic. **M3×20** gives ~11mm of engagement into the wheel;
  M3×16 only gives ~7mm.
- **Set screw** is an M3 through a heat-set insert, aligned with the D-flat.
- **Motor bolts** counterbore into the top of the base plate. The wheel rides on that face, so the
  pocket depth (`3 × countersink`) has to exceed the 3mm head height — currently `countersink=1.33`
  for a 3.99mm pocket.
