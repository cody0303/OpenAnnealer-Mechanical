// OpenAnnealer -- full machine assembly preview.
//
// Open this file and hit F5. It pulls the real part files in from cad/feeder/,
// so it always reflects whatever the parts currently are: edit hopper.scad or
// singulator.scad and this updates with them. Nothing here is a copy of a part.
//
// Lives in assembly/ rather than cad/ on purpose -- the release workflow runs
// `find cad -name "*.scad"` and renders every hit to STL, and this is a
// view-only file, not a part. Don't export it.
//
// Only things with no source file are modelled locally: the motor, servo,
// induction coil, thumbscrew, grommet and the cases. Those are rough stand-ins
// for visualisation, not parts to print.
//
// Where everything sits comes from cad/feeder/layout.scad, which the side
// panel shares, so the panel's holes always land on the parts. The world
// frame is described there: Z is the drop axis, the funnel arm points +Y to
// the cabinet wall. Stack spacings are in sharedDims.
//
// feederSide flips the unit left/right. It does it by turning the feeder
// +/-90 deg about the drop axis, not by mirroring: the hopper is symmetric
// with mounting on both sides, so the same printed parts build either hand.

include <../cad/feeder/layout.scad>

/* [Feeder] */
/* The feeder leans back by mountAngle and the drop bore is cut at mountAngle
   (both from sharedDims), so the discharge always falls dead vertical.
*/
// which side of the stack the feeder sits, seen from outside the cabinet
feederSide = "left";  // [left, right]

/* [Induction coil mock] */
coilTurns = 4;
coilID    = 26;
coilPitch = 5;          // tube OD and the leads' spacing are in sharedDims

/* [Thumbscrew mock] */
thumbHeadD = 14;
thumbHeadH = 7;
nutAcross  = 9.2;
nutH       = 4;

/* [Mock case -- .223 Rem] */
caseLen      = 44.7;
caseBodyD    = 9.5;
caseNeckD    = 6.4;
caseShoulder = 32;
caseNeck     = 38;

/* [Coil leads mock] */
leadIntoCabinet = 40;   // how far the leads run on past the wall's inner face

/* [Display] */
showCases   = true;
showMotor   = true;
showCoil    = true;
showFunnel  = true;
showArm     = true;
showCabinet = true;
hopperAlpha = 0.35;   // 1 = solid; lower to see the wheel and motor through it
funnelAlpha = 1;
cabinetAlpha = 1;     // lower to see the leads and servo inside

// +1 puts the feeder on -X (left, seen from outside), -1 on +X
hand       = (feederSide == "right") ? -1 : 1;
feederSpin = 90 * hand;     // turns the hopper's +/-X side square to the wall

coilR = coilID/2 + coilTube/2;              // coil tube centreline radius

// ---------------------------------------------------------------------------
// The real parts, pulled straight from their own files
// ---------------------------------------------------------------------------
// These are wrapped as modules in their own files and pulled in with `use`.
// hopper, shaftAdapter, funnel and servoMount have to be: they `use
// <catchnhole>` themselves, and a nested `use` resolves relative to whichever
// file pulls it in, so `include`-ing them from here can't find it.
use <../cad/feeder/hopper.scad>;        // provides hopper()
use <../cad/feeder/shaftAdapter.scad>;  // provides shaftAdapter()
use <../cad/feeder/funnel.scad>;        // provides funnel()
use <../cad/cabinet/servoMount.scad>;   // provides servoMount()
use <../cad/cabinetFlat/sidePanel.scad>; // provides sidePanel(), lead_hole_2d()

// The other two have no nested `use`, so they can be pulled straight in.
// If you ever add a `use <...>` to one of them it'll break here, and will need
// the same module wrapper as the ones above.
module part_singulator() { include <../cad/feeder/singulator.scad>; }
module part_hornMount()  { include <../cad/feeder/hornMount.scad>; }

// Takes children drawn in hopper.scad's own frame and puts them in the world:
// lean back, slide the bore exit onto the origin, then spin about the drop axis.
module in_feeder_frame() {
    rotate([0, 0, feederSpin])
     translate([0, -exitTiltY, -exitTiltZ])
      rotate([mountAngle, 0, 0])
        children();
}

// ---------------------------------------------------------------------------
// Stand-ins for things with no source file
// ---------------------------------------------------------------------------
module mock_case() {
    cylinder(d = caseBodyD, h = caseShoulder);
    translate([0,0,caseShoulder])
        cylinder(d1 = caseBodyD, d2 = caseNeckD, h = caseNeck - caseShoulder);
    translate([0,0,caseNeck]) cylinder(d = caseNeckD, h = caseLen - caseNeck);
}

// NEMA17. Z=0 is the motor face; body hangs below, shaft above.
module mock_motor(shaftLen = 24) {
    translate([-21.15,-21.15,-40]) cube([42.3, 42.3, 40]);
    cylinder(d = 22, h = 2);
    cylinder(d = shaftDia, h = shaftLen);
}

module mock_coil() {
    for (i = [0 : coilTurns - 1])
        translate([0, 0, i*coilPitch - (coilTurns-1)*coilPitch/2])
            rotate_extrude() translate([coilID/2 + coilTube/2, 0]) circle(d = coilTube);
}

// A copper tube run through a list of points.
module tube_path(pts, d) {
    for (i = [0 : len(pts) - 2])
        hull() {
            translate(pts[i])     sphere(d = d, $fn = 24);
            translate(pts[i + 1]) sphere(d = d, $fn = 24);
        }
}

// The two coil leads: each leaves its end turn tangentially, heading for the
// wall, closes up to leadGap, then runs straight through the grommet.
module mock_leads() {
    for (s = [1, -1]) {
        turnZ = coilZ + s * (coilTurns - 1) * coilPitch / 2;
        tube_path([
            [s * coilR,     0,              turnZ],
            [s * coilR,     coilR + 5,      turnZ],
            [s * leadGap/2, coilR + 20,     leadZ],
            [s * leadGap/2, clDist + cabinetWallThk + leadIntoCabinet, leadZ]
        ], coilTube);
    }
}

// Rubber grommet in the lead hole, lipped on both faces of the wall.
module mock_grommet() {
    translate([0, clDist - 1.5, leadZ]) rotate([-90, 0, 0])
        linear_extrude(cabinetWallThk + 3)
            difference() { lead_hole_2d(grommetLip); lead_hole_2d(0); }
    for (y = [clDist - 1.5, clDist + cabinetWallThk])
        translate([0, y, leadZ]) rotate([-90, 0, 0])
            linear_extrude(1.5)
                difference() { lead_hole_2d(2 * grommetLip); lead_hole_2d(0); }
}

// MG90S, output shaft on the origin pointing up, top of the case at z = 0.
// End-on to the wall: the short end is toward -Y, the case runs off along +Y.
module mock_servo() {
    translate([-servoBodyW/2, -servoShaftToEnd, -servoBodyH])
        cube([servoBodyW, servoBodyL, servoBodyH]);                    // case
    translate([-servoBodyW/2, servoBodyL/2 - servoShaftToEnd - servoEarSpan/2,
               -servoEarDrop - servoEarThk])
        cube([servoBodyW, servoEarSpan, servoEarThk]);                 // mounting ears
    cylinder(d = 11.8, h = 1.5, $fn = 48);                            // top boss
    cylinder(d = 4.8,  h = 4,   $fn = 24);                            // spline
}

// COTS thumbscrew, head up: the case stands on the flat top of the knurled
// head. The shank runs down through the arm and stop nuts jam either side of
// it to set how high the case sits in the coil.
module mock_thumbscrew() {
    color("Silver") {
        translate([0,0,caseBaseZ - thumbHeadH]) cylinder(d = thumbHeadD, h = thumbHeadH);
        translate([0,0,armBotZ - 10])
            cylinder(d = supportScrewSize,
                     h = (caseBaseZ - thumbHeadH) - (armBotZ - 10));
    }
    color("DimGray") {
        translate([0,0,armTopZ])        cylinder(d = nutAcross, h = nutH, $fn = 6);
        translate([0,0,armBotZ - nutH]) cylinder(d = nutAcross, h = nutH, $fn = 6);
    }
}

// A loose pile standing on the pan floor and the wheel's exposed crown.
// Cosmetic only, but generated rather than hardcoded so it still looks sane
// if the hopper gets resized. Laid out in the hopper outline's own frame
// (corner at the origin), then shifted the same way hopper.scad shifts it.
module mock_pile() {
    crownY = singulatorDiameter/2 - hopperYshift;
    inset  = wallThickness / cos(hopperConvergeAngle) + caseBodyD/2 + 1;
    translate([hopperXshift, hopperYshift, baseThickness])
        for (r = [0 : 5])
            for (c = [-5 : 5]) {
                y = crownY + 5 + r * 8.5;
                x = hopperWidth/2 + c * 10 + (r % 2) * 5;
                leftWall = (y < angleY) ? angleX * (1 - y/angleY) : 0;
                if (x > leftWall + inset
                 && x < hopperWidth - leftWall - inset
                 && y < hopperHeight - wallThickness - caseBodyD/2 - 1)
                    translate([x, y, 0]) mock_case();
            }
}

// ---------------------------------------------------------------------------
// Assembly
// ---------------------------------------------------------------------------

in_feeder_frame() {
        color("Gainsboro", hopperAlpha) hopper();

        if (showMotor)
            color([0.13,0.13,0.15]) mock_motor();

        color("DarkViolet") translate([0, 0, baseThickness - 1]) shaftAdapter();

        color("RoyalBlue") translate([0, 0, baseThickness]) part_singulator();

        if (showCases) {
            color("Goldenrod") mock_pile();
            color("Red")   // one sitting in a wheel pocket at the top of rotation
                translate([0, singulatorDiameter/2 - caseCutout/2, baseThickness])
                    mock_case();
        }
  }

// Everything below hangs on the drop axis
if (showFunnel)
    color("LightSteelBlue", funnelAlpha) translate([0, 0, funnelZ]) funnel();

if (showCoil)
    color("Peru") translate([0, 0, coilZ]) mock_coil();

if (showCases)
    color("Goldenrod") translate([0, 0, caseBaseZ]) mock_case();

if (showArm) {
    color("SeaGreen") translate([0, servoY, armBotZ]) rotate([0, 0, -90]) part_hornMount();
    // servo sits inside the cabinet, end-on to the wall, horn flat under the arm
    color("MidnightBlue") translate([0, servoY, servoTopZ]) mock_servo();
    color("Orchid") translate([0, servoY, servoMountTopZ]) servoMount();
}

mock_thumbscrew();

if (showCoil)
    color("Peru") mock_leads();

if (showCabinet) {
    // the panel is drawn flat in its own file; stand it up with its outer face
    // on y = clDist. A right-hand build is the same sheet turned over.
    color([0.62, 0.65, 0.70], cabinetAlpha)
        mirror([hand < 0 ? 1 : 0, 0, 0])
            translate([0, clDist + cabinetWallThk, 0]) rotate([90, 0, 0]) sidePanel();
    color([0.1, 0.1, 0.1]) mock_grommet();
}
