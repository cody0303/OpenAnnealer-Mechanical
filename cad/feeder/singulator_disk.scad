// Swappable singulator disk -- one per case-family. Rides on drive_hub.scad
// (3 pins for torque, 3 magnets for axial retention, tool-less swap) and
// spins against the stationary face_plate.scad. See docs/DESIGN.md
// "Hopper + singulator disk" for how the mechanism works.
//
// This file is sized for .223 Rem / 5.56 NATO (see dimensions.scad). To make
// a disk for another case family, copy dimensions.scad's case-dimension block
// into a family-specific override and re-render -- POCKET_HOLE_D is the only
// thing that needs to change; the hub interface (pins/magnets/boss) is
// identical across every family so they all fit the same hub.
//
// Coordinate convention: Z=0 is the disk's FRONT face (hopper side, where the
// pocket opens to receive a case). Z=DISK_THICKNESS is the BACK face (hub
// side) -- the pilot hole, pin sockets, and magnet pockets are recessed into
// this face.
//
// The pocket is modeled at DISCHARGE_ANGLE (dimensions.scad). Its absolute
// angle doesn't matter for printing -- the disk is otherwise rotationally
// symmetric about its own axis -- it's only placed there so a standalone
// render of this disk lines up with face_plate.scad's cutout in the combined
// preview (feeder_assembly.scad).
//
// Open this file directly in OpenSCAD to preview just the disk.

include <../lib/dimensions.scad>
include <../lib/shapes.scad>

module singulator_disk() {
    difference() {
        // Disk body
        cylinder(d = DISK_OD, h = DISK_THICKNESS);

        // Pocket hole -- clears the case rim; does NOT catch it. The face
        // plate's solid ring is what holds a captured case in until the
        // discharge cutout arrives. Placed at DISCHARGE_ANGLE purely so a
        // standalone render of this disk lines up with face_plate.scad's
        // cutout in feeder_assembly.scad's combined preview -- the pocket's
        // absolute angle doesn't matter for printing since the disk spins.
        translate([POCKET_ORBIT_R * cos(DISCHARGE_ANGLE), POCKET_ORBIT_R * sin(DISCHARGE_ANGLE), -1])
            cylinder(d = POCKET_HOLE_D, h = DISK_THICKNESS + 2);

        // Back-face mounting interface -- must match drive_hub.scad exactly.
        // (PILOT_BOSS_LEN and DRIVE_PIN_LEN both already fold in the face
        // plate's thickness and running gaps -- only ENGAGEMENT_DEPTH of that
        // actually enters the disk, hence using it directly here rather than
        // re-deriving it from the boss/pin length.)
        translate([0, 0, DISK_THICKNESS - ENGAGEMENT_DEPTH + 0.01])
            cylinder(d = PILOT_BOSS_D + 2*CLEARANCE_SNUG, h = ENGAGEMENT_DEPTH + 1);

        orbit(DRIVE_PIN_ORBIT_R, DRIVE_PIN_COUNT)
            translate([0, 0, DISK_THICKNESS - ENGAGEMENT_DEPTH + 0.01])
                cylinder(d = DRIVE_PIN_D + 2*CLEARANCE_LOOSE, h = ENGAGEMENT_DEPTH + 1);

        orbit(MAGNET_ORBIT_R, MAGNET_COUNT, MAGNET_ANGLE_OFFSET)
            translate([0, 0, DISK_THICKNESS - (MAGNET_THICKNESS + 0.2) + 0.01])
                cylinder(d = MAGNET_D + 2*CLEARANCE_PRESS, h = MAGNET_THICKNESS + 0.2);
    }
}

singulator_disk();
