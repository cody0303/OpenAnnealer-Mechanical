include <sharedDims.scad>
use <../../catchnhole/catchnhole.scad>;

//calcualte the triangle cutout based on the feed angle and singulator diameter
chordLength = singulatorDiameter * sin (singulatorExposureAngle/2);
angleX = (hopperWidth-chordLength)/2;
angleY = angleX/tan(hopperConvergeAngle);

// hopper outline
p0 = [0, angleY];
p1 = [0, hopperHeight];
p2 = [hopperWidth, hopperHeight];
p3 = [hopperWidth, angleY];
p4 = [(hopperWidth-angleX), 0];
p5 = [angleX, 0];
hopperPoints = [p0, p1, p2, p3, p4, p5];

hopperXshift=-hopperWidth/2;
hopperYshift=0.35*singulatorDiameter;

// Wrapped as a module so assembly/assembly.scad can place it.
// Opening this file on its own still renders the part, and the STL
// release workflow is unaffected.
module hopper() {
difference(){
    union(){
        difference(){
            //main hopper body
            union(){
                translate([hopperXshift, hopperYshift])
                    linear_extrude(height=hopperDepth)
                        polygon(hopperPoints);
                //singulator retaining wall
                cylinder(h=(hopperDepth*2/3), d=(singulatorDiameter+(2*wallThickness)+3));
            }
            
            //shell of the hopper
            translate([hopperXshift, hopperYshift, baseThickness])
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

    //motor stuff
    motorPlateWidth = 70;
    motorPoints = [[angleX, 0], [(hopperWidth-angleX), 0], [(hopperWidth-angleX), -motorPlateWidth], [angleX, -motorPlateWidth]];
    
    //motor center clearance hole
    translate([0, 0, -1])
        cylinder(baseThickness+2,d=motorClearanceCircle);
    
    //motor mount hole pattern
    translate([0-(0.5*motorHolePatternX), 0-(0.5*motorHolePatternY),0])
        for(x=[0:1]){
            for(y=[0:1]){
                translate([x*motorHolePatternX, y*motorHolePatternY, 0])
                    bolt("M3", baseThickness, kind = "socket_head", countersink = 1.33);
            }
        }
    
    //drop hole
    translate([0, 0-(singulatorDiameter/2),0])
        rotate([-mountAngle,0,0])
            translate([0,-dropHoleSize/4,-dropHoleSize])
                cylinder(h=dropHoleSize*2, d=dropHoleSize);
}
}


hopper();
