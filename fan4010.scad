include <BOSL2/std.scad>
include <jl_scad/box.scad>
include <BOSL2/screws.scad>

$fn = 64;

// 40x40x10mm fan (4010). STL is 40x40x10.6, centered in XY, Z 0..10.6.
// Standard 32mm mounting-hole pattern (±16 from center), M3 screws.
FAN_SIZE     = 40;
FAN_H        = 10.6;
FAN_MOUNT    = 16;          // hole offset from center (32mm pattern)
FAN_SCREW_D  = 3.4;         // M3 clearance
FAN_BORE_D   = 37;          // airflow opening through the host wall

FAN_MOUNT_POS = [
    [-FAN_MOUNT, -FAN_MOUNT],
    [ FAN_MOUNT, -FAN_MOUNT],
    [-FAN_MOUNT,  FAN_MOUNT],
    [ FAN_MOUNT,  FAN_MOUNT],
];

// Segment count for the airflow bore. The global $fn=64 leaves ~1.8mm facets
// on a 37mm circle (visibly polygonal); size it by circumference for ~0.5mm
// segments so the bore reads smooth.
FAN_BORE_FN = max(64, ceil(PI * FAN_BORE_D / 0.5));

module fan4010() {
    translate([0, 0, 10]) scale([1, 1, -1]) import("fan4010.stl");
}

// jl_scad drop-in. Origin sits on the host's inside face, Z pointing into the
// interior. The fan sits against that face; the host gets an airflow bore plus
// four M3 screw clearance holes, all cut through the wall (−Z).
module fan4010_jl(host_thickness=3) {
    // fan body preview, resting on the inside face
    box_preview() fan4010();
    box_cut() {
        // airflow opening through the wall
        down(host_thickness/2) {
            cyl(d=FAN_BORE_D, h=host_thickness + 0.2, $fn=FAN_BORE_FN);
            // For power wire
            color("red") translate([-6.5, -37.2/2 + 2, 0]) cyl(d=10, h=host_thickness + 0.2);
        }
        // four M3 screw holes
        for (p = FAN_MOUNT_POS)
            translate([p.x, p.y, 0]) down(host_thickness/2)
                cyl(d=FAN_SCREW_D + 2*get_slop(), h=host_thickness + 0.2);
    }
}

if (is_undef(_skip_render)) fan4010_jl();
