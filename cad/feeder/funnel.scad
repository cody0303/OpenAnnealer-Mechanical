include <sharedDims.scad>
use <../../catchnhole/catchnhole.scad>;

//=[exitDia/2,0];
p0=[0,0];
p1=[0,funnelHeight];
p2o=[(topDia/2)+wallThickness,funnelHeight];
//=[(topDia/2)+wallThickness,funnelHeight];
p3o=[(exitDia/2)+wallThickness,0];

module funnel() {
    difference(){
        union(){
            rotate_extrude(angle = 360)
                polygon([p0, p1, p2o, p3o]);
            translate([-(exitDia/2),0,0])
                cube([exitDia,clDist,funnelHeight]);
        }
        p3i=[exitDia/2,0];
        p2i=[topDia/2,funnelHeight];
        rotate_extrude(angle = 360)
            polygon([p0, p1, p2i, p3i]);
    //    for (i = [1 : funnelMountHoleCount])
    //        translate([0,clDist,(1/(funnelMountHoleCount+1))*funnelHeight*i])
    //            rotate([90,0,0])
    //                cylinder(h=4, d=4);
        //mounting nut interface
        for (z = [funnelHeight/4, funnelHeight*3/4]) {
            translate([0, clDist-wallThickness, z])
                rotate([90,0,0])
                    nutcatch_sidecut("M5", "hexagon", height_clearance=0.2, width_clearance=0.2);
            translate([0, clDist, z])
                rotate([90,0,0])
                    bolt("M5", length=(wallThickness+nut_height("M5")+5), kind="headless", length_clearance=1);
        }
    }
}
funnel();