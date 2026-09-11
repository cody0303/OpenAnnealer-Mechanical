// Small reusable helper modules shared across the feeder parts.
// Include dimensions.scad before this if a module needs one of its constants
// (none currently do -- these are pure geometry helpers).

// 2D profile of a D-shaft: a circle of diameter `d` with a flat cut `flat_depth`
// in from the edge. Extrude this to cut a D-shaft hole, or use it solid to
// model the shaft itself for a fit check.
module dshaft_2d(d, flat_depth) {
    r = d / 2;
    intersection() {
        circle(d = d);
        translate([-r - 1, -(r - flat_depth), 0])
            square([2 * r + 2, 2 * r + 2]);
    }
}

// 3D D-shaft hole, centered on the Z axis, extruded along Z, centered in Z.
module dshaft_hole(d, flat_depth, length) {
    linear_extrude(height = length, center = true)
        dshaft_2d(d, flat_depth);
}

// Places `count` copies of its children evenly around a circle of radius `r`,
// starting at `start_angle`. Each child is translated (not rotated) to its
// position -- use this for pins/magnet pockets that don't need to face inward.
module orbit(r, count, start_angle = 0) {
    for (i = [0 : count - 1]) {
        a = start_angle + i * 360 / count;
        translate([r * cos(a), r * sin(a), 0])
            children();
    }
}
