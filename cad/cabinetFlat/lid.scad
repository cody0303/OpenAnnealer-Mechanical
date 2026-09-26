include <../feeder/layout.scad>
use <sidePanel.scad>
use <../cabinet/fanAdapter.scad>
use <../cabinet/screenTilt.scad>
use <../cabinet/transformerCradle.scad>
use <../cabinet/flatPanel.scad>

// The cabinet's lid: sits inside the walls' tops and screws down into the
// top corner blocks. Nothing else on it, so it lifts off for servicing.
// Prints whole.
//
// Drawn flat, as seen from outside the cabinet (boxLayout.scad has the
// frame). Everything about where its holes go is in boxLayout.scad, shared
// with the assembly. For laser/waterjet cutting, export the DXF with
//   python tools/export_panel_dxf.py cad/cabinetFlat/lid.scad

/* [Export] */
exportDXF    = false;   // true: output the 2D face only (preview; use the script for a real DXF)
echoFeatures = false;   // true: echo the features for tools/export_panel_dxf.py
feederSide   = "left";  // [left, right] -- which build this face is for

hand = (feederSide == "right") ? -1 : 1;
include <../cabinet/boxLayout.scad>

features = hand > 0 ? faceFeatures("lid") : mirror_features(faceFeatures("lid"));
assert(features[0][3] <= printBed && features[0][4] <= printBed, "this face is bigger than the printer bed");

if (echoFeatures) echo(panelFeatures = features);
flat_export(features, cabinetWallThk, exportDXF);
