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
// induction coil, thumbscrew, grommet, the cases, and for now the cabinet box
// and the harvested heater's parts inside it. Those are rough stand-ins for
// visualisation, not parts to print.
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

/* [Cabinet box -- concept, not parts yet] */
/* Flat faces (ply or print, cabinetWallThk thick) on four printed corner
   posts, base and top plates. The feeder panel is the whole front face, so
   the box is exactly as wide as the panel; the screen housing sits on the far
   end wall.
*/
boxCutaway    = false;  // drop the top, back and screen-end walls to see inside
screenTiltDeg = 25;     // [0:1:45]
postLeg       = 20;     // corner posts: L-section legs...
postT         = 4;      // ...and thickness
beltH         = 20;     // belt rail round the inside at the tile seam: height...
beltT         = 8;      // ...and depth off the wall

/* [Heater + electronics mocks -- CONFIRM sizes] */
/* The coil, heatsinks, transformer and driver board stay in a short chain.
   The coil's leads come through the wall into the heatsinks on the holder;
   the transformer's cables leave the heatsinks' inner ends and it runs
   straight back from just behind them and down at 45 deg toward the driver
   board, which lies flat on the floor -- weight low. The board's fan is on
   the back wall just above the board's end, so the box stays one printer bed
   deep. Pose the transformer with the xfmr* settings; checkTransformer shows
   any clash. The low-voltage supply is left out for now.
*/
driverBoard     = [185, 35, 63.5];    // long (7.25 in), thick (board + parts + heatsink bar), wide
driverFan       = [45, 25];           // fan, now on the back wall: size and depth
boardStandoff   = 8;                  // the board's standoffs off the floor -- under the servo mount at most
transformerSize = [63.5, 90];         // diameter, length (3.5 in)
xfmrDown        = 45;                 // [0:1:90] transformer axis, degrees below horizontal
xfmrSide        = 0;                  // [0:1:90] swing from straight back (0) to along the wall (90), toward the feeder side
xfmrSetback     = 66;                 // inside face of the front wall to the axis at its front end -- clear of the heatsinks
xfmrShiftX      = 0;                  // its front end, off the drop axis (toward the feeder side is -)
xfmrRaise       = -20;                // its front end, above the lead height

/* [Display] */
showCases   = true;
showMotor   = true;
showCoil    = true;
showFunnel  = true;
showArm     = true;
showCabinet = true;     // the feeder side panel and the lead grommet
showBox     = true;     // the rest of the cabinet
showElectronics = true;
checkTransformer = false;   // true: draw only where the transformer hits something -- nothing drawn means clear
checkPosts       = false;   // true: draw only where the corner posts or belt hit the servo, its mount or the swinging arm
armSwing         = 45;      // the arm's swing each way from the drop axis, for checkPosts -- the wall slot limits it
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
use <../cad/cabinet/heatsinkHolder.scad>; // provides heatsinkHolder(), heatsinkHolderSize()
use <../cad/cabinetFlat/sidePanel.scad>; // provides sidePanel(), sidePanelTile(), panelFeatures(), panelSplitZ(), lead_hole_2d()

// The other two have no nested `use`, so they can be pulled straight in.
// If you ever add a `use <...>` to one of them it'll break here, and will need
// the same module wrapper as the ones above.
module part_singulator() { include <../cad/feeder/singulator.scad>; }
module part_hornMount()  { include <../cad/feeder/hornMount.scad>; }
use <../cad/cabinet/screenTilt.scad>;    // provides screenTilt(), screenTiltWallFeatures(), in_plate_frame()

// Box layout, in left-hand coordinates (a right-hand build is the mirror).
// Its front-left corner, top and bottom come from the feeder panel's outline,
// so the box follows the panel if that changes.
panelOutline = panelFeatures()[0];          // ["rrect", x, y, w, h, r]
boxW  = panelOutline[3];                    // the feeder panel is the whole front
boxX0 = panelOutline[1];                    // feeder side
boxX1 = boxX0 + boxW;                       // screen side
boxY0 = clDist;
boxZ0 = panelOutline[2];
boxZ1 = panelOutline[2] + panelOutline[4];
seamZ = panelSplitZ();                      // every printed wall splits here, on the feeder panel's line
T     = cabinetWallThk;

// transformer: front end (to the coil) just behind the lead entry, back end
// (to the board) down at the far end of its axis
xfmrDir = [-sin(xfmrSide)*cos(xfmrDown), cos(xfmrSide)*cos(xfmrDown), -sin(xfmrDown)];
xfmrA   = [xfmrShiftX, boxY0 + T + xfmrSetback, leadZ + xfmrRaise];
xfmrB   = xfmrA + transformerSize[1]*xfmrDir;

// the box: one feeder panel wide, one printer bed deep
boxD  = printBed;
boxY1 = clDist + boxD;

// driver board flat on the floor front to back, output end at the front,
// centred under the transformer's back end as far as the corner posts allow
// (their legs reach postLeg in from each corner)
boardX0 = max(boxX0 + T + postLeg + 1, min(boxX1 - T - postLeg - 1 - driverBoard[2], xfmrB[0] - driverBoard[2]/2));
boardY0 = boxY0 + T + (boxD - 2*T - driverBoard[0]) / 2;
boardZ0 = boxZ0 + T + boardStandoff;
assert(driverBoard[0] <= boxD - 2*T, "the driver board is longer than the box is deep");

// screen housing on the far end wall, centred front to back, up at eye level
// now that the electronics sit low
scrY = boxY0 + boxD/2;
scrZ = 0;


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

// The heatsink holder in place: its +X end face on the inside of the wall,
// centred between the leads.
module place_holder() {
    translate([0, clDist + cabinetWallThk + heatsinkHolderSize()[0]/2, leadZ]) rotate([0, 0, -90]) children();
}

// The two heatsinks on the holder's sides: a finned body off each flat face,
// fins curling back toward the holder above and below it. Rough -- the lead
// bores are heatsinkBoreIn in from the flat face, at mid-height.
module mock_heatsinks() {
    translate([0, clDist + cabinetWallThk, leadZ]) rotate([-90, 0, 0])
        linear_extrude(heatsinkLen)
            for (s = [1, -1]) mirror([s < 0 ? 1 : 0, 0]) {
                translate([heatsinkSpacing/2, -heatsinkH/2]) square([heatsinkDepth, heatsinkH]);
                for (t = [1, -1])
                    translate([heatsinkSpacing/2 - heatsinkFinReach, t > 0 ? 9 : -heatsinkH/2])
                        square([heatsinkFinReach + 0.01, heatsinkH/2 - 9]);
            }
}

// the room the holder and heatsinks take up inside the wall, grown by c
module heatsink_block_envelope(c = 0) {
    w = heatsinkSpacing/2 + heatsinkDepth + c;
    h = max(heatsinkHolderSize()[2], heatsinkH)/2 + c;
    translate([-w, clDist + cabinetWallThk - 1, leadZ - h])
        cube([2*w, max(heatsinkHolderSize()[0], heatsinkLen) + 1 + c, 2*h]);
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
// Cabinet box -- concept stand-ins, left-hand coordinates
// ---------------------------------------------------------------------------
// Places children in screenTilt.scad's frame (x along the wall, y up, z out)
// on the screen-end wall. The housing is turned, not mirrored, for a
// right-hand build: it has to match the real (unmirrored) Mini12864.
module on_screen_wall() {
    if (hand > 0) multmatrix([[0, 0, 1, boxX1], [1, 0, 0, scrY], [0, 1, 0, scrZ], [0, 0, 0, 1]]) children();
    else          multmatrix([[0, 0, -1, -boxX1], [-1, 0, 0, scrY], [0, 1, 0, scrZ], [0, 0, 0, 1]]) children();
}

// printed L posts in the vertical corners, between base and top, split at
// the seam; and the belt rail that runs round the inside at the seam, which
// every wall's two tiles screw into
module box_posts() {
    for (c = [[boxX0 + T, boxY0 + T, 1, 1], [boxX1 - T, boxY0 + T, -1, 1],
              [boxX0 + T, boxY1 - T, 1, -1], [boxX1 - T, boxY1 - T, -1, -1]])
        translate([c[0], c[1], 0]) mirror([c[2] < 0 ? 1 : 0, 0, 0]) mirror([0, c[3] < 0 ? 1 : 0, 0])
            for (z = [[boxZ0 + T, seamZ - beltH/2], [seamZ + beltH/2, boxZ1 - T]])
                translate([0, 0, z[0]]) {
                    cube([postLeg, postT, z[1] - z[0]]);
                    cube([postT, postLeg, z[1] - z[0]]);
                }
    // belt: front, back and both ends, notched where the transformer passes
    difference() {
        translate([0, 0, seamZ - beltH/2]) {
            translate([boxX0 + T, boxY0 + T, 0]) cube([boxW - 2*T, beltT, beltH]);
            translate([boxX0 + T, boxY1 - T - beltT, 0]) cube([boxW - 2*T, beltT, beltH]);
            translate([boxX0 + T, boxY0 + T, 0]) cube([beltT, boxD - 2*T, beltH]);
            translate([boxX1 - T - beltT, boxY0 + T, 0]) cube([beltT, boxD - 2*T, beltH]);
        }
        transformer_mock(clear = 2);
        heatsink_block_envelope(1);
    }
}

module box_faces() {
    h = boxZ1 - boxZ0;
    difference() {
        union() {
            if (!boxCutaway) translate([boxX0, boxY1 - T, boxZ0]) cube([boxW, T, h]);           // back
            translate([boxX0, boxY0 + T, boxZ0]) cube([T, boxD - 2*T, h]);                      // feeder-side end
            if (!boxCutaway) translate([boxX1 - T, boxY0 + T, boxZ0]) cube([T, boxD - 2*T, h]); // screen end
            if (!boxCutaway) translate([boxX0 + T, boxY0 + T, boxZ1 - T]) cube([boxW - 2*T, boxD - 2*T, T]); // top
            translate([boxX0 + T, boxY0 + T, boxZ0]) cube([boxW - 2*T, boxD - 2*T, T]);         // base
        }
        // intake, low along the feeder-side end
        for (z = [0 : 7 : 21]) translate([boxX0 - 1, boxY0 + 40, boxZ0 + T + 8 + z]) cube([T + 2, boxD - 80, 4]);
        // exhaust through the back wall, behind the fan
        for (z = [0 : 7 : driverFan[0] - 10]) translate([boardX0 + driverBoard[2]/2 - driverFan[0]/2 + 3, boxY1 - T - 1, fanZ0 + 5 + z]) cube([driverFan[0] - 6, T + 2, 4]);
        // IEC inlet cut-out, on the back up clear of the board
        translate([-14, boxY1 - T - 1, seamZ + 30]) cube([28, T + 2, 40]);
        // tile seams, as hairlines
        translate([boxX0 - 1, boxY0 + T, seamZ - 0.3]) cube([T + 2, boxD - 2*T, 0.6]);
        translate([boxX0 - 1, boxY1 - T - 1, seamZ - 0.3]) cube([boxW + 2, T + 2, 0.6]);
    }
}

// the screen housing's window and screw holes, cut through the end wall
module screen_wall_cut() {
    on_screen_wall() translate([0, 0, -T - 1]) linear_extrude(T + 2)
        for (f = screenTiltWallFeatures(screenTiltDeg))
            if (f[0] == "rect") translate([f[1], f[2]]) square([f[3], f[4]]);
            else translate([f[1], f[2]]) circle(d = f[3]);
}

// the harvested heater and the rest of the electronics
// the board's fan, on the back wall just above the board's far end
fanZ0 = boardZ0 + driverBoard[1] + 2;

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
        color("Silver")      cube([4, b[0], b[1]]);                                          // heatsink bar
        color("DarkGreen")   translate([4, 0, 2]) cube([b[2] - 4, b[0], 1.6]);               // board
        color([0.2,0.2,0.2]) translate([8, 5, 3.6]) cube([b[2] * 0.6, b[0] - 10, b[1] - 4]); // parts
    }
    // its fan, on the back wall just above the board's far end
    color("Black") translate([boardX0 + b[2]/2 - driverFan[0]/2, boxY1 - T - driverFan[1], fanZ0])
        cube([driverFan[0], driverFan[1], driverFan[0]]);
    // transformer, diagonally down along the front wall from the lead entry to the board
    color("Gold") transformer_mock();
    // relay/SSR on the floor beside the board, on the feeder side
    color("MediumBlue") translate([boardX0 - 27, boxY0 + boxD/2, boxZ0 + T]) cube([25, 40, 20]);
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
    translate([0, servoY, armBotZ]) rotate([0, 0, -90]) part_hornMount();
    translate([0, servoY, servoTopZ]) mock_servo();
    translate([0, servoY, servoMountTopZ]) servoMount();
    box_posts();
    translate([boxX0, boxY0, boxZ0]) cube([boxW, T, boxZ1 - boxZ0]);        // front wall
    translate([boxX0, boxY0, boxZ0]) cube([T, boxD, boxZ1 - boxZ0]);        // feeder-side end
    translate([boxX1 - T, boxY0, boxZ0]) cube([T, boxD, boxZ1 - boxZ0]);    // screen end
    translate([boxX0, boxY0, boxZ0]) cube([boxW, boxD, T]);                 // base
    // the funnel's bolt heads: the lower one on the inside of the front wall, in
    // the holder's pocket; the upper one, shared, on the holder's inner end
    translate([0, boxY0 + T, funnelZ + funnelBoltZs[0]]) rotate([-90, 0, 0]) cylinder(d = 9, h = 5);
    translate([0, boxY0 + T + heatsinkHolderSize()[0], funnelZ + funnelBoltZs[1]]) rotate([-90, 0, 0]) cylinder(d = 9, h = 5);
    translate([boardX0, boardY0, boardZ0]) cube([driverBoard[2], driverBoard[0], driverBoard[1]]);
    heatsink_block_envelope(0);
}

// what the corner posts and belt must keep clear of: the servo stack and the
// arm through its swing
module post_obstacles() {
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
else if (checkPosts)
    color("Red") intersection() { box_posts(); post_obstacles(); }
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
    // heatsink holder, stood upright inside the cabinet on the feeder panel
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
        difference() {
            mirror([hand < 0 ? 1 : 0, 0, 0]) box_faces();
            screen_wall_cut();
        }
    color([0.35, 0.35, 0.38]) mirror([hand < 0 ? 1 : 0, 0, 0]) box_posts();
    bin_and_tray();
    // screen housing, the Mini12864's knob and display, the controller behind it, and the E-stop
    on_screen_wall() {
        color("DimGray") screenTilt(screenTiltDeg);
        color("Silver") in_plate_frame(screenTiltDeg)
            translate([104.99/2 - (18.47 + 7.29)/2, (20.78 + 32.71)/2 - 47/2, 0]) cylinder(d = 20, h = 12);
        color("RoyalBlue") in_plate_frame(screenTiltDeg)
            translate([(14.5 + 67.75)/2 - 104.99/2, (10.5 + 40.25)/2 - 47/2, -2.5]) cube([53, 30, 1], center = true);
        color("ForestGreen") translate([-25, 5, -T - 14]) cube([51, 21, 2]);
        color("Yellow") translate([0, boxZ0 + 45 - scrZ, 0]) cylinder(d = 22, h = 6);
    }
}

if (showElectronics)
    mirror([hand < 0 ? 1 : 0, 0, 0]) box_electronics();
}
