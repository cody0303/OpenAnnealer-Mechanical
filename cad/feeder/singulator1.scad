include <sharedDims.scad>

//embossed text
difference(){
    //main body
    cylinder(h=hopperDepth-baseThickness, d=singulatorDiameter);
    
    //shaft adapter relief
    translate([0,0,-1])
        cylinder(h=flatLength, d=adapterDia+1);
    
    //drive holes
    for (i=[0:numPins-1]){
    rotate([0,0,i*(360/numPins)])    
        translate([pinLatOffset,0,0])
            cylinder(h=flatLength+10, d=3.2);
    }

    //case hole
    translate([0,(singulatorDiameter/2)-(caseCutout/2),-1])
        union(){
            translate([-(caseCutout/2),0,0])
                cube([caseCutout, caseCutout, hopperDepth-baseThickness+2]);
            cylinder(h=hopperDepth-baseThickness+2, d=caseCutout);
        }

    //text
    translate([0,(singulatorDiameter/2)-(caseCutout*1.5),hopperDepth-baseThickness-1])
        linear_extrude(2)
            text(str(caseCutout), halign="center", valign="top");
}