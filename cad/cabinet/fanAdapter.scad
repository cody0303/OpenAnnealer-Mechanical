include <../sharedDims.scad>

// Duct for the driver board's fan. It sits low on the inside of the cabinet's
// front wall, at the left end, over a grille, and tips the fan by angle, so it
// pulls air in from outside and blows it back and right, down the driver
// board's heatsink. The fan's seat is slid across from the inlet (offsetX) so
// the inlet clears the front-left corner block.
//   wall: M3 screws through the wall into heat-set inserts in the inlet face,
//         on the fan's own square hole pattern -- so for a right-hand build
//         the same part just turns end for end
//   fan:  M3 screws through the fan into heat-set inserts in the seat's
//         corners, on the same pattern
// Its bottom rests on the floor.
//
// Frame: the inlet face on z = 0 (against the wall), centred on x = y = 0, the
// duct running up +z; the fan's axis tips toward +x. Prints on the inlet face:
// the passage is narrowed on the +x side of the inlet so no inside wall leans
// past 45 deg, and its corners are filled solid from inlet to seat.

angle    = 30;      // the fan's axis, off square to the wall
offsetX  = -10;     // the seat's centre, across from the inlet's
wall     = 2;
lipT     = 3;       // the inlet's lip against the wall
plateT   = 8;       // the fan's seat -- thick enough for its inserts
seatRise = 4;       // the seat, higher than it needs to be to clear the lip
bossD    = 8;       // round the inlet's inserts
cornerW  = 9;       // the passage's filled corners

s  = driverFanSize;
bore = s - 3;       // the fan's open bore, through the seat
p  = driverFanHolePitch;

// the seat: its underside through c, facing n, u across it
n = [sin(angle), 0, cos(angle)];
u = [cos(angle), 0, -sin(angle)];
seatZ = lipT + 1 + (s/2 + wall) * sin(angle) + seatRise;
c = [offsetX, 0, seatZ];
// the inlet's +x edge: in far enough that the passage's wall on that side,
// from there up to the bore's edge, leans no more than 45 deg
boreEdge = c + (bore/2) * u;
inletX1 = min(s/2, boreEdge[0] + boreEdge[2]);

assert(p/2 + bossD/2 <= s/2 && p*sqrt(2)/2 - m3InsertD/2 >= bore/2 + 1,
       "the inserts don't fit between the fan's bore and the duct's edge");

// the seat's frame: x along u, z along n, origin at the centre of its underside
module on_seat() {
    multmatrix([[u[0], 0, n[0], c[0]], [0, 1, 0, c[1]], [u[2], 0, n[2], c[2]], [0, 0, 0, 1]]) children();
}

//for the assembly: the adapter and fan's reach across (x) -- overall on the +x
//side, and on the -x side within depth d of the wall -- how far it stands off
//the wall, the inserts' positions on the wall face, and the inlet opening
seatPts = [for (i = [-1, 1], j = [0, plateT + driverFanDepth]) c + i*(s/2)*u + j*n];
function fanAdapterMaxX() = max(s/2 + wall, max([for (q = seatPts) q[0]]));
function fanAdapterMinX(d) =
    let (e0 = [-(s/2 + wall), lipT], e1 = [c[0] - (s/2)*u[0], c[2] - (s/2)*u[2]])   // lip edge, seat's -x edge
    d <= e0[1] || e1[0] >= e0[0] ? e0[0]
  : d >= e1[1] ? e1[0]
  : e0[0] + (e1[0] - e0[0]) * (d - e0[1]) / (e1[1] - e0[1]);
function fanAdapterDepth() = max([for (q = seatPts) q[2]]);
function fanAdapterScrews() = [for (i = [-1, 1], j = [-1, 1]) [i*p/2, j*p/2]];
function fanAdapterSeatT() = plateT;                          // the fan sits on the seat this far out
function fanAdapterInlet() = [[-s/2, inletX1], [-s/2, s/2]];     // the opening on the wall: x, y

// a corner of the passage, filled solid from the inlet up to the seat
module corner_fill(i, j) {
    hull() {
        translate([i > 0 ? s/2 - cornerW : -s/2, j > 0 ? s/2 - cornerW : -s/2, -1]) cube([cornerW, cornerW, 1.01]);
        on_seat() translate([i > 0 ? s/2 - cornerW : -s/2, j > 0 ? s/2 - cornerW : -s/2, -0.01]) cube([cornerW, cornerW, 0.02]);
    }
}

module fanAdapter() {
    difference() {
        union() {
            hull() {
                translate([-s/2 - wall, -s/2 - wall, 0]) cube([s + 2*wall, s + 2*wall, lipT]);
                on_seat() translate([-s/2, -s/2, 0]) cube([s, s, plateT]);
            }
            //bosses for the wall's inserts: inside the corner fills on the -x side, standing
            //just outside the (short) duct on the +x side
            for (q = fanAdapterScrews()) translate([q[0], q[1], 0]) cylinder(d=bossD, h=m3InsertDepth + 1.5, $fn=36);
        }
        //the passage, from the inlet up to the fan's bore, its corners filled
        difference() {
            hull() {
                translate([-s/2, -s/2, -1]) cube([inletX1 + s/2, s, 1.01]);
                on_seat() cylinder(d=bore, h=0.01);
            }
            for (i = [-1, 1], j = [-1, 1]) corner_fill(i, j);
            for (q = fanAdapterScrews()) translate([q[0], q[1], -2]) cylinder(d=bossD, h=m3InsertDepth + 3.5, $fn=36);
        }
        on_seat() translate([0, 0, -1]) cylinder(d=bore, h=plateT + 2);
        //heat-set inserts: the fan's, down into the seat's corners...
        on_seat() for (q = fanAdapterScrews())
            translate([q[0], q[1], plateT - m3InsertDepth]) cylinder(d=m3InsertD, h=m3InsertDepth + 0.01, $fn=24);
        //...and the wall's, up into the inlet face, on the same pattern
        for (q = fanAdapterScrews()) translate([q[0], q[1], -0.01]) cylinder(d=m3InsertD, h=m3InsertDepth + 0.01, $fn=24);
    }
}

fanAdapter();
