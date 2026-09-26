// The cabinet box and what's inside it: where everything sits, and each flat
// face's features. Shared by the cabinet's face parts (cad/cabinetFlat/) and
// assembly/assembly.scad, so the holes always land on the parts. No geometry.
//
// Names, standing at the screen looking at the machine: front is the screen
// end (+X), back is where the Pico board's USB ports come out (-X), left is
// the feeder panel the hopper and the chain of action mount on (-Y, the side
// panel), right is the wall across from it (+Y), with the IEC inlet. All in
// left-hand-build coordinates (feeder on the left of the drop axis, seen from
// outside the left panel); a right-hand build is the mirror image.
//
// `include` it, after:
//   include <../feeder/layout.scad>
//   use <../cabinetFlat/sidePanel.scad>
//   use <fanAdapter.scad>
//   use <screenTilt.scad>
//   use <transformerCradle.scad>
// (with paths from the including file), and with `hand` set: +1 for a
// left-hand build, -1 for a right-hand one. It has no `use` or `include` of
// its own, because nested ones resolve from the top file, not from here.

/* [Screen] */
screenTiltDeg = 25;     // [0:1:45]

/* [Harvested heater -- CONFIRM sizes] */
/* The coil, heatsinks, transformer and driver board stay in a short chain.
   The coil's leads come through the left panel into the heatsinks on the
   holder; the transformer's cables leave the heatsinks' inner ends and it
   runs right from there, laid nearly flat (15 deg) just above the driver
   board, which lies flat on the floor -- weight low -- both as nearly in line
   with the coil as the fan allows. The board's heatsink is along its front
   side; the board's fan sits low on the front wall at the left end, in a
   printed duct (fanAdapter.scad) that pulls air in through the wall and
   blows it back and right down the heatsink, out of vents low in the right
   wall. The low-voltage supply is left out for now.
*/
driverBoard     = [185, 44, 44];      // long (7.25 in), and about 44 x 44 in section (board + parts + heatsink bar)
boardStandoff   = 0;                  // the board off the floor: taped straight down, so it fits under the servo mount
transformerSize = [63.5, 90];         // diameter, length (3.5 in)
xfmrDown        = 15;                 // [0:1:90] transformer axis, degrees below horizontal
xfmrSide        = 0;                  // [0:1:90] swing from straight right (0) to along the left panel (90), toward the back
xfmrSetback     = 91;                 // the left panel's inside face to its axis, at its left end -- as far right as it
                                      // goes, for the driver board's connection; the heatsinks come to it with
                                      // the heatsink holder's wallBackset (sharedDims)
xfmrShiftX      = -29;                // off the drop axis, toward the back (-) -- as little as the fan's duct, in
                                      // front of the driver board's heatsink, allows
cradleSlide     = [8, 6];             // the cradle's screws slot in the base, to slide it along the transformer's axis
                                      // for fitment: toward the heatsinks (left), and toward the right wall -- which
                                      // the modelled transformer is 1 mm off, but a shorter one could use
xfmrRaise       = -52.4;              // its left end, above the lead height -- as low as it goes: its lower end,
                                      // and the cradle's slab, 3 mm over the driver board

/* [Pico motor board -- eamars Pico Motor Expansion Board v2] */
/* On standoffs off the inside of the left panel, under the hopper, its USB
   edge toward the back wall so the board's USB-C and the Pico's port come out
   through cut-outs in it; the lid stays clear for servicing. Where it sits is
   set in sidePanel.scad, which drills the standoff holes. Board outline, holes
   and connectors are from its KiCad file.
*/
picoLift     = 8.5;     // ASSUMED: the Pico 2 W on female headers -- board face to the Pico's underside
picoStandoff = 10;      // M3 standoffs off the panel
usbCut       = [15, 10];// back-wall cut-out round each port: room for a cable's plug

/* [Right wall] */
iecCut       = [28, 40];// IEC inlet cut-out -- PLACEHOLDER until the inlet's chosen
iecAboveSeam = 30;      // its bottom, above the tile seam

/* [Faces] */
lapBoltD = 3.4;         // M3 clearance: the tiles' lap bolts, and screws into the corner blocks

T = cabinetWallThk;

// Opened on its own (as the release workflow does with every file in cad/)
// none of the above is set up, so the checks below stand down.
boxLayoutReady = !is_undef(hand);

// ---------------------------------------------------------------------------
// The box
// ---------------------------------------------------------------------------
// Its left-back corner, top and bottom come from the left panel's outline, so
// the box follows the panel if that changes.
panelOutline = panelFeatures()[0];          // ["rrect", x, y, w, h, r]
boxW  = panelOutline[3];                    // the left panel is the whole of the box's left side
boxX0 = panelOutline[1];                    // back
boxX1 = boxX0 + boxW;                       // front
boxY0 = clDist;                             // the left panel's outside face
boxD  = printBed;                           // one printer bed left to right, so lid and base print whole
boxY1 = boxY0 + boxD;                       // the right wall's outside face
boxZ0 = panelOutline[2];
boxZ1 = panelOutline[2] + panelOutline[4];
seamZ = panelSplitZ();                      // every printed face splits here, on the left panel's line

// the corner blocks: their lowest corners (x, y, z), and their middles, where
// the screws go in
cbX = [boxX0 + T, boxX1 - T - cornerBlock];
cbY = [boxY0 + T, boxY1 - T - cornerBlock];
cbZ = [boxZ0 + T, seamZ - cornerBlock/2, boxZ1 - T - cornerBlock];
cbMid = function (v) [for (c = v) c + cornerBlock/2];

// ---------------------------------------------------------------------------
// The harvested heater
// ---------------------------------------------------------------------------
// transformer: its left end (to the heatsinks) and right end (to the board)
xfmrDir = [-sin(xfmrSide)*cos(xfmrDown), cos(xfmrSide)*cos(xfmrDown), -sin(xfmrDown)];
xfmrA   = [xfmrShiftX, boxY0 + T + xfmrSetback, leadZ + xfmrRaise];
xfmrB   = xfmrA + transformerSize[1]*xfmrDir;

// driver board flat on the floor, left to right, centred under the
// transformer's right end, clear of the bottom corner blocks
boardX0 = max(boxX0 + T + cornerBlock + 1, min(boxX1 - T - cornerBlock - 1 - driverBoard[2], xfmrB[0] - driverBoard[2]/2));
boardY0 = boxY0 + T + (boxD - 2*T - driverBoard[0]) / 2;
boardZ0 = boxZ0 + T + boardStandoff;
assert(!boxLayoutReady || driverBoard[0] <= boxD - 2*T, "the driver board is longer than the box is deep");
assert(!boxLayoutReady || boardZ0 + driverBoard[1] + 1 <= servoMountTopZ - servoMountH,
       "the driver board runs into the servo mount above its left end -- lower boardStandoff");

// the transformer's cradle, on the floor under it; it's drawn for the pose
// above, and says what to change if the pose moves
cradleFit = transformerCradleFit();
cradleWant = [transformerSize[0], transformerSize[1], xfmrDown, xfmrA[2] - (boxZ0 + T), boardZ0 + driverBoard[1] - (boxZ0 + T),
              max(xfmrA[0] - boardX0, boardX0 + driverBoard[2] - xfmrA[0])];   // (from the transformer's axis)
assert(!boxLayoutReady || xfmrSide == 0, "the transformer cradle is drawn for a transformer running straight to the right");
assert(!boxLayoutReady || max([for (i = [0 : len(cradleWant) - 1]) abs(cradleFit[i] - cradleWant[i])]) < 0.5,
       str("transformerCradle.scad is out of step with boxLayout.scad -- set [xfmrD, xfmrLen, tilt, endH, boardTopH, boardHalfW] to ", cradleWant));
module place_cradle() { translate([xfmrA[0], xfmrA[1], boxZ0 + T]) children(); }

// The board's fan, in its duct low on the front wall at the left end, in
// front of the board: the duct tips it to the right, so it blows back and
// right, down the heatsink toward the transformer's end. The inlet is as
// near the heatsink's middle height as the servo mount above it lets it be
// (no lower than the floor), and as far left as the front-left corner block
// allows.
fanZ = max(boxZ0 + T + driverFanSize/2 + 2 + 0.5,
           min(boardZ0 + driverBoard[1]/2, servoMountTopZ - servoMountH - 1 - (driverFanSize/2 + 2)));
assert(!boxLayoutReady || fanZ + driverFanSize/2 + 2 + 1 <= servoMountTopZ - servoMountH + 0.01,
       "the fan's duct runs into the servo mount -- the servo stack is too low for it"); 
fanY = boxY0 + T + cornerBlock + 0.5 - fanAdapterMinX(cornerBlock + 0.5);   // (MinX is negative: the duct's reach toward the block)
assert(!boxLayoutReady || boardX0 + driverBoard[2] + 1 <= boxX1 - T - fanAdapterDepth(),
       "the driver board runs into the fan's duct -- move the transformer (xfmrShiftX) further back");
// the duct's frame, in the world: x to the right, y down, z into the cabinet from the front wall
module on_fan_duct() {
    multmatrix([[0, 0, -1, boxX1 - T], [1, 0, 0, fanY], [0, -1, 0, fanZ], [0, 0, 0, 1]]) children();
}

// the relay (or SSR), taped to the floor behind the board at the left end,
// clear of the back corner block (the transformer's cradle is at the right)
relaySize = [25, 40, 20];
relayAt   = [boxX0 + T + 2, boxY0 + T + cornerBlock + 2, boxZ0 + T];
assert(!boxLayoutReady || relayAt[0] + relaySize[0] + 1 <= boardX0, "the relay runs into the driver board");

// ---------------------------------------------------------------------------
// The Pico motor board, on the left panel
// ---------------------------------------------------------------------------
// Its own frame: u along its USB edge from the corner, v in from that edge,
// h up off its component face (KiCad x, y and up)
pb       = [91.694, 66.802, 1.6];
pbHoles  = [[5.08, 5.08], [86.614, 5.08], [5.08, 61.722], [86.614, 61.722]];
pbPorts  = [[71.882, 1.6], [42.926, picoLift + 1 + 1.6]];   // [u, h] of the port centres: the board's USB-C (J8), the Pico's
pbAt     = picoBoardAt();                    // [its USB edge (x), its top edge (z)], from sidePanel.scad
pbFaceY  = boxY0 + T + picoStandoff + pb[2]; // its component face
pbZ0     = pbAt[1] - pb[0];                  // its bottom edge
assert(!boxLayoutReady || pbAt[0] >= boxX0 + T + 0.5, "the Pico board runs into the back wall -- move picoEdgeX in sidePanel.scad");
assert(!boxLayoutReady || pbZ0 >= seamZ + cornerBlock/2 + 1 && pbAt[1] <= boxZ1 - T - cornerBlock - 1,
       "the Pico board runs into the corner blocks -- it has to sit between the seam-height and top ones");
assert(!boxLayoutReady || pbZ0 >= leadZ + heatsinkReachAt(pbAt[0] + pb[1]) + 0.5, "the Pico board runs into the heatsinks");
assert(!boxLayoutReady || pbFaceY + min([for (p = pbPorts) p[1]]) - usbCut[1]/2 >= boxY0 + T + 1,
       "the USB cut-outs run into the left panel -- lengthen picoStandoff");
// Seen from inside, facing the left panel, the USB edge is toward the back,
// so KiCad's x (steppers, Pico, USB-C) runs down the panel on a left-hand
// build and up it on a right-hand one -- turned, not mirrored, since it's the
// real board. (KiCad's y runs down its top view, so u, v, h is a left-handed
// frame: the matrices below are reflections of it on purpose.) These give
// world coordinates, not left-hand ones.
module on_pico_board() {
    if (hand > 0) multmatrix([[0, 1, 0, pbAt[0]], [0, 0, 1, pbFaceY], [-1, 0, 0, pbAt[1]], [0, 0, 0, 1]]) children();
    else          multmatrix([[0, -1, 0, -pbAt[0]], [0, 0, 1, pbFaceY], [1, 0, 0, pbZ0], [0, 0, 0, 1]]) children();
}
function pbToWorld(p) = hand > 0 ? [pbAt[0] + p[1], pbFaceY + p[2], pbAt[1] - p[0]]
                                 : [-pbAt[0] - p[1], pbFaceY + p[2], pbZ0 + p[0]];

// ---------------------------------------------------------------------------
// The screen housing, on the front wall
// ---------------------------------------------------------------------------
// centred left to right, up at eye level now that the electronics sit low
scrY = boxY0 + boxD/2;
scrZ = 0;
// Places children in screenTilt.scad's frame (x along the wall, y up, z out),
// in world coordinates. Turned, not mirrored, for a right-hand build: it has
// to match the real (unmirrored) Mini12864.
module on_screen_wall() {
    if (hand > 0) multmatrix([[0, 0, 1, boxX1], [1, 0, 0, scrY], [0, 1, 0, scrZ], [0, 0, 0, 1]]) children();
    else          multmatrix([[0, 0, -1, -boxX1], [-1, 0, 0, scrY], [0, 1, 0, scrZ], [0, 0, 0, 1]]) children();
}

// ---------------------------------------------------------------------------
// The flat faces (the left panel is sidePanel.scad)
// ---------------------------------------------------------------------------
// Each face's features in its own 2D frame, seen from outside, in left-hand
// coordinates (flatPanel.scad has the feature list format):
//   front  x -> right (+Y), y up        back  x -> -Y, y up
//   right  x -> -X, y up                lid   x -> +X, y -> +Y
//   base   x -> +X, y -> -Y
// A right-hand build's faces are these mirrored (mirror_features()).
function faceFeatures(which) =
    which == "front" ? frontFeatures()
  : which == "back"  ? backFeatures()
  : which == "right" ? rightFeatures()
  : which == "lid"   ? lidFeatures()
  :                    baseFeatures();
// the tall faces split at the seam like the left panel; where their lap bolts go
function faceIsTiled(which) = which == "front" || which == "back" || which == "right";
function faceLapXs(which) =
    let (span = which == "right" ? [-(boxX1 - T - cornerBlock), -(boxX0 + T + cornerBlock)]
                                 : [boxY0 + T + cornerBlock, boxY1 - T - cornerBlock],
         s = which == "back" ? [-span[1], -span[0]] : span)
    [for (f = [1/3, 2/3]) s[0] + f*(s[1] - s[0])];

// screws into the corner blocks, through a face: [its x, its y] in the face's frame
function cornerScrews(us, vs) = [for (u = us, v = vs) ["circle", u, v, lapBoltD]];

function frontFeatures() = concat(
    [["rect", boxY0 + T, boxZ0, boxD - 2*T, boxZ1 - boxZ0]],
    //the screen housing's window and screw holes (x along the wall, turned for a right-hand build)
    [for (f = screenTiltWallFeatures(screenTiltDeg))
        f[0] == "rect" ? let (u0 = scrY + hand*f[1], u1 = scrY + hand*(f[1] + f[3]))
                         ["rect", min(u0, u1), scrZ + f[2], abs(u1 - u0), f[4]]
                       : ["circle", scrY + hand*f[1], scrZ + f[2], f[3]]],
    //the fan's grille and duct screws: duct (x, y) is world (fanY + x, fanZ - y), so here the same
    [for (f = fanGrille())
        f[0] == "rect" ? ["rect", fanY + f[1], fanZ - f[2] - f[4], f[3], f[4]]
                       : ["circle", fanY + f[1], fanZ - f[2], f[3]]],
    cornerScrews(cbMid(cbY), cbMid(cbZ)));

function backFeatures() = concat(
    [["rect", -(boxY1 - T), boxZ0, boxD - 2*T, boxZ1 - boxZ0]],
    //the Pico board's two USB ports (the plug's wide side up and down)
    [for (p = pbPorts) let (c = pbToWorld([p[0], 0, p[1]]))
        ["rect", -c[1] - usbCut[1]/2, c[2] - usbCut[0]/2, usbCut[1], usbCut[0]]],
    cornerScrews([for (y = cbMid(cbY)) -y], cbMid(cbZ)));

// the fan's intake grille and the duct's screws, in the duct's frame: slots
// across the inlet, 4 tall; rows that pass near a screw stop short of its
// column, keeping 1.5 mm of wall round the hole
function fanGrille() = let (a = fanAdapterInlet(), clr = lapBoltD/2 + 1.5) concat(
    [for (z = [a[1][0] + 3 : 7 : a[1][1] - 6])
        let (near = min([for (q = fanAdapterScrews()) abs(z + 2 - q[1])]) < 2 + clr,
             x0 = near ? max(a[0][0] + 3, -driverFanHolePitch/2 + clr) : a[0][0] + 3,
             x1 = near ? min(a[0][1] - 3, driverFanHolePitch/2 - clr) : a[0][1] - 3)
        if (x1 > x0 + 2) ["rect", x0, z, x1 - x0, 4]],
    [for (q = fanAdapterScrews()) ["circle", q[0], q[1], lapBoltD]]);

function rightFeatures() = concat(
    [["rrect", -boxX1, boxZ0, boxW, boxZ1 - boxZ0, panelOutline[5]]],
    //exhaust, low, where the fan's air leaves the driver board's heatsink: from the
    //board's back edge forward to the front corner block
    let (x0 = boardX0, x1 = boxX1 - T - cornerBlock - 4)
        [for (z = [0 : 7 : 21]) ["rect", -x1, boxZ0 + T + 8 + z, x1 - x0, 4]],
    //the IEC inlet, above the seam in the middle
    [["rect", -iecCut[0]/2, seamZ + iecAboveSeam, iecCut[0], iecCut[1]]],
    cornerScrews([for (x = cbMid(cbX)) -x], cbMid(cbZ)));

function lidFeatures() = concat(
    [["rect", boxX0 + T, boxY0 + T, boxW - 2*T, boxD - 2*T]],
    cornerScrews(cbMid(cbX), cbMid(cbY)));

function baseFeatures() = concat(
    [["rect", boxX0 + T, -(boxY1 - T), boxW - 2*T, boxD - 2*T]],
    cornerScrews(cbMid(cbX), [for (y = cbMid(cbY)) -y]),
    //screws up into the transformer cradle's feet, in slots so it can slide along the
    //transformer's axis (cradleSlide)
    [for (h = transformerCradleFootHoles())
        ["vslot", xfmrA[0] + h[0], -(xfmrA[1] + h[1] + (cradleSlide[1] - cradleSlide[0])/2),
         (cradleSlide[0] + cradleSlide[1])/2, lapBoltD/2]]);

// Puts a face, drawn flat in its own frame (outside at z = T), in its place.
module place_face(which) {
    if (which == "front")      multmatrix([[0, 0, 1, boxX1 - T], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]]) children();
    else if (which == "back")  multmatrix([[0, 0, -1, boxX0 + T], [-1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]]) children();
    else if (which == "right") multmatrix([[-1, 0, 0, 0], [0, 0, 1, boxY1 - T], [0, 1, 0, 0], [0, 0, 0, 1]]) children();
    else if (which == "lid")   translate([0, 0, boxZ1 - T]) children();
    else                       multmatrix([[1, 0, 0, 0], [0, -1, 0, 0], [0, 0, -1, boxZ0 + T], [0, 0, 0, 1]]) children();
}
