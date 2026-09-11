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
wallThickness      = HOPPER_WALL_T;
baseThickness      = HOPPER_BASE_T;
hopperHeight       = HOPPER_HEIGHT;
hopperDepth        = HOPPER_DEPTH;
feedAngle          = HOPPER_FEED_ANGLE;
hopperWidth        = HOPPER_WIDTH;
singulatorDiameter = DISK_OD;   // the bottom outlet is a circular notch the wheel's rim sits in
rimIntrusion       = RIM_INTRUSION;

// Triangle cutout that converges the lower sides down to the outlet
angleY = 0.3 * hopperHeight;
angleX = angleY * tan(feedAngle);

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
            // pile. The circle's center sits below the hopper's bottom edge by
            // (radius - rimIntrusion), which is what makes the rim stand proud
            // by exactly rimIntrusion.
            //
            // Two things to watch if you edit this, both of which bit the
            // first draft: linear_extrude takes `height`, not `depth` (with
            // `depth` it silently falls back to a default and warns), and a
            // translate inside linear_extrude acts on a 2D shape, so a Z term
            // there does nothing -- translate the extruded solid instead.
            translate([hopperWidth/2,
                       -(singulatorDiameter/2 - rimIntrusion),
                       baseThickness])
                linear_extrude(height = hopperDepth - baseThickness + 1)
                    circle(d = singulatorDiameter);
        }
        // open the top -- loading
        translate([wallThickness, (hopperHeight - wallThickness) - 1, baseThickness])
            cube([(hopperWidth - (2*wallThickness)),
                  (wallThickness + 2),
                  (hopperDepth - baseThickness + 1)]);
    }
}

hopper();
