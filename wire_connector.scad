include <BOSL2/std.scad>
use <jl_scad/parts.scad>
include <BOSL2/screws.scad>
// 2-pin spring clamp wire connector (no-solder splice)
// Dimensions: 19.4 x 17.2 x 13.2mm

// Central block: 4mm
// Hole size: 3mm

$fn = 32;
$slop = 0.1;

WC_W = 19.4;
WC_D = 17.2;
WC_H = 13.2;
WC_HOLE_D = 3;          // central through-hole diameter (M3 clearance)
WC_CRADLE_WALL = 1.5;  // rect_tube wall thickness
WC_CRADLE_H = 3;        // rect_tube height
WC_CRADLE_EXTRA = WC_CRADLE_WALL * 2;  // extra beyond body (slop added at render time)
// Effective footprint including cradle (add 2*get_slop() at render time)
WC_EFF_W = WC_W + WC_CRADLE_EXTRA;
WC_EFF_D = WC_D + WC_CRADLE_EXTRA;
WC_EFF_H = WC_H + WC_CRADLE_H;

module base_connector(anchors=[], anchor=CENTER, spin=0, orient=UP) {
    attachable(anchor, spin, orient, size=[WC_W, WC_D, WC_H], anchors=anchors) {
        union() {
            // ghost body with pass-through hole; hideable via hide("ghost")
            diff() {
                tag("ghost") cuboid([WC_W, WC_D, WC_H]);
                tag("remove") cyl(d=WC_HOLE_D, h=WC_H+2);
            }
            // cradle wraps up around the body from the mount face; always visible
            down(WC_H/2) rect_tube(
                h=WC_CRADLE_H,
                size=[WC_W + WC_CRADLE_EXTRA + 2*get_slop(),
                      WC_D + WC_CRADLE_EXTRA + 2*get_slop()],
                wall=WC_CRADLE_WALL, rounding=1, anchor=BOTTOM);
        }
        children();
    }
}

module wire_connector() {
    anchors = [
        named_anchor("mount",  [0, 0, -WC_H/2], DOWN),
        named_anchor("screw",  [0, 0,  WC_H/2], UP),
    ];
    base_connector(anchors=anchors) children();
}

// _skip_render set before include suppresses standalone render
//if(!_skip_render) wire_connector();


module wire_connector_test() {
    plate_h = 3;
    diff() cuboid([25, 25, plate_h]) {
        attach(TOP, "mount") hide("ghost") wire_connector()
            attach("screw", BOT) tag("ghost") nut("M3");
        // M3 clearance hole through the plate, counterbored 2mm on the underside
        // for a flush button head
        attach(BOTTOM, TOP, inside=true, shiftout=0.01)
            screw_hole("M3,20", head="button", counterbore=2);
    }
}

wire_connector_test();


