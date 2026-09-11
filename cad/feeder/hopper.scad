// Hopper -- a flat-backed pan, open at the top for loading and at the bottom
// where it feeds the singulator wheel.
//
// Geometry is Cody's, kept as written; the parameters below are just wired up
// to dimensions.scad where they have to agree with the wheel.
//
// How it works: cases stand base-down on the base plate, sticking out the
// open front, with the walls constraining them laterally near their bases.
// The whole pan leans back, so the pile slides down the base plate and the
// sides -- converging at feedAngle -- funnel it into the bottom outlet. The
// singulator wheel's rim sits in that outlet, so the bottom of the pile rests
// on the wheel's tread: the wheel's cylindrical SIDE is the floor at the
// outlet, and a rim scallop coming round takes one case off the pile.
//
// Note the pan is deliberately shallower than a case is long -- a case is
// supported over the pan's depth and overhangs out the open front. hopperDepth
// is tied to DISK_THICKNESS so the walls and the wheel's tread cradle the case
// over the same span.
//
// Open this file directly in OpenSCAD to preview just the hopper.

include <../lib/dimensions.scad>

// Values come from dimensions.scad so the assembly places this pan against the
// wheel using the same numbers the pan is built from.
wallThickness           = HOPPER_WALL_T;
baseThickness           = HOPPER_BASE_T;
hopperWidth             = HOPPER_WIDTH;
hopperHeight            = HOPPER_HEIGHT;
hopperDepth             = HOPPER_DEPTH;
feedAngle               = HOPPER_FEED_ANGLE;
singulatorDiameter      = DISK_OD;   // the bottom outlet is a circular notch the wheel's rim sits in
singulatorExposureAngle = SINGULATOR_EXPOSURE_ANGLE;

// The converging funnel is derived from the singulator, not picked by eye: the
// exposure angle subtends a chord across the wheel, that chord is exactly how
// wide the outlet has to be, and the sides then fall back from it at feedAngle.
// So the funnel always lands precisely where the wheel's rim emerges.
// (Computed in dimensions.scad so the assembly and the capacity check use the
// same numbers this pan is built from.)
chordLength = HOPPER_CHORD;
angleX      = HOPPER_ANGLE_X;
angleY      = HOPPER_ANGLE_Y;

p0 = [0, angleY];
p1 = [0, hopperHeight];
p2 = [hopperWidth, hopperHeight];
p3 = [hopperWidth, angleY];
p4 = [(hopperWidth - angleX), 0];
p5 = [angleX, 0];
points = [p0, p1, p2, p3, p4, p5];

module hopper() {
    difference() {
        difference() {
            difference() {
                linear_extrude(height = hopperDepth)
                    polygon(points);
                // hollow it out, leaving the base plate and perimeter walls
                translate([0, 0, baseThickness])
                    linear_extrude(height = (hopperHeight - baseThickness))
                        offset(r = -(wallThickness))
                            polygon(points);
            }

            // Open the bottom: a circular notch the wheel's rim sits in, so
            // the exposed tread becomes the floor under the bottom of the
            // pile. The center drops below the pan's bottom edge by
            // R*cos(theta/2) -- the offset that puts the exposure chord
            // exactly on that edge -- leaving the rim standing proud by
            // RIM_INTRUSION. The cut is sized to RETAIN_R -- big enough to
            // clear a case seated in a scallop, small enough that a loose case
            // cannot escape through the annular gap.
            translate([0.5 * hopperWidth,
                       -SINGULATOR_CENTER_DROP,
                       baseThickness])
                linear_extrude(height = hopperDepth - baseThickness + 1)
                    circle(d = HOPPER_CUT_D);
        }
        // open the top -- loading
        translate([wallThickness, (hopperHeight - wallThickness) - 1, baseThickness])
            cube([(hopperWidth - (2*wallThickness)),
                  (wallThickness + 2),
                  (hopperDepth - baseThickness + 1)]);
    }
}

hopper();
