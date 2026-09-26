include <../feeder/layout.scad>
use <../cabinet/flatPanel.scad>         // feature_2d(), features_2d(), flat_part(), flat_tile()

// The cabinet's left panel (its side panel) -- the sheet the whole feeder
// stack bolts to: the
// hopper's side block, the end of the funnel arm and the servo mount, with a
// slot for the horn arm to swing through and a grommeted pass-through for the
// coil leads.
//
// Drawn flat, as it's cut. X runs across the panel and Y up it, matching world
// X and Z: the drop axis is x = 0 and the discharge exit is y = 0. Laid out for
// a left-hand build (feeder on -X, seen from outside); a right-hand build uses
// the same sheet turned over, so one cut file covers both.
//
// For laser/waterjet cutting, don't use OpenSCAD's own DXF export -- it
// writes a malformed file (an R10 header over R14-only entities, and every
// hole as a polygon) that services like SendCutSend reject. Instead run
//   python tools/export_panel_dxf.py cad/cabinetFlat/sidePanel.scad
// which reads panelFeatures() below and writes a clean R12 DXF with true
// arcs and circles, in mm.

/* [Export] */
exportDXF      = false; // true: output the 2D face only (preview; see above)
echoFeatures   = false; // true: echo panelFeatures() for tools/export_panel_dxf.py
// The panel is taller than a printer bed, so the STL comes as two tiles, split
// across a band nothing crosses. They meet in a half-lap -- the upper tile's
// outer half over the lower tile's inner half -- glued, and bolted through
// with M3 button heads from outside and nuts inside; the seam-height corner
// blocks clamp it at each end. Cut from sheet, it stays one piece: the DXF is
// whole, without the lap bolts.
panelTile      = "tiles";   // [tiles, whole, upper, lower]

/* [Panel] */
// Defaults are the smallest panel that still carries everything. The hopper
// overhangs the top edge, which sits just above its upper bolt; the two sides
// are worked out below, from what sits inside against them.
panelFeederMin  = 100;  // past the drop axis toward the back (the feeder's side), at least -- meets the hopper face
panelAboveBolt  = 11;   // the top edge, above the hopper's highest bolt
panelBelowArm   = 76.2; // clear panel below the horn arm's underside (3 in)
panelCornerR    = 3;    // outside corners

/* [Holes] */
boltClearD   = 5.5;     // M5 clearance
armSlotW     = 44;      // slot the horn arm swings through
armSlotClear = 2;       // above and below the arm, in that slot
screwD       = 3.4;     // M3 clearance: into the corner blocks' heat-set inserts, and the lap bolts

// the top edge, just above the hopper's highest bolt; the hopper overhangs it
panelTop = max([for (b = hopperBolts) feederToWorld([clDist, b[0], b[1]])[2]]) + panelAboveBolt;

// The front side: just far enough out that the seam-height corner block there
// clears the heatsinks' round backs (and the holder) across its height.
function panelFarSideFor(split) =
    let (dz = min([for (z = [split - cornerBlock/2 : 1 : split + cornerBlock/2]) abs(z - leadZ)]))
    heatsinkReachX(dz) + 1 + cornerBlock + cabinetWallThk;
// how far the heatsinks reach across (x) at dz above or below the lead height
function heatsinkReachX(dz) =
    abs(dz) >= heatsinkH/2 ? heatsinkTipX : min(heatsinkBackX, heatsinkArcC + sqrt(heatsinkArcR^2 - dz^2));
panelFarSide = panelFarSideFor(panelSplitZ());
// The back side: far enough out that the Pico motor board (below), stood just
// off the back wall, clears the heatsinks' backs altogether.
panelFeederSide = max(panelFeederMin, cabinetWallThk + 1 + 66.802 + heatsinkBackX + 0.5);   // (66.802: the board across)

// Split line for printing: halfway across the widest band nothing crosses,
// between the heatsink holder's bottom bolt and the lead grommets, but raised
// if need be to keep the upper tile on the bed.
function panelSplitZ() =
    max(((leadZ - holderBoltOff + boltClearD/2) + (leadZ - ((coilTube + 2)/2 + grommetLip))) / 2,
        panelTop - (printBed - 10));

// The lead pass-throughs, one per lead, grown by d. The assembly uses them for
// the grommets too.
module lead_hole_2d(d = 0) {
    for (s = [1, -1])
        translate([s * leadGap/2, 0]) circle(d = coilTube + 2 + 2*d);
}

// Corner blocks: a screw into each at its middle. The seam-height ones sit on
// the seam, so their screw goes through both halves of the lap and holds both
// tiles -- one row of screws along the seam, with the lap screws.
cornerXs = [-panelFeederSide + cabinetWallThk + cornerBlock/2, panelFarSide - cabinetWallThk - cornerBlock/2];
function cornerZs() = let (bot = armBotZ - panelBelowArm)
    [bot + cabinetWallThk + cornerBlock/2, panelSplitZ(), panelTop - cabinetWallThk - cornerBlock/2];
// Lap bolts (printed tiles only), between the corner blocks where the inside is
// clear for a nut: between the back corner block and the heatsinks.
lapScrewXs = [(-panelFeederSide + cabinetWallThk + cornerBlock - (heatsinkSpacing/2 + heatsinkDepth + 1)) / 2];

// The Pico motor board (eamars Pico Motor Expansion Board v2) stands off the
// inside of this panel on four M3 standoffs, under the hopper, between the
// seam-height and top corner blocks: its USB edge right up against the back
// wall, where its ports come out. The assembly places it from
// here and checks it.
picoBoardSize  = [91.694, 66.802];                          // along its USB edge, across
picoHoleUs     = [5.08, 86.614];                            // its holes, along the USB edge...
picoHoleVs     = [5.08, 61.722];                            // ...and in from it
picoEdgeX      = -panelFeederSide + cabinetWallThk + 1;     // the USB edge, 1 mm off the back wall
// the top edge: as low as the heatsinks' round backs allow under the board's
// inboard edge, and in any case under the head of the hopper's lower bolt (M5,
// 9 across), so a key can reach that over the top of the board
picoTopZ       = min(leadZ + heatsinkReachAt(picoEdgeX + picoBoardSize[1]) + 1.5 + picoBoardSize[0],
                     min([for (b = hopperBolts) feederToWorld([clDist, b[0], b[1]])[2]]) - 9/2 - 2);
function picoBoardAt() = [picoEdgeX, picoTopZ];

// The hopper motor's cable comes in above the Pico board, toward the back
// edge, where the hopper doesn't cover the panel outside: a slot for its flat
// ribbon and rectangular connector.
motorCableAt   = [-75, 45];     // centre
motorCableSlot = [18, 8];       // across, and tall

// Every edge of the panel as a list of simple features, all in mm in the
// panel's own frame. The first is the outline; the rest are cut out of it.
// sidePanel2d() draws exactly this list, and tools/export_panel_dxf.py writes
// it to DXF, so the cut file always matches the part.
//   ["rrect",  x, y, w, h, r]   rectangle, corner at x,y, corners rounded r
//   ["rect",   x, y, w, h]      rectangle, corner at x,y
//   ["slot",   cx, cy, s, r]    obround: two radius-r ends, centres cx+/-s
//   ["circle", cx, cy, d]
function panelFeatures() =
    let (bot = armBotZ - panelBelowArm)
    concat(
        //outline
        [["rrect", -panelFeederSide, bot, panelFeederSide + panelFarSide, panelTop - bot, panelCornerR]],
        //slot the horn arm swings through
        [["rect", -armSlotW/2, armBotZ - armSlotClear, armSlotW, supportThickness + 2*armSlotClear]],
        //coil leads, one hole each, sized for the grommets
        [for (s = [1, -1]) ["circle", s * leadGap/2, leadZ, coilTube + 2 + 2*grommetLip]],
        //M5 clearance: the heatsink holder's bottom bolt, inside (its top one is the funnel's upper bolt)
        [["circle", 0, leadZ - holderBoltOff, boltClearD]],
        //M5 clearance: end of the funnel arm
        [for (z = funnelBoltZs) ["circle", 0, funnelZ + z, boltClearD]],
        //M5 clearance: hopper side block, where its bolts land on the wall
        [for (b = hopperBolts) let (p = feederToWorld([clDist, b[0], b[1]]))
            ["circle", p[0], p[2], boltClearD]],
        //M5 clearance: servo mount, inside
        [for (x = [-servoMountBoltX, servoMountBoltX])
            ["circle", x, servoMountTopZ - servoMountH/2, boltClearD]],
        //M3 clearance: the Pico motor board's standoffs, inside (the same holes serve a
        //right-hand build, the board turned end for end)
        [for (u = picoHoleUs, v = picoHoleVs) ["circle", picoEdgeX + v, picoTopZ - u, screwD]],
        //the hopper motor's cable, above the Pico board
        [["rrect", motorCableAt[0] - motorCableSlot[0]/2, motorCableAt[1] - motorCableSlot[1]/2,
          motorCableSlot[0], motorCableSlot[1], 1]],
        //M3 clearance: into the corner blocks
        [for (x = cornerXs, z = cornerZs()) ["circle", x, z, screwD]]
    );

module sidePanel2d() {
    features_2d(panelFeatures());
}

// Wrapped as a module so assembly/assembly.scad can place it.
module sidePanel() {
    flat_part(panelFeatures(), cabinetWallThk);
}

// One printing tile: "upper" or "lower" of the split line, meeting the other
// in the half-lap, with the lap bolts' holes (flatPanel.scad).
module sidePanelTile(which) {
    flat_tile(panelFeatures(), cabinetWallThk, panelSplitZ(), tileLap, which, lapScrewXs, screwD);
}

tileW = panelFeederSide + panelFarSide;
assert(tileW <= printBed, "the panel is wider than the printer bed");
assert(panelTop - (panelSplitZ() - tileLap/2) <= printBed
       && (panelSplitZ() + tileLap/2) - (armBotZ - panelBelowArm) <= printBed,
       "a panel tile is taller than the printer bed");
assert(panelSplitZ() - tileLap/2 >= leadZ - holderBoltOff + boltClearD/2 + 1
       && panelSplitZ() + tileLap/2 <= leadZ - ((coilTube + 2)/2 + grommetLip) - 1,
       "the tiles' half-lap runs into the heatsink holder's bolt or the lead grommets");

if (echoFeatures) echo(panelFeatures = panelFeatures());
if (exportDXF) sidePanel2d();
else if (panelTile == "whole") sidePanel();
else if (panelTile == "upper") sidePanelTile("upper");
else if (panelTile == "lower") sidePanelTile("lower");
else {
    // both, side by side for printing
    sidePanelTile("upper");
    translate([tileW + 10, 0, 0]) sidePanelTile("lower");
}
