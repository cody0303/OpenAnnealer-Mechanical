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
//
// World frame: the Z axis IS the drop axis. The funnel, coil, case and
// thumbscrew all sit on it at x = y = 0, and z = 0 is where the drop bore's
// centreline crosses the hopper's base plane. The funnel arm points +Y,
// toward the cabinet wall.

include <../cad/feeder/sharedDims.scad>

/* [Feeder] */
/* The feeder leans back by mountAngle and the drop bore is cut at mountAngle
   (both from sharedDims), so the discharge always falls dead vertical.
*/
FEEDER_SPIN = 90;   // feeder rotation about the drop axis, vs the funnel arm

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
funnelAlpha = 1;

// ---------------------------------------------------------------------------
// Values duplicated from hopper.scad
//
// These live inside hopper.scad rather than sharedDims.scad, so this file has
// to mirror them (only the case pile uses them). Hoist them into sharedDims
// and this block can go.
// ---------------------------------------------------------------------------
hopperXshift = -hopperWidth/2;
hopperYshift = 0.35 * singulatorDiameter;
chordLength  = singulatorDiameter * sin(singulatorExposureAngle/2);
angleX       = (hopperWidth - chordLength) / 2;
angleY       = angleX / tan(hopperConvergeAngle);

// ---------------------------------------------------------------------------
// Derived layout -- nothing below here should need touching
// ---------------------------------------------------------------------------
// In the hopper's frame (origin on the motor axis, base plate underside at
// z = 0) the bore's centreline crosses the base plane here, allowing for the
// hole's dropHoleSize/4 offset.
exitY = -singulatorDiameter/2 - (dropHoleSize/4) / cos(mountAngle);

// ...and where that point ends up once the feeder leans back
exitTiltY = exitY * cos(mountAngle);
exitTiltZ = exitY * sin(mountAngle);

funnelRimZ = -dropToFunnelRim;
funnelZ    = funnelRimZ - funnelHeight;     // funnel's local origin is its exit
coilZ      = funnelZ - funnelToCoil;
caseBaseZ  = funnelZ - funnelToCase;
armTopZ    = caseBaseZ - caseToArm;
armBotZ    = armTopZ - supportThickness;

servoY = clDist + servoBackset;             // funnel arm to the wall, then the backset

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

// Feeder: lean back, slide the bore exit onto the origin, then spin about the
// drop axis. Everything inside the braces is in hopper.scad's own frame.
rotate([0, 0, FEEDER_SPIN])
 translate([0, -exitTiltY, -exitTiltZ])
  rotate([mountAngle, 0, 0]) {
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
    color("LightSteelBlue", funnelAlpha) translate([0, 0, funnelZ]) part_funnel();

if (showCoil)
    color("Peru") translate([0, 0, coilZ]) mock_coil();

if (showCases)
    color("Goldenrod") translate([0, 0, caseBaseZ]) mock_case();

if (showArm)
    color("SeaGreen") translate([0, servoY, armBotZ]) rotate([0, 0, -90]) part_hornMount();

mock_thumbscrew();
