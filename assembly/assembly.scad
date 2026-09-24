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
// Only things with no source file are modelled locally: the motor, the
// induction coil, the thumbscrew and the cases. Those are rough stand-ins for
// visualisation, not parts to print.

include <../cad/feeder/sharedDims.scad>

/* [Angles] */
// The drop bore is rotated -BORE_ANGLE in hopper.scad, so the discharge leaves
// at (FEEDER_TILT - BORE_ANGLE) off vertical. Equal values = dead vertical.
FEEDER_TILT = 45;   // how far the feeder leans back
FEEDER_SPIN = 90;   // feeder rotation about its own discharge, vs the funnel arm
BORE_ANGLE  = 45;   // MUST match the rotate() on hopper.scad's drop hole

/* [Vertical spacings] */
dropToFunnelRim = 18;   // discharge exit down to the funnel's top rim
funnelToCoil    = 15;   // funnel exit down to the centre of the coil
funnelToCase    = 50;   // funnel exit down to the case base / thumbscrew top
caseToArm       = 16;   // case base down to the top face of the horn arm

/* [Induction coil mock] */
coilTurns = 4;
coilID    = 26;
coilTube  = 4;
coilPitch = 5;

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

/* [Display] */
showCases   = true;
showMotor   = true;
showCoil    = true;
showFunnel  = true;
showArm     = true;
hopperAlpha = 0.35;   // 1 = solid; lower to see the wheel and motor through it

// ---------------------------------------------------------------------------
// Values duplicated from hopper.scad
//
// These are derived inside hopper.scad rather than living in sharedDims.scad,
// so this file has to mirror them. If you ever hoist them into sharedDims,
// delete this block and the duplication goes away.
// ---------------------------------------------------------------------------
motorCenterX = 0.5 * hopperWidth;
motorCenterY = -0.35 * singulatorDiameter;
dropHoleSize = 30;
boreOffsetY  = -dropHoleSize / 4;    // the drop hole's lateral offset

chordLength = singulatorDiameter * sin(singulatorExposureAngle/2);
angleX      = (hopperWidth - chordLength) / 2;
angleY      = angleX / tan(feedAngle);

// ---------------------------------------------------------------------------
// Derived layout -- nothing below here should need touching
// ---------------------------------------------------------------------------
chuteY = motorCenterY - singulatorDiameter/2;
// where the bore crosses the base plate, allowing for its lateral offset
exitY  = chuteY + boreOffsetY / cos(BORE_ANGLE);

// discharge exit in world; also the pivot the feeder spins about, so the drop
// stays put while the feeder turns
pivX = motorCenterX;
pivY = exitY * cos(FEEDER_TILT);
pivZ = exitY * sin(FEEDER_TILT);

// fall direction after the tilt, then after the spin
fallY = sin(FEEDER_TILT - BORE_ANGLE);
fallZ = -cos(FEEDER_TILT - BORE_ANGLE);
dirX  = -sin(FEEDER_SPIN) * fallY;
dirY  =  cos(FEEDER_SPIN) * fallY;

// lowest point of the hopper, so the funnel always clears it
hopperLowZ = (motorCenterY - (singulatorDiameter/2 + wallThickness + 1.5)) * sin(FEEDER_TILT);

funnelRimZ = min(hopperLowZ, pivZ) - dropToFunnelRim;
tToRim     = (funnelRimZ - pivZ) / fallZ;   // follow the drop down to the rim
axisX      = pivX + tToRim * dirX;          // funnel sits where the drop lands
axisY      = pivY + tToRim * dirY;

funnelZ   = funnelRimZ - funnelHeight;      // funnel's local origin is its exit
coilZ     = funnelZ - funnelToCoil;
caseBaseZ = funnelZ - funnelToCase;
armTopZ   = caseBaseZ - caseToArm;
armBotZ   = armTopZ - supportThickness;

servoY = axisY + clDist + servoBackset;     // funnel arm to the wall, then the backset

// ---------------------------------------------------------------------------
// The real parts, pulled straight from their own files
// ---------------------------------------------------------------------------
// hopper.scad and shaftAdapter.scad are wrapped as modules in their own files,
// because they `use <catchnhole>` -- and a nested `use` resolves relative to
// whichever file pulls it in, so including them from here can't find it.
use <../cad/feeder/hopper.scad>;        // provides hopper()
use <../cad/feeder/shaftAdapter.scad>;  // provides shaftAdapter()

// The other three have no nested `use`, so they can be pulled straight in.
// If you ever add a `use <...>` to one of them it'll break here, and will need
// the same module wrapper that hopper/shaftAdapter have.
module part_singulator() { include <../cad/feeder/singulator.scad>; }
module part_funnel()     { include <../cad/feeder/funnel.scad>; }
module part_hornMount()  { include <../cad/feeder/hornMount.scad>; }

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
// if the hopper gets resized.
module mock_pile() {
    crownY = motorCenterY + singulatorDiameter/2;
    inset  = wallThickness / cos(feedAngle) + caseBodyD/2 + 1;
    for (r = [0 : 5])
        for (c = [-5 : 5]) {
            y = crownY + 5 + r * 8.5;
            x = motorCenterX + c * 10 + (r % 2) * 5;
            leftWall = (y < angleY) ? angleX * (1 - y/angleY) : 0;
            if (x > leftWall + inset
             && x < hopperWidth - leftWall - inset
             && y < hopperHeight - wallThickness - caseBodyD/2 - 1)
                translate([x, y, baseThickness]) mock_case();
        }
}

// ---------------------------------------------------------------------------
// Assembly
// ---------------------------------------------------------------------------

// Feeder: leans back, then spins about its own discharge so the drop stays put
translate([pivX, pivY, 0])
 rotate([0, 0, FEEDER_SPIN])
  translate([-pivX, -pivY, 0])
   rotate([FEEDER_TILT, 0, 0]) {
        color("Gainsboro", hopperAlpha) hopper();

        if (showMotor)
            color([0.13,0.13,0.15])
                translate([motorCenterX, motorCenterY, 0]) mock_motor();

        color("DarkViolet")
            translate([motorCenterX, motorCenterY, baseThickness - 1]) shaftAdapter();

        color("RoyalBlue")
            translate([motorCenterX, motorCenterY, baseThickness]) part_singulator();

        if (showCases) {
            color("Goldenrod") mock_pile();
            color("Red")   // one sitting in a wheel pocket at the top of rotation
                translate([motorCenterX,
                           motorCenterY + singulatorDiameter/2 - caseCutout/2,
                           baseThickness]) mock_case();
        }
   }

// Everything below hangs on the funnel's vertical axis
if (showFunnel)
    color("LightSteelBlue", 0.55) translate([axisX, axisY, funnelZ]) part_funnel();

if (showCoil)
    color("Peru") translate([axisX, axisY, coilZ]) mock_coil();

color("Goldenrod") translate([axisX, axisY, caseBaseZ]) mock_case();

if (showArm)
    color("SeaGreen")
        translate([axisX, servoY, armBotZ]) rotate([0, 0, -90]) part_hornMount();

translate([axisX, axisY, 0]) mock_thumbscrew();
