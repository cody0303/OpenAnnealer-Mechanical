include <../feeder/layout.scad>
use <sidePanel.scad>
use <../cabinet/fanAdapter.scad>
use <../cabinet/screenTilt.scad>
use <../cabinet/transformerCradle.scad>
use <../cabinet/flatPanel.scad>

// The cabinet's back wall: the Pico motor board's two USB ports come out
// through it, and it screws into the corner blocks. Split for printing at
// the tile seam, like the left panel.
//
// Drawn flat, as seen from outside the cabinet (boxLayout.scad has the
// frame). Everything about where its holes go is in boxLayout.scad, shared
// with the assembly. For laser/waterjet cutting, export the DXF with
//   python tools/export_panel_dxf.py cad/cabinetFlat/backWall.scad

/* [Export] */
exportDXF    = false;   // true: output the 2D face only (preview; use the script for a real DXF)
echoFeatures = false;   // true: echo the features for tools/export_panel_dxf.py
panelTile    = "tiles"; // [tiles, whole, upper, lower]
feederSide   = "left";  // [left, right] -- which build this face is for

hand = (feederSide == "right") ? -1 : 1;
include <../cabinet/boxLayout.scad>

features = hand > 0 ? faceFeatures("back") : mirror_features(faceFeatures("back"));
assert(features[0][3] <= printBed, "this face is wider than the printer bed");
assert(boxZ1 - (seamZ - tileLap/2) <= printBed && (seamZ + tileLap/2) - boxZ0 <= printBed,
       "a tile of this face is taller than the printer bed");
lapXs = hand > 0 ? faceLapXs("back") : [for (x = faceLapXs("back")) -x];

if (echoFeatures) echo(panelFeatures = features);
flat_export(features, cabinetWallThk, exportDXF, seamZ, tileLap, lapXs, panelTile);
