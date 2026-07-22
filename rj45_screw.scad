include <BOSL2/std.scad>

$fn = 32;

// RJ45 screw-type jack dimensions
RJ45_BASE = [24.49, 33, 1.6];
RJ45_BODY = [16.5, 15.5, 13];
RJ45_HOLE_D = 3;
RJ45_HOLE_X = RJ45_BASE.x/2 - 2.245;    // symmetric around Y axis
RJ45_HOLE_Y = -RJ45_BASE.y/2 + 12.65;   // negative = toward FRONT

module rj45_screw(anchor=CENTER, spin=0, orient=UP) {
    total_h = RJ45_BASE.z + RJ45_BODY.z;
    plate_top_z = -total_h/2 + RJ45_BASE.z;
    anchors = [
        named_anchor("mount",   [0, 0, -total_h/2], DOWN),
        named_anchor("screw_L", [-RJ45_HOLE_X, RJ45_HOLE_Y, plate_top_z], UP),
        named_anchor("screw_R", [ RJ45_HOLE_X, RJ45_HOLE_Y, plate_top_z], UP),
    ];
    attachable(anchor, spin, orient,
               size=[RJ45_BASE.x, RJ45_BASE.y, total_h],
               anchors=anchors) {
        tag_this("ghost") down(total_h/2) diff() {
            cuboid(RJ45_BASE, anchor=BOTTOM) {
                tag("remove") move([-RJ45_HOLE_X, RJ45_HOLE_Y]) cyl(d=RJ45_HOLE_D, h=RJ45_BASE.z*3);
                tag("remove") move([ RJ45_HOLE_X, RJ45_HOLE_Y]) cyl(d=RJ45_HOLE_D, h=RJ45_BASE.z*3);
                position(TOP+FRONT) cuboid(RJ45_BODY, anchor=BOTTOM+FRONT);
            }
        }
        children();
    }
}

rj45_screw() show_anchors(s=6, std=false);
