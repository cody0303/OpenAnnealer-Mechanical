// Feeder motor bracket -- the part that actually mounts the motor.
//
// The motor bolts to this plate's rear face; the plate then ties to
// back_plate.scad through three standoffs on the back plate's existing mount
// circle. That makes motor, back plate and wheel one rigid stack referencing a
// single axis, which is what keeps the shaft centered in the wheel and gives
// the motor's reaction torque somewhere to go.
//
// THIS IS THE ONLY PART IN THE DESIGN WITH A MOTOR BOLT PATTERN IN IT, on
// purpose: the feeder motor isn't locked in yet, so a different frame size
// means reprinting this one plate and nothing else. Values are NEMA17 (see
// dimensions.scad); for NEMA14 change MOTOR_BOLT_SQUARE to 26 and
// MOTOR_BOSS_D to 22.
//
// Coordinate convention: Z=0 is the FRONT face (toward the standoffs and the
// back plate). Z=MOTOR_BRACKET_THICKNESS is the REAR face, which the motor
// bolts flat against.
//
// Open this file directly in OpenSCAD to preview just the bracket.

include <../lib/dimensions.scad>
include <../lib/shapes.scad>

// Must match back_plate.scad's mount circle
MOUNT_HOLE_D           = 3.4;
MOUNT_HOLE_ORBIT_R     = BACKPLATE_OD/2 - 4;
MOUNT_HOLE_COUNT       = 3;
MOUNT_HOLE_START_ANGLE = DISCHARGE_ANGLE + 70;

module motor_bracket() {
    difference() {
        cylinder(d = MOTOR_BRACKET_OD, h = MOTOR_BRACKET_THICKNESS);

        // Clearance for the motor's pilot boss and shaft
        translate([0, 0, -1])
            cylinder(d = MOTOR_BOSS_CLEAR_D, h = MOTOR_BRACKET_THICKNESS + 2);

        // Motor bolt pattern, clocked away from the discharge path
        rotate([0, 0, MOTOR_BOLT_ANGLE_OFFSET])
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx * MOTOR_BOLT_SQUARE/2, sy * MOTOR_BOLT_SQUARE/2, -1])
                    cylinder(d = MOTOR_BOLT_D, h = MOTOR_BRACKET_THICKNESS + 2);

        // Standoff holes -- same circle as the back plate's
        orbit(MOUNT_HOLE_ORBIT_R, MOUNT_HOLE_COUNT, MOUNT_HOLE_START_ANGLE)
            translate([0, 0, -1])
                cylinder(d = MOUNT_HOLE_D, h = MOTOR_BRACKET_THICKNESS + 2);

        // Discharge clearance -- a dropped case falls backwards through the
        // back plate, so it has to pass this plane too. Without this the
        // bracket is simply a floor for the case to land on.
        translate([POCKET_ORBIT_R * cos(DISCHARGE_ANGLE),
                   POCKET_ORBIT_R * sin(DISCHARGE_ANGLE),
                   -1])
            cylinder(d = MOTOR_DISCHARGE_CLEAR_D, h = MOTOR_BRACKET_THICKNESS + 2);
    }
}

motor_bracket();
