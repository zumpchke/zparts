include <BOSL2/std.scad>

// Breadboard dimensions (half-size, 170 holes)
BB_W = 55.5;
BB_D = 83.3;
BB_H = 9.1;

// Mounting hole positions (relative to breadboard center, after 90 deg X rotation)
BB_MOUNT_Y = 18.75;
BB_MOUNT_Z = -4.5;

module breadboard(anchors=[], anchor=CENTER, spin=0, orient=UP) {
    attachable(anchor, spin, orient, size=[BB_D, BB_W, BB_H], anchors=anchors) {
        rotate([90, 0, 0])
            import("raw/Mini-Breadboard YELLOW-2.stl");
        children();
    }
}

module smallbb() {
    anchors = [
        named_anchor("mount_TL", [0, BB_MOUNT_Y, BB_MOUNT_Z], UP),
        named_anchor("mount_TR", [0, -BB_MOUNT_Y, BB_MOUNT_Z], UP),
    ];
    breadboard(anchors=anchors) children();
}

// Example: external code placing standoffs at the anchors
smallbb() {
    attach("mount_TL") cyl(d=4, h=5, anchor=CENTER);
    attach("mount_TR") cyl(d=4, h=5, anchor=CENTER);
}