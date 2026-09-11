// Stationary face plate -- sits between the singulator disk and the drive
// hub. Blocks the disk's pocket hole everywhere except one discharge cutout,
// which is what actually singulates: a captured case rides around, blocked
// from falling through, until the pocket's rotation lines up with this
// cutout and the case drops through into the chute below. See
// docs/DESIGN.md "Hopper + singulator disk".
//
// This part does NOT rotate -- it mounts fixed to the housing. The hub's
// pins/boss/magnets pass through its central clearance hole completely
// unblocked to reach the disk on the other side; only the pocket's orbit
// (further out, at POCKET_ORBIT_R) is actually blocked by this plate.
//
// Coordinate convention: Z=0 is the FRONT face (facing the disk, separated by
// FACEPLATE_CLEARANCE_GAP). Z=FACEPLATE_THICKNESS is the BACK face (facing
// the hub, separated by another FACEPLATE_CLEARANCE_GAP).
//
// DISCHARGE_ANGLE (dimensions.scad) sets where the cutout sits, in this
// part's own local frame -- feeder_assembly.scad is what maps that to the
// real "downhill" direction once the ~45 degree tilt is applied.
//
// Open this file directly in OpenSCAD to preview just the face plate.

include <../lib/dimensions.scad>
include <../lib/shapes.scad>

MOUNT_HOLE_D = 3.4;              // M3 clearance
MOUNT_HOLE_ORBIT_R = FACEPLATE_OD/2 - 5;
MOUNT_HOLE_COUNT = 3;
MOUNT_HOLE_START_ANGLE = DISCHARGE_ANGLE + 60;  // offset off the discharge cutout so nothing overlaps

module face_plate() {
    difference() {
        cylinder(d = FACEPLATE_OD, h = FACEPLATE_THICKNESS);

        // Central clearance -- hub's pins/boss/magnets pass through untouched
        translate([0, 0, -1])
            cylinder(d = FACEPLATE_CENTER_CLEAR_D, h = FACEPLATE_THICKNESS + 2);

        // Discharge cutout -- the one place a captured case is allowed through
        translate([POCKET_ORBIT_R * cos(DISCHARGE_ANGLE), POCKET_ORBIT_R * sin(DISCHARGE_ANGLE), -1])
            cylinder(d = DISCHARGE_CUTOUT_D, h = FACEPLATE_THICKNESS + 2);

        // Mounting holes into the housing
        orbit(MOUNT_HOLE_ORBIT_R, MOUNT_HOLE_COUNT, MOUNT_HOLE_START_ANGLE)
            translate([0, 0, -1])
                cylinder(d = MOUNT_HOLE_D, h = FACEPLATE_THICKNESS + 2);
    }
}

face_plate();
