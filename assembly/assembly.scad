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

/* [Cabinet side mock] */
/* The wall's outer face is the plane y = clDist, where the funnel arm ends.
   The cabinet interior is +Y. servoBackset is measured from this outer face,
   so the servo body only clears the wall while cabinetWallThk < ~3.9.
*/
cabinetWallThk  = 3;
cabinetLeft     = 170;  // panel extent past the drop axis, feeder side (-X)
cabinetRight    = 110;  // ...and the other side (+X)
cabinetAbove    = 160;  // panel top, above the funnel rim
cabinetBelow    = 50;   // panel bottom, below the horn arm
armSlotW        = 44;   // slot the horn arm swings through
armSlotClear    = 2;    // above and below the arm, in that slot
leadGap         = 12;   // centre-to-centre of the coil leads at the wall
leadIntoCabinet = 40;   // how far the leads run on past the wall's inner face
grommetLip      = 2.5;

/* [Feeder bracket mock] */
/* A standoff filling the gap between the hopper's side and the wall, shaped
   to the hopper where it touches. Assumes FEEDER_SPIN = 90, which is what
   puts the hopper's +X side square to the wall.
*/
bracketFromY = -25;     // hopper frame: how far down the boss the bracket starts
bracketH     = 40;      // hopper frame: height up off the base plate underside
bracketBolts = 3;       // bolts through into the wall

/* [Display] */
showCases   = true;
showMotor   = true;
showCoil    = true;
showFunnel  = true;
showArm     = true;
showCabinet = true;
showBracket = true;
hopperAlpha = 0.35;   // 1 = solid; lower to see the wheel and motor through it
funnelAlpha = 1;
cabinetAlpha = 1;     // lower to see the leads and servo inside

// ---------------------------------------------------------------------------
// Values duplicated from hopper.scad
//
// These live inside hopper.scad rather than sharedDims.scad, so this file has
// to mirror them (the case pile and the bracket use them). Hoist them into
// sharedDims and this block can go.
// ---------------------------------------------------------------------------
hopperXshift = -hopperWidth/2;
hopperYshift = 0.35 * singulatorDiameter;
chordLength  = singulatorDiameter * sin(singulatorExposureAngle/2);
angleX       = (hopperWidth - chordLength) / 2;
angleY       = angleX / tan(hopperConvergeAngle);
hopperPoints = [[0, angleY], [0, hopperHeight], [hopperWidth, hopperHeight],
                [hopperWidth, angleY], [hopperWidth - angleX, 0], [angleX, 0]];
bossD        = singulatorDiameter + 2*wallThickness + 3;

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

coilR  = coilID/2 + coilTube/2;             // coil tube centreline radius
leadZ  = coilZ;                             // height the leads pass the wall at

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

// Takes children drawn in hopper.scad's own frame and puts them in the world:
// lean back, slide the bore exit onto the origin, then spin about the drop axis.
module in_feeder_frame() {
    rotate([0, 0, FEEDER_SPIN])
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

// The lead pass-through: a slotted hole, grown by d.
module lead_hole_2d(d = 0) {
    hull() for (s = [1, -1])
        translate([s * leadGap/2, 0]) circle(d = coilTube + 2 + 2*d, $fn = 48);
}

// Flat side panel of the cabinet, outer face at y = clDist.
module mock_cabinet_wall() {
    bot = armBotZ - cabinetBelow;
    difference() {
        translate([-cabinetLeft, clDist, bot])
            cube([cabinetLeft + cabinetRight, cabinetWallThk, funnelRimZ + cabinetAbove - bot]);

        // slot the horn arm swings through
        translate([-armSlotW/2, clDist - 1, armBotZ - armSlotClear])
            cube([armSlotW, cabinetWallThk + 2, supportThickness + 2*armSlotClear]);

        // lead pass-through, sized for the grommet
        translate([0, clDist - 1, leadZ]) rotate([-90, 0, 0])
            linear_extrude(cabinetWallThk + 2) lead_hole_2d(grommetLip);

        // screws into the end of the funnel arm
        for (i = [1 : funnelMountHoleCount])
            translate([0, clDist - 1, funnelZ + funnelHeight * i / (funnelMountHoleCount + 1)])
                rotate([-90, 0, 0]) cylinder(d = 4.5, h = cabinetWallThk + 2, $fn = 24);

        // the feeder bracket's bolts
        if (showBracket) in_feeder_frame() mock_bracket_bolts();
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

// Standoff from the hopper's side to the wall, in the hopper's own frame
// (where the wall face is x = clDist). A block cut back by the hopper's solid
// envelope -- outline plus retaining-wall boss -- so it seats on whatever it
// touches, with bolts running out through the wall.
module mock_bracket() {
    difference() {
        translate([0, bracketFromY, 0])
            cube([clDist, hopperHeight + hopperYshift - bracketFromY, bracketH]);

        translate([hopperXshift, hopperYshift, -1])
            linear_extrude(bracketH + 2) polygon(hopperPoints);
        translate([0, 0, -1]) cylinder(d = bossD, h = bracketH + 2);
    }
}

module mock_bracket_bolts() {
    span = hopperHeight + hopperYshift - bracketFromY;
    for (i = [1 : bracketBolts])
        translate([clDist - 12, bracketFromY + span * i / (bracketBolts + 1), bracketH/2])
            rotate([0, 90, 0]) {
                cylinder(d = 5, h = 12 + cabinetWallThk + 4, $fn = 24);   // shank
                translate([0, 0, 12 + cabinetWallThk])
                    cylinder(d = 9.2, h = 4, $fn = 6);                    // nut inside
            }
}

// MG90S, output shaft on the origin pointing up, top of the case at z = 0.
module mock_servo() {
    translate([-6.1, -6.1, -22.7]) cube([22.8, 12.2, 22.7]);           // case
    translate([-10.8, -6.1, -6.5]) cube([32.2, 12.2, 2.5]);            // mounting ears
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

        if (showBracket) {
            color("DarkOrange") mock_bracket();
            color("DimGray") mock_bracket_bolts();
        }
  }

// Everything below hangs on the drop axis
if (showFunnel)
    color("LightSteelBlue", funnelAlpha) translate([0, 0, funnelZ]) part_funnel();

if (showCoil)
    color("Peru") translate([0, 0, coilZ]) mock_coil();

if (showCases)
    color("Goldenrod") translate([0, 0, caseBaseZ]) mock_case();

if (showArm) {
    color("SeaGreen") translate([0, servoY, armBotZ]) rotate([0, 0, -90]) part_hornMount();
    // servo sits inside the cabinet, horn flat under the arm
    color("MidnightBlue") translate([0, servoY, armBotZ - 2]) mock_servo();
}

mock_thumbscrew();

if (showCoil)
    color("Peru") mock_leads();

if (showCabinet) {
    color([0.62, 0.65, 0.70], cabinetAlpha) mock_cabinet_wall();
    color([0.1, 0.1, 0.1]) mock_grommet();
}
