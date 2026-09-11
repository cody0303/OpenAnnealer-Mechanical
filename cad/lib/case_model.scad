// Simplified cartridge case solid, for visualization and fit-checking only.
//
// NOT a dimensionally faithful case model -- body taper is ignored and the
// shoulder is a single straight cone. It exists so assembly previews show
// what the mechanism is actually doing (cases standing on their bases against
// the singulator disk, one dropping into the pocket), which is much easier to
// sanity-check than bare plates and holes. Don't derive any fit from this.

// Proportions below are for a .223 Rem / 5.56 case. Passing different values
// gets you a rough stand-in for another family.
module case_model(rim_d = 9.6, body_d = 9.5, neck_d = 6.4, length = 44.7,
                  shoulder_start = 32, neck_start = 38) {
    // Head + body
    cylinder(d = body_d, h = shoulder_start);

    // Shoulder taper
    translate([0, 0, shoulder_start])
        cylinder(d1 = body_d, d2 = neck_d, h = neck_start - shoulder_start);

    // Neck
    translate([0, 0, neck_start])
        cylinder(d = neck_d, h = length - neck_start);
}
