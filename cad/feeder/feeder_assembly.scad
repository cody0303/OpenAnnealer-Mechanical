// Combined preview of the feeder: hopper -> singulator wheel -> shroud ->
// back plate -> drive hub. Open THIS file in OpenSCAD to sanity-check how the
// parts relate; open an individual part file to work on just that part.
//
// Visualization/fit-check aid, not something to print or export as one STL --
// print each part from its own file.
//
// --- How it works -----------------------------------------------------------
// Cases stand base-down on the back plate, sticking out the hopper's open
// front. The pan leans back, so the pile slides down the plate and the
// hopper's converging sides funnel it into the bottom outlet. The wheel's rim
// sits in that outlet -- its cylindrical SIDE is the floor the bottom of the
// pile rests on. A half-round scallop coming round takes one case off the
// pile; the shroud holds it in while the wheel carries it round; at the
// shroud's end the case is released and drops through the back plate's
// discharge hole into the chute.
//
// --- Coordinate bookkeeping -------------------------------------------------
//   Z = the wheel's axis. Assembly Z=0 is the back plate's FRONT face, i.e.
//   the surface case bases ride on.
//
//   z = -BACKPLATE_THICKNESS - GAP : hub's front face (boss/pins start here)
//   z = -BACKPLATE_THICKNESS .. 0  : back plate
//   z = GAP .. GAP + DISK_THICKNESS: wheel (running clear of the plate)
//   z = 0 upward                   : cases, standing on the plate
//
// The back plate is mirrored on placement because its own local Z runs front
// to back, opposite to assembly Z here.
//
// The whole thing is then tilted at the end to preview the real installed
// orientation. The chute and coil below aren't modeled yet.

include <../lib/dimensions.scad>
use <../lib/case_model.scad>
use <drive_hub.scad>
use <singulator_disk.scad>
use <back_plate.scad>
use <shroud.scad>
use <hopper.scad>

GAP = BACKPLATE_CLEARANCE_GAP;

ASSEMBLY_TILT_DEG = 45;

SHOW_CASES = true;   // set false for a clean view of the printed parts alone

// Cases resting on the wheel's crown and stacked up the hopper, all lying
// parallel to the wheel's axis. Positions are eyeballed for the preview.
CASE_POSITIONS = [
    [-10, 28], [0, 30], [10, 28],
    [-15, 37], [-5, 38], [5, 38], [15, 37],
    [-20, 46], [-10, 47], [0, 47], [10, 47], [20, 46],
    [-25, 55], [-15, 56], [-5, 56], [5, 56], [15, 56], [25, 55],
    [-20, 65], [-10, 65], [0, 65], [10, 65], [20, 65],
];

module feeder_assembly() {
    rotate([ASSEMBLY_TILT_DEG, 0, 0]) {

        color("SlateGray")
            translate([0, 0, -BACKPLATE_THICKNESS - GAP])
                drive_hub();

        color("DimGray")
            mirror([0, 0, 1])
                back_plate();

        color("SteelBlue")
            translate([0, 0, GAP])
                singulator_disk();

        color("Gainsboro")
            translate([0, 0, GAP])
                shroud();

        // The pan's bottom edge sits so the wheel's rim stands proud of it by
        // RIM_INTRUSION; its base plate is coplanar with the back plate's
        // front face, so case bases sit on one continuous floor. (In a real
        // build these two would likely merge into one printed part.)
        color("Wheat", 0.6)
            translate([-HOPPER_WIDTH/2, DISK_OD/2 - RIM_INTRUSION, -HOPPER_BASE_T])
                hopper();

        if (SHOW_CASES) {
            color("Goldenrod")
                for (p = CASE_POSITIONS)
                    translate([p[0], p[1], 0])
                        case_model();

            // One case captured in a scallop, part way round to the discharge
            color("OrangeRed")
                rotate([0, 0, 170])
                    translate([POCKET_ORBIT_R, 0, 0])
                        case_model();
        }
    }
}

feeder_assembly();
