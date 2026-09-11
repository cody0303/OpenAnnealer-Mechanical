# CAD — OpenSCAD source

Parametric, text-based CAD for the printed parts. [Install OpenSCAD](https://openscad.org/downloads.html)
(free) to open, render, and export STL from these files — there's no other way to view them.

## Layout

- [`lib/dimensions.scad`](lib/dimensions.scad) — single source of truth for every measurement.
  Every part file includes this instead of hard-coding numbers, so parts that need to fit each
  other (hub ↔ wheel ↔ back plate) are guaranteed to match by construction. **Change a value here,
  not in a part file**, and re-render everything that depends on it.
- [`lib/shapes.scad`](lib/shapes.scad) — small reusable helpers (D-shaft profile, bolt-circle
  placement).
- [`feeder/`](feeder) — the feed subsystem: hopper, singulator wheel, back plate, shroud, drive hub.
  See [`docs/DESIGN.md`](../docs/DESIGN.md) "Hopper + singulator wheel" for how these fit together
  mechanically.

## Currently modeled (feeder subsystem, .223 Rem / 5.56 NATO prototype)

| File | Part | Print material |
|---|---|---|
| [`feeder/drive_hub.scad`](feeder/drive_hub.scad) | Motor-side hub — mounts once on the 5mm D-shaft | PETG/nylon |
| [`feeder/singulator_disk.scad`](feeder/singulator_disk.scad) | Swappable scalloped-rim wheel — one per case-family | PETG/nylon |
| [`feeder/back_plate.scad`](feeder/back_plate.scad) | Stationary plate the case bases ride on, carries the discharge hole | PETG/nylon |
| [`feeder/shroud.scad`](feeder/shroud.scad) | Arc wall holding cases in their scallops; where it ends is the release point | PETG/nylon |
| [`feeder/hopper.scad`](feeder/hopper.scad) | Flat-backed pan, converging sides, non-precision | PLA/PETG |
| [`feeder/feeder_assembly.scad`](feeder/feeder_assembly.scad) | Combined preview of all five, tilted ~45° — **not** something you print or export as one piece; print each part from its own file | — |

Not yet modeled: the holder swing arm, shelf, insert cup, coil mount bracket, and drop chute (the
rest of the column below the feeder) — next after this subsystem is validated on the bench.

## Renders

[`renders/`](renders) has PNG snapshots of each part and the combined stack, rendered headlessly
with `openscad --render` — a quick way to see what these look like without opening OpenSCAD. These
already caught one real bug (an earlier `HUB_OD` was too small and the magnet pockets broke through
the hub's outer wall — fixed in `dimensions.scad`, visible as the difference between print-checked
history and the current renders). Re-render after any geometry change rather than trusting these to
stay current:

```bash
openscad -o renders/drive_hub.png --render --imgsize=900,900 feeder/drive_hub.scad
```

(swap in each part's `.scad` path; `feeder_assembly.scad` is the combined-stack shot).

## How to use these files

1. Open `feeder/feeder_assembly.scad` in OpenSCAD first to see how the pieces relate spatially and
   confirm nothing looks obviously wrong (gaps, overlaps).
2. Open each part file individually (`drive_hub.scad`, `singulator_disk.scad`, `back_plate.scad`,
   `shroud.scad`, `hopper.scad`) to inspect and export it — each file renders just that one part when opened
   directly.
3. **Export STL**: Design → Render (F6), then File → Export → Export as STL.
4. Before printing full-size parts, print small test coupons for the two fits that actually matter
   here (the fits without real tolerance margin baked in):
   - The drive pin / pin socket fit (`DRIVE_PIN_D` vs. its socket in `singulator_disk.scad`)
   - The magnet press-fit pockets (`MAGNET_D` vs. `CLEARANCE_PRESS`) — your printer's actual hole
     shrinkage varies enough that this is worth checking before committing a full disk to it
   Adjust `CLEARANCE_LOOSE` / `CLEARANCE_SNUG` / `CLEARANCE_PRESS` in `dimensions.scad` based on
   what you measure, not by hand-editing the derived diameters in the part files.

## Quick-change disk swap — assembly notes

- The hub's grub screw (`HUB_SETSCREW_D`, M3) is the **only** fastener touched during setup —
  tighten it once against the motor shaft's D-flat and never touch it again for caliber changes.
- 3 drive pins carry the actual rotational torque; 3 magnets hold the disk on axially. Swapping
  disks is meant to be tool-less: pull the old one off against the magnets, press the new one on
  until the pins seat and the magnets click.
- **Magnet polarity**: when gluing magnets into the hub's and each disk's pockets, make sure
  opposing pairs attract (not repel) — check with a second magnet before gluing, since OpenSCAD
  obviously can't encode polarity. Get this wrong on one disk and that one disk won't stay on.
- `MAGNET_D`/`MAGNET_THICKNESS` assume a common small neodymium disc magnet (6×2mm) — confirm
  against whatever you actually source before printing the pockets.

## .223 Rem is the first prototype family, not the only one

`dimensions.scad`'s case-dimension block (`CASE_LENGTH`, `CASE_RIM_D`, etc.) is set for .223 Rem /
5.56 NATO — the reference caliber picked for this first prototype. Only `POCKET_D` (the rim
scallop on the singulator wheel) actually depends on these values; the hub/disk mounting interface is identical
across every case family, so every future family's disk will pop onto the same hub. To add another
family, copy the case-dimension block with that family's real numbers and re-render
`singulator_disk.scad`.

**These are SAAMI reference values, not measurements** — verify against real fired brass with
calipers before committing to a full print, per [`docs/DESIGN.md`](../docs/DESIGN.md)'s existing
caveat on this.
