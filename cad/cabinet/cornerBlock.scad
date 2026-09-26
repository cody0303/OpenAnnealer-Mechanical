include <../sharedDims.scad>

// Corner block for the cabinet: twelve of them, in the four vertical corners
// at the base, across the tile seam and under the lid (placed by
// boxLayout.scad). Every face screws into them with an M3 through the face
// into a heat-set insert in the middle of the block's face against it. The
// inserts are in three faces round one corner, so turned the right way the
// same block fits every place -- the two walls it sits against, and the base
// or lid for the bottom and top ones (the seam ones just leave that one
// empty). The seam ones sit centred on the seam, so their screws come in
// through the half-lap.
//
// Frame: the corner the insert faces meet at is the origin; the block runs
// +x, +y, +z from it. Prints on any face.

// Wrapped as a module so assembly/assembly.scad can place it.
module cornerBlock() {
    c = cornerBlock;
    difference() {
        cube(c);
        //inserts: into the x = 0, y = 0 and z = 0 faces, at their middles
        for (r = [[0, 90, 0], [-90, 0, 0], [0, 0, 0]])
            translate([c/2, c/2, c/2]) rotate(r) translate([0, 0, -c/2 - 0.01])
                cylinder(d=m3InsertD, h=m3InsertDepth + 0.01, $fn=24);
    }
}

cornerBlock();
