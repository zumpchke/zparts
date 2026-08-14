include <BOSL2/std.scad>
include <BOSL2/screws.scad>
use <jl_scad/box.scad>

// 2-pin spring clamp wire connector (no-solder splice)
// Dimensions: 19.4 x 17.2 x 13.2mm  (central through-hole is 3mm)
//
//   wire_connector()                          Standalone / attachable footprint.
//                                             Ghost body + cradle + anchors.
//                                             No parent cutters.
//   wire_connector_jl(host_thickness=T)       jl_scad box_part(...) drop-in.
//                                             Ghost in box_preview; cradle as
//                                             printed geometry; cutters via
//                                             box_cut. Origin sits on the
//                                             box's inside face.

$fn = 32;
$slop = 0.1;

WC_W = 19.4;
WC_D = 17.2;
WC_H = 13.2;
WC_CRADLE_WALL = 1.5;
WC_CRADLE_H = 3;
WC_CRADLE_EXTRA = WC_CRADLE_WALL * 2;
WC_EFF_W = WC_W + WC_CRADLE_EXTRA;
WC_EFF_D = WC_D + WC_CRADLE_EXTRA;
WC_EFF_H = WC_H + WC_CRADLE_H;
WC_M3_CLEAR_NOM = 3.4;  // nominal M3 clearance diameter
WC_M3_NUT_TH_NOM = 2.4; // nominal M3 nut pocket depth
WC_TOLERANCE = 1.05;    // 3D print tolerance multiplier (elephant's foot, layer adhesion)
WC_M3_CLEAR_D = WC_M3_CLEAR_NOM * WC_TOLERANCE;
WC_M3_NUT_TH  = WC_M3_NUT_TH_NOM * WC_TOLERANCE;

module _wc_cradle() {
    rect_tube(h=WC_CRADLE_H,
              size=[WC_W + WC_CRADLE_EXTRA + 2*get_slop(),
                    WC_D + WC_CRADLE_EXTRA + 2*get_slop()],
              wall=WC_CRADLE_WALL, rounding=1, anchor=BOTTOM);
}

module wire_connector(anchor=CENTER, spin=0, orient=UP) {
    anchors = [
        named_anchor("mount", [0, 0, -WC_H/2], DOWN),
        named_anchor("screw", [0, 0,  WC_H/2], UP),
    ];
    attachable(anchor, spin, orient, size=[WC_W, WC_D, WC_H], anchors=anchors) {
        union() {
            tag_this("ghost") cuboid([WC_W, WC_D, WC_H]);
            down(WC_H/2) _wc_cradle();
        }
        children();
    }
}

module wire_connector_jl(host_thickness) {
    // ghost body — preview only
    box_preview() up(WC_H/2) cuboid([WC_W, WC_D, WC_H]);
    // cradle — real printed geometry
    _wc_cradle();
    // cutters — subtracted from the box wall via jl_scad's implicit diff
    box_cut() {
        down(host_thickness/2)
            cyl(d=WC_M3_CLEAR_D + 2*get_slop(), h=host_thickness + 0.2);
        down(host_thickness - WC_M3_NUT_TH/2)
            nut_trap_inline(l=WC_M3_NUT_TH + 2*get_slop(),
                            spec="M3", anchor=CENTER);
    }
}

// Standalone test: floor plate with clearance hole + nut trap cut through it,
// cradle on top, ghost body above. Demonstrates the full jl_scad mounting
// pattern without needing a box shell.
module wire_connector_test() {
    host = 3;
    // floor plate with cutouts
    diff() {
        cuboid([WC_EFF_W*1.125, WC_EFF_D*1.125, host], anchor=TOP);
        // clearance hole through the floor
        tag("remove") down(host/2)
            cyl(d=WC_M3_CLEAR_D + 2*get_slop(), h=host + 0.2);
        // nut trap pocket, cut up into the plate from the bottom face
        tag("remove") down(host + 0.01)
            nut_trap_inline(l=WC_M3_NUT_TH + 2*get_slop(),
                            spec="M3", anchor=BOTTOM);
    }
    // cradle on floor (real printed geometry)
    _wc_cradle();
    // ghost body, shown translucent so the cradle/cutouts read clearly
    %up(WC_H/2) cuboid([WC_W, WC_D, WC_H]);
}

if(is_undef(_skip_render)) wire_connector_test();
