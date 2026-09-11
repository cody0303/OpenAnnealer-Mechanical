// Motor-side quick-change hub for the singulator disk.
//
// Mounts on the feeder stepper's 5mm D-shaft with a single grub screw --
// tightened ONCE during initial motor install and never touched again. Every
// case-family disk (see singulator_disk.scad) pops on/off this same hub
// without tools: 3 drive pins carry the rotational torque, 3 embedded magnets
// hold the disk on axially. See docs/DESIGN.md "Hopper + singulator disk".
//
// Coordinate convention (shared with singulator_disk.scad and back_plate.scad):
// Z=0 is the hub's front face -- the plane the disk interfaces against once
// the pins/boss have crossed the back plate's clearance gap. The hub body
// extends in -Z (toward the motor); the boss, pins, and this face's magnets
// project/sit at Z>=0.
//
// Open this file directly in OpenSCAD to preview just the hub.

include <../lib/dimensions.scad>
include <../lib/shapes.scad>

module drive_hub() {
    difference() {
        union() {
            // Hub body
            translate([0, 0, -HUB_LENGTH])
                cylinder(d = HUB_OD, h = HUB_LENGTH);

            // Centering boss, projects forward from the front face
            cylinder(d = PILOT_BOSS_D, h = PILOT_BOSS_LEN);

            // Drive pins, same projection
            orbit(DRIVE_PIN_ORBIT_R, DRIVE_PIN_COUNT)
                cylinder(d = DRIVE_PIN_D, h = DRIVE_PIN_LEN);
        }

        // Shaft bore, all the way through the body. dshaft_hole() is centered
        // on Z, so it's translated to the midpoint of [-HUB_LENGTH-1, +1] --
        // 1mm of margin past each end of the body -- not to either endpoint.
        translate([0, 0, -HUB_LENGTH / 2])
            dshaft_hole(DSHAFT_D, DSHAFT_FLAT_DEPTH, HUB_LENGTH + 2);

        // Set screw, radial, through the body wall into the shaft bore --
        // the only fastener ever touched after initial install
        translate([0, 0, -HUB_LENGTH / 2])
            rotate([90, 0, 0])
                cylinder(d = HUB_SETSCREW_D, h = HUB_OD, center = true);

        // Magnet pockets, recessed into the front face
        orbit(MAGNET_ORBIT_R, MAGNET_COUNT, MAGNET_ANGLE_OFFSET)
            translate([0, 0, -(MAGNET_THICKNESS + 0.2) + 0.01])
                cylinder(d = MAGNET_D + 2 * CLEARANCE_PRESS, h = MAGNET_THICKNESS + 0.2);
    }
}

drive_hub();
