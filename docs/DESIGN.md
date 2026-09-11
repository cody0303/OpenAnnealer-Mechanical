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

1. **Hopper** — a wide V-trough, loosely filled with loose cases in bulk (no hand-orienting; they
   settle roughly base-down against the trough walls).
2. **Singulator disk** — a single-pocket disk, tilted ~45° at the hopper's throat and driven by the
   feeder stepper, catches one case at a time (rim-first, into a through-hole) as it rotates under
   the jumbled pile, rides on a stationary face plate until its pocket reaches a discharge cutout,
   then drops the case down a short chute into the holder below.
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

### Hopper + singulator disk

This is modeled directly on a real reference (ARC Precision's ARC Ultimate annealer): a wide
V-trough hopper feeds a rotating, tilted pocket disk that both singulates and reorients cases in
one mechanism.

- **Hopper**: a wide V-trough mounted at roughly 45° from vertical. Cases are dumped in as a loose
  batch — no hand-orienting. Because a case's flat, relatively heavy base makes it the natural
  "downhill" end, cases in the trough settle roughly base-down against the V on their own; the
  trough doesn't need to precisely orient every case, just bias most of them the right way often
  enough for the disk to pick up cleanly.
- **Singulator disk**: a flat disk with a **single through-hole pocket**, mounted on a shaft tilted
  with the hopper (~45°) and driven by the existing feeder stepper (`SELECT_FEEDER_MOTOR`). As it
  rotates under the jumbled pile, a case that happens to be positioned base-first over the pocket
  drops in, rim catching the hole's edge (the same principle as a shellholder — hole ID between
  case body OD and rim/head OD). Cases that aren't captured just ride along the disk surface and
  fall back into the hopper — no separate reject mechanism needed, this rejects itself.
- **Stationary face plate**: sits directly behind the disk (same tilt), supporting a captured case
  from below/behind as the disk carries it around — otherwise it would just fall straight through
  the pocket immediately. The face plate has one **discharge cutout**; when the pocket's rotation
  brings it over that cutout, the case is no longer supported and drops down the chute below into
  the holder.
- **Open-loop timing**: the firmware only needs to run the disk long enough to guarantee the pocket
  passes both the hopper zone and the discharge cutout at least once
  (`feed_run_time_ms`/`feed_speed_rps` in `profile.c`) — no feed-confirmation sensor needed, matching
  the brief. One real caveat worth flagging: because pickup is a matter of chance (a case has to
  happen to be sitting over the pocket when it passes under the pile), a single-pocket disk won't
  guarantee a catch on every single rotation the way a fully-constrained mechanism would — expect
  an occasional feed cycle that comes up empty, on top of the case-missing-the-holder risk the
  brief already calls out as unaddressed by sensing.
- **Case-family handling**: the disk is a **swappable part per case-family** (pocket ID/depth sized
  to that family's head diameter), keyed onto the motor shaft (D-shaft or grub-screw, matching the
  feeder motor's actual shaft) — same four-family grouping as the holder inserts below. ARC's real
  unit uses one disk with multiple pocket sizes around its rim instead; that's a viable upgrade path
  later, but a swappable single-pocket disk is a simpler first part to get right in FDM.
- This subsystem is explicitly the least mature part of this design — the brief calls the feed
  mechanism "not yet designed," and pickup reliability (hopper angle, disk tilt, pocket depth) is
  exactly the kind of thing that needs bench iteration against real cases, not more drawing.

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

- **Near the coil** (holder shelf, insert cups, singulator disk, face plate, coil mount bracket,
  drop chute): use **PETG or nylon**, not PLA/ABS. These parts sit closest to a part that gets hot
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

1. Get real case samples across the intended range (at minimum one from each family above) and
   check them against the family boundaries in the table — this gates the disk-pocket and insert
   sizes.
2. Purchase the induction coil; re-check the ≥25 mm clear-bore target and recompute the arm's
   minimum swing angle (formula above) against its actual OD.
3. Decide the feeder motor (and, if different, the second motor) before modeling any motor mount
   as more than the generic envelope described above.
4. Print a single-family prototype (recommend starting with the Large family — .308-class — since
   it's the most common bench case) of the singulator disk + face plate + holder shelf + insert cup,
   and bench test hopper pickup reliability and the feed/hold/drop sequence before committing to
   CAD for the other three families. Pickup reliability (hopper angle, disk tilt, pocket depth) is
   the part most likely to need several iterations — plan for that rather than expecting the first
   print to work.
