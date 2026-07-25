include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// 2-pin spring clamp wire connector (no-solder splice)
// Dimensions: 19.4 x 17.2 x 13.2mm
//
// Drop-in mount: bolt enters from above via "screw" anchor, passes through
// the connector body, through the parent, and threads into a captive M3
// nut trapped on the parent's far face.
//
// Consumer constraints:
//   - The parent MUST be wrapped in diff() — the connector emits tag("remove")
//     cutters via expose_tags=true, which need a diff scope to subtract.
//   - Pass host_thickness matching the parent's Z-extent along the mount
//     normal so the nut pocket lands on the far face.
//   - Pass mount_cut=false (or omit host_thickness) to disable the cutters.

$fn = 32;
$slop = 0.1;

WC_W = 19.4;
WC_D = 17.2;
WC_H = 13.2;
WC_HOLE_D = 3;              // central through-hole in the connector body
WC_CRADLE_WALL = 1.5;
WC_CRADLE_H = 3;
WC_CRADLE_EXTRA = WC_CRADLE_WALL * 2;
WC_EFF_W = WC_W + WC_CRADLE_EXTRA;
WC_EFF_D = WC_D + WC_CRADLE_EXTRA;
WC_EFF_H = WC_H + WC_CRADLE_H;
WC_M3_CLEAR_D = 3.4;        // M3 clearance shaft
WC_M3_NUT_TH  = 2.4;        // ISO 4032 M3 hex nut thickness

module wire_connector(host_thickness, mount_cut=true, anchor=CENTER, spin=0, orient=UP) {
    anchors = [
        named_anchor("mount", [0, 0, -WC_H/2], DOWN),
        named_anchor("screw", [0, 0,  WC_H/2], UP),
    ];
    attachable(anchor, spin, orient, size=[WC_W, WC_D, WC_H],
               anchors=anchors, expose_tags=true) {
        union() {
            // ghost body — hideable via hide("ghost")
            tag_this("ghost") cuboid([WC_W, WC_D, WC_H]);
            // connector's own M3 through-hole
            tag("remove") cyl(d=WC_M3_CLEAR_D + 2*get_slop(), h=WC_H + 2);
            // cradle wraps up around the body from the mount face
            down(WC_H/2) rect_tube(
                h=WC_CRADLE_H,
                size=[WC_W + WC_CRADLE_EXTRA + 2*get_slop(),
                      WC_D + WC_CRADLE_EXTRA + 2*get_slop()],
                wall=WC_CRADLE_WALL, rounding=1, anchor=BOTTOM);
            // cutters carried into the parent via expose_tags=true
            if (mount_cut && !is_undef(host_thickness))
                down(WC_H/2) {
                    // M3 clearance shaft through the full parent thickness
                    tag("remove") down(host_thickness/2)
                        cyl(d=WC_M3_CLEAR_D + 2*get_slop(),
                            h=host_thickness + 0.2);
                    // captive hex nut pocket, opens on the parent's far face
                    tag("remove") down(host_thickness - WC_M3_NUT_TH/2)
                        nut_trap_inline(l=WC_M3_NUT_TH + 2*get_slop(),
                                        spec="M3", anchor=CENTER);
                }
        }
        children();
    }
}

// Test: drop-in against a 5mm plate. Parent wraps in diff(); connector emits
// its own clearance shaft + nut pocket at the mount site.
module wire_connector_test() {
    diff() cuboid([25, 25, 3])
        attach(TOP, "mount") hide("ghost")
            wire_connector(host_thickness=3)
                attach("screw", BOT) tag("ghost") screw("M3,15", head="button");
}

if(is_undef(_skip_render)) wire_connector_test();
