# Bill of Materials — first pass

Status: concept-stage estimate to size the design, not a purchasing list. Quantities assume the
four-family swappable-insert scheme in [`docs/DESIGN.md`](../docs/DESIGN.md); anything marked
"per family" needs one unit per case-family you actually intend to run.

## Printed parts (FDM)

| Part | Material | Qty | Notes |
|---|---|---|---|
| Base plate | PLA/PETG | 1 | Mounts feeder assembly, electronics enclosure |
| Hopper (pan) | PLA/PETG | 1 | Flat-backed, converging sides, leans ~45° — `cad/feeder/hopper.scad` |
| Drive hub | PETG/Nylon | 1 | Fixed to feeder motor shaft — `cad/feeder/drive_hub.scad` |
| Singulator wheel | PETG/Nylon | 1 per family | Scalloped rim; quick-change onto drive hub — `cad/feeder/singulator_disk.scad` |
| Back plate | PETG/Nylon | 1 | Case bases ride on it; carries the discharge hole — `cad/feeder/back_plate.scad` |
| Shroud | PETG/Nylon | 1 | Retains cases in their scallops to the release point — `cad/feeder/shroud.scad` |
| Drop chute | PETG/Nylon | 1 | Disk discharge → holder |
| Coil mount bracket | PETG/Nylon | 1 | Vertical slot for height adjustment |
| Swing arm | PETG/Nylon | 1 | Carries adjustment stud |
| Holder shelf | PETG/Nylon | 1 | Slides on adjustment stud |
| Insert cup | PETG/Nylon | 1 per family | Press-fits onto shelf |
| Motor adapter plate | PLA/PETG | 1 per motor once chosen | Absorbs NEMA bolt-pattern differences |

## Hardware (fasteners, off-the-shelf)

| Item | Spec | Qty | Notes |
|---|---|---|---|
| Vertical pivot shaft (arm) | steel rod, diameter TBD by servo horn/bearing choice | 1 | |
| Hub set screw | M3 grub screw | 1 | Set once against motor shaft flat; never touched again per caliber swap |
| Quick-change magnets | 6×2mm neodymium disc | 3 per hub + 3 per disk | Press-fit into `drive_hub.scad`/`singulator_disk.scad` pockets — check polarity before gluing |
| Adjustment stud + thumb nut | threaded rod (e.g. M6), knurled nut | 1 set | Case-length compensation |
| Coil mount screw + slot hardware | M4 or M5 | 2 | Height-adjust clamp |
| Back plate mounting screws | M3 | 3 | Into housing standoffs — `cad/feeder/back_plate.scad` |
| Case-holder servo | TowerPro SG90/MG90S or similar | 1 | Per firmware README |
| Motor mounting screws | TBD once motor(s) chosen | — | Goes through adapter plate, not structural part |

## Explicitly not yet specified

- Induction coil module (external purchase, out of scope for this repo beyond the mount interface)
- Feeder motor and second/spare motor exact models — see `docs/DESIGN.md` § Second (spare) motor
  mounting; do not lock a bolt pattern to either until chosen
- Bearing (if any) for the pivot shaft vs. plain bushing — deferred to bench testing of arm friction
