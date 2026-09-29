// The cabinet box and what's inside it: where everything sits, and each flat
// face's features. Shared by the cabinet's face parts (cad/cabinetFlat/) and
// assembly/assembly.scad, so the holes always land on the parts. No geometry.
//
// Names, standing at the screen looking at the machine: front is the screen
// end (+X), back is where the Pico board's USB ports come out (-X), left is
// the feeder panel the hopper and the chain of action mount on (-Y, the side
// panel), right is the wall across from it (+Y). All in
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
/* The coil, heatsinks, transformer and driver board stay in a short chain,
   each joined to the next by the heater's own thick leads. The coil's leads
   come through the left panel into the heatsinks on the holder; the
   transformer's leads leave the heatsinks' inner ends for its upper end, and
   it runs down to the right, in line with the coil. Its leads to the driver
   board come straight out of the middle of its lower end, so the board stands
   on end just past it, its terminals near its bottom end on the face its
   heatsink is on -- facing the transformer. Only a shallow transformer lets
   those short leads reach an upright board: the steeper it is, the further its
   end's corner holds the board off. The box is as wide, left to right, as
   that chain needs. The board's fan, and the low-voltage supply, are left
   out for now.
*/
driverBoard     = [185, 44, 44];      // long (7.25 in), across its end (the terminal row), and deep (face to back)
transformerSize = [63.5, 90];         // diameter, length (3.5 in)
xfmrDown        = 25;                 // [0:1:40] transformer axis, degrees below horizontal
xfmrShiftX      = 0;                  // off the drop axis, toward the front -- in line with the coil
xfmrGap         = 17;                 // the heatsinks' inner ends to the middle of its upper end, along its run
                                      // (how high it sits comes from its cradle and shim)
hsLeads         = 52;                 // the leads, heatsinks to transformer...
boardLeads      = 20;                 // ...and transformer to board -- they're thick, so they need room to bend
boardFaceGap    = 1;                  // the transformer's lower end corner to the board's face
boardLeadsUp    = 8;                  // the board's terminal row, up from its bottom end
cradleSlide     = [8, 6];             // the cradle's screws slot in the base, to slide it along the transformer's axis
                                      // for fitment: toward the heatsinks (left), and toward the board -- which the
                                      // modelled transformer is 1 mm off, but a shorter one could use

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

/* [IEC inlet -- back wall] */
iecCut       = [47, 27.5];  // its panel cut-out, along the wall and up
iecLeftClear = 15;          // the left panel's inside face to the cut-out: room for the inlet's mounting screws
iecDepth     = 35;          // ASSUMED: how far its body and terminals reach in behind the wall

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
boxZ0 = panelOutline[2];
boxZ1 = panelOutline[2] + panelOutline[4];
seamZ = panelSplitZ();                      // every printed face splits here, on the left panel's line
// (its right side, boxY1, is set by the heater's chain, below)

// ---------------------------------------------------------------------------
// The harvested heater
// ---------------------------------------------------------------------------
// the transformer: the middle of its upper end, A (to the heatsinks), and of
// its lower end, B (to the board)
xfmrR   = transformerSize[0]/2;
xfmrDir = [0, cos(xfmrDown), -sin(xfmrDown)];
hsEndY  = boxY0 + T + wallBackset + heatsinkLen;       // the heatsinks' inner ends
// It sits on its old cradle (transformerCradle.scad, drawn for a shallower
// pose) with a wedge shim on the cradle's slab tipping it to xfmrDown, its
// middle over the shim's middle -- which sets how high it sits, and where
// along its run the cradle stands
xfmrOnCradle = transformerOnShim();                    // A in the cradle's frame: [along the run, up off the floor]
xfmrA   = [xfmrShiftX, hsEndY + xfmrGap, boxZ0 + T + xfmrOnCradle[1]];
xfmrB   = xfmrA + transformerSize[1]*xfmrDir;
cradleY = xfmrA[1] - xfmrOnCradle[0];                  // the cradle's origin, along the run
assert(!boxLayoutReady || transformerShimFit()[0] == xfmrDown,
       str("transformerCradle.scad's shim tips the transformer to ", transformerShimFit()[0], " -- set shimTilt to xfmrDown"));
assert(!boxLayoutReady || transformerCradleFit()[0] == transformerSize[0] && transformerCradleFit()[1] == transformerSize[1],
       "transformerCradle.scad is drawn for a different transformer -- set xfmrD and xfmrLen to transformerSize");
// its leads from the heatsinks: from their inner ends, at the lead bores
hsLeadRun = max([for (s = [1, -1]) norm([s*leadGap/2, hsEndY, leadZ] - xfmrA)]);
assert(!boxLayoutReady || hsLeadRun <= hsLeads - 6,
       str("the heatsinks are ", hsLeadRun, " from the transformer's upper end -- too far for their leads; shorten xfmrGap"));
assert(!boxLayoutReady || xfmrA[1] - xfmrR*sin(xfmrDown) >= hsEndY + 2 || xfmrA[2] + xfmrR*cos(xfmrDown) <= leadZ - heatsinkH/2 - 2,
       "the transformer's upper end runs into the heatsinks -- lengthen xfmrGap");

// The driver board stands on end just right of the transformer's lower end,
// across its leads: its face (the heatsink and terminal side) toward the
// transformer, boardFaceGap past the end's nearest corner, and its terminal
// row where the leads, straight out of the end's middle, meet that face.
// driverBoard is [long, across, deep]: long runs up, across runs front to
// back, deep runs right from its face.
boardY0  = xfmrB[1] + xfmrR*sin(xfmrDown) + boardFaceGap;    // its face
boardRun = (boardY0 - xfmrB[1]) / cos(xfmrDown);              // the leads' run, end to face
boardX0  = xfmrA[0] - driverBoard[1]/2;
boardZ0  = xfmrB[2] - (boardY0 - xfmrB[1])*tan(xfmrDown) - boardLeadsUp;
assert(!boxLayoutReady || boardRun <= boardLeads - 3,
       str("the board's face is ", boardRun, " from the transformer's lower end -- too far for its leads; make the transformer shallower (xfmrDown)"));
assert(!boxLayoutReady || boardZ0 + driverBoard[0] <= boxZ1 - T - 1, "the driver board runs into the lid");

// the box's right side: just past the board's back. The front and back walls,
// lid and base are that wide, less the side walls, and have to fit the bed
boxY1 = boardY0 + driverBoard[2] + 1 + T;   // the right wall's outside face
boxD  = boxY1 - boxY0;
assert(!boxLayoutReady || boxD - 2*T <= printBed - 4,
       str("the box is ", boxD, " left to right -- its front and back walls, lid and base won't fit the printer bed; shorten xfmrGap"));

// the corner blocks: their lowest corners (x, y, z), and their middles, where
// the screws go in
cbX = [boxX0 + T, boxX1 - T - cornerBlock];
cbY = [boxY0 + T, boxY1 - T - cornerBlock];
cbZ = [boxZ0 + T, seamZ - cornerBlock/2, boxZ1 - T - cornerBlock];
cbMid = function (v) [for (c = v) c + cornerBlock/2];

// the transformer's cradle and shim, on the floor under it, in the cradle's frame
module place_cradle() { translate([xfmrA[0], cradleY, boxZ0 + T]) children(); }

// the relay (or SSR), taped to the floor at the back-left, clear of the back
// corner block
relaySize = [25, 40, 20];
relayAt   = [boxX0 + T + 2, boxY0 + T + cornerBlock + 2, boxZ0 + T];

// the IEC inlet, low on the back wall at the left end, just above the relay --
// clear of the cradle's back legs, which rule out the floor beside it -- and
// iecLeftClear off the left panel for its mounting screws. Its body reaches in
// iecDepth behind the wall
iecY0 = boxY0 + T + iecLeftClear;               // its cut-out's left edge
iecZ0 = relayAt[2] + relaySize[2] + 1;          // ...and bottom edge
assert(!boxLayoutReady || iecY0 + iecCut[0] <= boxY1 - T - cornerBlock, "the IEC inlet runs past the back wall's corner blocks");
module iec_mock() {
    translate([boxX0 + T, iecY0, iecZ0]) cube([iecDepth, iecCut[0], iecCut[1]]);                  // body, inside
    translate([boxX0 - 3, iecY0 - 1.5, iecZ0 - 1.5]) cube([3, iecCut[0] + 3, iecCut[1] + 3]);    // flange, outside
}

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
    cornerScrews(cbMid(cbY), cbMid(cbZ)));

function backFeatures() = concat(
    [["rect", -(boxY1 - T), boxZ0, boxD - 2*T, boxZ1 - boxZ0]],
    //the Pico board's two USB ports (the plug's wide side up and down)
    [for (p = pbPorts) let (c = pbToWorld([p[0], 0, p[1]]))
        ["rect", -c[1] - usbCut[1]/2, c[2] - usbCut[0]/2, usbCut[1], usbCut[0]]],
    //the IEC inlet, low at the left end
    [["rect", -(iecY0 + iecCut[0]), iecZ0, iecCut[0], iecCut[1]]],
    cornerScrews([for (y = cbMid(cbY)) -y], cbMid(cbZ)));

function rightFeatures() = concat(
    [["rrect", -boxX1, boxZ0, boxW, boxZ1 - boxZ0, panelOutline[5]]],
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
        ["vslot", xfmrA[0] + h[0], -(cradleY + h[1] + (cradleSlide[1] - cradleSlide[0])/2),
         (cradleSlide[0] + cradleSlide[1])/2, lapBoltD/2]]);

// Puts a face, drawn flat in its own frame (outside at z = T), in its place.
module place_face(which) {
    if (which == "front")      multmatrix([[0, 0, 1, boxX1 - T], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]]) children();
    else if (which == "back")  multmatrix([[0, 0, -1, boxX0 + T], [-1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]]) children();
    else if (which == "right") multmatrix([[-1, 0, 0, 0], [0, 0, 1, boxY1 - T], [0, 1, 0, 0], [0, 0, 0, 1]]) children();
    else if (which == "lid")   translate([0, 0, boxZ1 - T]) children();
    else                       multmatrix([[1, 0, 0, 0], [0, -1, 0, 0], [0, 0, -1, boxZ0 + T], [0, 0, 0, 1]]) children();
}
