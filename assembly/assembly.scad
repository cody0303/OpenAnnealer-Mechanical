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
// induction coil, thumbscrew, grommets, the cases, the harvested heater's
// parts and the other electronics. Those are rough stand-ins for
// visualisation, not parts to print.
//
// Where everything sits comes from cad/feeder/layout.scad (the feeder stack)
// and cad/cabinet/boxLayout.scad (the box and what's in it), which the parts
// share, so their holes always land on the parts. The world frame is in
// layout.scad: Z is the drop axis, the funnel arm points +Y to the cabinet's
// left panel. The box's front, back, left and right are named in boxLayout.
// Stack spacings are in sharedDims.
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

/* [Mock case -- .338 Lapua Mag, the longest it takes] */
// Approximate. The thumbscrew is raised to put the shoulder/neck junction in
// the middle of the coil. .223 Rem: 44.7, 9.5, 6.4, 32, 38
caseLen      = 69.2;
caseBodyD    = 14.9;
caseNeckD    = 9.5;
caseShoulder = 54.9;    // base to the body/shoulder junction
caseNeck     = 60.9;    // base to the shoulder/neck junction

/* [Coil leads mock] */
leadIntoCabinet = 15;   // how far the leads run on past the wall's inner face, into the heatsinks

/* [Cabinet box] */
/* Flat faces (ply or print, cabinetWallThk thick) -- the left panel
   (cad/cabinetFlat/sidePanel.scad), front, back and right walls, lid and base
   (the other files there) -- screwed into printed corner blocks
   (cad/cabinet/cornerBlock.scad) in the four vertical corners at the base,
   the tile seam and the top. Printed faces split at the seam and meet in a
   half-lap, bolted through with nuts inside. Where everything in and on the
   box sits, and the screen tilt, the harvested heater's pose and the Pico
   board's settings, are in cad/cabinet/boxLayout.scad, which the faces share.
*/
boxCutaway    = false;  // drop the lid, front and right walls to see inside

/* [Display] */
showCases   = true;
showMotor   = true;
showCoil    = true;
showFunnel  = true;
showArm     = true;
showCabinet = true;     // the left panel and the lead grommets
showBox     = true;     // the rest of the cabinet
showElectronics = true;
checkTransformer = false;   // true: draw only where the transformer hits something -- nothing drawn means clear
checkCorners     = false;   // true: draw only where the corner blocks hit the servo, its mount or the swinging arm
armSwing         = 45;      // the arm's swing each way from the drop axis, for checkCorners -- the wall slot limits it
hopperAlpha = 0.35;   // 1 = solid; lower to see the wheel and motor through it
funnelAlpha = 1;
cabinetAlpha = 0.35;     // lower to see the leads and servo inside

// +1 puts the feeder on -X (left, seen from outside), -1 on +X
hand       = (feederSide == "right") ? -1 : 1;
feederSpin = 90 * hand;     // turns the hopper's +/-X side square to the wall

coilR = coilID/2 + coilTube/2;              // coil tube centreline radius
// the mock case's base: shoulder/neck junction mid-coil, no lower than the
// thumbscrew goes
caseSeatZ = max(caseBaseZ, coilZ - caseNeck);

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
use <../cad/cabinet/heatsinkHolder.scad>; // provides heatsinkHolder(), heatsinkHolderSize(), heatsinkHolderBackset()
use <../cad/cabinet/transformerCradle.scad>; // provides transformerCradle(), transformerCradleFit()
use <../cad/cabinet/fanAdapter.scad>;    // provides fanAdapter(), on_seat(), fanAdapterMaxX(), fanAdapterMinX(), fanAdapterScrews(), fanAdapterInlet(), fanAdapterSeatT()
use <../cad/cabinetFlat/sidePanel.scad>; // provides sidePanel(), sidePanelTile(), panelFeatures(), panelSplitZ(), lead_hole_2d()

// The other two have no nested `use`, so they can be pulled straight in.
// If you ever add a `use <...>` to one of them it'll break here, and will need
// the same module wrapper as the ones above.
module part_singulator() { include <../cad/feeder/singulator.scad>; }
module part_hornMount()  { include <../cad/feeder/hornMount.scad>; }
use <../cad/cabinet/screenTilt.scad>;    // provides screenTilt(), screenTiltWallFeatures(), in_plate_frame()

use <../cad/cabinet/cornerBlock.scad>;   // provides cornerBlock()
use <../cad/cabinet/flatPanel.scad>;     // provides flat_part(), flat_tile()

// Where the box and everything in and on it sits -- shared with the faces'
// part files. Needs `hand`, above, and the files it lists `use`d, which they are.
include <../cad/cabinet/boxLayout.scad>

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
            [s * leadGap/2, clDist + cabinetWallThk + heatsinkHolderBackset() + leadIntoCabinet, leadZ]
        ], coilTube);
    }
}

// The heatsink holder in place: its +X end face on the inside of the wall,
// centred between the leads.
module place_holder() {
    translate([0, clDist + cabinetWallThk + heatsinkHolderSize()[0] - heatsinkLen/2, leadZ]) rotate([0, 0, -90]) children();
}

// The two heatsinks on the holder's sides, as their outline: a round back
// (the arc in layout.scad) out to the fin tips, which curl back toward the
// holder above and below its centre block. The lead bores are heatsinkBoreIn
// in from the flat face, at mid-height.
module mock_heatsinks() {
    translate([0, clDist + cabinetWallThk + heatsinkHolderBackset(), leadZ]) rotate([-90, 0, 0])
        linear_extrude(heatsinkLen)
            for (s = [1, -1]) mirror([s < 0 ? 1 : 0, 0]) difference() {
                intersection() {
                    translate([heatsinkArcC, 0]) circle(r = heatsinkArcR, $fn = 180);
                    translate([heatsinkTipX, -heatsinkH]) square([heatsinkBackX, 2*heatsinkH]);
                }
                translate([heatsinkTipX - 1, -9]) square([heatsinkSpacing/2 - heatsinkTipX + 1, 18]);  // the holder's centre block
            }
}

// Rubber grommet in each lead hole, lipped on the outside only -- the
// heatsinks sit against the inside face.
module mock_grommet() {
    translate([0, clDist - 1.5, leadZ]) rotate([-90, 0, 0])
        linear_extrude(cabinetWallThk + 1.5)
            difference() { lead_hole_2d(grommetLip); lead_hole_2d(0); }
    for (y = [clDist - 1.5])
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
// it to set how high the case sits in the coil -- at its lowest (caseBaseZ)
// for the longest case, raised for shorter ones.
module mock_thumbscrew() {
    color("Silver") {
        translate([0,0,caseSeatZ - thumbHeadH]) cylinder(d = thumbHeadD, h = thumbHeadH);
        translate([0,0,armBotZ - 10])
            cylinder(d = supportScrewSize,
                     h = (caseSeatZ - thumbHeadH) - (armBotZ - 10));
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
                y = crownY + 5 + r * 0.87 * (caseBodyD + 0.5);
                x = hopperWidth/2 + (c + (r % 2) / 2) * (caseBodyD + 0.5);
                leftWall = (y < angleY) ? angleX * (1 - y/angleY) : 0;
                if (x > leftWall + inset
                 && x < hopperWidth - leftWall - inset
                 && y < hopperHeight - wallThickness - caseBodyD/2 - 1)
                    translate([x, y, 0]) mock_case();
            }
}

// ---------------------------------------------------------------------------
// Cabinet box, left-hand coordinates
// ---------------------------------------------------------------------------
// The corner blocks, in the four vertical corners: on the base, across the
// tile seam, and under the lid, each turned so its inserts face the faces it
// takes screws from (shown mirrored here -- the part itself just turns). cut
// leaves out the ones in the corner the cutaway opens (front, right).
module corner_blocks(cut = false) {
    for (i = [0, 1], j = [0, 1], k = [0, 1, 2])
        if (!(cut && i == 1 && j == 1))
            translate([cbX[i], cbY[j], cbZ[k]])
                translate([i*cornerBlock, j*cornerBlock, k == 2 ? cornerBlock : 0])
                    mirror([i, 0, 0]) mirror([0, j, 0]) mirror([0, 0, k == 2 ? 1 : 0]) cornerBlock();
}

// The front, back and right walls, lid and base, from their part files'
// features: the tall ones as their two printing tiles, a hairline apart.
module box_faces() {
    for (f = boxCutaway ? ["back", "base"] : ["front", "back", "right", "lid", "base"])
        place_face(f)
            if (faceIsTiled(f)) {
                translate([0, 0.3, 0]) flat_tile(faceFeatures(f), T, seamZ, tileLap, "upper", faceLapXs(f));
                flat_tile(faceFeatures(f), T, seamZ, tileLap, "lower", faceLapXs(f));
            } else flat_part(faceFeatures(f), T);
}

// The Pico motor board, roughly: board, the Pico on its headers, the two USB
// ports, the stepper driver modules, the D-sub (fitted, but nothing plugs in),
// and the standoffs to the wall. In the board's own frame.
module pico_board_mock() {
    color("DarkGreen") translate([0, 0, -pb[2]]) linear_extrude(pb[2])
        offset(r = 2.286) offset(delta = -2.286) square([pb[0], pb[1]]);
    color("SeaGreen") translate([42.926 - 10.5, 1.93, picoLift]) cube([21, 51, 1]);        // Pico 2 W
    color("Silver") translate([42.926 - 4.5, 0.6, picoLift + 1]) cube([9, 6, 3.2]);        // its USB port
    color("Silver") translate([71.882 - 4.47, -0.1, 0]) cube([8.94, 7.3, 3.2]);           // the board's USB-C
    for (v = [18.98, 42.67])                                                                // stepper drivers
        color("Purple") translate([18.54 - 7.62, v - 10.16, 0]) cube([15.24, 20.32, 20]);
    color("DimGray") translate([79.5, 29.98 - 15.5, 0]) cube([pb[0] + 1 - 79.5, 31, 12.5]);   // D-sub, facing off the board's end
    for (hl = pbHoles)
        color("Gold") translate([hl[0], hl[1], -pb[2] - picoStandoff]) cylinder(d = 5.5, h = picoStandoff, $fn = 6);
}

// the harvested heater and the rest of the electronics
// the transformer, as its own module so it can be checked for clashes
// (clear grows it all round, for cutting notches)
module transformer_mock(clear = 0) {
    d = xfmrDir;
    translate(xfmrA) rotate([0, 0, atan2(d[1], d[0])]) rotate([0, acos(d[2]), 0])
        translate([0, 0, -clear]) cylinder(d = transformerSize[0] + 2*clear, h = transformerSize[1] + 2*clear);
}

module box_electronics() {
    b = driverBoard;
    // driver board flat on the floor, output end at the front
    translate([boardX0, boardY0, boardZ0]) {
        color("Silver")      translate([b[2] - 4, 0, 0]) cube([4, b[0], b[1]]);                 // heatsink bar, front side
        color("DarkGreen")   translate([0, 0, 2]) cube([b[2] - 4, b[0], 1.6]);                  // board
        color([0.2,0.2,0.2]) translate([b[2] * 0.4 - 8, 5, 3.6]) cube([b[2] * 0.6, b[0] - 10, b[1] - 4]); // parts
    }
    // its fan, in its duct on the front wall, blowing down the heatsink
    on_fan_duct() {
        color("DimGray") fanAdapter();
        color("Black") on_seat() translate([-driverFanSize/2, -driverFanSize/2, fanAdapterSeatT()]) cube([driverFanSize, driverFanSize, driverFanDepth]);
    }
    // transformer, running right from the heatsinks, low over the board
    color("Gold") transformer_mock();
    // transformer cradle
    color("Tan") place_cradle() transformerCradle();
    // relay/SSR on the floor behind the board, at the left end
    color("MediumBlue") translate(relayAt) cube(relaySize);
    // IEC inlet
    color("Red") translate([-14, boxY1 - 1, seamZ + 30]) cube([28, 2, 40]);
}

// catch bin under the stack, on its own printed tray in front of the box
module bin_and_tray() {
    color([0.3, 0.3, 0.33]) translate([-60, -60, boxZ0]) cube([120, boxY0 + 60, T]);
    color("Silver") translate([-45, -45, boxZ0 + T])
        difference() { cube([90, 90, 50]); translate([2, 2, 2]) cube([86, 86, 50]); }
}

// everything the transformer must keep clear of (left-hand coordinates)
module transformer_obstacles() {
    place_cradle() transformerCradle();
    translate([0, servoY, armBotZ]) rotate([0, 0, -90]) part_hornMount();
    translate([0, servoY, servoTopZ]) mock_servo();
    translate([0, servoY, servoMountTopZ]) servoMount();
    corner_blocks();
    translate([boxX0, boxY0, boxZ0]) cube([boxW, T, boxZ1 - boxZ0]);        // left panel
    translate([boxX0, boxY0, boxZ0]) cube([T, boxD, boxZ1 - boxZ0]);        // back wall
    translate([boxX1 - T, boxY0, boxZ0]) cube([T, boxD, boxZ1 - boxZ0]);    // front wall
    translate([boxX0, boxY1 - T, boxZ0]) cube([boxW, T, boxZ1 - boxZ0]);    // right wall
    translate([boxX0, boxY0, boxZ0]) cube([boxW, boxD, T]);                 // base
    translate([boxX0, boxY0, boxZ1 - T]) cube([boxW, boxD, T]);             // lid
    // the funnel's bolt heads: the lower one on the inside of the left panel, in
    // the holder's pocket; the upper one, shared, on the holder's inner end
    translate([0, boxY0 + T, funnelZ + funnelBoltZs[0]]) rotate([-90, 0, 0]) cylinder(d = 9, h = 5);
    translate([0, boxY0 + T + heatsinkHolderSize()[0], funnelZ + funnelBoltZs[1]]) rotate([-90, 0, 0]) cylinder(d = 9, h = 5);
    translate([boardX0, boardY0, boardZ0]) cube([driverBoard[2], driverBoard[0], driverBoard[1]]);
    place_holder() heatsinkHolder();
    mock_heatsinks();
    on_fan_duct() { fanAdapter(); on_seat() translate([-driverFanSize/2, -driverFanSize/2, fanAdapterSeatT()]) cube([driverFanSize, driverFanSize, driverFanDepth]); }
}

// what the corner blocks must keep clear of: the servo stack and the arm
// through its swing
module corner_obstacles() {
    translate([0, servoY, servoMountTopZ]) servoMount();
    translate([0, servoY, servoTopZ]) mock_servo();
    for (t = [-armSwing : 5 : armSwing])
        translate([0, servoY, armBotZ]) rotate([0, 0, -90 + t]) part_hornMount();
}

// ---------------------------------------------------------------------------
// Assembly
// ---------------------------------------------------------------------------
if (checkTransformer)
    color("Red") intersection() { transformer_mock(); transformer_obstacles(); }
else if (checkCorners)
    color("Red") intersection() { corner_blocks(); corner_obstacles(); }
else {

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

if (showCoil) {
    color("Peru") translate([0, 0, coilZ]) mock_coil();
    // heatsink holder, stood upright inside the cabinet on the left panel
    // between the leads, its bolted end face on the wall, with the heatsinks
    // the leads plug into on each side. Not mirrored for a right-hand build.
    color("DarkOrange") place_holder() heatsinkHolder();
    color("Silver") mock_heatsinks();
}

if (showCases)
    color("Goldenrod") translate([0, 0, caseSeatZ]) mock_case();

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
            translate([0, clDist + cabinetWallThk, 0]) rotate([90, 0, 0]) {
                // shown as its two printing tiles, with a hairline between
                translate([0, 0.3, 0]) sidePanelTile("upper");
                sidePanelTile("lower");
            }
    color([0.1, 0.1, 0.1]) mock_grommet();
}

if (showBox) {
    color([0.93, 0.86, 0.72], cabinetAlpha)    // plywood-ish
        mirror([hand < 0 ? 1 : 0, 0, 0]) box_faces();
    color([0.35, 0.35, 0.38]) mirror([hand < 0 ? 1 : 0, 0, 0]) corner_blocks(cut = boxCutaway);
    bin_and_tray();
    // screen housing, and the Mini12864's knob and display
    on_screen_wall() {
        color("DimGray") screenTilt(screenTiltDeg);
        color("Silver") in_plate_frame(screenTiltDeg)
            translate([104.99/2 - (18.47 + 7.29)/2, (20.78 + 32.71)/2 - 47/2, 0]) cylinder(d = 20, h = 12);
        color("RoyalBlue") in_plate_frame(screenTiltDeg)
            translate([(14.5 + 67.75)/2 - 104.99/2, (10.5 + 40.25)/2 - 47/2, -2.5]) cube([53, 30, 1], center = true);
    }
}

if (showElectronics) {
    mirror([hand < 0 ? 1 : 0, 0, 0]) box_electronics();
    on_pico_board() pico_board_mock();
}
}
