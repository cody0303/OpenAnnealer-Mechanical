// Shared dimensions for the OpenAnnealer feeder subsystem (hopper + singulator
// wheel + back plate + drive hub). Single source of truth: every part file
// includes this instead of hard-coding numbers, so the hub/disk/face-plate
// interface is guaranteed to fit by construction. Change a value here and
// re-render everything rather than hand-editing a derived number downstream.
//
// All dimensions in mm.

$fn = 64;

// ---------------------------------------------------------------------------
// Case family: .223 Remington / 5.56x45 NATO (fired brass, no bullet)
//
// SAAMI reference values -- these are nominal/max published dimensions, NOT
// measurements off real brass. Verify with calipers before cutting the first
// print. See docs/DESIGN.md "Case-family reference groups" for the other
// family groups this will eventually need.
// ---------------------------------------------------------------------------
CASE_LENGTH = 44.70;  // max case length (SAAMI)
CASE_RIM_D  = 9.60;   // rim/head diameter (max) -- the feature the disk pocket clears
CASE_RIM_T  = 1.15;   // rim thickness (reference only, not used in the fits below)
CASE_BODY_D = 9.50;   // body diameter just ahead of the extractor groove (reference only)

// ---------------------------------------------------------------------------
// General fit tolerances -- first-pass guesses for FDM. Print a small test
// coupon (a short section of each fit) before committing to a full part, and
// adjust these three numbers rather than hand-editing the fits below.
// ---------------------------------------------------------------------------
CLEARANCE_LOOSE = 0.40;  // radial clearance for a part that must spin/drop freely (pocket hole, pin sockets)
CLEARANCE_SNUG  = 0.15;  // radial clearance for a locating/pilot fit
CLEARANCE_PRESS = -0.10; // negative = interference, for press-fit magnet pockets

// ---------------------------------------------------------------------------
// Singulator disk
// ---------------------------------------------------------------------------
// Scaled up from the 30mm placeholder, driven by the hopper needing to hold 50+ cases (see the
// capacity check in the hopper section). Growing the wheel also relieves what was a real squeeze:
//   - a scallop cuts POCKET_D/2 into the rim, so wheel material only survives inside
//     DISK_OD/2 - POCKET_D/2. At 30mm that was 9.8mm and forced the hub's magnets down to 4mm;
//     at 50mm it's 19.8mm, which comfortably takes the 6mm magnets back.
//   - scallop spacing: to leave as much rim material between scallops as each scallop is wide,
//     you need pi*DISK_OD >= 2 * POCKET_COUNT * POCKET_D. At 50mm that allows up to 7.
DISK_OD        = 50;
DISK_THICKNESS = 25;  // the wheel's TREAD WIDTH -- how much of a case's length the scallop cradles. The case
                       // lies parallel to the wheel's axis and overhangs both this and the back plate, so a
                       // wider tread cradles it more stably. Kept equal to HOPPER_DEPTH so the hopper's walls
                       // and the wheel's tread support the case over the same span.

// Scallops are cut into the wheel's RIM, not through its face: a case lying parallel to the wheel's axis
// nests into a half-round notch of the same axis orientation. Cases ride on the tread (the wheel's
// cylindrical side IS the hopper's floor at the outlet) until a scallop comes round and takes one.
POCKET_D       = CASE_RIM_D + 2*CLEARANCE_LOOSE;  // scallop diameter -- clears the case's largest section
POCKET_ORBIT_R = DISK_OD / 2;   // scallop centers sit exactly on the rim, so each is a half-round bite. Moving
                                 // this inward would grip harder but the case could then only leave axially.
POCKET_COUNT   = 4;             // at 90 degree spacing this pairs with SINGULATOR_EXPOSURE_ANGLE below: exactly
                                 // one scallop sits in the exposed window at a time.

// ---------------------------------------------------------------------------
// Retaining radius -- the single wall the pile runs against
//
// A case seated in a scallop has its centre on the rim, so it sticks out past
// the wheel's own surface by half a case. Anything meant to run beside the
// wheel therefore has to clear POCKET_ORBIT_R + CASE_RIM_D/2, NOT just the
// wheel's radius. Getting that wrong is what put a 2.8mm interference between
// a seated case and the hopper's outlet: the case fouled the hopper wall on
// its way out of the pile.
//
// The hopper's outlet cut and the shroud's inner face both use this one
// radius, so they hand off flush with no step for a case to catch on.
SHROUD_CLEAR = 1.0;   // radial clearance over a seated case
RETAIN_R     = POCKET_ORBIT_R + POCKET_D/2 + SHROUD_CLEAR;

// ---------------------------------------------------------------------------
// Back plate (stationary) -- the surface case bases ride on
//
// This is the hopper's floor continued underneath the wheel. A case stands
// base-down on it, is captured laterally by a rim scallop, and rides round
// with its base sliding on this plate until it reaches the discharge hole and
// drops through.
// ---------------------------------------------------------------------------
BACKPLATE_OD             = DISK_OD + 16;
BACKPLATE_THICKNESS      = 4;
BACKPLATE_CLEARANCE_GAP  = 0.5;   // running clearance between the wheel's back face and the plate
BACKPLATE_CENTER_CLEAR_D = 34;    // central clearance the hub's pins/magnets/boss pass through unblocked
DISCHARGE_CUTOUT_D       = POCKET_D + 2.5;  // bigger than the scallop, for rotational alignment slop
DISCHARGE_ANGLE          = 250;   // degrees. Pickup happens where the hopper's outlet meets the rim (top of
                                   // the wheel); this is far enough round that the shroud has carried the case
                                   // clear of the pile before letting it drop.

// ---------------------------------------------------------------------------
// Hopper -- flat-backed pan (geometry is Cody's; see hopper.scad).
//
// These live here rather than in hopper.scad because feeder_assembly.scad
// needs them to place the pan against the wheel, and a duplicated copy in the
// assembly file silently went stale once already.
// ---------------------------------------------------------------------------
HOPPER_WALL_T     = 2;
HOPPER_BASE_T     = 3;
HOPPER_WIDTH      = 85;              // sized for the 50-case target -- see the capacity check below
HOPPER_HEIGHT     = 90;
HOPPER_DEPTH      = DISK_THICKNESS;  // matches the wheel's tread width
HOPPER_FEED_ANGLE = 30;              // convergence of the pan's lower sides down to the outlet

// How much of the wheel's circumference is exposed to the pile through the outlet. This is what
// sets the outlet's width, and from there the whole converging funnel -- see hopper.scad, where
// the chord it subtends drives angleX/angleY rather than those being picked by eye.
SINGULATOR_EXPOSURE_ANGLE = 90;

// Where the wheel's center sits relative to the pan's bottom edge, and how far its rim therefore
// stands proud of that edge. R*cos(theta/2) is the exact offset that puts the exposure chord on
// the bottom edge; 0.35*D is the approximation used in hopper.scad (0.3536*D at 90 degrees).
SINGULATOR_CENTER_DROP = 0.35 * DISK_OD;
RIM_INTRUSION          = DISK_OD/2 - SINGULATOR_CENTER_DROP;  // exposed tread the pile rests on

// The outlet cut is sized to RETAIN_R, not to the wheel. It has to clear a case seated in a
// scallop (which reaches past the wheel's own surface), while still being tight enough that a
// loose case from the pile can't escape through the annular gap -- both asserted below.
HOPPER_CUT_D = 2 * RETAIN_R;

// The converging funnel falls out of the singulator geometry rather than being picked by eye: the
// exposure angle subtends a chord across the wheel, that chord is exactly how wide the outlet has
// to be, and the sides fall back from it at HOPPER_FEED_ANGLE.
HOPPER_CHORD   = DISK_OD * sin(SINGULATOR_EXPOSURE_ANGLE / 2);

// Arching risk. Standard hopper practice wants an outlet at least 4-6x the particle size before
// bridging stops being likely; below that, particles can key together into a stable arch over the
// opening and the hopper stops feeding even though it's full. This is NOT asserted, because the
// number here is genuinely marginal rather than wrong, and two things work in our favour that the
// rule of thumb doesn't account for: the outlet's floor is a rotating wheel (a continuous
// agitator, where the rule assumes static walls), and brass cases are smooth and non-cohesive.
// Raising SINGULATOR_EXPOSURE_ANGLE widens the chord if this does bridge on the bench -- about
// 100 degrees reaches 4x, about 147 degrees reaches 5x.
HOPPER_BRIDGE_RATIO = HOPPER_CHORD / CASE_RIM_D;
HOPPER_ANGLE_X = (HOPPER_WIDTH - HOPPER_CHORD) / 2;
HOPPER_ANGLE_Y = HOPPER_ANGLE_X / tan(HOPPER_FEED_ANGLE);

// Capacity check. Cases stand base-down on the pan's base plate, so they fill it as a single
// layer and capacity is just floor area over area-per-case. The per-case figure is hex packing
// at the case's rim diameter plus a little slop, then derated 15% because cases dumped in loose
// never pack perfectly.
HOPPER_FLOOR_AREA  = (HOPPER_WIDTH - 2*HOPPER_WALL_T) * (HOPPER_HEIGHT - HOPPER_WALL_T)
                     - HOPPER_ANGLE_X * HOPPER_ANGLE_Y;
HOPPER_AREA_PER_CASE = 0.866 * pow(CASE_RIM_D + 1, 2) * 1.15;
HOPPER_CAPACITY      = floor(HOPPER_FLOOR_AREA / HOPPER_AREA_PER_CASE);

// ---------------------------------------------------------------------------
// Shroud -- wraps the rim so a captured case can't fall out of its scallop
// between pickup and discharge. Where the shroud ends IS the release point.
// ---------------------------------------------------------------------------
// SHROUD_CLEAR and the shroud's inner radius (RETAIN_R) are defined up with the pocket geometry,
// since the hopper's outlet cut has to use the same radius.
SHROUD_THICKNESS   = 3;

// The shroud picks up exactly where the hopper's exposure window ends, so the pile runs against
// one continuous wall. Starting it any earlier drives the shroud into the hopper's opening -- an
// earlier fixed value of 100 overlapped the window by 35 degrees and the two parts collided.
SHROUD_START_ANGLE = 90 + SINGULATOR_EXPOSURE_ANGLE/2;
SHROUD_END_ANGLE   = DISCHARGE_ANGLE;

// ---------------------------------------------------------------------------
// Motor-side quick-change hub
//
// Fixed to the feeder motor's shaft ONCE (grub screw, set-and-forget). Every
// case-family disk pops on/off this same hub tool-lessly: 3 drive pins carry
// the actual torque, 3 magnets hold the disk on axially. No grub screw is
// ever touched again after the initial motor install.
// ---------------------------------------------------------------------------
DSHAFT_D          = 5.0;   // NEMA17 5mm D-shaft
DSHAFT_FLAT_DEPTH = 0.5;   // how far the flat is cut in from the full-diameter edge (typical for a 5mm D-shaft;
                            // measure yours -- this varies by manufacturer)
HUB_OD            = 36;    // hub body, sits behind the back plate -- does not need to pass through anything
                            // (must fully contain the magnet pockets below -- see assertion at the bottom
                            // of this file; a render caught this too small once, the pockets broke
                            // through the outer wall)
HUB_LENGTH        = 14;    // along the shaft
HUB_SETSCREW_D    = 2.6;   // pilot for an M3 thread-forming screw (drill/tap after printing, or press in a
                            // brass insert) -- this is the ONLY fastener touched when installing the motor

ENGAGEMENT_DEPTH = 4;  // how far the boss/pins reach into the disk's back face -- shared so both bottom out together

// Everything the hub puts on the wheel's back face has to live inside the radius the scallops
// leave intact (DISK_OD/2 - POCKET_D/2 = 9.8mm at a 30mm wheel), which is what forced this whole
// interface down a size. Angular position doesn't matter -- if it fits inside that radius it
// clears every scallop regardless of where they land.
PILOT_BOSS_D   = 8;    // centers the wheel on the hub
PILOT_BOSS_LEN = BACKPLATE_THICKNESS + 2*BACKPLATE_CLEARANCE_GAP + ENGAGEMENT_DEPTH;  // back plate + both running
                                                                                       // gaps + engagement

DRIVE_PIN_D       = 3.0;
DRIVE_PIN_LEN     = BACKPLATE_THICKNESS + 2*BACKPLATE_CLEARANCE_GAP + ENGAGEMENT_DEPTH;
DRIVE_PIN_ORBIT_R = 8;
DRIVE_PIN_COUNT   = 3;

MAGNET_D            = 6.0;   // common small neodymium disc -- confirm against what you actually source
MAGNET_THICKNESS    = 2.0;
MAGNET_ORBIT_R      = 12;
MAGNET_COUNT        = 3;
MAGNET_ANGLE_OFFSET = 60;    // rotates the magnet circle relative to the pin circle, purely so the two sets of
                              // pockets don't crowd each other -- hub and disk both use this same constant so
                              // they always line up

// ---------------------------------------------------------------------------
// Motor mount
//
// The bracket is the ONLY part in this design carrying a motor bolt pattern,
// deliberately: the feeder motor isn't locked in, so changing frame size means
// reprinting one small plate and nothing else. Values below are NEMA17.
//
// The bracket ties to the back plate through three standoffs on the back
// plate's existing mount circle, so motor, plate and wheel all reference one
// axis and the shaft can't wander out of the wheel's center.
// ---------------------------------------------------------------------------
MOTOR_BOLT_SQUARE  = 31;     // NEMA17 bolt spacing, center to center
MOTOR_BOLT_D       = 3.4;    // M3 clearance
MOTOR_BOSS_D       = 22;     // NEMA17 pilot boss on the motor's face
MOTOR_BOSS_CLEAR_D = 23.5;
MOTOR_SHAFT_LEN    = 24;     // shaft protrusion beyond the motor face -- MEASURE YOURS, 22 and 24 both common

MOTOR_BRACKET_OD        = BACKPLATE_OD;
MOTOR_BRACKET_THICKNESS = 5;
MOTOR_STANDOFF_LEN      = 20;   // off-the-shelf M3 standoff length
MOTOR_STANDOFF_OD       = 8;
MOUNT_HOLE_CHECK_D      = 3.4;   // the M3 clearance used on both plates, mirrored here for the assertions

// A stepper doesn't care how it's clocked, so the bolt pattern is rotated to put its corners as
// far as possible from the discharge path. The square's corners sit at offset+45+90k, so this
// offset lands them at DISCHARGE_ANGLE +/- 45 -- the furthest a 4-hole pattern can get from one
// direction. Getting this wrong is easy and silent (an earlier +45 put a bolt exactly ON the
// discharge axis), hence the assertion at the bottom of this file.
MOTOR_BOLT_ANGLE_OFFSET = DISCHARGE_ANGLE - 90;

// A dropped case falls backwards through the back plate's discharge hole, so it has to clear the
// bracket plane too -- otherwise the bracket is a floor the case lands on.
MOTOR_DISCHARGE_CLEAR_D = 16;

// Axial stack, working back from the wheel. The motor's face lands behind the back plate by the
// standoffs plus the bracket, and the shaft then has to reach forward far enough to fill the hub.
MOTOR_FACE_Z        = -(BACKPLATE_THICKNESS + MOTOR_STANDOFF_LEN + MOTOR_BRACKET_THICKNESS);
HUB_BACK_Z          = -(BACKPLATE_THICKNESS + BACKPLATE_CLEARANCE_GAP) - HUB_LENGTH;
SHAFT_TIP_Z         = MOTOR_FACE_Z + MOTOR_SHAFT_LEN;
SHAFT_IN_HUB        = SHAFT_TIP_Z - HUB_BACK_Z;   // how much of the hub's bore the shaft actually fills

// Where things land in the bracket's plane, used by the clearance assertions below
MOTOR_BOLT_ORBIT_R = MOTOR_BOLT_SQUARE * sqrt(2) / 2;
DISCHARGE_X        = POCKET_ORBIT_R * cos(DISCHARGE_ANGLE);
DISCHARGE_Y        = POCKET_ORBIT_R * sin(DISCHARGE_ANGLE);
MOTOR_BOLT_GAP     = min([ for (k = [0:3])
                           let (a = MOTOR_BOLT_ANGLE_OFFSET + 45 + 90*k)
                           norm([MOTOR_BOLT_ORBIT_R*cos(a) - DISCHARGE_X,
                                 MOTOR_BOLT_ORBIT_R*sin(a) - DISCHARGE_Y]) ]);
MOTOR_STANDOFF_GAP = min([ for (k = [0:2])
                           let (a = DISCHARGE_ANGLE + 70 + 120*k, r = BACKPLATE_OD/2 - 4)
                           norm([r*cos(a) - DISCHARGE_X, r*sin(a) - DISCHARGE_Y]) ]);

// ---------------------------------------------------------------------------
// Sanity checks -- these catch a future dimension edit that would silently
// break the fit (e.g. shrinking the back plate's clearance hole until it
// clips the magnets, or growing the pocket orbit until it exits the disk).
// If OpenSCAD throws one of these, a value above needs to change, not this
// assertion.
// ---------------------------------------------------------------------------
assert(MAGNET_ORBIT_R + MAGNET_D/2 < BACKPLATE_CENTER_CLEAR_D/2,
    "drive hub magnets must fit inside the back plate's central clearance hole");
assert(DRIVE_PIN_ORBIT_R + DRIVE_PIN_D/2 < BACKPLATE_CENTER_CLEAR_D/2,
    "drive pins must fit inside the back plate's central clearance hole");
assert(PILOT_BOSS_D/2 < DRIVE_PIN_ORBIT_R - DRIVE_PIN_D/2,
    "pilot boss must not overlap the drive pin circle");
assert(MAGNET_ORBIT_R + MAGNET_D/2 < HUB_OD/2 - 2,
    "hub magnet pockets must stay well inside the hub body's outer wall (2mm min) -- caught a real print-breaking bug here once already");
assert(DRIVE_PIN_ORBIT_R + DRIVE_PIN_D/2 < HUB_OD/2 - 2,
    "hub drive pins must stay well inside the hub body's outer wall (2mm min)");
assert(POCKET_ORBIT_R - POCKET_D/2 > MAGNET_ORBIT_R + MAGNET_D/2 + 2,
    "rim scallops must not cut into the wheel's hub-mounting region");
assert(DISCHARGE_CUTOUT_D/2 < BACKPLATE_OD/2 - DISK_OD/2 + POCKET_D/2,
    "discharge hole must stay inside the back plate's outer edge");
assert(HOPPER_CHORD < HOPPER_WIDTH - 4*HOPPER_WALL_T,
    "hopper must be wider than the wheel's exposure chord, with wall left either side");
assert(HOPPER_CAPACITY >= 50,
    "hopper must hold at least 50 cases -- grow HOPPER_WIDTH/HOPPER_HEIGHT (estimate, verify with real brass)");

// Motor mount clearances -- all three of these are things that look fine in the numbers and only
// show up as a jam or a dead-end on the bench.
assert(SHAFT_IN_HUB >= 10,
    "motor shaft must reach far enough into the hub bore -- adjust MOTOR_STANDOFF_LEN or check MOTOR_SHAFT_LEN");
assert(SHAFT_IN_HUB <= HUB_LENGTH,
    "motor shaft would bottom out past the hub -- it would push the wheel off the hub face");
assert(MOTOR_BOLT_GAP > MOTOR_BOLT_D/2 + MOTOR_DISCHARGE_CLEAR_D/2 + 1.5,
    "a motor bolt hole is too close to the discharge opening -- re-clock MOTOR_BOLT_ANGLE_OFFSET");
assert(MOTOR_STANDOFF_GAP > MOUNT_HOLE_CHECK_D/2 + MOTOR_DISCHARGE_CLEAR_D/2 + 1.5,
    "a standoff is too close to the discharge opening -- move the back plate mount circle");

// Jam / interference checks around the outlet -- the "curved area" where the pile meets the wheel.
assert(RETAIN_R > POCKET_ORBIT_R + CASE_RIM_D/2,
    "retaining wall must clear a case seated in a scallop, or the case fouls it leaving the pile");
assert(RETAIN_R - DISK_OD/2 < CASE_RIM_D,
    "annular gap beside the wheel must be narrower than a case, or loose cases escape the pile");
assert(SHROUD_START_ANGLE >= 90 + SINGULATOR_EXPOSURE_ANGLE/2,
    "shroud must start at or after the hopper's exposure window, or the two parts occupy the same space");

