include <sharedDims.scad>
use <../../catchnhole/catchnhole.scad>;

//calcualte the triangle cutout based on the feed angle and singulator diameter
chordLength = singulatorDiameter * sin (singulatorExposureAngle/2);
angleX = (hopperWidth-chordLength)/2;
angleY = angleX/tan(feedAngle);

// hopper outline
p0 = [0, angleY];
p1 = [0, hopperHeight];
p2 = [hopperWidth, hopperHeight];
p3 = [hopperWidth, angleY];
p4 = [(hopperWidth-angleX), 0];
p5 = [angleX, 0];
hopperPoints = [p0, p1, p2, p3, p4, p5];

//motorCenterLocation
motorCenterX=0.5*hopperWidth;
motorCenterY=-0.35*singulatorDiameter;

// Wrapped as a module so assembly/assembly.scad can place it.
// Opening this file on its own still renders the part, and the STL
// release workflow is unaffected.
module hopper() {
difference(){
    union(){
        difference(){
            //main hopper body
            union(){
                linear_extrude(height=hopperDepth)
                    polygon(hopperPoints);
                //singulator retaining wall
                translate([motorCenterX, motorCenterY, 0])
                    cylinder(h=(hopperDepth*2/3), d=(singulatorDiameter+(2*wallThickness)+3));
            }
            
            //shell of the hopper
            translate([0,0,baseThickness])
                linear_extrude(height=(hopperHeight-baseThickness))
                    offset(r=-(wallThickness))
                        polygon(hopperPoints);
            
            //singulator clearance (bottom)
            translate([motorCenterX, motorCenterY, baseThickness])
                cylinder(h=(hopperDepth-baseThickness+1), d=(singulatorDiameter+5));
                
            //top
            translate([wallThickness, (hopperHeight-wallThickness)-1, baseThickness])
                cube([(hopperWidth-(2*wallThickness)), (wallThickness+2), (hopperDepth-baseThickness+1)]);
        }
    }

    //motor stuff
    motorPlateWidth = 70;
    motorPoints = [[angleX, 0], [(hopperWidth-angleX), 0], [(hopperWidth-angleX), -motorPlateWidth], [angleX, -motorPlateWidth]];

//    //motor plate
//    linear_extrude(height=baseThickness)
//        polygon(motorPoints);
    
    //motor center clearance hole
    translate([motorCenterX, motorCenterY, -1])
        cylinder(baseThickness+2,d=motorClearanceCircle);
    
    //motor mount hole pattern
    translate([motorCenterX-(0.5*motorHolePatternX), motorCenterY-(0.5*motorHolePatternY),0])
        for(x=[0:1]){
            for(y=[0:1]){
                translate([x*motorHolePatternX, y*motorHolePatternY, 0])
                    bolt("M3", baseThickness, kind = "socket_head", countersink = 1.33);
            }
        }
    
    //drop hole
    dropHoleSize=30;
    translate([motorCenterX, motorCenterY-(singulatorDiameter/2),0])
        rotate([-45,0,0])
            translate([0,-dropHoleSize/4,-dropHoleSize])
                cylinder(h=dropHoleSize*2, d=dropHoleSize);
}
}

hopper();
