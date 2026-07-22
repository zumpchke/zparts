include <BOSL2/std.scad>

// 2-pin spring clamp wire connector (no-solder splice)
// Dimensions: 19.4 x 17.2 x 13.2mm

WC_W = 19.4;
WC_D = 17.2;
WC_H = 13.2;

module wire_connector(anchors=[], anchor=CENTER, spin=0, orient=UP) {
    my_anchors = [
        named_anchor("mount", [0, 0, -WC_H/2], DOWN),
        named_anchor("pin1", [-4, 0, WC_H/2], UP),
        named_anchor("pin2", [4, 0, WC_H/2], UP)
    ] + anchors;
    
    attachable(anchor, spin, orient, size=[WC_W, WC_D, WC_H], anchors=my_anchors) {
        cuboid([WC_W, WC_D, WC_H], anchor=BOTTOM);
        children();
    }
}

// Example: mount to a surface
wire_connector() {
    attach("mount") cyl(d=4, h=10, anchor=CENTER);
}
