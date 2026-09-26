// Shared by the cabinet's flat faces (cad/cabinetFlat/). A face is a list of
// features in its own 2D frame, in mm, seen from outside the cabinet; the
// first is its outline and the rest are cut out of it:
//   ["rrect",  x, y, w, h, r]   rectangle, corner at x,y, corners rounded r
//   ["rect",   x, y, w, h]      rectangle, corner at x,y
//   ["slot",   cx, cy, s, r]    obround: two radius-r ends, centres cx+/-s
//   ["vslot",  cx, cy, s, r]    the same, upright: centres cy+/-s
//   ["circle", cx, cy, d]
// tools/export_panel_dxf.py writes the same list to a DXF, so a cut file
// always matches the part. Extruded, a face's outside is its z = t side.
// `use` this file; it has no geometry of its own.

module feature_2d(f) {
    if (f[0] == "rrect")
        translate([f[1], f[2]])
            offset(r=f[5]) offset(delta=-f[5]) square([f[3], f[4]]);
    else if (f[0] == "rect")
        translate([f[1], f[2]]) square([f[3], f[4]]);
    else if (f[0] == "slot")
        hull() for (s = [1, -1]) translate([f[1] + s*f[3], f[2]]) circle(r=f[4]);
    else if (f[0] == "vslot")
        hull() for (s = [1, -1]) translate([f[1], f[2] + s*f[3]]) circle(r=f[4]);
    else if (f[0] == "circle")
        translate([f[1], f[2]]) circle(d=f[3]);
}

module features_2d(fs) {
    difference() {
        feature_2d(fs[0]);
        for (i = [1 : len(fs) - 1]) feature_2d(fs[i]);
    }
}

module flat_part(fs, t) {
    linear_extrude(height=t) features_2d(fs);
}

// One printing tile of a face taller than the printer bed: "upper" or "lower"
// of a horizontal split at y = split. The two meet in a half-lap lap tall --
// the upper tile keeps the outer half, the lower the inner -- glued, and
// bolted through (M3, nuts inside) at the xs along the split.
module flat_tile(fs, t, split, lap, which, xs = [], boltD = 3.4) {
    l = lap/2;
    difference() {
        intersection() {
            flat_part(fs, t);
            if (which == "upper") union() {
                translate([-1000, split + l, -1]) cube([2000, 1000, t + 2]);
                translate([-1000, split - l, t/2]) cube([2000, 2*l + 0.01, t]);
            } else union() {
                translate([-1000, split - l - 1000, -1]) cube([2000, 1000, t + 2]);
                translate([-1000, split - l - 0.01, -1]) cube([2000, 2*l + 0.01, 1 + t/2]);
            }
        }
        for (x = xs) translate([x, split, -1]) cylinder(d=boltD, h=t + 2, $fn=24);
    }
}

// A face seen from its other side: its features mirrored across x = 0 (a
// right-hand build's faces are the left-hand ones' mirror images).
function mirror_features(fs) = [for (f = fs)
    f[0] == "rrect" ? ["rrect", -f[1] - f[3], f[2], f[3], f[4], f[5]]
  : f[0] == "rect"  ? ["rect",  -f[1] - f[3], f[2], f[3], f[4]]
  : f[0] == "slot"  ? ["slot",  -f[1], f[2], f[3], f[4]]
  : f[0] == "vslot" ? ["vslot", -f[1], f[2], f[3], f[4]]
  :                   ["circle", -f[1], f[2], f[3]]];

// The export end of a face's own file: its features echoed for the DXF tool,
// the 2D face for a DXF preview, or the part -- as its two printing tiles side
// by side if it's split, else whole.
module flat_export(fs, t, exportDXF, split = undef, lap = 0, xs = [], tile = "tiles") {
    if (exportDXF) features_2d(fs);
    else if (is_undef(split) || tile == "whole") flat_part(fs, t);
    else if (tile == "upper" || tile == "lower") flat_tile(fs, t, split, lap, tile, xs);
    else {
        w = fs[0][3];
        flat_tile(fs, t, split, lap, "upper", xs);
        translate([w + 10, 0, 0]) flat_tile(fs, t, split, lap, "lower", xs);
    }
}
