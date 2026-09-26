include <../sharedDims.scad>

// Where everything sits in the machine, derived from sharedDims. Shared by
// cad/cabinetFlat/sidePanel.scad (which needs to know where to put its holes),
// cad/cabinet/servoMount.scad and assembly/assembly.scad (which places the
// parts), so they can't drift apart. No geometry here -- include it wherever
// sharedDims would go.
//
// World frame: Z is the drop axis. The funnel, coil, case and thumbscrew sit
// on it at x = y = 0, and z = 0 is where the drop bore's centreline crosses the
// hopper's base plane. The funnel arm points +Y to the cabinet wall, whose
// outer face is y = clDist. Positions are for a left-hand build (feeder on -X,
// seen from outside); a right-hand build is the mirror in X.

// ---------------------------------------------------------------------------
// Duplicated from the part files -- keep in step with them
// ---------------------------------------------------------------------------
// hopper.scad
hopperXshift = -hopperWidth/2;
hopperYshift = 0.35 * singulatorDiameter;
chordLength  = singulatorDiameter * sin(singulatorExposureAngle/2);
angleX       = (hopperWidth - chordLength) / 2;
angleY       = angleX / tan(hopperConvergeAngle);
hopperBoltYs = [10, angleY + hopperYshift - 10];    // hopper frame, on x = +/-clDist
hopperBoltZ  = (hopperDepth*2/3) / 2;
// funnel.scad
funnelBoltZs = [funnelHeight/4, funnelHeight*3/4];  // up from the funnel's exit

// ---------------------------------------------------------------------------
// Servo mount (cad/cabinet/servoMount.scad uses these directly)
// ---------------------------------------------------------------------------
servoClear      = 0.3;                                      // around the case, in the pocket
servoMountH     = servoBodyH - servoEarDrop - servoEarThk;  // ear underside to case bottom
servoMountBoltX = servoBodyW/2 + servoClear + wallThickness + 4;

// ---------------------------------------------------------------------------
// Feeder placement
// ---------------------------------------------------------------------------
// In the hopper's frame (origin on the motor axis, base plate underside at
// z = 0) the bore's centreline crosses the base plane here, allowing for the
// hole's dropHoleSize/4 offset...
exitY = -singulatorDiameter/2 - (dropHoleSize/4) / cos(mountAngle);
// ...and where that point ends up once the feeder leans back
exitTiltY = exitY * cos(mountAngle);
exitTiltZ = exitY * sin(mountAngle);

// A point in the hopper's frame, in the world, for a left-hand build: lean
// back, slide the bore exit onto the origin, spin 90 deg about the drop axis.
function feederToWorld(p) =
    let (t = [p[0],
              p[1]*cos(mountAngle) - p[2]*sin(mountAngle) - exitTiltY,
              p[1]*sin(mountAngle) + p[2]*cos(mountAngle) - exitTiltZ])
    [-t[1], t[0], t[2]];

// ---------------------------------------------------------------------------
// Stations down the drop axis
// ---------------------------------------------------------------------------
funnelRimZ = -dropToFunnelRim;
funnelZ    = funnelRimZ - funnelHeight;     // funnel's local origin is its exit
coilZ      = funnelZ - funnelToCoil;
caseBaseZ  = funnelZ - funnelToCase;       // thumbscrew head at its lowest, for the longest case
armTopZ    = caseBaseZ - caseToArm;
armBotZ    = armTopZ - supportThickness;
leadZ      = coilZ;                         // height the coil leads pass the wall at

// The heatsink holder stands inside the wall between the leads, centred on
// them. Its top bolt is the funnel's upper one, shared; its bottom one sits
// the same distance below the leads.
holderBoltOff = funnelZ + funnelBoltZs[1] - leadZ;

servoY         = clDist + servoBackset;     // funnel arm to the wall, then the backset
servoTopZ      = armBotZ - 2;               // horn sits flat under the arm
servoMountTopZ = servoTopZ - servoEarDrop - servoEarThk;   // where the ears sit
