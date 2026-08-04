include <BOSL2/std.scad>
include <jl_scad/box.scad>
use <jl_scad/parts.scad>

// LM2596S buck converter module
// Dimensions: 61 x 34 x 13mm, four M3 mounting holes 2mm inset from each corner
//
//   lm2596s()                                    Standalone / attachable footprint.
//                                                Ghost body + four mount anchors.
//   lm2596s_jl(standoff_h, standoff_od,          jl_scad box_part(...) drop-in.
//              standoff_id)                      Ghost above floor; four standoffs
//                                                rising from the inside face to
//                                                receive the board. Origin sits
//                                                on the box's inside face.

$fn = 32;

LM_W = 66;
LM_D = 36;
LM_H = 13;
LM_MOUNT_X = LM_W/2 - 2.55;
LM_MOUNT_Y = LM_D/2 - 2.55;
LM_MOUNT_HOLE_D = 3;

// Single source of truth for corner mount positions in [x, y].
// Order: BL, BR, TL, TR — matches the named anchors below.
LM_MOUNT_POS = [
    [-LM_MOUNT_X, -LM_MOUNT_Y],
    [ LM_MOUNT_X, -LM_MOUNT_Y],
    [-LM_MOUNT_X,  LM_MOUNT_Y],
    [ LM_MOUNT_X,  LM_MOUNT_Y],
];
LM_MOUNT_NAMES = ["mount_BL", "mount_BR", "mount_TL", "mount_TR"];

module lm2596s(anchor=CENTER, spin=0, orient=UP) {
    anchors = [
        for (i = idx(LM_MOUNT_POS))
            named_anchor(LM_MOUNT_NAMES[i],
                         [LM_MOUNT_POS[i].x, LM_MOUNT_POS[i].y, -LM_H/2], DOWN)
    ];
    attachable(anchor, spin, orient, size=[LM_W, LM_D, LM_H], anchors=anchors) {
        tag_this("ghost") cuboid([LM_W, LM_D, LM_H]);
        children();
    }
}

module lm2596s_jl(standoff_h=5, standoff_od=5, standoff_id=LM_MOUNT_HOLE_D) {
    // ghost body lifted on the standoffs above the floor
    box_preview() up(standoff_h + LM_H/2) cuboid([LM_W, LM_D, LM_H]);
    // four standoffs rising from the inside floor face
    for (p = LM_MOUNT_POS)
        translate([p.x, p.y, 0])
            standoff(h=standoff_h, od=standoff_od, id=standoff_id);
}

// Standalone test: flat surface + jl standoffs + ghost body, to preview
// how the module looks mounted on a box floor.
module lm2596s_test() {
    // test floor plate
    color("steelblue", 0.3) cuboid([LM_W*1.125, LM_D*1.125, 1.6], anchor=TOP);
    // jl variant (origin on floor inside face)
    lm2596s_jl();
}

if(is_undef(_skip_render)) lm2596s_test();
