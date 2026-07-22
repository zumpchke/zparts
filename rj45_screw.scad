include <BOSL2/std.scad>

$fn = 32;

// RJ45 screw-type jack dimensions
RJ45_BASE_W = 24.49;
RJ45_BASE_D = 33;
RJ45_BASE_H = 1.6;
RJ45_BODY_W = 16.5;
RJ45_BODY_D = 15.5;
RJ45_BODY_H = 13;
RJ45_HOLE_D = 3;

module base_rj45(anchors=[], anchor=CENTER, spin=0, orient=UP) {
    attachable(anchor, spin, orient, size=[RJ45_BASE_W, RJ45_BASE_D, RJ45_BODY_H], anchors=anchors) {
        diff() {
            cuboid([RJ45_BASE_W, RJ45_BASE_D, RJ45_BASE_H]) {
                tag("remove") position(FRONT+LEFT+BOTTOM) translate([2.245, 12.65, 0]) cyl(d=RJ45_HOLE_D, h=20, anchor=BOTTOM);
                tag("remove") position(FRONT+RIGHT+BOTTOM) translate([-2.245, 12.65, 0]) cyl(d=RJ45_HOLE_D, h=20, anchor=BOTTOM);
            }
            position(TOP+FRONT) cuboid([RJ45_BODY_W, RJ45_BODY_D, RJ45_BODY_H], anchor=BOTTOM+FRONT);
        }
        children();
    }
}

module rj45_screw() {
    // Hole centers in world coords (from position(FRONT+LEFT/RIGHT) translate offsets)
    hole_L_x = -RJ45_BASE_W/2 + 2.245;
    hole_R_x = RJ45_BASE_W/2 - 2.245;
    hole_y = RJ45_BASE_D/2 - 12.65;
    anchors = [
        named_anchor("mount", [0, 0, -RJ45_BASE_H/2], DOWN),
        named_anchor("screw_L", [hole_L_x, hole_y, RJ45_BASE_H/2], FRONT),
        named_anchor("screw_R", [hole_R_x, hole_y, RJ45_BASE_H/2], FRONT)
    ];
    base_rj45(anchors=anchors) children();
}

rj45_screw();
