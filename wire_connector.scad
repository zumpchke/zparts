include <BOSL2/std.scad>

// 2-pin spring clamp wire connector (no-solder splice)
// Dimensions: 19.4 x 17.2 x 13.2mm

// Central block: 4mm
// Hole size: 3mm

$fn = 32;
$slop = 0.1;

WC_W = 19.4;
WC_D = 17.2;
WC_H = 13.2;

module base_connector(anchors=[], anchor=CENTER, spin=0, orient=UP) {
    wall = 1.5;
    attachable(anchor, spin, orient, size=[WC_W, WC_D, WC_H], anchors=anchors) {
        cuboid([WC_W, WC_D, WC_H]) {
            position(BOTTOM)
                rect_tube(h=3, size=[WC_W + wall*2 + 2*get_slop(), WC_D + wall*2 + 2*get_slop()], wall=wall, rounding=1);
        }
        children();
    }
}

module wire_connector() {
    anchors = [
        named_anchor("mount", [0, 0, -WC_H/2], DOWN)
    ];
    base_connector(anchors=anchors) children();
}

wire_connector();