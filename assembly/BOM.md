# Bill of Materials — first pass

Status: work in progress. The feeder parts are modelled; everything below the feeder is design
only. Nothing has been bench-tested.

## Printed parts (FDM)

| Part | Material | Qty | Notes |
|---|---|---|---|
| Hopper (pan) | PLA/PETG | 1 | Flat-backed pan; boss doubles as wheel retaining wall, base plate and motor mount — `cad/feeder/hopper.scad` |
| Singulator wheel | PETG/Nylon | 1 per case size | Rim pocket, size embossed on the face — `cad/feeder/singulator1.scad` |
| Shaft adapter | PETG/Nylon | 1 | D-bore hub, couples wheel to motor shaft — `cad/feeder/shaftAdapter.scad` |

Not yet modelled (design only, see `docs/DESIGN.md`):

| Part | Material | Qty | Notes |
|---|---|---|---|
| Drop chute | PETG/Nylon | 1 | Wheel discharge → holder |
| Coil mount bracket | PETG/Nylon | 1 | Vertical slot for height adjustment |
| Swing arm | PETG/Nylon | 1 | Carries adjustment stud |
| Holder shelf | PETG/Nylon | 1 | Slides on adjustment stud |
| Insert cup | PETG/Nylon | 1 per family | Press-fits onto shelf |

## Hardware (fasteners, off-the-shelf)

| Item | Spec | Qty | Notes |
|---|---|---|---|
| Vertical pivot shaft (arm) | steel rod, diameter TBD by servo horn/bearing choice | 1 | |
| Hub set screw | M3 grub screw + heat-set insert | 1 | Bears on the shaft's D-flat — `cad/feeder/shaftAdapter.scad` |
| Drive pins | M3×20 socket head | 2 | Thread into the adapter, protrude ~11mm into the wheel. M3×16 only reaches ~7mm |
| Adjustment stud + thumb nut | threaded rod (e.g. M6), knurled nut | 1 set | Case-length compensation |
| Coil mount screw + slot hardware | M4 or M5 | 2 | Height-adjust clamp |
| Case-holder servo | TowerPro SG90/MG90S or similar | 1 | Per firmware README |
| Motor mounting screws | M3 socket head | 4 | Counterbored into the top of the hopper's base plate |

## Explicitly not yet specified

- Induction coil module (external purchase, out of scope for this repo beyond the mount interface)
- Feeder motor and second/spare motor exact models — see `docs/DESIGN.md` § Second (spare) motor
  mounting; do not lock a bolt pattern to either until chosen
- Bearing (if any) for the pivot shaft vs. plain bushing — deferred to bench testing of arm friction
