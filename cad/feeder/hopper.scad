// Hopper -- an open, flared scoop that holds a loose pile of cases standing on
// their bases directly against the singulator disk's face.
//
// Modeled on the ARC Precision / ADG annealer's feeder (see the reference
// photos discussed in docs/DESIGN.md). The key point, which is easy to get
// wrong: THE DISK FACE IS THIS HOPPER'S FLOOR. There is no separate bottom
// here. Cases are dumped in loose and stand packed together on their bases
// against the spinning disk, all roughly parallel, their axes perpendicular
// to the disk face. The whole assembly leans ~45 degrees so gravity does two
// jobs at once: it presses the case bases flat against the disk face (so a
// base can drop straight into a pocket as it passes), and it shuffles the
// pile down-slope so cases keep feeding toward the pickup zone.
//
// Structure, bottom to top:
//   - a straight collar at disk diameter, which retains the case bases over
//     the disk face and keeps the pile from spilling off the down-slope edge
//   - a flared mouth above it, which holds the bulk of the pile
//   - a big angled scoop cut through the up-slope side, so cases can be poured
//     in and the pile is visible -- this is what gives the real unit its
//     "batwing" silhouette, two pointed wings either side of an open scoop
//
// Non-precision part: nothing here needs a tight fit (unlike the
// disk/face-plate/hub interface), so treat these numbers as a starting point
// for bench iteration on pickup reliability, not a fixed spec.
//
// Open this file directly in OpenSCAD to preview just the hopper.

include <../lib/dimensions.scad>

HOPPER_WALL       = 2.5;
HOPPER_CLEAR      = 0.5;                       // radial clearance so the spinning disk never rubs the collar
HOPPER_BASE_D     = DISK_OD + 2*HOPPER_CLEAR;  // inner diameter where the hopper meets the disk
HOPPER_COLLAR_H   = 14;                        // straight retaining wall around the case bases
HOPPER_MOUTH_D    = 150;                       // flared mouth -- sets how big a pile it holds
HOPPER_FLARE_H    = 80;
HOPPER_SCOOP_ANG  = 38;                        // how steeply the loading scoop's floor slopes
HOPPER_SCOOP_Z    = 16;                        // how far up the wall the scoop cut starts
HOPPER_SCOOP_SECTOR = 150;                     // angular width of the scoop opening, centered up-slope (+Y).
                                                // The rest of the circumference keeps full height: a tall
                                                // retaining wall down-slope where the pile sits, and the two
                                                // pointed "wings" either side of the opening.

// Hollow frustum: a conical wall of constant thickness, open at both ends.
// d1_in/d2_in are INNER diameters at the bottom and top.
module conical_shell(d1_in, d2_in, h, wall) {
    difference() {
        cylinder(d1 = d1_in + 2*wall, d2 = d2_in + 2*wall, h = h);
        translate([0, 0, -1])
            cylinder(d1 = d1_in, d2 = d2_in, h = h + 2);
    }
}

// Pie-slice solid of `sector` degrees, centered on +Y, used to limit the
// scoop cut to the up-slope side instead of slicing all the way around.
module pie_wedge(sector, r, h) {
    rotate([0, 0, 90 - sector/2])
        rotate_extrude(angle = sector)
            square([r, h]);
}

module hopper() {
    big = 400;  // oversized cutting solid

    difference() {
        union() {
            // Retaining collar, straight at disk diameter
            conical_shell(HOPPER_BASE_D, HOPPER_BASE_D, HOPPER_COLLAR_H, HOPPER_WALL);

            // Flared mouth
            translate([0, 0, HOPPER_COLLAR_H])
                conical_shell(HOPPER_BASE_D, HOPPER_MOUTH_D, HOPPER_FLARE_H, HOPPER_WALL);
        }

        // Loading scoop. Two solids intersected: a tilted half-space (so the
        // scoop's floor slopes rather than being a flat shelf) limited to a
        // pie wedge on the up-slope (+Y) side. Without the wedge the cut runs
        // right around the rim and saddles the whole hopper; with it, the
        // down-slope wall stays full height where gravity piles the cases,
        // and the two sides are left as the pointed wings.
        //
        // +Y is up-slope because DISCHARGE_ANGLE (270, i.e. -Y) is the
        // down-slope direction once feeder_assembly.scad applies the tilt.
        intersection() {
            translate([0, 0, HOPPER_SCOOP_Z])
                pie_wedge(HOPPER_SCOOP_SECTOR, big, big);

            translate([0, 0, HOPPER_SCOOP_Z])
                rotate([HOPPER_SCOOP_ANG, 0, 0])
                    translate([-big/2, 0, -big/2])
                        cube([big, big, big]);
        }
    }
}

hopper();
