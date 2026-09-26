include <../sharedDims.scad>
use <../../catchnhole/catchnhole.scad>;

//calcualte the triangle cutout based on the feed angle and singulator diameter
chordLength = singulatorDiameter * sin (singulatorExposureAngle/2);
angleX = (hopperWidth-chordLength)/2;
angleY = angleX/tan(hopperConvergeAngle);

hopperXshift=-hopperWidth/2;
hopperYshift=0.35*singulatorDiameter;

// hopper outline
p0 = [0+hopperXshift, angleY+hopperYshift];
p1 = [0+hopperXshift, hopperHeight+hopperYshift];
p1e = [-clDist, hopperHeight+hopperYshift];
p1ex = [-clDist, 0];
p2 = [hopperWidth+hopperXshift, hopperHeight+hopperYshift];
p2e = [clDist, hopperHeight+hopperYshift];
p2ex = [clDist, 0];
p3 = [hopperWidth+hopperXshift, angleY+hopperYshift];
p4 = [(hopperWidth-angleX)+hopperXshift, hopperYshift];
p5 = [angleX+hopperXshift, hopperYshift];
hopperPoints = [p0, p1, p2, p3, p4, p5];


// Wrapped as a module so assembly/assembly.scad can place it.
// Opening this file on its own still renders the part, and the STL
// release workflow is unaffected.
module hopper() {
difference(){
    union(){
        difference(){
            //main hopper body
            union(){
                //translate([hopperXshift, hopperYshift])
                    linear_extrude(height=hopperDepth)
                        polygon(hopperPoints);
                //singulator retaining wall
                cylinder(h=(hopperDepth*2/3), d=(singulatorDiameter+(2*wallThickness)+3));
                linear_extrude(height=(hopperDepth*2/3))
                    polygon([p1e,p1ex, p2ex,p2e]);
                //blend the side flats into the retaining wall: hulling the circle
                //with the flats' bottom corners gives a line from each corner
                //tangent to the circle
                linear_extrude(height=(hopperDepth*2/3))
                    hull(){
                        circle(d=(singulatorDiameter+(2*wallThickness)+3));
                        polygon([p1ex, p2ex, [0, hopperYshift]]);
                    }
            }
            
            //shell of the hopper
            translate([0, 0, baseThickness])
                linear_extrude(height=(hopperHeight-baseThickness))
                    offset(r=-(wallThickness))
                        polygon(hopperPoints);
            
            //singulator clearance (bottom)
            translate([0, 0, baseThickness])
                cylinder(h=(hopperDepth-baseThickness+1), d=(singulatorDiameter+5));
                
            //top
            translate([wallThickness+hopperXshift, hopperHeight-wallThickness+hopperYshift-1, baseThickness])
                cube([(hopperWidth-(2*wallThickness)), (wallThickness+2), (hopperDepth-baseThickness+1)]);
        }
    }
    
    //motor center clearance hole
    translate([0, 0, -1])
        cylinder(baseThickness+2,d=motorClearanceCircle);
    
    //motor mount hole pattern
    translate([0-(0.5*motorHolePatternX), 0-(0.5*motorHolePatternY),0])
        for(x=[0:1]){
            for(y=[0:1]){
                translate([x*motorHolePatternX, y*motorHolePatternY, 0])
                    bolt("M3", length=baseThickness, kind = "socket_head", countersink = 1.33);
            }
        }
    
    //drop hole
    translate([0, 0-(singulatorDiameter/2),0])
        rotate([-mountAngle,0,0])
            translate([0,-dropHoleSize/4,-dropHoleSize])
                cylinder(h=dropHoleSize*2, d=dropHoleSize);
                
    //mounting nut interface, on both sides (mirror([0,0,0]) is a no-op)
    mountBoltZ = (hopperDepth*2/3)/2;
    for (side = [0, 1]) mirror([side, 0, 0])
        for (y = [10, angleY+hopperYshift-10]) {
            translate([clDist-wallThickness, y, mountBoltZ])
                rotate([0,-90,0])
                    nutcatch_sidecut("M5", "hexagon", height_clearance=0.2, width_clearance=0.2);
            translate([clDist, y, mountBoltZ])
                rotate([0,-90,0])
                    bolt("M5", length=(wallThickness+nut_height("M5")+5), kind="headless", length_clearance=1);
        }
    
}
}


hopper();
