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

// Raw ghost geometry: plate + body + through-holes. Untagged — caller
// (rj45_screw or rj45_screw_jl) chooses the tag context (ghost vs box_keep).
// Centered on the assembly at origin.
module _rj45_ghost() {
    total_h = RJ45_BASE.z + RJ45_BODY.z;
    down(total_h/2) diff() {
        cuboid(RJ45_BASE, anchor=BOTTOM) {
            tag("remove") move([-RJ45_HOLE_X, RJ45_HOLE_Y]) cyl(d=RJ45_HOLE_D, h=RJ45_BASE.z*3);
            tag("remove") move([ RJ45_HOLE_X, RJ45_HOLE_Y]) cyl(d=RJ45_HOLE_D, h=RJ45_BASE.z*3);
            position(TOP+FRONT) cuboid(RJ45_BODY, anchor=BOTTOM+FRONT);
        }
    }
}

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
        tag_this("ghost") _rj45_ghost();
        children();
    }
}

// RJ45 for jl_scad box projects. Assumes floor-mount: origin sits on the box's
// inside floor face with Z pointing into the box interior. The RJ45 breakout
// board's socket sticks out in the -Y direction (toward FRONT); the plug port
// cutout extends -Y from the body's back face, punching through whatever
// wall is in front.
//   host_thickness — floor thickness (for M3 clearance shafts under standoffs)
//   port_reach     — how far the port cutout extends past the body's BACK face
//                    in -Y. Must be large enough to reach through the front
//                    wall from wherever the RJ45 is placed. Default 25mm.
//   standoff_h/od/id — mounting standoff dimensions
module rj45_screw_jl(host_thickness=3, port_reach=25,
                     standoff_h=5, standoff_od=5, standoff_id=3) {
    total_h = RJ45_BASE.z + RJ45_BODY.z;
    body_center_z = standoff_h + RJ45_BASE.z + RJ45_BODY.z/2;
    body_back_y = -RJ45_BASE.y/2 + RJ45_BODY.y;    // rj45 local Y of body's back

    // Ghost body preview (protected from cutouts via BOX_KEEP_TAG)
    box_preview() up(standoff_h + total_h/2) _rj45_ghost();

    // Standoffs at each mount hole, rising from origin to plate underside
    for (pos = [[-RJ45_HOLE_X, RJ45_HOLE_Y], [RJ45_HOLE_X, RJ45_HOLE_Y]])
        move(pos) standoff(h=standoff_h, od=standoff_od, id=standoff_id, fillet=2);

    box_cut() {
        // Plug port cutout: rectangular tunnel at body's XZ cross-section,
        // running from body BACK forward (-Y) through the wall in front.
        move([0, body_back_y, body_center_z])
            cuboid([RJ45_BODY.x + 1, RJ45_BODY.y + port_reach, RJ45_BODY.z + 1],
                   anchor=BACK, chamfer=1);
    }
}

if (is_undef(_skip_render)) rj45_screw_jl();
