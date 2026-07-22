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
                position(FRONT+LEFT) translate([2.245, 12.65, 0]) cyl(d=RJ45_HOLE_D, h=10, anchor=BOTTOM);
                position(FRONT+RIGHT) translate([-2.245, 12.65, 0]) cyl(d=RJ45_HOLE_D, h=10, anchor=BOTTOM);
                position(TOP+FRONT) cuboid([RJ45_BODY_W, RJ45_BODY_D, RJ45_BODY_H], anchor=BOTTOM+FRONT);
            }
        }
        children();
    }
}

module rj45_screw() {
    anchors = [
        named_anchor("mount", [0, 0, -RJ45_BASE_H/2], DOWN)
    ];
    base_rj45(anchors=anchors) children();
}

rj45_screw();
