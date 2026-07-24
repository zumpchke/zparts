include <BOSL2/std.scad>

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

minibb();
