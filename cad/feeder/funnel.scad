include <sharedDims.scad>

//=[exitDia/2,0];
p0=[0,0];
p1=[0,funnelHeight];
p2o=[(topDia/2)+wallThickness,funnelHeight];
//=[(topDia/2)+wallThickness,funnelHeight];
p3o=[(exitDia/2)+wallThickness,0];

difference(){
    union(){
        rotate_extrude(angle = 360)
            polygon([p0, p1, p2o, p3o]);
        translate([-(exitDia/2),0,0])
            cube([exitDia,mountDist,funnelHeight]);
    }
    p3i=[exitDia/2,0];
    p2i=[topDia/2,funnelHeight];
    rotate_extrude(angle = 360)
        polygon([p0, p1, p2i, p3i]);
    for (i = [1 : funnelMountHoleCount])
        translate([0,mountDist,(1/(funnelMountHoleCount+1))*funnelHeight*i])
            rotate([90,0,0])
                cylinder(h=4, d=4);
}