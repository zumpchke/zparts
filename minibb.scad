include <BOSL2/std.scad>
include <jl_scad/box.scad>
use <jl_scad/parts.scad>

$fn = 32;

// Mini breadboard dimensions
MBB_W = 20;
MBB_D = 15;
MBB_H = 9.6;
MBB_MOUNT_X = 5;    // hole offset from center on X axis
MBB_MOUNT_HOLE_D = 2;

module base_minibb(anchors=[], anchor=CENTER, spin=0, orient=UP) {
    attachable(anchor, spin, orient, size=[MBB_W, MBB_D, MBB_H], anchors=anchors) {
        diff() {
            cuboid([MBB_W, MBB_D, MBB_H]);
            tag("remove") translate([-MBB_MOUNT_X, 0, MBB_H/2])
                cyl(d=MBB_MOUNT_HOLE_D, h=MBB_H+2, anchor=TOP);
            tag("remove") translate([MBB_MOUNT_X, 0, MBB_H/2])
                cyl(d=MBB_MOUNT_HOLE_D, h=MBB_H+2, anchor=TOP);
        }
        children();
    }
}

module minibb() {
    anchors = [
        named_anchor("mount_L", [-MBB_MOUNT_X, 0, MBB_H/2], UP),
        named_anchor("mount_R", [ MBB_MOUNT_X, 0, MBB_H/2], UP),
    ];
    base_minibb(anchors=anchors) children();
}

// jl_scad drop-in: ghost breadboard lifted on two standoffs above the floor.
// Standoffs are placed at the MBB_MOUNT_X hole positions — same locations as
// the mount_L/mount_R anchors, but the anchors sit on the part's TOP face
// (for box-wall mounting), so attaching standoffs through them would bury
// the standoff bases inside the breadboard. Explicit placement keeps the
// two use cases honest.
module minibb_jl(standoff_h=3, standoff_od=3, standoff_id=MBB_MOUNT_HOLE_D) {
    box_preview() up(standoff_h + MBB_H/2) minibb();
    for (x = [-MBB_MOUNT_X, MBB_MOUNT_X])
        translate([x, 0, 0])
            standoff(h=standoff_h, od=standoff_od, id=standoff_id);
}

// Standalone test: mounting surface on top, assembly hanging beneath it
// (mount normal points down, as when mounted to a lid/ceiling). Exercises the
// real jl wrapper. $box_show_previews is forced on so box_preview()'s ghost
// renders in F5 outside a box_make context.
module minibb_test() {
    $box_show_previews = true;
    cuboid([MBB_W*1.125, MBB_D*1.125, 3], anchor=BOTTOM) {
        position(TOP) minibb_jl();
    }
}

if (is_undef(_skip_render)) minibb_test();
