include <../sharedDims.scad>

// Cradle for the harvested heater's transformer: a bridge over the driver
// board. A slab lies under the transformer, its top face along the
// transformer's underside, on a leg either side of the board down to the
// cabinet floor, where M3 screws come up into heat-set inserts in the feet.
// Two zip ties go over the transformer and down through the slab either
// side of it; snug slots keep them from sliding, and they're all that holds
// the transformer along its slope.
//
// Prints on the slab's top face: the slab spans leg to leg within its
// layers, and the legs are walls carrying the load straight down. Their
// edges lean 45 deg; the tie slots come out vertical.
//
// Frame: X front to back as in the assembly, but centred on the
// transformer's axis; Y to the right, along its run; Z up. The origin is on
// the floor under the centre of its left (upper) end face. Everything under
// "keep in step" has to match cad/cabinet/boxLayout.scad, which checks it.

/* [Transformer and board -- keep in step with boxLayout.scad] */
xfmrD      = 63.5;  // transformer diameter...
xfmrLen    = 90;    // ...and length
tilt       = 15;    // its axis, below horizontal
endH       = 101;   // its axis above the floor, at its left (upper) end face
boardTopH  = 44;    // the driver board's top above the floor (it lies under the transformer)...
boardHalfW = 22;    // ...and its farther edge from the axis

/* [Cradle] */
slabT     = 8;
slabFrom  = 10;     // along the transformer from its left end...
slabTo    = 60;     // ...to here, where the legs end -- any further and the slab drops onto the board
legTo     = 60;     // the legs carry the slab this far along (no further than slabTo)
legX      = [38, 46];   // each leg, off the axis
footLen   = 45;     // along Y, on the floor

/* [Zip ties] */
tieW      = 5.5;    // slot along the transformer, for ties up to ~4.8 wide (a tie over the
tieT      = 2.5;    // transformer lies flat on it)... and across, for ties up to ~1.3 thick
tieAt     = [20, 50];   // along the transformer from its left end -- on the slab, 10 in from each end
tieX      = 22;     // either side of the axis

r = xfmrD/2;
slabLow = endH - slabTo*sin(tilt) - (r + slabT)*cos(tilt);   // the slab's lowest point, above the floor
assert(slabLow >= boardTopH + 3, "the slab drops onto the driver board");
assert(endH - xfmrLen*sin(tilt) - r*cos(tilt) >= boardTopH + 3, "the transformer's lower end drops onto the driver board");
assert(legTo <= slabTo, "the legs run past the slab");
assert(min(tieAt) - tieW/2 >= slabFrom + 3 && max(tieAt) + tieW/2 <= slabTo - 3, "the zip tie slots run off the slab");
assert(legX[0] >= boardHalfW + 2, "the legs run into the driver board");
assert(legX[0] > r + 2, "the legs run into the transformer");
// the feet, along Y: centred under the legs' stretch of the slab
footMidY = ((slabFrom + legTo)/2)*cos(tilt) - (r + slabT/2)*sin(tilt);

//for the assembly: what the cradle was drawn for, and where its feet's screws go (x, y)
function transformerCradleFit() = [xfmrD, xfmrLen, tilt, endH, boardTopH, boardHalfW];
function transformerCradleFootHoles() =
    [for (s = [1, -1], y = [-1, 1]) [s*(legX[0] + legX[1])/2, footMidY + y*(footLen/2 - 7)]];

// the transformer's frame: X across, Y along its axis from the left end face,
// Z square to both (up, away from the underside); it occupies |(x, z)| <= r
module axis_frame() {
    multmatrix([[1, 0,          0,          0],
                [0, cos(tilt),  sin(tilt),  0],
                [0, -sin(tilt), cos(tilt),  endH],
                [0, 0,          0,          1]]) children();
}

module slab(x0, x1, t1 = slabTo) { axis_frame() translate([x0, slabFrom, -r - slabT]) cube([x1 - x0, t1 - slabFrom, slabT]); }

module transformerCradle() {
    difference() {
        union() {
            slab(-legX[1], legX[1]);
            //legs: the slab's ends, down to the floor
            for (s = [1, -1]) mirror([s < 0 ? 1 : 0, 0, 0]) hull() {
                slab(legX[0], legX[1], legTo);
                translate([legX[0], footMidY - footLen/2, 0]) cube([legX[1] - legX[0], footLen, 1]);
            }
        }
        //zip tie slots, through the slab either side of the transformer
        for (y = tieAt, x = [-tieX, tieX])
            axis_frame() translate([x - tieT/2, y - tieW/2, -r - slabT - 1]) cube([tieT, tieW, slabT + 2]);
        //M3 heat-set inserts up into the feet, for screws from under the floor
        for (h = transformerCradleFootHoles())
            translate([h[0], h[1], -1]) cylinder(d=m3InsertD, h=m3InsertDepth + 1, $fn=24);
    }
}

// Laid for printing: on the slab's top face, the legs straight up.
module transformerCradle_print() {
    translate([0, 0, -r]) rotate([180, 0, 0])
        multmatrix([[1, 0, 0, 0], [0, cos(tilt), -sin(tilt), 0], [0, sin(tilt), cos(tilt), 0], [0, 0, 0, 1]])
            translate([0, 0, -endH]) transformerCradle();
}

transformerCradle_print();
