// Combined preview of the feeder stack: drive hub -> face plate -> singulator
// disk -> hopper. Open THIS file in OpenSCAD to sanity-check spacing and
// alignment across all four parts at once; open an individual part file to
// work on just that part.
//
// This is a visualization/fit-check aid, not itself something you'd print or
// export as one STL -- print each part from its own file.
//
// --- Coordinate bookkeeping -------------------------------------------------
// Each part file defines its own convenient local Z axis (documented at the
// top of that file). Walking from the hub outward along assembly Z:
//
//   assembly Z = 0                       : hub's front face (boss/pins start here)
//   assembly Z = GAP                     : face plate's back face (hub side)
//   assembly Z = GAP + T_FP              : face plate's front face (disk side)
//   assembly Z = GAP + T_FP + GAP        : disk's back face (hub side)
//   assembly Z = GAP + T_FP + GAP + T_DK : disk's front face (hopper side) -- hopper starts here
//
// The face plate and disk are each mirrored before placement, because their
// own local Z increases from front (disk/hopper side) to back (hub side) --
// the opposite direction from assembly Z, which increases from the hub
// outward. See the mirror+translate pattern below.
//
// The whole stack is then tilted ~45 degrees at the very end to preview the
// real installed orientation (see docs/DESIGN.md / concept_diagram.svg) --
// the coil/holder assembly below the chute isn't modeled yet, so this is
// illustrative only.

include <../lib/dimensions.scad>
use <drive_hub.scad>
use <singulator_disk.scad>
use <face_plate.scad>
use <hopper.scad>

GAP  = FACEPLATE_CLEARANCE_GAP;
T_FP = FACEPLATE_THICKNESS;
T_DK = DISK_THICKNESS;

FACEPLATE_FRONT_Z = GAP + T_FP;
DISK_FRONT_Z      = GAP + T_FP + GAP + T_DK;

ASSEMBLY_TILT_DEG = 45;

module feeder_assembly() {
    rotate([ASSEMBLY_TILT_DEG, 0, 0]) {
        color("SlateGray")
            drive_hub();

        color("DimGray", 0.9)
            translate([0, 0, FACEPLATE_FRONT_Z])
                mirror([0, 0, 1])
                    face_plate();

        color("SteelBlue", 0.9)
            translate([0, 0, DISK_FRONT_Z])
                mirror([0, 0, 1])
                    singulator_disk();

        color("Wheat", 0.6)
            translate([0, 0, DISK_FRONT_Z])
                hopper();
    }
}

feeder_assembly();
