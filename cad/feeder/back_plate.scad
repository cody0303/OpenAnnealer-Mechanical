// Stationary back plate -- the surface case bases ride on.
//
// This is the hopper's floor continued underneath the wheel. A case stands
// base-down on this plate; the hopper's converging walls slide it down to the
// outlet, where a rim scallop on the wheel captures it laterally. From there
// the case rides round with its base still sliding on this plate, until the
// scallop reaches the discharge hole and the case drops straight through.
//
// So this plate does the axial job (holding the case's base) while the
// wheel's rim scallop does the lateral job (carrying it round). Replaces the
// earlier face_plate.scad, which was built for a through-the-face pocket that
// turned out to be the wrong mechanism.
//
// The hub's pins/boss/magnets pass through the central clearance hole
// completely unblocked to reach the wheel on the other side.
//
// Coordinate convention: Z=0 is the FRONT face (the side the wheel runs
// against, separated by BACKPLATE_CLEARANCE_GAP). Z=BACKPLATE_THICKNESS is
// the BACK face, toward the hub and motor.
//
// Open this file directly in OpenSCAD to preview just the plate.

include <../lib/dimensions.scad>
include <../lib/shapes.scad>

MOUNT_HOLE_D           = 3.4;   // M3 clearance
MOUNT_HOLE_ORBIT_R     = BACKPLATE_OD/2 - 4;
MOUNT_HOLE_COUNT       = 3;
MOUNT_HOLE_START_ANGLE = DISCHARGE_ANGLE + 70;  // kept off the discharge hole

module back_plate() {
    difference() {
        cylinder(d = BACKPLATE_OD, h = BACKPLATE_THICKNESS);

        // Central clearance -- hub's pins/boss/magnets pass through untouched
        translate([0, 0, -1])
            cylinder(d = BACKPLATE_CENTER_CLEAR_D, h = BACKPLATE_THICKNESS + 2);

        // Discharge hole -- the one place a carried case is allowed through.
        // Sits on the scallop's orbit (the wheel's rim), so it straddles the
        // wheel's edge: half under the wheel, half outside it.
        translate([POCKET_ORBIT_R * cos(DISCHARGE_ANGLE),
                   POCKET_ORBIT_R * sin(DISCHARGE_ANGLE),
                   -1])
            cylinder(d = DISCHARGE_CUTOUT_D, h = BACKPLATE_THICKNESS + 2);

        // Mounting holes into the housing
        orbit(MOUNT_HOLE_ORBIT_R, MOUNT_HOLE_COUNT, MOUNT_HOLE_START_ANGLE)
            translate([0, 0, -1])
                cylinder(d = MOUNT_HOLE_D, h = BACKPLATE_THICKNESS + 2);
    }
}

back_plate();
