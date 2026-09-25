$fn=180;

//printer -- printed pieces are split so each fits this square bed
printBed            = 200;

//hardware
m3InsertD           = 4.0;  //M3 heat-set insert hole -- check your insert's datasheet
m3InsertDepth       = 6.2;  //for a 5.7 mm long insert, plus a little for melt-back

//shaftAdapter
adapterDia      = 20;
pinLatOffset    = 6;
numPins         = 2;

//overall
clDist              = 60;

//hopper
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

//singulator
singulatorDiameter      = 80;
singulatorExposureAngle = 90;
numHoles                = 4;
caseCutout              = 10;

//funnel
topDia              = 40;
exitDia             = 20;
funnelHeight        = 30;

//movable support
supportScrewSize    = 5;
supportThickness    = 6;
cabinetWallThk      = 6;  //cabinet faces (ply or print); the servo mount bolts to the inside of the feeder panel

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
funnelToCase        = 50;   //funnel exit down to the case base / thumbscrew top
caseToArm           = 16;   //case base down to the top face of the horn arm

//induction coil leads, where they pass through the cabinet wall
coilTube            = 4;    //copper tube OD
leadGap             = 12;   //centre-to-centre of the two leads
grommetLip          = 2.5;  //the pass-through is grown by this for the grommet
