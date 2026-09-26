include <../sharedDims.scad>

// Tilted housing for the BIGTREETECH Mini12864 V2.0 display, on the outside
// of a cabinet wall. The display face tips back by screenTilt so it looks up
// at the user; 0 is flush with the wall.
//
// The board screws to standoffs behind the face, display and knob through
// it. The back is open to a matching window in the wall, which the board's
// EXP connectors and ribbons pass through. It's held by four M3 screws from
// inside the cabinet, through the wall into heat-set inserts in the four ears
// (M3 x 10 through the 6 mm wall). screenTiltWallFeatures() gives the wall its
// window and screw holes, in the same form as panelFeatures() in
// cad/cabinetFlat/sidePanel.scad.
//
// Frame: X across the display, Y up the wall, Z out of it. The back face is
// z = 0 on the wall, centred on x = 0, lowest point at y = 0. The part is
// drawn installed; the top-level call lays it face-down for printing, and
// every wall then leans at most screenTilt, so 0-45 prints without supports.

/* [Tilt] */
screenTilt = 20;        // [0:1:45]

/* [Mini12864 V2.0 -- from the BTT dimension drawing] */
// Positions are as the drawing gives them: mm from the board's bottom-left
// corner, looking at the display side.
pcbW       = 104.99;
pcbH       = 47;
pcbThk     = 1.6;
pcbHoles   = [[8.99, 3], [8.99, 44], [101.99, 3], [101.99, 44]];
lcdView    = [14.5, 10.5, 67.75, 40.25];    // measured: x0, y0, x1, y1 of the visible pixel area
lcdMargin  = 0.5;       // window clearance round the visible area, each side
lcdBevel   = 1.5;       // window opens out this much at the front (45 deg), so the face's
                        // thickness doesn't shade the edge pixels when you look down at it
knobAt     = [104.99 - (18.47 + 7.29)/2, (20.78 + 32.71)/2];   // centre of the encoder outline
knobHoleD  = 24;        // big on purpose: takes in the two LEDs either side of the encoder (~9 mm off
                        // its centre on the drawing), so they light the knob and glow round its skirt
knobBackAt = 10.25;     // measured: board face to the back of the knob
resetAt    = [104.99 - 12.53, 8.71];
resetBodyH = 4;         // measured: board face to the top of the reset button's body...
resetStemH = 4 + 3.25;  // ...and to the top of its stem
// The reset (back/stop) is pressed with a fingertip, so it sits at the bottom
// of a wide funnel reaching in from the face, with its stem coming up through
// the hole in the bottom. The opening is centred below the button, away from
// the knob hole, and every wall leans in at 45 deg or less away from the face,
// so it prints face-down without support.
resetStemIn   = 2.5;    // how far the stem comes up into the well
resetHoleD    = 5;      // the well's bottom, round the stem -- ASSUMED stem up to ~4 mm across
resetWellD    = 10;     // opening in the face
resetWellDrop = 0.5;    // ...centred this far below the button, away from the knob hole
resetWellWall = 1.6;
frontStack = 6.1;       // measured: board face to the front of the LCD (= standoff height)

/* [Housing] */
wallT          = 2.4;   // sides, top and bottom
plateT         = 2;     // the face the display looks through
clr            = 1;     // around the board
backClr        = 0.5;   // behind the board, at its closest to the wall
standoffD      = 6;
standoffPilotD = 2.5;   // M3 self-tapper into the standoff (the board's holes are 3 mm)
earW           = 10;    // mounting ears, off each side
earH           = 10;    // each ear takes an M3 heat-set insert: m3InsertD / m3InsertDepth, in sharedDims
wallScrewD     = 3.4;   // M3 clearance, in the cabinet wall

assert(frontStack + plateT < knobBackAt,
       "the face would touch the back of the knob -- thin plateT or lower the standoffs");

// ---------------------------------------------------------------------------
// Derived
// ---------------------------------------------------------------------------
// drawing coordinates (from the board's corner) to board-centred ones
function fromCentre(p) = [p[0] - pcbW/2, p[1] - pcbH/2];
lcdWinSize = [lcdView[2] - lcdView[0] + 2*lcdMargin, lcdView[3] - lcdView[1] + 2*lcdMargin];
lcdWinAt   = fromCentre([(lcdView[0] + lcdView[2])/2, (lcdView[1] + lcdView[3])/2]);

boxW   = pcbW + 2*clr + 2*wallT;
boxH   = pcbH + 2*clr + 2*wallT;
boxDep = plateT + frontStack + pcbThk + backClr;

resetWellDepth = plateT + frontStack - resetStemH + resetStemIn;   // face to the well bottom
resetWellAt    = fromCentre(resetAt) - [0, resetWellDrop];          // centre of the opening
assert(resetWellDepth > plateT, "the reset stem reaches the face -- no well needed");
assert(resetWellDepth <= plateT + frontStack - resetBodyH - 0.5,
       "the reset well's bottom hits the button's body -- cut resetStemIn");
assert(resetWellD/2 + resetWellDrop - resetHoleD/2 <= resetWellDepth,
       "the reset well's lower wall leans past 45 deg -- narrow resetWellD or cut resetWellDrop");
assert(norm(fromCentre(knobAt) - resetWellAt) - knobHoleD/2 - resetWellD/2 >= 1,
       "the reset well runs into the knob hole -- narrow resetWellD");
assert(resetWellAt[1] - resetWellD/2 >= -(pcbH/2 + clr),
       "the reset well runs into the bottom wall -- narrow resetWellD or cut resetWellDrop");

// The housing is a box square to the display face (the "plate frame": x
// across, y up the face, z out of it, z = 0 on the outer face), hulled back
// to the wall. Placed so its back-top edge just touches the wall and its
// lowest corner sits at y = 0.
function plateOrigin(a) = [0, (boxH/2)*cos(a) + boxDep*sin(a), (boxH/2)*sin(a) + boxDep*cos(a)];

module in_plate_frame(a) {
    o = plateOrigin(a);
    multmatrix([[1, 0,      0,      o[0]],
                [0, cos(a), sin(a), o[1]],
                [0, -sin(a), cos(a), o[2]],
                [0, 0,      0,      1]])
        children();
}

// a box in the plate frame, hulled onto the wall (or 1 mm past it, to open it)
module hulled_to_wall(a, w, h, z0, z1, pastWall = 0) {
    hull() {
        in_plate_frame(a) translate([-w/2, -h/2, z0]) cube([w, h, z1 - z0]);
        translate([0, 0, -pastWall])
            linear_extrude(pastWall + 0.01)
                projection() in_plate_frame(a) translate([-w/2, -h/2, z0]) cube([w, h, z1 - z0]);
    }
}

// the reset well in the plate frame: its hollow, or grown by g for its shell
// (the hollow runs out past the face by `past`)
module reset_well(g = 0, past = 0) {
    hull() {
        translate([resetWellAt[0], resetWellAt[1], -0.01]) cylinder(d=resetWellD + 2*g, h=0.01 + past);
        translate(concat(fromCentre(resetAt), -resetWellDepth)) cylinder(d=resetHoleD + 2*g, h=0.01);
    }
}

function earYs(a) = let (top = plateOrigin(a)[1] + (boxH/2)*cos(a)) [earH/2, top - earH/2];
// how far the housing stands off the wall at height y: its front face above
// the bottom-front corner, its sloping underside below it
function hullDepthAt(a, y) =
    let (o = plateOrigin(a))
    (y >= boxDep*sin(a)) ? o[2] - (y - o[1])*tan(a)
                         : boxH*sin(a) + y/tan(a);

module screenTilt(a = screenTilt) {
    for (y = earYs(a))
        assert(min(hullDepthAt(a, y - m3InsertD/2), hullDepthAt(a, y + m3InsertD/2)) >= m3InsertDepth + 1,
               "an ear is too shallow for its heat-set insert at this tilt -- shorten m3InsertDepth or lower earH");
    holes = [for (h = pcbHoles) fromCentre(h)];
    knob  = fromCentre(knobAt);
    reset = fromCentre(resetAt);
    difference(){
        union(){
            //shell
            difference(){
                hulled_to_wall(a, boxW, boxH, -boxDep, 0);
                hulled_to_wall(a, boxW - 2*wallT, boxH - 2*wallT, -boxDep - 1, -plateT, 1);
            }
            //mounting ears, off each side: the same hull, widened, cut down to
            //short tabs outside the side walls
            intersection(){
                hulled_to_wall(a, boxW + 2*earW, boxH, -boxDep, 0);
                union() for (sx = [-1, 1], y = earYs(a))
                    translate([sx > 0 ? boxW/2 - 0.01 : -boxW/2 - earW + 0.01, y - earH/2, -1])
                        cube([earW, earH, 200]);
            }
            //standoffs for the board, behind the face
            in_plate_frame(a)
                for (p = holes)
                    translate([p[0], p[1], -plateT - frontStack])
                        cylinder(d=standoffD, h=frontStack + 0.01);
            //reset well, reaching in from the face toward the button
            in_plate_frame(a)
                reset_well(resetWellWall);
        }

        //display, knob and reset through the face
        in_plate_frame(a) {
            translate([lcdWinAt[0], lcdWinAt[1], 0]) {
                //straight through the face...
                cube([lcdWinSize[0], lcdWinSize[1], 2*plateT + 2], center=true);
                //...then bevelled open toward the front
                hull() {
                    translate([0, 0, -lcdBevel]) cube([lcdWinSize[0], lcdWinSize[1], 0.01], center=true);
                    translate([0, 0, 0.01]) cube([lcdWinSize[0] + 2*lcdBevel, lcdWinSize[1] + 2*lcdBevel, 0.02], center=true);
                }
            }
            translate([knob[0], knob[1], -plateT - 1])
                cylinder(d=knobHoleD, h=plateT + 2);
            translate([reset[0], reset[1], -resetWellDepth - 1])
                cylinder(d=resetHoleD, h=resetWellDepth + 2);
            reset_well(0, 0.01);
            //standoff pilots
            for (p = holes)
                translate([p[0], p[1], -plateT - frontStack - 1])
                    cylinder(d=standoffPilotD, h=frontStack);
        }

        //heat-set insert holes in the ears, from the wall side
        for (sx = [-1, 1], y = earYs(a))
            translate([sx*(boxW/2 + earW/2), y, -1])
                cylinder(d=m3InsertD, h=m3InsertDepth + 1);
    }
}

// What the cabinet wall needs: the window behind the housing and the four
// screw holes, in this part's frame (x across, y up from the housing's lowest
// point). Same feature form as panelFeatures() in sidePanel.scad.
function screenTiltWallFeatures(a = screenTilt) =
    let (o    = plateOrigin(a),
         ih   = boxH - 2*wallT,
         yLo  = o[1] - (ih/2)*cos(a) - boxDep*sin(a),
         yHi  = o[1] + (ih/2)*cos(a) - plateT*sin(a))
    concat(
        [["rect", -(boxW/2 - wallT), yLo, boxW - 2*wallT, yHi - yLo]],
        [for (sx = [-1, 1], y = earYs(a)) ["circle", sx*(boxW/2 + earW/2), y, wallScrewD]]
    );

// Face-down for printing: turn the face's outward normal to -Z, then sit it
// on the bed.
module screenTilt_print(a = screenTilt) {
    r = a - 180;
    o = plateOrigin(a);
    // the outer face passes through the plate origin; after the turn it's the lowest point
    zFace = o[1]*sin(r) + o[2]*cos(r);
    translate([0, 0, -zFace]) rotate([r, 0, 0]) screenTilt(a);
}

screenTilt_print();
