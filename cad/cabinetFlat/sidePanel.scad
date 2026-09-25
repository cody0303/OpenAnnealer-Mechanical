include <../feeder/layout.scad>

// Cabinet side panel -- the sheet the whole feeder stack bolts to: the
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

/* [Panel] */
// Defaults are the smallest panel that still carries everything. The hopper
// overhangs the top edge, which sits just above its upper bolt.
panelFeederSide = 100;  // past the drop axis on the feeder's side -- meets the hopper face at the top edge
panelFarSide    = 25;   // past the drop axis on the other side -- just clears the servo mount
panelTop        = 100;  // above the discharge exit
panelBelowArm   = 76.2; // clear panel below the horn arm's underside (3 in)
panelCornerR    = 3;    // outside corners

/* [Holes] */
boltClearD   = 5.5;     // M5 clearance
armSlotW     = 44;      // slot the horn arm swings through
armSlotClear = 2;       // above and below the arm, in that slot

// The lead pass-through: a slotted hole, grown by d. The assembly uses it for
// the grommet too.
module lead_hole_2d(d = 0) {
    hull() for (s = [1, -1])
        translate([s * leadGap/2, 0]) circle(d = coilTube + 2 + 2*d);
}

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
        //coil leads, sized for the grommet
        [["slot", 0, leadZ, leadGap/2, (coilTube + 2)/2 + grommetLip]],
        //M5 clearance: end of the funnel arm
        [for (z = funnelBoltZs) ["circle", 0, funnelZ + z, boltClearD]],
        //M5 clearance: hopper side block, where its bolts land on the wall
        [for (y = hopperBoltYs) let (p = feederToWorld([clDist, y, hopperBoltZ]))
            ["circle", p[0], p[2], boltClearD]],
        //M5 clearance: servo mount, inside
        [for (x = [-servoMountBoltX, servoMountBoltX])
            ["circle", x, servoMountTopZ - servoMountH/2, boltClearD]]
    );

module feature_2d(f) {
    if (f[0] == "rrect")
        translate([f[1], f[2]])
            offset(r=f[5]) offset(delta=-f[5]) square([f[3], f[4]]);
    else if (f[0] == "rect")
        translate([f[1], f[2]]) square([f[3], f[4]]);
    else if (f[0] == "slot")
        hull() for (s = [1, -1]) translate([f[1] + s*f[3], f[2]]) circle(r=f[4]);
    else if (f[0] == "circle")
        translate([f[1], f[2]]) circle(d=f[3]);
}

module sidePanel2d() {
    features = panelFeatures();
    difference(){
        feature_2d(features[0]);
        for (i = [1 : len(features) - 1])
            feature_2d(features[i]);
    }
}

// Wrapped as a module so assembly/assembly.scad can place it.
module sidePanel() {
    linear_extrude(height=cabinetWallThk)
        sidePanel2d();
}

if (echoFeatures) echo(panelFeatures = panelFeatures());
if (exportDXF) sidePanel2d();
else sidePanel();
