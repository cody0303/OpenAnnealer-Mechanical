use <../../catchnhole/catchnhole.scad>;
include <../feeder/layout.scad>     //sharedDims (the heatsinks), and where the funnel's bolts are

// Stands inside the cabinet on the left panel, its +X end face on the wall,
// centred between the coil's leads (z = 0 is the lead height). The heatsinks
// bolt to its sides with M4s into heat-set inserts. They can sit wallBackset
// back from the wall: the bosses and web reach across the gap to it.
//   top boss:    the funnel's upper M5, shared -- in from inside the cabinet,
//                down a counterbore and through here and the wall, into the
//                funnel's nut catch
//   bottom boss: an M5 in from outside the cabinet, into a nut caught here
// The bottom M5 and the funnel's lower one are screwLen long; the top one is
// topScrewLen, which sets how much holder is left under its head.
//   web:         a pocket at the wall end for the funnel's lower bolt head

holderLength=38;
          //the heatsinks' wall end, off the wall
heatsinkInsideLat=18;
mountingBossHeight=15;
attachmentScrewBackset=20;

bossZ = holderBoltOff;                              //centre of each mounting boss, off the lead height
funnelHeadZ = funnelZ + funnelBoltZs[0] - leadZ;    //the funnel's lower bolt, off the lead height

screwLen    = 20;   //the bottom M5, and the funnel's lower one
topScrewLen = 25;   //the top M5, shared with the funnel
headCbD     = 10;   //counterbore for an M5 socket cap head (8.5)
//the top bolt's head seats this far from the wall, so it passes 1 mm through the funnel's nut
//(which is caught wallThickness in from the funnel's wall end)
topSeat = topScrewLen - cabinetWallThk - (wallThickness + nut_height("M5") + 0.2 + 1);
assert(topSeat >= 5, "too little holder under the top bolt's head -- use a longer topScrewLen");
assert(topSeat < holderLength + wallBackset - 5, "the top bolt's head sits almost out of the holder -- use a shorter topScrewLen");
assert(screwLen - cabinetWallThk <= wallThickness + nut_height("M5") + 5,
       "screwLen bottoms out in the funnel's and the bottom boss's bolt holes");

assert(bossZ - mountingBossHeight/2 >= heatsinkH/2 + 1, "the bosses run into the heatsinks' fins");
assert(8/2 <= heatsinkSpacing/2 - heatsinkFinReach - 0.5, "the web runs into the heatsinks' fins");

//for the assembly: overall size (wall face to inner end), and how far the heatsinks sit off the wall
function heatsinkHolderSize() = [holderLength + wallBackset, heatsinkSpacing, 2*bossZ + mountingBossHeight];
function heatsinkHolderBackset() = wallBackset;

wallX = holderLength/2 + wallBackset;   //the wall face (the heatsinks span -holderLength/2..holderLength/2)

module mirror_copy(v = [1, 0, 0]) {
    children();
    mirror(v) children();
}

// Wrapped as a module so assembly/assembly.scad can place it.
module heatsinkHolder() {
    difference(){
        union(){
            cube([holderLength, heatsinkSpacing, heatsinkInsideLat], center=true);
            //the web and bosses run on to the wall
            translate([wallBackset/2, 0, 0]) {
                cube([holderLength + wallBackset, 8, 2*bossZ], center=true);
                mirror_copy([0,0,1])
                    translate([0,0,bossZ])
                        cube([holderLength + wallBackset, heatsinkSpacing, mountingBossHeight], center=true);
            }
        }
        //top: the funnel's upper M5, straight through, counterbored from the inner end so the
        //head seats topSeat from the wall
        translate([wallX, 0, bossZ])
            rotate([0,-90,0]) {
                bolt("M5", length=holderLength+wallBackset+1, kind="headless", length_clearance=1);
                translate([0, 0, topSeat]) cylinder(d=headCbD, h=holderLength+wallBackset);
            }
        mirror([0,0,1]){
            //bottom: an M5 in through the end face, its nut caught wallThickness behind it
            translate([wallX-wallThickness, 0, bossZ])
                rotate([90,0,-90])
                    nutcatch_sidecut("M5", "hexagon", height_clearance=0.2, width_clearance=0.2);
            //bolt hole from the end face, on past the nut for the bolt's tip
            translate([wallX, 0, bossZ])
                rotate([0,-90,0])
                    bolt("M5", length=(wallThickness+nut_height("M5")+5), kind="headless", length_clearance=1);
        }
        //the funnel's lower bolt head (M5 socket cap, 8.5 x 5), in a pocket at the wall end
        translate([wallX+1, 0, funnelHeadZ])
            rotate([0,-90,0])
                cylinder(d=10, h=6+1);
        //M4 heat-set insert in the side face (the part is centred, so that face is at heatsinkSpacing/2);
        //starts 1 mm outside it for a clean cut
        mirror_copy([0,1,0])
            translate([(holderLength/2)-attachmentScrewBackset, heatsinkSpacing/2+1, 0])
                rotate([90,0,0])
                    cylinder(h=m4InsertDepth+1, d=m4InsertD);
    }
}

heatsinkHolder();
