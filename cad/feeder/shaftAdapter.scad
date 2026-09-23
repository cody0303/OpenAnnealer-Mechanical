include <sharedDims.scad>
use <../../catchnhole/catchnhole.scad>;
shaftSquareBool=false;

difference(){
    //core adapter
    cylinder(h=flatLength, d=adapterDia);
    
    //shaft hole
    if(shaftSquareBool)
        translate([-shaftSquareDim/2,-shaftSquareDim/2,-1])
            cube([shaftSquareDim+0.1, shaftSquareDim+0.1, flatLength+2]);
    else
        translate([0,0,-1])
            cylinder(h=flatLength+2, d=shaftDia+0.1);
    

    //drive holes
    for (i=[0:numPins-1]){
        //pattern rotate
        rotate([0,0,i*(360/numPins)])    
            translate([pinLatOffset,0,flatLength])
                //flip the bolt to the bottom
                rotate([180,0,0])
                    bolt("M3", flatLength, kind = "socket_head", countersink = 1);
    }
    
    //set screw
    insertHoleSize=4;
    translate([0,0,flatLength/2])
        rotate([-90,0,0])
            cylinder(h=(adapterDia/2)+1,d=insertHoleSize);
}