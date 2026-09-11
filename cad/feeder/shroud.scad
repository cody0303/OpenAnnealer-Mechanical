// Shroud -- a stationary arc wall wrapping the singulator wheel's rim.
//
// Once a case is nested in a rim scallop, nothing stops it rolling straight
// back out as the wheel turns away from the hopper. This wall is what keeps it
// in: it follows the rim at a small clearance over the captured case, from just
// past the hopper's outlet round to the discharge angle.
//
// Where the shroud ENDS is the release point -- the case is simply no longer
// held, and drops out of its scallop into the chute below. So SHROUD_END_ANGLE
// and DISCHARGE_ANGLE are the same number by definition (see dimensions.scad).
//
// Coordinate convention: concentric with the wheel, Z = the wheel's axis, and
// Z=0 lines up with the wheel's back face so the wall spans the tread width.
//
// Open this file directly in OpenSCAD to preview just the shroud.

include <../lib/dimensions.scad>

SHROUD_INNER_R = POCKET_ORBIT_R + POCKET_D/2 + SHROUD_CLEAR;

module shroud() {
    sweep = SHROUD_END_ANGLE - SHROUD_START_ANGLE;

    rotate([0, 0, SHROUD_START_ANGLE])
        rotate_extrude(angle = sweep)
            translate([SHROUD_INNER_R, 0])
                square([SHROUD_THICKNESS, DISK_THICKNESS]);
}

shroud();
