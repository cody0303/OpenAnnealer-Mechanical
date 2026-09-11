// Hopper -- wide mouth for dumping cases in loose, narrowing to sit over the
// singulator disk's front face. This part is explicitly non-precision (see
// docs/DESIGN.md): unlike the disk/face-plate/hub interface, nothing here
// needs a tight fit, so treat these numbers as a starting point for bench
// iteration on pickup reliability (hopper angle, mouth size), not a fixed
// spec.
//
// Modeled as a simple truncated 4-sided pyramid (funnel), open at both ends:
// wide at the top (loading mouth) narrowing to the bottom (sits over the
// disk). In the full assembly this whole shape mounts tilted ~45 degrees --
// see feeder_assembly.scad.
//
// Open this file directly in OpenSCAD to preview just the hopper.

include <../lib/dimensions.scad>

HOPPER_BOTTOM_W = DISK_OD + 10;   // bottom opening -- covers the disk's front face
HOPPER_TOP_W    = HOPPER_BOTTOM_W + 80;  // top (loading) opening -- wide enough to dump a handful of cases in
HOPPER_HEIGHT   = 100;
HOPPER_WALL_T   = 2.5;

module hopper_shell(bottom_w, top_w, height, wall_t) {
    difference() {
        hull() {
            cube([bottom_w, bottom_w, 0.01], center = true);
            translate([0, 0, height])
                cube([top_w, top_w, 0.01], center = true);
        }
        hull() {
            translate([0, 0, -1])
                cube([bottom_w - 2*wall_t, bottom_w - 2*wall_t, 1], center = true);
            translate([0, 0, height + 1])
                cube([top_w - 2*wall_t, top_w - 2*wall_t, 1], center = true);
        }
    }
}

module hopper() {
    hopper_shell(HOPPER_BOTTOM_W, HOPPER_TOP_W, HOPPER_HEIGHT, HOPPER_WALL_T);
}

hopper();
