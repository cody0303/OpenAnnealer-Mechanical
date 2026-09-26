# Bill of Materials

Status: work in progress. Everything below is modelled and checked in `assembly/assembly.scad`;
nothing has been bench-tested. Screw lengths assume 6 mm cabinet faces (`cabinetWallThk` in
`cad/sharedDims.scad`) — re-check them if that changes.

## Printed parts (FDM)

| Part | Material | Qty | Notes |
|---|---|---|---|
| Hopper (pan) | PLA/PETG | 1 | Boss doubles as wheel retaining wall, base plate and motor mount — `cad/feeder/hopper.scad` |
| Singulator wheel | PETG/Nylon | 1 per case family | Rim pocket, size embossed on the face — `cad/feeder/singulator.scad` |
| Shaft adapter | PETG/Nylon | 1 | D-bore hub, couples wheel to motor shaft — `cad/feeder/shaftAdapter.scad` |
| Funnel | PETG | 1 | Wheel discharge down into the coil — `cad/feeder/funnel.scad` |
| Horn mount | PETG/Nylon | 1 | Keys to the servo's stock horn; carries the thumbscrew — `cad/feeder/hornMount.scad` |
| Servo mount | PETG | 1 | MG90S hangs in it on its ears — `cad/cabinet/servoMount.scad` |
| Heatsink holder | PETG | 1 | Holds the two coil heatsinks — `cad/cabinet/heatsinkHolder.scad` |
| Screen housing | PETG | 1 | Tilted screen and knob, front wall — `cad/cabinet/screenTilt.scad` |
| Transformer cradle | PETG | 1 | Bridge over the driver board — `cad/cabinet/transformerCradle.scad` |
| Fan duct | PETG | 1 | 40 mm fan, low on the front wall, angled down the driver heatsink — `cad/cabinet/fanAdapter.scad` |
| Corner block | PETG | 12 | Four vertical corners × base, seam and lid — `cad/cabinet/cornerBlock.scad` |

## Cabinet faces

6 mm, either printed or cut from plywood from the DXF (`tools/export_panel_dxf.py`, or the release
artifacts). The front, back, left and right walls are taller than the 200 mm bed; printed, each is
two tiles joined by a half-lap, glued and bolted.

| Face | File | Notes |
|---|---|---|
| Left panel | `cad/cabinetFlat/sidePanel.scad` | The feeder stack, heatsink holder, servo mount and Pico board bolt to it |
| Front wall | `cad/cabinetFlat/frontWall.scad` | Screen housing, fan intake grille |
| Back wall | `cad/cabinetFlat/backWall.scad` | Pico board's USB-C ports |
| Right wall | `cad/cabinetFlat/rightWall.scad` | Exhaust vents, IEC inlet (cut-out is a placeholder) |
| Lid | `cad/cabinetFlat/lid.scad` | Nothing mounted to it, for servicing |
| Base | `cad/cabinetFlat/base.scad` | Transformer cradle screws up into it |

Each wall file has `feederSide`; a right-hand build exports its faces with `"right"`.

## Fasteners

| Item | Spec | Qty | Where |
|---|---|---|---|
| M5 bolt | M5×20 button head | 6 | Through the left panel into captive nuts: hopper 2, servo mount 2, funnel lower 1, heatsink holder bottom 1 |
| M5 bolt | M5×25 button head | 1 | Through the left panel, the heatsink holder and into the funnel's upper nut |
| M5 nut | hex | 7 | Captive in the hopper, servo mount, funnel and heatsink holder |
| Thumbscrew | M5, ~50 long, + 2 jam nuts | 1 | Case stop in the horn mount; shorter cases ride up it |
| M3 screw | M3×10 button head | 32 | Through the faces into the corner blocks |
| M3 heat-set insert | `m3InsertD` × `m3InsertDepth` | 36 | Corner blocks, 3 each (the seam blocks' third one is unused) |
| M3 bolt + nut + washer | M3×10 button head | 7 | Tile half-lap bolts, nut inside (left 1, front 2, back 2, right 2) |
| M3 screw | M3×10 | 4 | Front wall into the screen housing's ear inserts |
| M3 heat-set insert | | 4 | Screen housing ears |
| M3 self-tapper | ~M3×6 | 4 | Screen board onto the housing's standoffs |
| M3 screw + washer | M3×10 | 4 | Up through the base's slots into the cradle's feet; the washers bridge the slots |
| M3 heat-set insert | | 4 | Transformer cradle feet |
| Zip tie | ≤5 mm wide | 2 | Over the transformer, through the cradle |
| M3 screw | M3×10 | 4 | Front wall into the fan duct's inlet inserts |
| M3 screw | M3×25 | 4 | Through the fan into the duct's seat inserts |
| M3 heat-set insert | | 8 | Fan duct: 4 in the inlet face, 4 in the seat |
| M3 standoff | M3×10 female–female | 4 | Pico motor board off the left panel |
| M3 screw | M3×10 / M3×6 | 4 / 4 | Standoffs: through the panel / through the board |
| M4 heat-set insert | `m4InsertD` × `m4InsertDepth` | 2 | Heatsink holder, one each side |
| M4 screw | length to suit the heatsinks | 2 | Heatsinks onto the holder |
| Motor screw | M3 socket head | 4 | Counterbored into the top of the hopper's base plate |
| Drive pin | M3×20 socket head | 2 | Thread into the shaft adapter, protrude ~11 mm into the wheel. M3×16 only reaches ~7 mm |
| Hub set screw | M3 grub + heat-set insert | 1 | Bears on the shaft's D-flat |
| Horn screws | the servo's own small self-tappers | 2+ | Horn into the horn mount |

## Other hardware

| Item | Qty | Notes |
|---|---|---|
| Grommet, for an 11 mm hole | 2 | Coil leads through the left panel |
| Edge trim (optional) | ~60 mm | The 18 × 8 stepper cable slot in the left panel |
| 40 × 20 mm fan | 1 | 32 mm hole pitch |
| NEMA 17 stepper | 1 | Feeder wheel |
| MG90S servo | 1 | Swing arm |
| Pico motor expansion board + Pico 2 W | 1 | eamars/RaspberryPi-Pico-Motor-Expansion-Board |
| IEC inlet with switch | 1 | Model TBD; the right wall's cut-out is a placeholder |
| Double-sided mounting tape | — | Driver board and relay |

The coil, its heatsinks, the transformer and the driver board are harvested from an induction
heater; confirm their sizes against `cad/cabinet/boxLayout.scad`.
