// Swappable singulator wheel -- one per case-family. Rides on drive_hub.scad
// (3 pins for torque, 3 magnets for axial retention, tool-less swap) and
// turns against the stationary back_plate.scad.
//
// The capture feature is a set of half-round SCALLOPS CUT INTO THE RIM, not
// holes through the face. Cases lie parallel to the wheel's axis, so a case
// and a scallop are two parallel cylinders -- the case nests into the notch
// exactly. The wheel's cylindrical side is also the hopper's floor at the
// outlet: the pile rests on the tread, and a scallop coming round takes one
// case off the bottom of it.
//
// Sized for .223 Rem / 5.56 NATO (see dimensions.scad). For another case
// family only POCKET_D changes -- the hub interface is identical across every
// family, so all of them fit the same hub.
//
// Coordinate convention: Z = the wheel's axis. Z=0 is the BACK face (the one
// that runs against the back plate; the hub's pins/boss land here).
// Z=DISK_THICKNESS is the FRONT face, the open side the cases stick out of.
//
// Open this file directly in OpenSCAD to preview just the wheel.

include <../lib/dimensions.scad>
include <../lib/shapes.scad>

module singulator_disk() {
    difference() {
        cylinder(d = DISK_OD, h = DISK_THICKNESS);

        // Rim scallops -- each a half-round bite, axis parallel to the
        // wheel's, running the full tread width so a case can nest in and
        // later drop straight out radially.
        orbit(POCKET_ORBIT_R, POCKET_COUNT)
            translate([0, 0, -1])
                cylinder(d = POCKET_D, h = DISK_THICKNESS + 2);

        // Back-face mounting interface -- must match drive_hub.scad exactly.
        translate([0, 0, -0.01])
            cylinder(d = PILOT_BOSS_D + 2*CLEARANCE_SNUG, h = ENGAGEMENT_DEPTH);

        orbit(DRIVE_PIN_ORBIT_R, DRIVE_PIN_COUNT)
            translate([0, 0, -0.01])
                cylinder(d = DRIVE_PIN_D + 2*CLEARANCE_LOOSE, h = ENGAGEMENT_DEPTH);

        orbit(MAGNET_ORBIT_R, MAGNET_COUNT, MAGNET_ANGLE_OFFSET)
            translate([0, 0, -0.01])
                cylinder(d = MAGNET_D + 2*CLEARANCE_PRESS, h = MAGNET_THICKNESS + 0.2);
    }
}

singulator_disk();
