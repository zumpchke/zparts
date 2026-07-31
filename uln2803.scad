include <BOSL2/std.scad>
include <jl_scad/box.scad>
use <jl_scad/parts.scad>

// ULN2803 high-voltage Darlington transistor array breakout
// Board: 23 x 23 mm, ~15mm tall (pin headers). Two M3 mounting holes
// along the long axis, 3mm inset from each end.
//
//   uln2803()                                    Standalone / attachable footprint.
//                                                Ghost cuboid + two mount anchors.
//   uln2803_jl(standoff_h, standoff_od,          jl_scad box_part(...) drop-in.
//            standoff_id)                        Ghost above floor; two standoffs
//                                                rising from the inside face.

$fn = 32;

ULN_W = 23;
ULN_D = 23;
ULN_H = 15;
ULN_MOUNT_Y = ULN_D/2 - 3;    // 8.5mm from center
ULN_MOUNT_HOLE_D = 3.2;        // M3 clearance

ULN_MOUNT_POS = [
    [0, -ULN_MOUNT_Y],   // bottom
    [0,  ULN_MOUNT_Y],   // top
];
ULN_MOUNT_NAMES = ["mount_B", "mount_T"];

// Raw ghost geometry: board envelope with the two M3 mounting holes drilled
// through. Untagged — the caller picks the tag context (ghost vs box_keep),
// so box_preview()'s BOX_KEEP_TAG isn't clobbered by an inner tag_this().
module _uln2803_ghost() {
    diff() {
        cuboid([ULN_W, ULN_D, ULN_H]);
        for (p = ULN_MOUNT_POS)
            tag("remove") move(p)
                cyl(d=ULN_MOUNT_HOLE_D, h=ULN_H + 2);
    }
}

module uln2803(anchor=CENTER, spin=0, orient=UP) {
    anchors = [
        for (i = idx(ULN_MOUNT_POS))
            named_anchor(ULN_MOUNT_NAMES[i],
                         [ULN_MOUNT_POS[i].x, ULN_MOUNT_POS[i].y, -ULN_H/2], DOWN)
    ];
    attachable(anchor, spin, orient, size=[ULN_W, ULN_D, ULN_H], anchors=anchors) {
        tag_this("ghost") _uln2803_ghost();
        children();
    }
}

module uln2803_jl(standoff_h=5, standoff_od=5, standoff_id=ULN_MOUNT_HOLE_D) {
    box_preview() up(standoff_h + ULN_H/2) _uln2803_ghost();
    for (p = ULN_MOUNT_POS)
        translate([p.x, p.y, 0])
            standoff(h=standoff_h, od=standoff_od, id=standoff_id);
}

if (is_undef(_skip_render)) uln2803() show_anchors(s=6, std=false);