include <../feeder/layout.scad>
use <../../catchnhole/catchnhole.scad>;

// Holds the MG90S end-on, short end toward the cabinet wall, so the arm's
// swing is symmetric about it and the same mount works with the feeder on
// either side. The servo drops into the pocket from above and hangs on its
// ears; M5 bolts come in through the cabinet wall into captive nuts, the same
// way the hopper and funnel mount.
//
// Origin: output shaft axis. z = 0 is the top face, where the ears sit. The
// face that bolts to the wall is at y = -(servoBackset - cabinetWallThk), so
// +Y points away from the wall, into the cabinet.

//servoClear, servoMountH and servoMountBoltX come from layout.scad, which
//the side panel shares, so its bolt holes always line up with this part
earPilotD   = 1.6;                                      //self-tappers through the servo's ears
mountH      = servoMountH;                              //ear underside down to the case bottom
mountWallY  = -(servoBackset - cabinetWallThk);         //the face against the wall
bodyCenterY = servoBodyL/2 - servoShaftToEnd;           //case centre, from the shaft
mountFarY   = bodyCenterY + servoEarSpan/2 + 3;         //just past the far ear's tip
mountBoltX  = servoMountBoltX;
mountHalfW  = mountBoltX + wallThickness + 4;
//the servo's cable leaves the case at its wall-side end, low down: a notch through
//the mount's end there, open at the bottom, lets it bend straight down against the wall.
//It's set by what's left above it: tilted in for insertion, the servo's cable dips
//to 8 mm below the ears' underside, so no more than that (the wall-side ear's pilot
//breaks into the notch -- fine)
cableNotchW    = 6;
cableNotchRoof = 7;                                     //mount left above the notch -- 8 at most
cableNotchH    = mountH - cableNotchRoof;               //up from the case bottom

assert(bodyCenterY - servoEarSpan/2 > mountWallY,
       "the servo's wall-side ear hits the cabinet wall -- increase servoBackset");
assert(cableNotchRoof <= 8, "the cable notch is too shallow for the servo's cable as it's tilted in");

// Wrapped as a module so assembly/assembly.scad can place it.
module servoMount() {
    difference(){
        //main block
        translate([-mountHalfW, mountWallY, -mountH])
            cube([2*mountHalfW, mountFarY-mountWallY, mountH]);

        //pocket the case drops through
        translate([-(servoBodyW/2+servoClear), -(servoShaftToEnd+servoClear), -mountH-1])
            cube([servoBodyW+2*servoClear, servoBodyL+2*servoClear, mountH+2]);

        //notch for the servo's cable, at the wall-side end
        translate([-cableNotchW/2, mountWallY - 1, -mountH - 1])
            cube([cableNotchW, -(servoShaftToEnd + servoClear) - mountWallY + 2, cableNotchH + 1]);

        //pilots for the ear screws
        for (y = [bodyCenterY-servoEarHolePitch/2, bodyCenterY+servoEarHolePitch/2])
            translate([0, y, -8])
                cylinder(h=9, d=earPilotD);

        //mounting nut interface, mirrored so the mount is symmetric
        for (side = [0, 1]) mirror([side, 0, 0]) {
            translate([mountBoltX, mountWallY+wallThickness, -mountH/2])
                rotate([-90,0,0])
                    nutcatch_sidecut("M5", "hexagon", height_clearance=0.2, width_clearance=0.2);
            translate([mountBoltX, mountWallY, -mountH/2])
                rotate([-90,0,0])
                    bolt("M5", length=(wallThickness+nut_height("M5")+5), kind="headless", length_clearance=1);
        }
    }
}

servoMount();
