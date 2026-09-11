// Simplified NEMA stepper stand-in, for assembly previews only.
//
// Not a part to print and not dimensionally exact -- the body is a plain cube
// with no cable gland, chamfers or end bells. It exists so the assembly shows
// where the motor physically sits and makes interferences visible.
//
// Coordinate convention: Z=0 is the motor's FACE (the surface that bolts flat
// against the bracket). The body extends in -Z; the pilot boss and shaft
// project in +Z.

module nema_motor(face = 42.3, body_len = 40, boss_d = 22, boss_h = 2,
                  shaft_d = 5, shaft_len = 24) {
    // Body
    translate([-face/2, -face/2, -body_len])
        cube([face, face, body_len]);

    // Pilot boss
    cylinder(d = boss_d, h = boss_h);

    // Output shaft
    cylinder(d = shaft_d, h = shaft_len);
}
