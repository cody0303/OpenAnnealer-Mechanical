# OpenAnnealer — Mechanical Design

Status: **concept / first pass, not yet bench-verified.** This document responds to the mechanical
design brief handed off from the firmware side of the project (see
[OpenAnnealer](https://github.com/cody0303/OpenAnnealer)). It proposes one coherent, buildable
concept for every open mechanical question in that brief, flags every assumption that still needs
a real part or a real case in hand to confirm, and leaves the things that are genuinely still open
as open. Diagram: [`concept_diagram.svg`](concept_diagram.svg).

## Assumptions and open items (read this first)

These are the load-bearing assumptions behind everything below. If any of them are wrong, the
affected subsystem needs rework before it's worth modeling in CAD:

| # | Assumption | Why it matters | Confirmed? |
|---|---|---|---|
| 1 | Case range to support: pistol through magnum, roughly 0.75"–2.85" (19–72 mm) case length | Drives hopper/disk and holder-insert sizing | No — working range, not measured against real cases yet |
| 2 | Induction coil not yet purchased | Coil bore ID and winding height set the minimum clearance the holder column and cook-zone height must fit inside | No — mount is designed adjustable/oversized until a real coil is on hand |
| 3 | Feeder motor and the second ("spare") motor's frame size (NEMA form factor) | Determines mounting bolt patterns | **Not locked** — see [Second (spare) motor mounting](#second-spare-motor-mounting) below; do not cut a fixed bolt pattern for either motor into a structural part |
| 4 | Fabrication: FDM 3D printing for all custom parts | Drives wall thickness, tolerance, and material choices below | Confirmed by you |
| 5 | New enclosure/base, no chassis carryover from OpenTrickler | Frees up the layout | Confirmed by you |

Everything downstream of #1–#3 is written to be **adjustable or swappable**, specifically so that
getting one of these assumptions wrong later costs a reprinted insert, not a redesign.

## Kinematic concept

One column, top to bottom (see diagram):

1. **Hopper** — a flat-backed pan leaning ~45°, loosely filled with cases in bulk (no
   hand-orienting). They stand base-down on its base plate and slide toward the bottom outlet.
2. **Singulator wheel** — a scalloped-rim wheel driven by the feeder stepper, its rim sitting in
   the outlet so its cylindrical side is the floor under the pile. It rotates under
   the outlet, takes one case off the bottom of the pile into a rim scallop, and — held in by a
   shroud, its base sliding on the back plate — carries it round to the discharge, where it drops
   down a short chute into the holder below.
3. **Coil zone** — the case's neck/shoulder ("cook zone") sits inside the induction coil, supported
   from below by a shelf mounted on the swing arm.
4. **Swing arm** — rotates about a vertical pivot, in the horizontal plane, between two servo-
   commanded positions:
   - **HOLD** — shelf positioned directly under the coil bore, case supported.
   - **DROP** — shelf swung just far enough to clear the coil body; case is no longer supported and
     falls straight down.
5. **Drop point** — no funnel or catch tray in this design; the case falls straight down into
   whatever catch area you provide below (sized separately, per your call).

This matches the firmware's model exactly: the servo only ever commands two fixed ratios
(`HOLDER_RATIO_HOLD` / `HOLDER_RATIO_DROP`, see
[`servo_gate.h`](https://github.com/cody0303/OpenAnnealer/blob/main/src/servo_gate.h)) and never
receives a per-case-length or per-caliber value. All length/diameter compensation has to live in
the mechanism, set by hand before a run — which is exactly what the brief specifies ("a simple
swing arm with an adjustment nut... a manual, physical setting, not something the firmware
commands per case").

## Subsystem designs

### Case holder (swing arm)

- A single arm rotates on a vertical pivot shaft, driven by the case-holder servo, between two
  commanded positions (HOLD/DROP). **No mechanical hard-stop hardware is included** — the RC servo
  is inherently position-controlled (it always drives to whichever duty cycle it's told), so the
  servo itself is the repeatable element, exactly as `servo_gate.c` implements it
  (`close_duty_cycle`/`open_duty_cycle`, two fixed values). A physical stop can be retrofitted later
  if bench testing turns up slop under load, but nothing is designed in preemptively.
- The sweep only needs to be large enough for the shelf/case to clear the coil body, not a fixed
  90°+ arc. For an arm of radius `r` (pivot to case centerline) and a coil of outer radius `R`
  (measured from the HOLD centerline, i.e. from the case's position), the chord the case travels at
  swing angle `θ` is `2r·sin(θ/2)`; solving for the angle that just clears the coil plus a small
  margin `m`: `θ_min = 2·asin((R + m) / (2r))`. E.g. at `r` = 50 mm and `R` = 25 mm coil radius with
  a 5 mm margin, `θ_min ≈ 35°` — nowhere near 90°. Longer arms need even less angle for the same
  coil. **Finalize this once a real coil OD and arm radius are chosen**; the diagram shows a small
  sweep as the working assumption instead of the earlier 90–100° figure.
- At the working end of the arm, a **vertical stud** carries a shelf/cup that slides up or down the
  stud and locks with a **thumb nut** — this is the "adjustment nut" from the brief. Raising or
  lowering the shelf changes how far a case sits down into the guide column, which is what lines
  up the case's neck/shoulder with the coil regardless of overall case length. This setting is
  physical and manual, touched once per case type, never per-cycle.
- The shelf top is a **swappable insert cup**, not a single universal pocket. Rim and extractor-
  groove diameters cluster into a handful of families rather than varying smoothly (this is why
  press shellholders come in a fixed set of groups, not one universal size) — a single hole sized
  for a .338 Lapua rim would let a 9mm case rock or tip, and a hole sized for 9mm won't accept a
  magnum rim at all. Four printed insert cups covering the ranges in the table below is a small,
  cheap part count for a large gain in reliability at both ends of the range. Insert retention:
  press-fit shoulder into a shallow recess on the shelf, sized for a firm hand-press fit in PETG
  (no fasteners needed — it's a tool-less swap between range sessions).

### Hopper + singulator wheel

Modeled on a real reference (ARC Precision / ADG's ARC Ultimate annealer): a leaning, flat-backed
hopper pan feeds a scalloped-rim wheel that singulates cases off the bottom of the pile. **CAD**:
[`cad/feeder/`](../cad/feeder) (OpenSCAD, sized for a .223 Rem/5.56 NATO first prototype) — see
[`cad/README.md`](../cad/README.md) before printing.

- **Hopper**: a flat-backed pan, leaning back at roughly 45°, open at the top for loading and at
  the bottom where it feeds the wheel. Cases are dumped in loose (no hand-orienting) and stand
  base-down on the pan's base plate, sticking out of its open front; the walls constrain them
  laterally near their bases. The lean makes the pile slide down the base plate, and the pan's
  lower sides — converging at a `feedAngle` of 30° — funnel it into the bottom outlet.
- **The wheel's rim sits in that outlet, and its cylindrical *side* is the floor the bottom of the
  pile rests on.** This is the detail that makes the whole mechanism work, and it's easy to get
  wrong: the cases do not stand on the wheel's *face*, and the capture feature is not a hole
  through the face. They rest against the wheel's tread, and the pockets are scallops in its edge.
- **Singulator wheel**: driven by the existing feeder stepper (`SELECT_FEEDER_MOTOR`), with
  **half-round scallops cut into its rim**. Cases lie parallel to the wheel's axis, so a case and a
  scallop are two parallel cylinders — the case nests into the notch exactly. A scallop coming round
  under the outlet takes one case off the bottom of the pile; the rest of the pile just keeps
  resting on the smooth tread, so the mechanism rejects surplus cases by itself with no separate
  mechanism.
- **Tread width** (the wheel's thickness) sets how much of a case's length is cradled. The case
  overhangs it considerably — 20mm of tread under a 44.7mm case — so the hopper walls and back
  plate do the rest of the work of keeping it from skewing. Widening the tread is the first thing to
  try if cases cock or jam.
- **Back plate**: the hopper's floor continued underneath the wheel. It's what the case *base* rides
  on — so the plate does the axial job and the rim scallop does the lateral one. A case carried
  round keeps its base sliding on this plate until it reaches the plate's discharge hole.
- **Shroud**: an arc wall following the rim at a small clearance, from just past the outlet round to
  the discharge. Without it a captured case would simply roll back out of its scallop as the wheel
  turned away from the pile. **Where the shroud ends is the release point** — the case is no longer
  held, and drops through the discharge hole into the chute.
- **Open-loop timing**: the firmware only needs to run the wheel long enough to guarantee a scallop
  passes both the hopper outlet and the discharge at least once
  (`feed_run_time_ms`/`feed_speed_rps` in `profile.c`) — no feed-confirmation sensor needed, matching
  the brief. One real caveat worth flagging: pickup still isn't guaranteed — a case has to actually
  settle into a scallop as it passes under the pile, and a near-empty hopper or a bridged pile can
  let a scallop go by empty. Expect the occasional feed cycle that delivers nothing, on top of the
  case-missing-the-holder risk the brief already calls out as unaddressed by sensing. More scallops
  round the rim (`POCKET_COUNT`) buys margin here, since a cycle then gets several chances.
- **Case-family handling**: the disk is a **swappable part per case-family** (pocket diameter sized
  to that family's rim/head diameter) — same four-family grouping as the holder inserts below. It
  mounts on a quick-change hub rather than being keyed directly to the motor shaft: the hub's grub
  screw is set once against the shaft during initial motor install and never touched again; the
  disk itself pops on/off tool-lessly via 3 drive pins (torque) and 3 embedded magnets (axial
  retention) — swapping calibers doesn't mean fighting a grub screw each time. See
  [`cad/feeder/drive_hub.scad`](../cad/feeder/drive_hub.scad) and
  [`cad/feeder/singulator_disk.scad`](../cad/feeder/singulator_disk.scad).
- This subsystem is explicitly the least mature part of this design — the brief calls the feed
  mechanism "not yet designed," and pickup reliability (hopper lean, scallop count and depth, tread
  width) is exactly the kind of thing that needs bench iteration against real cases, not more
  drawing.

### Coil mount

- Since no coil is bought yet, the mount is deliberately **not** built around specific coil
  dimensions. It's a bracket with a **vertical slot** on at least one side, so coil height is
  field-adjustable with a single screw once a real coil arrives — this sets which part of the case
  ends up in the strongest field region without redesigning anything.
- Minimum bore clearance to design toward: the holder column's largest liner OD plus wall
  thickness plus a few mm working clearance — call it **≥25 mm clear ID** through the coil as a
  starting target. **This number must be checked against the actual coil once purchased** before
  finalizing the guide-column OD; it's the one dimension in this document most likely to force a
  revision.

### Drop point

- No funnel or catch tray in this design — the case falls straight down from the DROP position.
  Catch-area sizing/placement is on you; this repo only needs to keep the drop point's location
  (position under the coil, height above your bench/tray) documented once the frame is built, so a
  catch area can be sized against it.

### Second (spare) motor mounting

The firmware brief describes this as hardware-present-but-unused, reserved for a future
feed-path function, "no mechanical role assigned yet." Since you're not locked to a specific motor
for either the feeder or this spare position, **no structural part in this design commits to a
fixed motor bolt pattern.** Concretely:

- Reserve a flat, unobstructed mounting **envelope** near the hopper/singulator (roughly
  50×50 mm clear area plus shaft clearance) rather than drilling a bolt circle now.
- When a motor is actually chosen for this position (and, if it turns out to differ from what's
  currently on the feeder, for that one too), the mounting bolt pattern goes on a small
  **printed adapter plate** — a single reprintable part between the motor and the frame — instead
  of being cut into the main structure. NEMA 14 and NEMA 17 motors use different bolt spacing
  (26 mm vs. 31 mm square, respectively); an adapter plate absorbs that difference for the cost of
  one reprint instead of a structural rework.
- No specific future function (hopper advance, multi-case carousel, etc.) is assumed here — the
  brief is explicit that none has been designed yet, and committing this document to one would be
  guessing.

### Frame / base

- New enclosure, no chassis carryover. Hopper + singulator disk → coil → holder → open drop point,
  mounted to a flat base plate; electronics enclosure (LCD/encoder module, control board) mounts
  wherever is convenient on or beside the base — no mechanical constraint from that side beyond
  enclosure volume, per the brief.

## Case-family reference groups (working assumption)

Used to size the swappable disks and holder inserts above. These are standard published SAAMI
case dimensions, not measurements — **verify against your actual cases before cutting the first
insert**, especially at the top end (this document assumes "magnum" tops out around .338 Lapua
Magnum-class, not the largest belted or beltless magnums that exist):

| Family | Example calibers | Case length range | Rim/groove Ø range |
|---|---|---|---|
| Small (pistol/small rifle) | 9mm Luger, .380 ACP, .223/5.56 | ~17–45 mm | ~9.5–9.7 mm |
| Medium | .45 ACP, .30-30, .243 Win | ~23–52 mm | ~11.2–12.0 mm |
| Large | .308 Win, .30-06, .270 Win | ~51–64 mm | ~12.0 mm |
| Magnum | .300 Win Mag, .338 Lapua Mag | ~64–72 mm | ~12.0–14.9 mm (belted magnums: belt Ø ~13.0 mm) |

If real use turns out to need calibers past .338 Lapua Magnum (e.g. .50 BMG-class), that's a fifth
family and a larger coil, not a change to this structure.

## Servo torque sanity check

Brief specifies a TowerPro SG90/MG90S-class servo (per the firmware README). Worst case load is
the heaviest case + insert cup, at the arm's working radius:

- Heaviest case (empty .338 Lapua Mag brass): ~26 g
- Insert cup + shelf hardware: ~15 g estimated
- Arm radius to load: ~50 mm (0.05 m)

Static torque required: `(0.026 + 0.015) kg × 9.81 m/s² × 0.05 m ≈ 0.020 N·m ≈ 0.21 kgf·cm`

MG90S rated stall torque is ~2.2 kgf·cm (4.8 V) / SG90 ~1.6 kgf·cm — roughly **8–10× margin** even
at the heaviest end of the range, before accounting for the servo's own gear-hold. No torque
concern with the specified servo; this isn't a constraint on arm length or insert weight within
any sane design.

## Materials and fabrication (FDM)

- **Near the coil** (holder shelf, insert cups, coil mount bracket, drop chute): use **PETG or nylon**, not PLA/ABS. These parts sit closest to a part that gets hot
  and radiates during dwell; PLA softens around 60°C and ABS around 100°C, both low enough to be a
  real concern this close to an induction-heated case. PETG (~80°C HDT) is the practical minimum;
  nylon is better if you see any softening in testing.
- **Away from the coil** (base plate, hopper, motor mounts): PLA or PETG is fine — no thermal
  exposure to plan around.
- Standard FDM tolerances (±0.2 mm) are fine everywhere except the insert-cup-to-shelf press fit —
  plan a test coupon for that before printing full-size parts, since press-fit tolerance is
  printer- and material-dependent.

## Bill of materials (mechanical, first pass)

See [`assembly/BOM.md`](../assembly/BOM.md).

## Next steps requiring physical hardware (not deferrable to more writing)

1. **In progress**: [`cad/feeder/`](../cad/feeder) has a first-pass hopper + singulator disk + face
   plate + drive hub, sized for a .223 Rem/5.56 NATO prototype off SAAMI reference dimensions —
   verify those against real fired brass with calipers before printing full-size parts (`cad/`
   README has the two fits worth test-coupon-ing first: the drive pin fit and the magnet press-fit).
2. Print that first prototype and bench test hopper pickup reliability and singulation before
   committing to CAD for the other three case families (Small/Medium/Magnum) or for the holder
   assembly below it. Pickup reliability (hopper angle, disk tilt, pocket depth) is the part most
   likely to need several iterations — plan for that rather than expecting the first print to work.
3. Purchase the induction coil; re-check the ≥25 mm clear-bore target and recompute the arm's
   minimum swing angle (formula above) against its actual OD.
4. Decide the feeder motor (and, if different, the second motor) before modeling any motor mount
   as more than the generic envelope described above — also confirms the feeder motor's actual
   shaft diameter/flat depth against `DSHAFT_D`/`DSHAFT_FLAT_DEPTH` in `cad/lib/dimensions.scad`.
5. Model the holder swing arm, shelf, insert cup, coil mount bracket, and drop chute — not started
   yet; the feeder subsystem above was the starting point.
