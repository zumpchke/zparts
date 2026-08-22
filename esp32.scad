include <BOSL2/std.scad>
include <jl_scad/box.scad>
use <jl_scad/parts.scad>

// ESP32-WROOM module
// Dimensions: 51.74 x 29 x 15mm, four M3 mounting holes in corners.
//
//   esp32()                                      Standalone / attachable footprint.
//                                                Ghost cuboid + four mount anchors.
//   esp32_jl(standoff_h, standoff_od,            jl_scad box_part(...) drop-in.
//            standoff_id)                        Ghost above floor; four standoffs
//                                                rising from the inside face.

$fn = 32;

ESP_W = 51.74;
ESP_D = 29;
ESP_H = 15;
ESP_MOUNT_X = ESP_W/2 - 2.4;   // 23.47
ESP_MOUNT_Y = ESP_D/2 - 2.23;   // 12.27
ESP_MOUNT_HOLE_D = 3.2;         // M3 clearance

ESP_MOUNT_POS = [
    [-ESP_MOUNT_X, -ESP_MOUNT_Y],
    [ ESP_MOUNT_X, -ESP_MOUNT_Y],
    [-ESP_MOUNT_X,  ESP_MOUNT_Y],
    [ ESP_MOUNT_X,  ESP_MOUNT_Y],
];
ESP_MOUNT_NAMES = ["mount_BL", "mount_BR", "mount_TL", "mount_TR"];

module esp32(anchor=CENTER, spin=0, orient=UP) {
    anchors = [
        for (i = idx(ESP_MOUNT_POS))
            named_anchor(ESP_MOUNT_NAMES[i],
                         [ESP_MOUNT_POS[i].x, ESP_MOUNT_POS[i].y, -ESP_H/2], DOWN)
    ];
    attachable(anchor, spin, orient, size=[ESP_W, ESP_D, ESP_H], anchors=anchors) {
        tag_this("ghost") cuboid([ESP_W, ESP_D, ESP_H]);
        children();
    }
}

module esp32_jl(standoff_h=5, standoff_od=5, standoff_id=ESP_MOUNT_HOLE_D) {
    box_preview() up(standoff_h + ESP_H/2) cuboid([ESP_W, ESP_D, ESP_H]);
    for (p = ESP_MOUNT_POS)
        translate([p.x, p.y, 0])
            standoff(h=standoff_h, od=standoff_od, id=standoff_id, fillet=2);
}

// Standalone test: flat surface + jl standoffs + ghost body, to preview
// how the module looks mounted on a box floor.
module esp32_test() {
    color("steelblue", 0.3) cuboid([ESP_W*1.125, ESP_D*1.125, 3], anchor=TOP);
    esp32_jl();
}

if (is_undef(_skip_render)) esp32_test();