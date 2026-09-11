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
// Wheel diameter is squeezed from two directions, so it can't be picked freely:
//   - scallop spacing: to leave as much rim material between scallops as each scallop is wide,
//     you need pi*DISK_OD >= 2 * POCKET_COUNT * POCKET_D. At POCKET_D 10.4 that's DISK_OD >= 40
//     for 6 scallops, >= 27 for 4, >= 20 for 3.
//   - the quick-change hub: a scallop cuts POCKET_D/2 into the rim, and the hub's magnet circle
//     needs MAGNET_ORBIT_R + MAGNET_D/2 of clear radius inside that. With the current hub that
//     puts a hard floor of about DISK_OD >= 49 (see the assertion at the bottom of this file).
// So a ~20mm singulator wheel is not compatible with this magnetic quick-change hub -- it would
// need a smaller hub interface (smaller magnets on a tighter circle), at the cost of grip.
DISK_OD        = 56;
DISK_THICKNESS = 20;  // the wheel's TREAD WIDTH -- how much of a case's length the scallop cradles. The case
                       // lies parallel to the wheel's axis and overhangs both this and the back plate, so a
                       // wider tread cradles it more stably. Kept equal to HOPPER_DEPTH so the hopper's walls
                       // and the wheel's tread support the case over the same span.

// Scallops are cut into the wheel's RIM, not through its face: a case lying parallel to the wheel's axis
// nests into a half-round notch of the same axis orientation. Cases ride on the tread (the wheel's
// cylindrical side IS the hopper's floor at the outlet) until a scallop comes round and takes one.
POCKET_D       = CASE_RIM_D + 2*CLEARANCE_LOOSE;  // scallop diameter -- clears the case's largest section
POCKET_ORBIT_R = DISK_OD / 2;   // scallop centers sit exactly on the rim, so each is a half-round bite. Moving
                                 // this inward would grip harder but the case could then only leave axially.
POCKET_COUNT   = 6;             // the reference wheel is scalloped all the way round; 1 also works (the rest of
                                 // the tread is just smooth floor for the pile) but feeds far slower.

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
BACKPLATE_CENTER_CLEAR_D = 36;    // central clearance the hub's pins/magnets/boss pass through unblocked
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
HOPPER_WALL_T  = 2;
HOPPER_BASE_T  = 3;
HOPPER_HEIGHT  = 50;
HOPPER_DEPTH   = DISK_THICKNESS;  // matches the wheel's tread width
HOPPER_MARGIN  = 12;              // material either side of the wheel at the outlet
HOPPER_WIDTH   = DISK_OD + 2*HOPPER_MARGIN;
HOPPER_FEED_ANGLE = 30;           // convergence of the pan's lower sides down to the outlet
RIM_INTRUSION  = 4;               // how far the wheel's rim stands proud of the hopper's bottom edge --
                                   // this is the exposed tread the bottom of the pile rests on

// ---------------------------------------------------------------------------
// Shroud -- wraps the rim so a captured case can't fall out of its scallop
// between pickup and discharge. Where the shroud ends IS the release point.
// ---------------------------------------------------------------------------
SHROUD_CLEAR       = 1.0;   // radial clearance over the captured case
SHROUD_THICKNESS   = 3;
SHROUD_START_ANGLE = 100;   // just past the hopper outlet at the top of the wheel (90 degrees)
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
HUB_OD            = 40;    // hub body, sits behind the back plate -- does not need to pass through anything
                            // (must fully contain the magnet pockets below -- see assertion at the bottom
                            // of this file; a render caught this too small at 30mm, the pockets broke
                            // through the outer wall)
HUB_LENGTH        = 14;    // along the shaft
HUB_SETSCREW_D    = 2.6;   // pilot for an M3 thread-forming screw (drill/tap after printing, or press in a
                            // brass insert) -- this is the ONLY fastener touched when installing the motor

ENGAGEMENT_DEPTH = 4;  // how far the boss/pins reach into the disk's back face -- shared so both bottom out together

PILOT_BOSS_D   = 8;    // centers the disk on the hub
PILOT_BOSS_LEN = BACKPLATE_THICKNESS + 2*BACKPLATE_CLEARANCE_GAP + ENGAGEMENT_DEPTH;  // back plate + both running
                                                                                       // gaps + engagement

DRIVE_PIN_D       = 3.0;
DRIVE_PIN_LEN     = BACKPLATE_THICKNESS + 2*BACKPLATE_CLEARANCE_GAP + ENGAGEMENT_DEPTH;
DRIVE_PIN_ORBIT_R = 12;
DRIVE_PIN_COUNT   = 3;

MAGNET_D            = 6.0;   // common small neodymium disc magnet -- confirm against what you actually source
MAGNET_THICKNESS    = 2.0;
MAGNET_ORBIT_R      = 14;
MAGNET_COUNT        = 3;
MAGNET_ANGLE_OFFSET = 60;    // rotates the magnet circle relative to the pin circle, purely so the two sets of
                              // pockets don't crowd each other -- hub and disk both use this same constant so
                              // they always line up

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
