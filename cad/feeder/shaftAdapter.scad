include <sharedDims.scad>
use <../../catchnhole/catchnhole.scad>;
shaftSquareBool=false;

// Wrapped as a module so assembly/assembly.scad can place it.
// Opening this file on its own still renders the part, and the STL
// release workflow is unaffected.
module shaftAdapter() {
difference(){
    //core adapter
    cylinder(h=flatLength, d=adapterDia);
    
    //shaft hole
    if(shaftSquareBool)
        translate([-shaftSquareDim/2,-shaftSquareDim/2,-1])
            cube([shaftSquareDim+0.1, shaftSquareDim+0.1, flatLength+2]);
    else
        difference(){
            translate([0,0,-1])
                cylinder(h=flatLength+2, d=shaftDia+0.1);
            translate([-shaftDia/2,shaftDwidth-(shaftDia/2)+0.1,0])
                cube([shaftDia, shaftDia, flatLength+2]);
        }
    

    //drive holes
    for (i=[0:numPins-1]){
        //pattern rotate
        rotate([0,0,i*(360/numPins)])
            translate([pinLatOffset,0,flatLength])
                scale([0.95,0.95,1])
                    //flip the bolt to the bottom
                    rotate([180,0,0])
                        bolt("M3", flatLength, kind = "socket_head", head_diameter_clearance=1.5, countersink = 1);
    }
    
    //set screw
    translate([0,0,flatLength/2])
        rotate([-90,0,0])
            union(){
                cylinder(h=(adapterDia/2)+1,d=m3InsertD);
                translate([0,0,(adapterDia/2)-4])
                    cylinder(h=4,d=6);
            }
}
}

shaftAdapter();
