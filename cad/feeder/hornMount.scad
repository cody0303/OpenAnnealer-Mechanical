// Mount that captures the stock horn an MG90S ships with.
//
// The idea: don't reproduce the spline. Let the OEM horn stay on the spline
// where it belongs, and key your printed part to the HORN instead.
//
//   - a pocket matching the horn's arms takes the torque
//   - small self-tappers through the horn's existing holes hold it axially
//   - a central bore clears the horn's raised hub and still lets a driver
//     reach the servo's retaining screw after assembly
//
// Because the pocket does the driving, none of this needs to be precise --
// only the six numbers in the block below, all of which take a caliper and
// about two minutes. The values here are TYPICAL for a 9g horn and vary
// between vendors; measure yours.
//
// WHAT TO MEASURE:
//   1. hornThk      arm thickness (the flat part, not the hub)
//   2. armW         arm width -- measure at the tip, the widest point you must clear
//   3. armLen       centre of spline to the outer end of the arm
//   4. holeR/pitch  centre to the innermost hole, and hole-to-hole spacing
//   5. holeD        arm hole diameter
//   6. hubD / hubH  raised hub boss around the spline, and how far it stands
//                   proud of the arm's top face
//
// armCount: 1 = single, 2 = straight/double, 4 = cross/star.

/* [Stock horn -- MEASURE YOURS] */
armCount  = 2;
hornThk   = 1.5;
armW      = 5.0;
armLen    = 9.5;
holeR     = 4.5;    // centre to innermost hole
holePitch = 2.5;
holeCount = 3;
holeD     = 1.3;    // the horn's own holes; screws thread into the print below
hubD      = 7.0;
hubH      = 2.6;

/* [Fits] */
pocketClear = 0.25;  // added around the arms and hub so the horn drops in
screwPilotD = 1.5;   // pilot for a self-tapper pulling the print onto the horn
driverBoreD = 4.0;   // lets a driver reach the servo's central retaining screw

/* [Your part] */
leverLen   = 40;
plateH   = 6;        // must exceed hornThk + a bit of roof over the pocket
screwSize = 5;

$fn = 96;

// Negative of the horn: arms + hub boss, grown by pocketClear.
module horn_negative(clear = 0) {
    // arms
    for (i = [0 : armCount - 1])
        rotate([0, 0, i * 360 / (armCount == 1 ? 1 : armCount)])
            translate([0, 0, -0.01])
                linear_extrude(hornThk + clear + 0.01)
                    hull() {
                        circle(d = hubD + 2*clear);
                        translate([armLen, 0]) circle(d = armW + 2*clear);
                    }
    // raised hub boss, standing proud of the arm face
    translate([0, 0, -0.01])
        cylinder(d = hubD + 2*clear, h = hornThk + hubH + clear + 0.01);
}

difference(){
    //make the overall shape
    union(){
        //end where the screw goes
        translate([leverLen, 0, 0])
            cylinder(h=plateH, d=screwSize+4);
        //block for the horn interface
        translate([-(armLen+holeR), -(hubD+4)/2, 0])
            cube([(armLen+holeR)*2, hubD+4, plateH]);
        //nice tapered shape between them
        linear_extrude(height=plateH)
            polygon([[(armLen+holeR),(hubD+4)/2],[leverLen,(screwSize+4)/2],[leverLen,-(screwSize+4)/2],[(armLen+holeR),-(hubD+4)/2]]);
    }
    //horn pocket
    horn_negative(pocketClear);
    //screw hole
    translate([leverLen, 0, -1])
        cylinder(h=plateH+2, d=screwSize+0.2);
    //clearance for horn screw access
    translate([0, 0, -0.01])
        cylinder(d = driverBoreD, h = plateH + 0.02);
    //horn mating screws
    for (i = [0 : armCount - 1])
            rotate([0, 0, i * 360 / (armCount == 1 ? 1 : armCount)])
                for (j = [0 : holeCount - 1])
                    translate([holeR + j * holePitch, 0, hornThk - 0.01])
                        cylinder(d = screwPilotD, h = plateH);
}

