include <BOSL2/std.scad>
include <jl_scad/box.scad>
use <jl_scad/parts.scad>

$fn = 32;

// RJ45 screw-type jack dimensions
RJ45_BASE = [24.49, 33, 1.6];
RJ45_BODY = [16.5, 15.5, 13];
RJ45_HOLE_D = 3;
RJ45_HOLE_X = RJ45_BASE.x/2 - 2.245;    // symmetric around Y axis
RJ45_HOLE_Y = -RJ45_BASE.y/2 + 12.65;   // negative = toward FRONT

module rj45_screw(anchor=CENTER, spin=0, orient=UP) {
    total_h = RJ45_BASE.z + RJ45_BODY.z;
    plate_top_z = -total_h/2;
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

// RJ45 for jl_scad box projects. Places ghost body, standoffs at screw holes,
// and optional chamfered cutout through the box wall.
//   host_thickness  — box wall thickness (for cutout depth)
//   standoff_h      — standoff height from inside face
//   standoff_od     — standoff outer diameter
//   standoff_id     — standoff inner diameter
//   cutout          — [W, D, H] chamfered cuboid to cut through the wall;
//                     set undef to skip the cutout.
//   cutout_offset   — [X, Y, Z] offset from the jack base for the cutout.
module rj45_screw_jl(host_thickness=3, standoff_h=5, standoff_od=4, standoff_id=3,
                     cutout=[20, 20, 16], cutout_offset=[0, -10, 3.1]) {
    // Ghost body preview (above the floor)
    box_preview() up(host_thickness + RJ45_BASE.z/2) rj45_screw();

    // Standoffs at screw holes
    rj45_screw() {
        attach("screw_L") standoff(h=standoff_h, od=standoff_od, id=standoff_id, anchor=TOP);
        attach("screw_R") standoff(h=standoff_h, od=standoff_od, id=standoff_id, anchor=TOP);
    }

    // Cutout through the wall (if requested)
    if (!is_undef(cutout)) {
        box_cut() move(cutout_offset) cuboid(cutout, anchor=BOTTOM, chamfer=3);
    }
}

if (is_undef(_skip_render)) rj45_screw_jl();
