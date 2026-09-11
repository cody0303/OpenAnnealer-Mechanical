// Shared dimensions for the OpenAnnealer feeder subsystem (hopper + singulator
// disk + face plate + drive hub). Single source of truth: every part file
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
DISK_OD        = 72;
DISK_THICKNESS = 10;  // doubles as the pocket's socket depth. A case rides the disk standing on its base,
                       // perpendicular to a face that's tilted ~45 degrees, so the pocket has to be deep
                       // enough to hold it upright against its own tipping moment on the way to the
                       // discharge -- 5mm was almost certainly too shallow for a 44.7mm .223 case.
                       // Prime bench-test variable: if cases tip or hang up, this is the first number to
                       // change. (The reference ARC unit appears to stack rings behind its disk, which
                       // would be one way to tune this per case length without reprinting the disk.)

POCKET_ORBIT_R = 27;                                // radius from the rotation axis to the pocket hole's center
POCKET_HOLE_D  = CASE_RIM_D + 2*CLEARANCE_LOOSE;     // clears the case rim -- this hole does NOT catch the case;
                                                      // the face plate below does. See docs/DESIGN.md "Hopper +
                                                      // singulator disk".

// ---------------------------------------------------------------------------
// Face plate (stationary) -- blocks the pocket everywhere except one cutout
// ---------------------------------------------------------------------------
FACEPLATE_OD             = 76;
FACEPLATE_THICKNESS      = 4;
FACEPLATE_CLEARANCE_GAP  = 0.5;   // running clearance between the disk's back face and the face plate's front face
FACEPLATE_CENTER_CLEAR_D = 36;    // central clearance hole the hub's pins/magnets/boss pass through unblocked
DISCHARGE_CUTOUT_D       = POCKET_HOLE_D + 2.5;  // bigger than the pocket hole for rotational alignment slop
DISCHARGE_ANGLE          = 270;   // degrees, this part's local frame -- chosen so that, given the X-axis tilt
                                   // feeder_assembly.scad applies, this angle actually ends up lowest (real
                                   // "downhill" direction), rather than being an arbitrary illustrative choice

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
HUB_OD            = 40;    // hub body, sits behind the face plate -- does not need to pass through anything
                            // (must fully contain the magnet pockets below -- see assertion at the bottom
                            // of this file; a render caught this too small at 30mm, the pockets broke
                            // through the outer wall)
HUB_LENGTH        = 14;    // along the shaft
HUB_SETSCREW_D    = 2.6;   // pilot for an M3 thread-forming screw (drill/tap after printing, or press in a
                            // brass insert) -- this is the ONLY fastener touched when installing the motor

ENGAGEMENT_DEPTH = 4;  // how far the boss/pins reach into the disk's back face -- shared so both bottom out together

PILOT_BOSS_D   = 8;    // centers the disk on the hub
PILOT_BOSS_LEN = FACEPLATE_THICKNESS + 2*FACEPLATE_CLEARANCE_GAP + ENGAGEMENT_DEPTH;  // face plate + both running
                                                                                        // gaps + engagement

DRIVE_PIN_D       = 3.0;
DRIVE_PIN_LEN     = FACEPLATE_THICKNESS + 2*FACEPLATE_CLEARANCE_GAP + ENGAGEMENT_DEPTH;
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
// break the fit (e.g. shrinking the face plate's clearance hole until it
// clips the magnets, or growing the pocket orbit until it exits the disk).
// If OpenSCAD throws one of these, a value above needs to change, not this
// assertion.
// ---------------------------------------------------------------------------
assert(MAGNET_ORBIT_R + MAGNET_D/2 < FACEPLATE_CENTER_CLEAR_D/2,
    "drive hub magnets must fit inside the face plate's central clearance hole");
assert(DRIVE_PIN_ORBIT_R + DRIVE_PIN_D/2 < FACEPLATE_CENTER_CLEAR_D/2,
    "drive pins must fit inside the face plate's central clearance hole");
assert(PILOT_BOSS_D/2 < DRIVE_PIN_ORBIT_R - DRIVE_PIN_D/2,
    "pilot boss must not overlap the drive pin circle");
assert(MAGNET_ORBIT_R + MAGNET_D/2 < HUB_OD/2 - 2,
    "hub magnet pockets must stay well inside the hub body's outer wall (2mm min) -- caught a real print-breaking bug here once already");
assert(DRIVE_PIN_ORBIT_R + DRIVE_PIN_D/2 < HUB_OD/2 - 2,
    "hub drive pins must stay well inside the hub body's outer wall (2mm min)");
assert(POCKET_ORBIT_R - POCKET_HOLE_D/2 > FACEPLATE_CENTER_CLEAR_D/2,
    "pocket hole's inner edge must clear the face plate's central hole, so it stays over solid blocking material");
assert(POCKET_ORBIT_R + POCKET_HOLE_D/2 < DISK_OD/2 - 2,
    "pocket hole must stay well inside the disk's outer edge (2mm min rim)");
assert(POCKET_ORBIT_R + DISCHARGE_CUTOUT_D/2 < FACEPLATE_OD/2 - 2,
    "discharge cutout must stay well inside the face plate's outer edge (2mm min rim)");
