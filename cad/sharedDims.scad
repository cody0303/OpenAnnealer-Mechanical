$fn=180;

/* [Printer] */
printBed            = 200;

/* [Hardware] */
m3InsertD           = 4.0;  //M3 heat-set insert hole -- check your insert's datasheet
m3InsertDepth       = 6.2;  //for a 5.7 mm long insert, plus a little for melt-back
m4InsertD           = 5.0;
m4InsertDepth       = 8.0;

/* [Shaft Adapter] */
adapterDia      = 20;
pinLatOffset    = 6;
numPins         = 2;

//overall
clDist              = 60;

/* [Hopper] */
wallThickness   = 5;
baseThickness   = 8;
hopperWidth     = 100;
hopperHeight    = 100;
hopperDepth     = 60;
hopperConvergeAngle       = 30;
dropHoleSize    = 30;
mountAngle      = 45;
//NEMA17 motor dimensions
shaftSquareDim      = 3;
shaftDia            = 5;
shaftDwidth         = 4.5;
flatLength          = 12;
motorHolePatternX   = 31;
motorHolePatternY   = 31;
motorClearanceCircle= 23;

/* [Singulator] */
singulatorDiameter      = 80;
singulatorExposureAngle = 90;
numHoles                = 4;
caseCutout              = 10;

/* [Funnel] */
topDia              = 40;
exitDia             = 20;
funnelHeight        = 30;

/* [Movable Support] */
supportScrewSize    = 5;
supportThickness    = 6;
cabinetWallThk      = 6;  //cabinet faces (ply or print); the servo mount bolts to the inside of the left panel
cornerBlock         = 20; //printed blocks in the cabinet's vertical corners -- at the base, the tile seam and
                          //the top; every wall screws into them
tileLap             = 16; //where a printed wall's two tiles meet: a half-lap this tall, glued and screwed

//MG90S servo -- typical numbers, measure yours
servoBodyL          = 22.8; //case length, along the ears
servoBodyW          = 12.2;
servoBodyH          = 22.7; //case bottom to case top, not counting the output boss
servoShaftToEnd     = 6.1;  //output shaft centre to the short end of the case
servoEarSpan        = 32.2; //tip to tip of the mounting ears
servoEarHolePitch   = 27.8;
servoEarThk         = 2.5;
servoEarDrop        = 4.0;  //case top down to the top face of the ears
servoWallClear      = 1.2;  //air between the servo's wall-side ear and the inside of the cabinet wall
//distance from the outside wall of the box to the servo's axis: the wall, then as far as the
//wall-side ear reaches from the shaft (half the ear span, less the case centre's offset
//behind the shaft), then the clearance. It has to come after the servo numbers it uses.
servoBackset        = cabinetWallThk + (servoEarSpan/2 - (servoBodyL/2 - servoShaftToEnd)) + servoWallClear;

//stack spacing down the drop axis
dropToFunnelRim     = 18;   //discharge exit down to the funnel's top rim
funnelToCoil        = 15;   //funnel exit down to the centre of the coil
maxCaseLen          = 69.2; //the longest case it takes (.338 Lapua Mag); shorter ones ride up the thumbscrew
funnelToCase        = maxCaseLen + 7;   //funnel exit down to the thumbscrew head at its lowest: the longest
                                        //case, with its mouth clear of the funnel
caseToArm           = 16;   //thumbscrew head at its lowest down to the top face of the horn arm

/* [Heatsink Holder] */
//induction heater heatsinks -- the pair on the heatsink holder, inside the cabinet; the coil's
//leads come through the wall and plug into them, and the transformer's cables leave the far end
heatsinkSpacing     = 20;   //between their flat faces: the holder's width across them
heatsinkH           = 54;   //overall, across the fins
heatsinkFinReach    = 5.25; //the fins stand this far proud of the flat face, toward the holder
heatsinkDepth       = 18.5; //flat face out to the back of the curved base (round, not square -- see layout)
heatsinkLen         = 38;   //extrusion length, the same as the holder
heatsinkBoreIn      = 7;    //the coil's lead plugs in this far in from the flat face, at mid-height

//the driver board's fan -- a standard 40 x 20
driverFanSize       = 40;   //square
driverFanDepth      = 20;
driverFanHolePitch  = 32;   //between its screw holes (M3)

//induction coil leads, where they pass through the cabinet wall
coilTube            = 4;    //copper tube OD
leadGap             = heatsinkSpacing + 2*heatsinkBoreIn;   //centre-to-centre: the heatsinks' lead bores
grommetLip          = 2.5;  //the pass-through is grown by this for the grommet
wallBackset         = 45;
